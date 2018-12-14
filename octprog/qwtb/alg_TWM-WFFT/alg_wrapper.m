function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm TWM-WFFT.
%
% See also qwtb
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
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
             
%     if cfg.y_is_diff
%         % Input data 'y' is differential: if it is not allowed, put error message here
%         error('Differential input data ''y'' not allowed!');     
%     end
    
    if cfg.is_multi
        % Input data 'y' contains more than one record: if it is not allowed, put error message here
        error('Multiple input records in ''y'' not allowed!'); 
    end
    
    
    % Rebuild TWM style correction tables:
    % This is not necessary, but the TWM style tables are more comfortable to use then raw correction matrices
    tab = qwtb_restore_correction_tables(datain,cfg);
    
    
    % ------------------------------------------------------------------------------------------     
    % ------------------------------------------------------------------------------------------
    
    % get spectrum:
    din = struct();
    din.fs.v = fs;
    if isfield(datain,'window')
        din.window = datain.window;
    else
        din.window.v = 'rect';    
    end
    cset.verbose = 0;
    din.y.v = datain.y.v;                
    dout = qwtb('SP-WFFT',din,cset);
    fh    = dout.f.v(:); % freq. vector of the DFT bins
    A     = dout.A.v(:); % amplitude vector of the DFT bins
    ph    = dout.ph.v(:); % phase vector of the DFT bins
    w     = dout.w.v; % window coefficients
    
    %  get window scaling factor:
    w_gain = mean(w);
    %  get window rms:
    w_rms = mean(w.^2).^0.5;    
   
    % get ADC aperture value [s]:
    ta = abs(datain.adc_aper.v);
    
    % calculate aperture gain/phase correction:
    fap = fh + 1e-12; % needed for DC work
    ap_gain = (pi*ta*fap)./sin(pi*ta*fap);
    ap_phi  =  pi*ta*fh;
    
    % corrections interpolation mode:
    % ###note: do not change, this works best for frequency characteristics
    i_mode = 'pchip';
    
    % correct ADC offset:
    A(1) = A(1) - datain.adc_offset.v; % remove DC offset from working spectrum
        
    % get gain/phase correction for the freq. components (high-side ADC):
    ag = correction_interp_table(tab.adc_gain, abs(A), fh, 'f',1, i_mode);
    ap = correction_interp_table(tab.adc_phi,  abs(A), fh, 'f',1, i_mode);
    
    if any(isnan(ag.gain))
        error('High-side ADC gain correction: not sufficient range of correction data!');
    end
    if any(isnan(ap.phi))
        error('High-side ADC phase correction: not sufficient range of correction data!');
    end
       
    % apply aperture corrections (when enabled and some non-zero value entered for the aperture time):
    if datain.adc_aper_corr.v && ta > 1e-12
        ag.gain = ag.gain.*ap_gain;
        ap.phi = ap.phi + ap_phi;
    end      
     
    % apply high-side adc tfer to the spectrum estimate:        
    A  = A.*ag.gain;
    ph = ph + ap.phi;

    % compesante phase by timestamp:
    ph = ph - fh.*datain.time_stamp.v*2*pi;
    
    
    if cfg.y_is_diff
        % --- differential mode ---:
        
        % get low-side spectrum
        din.y.v = datain.y_lo.v;                
        dout = qwtb('SP-WFFT',din,cset);
        A_lo   = dout.A.v(:); % amplitude vector of the DFT bins
        ph_lo  = dout.ph.v(:); % phase vector of the DFT bin
    
        % correct ADC offset:
        A_lo(1) = A_lo(1) - datain.lo_adc_offset.v; % remove DC offset from working spectrum
            
        % get gain/phase correction for the freq. components (high-side ADC):
        ag = correction_interp_table(tab.lo_adc_gain, abs(A_lo), fh, 'f',1, i_mode);
        ap = correction_interp_table(tab.lo_adc_phi,  abs(A_lo), fh, 'f',1, i_mode);
        
        if any(isnan(ag.gain))
            error('High-side ADC gain correction: not sufficient range of correction data!');
        end
        if any(isnan(ap.phi))
            error('High-side ADC phase correction: not sufficient range of correction data!');
        end
           
        % apply aperture corrections (when enabled and some non-zero value entered for the aperture time):
        if datain.lo_adc_aper_corr.v && ta > 1e-12
            ag.gain = ag.gain.*ap_gain;
            ap.phi = ap.phi + ap_phi;
        end      
         
        % apply high-side adc tfer to the spectrum estimate:        
        A_lo  = A_lo.*ag.gain;
        ph_lo = ph_lo + ap.phi;
    
        % compesante phase by timestamp:
        ph_lo = ph_lo - fh.*(datain.time_stamp.v + datain.time_shift_lo.v)*2*pi;
        
        % high-side:            
          Y  = A.*exp(j*ph);
        u_Y  = 0*Y;
        u_ph = 0*Y;
        % low-side:
          Y_lo  = A_lo.*exp(j*ph_lo);
        u_Y_lo  = 0*Y_lo;
        u_ph_lo = 0*Y_lo;
        % estimate digitizer input rms level:
        dA = abs(Y - Y_lo);
        rms_ref = sum(0.5*dA.^2).^0.5*w_gain/w_rms;            
        % calculate transducer tfer:
        fh_dc = fh; fh_dc(1) = 1e-3; % override DC frequency by non-zero value
        [trg,trp,u_trg,u_trp] = correction_transducer_loading(tab,datain.tr_type.v,fh_dc,[], abs(Y),angle(Y),u_Y,u_ph, abs(Y_lo),angle(Y_lo),u_Y_lo,u_ph_lo, 'rms',rms_ref);
        A = trg;
        ph = trp;
        
