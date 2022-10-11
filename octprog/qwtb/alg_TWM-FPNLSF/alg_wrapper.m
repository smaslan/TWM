function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm TWM-FPNLSF.
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
    
    % get initial frequency estimate:
    f_est = datain.f_est.v;    
    
    % timestamp phase compensation state:
    %  note: this will do the phase correction by the timestamp
    tstmp_comp = isfield(datain, 'comp_timestamp') && ((isnumeric(datain.comp_timestamp.v) && datain.comp_timestamp.v) || (ischar(datain.comp_timestamp.v) && strcmpi(datain.comp_timestamp.v,'on')));
    
    % --- get ADC LSB value
    if isfield(datain,'lsb')
        % get LSB value directly
        lsb = datain.lsb.v;
    elseif isfield(datain,'adc_nrng') && isfield(datain,'adc_bits')
        % get LSB value estimate from nominal range and resolution
        lsb = 2*datain.adc_nrng.v*2^(-datain.adc_bits.v);    
    else
        error('FPNLSF, corrections: Correction data contain no information about ADC resolution+range or LSB value!');
    end
         
    if cfg.y_is_diff
        % Input data 'y' is differential: if it is not allowed, put error message here
        %error('Differential input data ''y'' not allowed!');     
    end
    
    if cfg.is_multi_records
        % Input data 'y' contains more than one record: if it is not allowed, put error message here
        error('Multiple input records in ''y'' not allowed!'); 
    end
    
    % Rebuild TWM style correction tables:
    % This is not necessary but the TWM style tables are more comfortable to use then raw correction matrices
    tab = qwtb_restore_correction_tables(datain,cfg);
    
    % this file folder:
    mfld = [fileparts(mfilename('fullpath')) filesep()];
    
    
    
    % --------------------------------------------------------------------
    % Start of the algorithm
    % --------------------------------------------------------------------
        
    % build channel data to process:
    %  note: this is a residue of multichannel algorithm, only purpose is to make further processing easier     
    vc.tran = datain.tr_type.v; % transducer type
    vc.is_diff = cfg.y_is_diff; % differential transducer?
    vc.y = datain.y.v; % high-side channel sample data    
    vc.ap_corr = datain.adc_aper_corr.v; % aperture correction enabled?
    vc.ofs = datain.adc_offset; % ADC offset voltage
    if cfg.y_is_diff
        % differential mode, low-side channel - the same paremters as for high side differential channel
        vc.y_lo = datain.y_lo.v;
        vc.tsh_lo = datain.time_shift_lo; % low-high side channel time shift
        vc.ap_corr_lo = datain.lo_adc_aper_corr.v;
        vc.ofs_lo = datain.lo_adc_offset;    
    end
        
    
    % --- Process the channels with corrections ---
    
    % samples count:
    N = numel(vc.y);
    
    % restore time vector:
    t(:,1) = [0:N-1]/fs;
        
    % get ADC aperture value [s]:
    ta = abs(datain.adc_aper.v);
    
    % fix frequency estimate by timebase error:
    f_est = f_est.*(1 + datain.adc_freq.v);
    
    % improved FPNLSF() parameters:
    cfg.max_try = 100; % max retry cycles
    cfg.max_time = 60; % max total calculation time [s]
    cfg.max_dev = 500e-6; % max rel deviation of freq. from freq. estimate [-] 
    
    % estimate signal parameters:
    [Ax, fx, phx, ox] = FPNLSF_loop(t, vc.y, f_est, calcset.verbose, cfg);    
    if isinf(fx)
        error('Fitting algorithm failed! Check waveform and initial frequency estimate accuracy! The frequency estimate should be accurate to 500 ppm.');
    end
    
        
    % store original frequency before tb. correction:
    f_org = fx;
    % apply timebase frequency correction:    
    % note: it is relative correction of timebase error, so apply inverse correction to measured f.  
    fx = fx./(1 + datain.adc_freq.v);    
    % calculate correction uncertainty (absolute):
    u_fx = fx.*datain.adc_freq.u;
    
    
    % select window type:
    win_type = 'flattop_matlab';

             
    if cfg.y_is_diff
        % --- DIFFERENTIAL TRANSDUCER MODE
        
        % This is tough one. The fitting algorithm will work only in timedomain, so the
        % the high- and low-side signals must be corrected in timedomain, then subtracted,
        % then passed to the algorithm and the result must be corrected from
        % the known ratio of high- and low-side vectors. But these vectors cannot be 
        % obtained from the fitting algorihm because it will fit different freq.
        % for low- and high-side. So the rough ratio of the low- and high-side
        % must be obtained using other method - windowed FFT. It will have error
        % for non-coherent sampling, but the error should be roughly the same for 
        % low- and high-side signal which should be enough to calculate differential
        % transducer transfer.
        
        % get high-side spectrum:
        din = struct();
        din.fs.v = fs;
        din.window.v = win_type;
        cset.verbose = 0;
        din.y.v = vc.y;                
        dout = qwtb('SP-WFFT',din,cset);
        qwtb('TWM-FPNLSF','addpath'); % ###todo: fix qwtb so it does not loose the path every time another alg. is called
        fh    = dout.f.v(:); % freq. vector of the DFT bins
        vc.Y  = dout.A.v(:); % amplitude vector of the DFT bins
        vc.ph = dout.ph.v(:); % phase vector of the DFT bins
        
        % get low-side spectrum:
        din.y.v = vc.y_lo;                
        dout = qwtb('SP-WFFT',din,cset);
        qwtb('TWM-FPNLSF','addpath'); % ###todo: fix qwtb so it does not loose the path every time another alg. is called
        fh       = dout.f.v(:); % freq. vector of the DFT bins
        vc.Y_lo  = dout.A.v(:); % amplitude vector of the DFT bins
        vc.ph_lo = dout.ph.v(:); % phase vector of the DFT bins
                
        
        % get window parameters (needed later):
        w_gain = mean(dout.w.v);        
        w_rms = mean(dout.w.v.^2).^0.5;        
        
        % identify DFT bin with the estimated freq. component:
        [v,fid] = min(abs(fh - f_est));
               
        % get rough voltage vectors for high- and low-side channels from DFT:
        A0    = vc.Y(fid);
        A0_lo = vc.Y_lo(fid);
        ph0    = vc.ph(fid);
        ph0_lo = vc.ph_lo(fid);
        
        % DC offset:
        dc    = vc.Y(1);
        dc_lo = vc.Y_lo(1);
        % estimate for ADC offset uncertainties:
        u_dc    = vc.ofs.u;
        u_dc_lo = vc.ofs_lo.u;
        
        % temporarily remove all DC offsets from signal (time domain):
        vc.y    = vc.y    - dc;
        vc.y_lo = vc.y_lo - dc_lo;        
        % fix ADC DC offsets in frequency domain:        
        dc    = dc    - vc.ofs.v;
        dc_lo = dc_lo - vc.ofs_lo.v;
        
                                        
        % get gain/phase correction for the dominant component (high-side digitizer):
        ag = correction_interp_table(tab.adc_gain, A0, fx);
        ap = correction_interp_table(tab.adc_phi,  A0, fx);        
        % get gain/phase correction for the dominant component (low-side digitizer):
        agl = correction_interp_table(tab.lo_adc_gain, A0_lo, fx);
        apl = correction_interp_table(tab.lo_adc_phi,  A0_lo, fx);
        
        % calculate aperture gain/phase correction (for fx):
        ap_gain = (pi*ta*fx)./sin(pi*ta*fx);
        ap_phi  =  pi*ta*fx;
        
        % apply aperture corrections (when enabled and some non-zero value entered for the aperture time):
        ap_pht = 0;
        if vc.ap_corr && ta > 1e-12 
            vc.y = vc.y.*ap_gain; % time domain
            ap_pht = ap_pht - ap_phi;
            A0 = A0.*ap_gain; % freq domain
            ph0 = ph0 + ap_phi;            
        end
        if vc.ap_corr_lo && ta > 1e-12 
            vc.y_lo = vc.y_lo.*ap_gain; % time domain
            ap_pht = ap_pht + ap_phi;
            A0_lo = A0_lo.*ap_gain; % freq domain
            ph0_lo = ph0_lo + ap_phi;
        end
        
        % apply digitizer gain correction to timedomain signals:
        vc.y = vc.y.*ag.gain;
        vc.y_lo = vc.y_lo.*agl.gain;
        % apply digitizer tfer to DFT vectors:
        A0    = A0.*ag.gain;
        A0_lo = A0_lo.*agl.gain;
        ph0    = ph0 + ap.phi;
        ph0_lo = ph0_lo + apl.phi;
        % apply low-side timeshift DFT vectors:      
        ph0_lo = ph0_lo - vc.tsh_lo.v*fx*2*pi;        
        % get estimate of uncertainty for the DFT vectors:        
        u_A0    = A0.*ag.u_gain;
        u_A0_lo = A0_lo.*agl.u_gain;
        u_ph0    = ap.u_phi;
        u_ph0_lo = ((apl.u_phi)^2 + (vc.tsh_lo.u*fx*2*pi)^2)^0.5;
                
        
        % phase correction of the low-side channel: 
        lo_ph = apl.phi - ap.phi + ap_pht;
        % phase correction converted to time:
        lo_ph_t = lo_ph/2/pi/fx - vc.tsh_lo.v;
       
        % generate time vectors for high/low-side channels (with timeshift):
        t_max = (N-1)/fs;
        thi = t; % high-side
        tlo = thi + lo_ph_t; % low-side
        
        % resample (interpolate) the high/low side waveforms to compensate timeshift:    
        imode = 'spline'; % using 'spline' mode as it shows lowest errors on harmonic waveforms
        ida = find(thi >= 0    & tlo >= 0   ,1);
        idb = find(thi < t_max & tlo < t_max,1,'last');
        vc.y    = interp1(thi,vc.y   ,thi(ida:idb),imode,'extrap');
        vc.y_lo = interp1(thi,vc.y_lo,tlo(ida:idb),imode,'extrap');
        t = t(ida:idb) - t(ida); % generate new time vector referenced to 0s
        N = numel(vc.y);
        
        % high-side channel phase shift:                              
        lo_ph_t = -thi(ida);
        d_ph = lo_ph_t*(lo_ph_t < 0)*fx*2*pi;
        
        % calculate hi-lo difference in timedomain:            
        vc.y = vc.y - vc.y_lo; % time-domain
        
        % get ADC DC gains:        
        dcg    = correction_interp_table(tab.adc_gain, dc, 1e-12);
        dcg_lo = correction_interp_table(tab.lo_adc_gain, dc_lo, 1e-12);
        % apply ADC DC gains:
        dc    = dc*dcg.gain;
        dc_lo = dc_lo*dcg_lo.gain; % frequency domain
        vc.y = vc.y + (dc - dc_lo); % time domain
        
        % calculate normalized transducer tfer from the DFT vectors:
        if ~isempty(vc.tran)
            Y0    = [dc A0].*exp(j*[0 ph0]);
            Y0_lo = [dc_lo A0_lo].*exp(j*[0 ph0_lo]);
            [trg,trp,u_trg,u_trp] = correction_transducer_loading(tab,vc.tran,[1e-6 fx],[], [dc A0],[0 ph0],[u_dc u_A0],[0 u_ph0], [dc_lo A0_lo],[0 ph0_lo],[u_dc_lo u_A0_lo],[0 u_ph0_lo]);           
            u_trg = u_trg./trg;
            tr = trg.*exp(j*trp);
            trg = abs(tr./(Y0 - Y0_lo));
            trp = angle(tr./(Y0 - Y0_lo));            
        else
            % no transducer defined:
            error('No transducer defined not allowed!');
