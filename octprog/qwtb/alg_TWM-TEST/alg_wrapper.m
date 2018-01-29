function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm TWM-TEST.
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
    % Now we are ready to do whatever the algorithm should do ...
    % Replace following code by whatever algorithm you like
    % --------------------------------------------------------------------
        
    % --- lets assume simple FFT spectral analysis ---
    
    % calculate spectrum (polar form):
    [f_U, amp, phi] = ampphspectrum(datain.y.v, fs);
    f_U = f_U(:); % ###note to be removed
    
    % get range of the used frequencies: 
    f_min = min(f_U);
    f_max = max(f_U);
    
    
    % --- now apply digitizer gain/phase corrections to the raw spectrum:
    
    % unite frequency/amplitude axes of the digitizer gain/phase corrections: 
    [tabs,ax_a,ax_f] = correction_expand_tables({tab.adc_gain, tab.adc_phi});
    % extract modified tables:
    adc_gain = tabs{1};
    adc_phi = tabs{2};
    
    % get range of the used amplitudes: 
    a_min = min(amp);
    a_max = max(amp);
        
    % check if correction data have sufficient range for the measured spectrum components:
    % note: isempty() tests is used to identify if the correction is not dependent on the axis, therefore the error check does not apply
    if ~isempty(ax_f) && (f_min < min(ax_f) || f_max > max(ax_f))
        error('Digitizer gain/phase correction data do not have sufficient frequency range!');
    end    
    if ~isempty(ax_a) && (a_min < min(ax_a) || a_max > max(ax_a))
        error('Digitizer gain/phase correction data do not have sufficient frequency range!');
    end
    
    % interpolate the gain/phase table to the measured frequencies and amplitudes:
    adc_gain = correction_interp_table(adc_gain,amp(:),f_U(:),'f',1);
    adc_phi = correction_interp_table(adc_phi,amp(:),f_U(:),'f',1);
    
    % check if there aren't some NaNs in the correction data - that means user correction dataset contains some undefined values:
    if any(isnan(adc_gain.gain)) || any(isnan(adc_phi.phi))
        error('Digitizer gain/phase correction data do not have sufficient frequency range!');
    end
    
    % apply the digitizer transfer correction:
    amp = amp.*adc_gain.gain;
    phi = phi + adc_phi.phi;

    
    % --- now apply transducer gain/phase corrections:
    % this will be more tricky, because trans. correction data are dependent on the input rms value so,
    % 1) we have to calculate RMS of the digitizer signal
    % 2) we have to multiply it by rms-independent correction data to get estimate of INPUT rms value
    % 3) finally, we can obtain the correction coefficient for the rms value
    % 4) we apply the correction to the digitizer signal
    
    % unite frequency/amplitude axes of the transducer gain/phase corrections: 
    [tabs,ax_a,ax_f] = correction_expand_tables({tab.tr_gain, tab.tr_phi});
    % extract modified tables:
    tr_gain = tabs{1};
    tr_phi = tabs{2};
            
    % check if correction data have sufficient range for the measured spectrum components:
    % note: isempty() tests is used to identify if the correction is not dependent on the axis, therefore the error check does not apply
    if ~isempty(ax_f) && (f_min < min(ax_f) || f_max > max(ax_f))
        error('Transducer gain/phase correction data do not have sufficient frequency range!');
    end    
    if ~isempty(ax_a) && (a_min < min(ax_a) || a_max > max(ax_a))
        error('Transducer gain/phase correction data do not have sufficient frequency range!');
    end
    
    % interpolate the gain tfer table to the measured frequencies but NOT amplitudes:
    tr_gain_tmp = correction_interp_table(tr_gain,[],f_U);
    
    % get the rms-independent tfer:
    % the nanmean is used to find mean correction coefficient for all available rms-values ignoring missing NaN-data 
    gain_tmp = nanmean(tr_gain_tmp.gain,2);
    
    % apply the tfer to the signal to get INPUT spectrum estimate:
    amp_tmp = amp.*gain_tmp;
    
    % now estimate rms value of the spectrum:
    rms = sum(0.5*abs(amp).^2)^0.5;
    
    % interpolate the gain/phase tfer table to the measured frequencies and rms level:
    tr_gain = correction_interp_table(tr_gain,rms,f_U);
    tr_phi = correction_interp_table(tr_phi,rms,f_U);
    
    % check if there aren't some NaNs in the correction data - that means user correction dataset contains some undefined values:
    if any(isnan(tr_gain.gain)) || any(isnan(tr_phi.phi))
        error('Transducer gain/phase correction data do not have sufficient frequency range!');
    end
    
    % finally apply the transducer correction:
    amp = amp.*tr_gain.gain;
    phi = phi + tr_phi.phi;
    
    
    % --- now we have the spectrum of signal on the transducer input
    % lets return calculated quantities to the caller:
    % note the '.v' stands for the value of the quantity, eventual '.u' would be uncertainty 
    
    % return signal RMS value:
    dataout.rms.v = sum(0.5*amp.^2).^0.5;
    
    % return the spectrum in polar form:
    dataout.f.v = f_U;
    dataout.amp.v = amp;
    dataout.phi.v = phi;
    
       
    % --------------------------------------------------------------------
    % End of the demonstration algorithm
    % --------------------------------------------------------------------
   
    % --- my job here is done...
          

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
