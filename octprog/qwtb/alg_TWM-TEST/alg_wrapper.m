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
        %error('Differential input data ''y'' not allowed!');     
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
    % Replace following code by whatever algorithm you like.
    % --------------------------------------------------------------------
        
    % --- lets assume simple FFT spectral analysis ---
    
    % --- first we have to deal with possible differential input, i.e. the signal may be:
    % just 'y' for signle-ended connection or ('y' - 'y_lo') for differential connection.
    % The task is to correct the digitizer channels 'y' (and 'y_lo') independently
    % so everything in the first stage of processing will be made up to twice
    
    % build names of the input channels:
    chn_data_names = {'y';'y_lo'};
    
    % build prefix names of the corrections (first high-side or single-ended, then low-side):
    corr_pfx = cfg.pfx_ch;
    
    % total count of input channels (1 for SE, 2 for differential) 
    chn_n = 1 + cfg.y_is_diff;
    
    % empty list of channel correction tables so far:
    gp_tabs = {};
        
    % collect all needed correction tables for each input channel:
    for c = 1:chn_n
    
        % correction channle prefix:
        pfx = corr_pfx{c};
        
        % load correction of this channel (gain and phase only at this stage):
        gp_tabs = {gp_tabs{:}, getfield(tab, [pfx 'adc_gain']), getfield(tab, [pfx 'adc_phi'])};
    
    end
    
    
    % Unite frequency/amplitude axes of the digitizer chanel gain/phase corrections:
    %   Note: This step is needed and must be performed for ALL channels involved in the calculation
    %   because user may have created correction tables with different freq. or amplitude axes,
    %   so this will find the largest common range of the axes and interpolates the tables
    %   the common axes. That simplifies further processing and furthermore we can tell
    %   immediately if the common range of axes is enough for the data to be corrected.
    [gp_tabs, ax_a, ax_f] = correction_expand_tables(gp_tabs);
    
    
    % clear calculated spectrum: 
    amp = [];
    phi = [];    
    
    % --- apply correction to each input channel:
    for c = 1:chn_n
    
        % get input signal:
        y = getfield(datain, chn_data_names{c});
    
        % calculate spectrum (polar form):
        [f_U, amp, phi] = ampphspectrum(y.v, fs);
        f_U = f_U(:); % ###note to be removed
        
        % get range of the existing frequencies: 
        f_min = min(f_U);
        f_max = max(f_U);
        
        % get range of the existing amplitudes in the signal: 
        a_min = min(amp);
        a_max = max(amp);
        
        % --- now apply digitizer gain/phase corrections to the raw spectrum:        
    
        % extract correction tables for this channel:
        adc_gain = gp_tabs{c*2 - 2 + 1};
        adc_phi = gp_tabs{c*2 - 2 + 2};
            
        % check if correction data have sufficient range for the measured spectrum components:
        % note: isempty() tests is used to identify if the correction is not dependent on the axis, therefore the error check does not apply
        if ~isempty(ax_f) && (f_min < min(ax_f) || f_max > max(ax_f))
            error('Digitizer gain/phase correction data do not have sufficient frequency range!');
        end    
        if ~isempty(ax_a) && (a_min < min(ax_a) || a_max > max(ax_a))
            error('Digitizer gain/phase correction data do not have sufficient frequency range!');
        end
        
        % interpolate the gain/phase tables to the measured frequencies and amplitudes:
        adc_gain = correction_interp_table(adc_gain,amp(:),f_U(:),'f',1);
        adc_phi = correction_interp_table(adc_phi,amp(:),f_U(:),'f',1);
        
        % check if there are some NaNs in the correction data - that means user correction dataset contains some undefined values:
        if any(isnan(adc_gain.gain)) || any(isnan(adc_phi.phi))
            error('Digitizer gain/phase correction data do not have sufficient frequency range!');
        end
        
        % apply the digitizer transfer correction:
        amp(:,c) = amp.*adc_gain.gain;
        phi(:,c) = phi + adc_phi.phi;
    
    end
    
    % now we can subtract the two input channels for the differential mode:    
    if cfg.y_is_diff    
        amp = amp(:,1) - amp(:,2);        
        phi = phi(:,1) - phi(:,2);                
    end    
    % --- from now we have one single-ended signal
    
    

    
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
    
    % --- NOTE ---
    % This was very basic calculation, the real stuff is not there:
    % No uncertainty contribution from the correction was implemented yet.
    % No correction to the interchannel cross-talk is present.
    % Also no correction to the cable effects was implemented and
    % no correction to the low-side cable leakage current (diff. mode) was implemented.
    % These are the actual tricky parts to be done.
           
    % --------------------------------------------------------------------
    % End of the demonstration algorithm.
    % --------------------------------------------------------------------
       
   
    % --- my job here is done...
          

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