%             u_trg = ((u_A0/A0)^2 + (u_A0_lo/A0_lo)^2)^0.5;
%             u_trp = (u_ph0^2 + u_ph_lo^2)^0.5;
%             trg = 1;
%             trp = 0;
        end
        
        % extract DC transdcuer gain:
        dcg = trg(1);    
        u_dcg = u_trg(1);
        
        % extract harmonic gain:
        trg = trg(2);
        trp = trp(2);
        u_trg = u_trg(2);    
        u_trp = u_trp(2);
          
        
        % estimate signal parameters (from final differential signal):            
        [Ax, fx, phx, ox] = FPNLSF_loop(t, vc.y, f_est, calcset.verbose, cfg);
        if isinf(fx)
            error('Fitting algorithm failed! Check waveform and initial frequency estimate accruacy! The frequency estimate should be accurate to 500 ppm.');
        end
        
        if strcmpi(calcset.unc,'guf')
            % GUF - use estimator:
            
            % get spectrum (differential):
            din = struct();
            din.fs.v = fs;
            din.window.v = win_type;
            cset.verbose = 0;
            din.y.v = vc.y;                
            dout = qwtb('SP-WFFT',din,cset);
            qwtb('TWM-FPNLSF','addpath'); % ###todo: fix qwtb so it does not loose the path every time another alg. is called
            fh = dout.f.v(:); % freq. vector of the DFT bins
            Y  = dout.A.v(:); % amplitude vector of the DFT bins
            w  = dout.w.v; % window coefficients
           
            % --- get ADC LSB value
            if isfield(datain,'lo_lsb')
                % get LSB value directly
                lsb_lo = datain.lo_lsb.v;
            elseif isfield(datain,'lo_adc_nrng') && isfield(datain,'lo_adc_bits')
                % get LSB value estimate from nominal range and resolution
                lsb_lo = 2*datain.lo_adc_nrng.v*2^(-datain.lo_adc_bits.v);    
            else
                error('FPNLSF, corrections: Correction data contain no information about ADC resolution+range or LSB value!');
            end
            
            % effective LSB:
            lsb_ef = Ax*((lsb/vc.Y(fid))^2 + (lsb/vc.Y_lo(fid))^2)^0.5;
            
            % get adc SFDR: 
            adc_sfdr =    correction_interp_table(tab.adc_sfdr, vc.Y(fid), fx);
            adc_sfdr_lo = correction_interp_table(tab.lo_adc_sfdr, vc.Y_lo(fid), fx);
            
            % effective ADC SFDR [dB]:
            adc_sfdr = -20*log10(((vc.Y(fid)*10^(-adc_sfdr.sfdr/20))^2 + (vc.Y_lo(fid)*10^(-adc_sfdr_lo.sfdr/20))^2)^0.5/Y(fid));
                                                                                                                           
            % get transducer SFDR:
            tr_sfdr  = correction_interp_table(tab.tr_sfdr, Ax*2^-0.5, fx);
            
            % calculate effective system SFDR:
            sfdr_sys = -20*log10(10^(-adc_sfdr/20) + 10^(-tr_sfdr.sfdr/20));
            
            % effective jitter:
            jitt = (datain.adc_jitter.v^2 + datain.lo_adc_jitter.v^2)^0.5;
            
            
            % estimate uncertainty:
            unc = unc_estimate(fh,Y,fs,N,fx,Ax,ox,lsb_ef,jitt,sfdr_sys,w);
            
            % expand uncertainty - very naive approximation of difference of two signals:
            unc.dpx.val = unc.dpx.val*1.5;
            unc.dfx.val = unc.dfx.val*1.5;
            unc.dAx.val = unc.dAx.val*1.5;
            unc.dox.val = unc.dox.val*1.5;
          
        else
            % other modes - do nothing: 
          
            unc.dpx.val = 0;
            unc.dfx.val = 0;
            unc.dAx.val = 0;
            unc.dox.val = 0;
                      
        end

        
        % apply timebase frequency correction:    
        %  note: it is relative correction of timebase error, so apply inverse correction to measured f.  
        fx = fx./(1 + datain.adc_freq.v);    
        
        % apply transducer correction:
        Ax  = Ax*trg;
        phx = phx + trp;
        ox = ox*dcg;
        
        % apply digitizer phase correction:
        % note we did just interchannel phase correction, so now we have to apply absolute phase correction
        phx = phx + ap.phi;
        % apply high-side channel timeshift phase error:
        phx = phx + d_ph;
        % apply the aperture phase correction:
        if vc.ap_corr && ta > 1e-12 
            phx = phx + ap_phi;
        end
        
        % uncertainty of the signal parameters:
        u_Ax = Ax.*u_trg;
        u_phx = u_trp;
        u_ox = ox.*u_dcg;
        
        % add alg. uncertainty contribution:
        u_Ax = (u_Ax^2 + (Ax.*unc.dAx.val)^2)^0.5;
        u_phx = (u_phx^2 + unc.dpx.val^2)^0.5;
        u_fx = (u_fx^2 + (fx*unc.dfx.val)^2)^0.5;
        u_ox = (u_ox^2 + (unc.dox.val*dcg)^2)^0.5;
        
        
    else        
        % --- SINGLE-ENDED TRANSDUCER MODE
        
        % -- uncertainty estimator:
        if strcmpi(calcset.unc,'guf')
            % GUF - use estimator:
            
            % get effective ADC + transducer SFDR:
            adc_sfdr = correction_interp_table(tab.adc_sfdr, Ax, fx);
            tr_sfdr  = correction_interp_table(tab.tr_sfdr,  Ax, fx);        
            sfdr_sys = -20*log10(10^(-adc_sfdr.sfdr/20) + 10^(-tr_sfdr.sfdr/20));
            
            % get spectrum:
            din = struct();
            din.fs.v = fs;
            din.window.v = win_type;
            cset.verbose = 0;
            din.y.v = vc.y;                
            dout = qwtb('SP-WFFT',din,cset);
            qwtb('TWM-FPNLSF','addpath'); % ###todo: fix qwtb so it does not loose the path every time another alg. is called
            fh = dout.f.v(:); % freq. vector of the DFT bins
            Y  = dout.A.v(:); % amplitude vector of the DFT bins
            w  = dout.w.v; % window coefficients

            % estimate uncertainty:
            unc = unc_estimate(fh,Y,fs,N,fx,Ax,ox,lsb,datain.adc_jitter.v,sfdr_sys,w);
          
        else
            % other modes - do nothing: 
          
            unc.dpx.val = 0;
            unc.dfx.val = 0;
            unc.dAx.val = 0;
            unc.dox.val = 0;
                      
        end
        
        % calculate aperture gain/phase correction (for f0):
        ap_gain = (pi*ta*fx)./sin(pi*ta*fx);
        ap_phi  =  pi*ta*fx;
        
        % apply aperture corrections (when enabled and some non-zero value entered for the aperture time):
        if vc.ap_corr && ta > 1e-12 
            Ax = Ax.*ap_gain;
            phx = phx + ap_phi;
        end
        
        % get gain/phase correction for the dominant component (high-side digitizer):
        ag = correction_interp_table(tab.adc_gain, Ax, fx);
        ap = correction_interp_table(tab.adc_phi,  Ax, fx);
        
        % apply gain/phase correction:
        Ax = Ax.*ag.gain;
        phx = phx + ap.phi;
        % get unc. contribution:
        u_Ax = Ax.*ag.u_gain;
        u_phx = ap.u_phi;
        
        % remove DC offset:
        ox = ox - vc.ofs.v;
                
        % add alg. uncertainty contribution:
        u_Ax = (u_Ax^2 + (Ax.*unc.dAx.val)^2)^0.5;
        u_phx = (u_phx^2 + unc.dpx.val^2)^0.5;
        u_fx = (u_fx^2 + (fx*unc.dfx.val)^2)^0.5;
        u_ox = (vc.ofs.u^2 + unc.dox.val^2)^0.5;
                
        % apply transducer tfer to signal estimates:
        [Ax,phx,u_Ax,u_phx] = correction_transducer_loading(tab,vc.tran,[1e-6 fx],[], [abs(ox) Ax],[0 phx],[u_ox u_Ax],[0 u_phx]);
        
        % extract offset:
        ox = Ax(1)*sign(ox);
        u_ox = u_Ax(1);
        
        % extract harmonic:
        Ax = Ax(2);
        u_Ax = u_Ax(2);
        phx = phx(2);        
        u_phx = u_phx(2);
        
        
    end
        
    % apply time-stamp phase correction:
    if tstmp_comp
        % note: assume frequency comming from digitizer tb., because the timestamp comes also from dig. timebase
        phx = phx - datain.time_stamp.v*f_org*2*pi;
        % calc. uncertainty contribution:
        u_p_ts = 2*pi*((datain.time_stamp.u*f_org)^2 + (datain.time_stamp.v*u_fx)^2)^0.5;
    else
        u_p_ts = 0;
    end
    % apply timestamp uncertainty to phase:
    u_phx = (u_phx^2 + u_p_ts^2)^0.5;
    
    % wrap the phase:
    phx = mod(phx + pi,2*pi) - pi;
    
    
    % calc. coverage factor:
    ke = loc2covg(calcset.loc,50);       
    
    % --- returning results ---    
    dataout.f.v = fx;
    dataout.f.u = u_fx*ke;
    dataout.A.v = Ax;
    dataout.A.u = u_Ax*ke;
    dataout.phi.v = phx;
    dataout.phi.u = u_phx*ke;
    dataout.ofs.v = ox;
    dataout.ofs.u = u_ox*ke;
           
    % --------------------------------------------------------------------
    % End of the algorithm.
    % --------------------------------------------------------------------


