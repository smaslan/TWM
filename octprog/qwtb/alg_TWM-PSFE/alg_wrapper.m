function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm TWM-PSFE.
%
% See also qwtb
%
% Format input data --------------------------- %<<<1
         
    
    % Restore orientations of the input vectors to originals (before passing via QWTB)
    % This is critical for the correction data! 
    [datain,cfg] = qwtb_restore_twm_input_dims(datain,1);
        
    % try to obtain sampling rate from alternative input quantities [Hz]
    if isfield(datain, 'fs')
        Ts = 1./datain.fs.v;
    elseif isfield(datain, 'Ts')
        Ts = datain.Ts.v;
    else
        Ts = mean(diff(datain.t.v));
    end
    
    % PSFE frequency estimate mode:
    if isfield(datain, 'f_estimate') && isnumeric(datain.f_estimate.v) && ~isempty(datain.f_estimate.v)
        f_estimate = datain.f_estimate.v;
    else
        % default:
        f_estimate = 1;
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
    % Start of the algorithm
    % --------------------------------------------------------------------
    
    % clear algorithm warning message:
    warn = '';
    
    % load input signal (or high-side input channel for diff. mode):
    y = datain.y.v;    
    
    if cfg.y_is_diff
        % differential input - subtract diff. inputs  channels in time domain:
        % note: this is very crude solution, in fact the inputs should have independent corrections applied
        %       and the they can be subtracted, but this is too complex. For freq. estimate the subtraction
        %       should produce usable output as long as the transfers of the channels do not differ drastically
        
        y = y - datain.y_lo.v;
        
    end
    
    if f_estimate < 0
        % apply initial f. estimate correction:
        f_estimate = f_estimate.*(1 + datain.adc_freq.v);
    end
    
    % call PSFE to obtain estimate:
    [f, A, ph] = PSFE(y,Ts,f_estimate);
    
    % store original frequency before tb. correction:
    f_org = f;
    % apply timebase frequency correction:    
    % note: it is relative correction of timebase error, so apply inverse correction to measured f.  
    f = f./(1 + datain.adc_freq.v);    
    % calculate correction uncertainty (absolute):
    u_af = f.*datain.adc_freq.u;           

    
    % check deviation of the estimate from initial guess       
    if f_estimate < 0 && abs((-f_estimate - f)/f) > 0.05
        add_warn(warn, 'Deviation of freq. estimate from user initial guess higher than 5%');
    end
    
         
    if cfg.y_is_diff
        % diff. mode: invalidate everything but frequency: 
        A = NaN;
        ph = NaN;
        
    else
        % --- SE mode: apply corrections

        % apply time-stamp phase correction:
        % note: assume frequency comming from digitizer tb., because the timestamp comes also from dig. timebase
        ph = ph - datain.time_stamp.v*f_org*2*pi;
        % calc. uncertainty contribution:
        u_p_ts = datain.time_stamp.u*f_org*2*pi;        
        
        % Unite frequency/amplitude axes of the digitizer channel gain/phase corrections:
        [gp_tabs, ax_a, ax_f] = correction_expand_tables({tab.adc_gain, tab.adc_phi});
        
        % extract correction tables for this channel:
        adc_gain = gp_tabs{1};
        adc_phi = gp_tabs{2};       
        
        % check if correction data have sufficient range for the measured spectrum components:
        % note: isempty() tests is used to identify if the correction is not dependent on the axis, therefore the error check does not apply
        if ~isempty(ax_f) && (f < min(ax_f) || f > max(ax_f))
            error('Digitizer gain/phase correction data do not have sufficient frequency range!');
        end    
        if ~isempty(ax_a) && (A < min(ax_a) || A > max(ax_a))
            error('Digitizer gain/phase correction data do not have sufficient amplitude range!');
        end
        
        % interpolate the gain/phase tables to the measured frequency and amplitude:
        adc_gain = correction_interp_table(adc_gain,A,f,'f',1);
        adc_phi = correction_interp_table(adc_phi,A,f,'f',1);
        
        
        
        % check if there are some NaNs in the correction data - that means user correction dataset contains some undefined values:
        if any(isnan(adc_gain.gain)) || any(isnan(adc_phi.phi))
            error('Digitizer gain/phase correction data do not have sufficient frequency range!');
        end
                
        % apply the digitizer transfer correction:
        A = A.*adc_gain.gain;
        ph = ph + adc_phi.phi;
        
        % get digitizer correction uncertainty contribution:
        u_ag = adc_gain.u_gain;
        u_ap = adc_phi.u_phi;
        
        
        
        % --- now apply transducer gain/phase corrections:
        % this will be more tricky, because trans. correction data are dependent on the input rms value so,
        
        % unite frequency/amplitude axes of the transducer gain/phase corrections: 
        [tabs,ax_a,ax_f] = correction_expand_tables({tab.tr_gain, tab.tr_phi});
        % extract modified tables:
        tr_gain = tabs{1};
        tr_phi = tabs{2};
                
        % check if correction data have sufficient range for the measured spectrum components:
        % note: isempty() tests is used to identify if the correction is not dependent on the axis, therefore the error check does not apply
        if ~isempty(ax_f) && (f < min(ax_f) || f > max(ax_f))
            error('Transducer gain/phase correction data do not have sufficient frequency range!');
        end    
        if ~isempty(ax_a) && (A < min(ax_a) || A > max(ax_a))
            error('Transducer gain/phase correction data do not have sufficient amplitude range!');
        end
        
        % interpolate the gain/phase tfer table to the measured frequencies but NOT amplitudes:        
        tr_gain = correction_interp_table(tr_gain,[],f);
        tr_phi = correction_interp_table(tr_phi,[],f);
        
        % get the rms-independent tfer:
        % note: for this alg. it is not possible to evaluate RMS easily, so lets assume the correction is not dependent on it...
        % the nanmean is used to find mean correction coefficient for all available rms-values ignoring missing NaN-data  
        kgain = nanmean(tr_gain.gain,2);
        kphi = nanmean(tr_phi.phi,2);
                
        % check if there aren't some NaNs in the correction data - that means user correction dataset contains some undefined values:
        if any(isnan(kgain)) || any(isnan(kphi))
            error('Transducer gain/phase correction data do not have sufficient frequency range!');
        end
        
        % apply the tfer to the signal to get INPUT signal estimate:
        A = A.*kgain;
        ph = ph + kphi;
                
        
        % get transducer correction uncertainty contribution:
        % as we ignored the correction might be rms-dependent, lets assume the uncertainty has two parts:
        % 1) the worst uncertainty for all rms-values
        % 2) the difference between max and min correction value for all rms-values
        % that should give decent worst case estimate
        
        % 1) worst uncertainty (normal distr.):
        u_tg = max(tr_gain.u_gain,[],2);
        u_tp = max(tr_phi.u_phi,[],2);
        
        % 2) largest difference of all corr. data from mean corr. data (rectangular distr.):
        d_tg = max(max(tr_gain.gain,[],2) - kgain, kgain - min(tr_gain.gain,[],2));
        d_tp = max(max(tr_phi.phi,[],2) - kphi, kphi - min(tr_phi.phi,[],2));        
        
        % combine:
        if ~isnan(d_tg)
            u_tg = (u_tg.^2 + d_tg.^2/3).^0.5;        
        end
        if ~isnan(d_tp)
            u_tp = (u_tp.^2 + d_tp.^2/3).^0.5;        
        end
        
        % wrap phase to interval <-pi;+pi>:
        ph = mod(ph + pi,2*pi) - pi;
                                
        
        % --- now calculate estimate of the uncertainty:
        % note: only contributions of correction applied yet
        % ###TODO: 1) contribution of the PSFE itself
        %          2) some estimate of the effect of the simplified diff. mode
        %          3) sampling jitter effect
        
        % absolute uncertainty of the gain corrections:
        u_g = A.*(u_tg.^2 + u_ag.^2).^0.5;
        
        % absolute uncertainty of the phase corrections:
        u_p = (u_tp.^2 + u_ap.^2 + u_p_ts.^2).^0.5;
        
    end
    
    % absolute uncertainty of the frequency:         
    u_f = u_af;
    
    
    % return calculated quantities:
    dataout.f.v = f;
    dataout.f.u = u_f;    
    dataout.A.v = A;
    dataout.phi.v = ph;
    if ~cfg.y_is_diff
        dataout.A.u = u_g;
        dataout.phi.u = u_p;
    end
    
    % return warning(s):
    dataout.warning.v = warn;      
        
           
    % --------------------------------------------------------------------
    % End of the demonstration algorithm.
    % --------------------------------------------------------------------


end % function


% append warrning message:
function warn = add_warn(warn, new_warn)
    if ~isempty(warn)
        warn = [warn '|'];
    end
    warn = [warn new_warn];    
end


% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
