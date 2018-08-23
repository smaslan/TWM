function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm TWM-PSFE.
%
% See also qwtb
%
% Format input data --------------------------- %<<<1
    
    % Restore orientations of the input vectors to originals (before passing via QWTB)
    % This is critical for the correction data! 
    [datain,cfg] = qwtb_restore_twm_input_dims(datain,1);

    if cfg.y_is_diff
        % Input data 'y' is differential: if it is not allowed, put error message here
        %error('Differential input data ''y'' not allowed!');     
    end
    
    if cfg.is_multi
        % Input data 'y' contains more than one record: if it is not allowed, put error message here
        error('Multiple input records in ''y'' not allowed!'); 
    end
    

    % try to obtain sampling rate from alternative input quantities [Hz]
    if isfield(datain, 'fs')
        Ts = 1./datain.fs.v;
    elseif isfield(datain, 'Ts')
        Ts = datain.Ts.v;
    else
        Ts = mean(diff(datain.t.v));
    end
    
    % PSFE frequency estimate mode:
%     if isfield(datain, 'f_estimate') && isnumeric(datain.f_estimate.v) && ~isempty(datain.f_estimate.v)
%         f_estimate = datain.f_estimate.v;
%     else
%         % default:
%         f_estimate = 1;
%     end
    
    % timestamp phase compensation state:
    tstmp_comp = isfield(datain, 'comp_timestamp') && ((isnumeric(datain.comp_timestamp.v) && datain.comp_timestamp.v) || (ischar(datain.comp_timestamp.v) && strcmpi(datain.comp_timestamp.v,'on')));
    
    % --- get ADC LSB value
    if isfield(datain,'lsb')
        % get LSB value directly
        lsb = datain.lsb.v;
    elseif isfield(datain,'adc_nrng') && isfield(datain,'adc_bits')
        % get LSB value estimate from nominal range and resolution
        lsb = 2*datain.adc_nrng.v*2^(-datain.adc_bits.v);    
    else
        error('PSFE, corrections: Correction data contain no information about ADC resolution+range or LSB value!');
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
    
    % remove ADC DC offset:
    y = y - datain.adc_offset.v;    
    
    if cfg.y_is_diff
        % differential input - subtract diff. inputs  channels in time domain:
        % note: this is very crude solution, in fact the inputs should have independent corrections applied
        %       and the they can be subtracted, but this is too complex. For freq. estimate the subtraction
        %       should produce usable output as long as the transfers of the channels do not differ drastically
        
        y = y - datain.y_lo.v;
        
        % remove DC offset of the low-side channel:
        y = y + datain.lo_adc_offset.v;
        
    end
    
%     if f_estimate < 0
%         % apply initial f. estimate correction:
%         f_estimate = f_estimate.*(1 + datain.adc_freq.v);
%     end


    
    

    
    % call low level PSFE algorithm to obtain estimate of the harmonic:
    %  note: no uncertainty at this time because we don't know all necessary parameters yet! 
    din.Ts = struct('v',Ts, 'u',0*Ts);
    din.y  = struct('v',y,  'u',0*y);
    cset = calcset;
    cset.unc = 'none';
    cset.verbose = 0;
    dout = qwtb('PSFE',din,cset);
    qwtb('TWM-PSFE','addpath'); % ###todo: fix qwtb so it does not loose the path every time another alg. is called    
    f  = dout.f.v;
    A  = dout.A.v;
    ph = dout.ph.v;
 
    
    % store original frequency before tb. correction:
    f_org = f;
    % apply timebase frequency correction:    
    % note: it is relative correction of timebase error, so apply inverse correction to measured f.  
    f = f./(1 + datain.adc_freq.v);    
    % calculate correction uncertainty (absolute):
    u_af = f.*datain.adc_freq.u;          

    
    % check deviation of the estimate from initial guess:       
