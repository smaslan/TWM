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
    
    % initial frequency estimate:
    f_est = datain.f_est.v;    
    
    % timestamp phase compensation state:
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
    
    if cfg.is_multi
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
    
    % TODO: uncertainty!
            
    
    % build channel data to process:     
    vc.tran = datain.tr_type.v;
    vc.is_diff = cfg.y_is_diff;
    vc.y = datain.y.v;
    vc.ap_corr = datain.adc_aper_corr.v;
    if cfg.y_is_diff
        vc.y_lo = datain.y_lo.v;
        vc.tsh_lo = datain.time_shift_lo; % low-high side channel time shift
        vc.ap_corr_lo = datain.lo_adc_aper_corr.v;    
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
        error('Fitting algorithm failed! Check waveform and initial frequency estimate accruacy!');
    end
    
        
    % store original frequency before tb. correction:
    f_org = fx;
    % apply timebase frequency correction:    
    % note: it is relative correction of timebase error, so apply inverse correction to measured f.  
    fx = fx./(1 + datain.adc_freq.v);    
    % calculate correction uncertainty (absolute):
    u_fx = fx.*datain.adc_freq.u;

             
    if cfg.y_is_diff
        % --- DIFFERENTIAL TRANSDUCER MODE
        
        % This is tough one. The fitting algorithm will work only in timedomain, so the
        % the high- and low-side signals must be corrected in timedomain, then subtracted,
        % then passed to the algorithm and the result must be correction from
        % the known ratio of high- and low-side vectors. But these vectors cannot be 
        % obtained from the fitting algorihm because it will fit different freq.
        % for low- and high-side. So the rough ratio of the low- and high-side
        % must be obtained using other method - windowed FFT. It will have error
        % on for non-coherent sampling, but the error should be roughly the same for 
        % low- and high-side signal which should be enough to calculate diff. tran. tfer.
        
        % get high-side spectrum:
        [fh, vc.Y, vc.ph] = ampphspectrum(vc.y, fs, 0, 0, 'flattop_matlab', [], 0);    
        % get low-side spectrum:
        [fh, vc.Y_lo, vc.ph_lo] = ampphspectrum(vc.y_lo, fs, 0, 0, 'flattop_matlab', [], 0);
                        
        % identify DFT bin with the estimated freq. component:
        [v,fid] = min(abs(fh - f_est));
               
        
        
        % get rough voltage vectors for high- and low-side channels from DFT:
        A0    = vc.Y(fid);
        A0_lo = vc.Y_lo(fid);
        ph0    = vc.ph(fid);
        ph0_lo = vc.ph_lo(fid);
                
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

        
        % calculate normalized transducer tfer from the DFT vectors:
        if ~isempty(vc.tran)
            Y0    = A0.*exp(j*ph0);
            Y0_lo = A0_lo.*exp(j*ph0_lo);
            [trg,trp,u_trg,u_trp] = correction_transducer_loading(tab,vc.tran,fx,[], A0,ph0,u_A0,u_ph0, A0_lo,ph0_lo,u_A0_lo,u_ph0_lo);           
            u_trg = u_trg/trg;
            tr = trg.*exp(j*trp);
            trg = abs(tr./(Y0 - Y0_lo));
            trp = angle(tr./(Y0 - Y0_lo));            
            %trg = trg./abs(Y0 - Y0_lo);
            %trp = trp - angle(Y0 - Y0_lo);        
        else
            % no transducer defined:
            u_trg = ((u_A0/A0)^2 + (u_A0_lo/A0_lo)^2)^0.5;
            u_trp = (u_ph0^2 + u_ph_lo^2)^0.5;
            trg = 1;
            trp = 0;
        end
        
        
        % estimate signal parameters (from differential signal):            
        [Ax, fx, phx, ox] = FPNLSF_loop(t, vc.y, f_est, calcset.verbose, cfg);
        if isinf(fx)
            error('Fitting algorithm failed! Check waveform and initial frequency estimate accruacy!');
        end
        
        if strcmpi(calcset.unc,'guf')
            % GUF - use estimator:
            
            % --- get ADC LSB value
            if isfield(datain,'lo_lsb')
                % get LSB value directly
                lsb = datain.lo_lsb.v;
            elseif isfield(datain,'lo_adc_nrng') && isfield(datain,'lo_adc_bits')
                % get LSB value estimate from nominal range and resolution
                lsb = 2*datain.lo_adc_nrng.v*2^(-datain.lo_adc_bits.v);    
            else
                error('FPNLSF, corrections: Correction data contain no information about ADC resolution+range or LSB value!');
            end
                       
            
            % effective LSB:
            lsb_ef = ((lsb/vc.Y(fid))^2 + (lsb/vc.Y_lo(fid))^2)^0.5;
            
            
            % get spectrum:
            [fh, Y] = ampphspectrum(vc.y, fs, 0, 0, 'flattop_matlab', [], 0);
            
            % estimate uncertainty:
            unc = unc_estimate(fh,Y,fs,N,fx,Ax,ox,lsb_ef*(Ax+abs(ox)),datain.jitter.v,tab);
            
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
        
        % add alg. uncertainty contribution:
        u_Ax = (u_Ax^2 + (Ax.*unc.dAx.val)^2)^0.5;
        u_phx = (u_phx^2 + unc.dpx.val^2)^0.5;
        u_fx = (u_fx^2 + (fx*unc.dfx.val)^2)^0.5;
                
        % todo: handle the offset, it will be wrong because of the timedomain corrections at fx are not the same as for DC
        
        % todo: implement some unc. estimate even for the differential mode...
        
    else        
        % --- SINGLE-ENDED TRANSDUCER MODE
        
        % -- uncertainty estimator:
        
        
        if strcmpi(calcset.unc,'guf')
            % GUF - use estimator:
            
            % get spectrum:
            [fh, Y] = ampphspectrum(vc.y, fs, 0, 0, 'flattop_matlab', [], 0);
            
            % estimate uncertainty:
            unc = unc_estimate(fh,Y,fs,N,fx,Ax,ox,lsb,datain.jitter.v,tab);
          
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
        
        
        % add alg. uncertainty contribution:
        u_Ax = (u_Ax^2 + (Ax.*unc.dAx.val)^2)^0.5;
        u_phx = (u_phx^2 + unc.dpx.val^2)^0.5;
        u_fx = (u_fx^2 + (fx*unc.dfx.val)^2)^0.5;
                
        % apply gain correction to offset:
        % todo: decide if I should take the DC component from correction data because the correction data may not be present down to 0Hz?
        
        % apply transducer tfer to signal estimates:
        [Ax,phx,u_Ax,u_phx] = correction_transducer_loading(tab,vc.tran,fx,[], Ax,phx,u_Ax,u_phx);
        
        % apply transducer gain correction to offset:
        % todo: decide if I should take the DC component from correction data because the correction data may not be present down to 0Hz?
        
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
           
    
    % --- returning results ---    
    dataout.f.v = fx;
    dataout.f.u = u_fx;
    dataout.A.v = Ax;
    dataout.A.u = u_Ax;
    dataout.phi.v = phx;
    dataout.phi.u = u_phx;
    dataout.ofs.v = ox;
    dataout.ofs.u = 0;
           
    % --------------------------------------------------------------------
    % End of the algorithm.
    % --------------------------------------------------------------------


