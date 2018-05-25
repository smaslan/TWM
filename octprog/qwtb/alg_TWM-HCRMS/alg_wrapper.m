function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm TWM-HCRMS.
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
    
    % obtain nominal frequency value:
    if isfield(datain,'nom_f')
        nom_f = datain.nom_f.v;
    else
        % default:
        nom_f = NaN; 
    end
    
    % obtain nominal rms value:
    if isfield(datain,'nom_rms')
        nom_rms = datain.nom_rms.v;
    else    
        % default:
        nom_rms = 230.0; 
    end
    
    % obtain calculation mode:
    if isfield(datain,'mode')
        mode = datain.mode.v;
    else
        % default: A class 61000-3-40 
        mode = 'A';
    end
    if mode ~= 'A' && mode ~= 'S'
        error(sprintf('Calculation mode ''%s'' not supported!',mode));
    end
    
    % obtain tresholds:
    if isfield(datain,'sag_tres')
        sag_tres = datain.sag_tres.v;
    else
        sag_tres = 90;
    end
    if isfield(datain,'swell_tres')
        swell_tres = datain.swell_tres.v;
    else
        swell_tres = 110;
    end
    if isfield(datain,'int_tres')
        int_tres = datain.int_tres.v;
    else
        int_tres = 10;
    end
    % obtain hysteresis:
    if isfield(datain,'hyst')
        hyst = datain.hyst.v;
    else
        hyst = 2;
    end
    
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
        error('Differential input data ''y'' not allowed!');     
    end
    
    if cfg.is_multi
        % Input data 'y' contains more than one record: if it is not allowed, put error message here
        error('Multiple input records in ''y'' not allowed!'); 
    end
    
    % timestamp phase compensation state:
    do_plots = isfield(datain, 'plot') && ((isnumeric(datain.plot.v) && datain.plot.v) || (ischar(datain.plot.v) && strcmpi(datain.plot.v,'on')));
    
    if ~isfield(calcset,'dbg_plots')
        calcset.dbg_plots = 0;
    end        
    
    % Rebuild TWM style correction tables:
    % This is not necessary but the TWM style tables are more comfortable to use then raw correction matrices
    tab = qwtb_restore_correction_tables(datain,cfg);
    
    
    % --------------------------------------------------------------------
    % Start of the algorithm
    % --------------------------------------------------------------------
    
    % fix timebase error:
    tb_corr = (1 + datain.adc_freq.v);
    fs = fs/tb_corr;
    
    % get signal:
    y = datain.y.v;
    
    % sample count:
    N = size(y,1);
    
    
    % --- apply gain corrections
    fprintf('Scaling signal...\n');
    
    % remove DC offset error:
    y = y - datain.adc_offset.v;
        
    % get initial guess of main component frequency:
    if isnan(nom_f)
        % estimate nominal frequency of not defined explicitly:
        f0_est = PSFE(y,1/fs);
    else
        f0_est = nom_f;
    end
    
    % get digitizer gain/phase correction (independent to amplitude): 
    ag = correction_interp_table(tab.adc_gain, [], f0_est);
    ap = correction_interp_table(tab.adc_phi, [], f0_est);
    % combine tfers for all amplitudes to mean amplitude, expand uncertainty: 
    g         = nanmean(ag.gain);
    ag.u_gain = (max(ag.u_gain).^2/3 + max([nanmax(ag.gain) - g;g - nanmin(ag.gain)])^2/3).^0.5;
    ag.gain   = g; 
    p        = nanmean(ap.phi);
    ap.u_phi = (max(ap.u_phi).^2/3 + max([nanmax(ap.phi) - p;p - nanmin(ap.phi)])^2/3).^0.5;
    ap.phi   = p;
        
    % apply aperture:
    ta = datain.adc_aper.v;
    if abs(ta) > 1e-12 && datain.adc_aper_corr.v
        % calculate aperture gain/phase correction (for f0):
        ap_gain = (pi*ta*f0_est)./sin(pi*ta*f0_est);
        ap_phi  =  pi*ta*f0_est;
        % combine with ADC tfer:
        ag.gain = ag.gain*ap_gain;
        ag.u_gain = ag.u_gain*ap_gain;
        ap.phi = ap.phi + ap_phi;
    end
    
    % apply digitizer gain:
    y = y*ag.gain;
    
    % average rms over the signal:    
    %w = blackmanharris(N,'periodic');
    %w = w(:);
    %W = mean(w.^2)^-0.5;
    %rms = W*mean(0.5*(w.*y).^2)^0.5
        
    if isempty(datain.tr_type.v)
        % no transducer defined - apply plain tfer:
                
        % get transducer tfer (independent of rms):
        trg = correction_interp_table(tab.tr_gain, [], f0_est);
        trp = correction_interp_table(tab.tr_phi, [], f0_est);
        % combine tfers for all rms levels to find the worst case uncertainty: 
        g          = nanmean(trg);
        trg.u_gain = (max(trg.u_gain).^2/3 + max([nanmax(trg.gain) - g;g - nanmin(trg.gain)])^2/3).^0.5;
        trg.gain   = g; 
        trp       = nanmean(trp.phi);
        trp.u_phi = (max(trp.u_phi).^2/3 + max([nanmax(trp.phi) - p;p - nanmin(trp.phi)])^2/3).^0.5;
        trp.phi   = p;
                
    else 
        % tran. type defined:       
        
        % calculate transducer transfer + loading effect: 
        [gain,phi,u_gain,u_phi] = correction_transducer_loading(tab,datain.tr_type.v,f0_est,[], 1,0,0,0);
        
        % get transducer tfer (independent of rms):
        trg = correction_interp_table(tab.tr_gain, [], f0_est);
        trp = correction_interp_table(tab.tr_phi, [], f0_est);
        % combine tfers for all rms levels to find the worst case uncertainty: 
        trg.u_gain = (max(trg.u_gain).^2/3 + max([nanmax(trg.gain) - gain;gain - nanmin(trg.gain)])^2/3).^0.5;
        trg.gain   = gain; 
        trp.u_phi = (max(trp.u_phi).^2/3 + max([nanmax(trp.phi) - phi;phi - nanmin(trp.phi)])^2/3).^0.5;
        trp.phi   = phi;
               
    end
    
    % apply transdcuer gain:
    y = y*trg.gain;
    
           
    % ###TODO: phase and time shifts
    
    % time shift due to the signal path correction:
    dt_corr = (ap.phi + trp.phi)/2/pi/f0_est;
    
    % time stamp of first sample:
    ts = dt_corr + datain.time_stamp.v*tb_corr;
     
      
    cfg.f0_est = f0_est;
    cfg.nom_f = nom_f;
    cfg.nom_rms = nom_rms;
    cfg.mode = mode;
    cfg.do_plots = do_plots;    
    cfg.ev.hyst = hyst;
    cfg.ev.sag_tres = sag_tres;
    cfg.ev.swell_tres = swell_tres;
    cfg.ev.int_tres = int_tres;
    
    % generate empty results:
    dataout = struct();
    
    
    
    [t,rms,dataout] = hcrms_calc_pq(dataout,ts,fs,y,cfg,calcset);
            
      
           
    
    % --- returning results ---    
    
           
    % --------------------------------------------------------------------
    % End of the algorithm.
    % --------------------------------------------------------------------


end % function



% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