end % function




function [unc] = unc_estimate(fh,Y,fs,N,fx,Ax,ox,lsb,jitt,sfdr,w)
% Uncertainty estimator of the improved FPNLSF algorithm FPNLSF_loop(...,cfg)
% calculated for configuration:
%  cfg.max_try = 100; % max retry cycles
%  cfg.max_time = 60; % max total calculation time [s]
%  cfg.max_dev = 500e-6; % max rel deviation of freq. from freq. estimate [-]
% The result should not be affected by max_time and max_try, only by max_dev!
%  
% Usage:
%  [unc] = unc_estimate(fh,Y,fs,N,fx,Ax,ox,lsb,jitt,sfdr,w)
%
% Parameters:
%  fh - DFT bin frequencies
%  Y  - DFT bin amplitudes
%  fs - sampling rate [Hz]
%  N - samples count in record
%  fx - frequency of the fundamental component
%  Ax - amplitude of the fundamental component
%  ox - DC offset of the signal
%  lsb - absolute resolution of the ADC
%  jitt - rms jitter of the sampling [s]
%  sfdr - positive SFDR [dBc]
%  w - window coefficients used for the spectrum Y(fh) calculation
%
% Returns:
%  unc.dpx.val - absolute phase angle uncertainty
%  unc.dfx.val - relative frequency uncertainty
%  unc.dAx.val - relative amplitude uncertainty
%  unc.dox.val - absolute offset uncertainty
%
% The valid range of estimator depends on the precalculated lookup table.
% Current version (2018-06-20) supports ranges:
%  10 to 100 periods of the signal (higher values possible, but not tested)
%  10 to 1000 samples per period (higher values possible, should work)
%  at least 4 bits of resolution per fullscale
%  up to -30dBc SFDR
%  rms jitter up to 1e-2/f0
%
    
    % get window scaling factor:
    w_gain = mean(w);
    % get window rms:
    w_rms = mean(w.^2).^0.5;
    
    
    % harmonic components:
    fhx = [fx:fx:max(fh)];
    fid = round(fhx/fs*N) + 1;
    
    % get harmonic DFT bins:
    wind_w = 7;
    sid = [];
    for k = 1:numel(fhx)
        sid = [sid,(fid(k) - wind_w):(fid(k) + wind_w)];    
    end
    % remove them from spectrum:
    sid = unique(sid);    
    nid = setxor([1:numel(fh)],sid);
    nid = nid(nid <= numel(fh) & nid > 0);
    
    % remove top harmonics:
    for k = 1:50
        % find maximum:
        [v,id] = max(Y(nid));
        if isempty(id)
            break;
        end
        % identify surounding DFT bins: 
        sid = [(nid(id) - wind_w):(nid(id) + wind_w)];
        % remove it:
        nid = setdiff(nid,sid);
        nid = nid(nid <= numel(fh) & nid > 0);                
    end
    
    % get noise DFT bins:    
    nid = nid(nid > wind_w & nid <= numel(nid)); % get rid of DC and limit to valid range
    
    % noise level estimate from the spectrum residue to full bw.:
    if numel(nid) < 2
        Y_noise = [0];
    else
        Y_noise = interp1(fh(nid),Y(nid),fh,'nearest','extrap');
    end
    
    % estimate full bw. rms noise:    
    noise_rms = sum(0.5*Y_noise.^2).^0.5/w_rms*w_gain;
    
    % signal RMS estimate:
    sig_rms = Ax*2^-0.5;
    
    % SNR estimate:
    snr = -10*log10((noise_rms/sig_rms)^2);
    
    % SNR equivalent time jitter (yes, very nasty solution, but it should work...):
    % note: this should be equivalent jitter to the remaining noise in the signal
    %       as the estimator has no input for noise, this is possible way...
    tj = 10^(-snr/20)/2/pi/fx;
  
    % estimate SFDR of the signal:
    Y_max = sum(([Y(10:(fid-10));Y((fid + 10):end)]).^2)^0.5;
    sfdr_sig = -20*log10(Y_max/Ax);

    % total SFDR estimate:
    sfdr = min(sfdr,sfdr_sig);        
    
        
    ax = struct();            
    % periods count of 'fx' in signal:
    ax.f0_per.val = N*fx/fs;
    % sampling rate to 'fx' ratio:
    ax.fs_rat.val = fs/fx;
    % total used ADC bits for the signal:
    ax.bits.val = log2(2*(Ax + abs(ox))/lsb);
    % jitter relative to frequency:
    ax.jitt.val = (jitt^2 + tj^2)^0.5*fx;
    % SFDR estimate: 
    ax.sfdr.val = sfdr;
    
    %ax
    
    % current folder:
    mfld = [fileparts(mfilename('fullpath')) filesep()];
        
    % try to estimate uncertainty:       
    unc = interp_lut([mfld 'unc.lut'],ax);
    
    
    % scale down to (k = 1):    
    ttc = 1.2; % tic-toc safety coefficient :)
    unc.dpx.val = 0.5*unc.dpx.val*ttc;
    unc.dfx.val = 0.5*unc.dfx.val*ttc;
    unc.dAx.val = 0.5*unc.dAx.val*ttc;
    % note: the extension coeficient reflects the simulation setup, possibly should be integrated in the LUT to make it more consistent
    unc.dox.val = 0.5*unc.dox.val*ttc/Ax;

