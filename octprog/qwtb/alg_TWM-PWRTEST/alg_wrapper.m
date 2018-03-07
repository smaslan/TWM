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
    % Note it supports single-ended and differential input, but the 
    % differential is only approximated.
    %
    % Note the algorithm does adc/transducer/aperture/cable corrections
    % only for the dominant harmonic component of the signal.
    % Therefore, the results for signals with many harmonics of comparable
    % amplitudes will be inacurrate! 
    % Also it does only very lazy phase correction of the digitizers, 
    % cables and transducers by shifting waveforms per whole samples
    % again just for the dominant component!
    %
    % TODO:
    %  - timeshift by resampling
    %  - uncertainty estimation at least from corrections
    %  - create test function
    
    
    % --- For easier use we convert u/i channels to virtual channels array ---
    % so we can process the voltage and current using the same code...
    
    %fieldnames(datain)
    
        
    tab_list = {'tr_gain','tr_phi','tr_Zca','tr_Yca','tr_Zcal','tr_Zcam','adc_Yin','lo_adc_Yin','Zcb','Ycb','tr_Zlo','adc_gain','adc_phi','lo_adc_gain','lo_adc_phi'};
    clear vcl; % virt. chn. list 
    id = 0;
    % build virtual channe (U):
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
    % build virtual channe (I):
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
        
        % get spectrum:
        [fh, vc.Y] = ampphspectrum(vc.y, fs, 0, 0, 'flattop_matlab', [], 0);
        
        % get channel voltage:    
        if vc.is_diff
            % in diff mode estimate hi-lo difference:
            y = vc.y - vc.y_lo;
        else
            y = vc.y; 
        end
        
        % get spectrum:
        [fh, vc.Yd] = ampphspectrum(y, fs, 0, 0, 'flattop_matlab', [], 0);
        
        if vc.is_diff
            % get low-side spectrum:
            [fh, vc.Y_lo] = ampphspectrum(vc.y_lo, fs, 0, 0, 'flattop_matlab', [], 0);
        end
        
        vcl{k} = vc;
    end
    
    % --- estimate dominant power component:
    
    % apparent power components:
    Sh = vcl{1}.Yd.*vcl{2}.Yd;
    
    % find dominant harmonic component:
    [v,fid] = max(Sh);
    f0 = fh(fid) % fundamental frequency
    
    
    
    
    
    % --- Process the channels with corrections ---
        
    % get ADC aperture value [s]:
    ta = abs(datain.adc_aper.v);
    
    % calculate aperture gain/phase correction (for f0):
    ap_gain = (pi*ta*f0)./sin(pi*ta*f0);
    ap_phi  =  pi*ta*f0;
         
    
    % for each virtual (u/i) channel:
    for k = 1:numel(vcl)
        % get channel:
        vc = vcl{k};
        
        % get gain/phase correction for the dominant component (high-side ADC):
        ag = correction_interp_table(vc.tab.adc_gain,vc.Y(fid),f0);
        ap = correction_interp_table(vc.tab.adc_phi,vc.Y(fid),f0);
        
        % apply high-side gain:
        vc.y = vc.y.*ag.gain; % to time-domain signal        
        vc.Y = vc.Y.*ag.gain; % to spectrum
        
        % apply aperture corrections (when enabled and some non-zero value entered for the aperture time):
        if vc.ap_corr && ta > 1e-12 
            vc.y = vc.y.*ap_gain;               
        end         
                
        % for differential mode only:
        if vc.is_diff
            % get gain/phase correction for the dominant component (low-side ADC):
            ag = correction_interp_table(vc.tab.lo_adc_gain,vc.Y(fid),f0);
            apl = correction_interp_table(vc.tab.lo_adc_phi,vc.Y(fid),f0);
            
            % apply high-side gain:
            vc.y_lo = vc.y_lo.*ag.gain; % to time-domain signal
            vc.Y_lo = vc.Y_lo.*ag.gain; % to spectrum
            
            % apply aperture corrections (when enabled and some non-zero value entered for the aperture time):
            if vc.ap_corr_lo && ta > 1e-12 
                vc.y_lo = vc.y_lo.*ap_gain; % to time-domain signal
                vc.Y_lo = vc.Y_lo.*ap_gain; % to spectrum                        
            end
            
            
            % phase correction of the low-side channel: 
            lo_ph = apl.phi - ap.phi;
            % phase correction converted to time:
            lo_ph_t = lo_ph/2/pi/f0 + vc.tsh_lo.v;
            % phase correction converted to samples count:
            lo_ph_n = round(lo_ph_t*fs);
            
            % shift the high/low channels if the shift is at least one sampling period:
            if lo_ph_n > 0
                % positive shift:                
                vc.y_lo = vc.y_lo(1+lo_ph_n:end)
                vc.y    = vc.y(1:end-lo_ph_n);
            elseif lo_ph_n < 0
                % negative shift:
                vc.y_lo = vc.y_lo(1:end+lo_ph_n)
                vc.y    = vc.y(1-lo_ph_n:end);
                % store high-side channel time shift for the u/i channel shift calculation!
                vc.tsh  = lo_ph_n/fs;
            end
            
            % calculate hi-lo difference:            
            vc.y = vc.y - vc.y_lo; % time-domain
            vc.Y = vc.Y - vc.Y_lo; % spectrum
            
        end        
        
        % estimate transducer correction tfer for dominant component 'f0':
        % note we ignore the differential mode because we don't know low/high-side voltage vectors...
        % so for differential mode we will use single-ended mode as well 
        [trg,trp,u_trg] = correction_transducer_loading(vc.tab,vc.tran,f0,[],1,0,0,0);
        
        % apply transducer correction:
        vc.y = vc.y.*trg; % to time-domain signal        
        vc.Y = vc.Y.*trg; % to spectrum
                
        % store v.channel timeshift:
        vc.tsh = vc.tsh + trp/2/pi/f0;
        
        if any(isnan(vc.y))
            error('Correction data have insufficient range for the signal!');
        end             
        
        vcl{k} = vc;
    end
    
    
    % --- apply interchannel u/i time shift ---
    
    % get corrected u/i:
    u = vcl{1}.y;
    i = vcl{2}.y;
    
    % total (i-u) timeshift:
    tsh = vcl{1}.tsh - vcl{2}.tsh + datain.time_shift.v;  
    % round to sampling periods:
    tsh_n = round(tsh*fs);
    
    % shift the u/i channels if the shift is at least one sampling period: 
    if tsh_n > 0
        u = u(1:end-tsh_n);
        i = i(1+tsh_n:end);            
    elseif tsh_n < 0
        u = u(1-tsh_n:end);
        i = i(1:end+tsh_n);
    end
    
    % align u/i to the same length:
    N = min(numel(u),numel(i));
    u = u(1:N);
    i = i(1:N);
    
    
    
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
    
    % raw spectra:
    dataout.spec_f.v = fh(:);
    dataout.spec_S.v = vcl{1}.Y.*vcl{2}.Y;
    dataout.spec_U.v = vcl{1}.Y;
    dataout.spec_I.v = vcl{2}.Y;
    
    
     
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





