function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm TWM-MODTDPS.
%
% See also qwtb
%
% Format input data --------------------------- %<<<1
    
    % Restore orientations of the input vectors to originals (before passing via QWTB)
    % This is critical for the correction data! 
    [datain,cfg] = qwtb_restore_twm_input_dims(datain,1);

    % try to obtain sampling rate from alternative input quantities [Hz]
    if isfield(datain, 'fs')
        fs = datain.fs.v;
    elseif isfield(datain, 'Ts')
        fs = 1/datain.Ts.v;
    else
        fs = 1/mean(diff(datain.t.v));
    end
    
    % PSFE frequency estimate mode:
    if isfield(datain, 'wave_shape') && ischar(datain.wave_shape.v)
        wave_shape = datain.wave_shape.v;
    else
        wave_shape = 'sine';
    end
    
    % timestamp phase compensation state:
    comp_err = isfield(datain, 'comp_err') && ((isnumeric(datain.comp_err.v) && datain.comp_err.v) || (ischar(datain.comp_err.v) && strcmpi(datain.comp_err.v,'on')));
         
    if cfg.y_is_diff
        % Input data 'y' is differential: if it is not allowed, put error message here
        %error('Differential input data ''y'' not allowed!');     
    end
    
    if cfg.is_multi
        % Input data 'y' contains more than one record: if it is not allowed, put error message here
        error('Multiple input records in ''y'' not allowed!'); 
    end
    
    if ~isfield(calcset, 'fetch_luts')
        % by default do not prefetch uncertainty LUT tables: 
        calcset.fetch_luts = 0;
    end
    
    % Rebuild TWM style correction tables:
    % This is not necessary but the TWM style tables are more comfortable to use then raw correction matrices
    tab = qwtb_restore_correction_tables(datain,cfg);
    
    
    % --------------------------------------------------------------------
    % Start of the algorithm
    % --------------------------------------------------------------------

    
    % build channel data to process:
    %  note: this is a residue of multichannel algorithm, only purpose is to make further processing easier     
    vc.tran = datain.tr_type.v; % transducer type
    vc.is_diff = cfg.y_is_diff; % differential transducer?
    vc.y = datain.y.v; % high-side channel sample data    
    vc.ap_corr = datain.adc_aper_corr.v; % aperture correction enabled?
    %vc.ofs = datain.adc_offset; % ADC offset voltage
    if cfg.y_is_diff
        % differential mode, low-side channel - the same paremters as for high side differential channel
        vc.y_lo = datain.y_lo.v;
        vc.tsh_lo = datain.time_shift_lo; % low-high side channel time shift
        vc.ap_corr_lo = datain.lo_adc_aper_corr.v;
        %vc.ofs_lo = datain.lo_adc_offset;    
    end
    
    
    % window type for spectrum analysis (rather do not change):
    %  note: is not used for calculation of parameters, just for some support functions
    win_type = 'flattop_matlab';
       
    
    % fix frequency sampling rate timebase error:
    fs = fs./(1 + datain.adc_freq.v);
    
    
    % --- Find dominant harmonic component --- 
     
    % estimate dominant harmonic component:
    % note: this should be carrier frequency, PSFE seems to be quite insensitive to AM modulation
    din.Ts.v = 1/fs;
    din.y.v  = vc.y;
    cset = calcset;
    cset.unc = 'none';
    cset.verbose = 0;
    dout = qwtb('PSFE',din,cset);
    %qwtb('TWM-MODTDPS','addpath'); % ###todo: fix qwtb so it does not loose the path every time another alg. is called    
    f0 = dout.f.v;
    A0 = dout.A.v;
    
       
        
    
    % get high-side spectrum:
    din = struct();
    din.fs.v = fs;
    din.window.v = win_type;
    cset.verbose = 0;
    din.y.v = vc.y;                
    dout = qwtb('SP-WFFT',din,cset);
    %qwtb('TWM-MODTDPS','addpath'); % ###todo: fix qwtb so it does not loose the path every time another alg. is called
    fh    = dout.f.v(:); % freq. vector of the DFT bins
    vc.Y  = dout.A.v(:); % amplitude vector of the DFT bins
    vc.ph = dout.ph.v(:); % phase vector of the DFT bins
    w     = dout.w.v(:); % window coefficients

    if vc.is_diff
        % get low-side spectrum:
        din.y.v = vc.y_lo;                
        dout = qwtb('SP-WFFT',din,cset);
        %qwtb('TWM-MODTDPS','addpath'); % ###todo: fix qwtb so it does not loose the path every time another alg. is called
        fh       = dout.f.v(:); % freq. vector of the DFT bins
        vc.Y_lo  = dout.A.v(:); % amplitude vector of the DFT bins
        vc.ph_lo = dout.ph.v(:); % phase vector of the DFT bins
    end
          
    % get id of the dominant DFT bin coresponding to 'f0':
    [v,fid] = min(abs(f0 - fh));
    
    
    
    % --- Process the channels with corrections ---
        
    % get ADC aperture value [s]:
    ta = abs(datain.adc_aper.v);
    
    % calculate aperture gain/phase correction (for f0):
    ap_gain = (pi*ta*f0)./sin(pi*ta*f0);
    ap_phi  =  pi*ta*f0; % phase is not needed - should be identical for all channels
         
    
        
    % dominant component vector:
    A0_hi  = vc.Y(fid);
    ph0_hi = vc.ph(fid);
    
    % get gain/phase correction for the dominant component (high-side ADC):
    ag = correction_interp_table(tab.adc_gain, A0_hi, f0);
    ap = correction_interp_table(tab.adc_phi,  A0_hi, f0);
    
    % apply high-side gain:
    vc.y = vc.y.*ag.gain; % to time-domain signal
    tot_gain = ag.gain;        
    
    % apply aperture corrections (when enabled and some non-zero value entered for the aperture time):
    if vc.ap_corr && abs(ta) > 1e-12 
        vc.y = vc.y.*ap_gain;               
    end
            
    
    if vc.is_diff
        % -- DIFFERENTIAL MODE:        
    
        % dominant component vector (low-side):
        A0_lo  = vc.Y_lo(fid);
        ph0_lo = vc.ph_lo(fid);
        
        % get gain/phase correction for the dominant component (low-side ADC):
        ag =  correction_interp_table(tab.lo_adc_gain, A0_lo, f0);
        apl = correction_interp_table(tab.lo_adc_phi,  A0_lo, f0);
        
        % apply low-side gain:
        vc.y_lo = vc.y_lo.*ag.gain; % to time-domain signal
        
        % apply aperture corrections (when enabled and some non-zero value entered for the aperture time):
        if vc.ap_corr_lo && abs(ta) > 1e-12 
            vc.y_lo = vc.y_lo.*ap_gain; % to time-domain signal                        
        end
                    
        % phase correction of the low-side channel: 
        lo_ph = apl.phi - ap.phi;
        % phase correction converted to time:
        lo_ph_t = lo_ph/2/pi/f0 + vc.tsh_lo.v;
       
        % generate time vectors for high/low-side channels (with timeshift):
        N = numel(vc.y);
        t_max    = (N-1)/fs;
        thi      = [];
        thi(:,1) = [0:N-1]/fs; % high-side
        tlo      = thi + lo_ph_t; % low-side
        
        % resample (interpolate) the high/low side waveforms to compensate timeshift:    
        imode = 'spline'; % using 'spline' mode as it shows lowest errors on harmonic waveforms
        ida = find(thi >= 0    & tlo >= 0   ,1);
        idb = find(thi < t_max & tlo < t_max,1,'last');    
        vc.y    = interp1(thi,vc.y   , thi(ida:idb), imode,'extrap');
        vc.y_lo = interp1(thi,vc.y_lo, tlo(ida:idb), imode,'extrap');
        N = numel(vc.y);
        
        % calculate hi-lo difference:            
        vc.y = vc.y - vc.y_lo; % time-domain
                                
        % estimate transducer correction tfer for dominant component 'f0':
        % note: The transfer is aproximated from windowed-FFT bins nearest to 
        %       the analyzed freq. despite the sampling was is coherent.
        %       The absolute values of the DFT bin vectors are wrong due to the window effects, 
        %       but the ratio of the high/low-side vectors is unaffected, 
        %       so they can be used to calculate the tfer which is then normalized.
        % note: the corrections is relative correction to the difference of digitizer voltages (y - y_lo)
        % note: corrector estimates rms just from the component 'f0', so it may not be accurate
        if ~isempty(vc.tran)
            Y0    = A0_hi.*exp(j*ph0_hi);
            Y0_lo = A0_lo.*exp(j*ph0_lo);
            [trg,trp] = correction_transducer_loading(tab,vc.tran,f0,[], A0_hi,ph0_hi,0,0, A0_lo,ph0_lo,0,0);            
            trg = trg./abs(Y0 - Y0_lo);
            trp = trp - angle(Y0 - Y0_lo);            
        else
            trg = 1;
            trp = 0;
        end
        
    else
        % -- single-ended mode:
            
        % estimate transducer correction tfer for dominant component 'f0':
        % note: corrector estimates rms just from the component 'f0', so it may not be accurate
        if ~isempty(vc.tran)
            [trg,trp] = correction_transducer_loading(tab,vc.tran,f0,[],A0,0,0,0);
            trg = trg./A0;
        else
            trg = 1;
            trp = 0;
        end

    
    end        
    
    % apply transducer correction:
    vc.y = vc.y.*trg; % to time-domain signal
    tot_gain = tot_gain*trg;        
    
    if any(isnan(vc.y))
        error('Correction data have insufficient range for the signal!');
    end
    
    
    % --- main algorithm start --- 
    
    % estimate the modulation:
    [me, dc,f0,A0, fm,Am,phm, n_A0,n_Am,u_f0x,u_fmx] = mod_tdps(fs,vc.y,wave_shape,comp_err,~strcmpi(calcset.unc,'none'));
    
    
    

    % --- now the fun part - estimate uncertainty ---
    
    if strcmpi(calcset.unc,'guf')
        % --- GUF + estimator:
        
        % get ADC LSB value (high-side):
        if isfield(datain,'lsb')
            % get LSB value directly
            lsb = datain.lsb.v;
        elseif isfield(datain,'adc_nrng') && isfield(datain,'adc_bits')
            % get LSB value estimate from nominal range and resolution
            lsb = 2*datain.adc_nrng.v*2^(-datain.adc_bits.v);    
        else
            error('FPNLSF, corrections: Correction data contain no information about ADC resolution+range or LSB value!');
        end
        
        if vc.is_diff
            % -- differential mode:
    
            % get adc SFDR: 
            adc_sfdr =    correction_interp_table(tab.adc_sfdr, vc.Y(fid), f0);
            adc_sfdr_lo = correction_interp_table(tab.lo_adc_sfdr, vc.Y_lo(fid), f0);
            
            % effective ADC SFDR [dB]:
            adc_sfdr = -20*log10(((vc.Y(fid)*10^(-adc_sfdr.sfdr/20))^2 + (vc.Y_lo(fid)*10^(-adc_sfdr_lo.sfdr/20))^2)^0.5/(A0/tot_gain));
            
            % get transducer SFDR:
            tr_sfdr  = correction_interp_table(tab.tr_sfdr, 2^-0.5*A0, f0);
            
            % calculate effective system SFDR:
            sfdr_sys = -20*log10(10^(-adc_sfdr/20) + 10^(-tr_sfdr.sfdr/20));
            
            
            % get ADC LSB value (low-side):
            if isfield(datain,'lo_lsb')
                % get LSB value directly
                lsb_lo = datain.lo_lsb.v;
            elseif isfield(datain,'lo_adc_nrng') && isfield(datain,'lo_adc_bits')
                % get LSB value estimate from nominal range and resolution
                lsb_lo = 2*datain.lo_adc_nrng.v*2^(-datain.lo_adc_bits.v);    
            else
                error('FPNLSF, corrections: Correction data contain no information about ADC resolution+range or LSB value!');
            end
            
            % effective LSB value:
            lsb = (lsb^2 + lsb_lo^2)^0.5*tot_gain;
            
            % recalculate spectrum from the difference signal:          
            din.y.v = vc.y;                
            dout = qwtb('SP-WFFT',din,cset);
            %qwtb('TWM-MODTDPS','addpath'); % ###todo: fix qwtb so it does not loose the path every time another alg. is called
            fh = dout.f.v(:); % freq. vector of the DFT bins
            Y  = dout.A.v(:); % amplitude vector of the DFT bins
            w  = dout.w.v(:); % window coefficients
            
            
            % effective jitter value:
            jitt = (datain.adc_jitter.v^2 + datain.lo_adc_jitter.v^2)^0.5; 
            
        else
            % -- single-ended mode:
            
            % get SFDR: 
            adc_sfdr = correction_interp_table(tab.adc_sfdr, A0/tot_gain, f0);
            tr_sfdr  = correction_interp_table(tab.tr_sfdr,  2^-0.5*A0, f0);
            
            % get system SFDR estimate:
            sfdr_sys = -20*log10(10^(-adc_sfdr.sfdr/20) + 10^(-tr_sfdr.sfdr/20));             

            % get LSB absolute value scaled to input signal:
            lsb = lsb*tot_gain;
            
            % signal spectrum:
            Y = vc.Y;
            
            % jitter value [s]:
            jitt = datain.adc_jitter.v;
            
        end
        
        % run unc. estimator: 
        unc = unc_estimate(dc,f0,A0,fm,Am,phm, numel(vc.y),fh,Y*tot_gain,fs, sfdr_sys,lsb,jitt, wave_shape,comp_err, w, calcset.fetch_luts);     
    
    else
        % -- no uncertainty:
        
        unc.df0.val = 0;
        unc.dA0.val = 0;
        unc.dfm.val = 0;
        unc.dmod.val = 0;
    
    end
    

  
    
    % build virtual list of involved freqs. (sine mod. components):
    %   note: we use it even for square
    df0 = 1e-1;
    fc =  [f0; f0+df0; f0-fm;     f0+fm];
    Ac =  [A0; A0;     0.5*Am;    0.5*Am];
    phc = [0;  0;      +pi/2-phm; -pi/2+phm];
    
    
    % revert amplitudes back to pre-corrections state:
    Ac = Ac./tot_gain;
        
    
    
    % get gain/phase correction for the dominant component (high-side ADC):
    ag = correction_interp_table(tab.adc_gain, Ac, fc, 'f', 1);
    ap = correction_interp_table(tab.adc_phi,  Ac, fc, 'f', 1);
    
    % apply digitizer tfer:            
    A0_hi = Ac.*ag.gain;
    ph0_hi = phc + ap.phi;
    u_A0_hi = Ac.*ag.u_gain;
    u_ph0_hi = phc.*ap.u_phi;
    
    % apply transducer correction:
    if ~isempty(vc.tran)
        [trg,trp,u_trg,u_trp] = correction_transducer_loading(tab,vc.tran,fc,[], A0_hi,ph0_hi,u_A0_hi,u_ph0_hi);            
        u_trg = u_trg./trg;
        trg = trg./Ac;
        trp = trp - phc;
    else
        u_trg = u_A0_hi./Ac;
        trg = A0_hi./Ac;
        trp = ph0_hi - phc;             
    end
    
    % estimate of modulating amplitude error due to phase of imperfect corrections (relative):    
    ur_Am_pc = abs(mod(diff(trp(3:end)+u_trp(3:end)) + pi,2*pi) - pi)/3^0.5;
    
    if vc.is_diff
        % DIFF mode:
        % note: uncertainty not implemented!
        
        warning('Uncertainty for diff. mode is not fully implemented!');
        
        trg = ones(3,1);
        u_trg = trg*0;        
                        
    end
    
    
    
    % carrier frequency uncertainty:
    u_f0 = f0*(unc.df0.val^2 + datain.adc_freq.u^2)^0.5;
    u_f0 = (u_f0^2 + u_f0x^2)^0.5;

    % modulating frequency uncertainty:
    u_fm = fm*(unc.dfm.val^2 + datain.adc_freq.u^2)^0.5;
    u_fm = (u_fm^2 + u_fmx^2)^0.5;
    
    % -- modulation relative unc. from corrections:
    % difference of the mean of sideband correction values from the carrier (because we used carrier freq. correction for entire signal):
    %  ###todo: this is very schmutzige solution because it does not take into account the sideband phase errors but it seems to work  
    ur_mod_a = sum((trg(3:end)/trg(1) - 1).^2).^0.5/3^0.5;
    ur_mod_b = abs(mean(trg(3:end))/trg(1) - 1)/3^0.5;
    ur_mod = mean([ur_mod_a,ur_mod_b]);
    if strcmpi(wave_shape,'rect')
        % rectangular wave mode:
        % extend the estimate by some tictoc coefficient because rectangular modulation will cause even worse errors due to much more sidebands 
        ur_mod = ur_mod*2;
    end
    
    % relative uncertainty of amplitude due to uncertainty frequency:
    ur_A_frq = u_f0/df0*abs(diff(trg(1:2)));
    
    % carrier relative unc. from corrections:
    ur_A0 = u_trg(1);
    u_A0 = A0.*ur_A0;
    u_A0 = (u_A0.^2 + n_A0.^2 + (A0*unc.dA0.val)^2 + (A0*ur_A_frq)^2).^0.5;
        
    % uncertainty of the side bands:
    ur_mod = (ur_mod.^2 + sum(u_trg(3:end).^2/3) + ur_Am_pc^2 + ur_A_frq^2).^0.5;
    ur_mod_tmp = ur_mod;
    % add parameter estimator uncertainty:
    ur_mod = (ur_mod^2 + (n_A0/A0)^2 + (n_Am/Am)^2 + unc.dmod.val^2)^0.5;
        
    % modulating amplitude abs unc.:    
    u_Am = Am.*(ur_mod_tmp.^2 + ur_A0.^2 + (n_Am/Am)^2 + (unc.dmod.val*A0/Am)^2).^0.5;
    
    
    % --- returning results ---
    
    % calc. coverage factor:
    ke = loc2covg(calcset.loc,50);
        
    % return envelope:
    dataout.env.v   = me(:);
    dataout.env_t.v = [0:numel(me)-1]'/fs;
    
    % return carrier:
    dataout.f0.v = f0;
    dataout.f0.u = u_f0*ke;
    dataout.A0.v = A0;
    dataout.A0.u = u_A0*ke;
    %dataout.dc.v = dc;
    
    % return modulation signal parameters:
    dataout.f_mod.v = fm;
    dataout.f_mod.u = u_fm*ke;
    dataout.cpm.v = 120*fm;
    dataout.cpm.u = 120*u_fm*ke;
    dataout.A_mod.v = Am;
    dataout.A_mod.u = u_Am*ke;
    dataout.mod.v = 100*Am/A0;
    dataout.mod.u = 100*ur_mod*ke;
           
    % --------------------------------------------------------------------
    % End of the demonstration algorithm.
    % --------------------------------------------------------------------