end % function




function [unc] = unc_estimate(fh,Y,fs,N,fx,Ax,ox,lsb,jitt,tab)
% Uncertainty estimator:
    
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
    for k = 1:20
        % find maximum:
        [v,id] = max(Y(nid));
        % identify sorounding DFT bins: 
        sid = [(nid(id) - wind_w):(nid(id) + wind_w)];
        % remove it:
        nid = setdiff(nid,sid);
        nid = nid(nid <= numel(fh) & nid > 0);                
    end   
    
    % get noise DFT bins:    
    nid = nid(nid > wind_w & nid <= numel(nid)); % get rid of DC and limit to valid range
    
    % estimate RMS of noise:
    noise_rms = sum(0.5*Y(nid).^2).^0.5;        
    noise_rms = noise_rms*(numel(fh)/numel(nid))^0.5; % expand to cover limited selection of DFT bins
    
    % signal RMS estimate:
    sig_rms = Ax*2^-0.5;
    
    % SNR estimate:
    snr = -10*log10((noise_rms/sig_rms)^2);
    
    % SNR equivalent time jitter:
    tj = 10^(-snr/20)/2/pi/fx;
  
    % estimate SFDR of the signal:
    Y_max = max([Y(10:(fid-10));Y((fid + 10):end)]);
    sfdr = -20*log10(Y_max/Ax);
    
    % estimate SFDR of the system:
    adc_sfdr = correction_interp_table(tab.adc_sfdr, Ax, fx);
    tr_sfdr  = correction_interp_table(tab.tr_sfdr,  Ax, fx);        
    sfdr_sys = -20*log10(10^(-adc_sfdr.sfdr/20) + 10^(-tr_sfdr.sfdr/20));        
    
    % total SFDR estimate:
    sfdr = min(sfdr_sys,sfdr);        
    
        
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
    
    % current folder:
    mfld = [fileparts(mfilename('fullpath')) filesep()];
        
    % try to estimate uncertainty:       
    unc = interp_lut([mfld 'unc.lut'],ax);
    
    % scale down to (k = 1):
    unc.dpx.val = 0.5*unc.dpx.val;
    unc.dfx.val = 0.5*unc.dfx.val;
    unc.dAx.val = 0.5*unc.dAx.val;
    unc.dox.val = 0.5*unc.dox.val;

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
        [Ax, fx, phx, ox] = FPNLSF(t,ux,f_est*(1+rand_f),verbose,phi_est);
        ox = ox - rand_o;
                    
        if ~isinf(fx) && abs(fx/f_est-1) < cfg.max_dev
            % result possibly ok - leave
            fail = 0; 
            break;
        elseif tr == cfg.max_try || toc(tid) > cfg.max_time 
            disp('Warning: No convergence even after all retrires! Dunno what to do now...');
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