%         figure
%         loglog(fh,A)
        
    
    else
        % --- single ended mode ---
        
        % apply transducer correction:
        rms_ref = sum(0.5*A.^2).^0.5*w_gain/w_rms;
        Y = abs(A); % amplitudes, rectify DC
        fh_dc = fh; fh_dc(1) = 1e-3; % override DC frequency by non-zero value
        [trg,trp,u_trg,u_trp] = correction_transducer_loading(tab,datain.tr_type.v,fh_dc,[], Y,ph,0*Y,0*ph, 'rms',rms_ref);
        trg(1) = trg(1)*sign(A(1));
        A = trg;
        ph = trp;
        
    end
    
    % wrap phase to +-180deg:
    %  note: this is critical to avoid insane phase due to time_stamp correction!
    ph = mod(ph + pi, 2*pi) - pi;
    
    
    % search dominant component:
    [Amax,mid] = max(A);     
    
    % local copy of spectrum:
    w_size = 11;
    Ax = A*0;
    Ax(w_size:end) = A(w_size:end);
    
    % max harmonics to search:
    H_max = 100;
    
    % min ratio to fundamental to take it into account:
    h_min_ratio = 10e-6;
    
    % spestrum width:
    N = numel(A);
        
    h_list = [];            
    for h = 1:H_max
                
        % look for highest harmonic:            
        [v,id] = max(Ax);                     
        
        % leave if harmonics too low:
        if v < Amax*h_min_ratio || isempty(id)
            break;
        end
    
        % found harmonics list:
        h_list(end+1) = id;
        
        % DFT bins occupied by the harmonic
        h_bins = max((id - w_size),1):min(id + w_size,N);
        
        % remove harmonic bins from remaining list:
        Ax(h_bins) = 0;
        
    end
    
        
    
    
    
        
    % get nearest frequency bin in spectrum: 
    fx = datain.f_nom.v;    
    [f0,fid] = min(abs(fx - fh));
    
    % return extracte DFT bin:
    dataout.f.v = fh(fid);
    dataout.A.v = A(fid);
    dataout.ph.v = ph(fid);
    dataout.rms.v = (A(1)^2 + sum(0.5*A(h_list).^2))^0.5;
    dataout.dc.v = A(1);              
    dataout.f.u = 0;
    dataout.A.u = 0;
    dataout.ph.u = 0;
    dataout.rms.u = 0;
    dataout.dc.u = 0;
    
    % return spectrum:
    dataout.spec_f.v = fh;
    dataout.spec_A.v = A;   

end % function

