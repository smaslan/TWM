function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm TWM-PWRTEST.
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
         
    if cfg.u_is_diff || cfg.i_is_diff
        % Input data 'y' is differential: if it is not allowed, put error message here
        %error('Differential input data ''y'' not allowed!');     
    end
    
    if cfg.is_multi
        % Input data 'y' contains more than one record: if it is not allowed, put error message here
        error('Multiple input records in ''y'' not allowed!'); 
    end
    
    % Rebuild TWM style correction tables:
    % This is not necessary, but the TWM style tables are more comfortable to use then raw correction matrices
    tab = qwtb_restore_correction_tables(datain,cfg);
    
    
    
    % --------------------------------------------------------------------
    % Now we are ready to do whatever the algorithm should do ...
    % Replace following code by whatever algorithm you like.
    % --------------------------------------------------------------------
    %
    % Following example code is very simple calculator of RMS power 
    % for non-coherently sampled waveforms.
    % It uses windowed time-integration technique which should work
    % for at least 8 periods of the fundamental component per record.
    %
    % Note it supports single-ended and differential input.
    %
    % Note the algorithm does adc/transducer/aperture/cable corrections
    % only for the dominant harmonic component of the signal.
    % Therefore, the results for signals with many harmonics of comparable
    % amplitudes will be inacurrate! 
    % Also it does only very lazy phase correction of the digitizers
    % by resampling in time using 'spline' method.  
    % 
    %
    % TODO:
    %  - uncertainty estimation at least from corrections
    %    
    
    
    % --- For easier processing we convert u/i channels to virtual channels array ---
    % so we can process the voltage and current using the same code...   
        
    % list of involved correction tables without 'u_' or 'i_' prefices
    tab_list = {'tr_gain','tr_phi','tr_Zca','tr_Yca','tr_Zcal','tr_Zcam','adc_Yin','lo_adc_Yin','Zcb','Ycb','tr_Zlo','adc_gain','adc_phi','lo_adc_gain','lo_adc_phi'};
    clear vcl; id = 0; % virt. chn. list     
    % -- build virtual channel (U):
    id = id + 1;
    vcl{id}.tran = 'rvd';
    vcl{id}.is_diff = cfg.u_is_diff;
    vcl{id}.y = datain.u.v;
    vcl{id}.ap_corr = datain.u_adc_aper_corr.v;
    if cfg.u_is_diff
        vcl{id}.y_lo = datain.u_lo.v;
        vcl{id}.tsh_lo = datain.u_time_shift_lo; % low-high side channel time shift
        vcl{id}.ap_corr_lo = datain.u_lo_adc_aper_corr.v;    
    end        
    vcl{id}.tab = conv_vchn_tabs(tab,'u',tab_list);       
    vcl{id}.tsh = 0; % high-side channel shift (do not change!)    
    % -- build virtual channel (I):
    id = id + 1;
    vcl{id}.tran = 'shunt';
    vcl{id}.is_diff = cfg.i_is_diff;
    vcl{id}.y = datain.i.v;
    vcl{id}.ap_corr = datain.i_adc_aper_corr.v;
    if cfg.i_is_diff
        vcl{id}.y_lo = datain.i_lo.v;
        vcl{id}.tsh_lo = datain.i_time_shift_lo;
        vcl{id}.ap_corr_lo = datain.i_lo_adc_aper_corr.v;
    end            
    vcl{id}.tab = conv_vchn_tabs(tab,'i',tab_list);    
    vcl{id}.tsh = 0; % high-side channel shift (do not change!)
    
    
    
    % --- Find dominant harmonic component --- 
     
    % --- get channel spectra:    
    % for each virtual (u/i) channel:
    for k = 1:numel(vcl)
        % get channel:
        vc = vcl{k};
        
        % estimate dominant harmonic component:
        [vc.f0, vc.A0] = PSFE(vc.y, 1/fs);
        
        % get spectrum:
        [fh, vc.Y, vc.ph] = ampphspectrum(vc.y, fs, 0, 0, 'flattop_matlab', [], 0);
        
        if vc.is_diff
            % get low-side spectrum:
            [fh, vc.Y_lo, vc.ph_lo] = ampphspectrum(vc.y_lo, fs, 0, 0, 'flattop_matlab', [], 0);
        end
        
        vcl{k} = vc;
    end
    
    % --- estimate dominant power component:
    
    % select larger of the u/i amplitudes:
    A = [vcl{1}.A0 vcl{2}.A0];
    [v,id] = max(A);
    % use the estimates dominant harmonic frequency:    
    f0 = vcl{id}.f0
    
    % get id of the dominant DFT bin coresponding to 'f0':
    [v,fid] = min(abs(f0 - fh));
    
    
    
    
    % --- Process the channels with corrections ---
        
    % get ADC aperture value [s]:
    ta = abs(datain.adc_aper.v);
    
    % calculate aperture gain/phase correction (for f0):
    ap_gain = (pi*ta*f0)./sin(pi*ta*f0);
    ap_phi  =  pi*ta*f0; % phase is not needed - should be identical for all channels
         
    
    % --- for each virtual (u/i) channel:
    for k = 1:numel(vcl)
        % get channel:
        vc = vcl{k};
        
        % dominant component vector:
        A0  = vc.Y(fid);
        ph0 = vc.ph(fid);
        
        % get gain/phase correction for the dominant component (high-side ADC):
        ag = correction_interp_table(vc.tab.adc_gain, A0, f0);
        ap = correction_interp_table(vc.tab.adc_phi,  A0, f0);
        
        % apply high-side gain:
        vc.y = vc.y.*ag.gain; % to time-domain signal        
        
        % apply aperture corrections (when enabled and some non-zero value entered for the aperture time):
        if vc.ap_corr && ta > 1e-12 
            vc.y = vc.y.*ap_gain;               
        end         
                
        
        if vc.is_diff
            % -- differential mode:
        
            % dominant component vector (low-side):
            A0_lo  = vc.Y_lo(fid);
            ph0_lo = vc.ph_lo(fid);
            
            % get gain/phase correction for the dominant component (low-side ADC):
            ag =  correction_interp_table(vc.tab.lo_adc_gain, A0_lo, f0);
            apl = correction_interp_table(vc.tab.lo_adc_phi,  A0_lo, f0);
            
            % apply high-side gain:
            vc.y_lo = vc.y_lo.*ag.gain; % to time-domain signal
            
            % apply aperture corrections (when enabled and some non-zero value entered for the aperture time):
            if vc.ap_corr_lo && ta > 1e-12 
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
                     
            % store high-side channel timeshift:
            % note: this is needed to correctly align u/i channels 
            lo_ph_t = -thi(ida);
            vc.tsh = lo_ph_t*(lo_ph_t < 0);
            
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
            Y0    = A0.*exp(j*ph0);
            Y0_lo = A0_lo.*exp(j*ph0_lo);
            [trg,trp,u_trg] = correction_transducer_loading(vc.tab,vc.tran,f0,[], A0,ph0,0,0, A0_lo,ph0_lo,0,0);            
            trg = trg./abs(Y0 - Y0_lo);
            trp = trp - angle(Y0 - Y0_lo);
            
        else
            % -- single-ended mode:
        
            % estimate transducer correction tfer for dominant component 'f0':
            % note: corrector estimates rms just from the component 'f0', so it may not be accurate
            [trg,trp,u_trg] = correction_transducer_loading(vc.tab,vc.tran,f0,[],A0,0,0,0);
            trg = trg./A0;
        
        end        
        
        % apply transducer correction:
        vc.y = vc.y.*trg; % to time-domain signal        
                
        % store total v.channel timeshift:
        vc.tsh = vc.tsh + (trp + ap.phi)/2/pi/f0;
        
        if any(isnan(vc.y))
            error('Correction data have insufficient range for the signal!');
        end             
        
        vcl{k} = vc;
    end
    
    
    % --- apply interchannel u/i time shift ---
    
    % get corrected u/i:
    u = vcl{1}.y;
    i = vcl{2}.y;
    
    % align u/i to the same length:
    N = min(numel(u),numel(i));
    u = u(1:N);
    i = i(1:N);
    
    % total (i-u) timeshift:
    tsh = vcl{2}.tsh - vcl{1}.tsh - datain.time_shift.v; 
    
    % generate time vectors for u/i channels (with timeshift):
    t_max = (N-1)/fs;
    tu(:,1) = [0:N-1]/fs;
    ti      = tu + tsh;
    
    % resample the u/i waveforms to compensate timeshift:    
    imode = 'spline'; % using 'spline' mode as it shows lowest errors on harmonic waveforms
    ida = find(tu >= 0 & ti >= 0,1);
    idb = find(tu < t_max & ti < t_max,1,'last');    
    u = interp1(tu,u,tu(ida:idb),imode,'extrap');
    i = interp1(tu,i,ti(ida:idb),imode,'extrap');
    N = numel(u);
        
    % --- Calculate power ---

    % generate window for the RMS algorithm (periodic):
    w = hanning(N + 1);
    w = w(1:end-1);
    w = w(:);
    
    % calculate inverse RMS of the window (needed for scaling of the result): 
    W = mean(w.^2)^-0.5;
    
    % calculate RMS levels of u/i:
    U = W*mean((w.*u).^2).^0.5;
    I = W*mean((w.*i).^2).^0.5;
    
    % calculate RMS active power value:
    P = W^2*mean(w.^2.*u.*i);
    
    % calculate apperent power:
    S = U*I;        
    
    % calculate reactive power:
    Q = (S^2 - P^2)^0.5;
    
    % calculate power factor:
    PF = P/S;
        
    
    % --- return quantities to QWTB:
    
    % power parameters:
    dataout.U.v = U;
    dataout.I.v = I;
    dataout.P.v = P;
    dataout.S.v = S;
    dataout.Q.v = Q;
    dataout.PF.v = PF;
    
    % return spectra of the corrected waveforms:   
    [fh, dataout.spec_U.v] = ampphspectrum(u, fs, 0, 0, 'flattop_matlab', [], 0);
    [fh, dataout.spec_I.v] = ampphspectrum(i, fs, 0, 0, 'flattop_matlab', [], 0);
    dataout.spec_S.v = dataout.spec_U.v.*dataout.spec_I.v;
    dataout.spec_f.v = fh(:); 
     
    % --------------------------------------------------------------------
    % End of the demonstration algorithm.
    % --------------------------------------------------------------------
       
   
    % --- my job here is done...
          

end % function


% convert correction tables 'pfx'_list{:} to list{:}
% i.e. get rid of prefix (usually 'u_' or 'i_')
% list - names of the correction tables
% pfx - prefix without '_' 
function [tout] = conv_vchn_tabs(tin,pfx,list)
    
    tout = struct();
    for t = 1:numel(list)    
        name = [pfx '_' list{t}];
        if isfield(tin,name)
            tout = setfield(tout, list{t}, getfield(tin,name));
        end
    end
    
end