%     if f_estimate < 0 && abs((-f_estimate - f)/f) > 0.05
%         add_warn(warn, 'Deviation of freq. estimate from user initial guess higher than 5%');
%     end
    
         
    if cfg.y_is_diff
        % diff. mode: invalidate everything but frequency: 
        A = NaN;
        ph = NaN;        
        u_g = 0;
        u_p = 0;
        u_fx = 0;
        
    else
        % --- SE mode: apply corrections

        % apply time-stamp phase correction:
        if tstmp_comp
            % note: assume frequency comming from digitizer tb., because the timestamp comes also from dig. timebase
            ph = ph - datain.time_stamp.v*f_org*2*pi;
            % calc. uncertainty contribution:
            u_p_ts = 2*pi*((datain.time_stamp.u*f_org)^2 + (datain.time_stamp.v*u_af)^2)^0.5;
        else
            u_p_ts = 0;
        end
        
        
        % calculate aperture corrections (when enabled and some non-zero value entered for the aperture time):
        if datain.adc_aper_corr.v && abs(datain.adc_aper.v) > 1e-12 
        
            % get aperture time:
            ta = datain.adc_aper.v;
          
            % calculate gain correction:
            ap_gain = (pi*ta*f)./sin(pi*ta*f);
            % calculate phase correction:
            ap_phi = pi*ta*f;
            
            % apply the corrections:
            A = A*ap_gain;
            ph = ph + ap_phi; 
        
        end        
                
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
        
        % get ADC SFDR value:
        adc_sfdr = correction_interp_table(tab.adc_sfdr, A, f);
                
        % apply the digitizer transfer correction:
        A = A.*adc_gain.gain;
        ph = ph + adc_phi.phi;      
        
        
        % --- now apply transducer gain/phase corrections:
        
        if isempty(datain.tr_type.v)
            % -- transducer type not defined:
            warning('Transducer type not defined! Not applying tran. correction!');
            u_A  = A*u_ag;
            u_ph = ph*u_ap;
        else
            % -- tran. type defined, apply correction:
            [A,ph,u_A,u_ph] = correction_transducer_loading(tab,datain.tr_type.v,f,[], A,ph,A.*adc_gain.u_gain,adc_phi.u_phi);                
        end
        
        if any(isnan(A))
            error('Transducer gain/phase correction data or terminal/cable impedances do not have sufficient range!');
        end
        
        % get transducer SFDR value estimate:
        tr_sfdr = correction_interp_table(tab.tr_sfdr, A*2^-0.5, f);
        
        % interpolate the gain/phase tfer table to the measured frequencies but NOT rms:        
        tr_gain = correction_interp_table(tab.tr_gain,[],f);
        tr_phi  = correction_interp_table(tab.tr_phi, [],f);
        
        % interpolate the gain/phase tfer table to the measured frequencies with rms estimate from single A component:        
        tr_gain_rms = correction_interp_table(tab.tr_gain, (0.5*A^2)^0.5, f);
        tr_phi_rms  = correction_interp_table(tab.tr_phi,  (0.5*A^2)^0.5, f);
        
        % get the rms-independent tfer:
        % note: for this alg. it is not possible to evaluate RMS easily, so lets assume the correction is not dependent on it...
        % the nanmean is used to find mean correction coefficient for all available rms-values ignoring missing NaN-data  
        kgain = nanmean(tr_gain.gain,2);
        kphi = nanmean(tr_phi.phi,2);
                
        % check if there aren't some NaNs in the correction data - that means user correction dataset contains some undefined values:
        if any(isnan(kgain)) || any(isnan(kphi))
            error('Transducer gain/phase correction data do not have sufficient frequency range!');
        end
        
        % get transducer correction uncertainty contribution:
        % correction may be rms dependent, but we have not RMS value, so lets estimate worst case error from:
        % 1) the worst uncertainty for all rms-values
        % 2) the difference between max and min correction value for all rms-values
        % that should give decent worst case estimate
        
        % 1) worst uncertainty (normal distr.):
        u_tg = max(tr_gain.u_gain,[],2);
        u_tp = max(tr_phi.u_phi,[],2);
        
        % 2) largest difference of all corr. data from mean corr. data (rectangular distr.):
        d_tg = max(max(tr_gain.gain,[],2) - kgain, kgain - min(tr_gain.gain,[],2));
        d_tp = max(max(tr_phi.phi,[],2) - kphi, kphi - min(tr_phi.phi,[],2));
        
        % note: the loading correction function already added uncertainty of tfer,
        % we need to subtract it from the uncertainty so the 1) is not included twice in the end:
        u_tg_rms = tr_gain_rms.u_gain;
        u_tp_rms = tr_phi_rms.u_phi;           
        
        % combine:
        if ~isnan(d_tg)
            u_tg = (u_tg.^2 + d_tg.^2/3).^0.5;        
        end
        if ~isnan(d_tp)
            u_tp = (u_tp.^2 + d_tp.^2/3).^0.5;        
        end
        

        if ~strcmpi(calcset.unc,'none')
        
            % get effective ADC + transducer SFDR:
            sfdr_sys = -20*log10(10^(-adc_sfdr.sfdr/20) + 10^(-tr_sfdr.sfdr/20));
                       
            % call low level PSFE algorithm to obtain estimate of the harmonic:
            %  note: this time with uncertainty becasue we know all the required parameters...
            din.jitter.v = datain.adc_jitter.v;
            din.adcres.v = lsb*adc_gain.gain*kgain;
            din.sfdr.v = sfdr_sys;
            cset = calcset;
            cset.loc = 0.68; % calculate with standard uncertainty
            cset.verbose = 0;  
            dout = qwtb('PSFE',din,cset);
            qwtb('TWM-PSFE','addpath'); % ###todo: fix qwtb so it does not loose the path every time another alg. is called
            u_fx = dout.f.u;
        else
            % no uncertainty:
            u_fx = 0;
        end
        
        % absolute uncertainty of the gain corrections:
        u_g = ((A.*u_tg).^2 + u_A.^2 - (A.*u_tg_rms).^2).^0.5;
        
        % absolute uncertainty of the phase corrections:
        u_p = (u_tp.^2 + u_ph.^2 + u_p_ts.^2 - u_tp_rms.^2).^0.5;
        
        % wrap phase to interval <-pi;+pi>:
        ph = mod(ph + pi,2*pi) - pi;

    end
    
    % absolute uncertainty of the frequency:         
    u_f = (u_af^2 + u_fx^2)^0.5;
    
    
    % return calculated quantities:
    dataout.f.v = f;
    dataout.f.u = u_f*loc2covg(calcset.loc,50);    
    dataout.A.v = A;
    dataout.phi.v = ph;
    dataout.A.u = u_g;
    dataout.phi.u = u_p;
        
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