end




function [Ax, fx, phx, ox] = FPNLSF_loop(t,u,f_est,verbose,cfg)
% Wrapper for the FPNLSF algorithm.
% Retries to calculation when deviation of the fx from f_est exceeds limit.
% Also includes initial phase estimate which seems to be necessary for the 
% Octave version.
% Note the time vector 't' must start with 0.
%
% Parameters:
%   cfg.max_try - maximum retries (default 100).
%   cfg.max_time - maximum timeout (default 60s)
%   cfg.max_dev - maximum relative deviation of fit freq from f_est (default 0.0005)

    % create default setup:
    if nargin < 5
        cfg = struct();
    end
    if ~isfield(cfg,'max_try')
        cfg.max_try = 100;
    end
    if ~isfield(cfg,'max_time')
        cfg.max_time = 60;
    end
    if ~isfield(cfg,'max_dev')
        cfg.max_dev = 0.0005;
    end
    
    % initial time:
    tid = tic();
    
    % try to estimate initial phase:
    phi_zc = phase_zero_cross(u);
    
    % --- retry loop:
    for tr = 1:cfg.max_try
        
        % randomize initial guess (from second try):
        rand_p = randn(1)*0.01*pi*(tr > 1); % phase
        rand_f = cfg.max_dev*randn(1)*f_est*(tr > 1); % frequency
        rand_o = 0.001*randn(1)*(tr > 1); % offset
        
        % randomize offeset:
        ux = u + rand_o;
        
        if isinf(phi_zc)
            % failed zero-cross - generate random estimate:
            phi_est = randn(1)*pi;
        else
            % zero-cross estimate ok - tiny randomization for the retries:
            phi_est = phi_zc + rand_p; 
        end
        
        % try to fit waveform:
        %  ###todo: fix QWTB original function and call it from here via QWTB            
        [Ax, fx, phx, ox] = FPNLSF(t,ux,f_est*(1+rand_f),verbose,phi_est);
        ox = ox - rand_o;
                    
        if ~isinf(fx) && abs(fx/f_est-1) < cfg.max_dev
            % result possibly ok - leave
            fail = 0; 
            break;
        elseif tr == cfg.max_try || toc(tid) > cfg.max_time 
            disp('Warning: No convergence even after all retries! Dunno what to do now...');
            fail = 1;
            break;
        end
        % retry because we got no convergence or too high phase deviation
                   
    end
    
    if fail
        % invalidate result if retries failed:
        Ax = inf;
        fx = inf;
        phx = inf;
        ox = inf;
    end
            
end



% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