end % function



function [unc] = unc_estimate(dc,f0,A0,fm,Am,phm, N,fh,Y,fs,sfdr,lsb,jitt, wave_shape,comp_err, w, fetch_luts)
% Uncertainty estimator of the MODTDPS algorithm mod_tdps()
%  
% Usage:
%  unc = unc_estimate(dc,f0,A0,fm,Am,phm, N,fh,Y,fs,sfdr,lsb,jitt, wave_shape,comp_err, w, fetch_luts)
%
% Parameters:
%  dc - dc offset
%  f0 - carrier frequency
%  A0 - carrier amplitude
%  fm - modulating frequency
%  Am - modulating amplitude
%  phm - modulating phase [rad]
%  N - samples count in record
%  fh - DFT bin frequencies [Hz]
%  Y  - DFT bin amplitudes
%  fs - sampling rate [Hz]
%  sfdr - positive SFDR [dBc]
%  lsb - absolute resolution of the ADC
%  jitt - rms jitter of the sampling [s]
%  wave_shape - modulating waveform {'sine' or 'rect'}
%  comp_err - non-zero to enable self-compensation of the algorithm error
%  w - window coefficients used for the spectrum Y(fh) calculation
%  fetch_lust - prefetches the uncertainty LUT tables to global variables (for fast execution during validation)
%
% Returns:
%  unc.df0.val - relative frequency uncertainty
%  unc.dA0.val - relative carrier amplitude uncertainty
%  unc.dfm.val - relative modulating frequency uncertainty
%  unc.dmod.val - absolute modulation depth uncertainty
%
% The valid range of estimator depends on the precalculated lookup table.
% Current version (2018-06-21) supports ranges:
%  at least 3 periods of modulating signal
%  at least 10 samples per carrier period
%  modulation depth 0.01 to 0.99
%  modulating/carrier freq. below 0.33
%  jitter below 1e-2/f0
%  at least 4 bits per fullscale waveform
%  up to -30dBc SFDR (harmonic or interharmonic)
%
% Note there are a few gaps in the LUT so it may return error on the 
% missing spots. 
% 

    % freq. component count:
    F = numel(fh);

    % get window scaling factor:
    w_gain = mean(w);
    % get window rms:
    w_rms = mean(w.^2).^0.5;
    

    % peak signal value:
    Apk = A0 + Am + abs(dc);
    
    % DFT bins of the sine modulation freq. components:
    fid = round([f0;f0-fm;f0+fm]/fs*N) + 1;
    
    % remove harmonic DFT bins:
    wind_w = 7;
    sid = [];
    for k = 1:numel(fid)
        sid = [sid,(fid(k) - wind_w):(fid(k) + wind_w)];    
    end
    % remove them from spectrum:
    sid = unique(sid);    
    nid = setdiff([1:F],sid);
    nid = nid(nid <= F & nid > 0);
    % now 'nid' DFT bins should contain only spurrs and noise...
    
    % remove DC offset from DFT residue:
    nid = nid(nid > wind_w);
    
    % identify and remove top harmonics:
    h_max = [];
    for k = 1:50
        % find maximum:
        [h_max(k),id] = max(Y(nid));
        if isempty(id)
            break;
        end
        % identify sorounding DFT bins: 
        sid = [(nid(id) - wind_w):(nid(id) + wind_w)];
        % remove it:
        nid = setdiff(nid,sid);
        nid = nid(nid <= numel(fh) & nid > 0);
    end
    % now 'nid' should contain only residual noise and small harmonics...
    
    
    % noise level estimate from the spectrum residue to full bw.:
    if numel(nid) < 2
        Y_noise = [0];
    else
        Y_noise = interp1(fh(nid),Y(nid),fh,'nearest','extrap');
    end
    
    % estimate full bw. rms noise:    
    noise_rms = sum(0.5*Y_noise.^2).^0.5/w_rms*w_gain;
    
    % signal SFDR estimate [dB]:
    sfdr_sig = -20*log10(sum(h_max.^2)^0.5/Y(fid(1)));
    
    % select worst SFDR source [dB]:
    %  note: either user defined SFDR or measured SFDR
    sfdr = min(sfdr_sig,sfdr);    
    
    % signal RMS estimate:
    sig_rms = A0*2^-0.5;
    
    % SNR estimate:
    snr = -10*log10((noise_rms/sig_rms)^2);
    
    % SNR equivalent time jitter:
    %  note: this is because the estimator has no input for noise, so noise must be recalculated to equivalent jitter 
    tj = 10^(-snr/20)/2/pi/f0;
    
    
    ax = struct();            
    % total used ADC bits for the signal:
    ax.bits.val = log2(2*Apk/lsb);
    % jitter relative to frequency:
    ax.jitt.val = (jitt^2 + tj^2)^0.5*f0;
    % SFDR estimate: 
    ax.sfdr.val = sfdr;
    % modulating/carrier frequency ratio: 
    ax.fmf0_rat.val = fm/f0;
    % sampling rate to carrier ratio:
    ax.fsf0_rat.val = fs/f0;
    % modulating depth [-]:
    ax.modd.val = Am/A0;
    % periods count of carrier:
    ax.fm_per.val = N/fs*fm;
    
    %ax
    
    % current folder:
    mfld = [fileparts(mfilename('fullpath')) filesep()];
        
    if strcmpi(wave_shape,'sine') && comp_err
        % try to estimate uncertainty:       
        %unc = interp_lut([mfld 'sine_corr_unc.lut'],ax);
        
        if fetch_luts, global modtdps_lut_sc; else modtdps_lut_sc = []; end           
        modtdps_lut_sc = fetch_lut(modtdps_lut_sc, [mfld 'sine_corr_unc.lut']);
        unc = interp_lut(modtdps_lut_sc,ax);
        
    elseif strcmpi(wave_shape,'sine') && ~comp_err
        % try to estimate uncertainty:       
        %unc = interp_lut([mfld 'sine_ncorr_unc.lut'],ax);
        
        if fetch_luts, global modtdps_lut_snc; else modtdps_lut_snc = []; end           
        modtdps_lut_snc = fetch_lut(modtdps_lut_snc, [mfld 'sine_ncorr_unc.lut']);
        unc = interp_lut(modtdps_lut_snc,ax);
        
    elseif strcmpi(wave_shape,'rect')
        % try to estimate uncertainty:       
        %unc = interp_lut([mfld 'rect_ncorr_unc.lut'],ax);
        
        if fetch_luts, global modtdps_lut_rnc; else modtdps_lut_rnc = []; end           
        modtdps_lut_rnc = fetch_lut(modtdps_lut_rnc, [mfld 'rect_ncorr_unc.lut']);
        unc = interp_lut(modtdps_lut_rnc,ax);
 
    else
        % no uncertainty:
        
        error('Uncertainty estimator for given parameters of the algorithm is not avilable! Only ''sine'' and ''rect'' mode are available.');
        
    end
        
    % scale down to (k = 1):    
    unc.df0.val = 0.5*unc.df0.val;
    unc.dA0.val = 0.5*unc.dA0.val*1.1; % ###note: empiric extension
    unc.dfm.val = 0.5*unc.dfm.val;
    unc.dmod.val = 0.5*unc.dmod.val;

end

function [lut] = fetch_lut(lut,pth)
    if isempty(lut)
        lut = load(pth,'-mat','lut');
        lut = lut.lut;
    end
end



% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
