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
    
    % timestamp phase compensation state:
    tstmp_comp = isfield(datain, 'comp_timestamp') && ((isnumeric(datain.comp_timestamp.v) && datain.comp_timestamp.v) || (ischar(datain.comp_timestamp.v) && strcmpi(datain.comp_timestamp.v,'on')));
         
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
        
    % --- lets try simple FFT spectral analysis ---
    
    % --- first we have to deal with possible differential input, i.e. the signal may be:
    % just 'y' for signle-ended connection or ('y' - 'y_lo') for differential connection.
    % The task is to correct the digitizer channels 'y' (and 'y_lo') independently
    % so everything in the first stage of processing will be made up to twice
    
    % empty list of channel correction tables so far:
    gp_tabs = {};
        
    % collect all needed correction tables for each input channel:
    for c = 1:numel(cfg.ysub)
    
        % correction subchannel prefix ('y_', 'y_lo_'):
        pfx = cfg.pfx_ch{c};
        
        % load correction of this channel (gain and phase only at this stage):
        gp_tabs = {gp_tabs{:}, getfield(tab, [pfx 'adc_gain']), getfield(tab, [pfx 'adc_phi'])};
    
    end
    
    
    % Unite frequency/amplitude axes of the digitizer chanel gain/phase corrections:
    %   Note: This step is needed and must be performed for ALL channels involved in the calculation
    %   because user may have created correction tables with different freq. or amplitude axes,
    %   so this will find the largest common range of the axes and interpolates the tables
    %   the common axes. That simplifies further processing and furthermore we can tell
    %   immediately if the common range of axes is enough for the data to be corrected.
    [tabs, ax_a, ax_f] = correction_expand_tables(gp_tabs,'none');
    
    
    % clear calculated spectrum: 
    amp = [];
    phi = [];
    
        
    
    % --- apply correction to each input subchannel:
    for c = 1:numel(cfg.ysub)
    
        % get input subchannel:
        y = getfield(datain, cfg.ysub{c});
    
        % calculate spectrum (polar form):
        [f_U, A, Ph] = ampphspectrum(y.v, fs);
        f_U = f_U(:); % ###note to be removed after ampphspectrum() fixed...
        
        % get range of the existing frequencies: 
        f_min = min(f_U);
        f_max = max(f_U);        
        % get range of the existing amplitudes in the signal: 
        a_min = min(A);
        a_max = max(Ph);
        
        
        % --- now apply digitizer gain/phase corrections to the raw spectrum:        
    
        % extract correction tables for this subchannel:
        adc_gain = gp_tabs{c*2 - 2 + 1};
        adc_phi  = gp_tabs{c*2 - 2 + 2};
            
        % check if correction data have sufficient range for the measured spectrum components:
        % note: isempty() tests is used to identify if the correction is not dependent on the axis, therefore the error check does not apply
        if ~isempty(ax_f) && (f_min < min(ax_f) || f_max > max(ax_f))
            error('Digitizer gain/phase correction data do not have sufficient frequency range!');
        end    
        if ~isempty(ax_a) && (a_min < min(ax_a) || a_max > max(ax_a))
            error('Digitizer gain/phase correction data do not have sufficient frequency range!');
        end
        
        % interpolate the gain/phase tables to the measured frequencies and amplitudes:
        adc_gain = correction_interp_table(adc_gain,A(:),f_U(:),'f',1);
        adc_phi =  correction_interp_table(adc_phi, A(:),f_U(:),'f',1);
        
        % check if there are some NaNs in the correction data - that means user correction dataset contains some undefined values:
        if any(isnan(adc_gain.gain)) || any(isnan(adc_phi.phi))
            error('Digitizer gain/phase correction data do not have sufficient frequency range!');
        end
        
        % apply the digitizer transfer correction:
        amp(:,c) = A(:).*adc_gain.gain;
        phi(:,c) = Ph(:) + adc_phi.phi;
        
        if c > 1
            % -- low-side channel:
            % correct high-low side channel time-shift:
            phi(:,c) = phi(:,c) - datain.time_shift_lo.v*f_U*2*pi;            
        end
    
    end
    
    % --- correct time-stamp:
    if tstmp_comp
        phi = bsxfun(@minus,phi,datain.time_stamp.v*f_U*2*pi);
    end
    
    % --- ADC aperture correction:
    if datain.adc_aper_corr.v && datain.adc_aper.v > 1e-12
        % get ADC aperture value [s]:
        ta = abs(datain.adc_aper.v);
        
        % calculate aperture gain/phase correction:
        ap_gain = (pi*ta*max(f_U,eps))./sin(pi*ta*max(f_U,eps));
        ap_phi  =  pi*ta*f_U;        
        % apply it to subchannels:
        amp = bsxfun(@times,amp,ap_gain);
        phi = bsxfun(@plus, phi,ap_phi);
    end
    
    
    % --- now apply transducer gain/phase corrections:        
    if isempty(datain.tr_type.v)
        % -- transducer type not defined:
        warning('Transducer type not defined! Not applying tran. correction!');
        if cfg.y_is_diff
            % diff connection - do just a crude difference (high-low)-side subchannels:
            amp = -diff(amp,[],2);
            phi = -diff(phi,[],2);
        end
        u_amp = amp*0;
        u_phi = phi*0;
    elseif cfg.y_is_diff
        % -- differential connection:
        [amp,phi,u_amp,u_phi] = correction_transducer_loading(tab,datain.tr_type.v,f_U,[], amp(:,1),phi(:,1),0*amp(:,1),0*phi(:,1), amp(:,2),phi(:,2),0*amp(:,2),0*phi(:,2));        
    else
        % -- single-ended connection:
        [amp,phi,u_amp,u_phi] = correction_transducer_loading(tab,datain.tr_type.v,f_U,[], amp,phi,0*amp,0*phi);                
    end
    
    % wrap phase to +-pi:
    phi = mod(phi + pi,2*pi) - pi;  
    
    if any(isnan(amp)) || any(isnan(phi))
        error('Transducer gain/phase correction data do not have sufficient frequency/rms range for the signal!');
    end

    
    % --- now we have the spectrum of signal on the transducer input
    % lets return calculated quantities to the caller:
    % note the '.v' stands for the value of the quantity, eventual '.u' would be uncertainty 
    
    % return signal RMS value:
    dataout.rms.v = sum(0.5*amp.^2).^0.5;
    
    % return the spectrum in polar form:
    dataout.f.v = f_U;
    dataout.amp.v = amp;
    dataout.phi.v = phi;
    
    % get DFT bin id to extract
    if isfield(datain,'bin')
      % select bin explicitly:
      bin = datain.bin.v+1;
    elseif isfield(datain,'freq')
      % select bin by freq (nearest):
      bin = interp1(f_U,[1:numel(f_U)]',datain.freq.v,'nearest','extrap');
    else
      % default DC:
      bin = 1;
    end  
    
    % return selected DFT bin value:
    dataout.bin_f.v = f_U(bin);
    dataout.bin_A.v = amp(bin);
    dataout.bin_phi.v = phi(bin);
    
    % calculate THD when the 'bin' is fundamental:
    h_list = amp(bin:bin:end);
    dataout.bin_thd.v = sum(h_list(2:end).^2).^0.5/h_list(1)*100;
    
    
    % --- NOTE ---
    % This was very basic calculation, the real stuff is not there:
    % No uncertainty contribution from the correction was implemented yet.
    % No correction to the interchannel cross-talk is present.
    % These are the actual tricky parts to be done.
           
    % --------------------------------------------------------------------
    % End of the demonstration algorithm.
    % --------------------------------------------------------------------
       
   
    % --- my job here is done...
          

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
