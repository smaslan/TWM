function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm TWM-Flicker.
%
% See also qwtb
%
% Format input data --------------------------- %<<<1
    
    % Restore orientations of the input vectors to originals (before passing via QWTB)
    % This is critical for the correction data! 
    [datain,cfg] = qwtb_restore_twm_input_dims(datain,1);

    % try to obtain sampling rate from alternative input quantities [Hz]
    if isfield(datain, 'Ts')
        fs = 1./datain.Ts.v;
    elseif isfield(datain, 'fs')
        fs = datain.fs.v;
    else
        fs = 1/mean(diff(datain.t.v));
    end
         
    if cfg.y_is_diff
        % Input data 'y' is differential: if it is not allowed, put error message here
        error('Differential input data ''y'' not allowed!');     
    end
    
    if cfg.is_multi
        % Input data 'y' contains more than one record: if it is not allowed, put error message here
        error('Multiple input records in ''y'' not allowed!'); 
    end
    
    % Rebuild TWM style correction tables:
    % This is not necessary but the TWM style tables are more comfortable to use then raw correction matrices
    tab = qwtb_restore_correction_tables(datain,cfg);
    
    
    
    % --------------------------------------------------------------------
    % Start of the algorithm
    % --------------------------------------------------------------------
    
    
    % --- 1) Signal scaling ---
    
    % load input signal (or high-side input channel for diff. mode):
    y = datain.y.v;
    N = numel(y);
        
    % apply timebase frequency correction:
    fs = fs.*(1 + datain.adc_freq.v);
    
    % remove ADC DC offset:
    y = y - datain.adc_offset.v;
    
    % -- separate DC component:
    % note: to apply correct tfer. corrections, we need to split signal into DC and AC part
    % get DC component:
    w = blackmanharris(N,'periodic'); w = w(:);
    w_gain = mean(w);
    w_rms = mean(w.^2).^0.5;
    dc = mean(w.*y)/w_gain;
    % remove DC from signal (temporarilly):
    y = y - dc;
        
    
    % carrier frequency:
    fc = datain.f_line.v;
    
    % generate possible carrier spread:
    %  ###note: we estimate it won't be worse than +-2Hz
    fcd = datain.f_line.v + [0;-2;2];
    fcd = [1e-12;fcd]; % add DC component
    % so freq. list contains [fc fc+? fc-? 'DC']...     
    
    % interpolate the gain/phase tables to the the working frequencies, ignore level dependence:
    adc_gain = correction_interp_table(tab.adc_gain,[],fcd);
    
    % extract DC gain:
    adc_dc_gain = nanmean(adc_gain.gain(1,:));
    % remove DC component from the working tfer 'adc_gain':
    adc_gain.gain = adc_gain.gain(2:end,:);
    adc_gain.u_gain = adc_gain.u_gain(2:end,:);
        
    % mean digitizer gain at carrier freq.:
    ag = nanmean(adc_gain.gain(:));
    % worst case gain variation in the carrier freq. range:
    ag_max = max(adc_gain.gain(:)) + max(adc_gain.u_gain(:));
    ag_min = min(adc_gain.gain(:)) - max(adc_gain.u_gain(:));
    % digitizer gain uncertainty estimate:
    u_ag = max(ag_max - ag,ag - ag_min)/3^0.5;
    
    % calculate aperture corrections (when enabled and some non-zero value entered for the aperture time):
    ta = datain.adc_aper.v;
    if datain.adc_aper_corr.v && abs(ta) > 1e-12 
        
        % calculate gain correction:
        ag_gain = (pi*ta*fcd(2:end))./sin(pi*ta*fcd(2:end));
        % aperture uncertainty:
        u_ag_gain = max(abs(ag_gain(2:end) - ag_gain(1)))/3^0.5;
        
        % combine with digitzer gain:
        ag   = ag*ag_gain(1);
        u_ag = (u_ag^2 + u_ag_gain^2)^0.5;   
        
    end
    
    
    % ADC input rms estimate:
    adc_rms = mean((w.*(y.*ag + dc.*adc_dc_gain)).^2)^0.5/w_rms;
    
    
    % get transducer tfer for working frequencies, ignore rms dependence: 
    tr_gain = correction_interp_table(tab.tr_gain,[],fcd);
    
    % extract DC gain:
    tr_dc_gain = nanmean(tr_gain.gain(1,:));
    % remove DC from working tfer: 
    tr_gain.gain = tr_gain.gain(2:end,:); 
    tr_gain.u_gain = tr_gain.u_gain(2:end,:);
    
    if isempty(datain.tr_type.v)
        % -- transducer type not defined:
        warning('Transducer type not defined! Applying just basic gain correction.');
        
        % mean digitizer gain at carrier freq.:
        trg = nanmean(tr_gain.gain(:));
        % worst case gain variation in the carrier freq. range:
        trg_max = max(tr_gain.gain(:)) + max(tr_gain.u_gain(:));
        trg_min = min(tr_gain.gain(:)) - max(tr_gain.u_gain(:));
        % transducer gain uncertainty estimate:
        u_trg = max(trg_max - trg,trg - trg_min)/3^0.5;
        
    else
        % -- tran. type defined, apply correction:
        
        A0 = repmat(1,size(fcd));
        [trg,trp,u_trg,u_p] = correction_transducer_loading(tab,datain.tr_type.v,fcd,[], A0,0*A0,0*A0,0*A0, 'rms',adc_rms);
        
        % extract DC gain:
        tr_dc_gain = trg(1);
        trg = trg(2:end); % remove DC from working tfer
        
        % worst case gain variation:
        trg_max = max(trg) + max(u_trg);
        trg_min = min(trg) - max(u_trg);
        % digitizer gain uncertainty estimate:
        u_trg = max(trg_max - trg,trg - trg_min)/3^0.5;
        % mean digitizer gain at carrier:
        trg = trg(1);
                                
    end
    
    % apply carrier gain:
    y = y*ag*trg;
    
    % add back the DC component:
    y = y + dc*adc_dc_gain*tr_dc_gain;    
    % now the signal 'y' should be correctly scaled to original...
    
    
    % call low level flicker algorithm:
    din.fs.v = fs;
    din.y.v = y;
    din.f_line.v = datain.f_line.v;
    cset = calcset;
    cset.unc = 'none';    
    dout = qwtb('flicker_sim', din, cset);
    
    % ###todo: remove when main flicker_sim is fixed...    
    dataout.Pst.v = dout.Pst;    
    dataout.Pinst.v = dout.Pinst;
    
    if strcmpi(calcset.unc,'guf')
        % estimate some uncertainty:
        % ###todo: should be replaced by something more sophisticated, but 0.9%*PST seems to be the worst case 
        dataout.Pst.u = 0.009*calcset.loc*1.05*dataout.Pst.v;
    else
        dataout.Pst.u = 0;
    end
                   
    % --------------------------------------------------------------------
    % End of the demonstration algorithm.
    % --------------------------------------------------------------------


end % function
% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
