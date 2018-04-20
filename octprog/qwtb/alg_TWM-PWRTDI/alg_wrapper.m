function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm TWM-PWRTDI.
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
    % RMS power calculation using time-domain-integration (TDI) of 
    % windowed u/i signals.    
    % Frequency dependent corrections of the gain/phase are made using
    % FFT filtering. The filtering method is based on the JV's 
    % sampling wattmeter.
    %
    % TODO:
    %  - implement gain/phase corrections
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
    

    % corrections interpolation mode:
    i_mode = 'pchip';
    
    % samples count:
    N = size(datain.u.v,1);    

    % size of the FFT filter:
    %  note: should be selected automatically based on the source samples count
    fft_size = 2^nextpow2(N/4);
    
    
    % --- Find dominant harmonic component --- 
     
    % --- get channel spectra:    
    % for each virtual (u/i) channel:
    for k = 1:numel(vcl)
        % get channel:
        vc = vcl{k};
        
        % get spectrum:
        [fh, vc.Y, vc.ph] = ampphspectrum(vc.y, fs, 0, 0, 'flattop_248D', [], 0);
        
        if vc.is_diff
            % get low-side spectrum:
            [fh, vc.Y_lo, vc.ph_lo] = ampphspectrum(vc.y_lo, fs, 0, 0, 'flattop_248D', [], 0);
        end
        
        vcl{k} = vc;
    end
    fh = fh(:);
    
    % get used window coherent gain:
    %  get window:
    w = window_coeff('flattop_matlab',N);
    %  get window scaling factor:
    w_gain = mean(w);
    %  get window rms:
    w_rms = mean(w.^2).^0.5;
    
    
    
    
    % --- Process the channels with corrections ---
        
    % get ADC aperture value [s]:
    ta = abs(datain.adc_aper.v);
    
    % calculate aperture gain/phase correction (for f0):
    fap = fh + 1e-12;
    ap_gain = (pi*ta*fap)./sin(pi*ta*fap);
    ap_phi  =  pi*ta*fh; % phase is not needed - should be identical for all channels
    
    
    
        
         
    
    % --- for each virtual (u/i) channel:
    for k = 1:numel(vcl)
        % get channel:
        vc = vcl{k};
        
        % get gain/phase correction for the freq. components (high-side ADC):
        ag = correction_interp_table(vc.tab.adc_gain, vc.Y, fh, 'f',1, i_mode);
        ap = correction_interp_table(vc.tab.adc_phi,  vc.Y, fh, 'f',1, i_mode);
        
        if any(isnan(ag.gain))
            error('High-side ADC gain correction: not sufficient range of correction data!');
        end
        if any(isnan(ap.phi))
            error('High-side ADC phase correction: not sufficient range of correction data!');
        end
               
        % apply aperture corrections (when enabled and some non-zero value entered for the aperture time):
        if vc.ap_corr && ta > 1e-12
            ag.gain = ag.gain.*ap_gain;
        end
         
        % apply high-side adc tfer to the spectrum estimate:        
        vc.Y  = vc.Y.*ag.gain;
        vc.ph = vc.ph + ap.phi;
        
        % store high-side ADC tfer:
        vc.adc_gain = ag;
        vc.adc_phi = ap;
        
        if vc.is_diff
            % -- differential mode:
        
            % get gain/phase correction for the freq. components (low-side ADC):
            agl = correction_interp_table(vc.tab.lo_adc_gain, vc.Y_lo, fh, 'f',1, i_mode);
            apl = correction_interp_table(vc.tab.lo_adc_phi,  vc.Y_lo, fh, 'f',1, i_mode);
            
            if any(isnan(agl.gain))
                error('Low-side ADC gain correction: not sufficient range of correction data!');
            end
            if any(isnan(apl.phi))
                error('Low-side ADC phase correction: not sufficient range of correction data!');
            end              
            
            % apply aperture corrections (when enabled and some non-zero value entered for the aperture time):
            if vc.ap_corr && ta > 1e-12
                agl.gain = agl.gain.*ap_gain;
            end
            
            % apply low-side time shift correction:
            apl.phi   = apl.phi + vc.tsh_lo.v*fh*2*pi;
            apl.u_phi = (apl.u_phi.^2 + (vc.tsh_lo.u*fh*2*pi).^2).^0.5;
            
            % apply low-side adc tfer to the spectrum estimate:        
            vc.Y_lo  = vc.Y_lo.*agl.gain;
            vc.ph_lo = vc.ph_lo + apl.phi;
            
            % store low-side ADC tfer:
            vc.adc_gain_lo = agl;
            vc.adc_phi_lo = apl;
            
            % estimate transducer correction tfer from the spectrum estimates:
            % note: The transfer is aproximated from windowed-FFT bins 
            %       despite the sampling was is coherent.
            %       The absolute values of the DFT bin vectors are wrong
            %       due to the window effects, but the ratio of the high/low-side vectors
            %       is unaffected (hopefully), so they can be used to calculate the tfer
            %       which is then normalized to the used difference of high-low side spectra.
            % note: the corrections is relative correction to the difference of digitizer voltages (y - y_lo)
            % note: using window gain so the rms of signal is correct
            zz = zeros(size(vc.Y));            
            Y    = vc.Y.*exp(j*vc.ph)*w_gain;
            Y_lo = vc.Y_lo.*exp(j*vc.ph_lo)*w_gain;
            [trg,trp] = correction_transducer_loading(vc.tab,vc.tran,fh,[], abs(Y),angle(Y),zz,zz, abs(Y_lo),angle(Y_lo),zz,zz);            
            trg = trg./abs(Y - Y_lo);
            trp = trp - angle(Y - Y_lo);
                        
            %figure
            %semilogx(fh,trg)
            
            % store transducer tfer:
            vc.tr_gain = trg;
            vc.tr_phi = trp;

        else
            % -- single-ended mode:
        
            % estimate transducer correction tfer from the spectrum estimate:            
            zz = zeros(size(vc.Y));
            [trg,trp] = correction_transducer_loading(vc.tab,vc.tran,fh,[], vc.Y*w_gain,zz,zz,zz);
            trg = trg./vc.Y/w_gain;
            
            if any(isnan(trg))
                error('Transducer gain correction: not sufficient range of correction data!');
            end
            if any(isnan(trp))
                error('Transducer phase correction: not sufficient range of correction data!');
            end
            
            % combine ADC and transducer tfers:
            %  note: so we will apply just one filter instead of two
            vc.adc_gain.gain = vc.adc_gain.gain.*trg;
            vc.adc_phi.phi   = vc.adc_phi.phi + trp;
                        
        end
        
        
        
                
        vcl{k} = vc;
    end
        
    
    
    
    % reference channel phase:
    ap_ref = vcl{1}.adc_phi;
       
    % for each virtual (u/i) channel:
    for k = 1:numel(vcl)
        % get v.channel:
        vc = vcl{k};
        
        if k == 2
            % current channel:
            
            % add (i-u) timeshift correction:
            %  note: this is to reduce total phase correction value
            vc.adc_phi.phi   = vc.adc_phi.phi - datain.time_shift.v.*fh*2*pi; 
            vc.adc_phi.u_phi = (vc.adc_phi.u_phi.^2 + (datain.time_shift.u.*fh*2*pi).^2).^0.5;            
        end
        
        % subtract reference channel phase:
        %  note: this is to reduce total phase correction value
        vc.adc_phi.phi   = vc.adc_phi.phi - ap_ref.phi; 
        vc.adc_phi.u_phi = (vc.adc_phi.u_phi.^2 + ap_ref.u_phi.^2).^0.5;
        
        if vc.is_diff
            % -- differential mode:
            
            if k == 2
                % current channel:
                
                % add (i-u) timeshift correction:
                %  note: this is to reduce total phase correction value
                vc.adc_phi_lo.phi   = vc.adc_phi_lo.phi - datain.time_shift.v.*fh*2*pi; 
                vc.adc_phi_lo.u_phi = (vc.adc_phi_lo.u_phi.^2 + (datain.time_shift.u.*fh*2*pi).^2).^0.5;            
            end
                        
            % subtract reference channel phase:
            %  note: this is to reduce total phase correction value 
            vc.adc_phi_lo.phi   = vc.adc_phi_lo.phi - ap_ref.phi; 
            vc.adc_phi_lo.u_phi = (vc.adc_phi_lo.u_phi.^2 + ap_ref.u_phi.^2).^0.5;
            
            % apply ADC tfer filter:
            vc.y = td_fft_filter(vc.y, fs, fft_size, fh,vc.adc_gain.gain,vc.adc_phi.phi);
            vc.y_lo = td_fft_filter(vc.y_lo, fs, fft_size, fh,vc.adc_gain_lo.gain,vc.adc_phi_lo.phi);
            
            % calculate high-low difference:
            vc.y = vc.y - vc.y_lo;
            
            % apply transducer tfer filter:
            [vc.y,vc.start,vc.end] = td_fft_filter(vc.y, fs, fft_size, fh,vc.tr_gain,vc.tr_phi, i_mode);
                        
        else
            % -- single-ended mode:

            % apply combined ADC+transducer tfer to the time series:
            [vc.y] = td_fft_filter(vc.y, fs, fft_size, fh,vc.adc_gain.gain,vc.adc_phi.phi);
            
            % valid waveform section start/end:
            vc.start = 1;
            vc.end = numel(vc.y);
            
        end
        
        % store v.channel:
        vcl{k} = vc;            
    end
    
    % crop the waveform to the mathing lengths for diff/no-diff transducer combinations:
    if vcl{1}.is_diff && ~vcl{2}.is_diff
        vcl{2}.y = vcl{2}.y(vcl{1}.start:vcl{1}.end);
    elseif vcl{2}.is_diff && ~vcl{1}.is_diff
        vcl{1}.y = vcl{1}.y(vcl{2}.start:vcl{2}.end);
    end
    
    
    
    
    % --- apply interchannel u/i time shift ---
    
    % get corrected u/i:
    u = vcl{1}.y;
    i = vcl{2}.y;
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
    [fh, dataout.spec_U.v] = ampphspectrum(u, fs, 0, 0, 'flattop_248D', [], 0);
    [fh, dataout.spec_I.v] = ampphspectrum(i, fs, 0, 0, 'flattop_248D', [], 0);
    dataout.spec_S.v = dataout.spec_U.v.*dataout.spec_I.v;
    dataout.spec_f.v = fh(:);
    
    figure;
    loglog(fh,dataout.spec_U.v)
    figure;
    loglog(fh,dataout.spec_I.v)  
    
    
     
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





