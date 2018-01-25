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
    
    % get waveform vector:
    u = datain.y.v;
    
    % calculate full spectrum:
    U = fft(u);
    
    % total DFT bins count:
    N = numel(U);
    
    % throw away negative frequencies of the spectrum:
    % and normalize
    U = U(1:floor(N/2))/N*2;
    
    % remaining DFT bins count:
    N = numel(U);
    
    % build frequency axis:
    f_U = [0:N-1]/fs;
    
    % get range of the used frequencies: 
    f_min = min(f_U);
    f_max = max(f_U);
    
    
    % --- now apply digitizer gain/phase corrections to the raw spectrum:
    
    % unite frequency/amplitude axes of the digitizer gain/phase corrections: 
    [tabs,ax_a,ax_f] = correction_expand_tables({tab.adc_gain, tab.adc_phi});
    % extract modified tables:
    adc_gain = tabs{1};
    adc_phi = tabs{2};
    
    % calculate amplitude spectrum:
    amp_U = abs(U);
    
    % get range of the used amplitudes: 
    a_min = min(amp_U);
    a_max = max(amp_U);
        
    % check if correction data have sufficient range for the measured spectrum components:
    % note: isempty() tests is used to identify if the correction is not dependent on the axis, therefore the error check does not apply
    if ~isempty(ax_f) && (f_min < min(ax_f) || f_max > max(ax_f))
        error('Digitizer gain/phase correction data do not have sufficient frequency range!');
    end    
    if ~isempty(ax_a) && (a_min < min(ax_a) || a_max > max(ax_a))
        error('Digitizer gain/phase correction data do not have sufficient frequency range!');
    end
    
    % build complex transfer table from digitizer gain/phase:  
    adc_tf = correction_add2table(adc_gain,'tf',adc_gain.gain.*exp(j*adc_phi.phi));
              
    % interpolate the complex tfer table to the measured frequencies and amplitudes:
    adc_tf = correction_interp_table(adc_tf,amp_U(:),f_U(:),'f',1);
    
    
    % apply the digitizer transfer correction in the complex domain:
    U = U.*adc_tf.tf;
    
    
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
    
    % calculate amplitude spectrum:
    amp_U = abs(U);
    
    % get range of the used amplitudes: 
    a_min = min(amp_U);
    a_max = max(amp_U);
        
    % check if correction data have sufficient range for the measured spectrum components:
    % note: isempty() tests is used to identify if the correction is not dependent on the axis, therefore the error check does not apply
    if ~isempty(ax_f) && (f_min < min(ax_f) || f_max > max(ax_f))
        error('Transducer gain/phase correction data do not have sufficient frequency range!');
    end    
    if ~isempty(ax_a) && (a_min < min(ax_a) || a_max > max(ax_a))
        error('Transducer gain/phase correction data do not have sufficient frequency range!');
    end
    
    % build complex transfer table from transducer gain/phase:
    tr_tf = correction_add2table(tr_gain,'tf',tr_gain.gain.*exp(j*tr_phi.phi));
          
    % interpolate the complex tfer table to the measured frequencies but NOT amplitudes:
    tr_tf_tmp = correction_interp_table(tr_tf,[],f_U);
    
    % get the rms-independent tfer:
    % the nanmean is used to find mean correction coefficient for all available rms-values ignoring missing NaN-data 
    tf_tmp = nanmean(tr_tf_tmp.tf,2);
    
    % apply the tfer to the signal to get INPUT spectrum estimate:
    U_tmp = U.*tf_tmp;
    
    % now estimate rms value of the spectrum:
    rms = (0.5*U_tmp.^2).^0.5;
    
    % interpolate the complex tfer table to the measured frequencies and rms level:
    tr_tf = correction_interp_table(tr_tf,rms,f_U);
    
    % finally apply the transducer correction in complex domain:
    U = U.*tr_tf.tf;
    
    
    % --- now we have the spectrum of signal on the transducer input
    % lets return calculated quantities to the caller:
    % note the '.v' stands for the value of the quantity, eventual '.u' would be uncertainty 
    
    % return signal RMS value:
    dataout.rms.v = (0.5*U.^2).^0.5;
    
    % return the spectrum in polar form:
    dataout.spec_f.v = f_U;
    dataout.spec_amp.v = abs(U);
    dataout.spec_phi.v = arg(U);
    
       
    % --------------------------------------------------------------------
    % End of the demonstration algorithm
    % --------------------------------------------------------------------
   
    % --- my job here is done...
          

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
