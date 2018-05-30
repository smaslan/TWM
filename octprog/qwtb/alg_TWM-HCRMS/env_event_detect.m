function [t_start,t_dur,rms_xtr,found,u_start,u_dur,u_rms_xtr] = env_event_detect(t,v_rms,u_rms,range,int)
% This function scans through the v_rms(t) envelope and detects either 
% positive or negative event (swell, sag/interruption).
% The detection tresholds are given by 'range':
%  range = [start_rms stop_rms], 
% where the stop_rms > start_rms for sag/inerruption and stop_rms < start_rms
% for swell. 'int' enables interpolation.
% 't_start' is event start time or NaN if not detected.
% 't_dur' is event duration time or NaN if not detected.
% 'rms_xtr' is maximum or minimum rms value during the event.
% 'found' is non-zero if full event was found.
% Note the function ignores events that may follow the detected one.
%
% License:
% --------
% This is part of the TWM - Traceable PQ Wattmeter
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.
%    

    % event to detect sag/interruption?
    is_sag = diff(range) > 0;
        
    % calculate uncertainty?
    do_unc = ~isempty(u_rms);
    
    u_start = 0;
    u_dur = 0;
    u_rms_xtr = 0; 
    
    % -- uncertainty loop:
    for k = 1:(1 + do_unc*2)
        
        if k == 1
            % first pass - use clean input rms for both start and stop:
            a_rms = v_rms;
            b_rms = v_rms;
        elseif k == 2
            % second pass (unc. only) - use rms-unc for start and rms+unc for end
            if is_sag
                a_rms = v_rms - u_rms;
                b_rms = v_rms + u_rms;
            else
                a_rms = v_rms + u_rms;
                b_rms = v_rms - u_rms;
            end
        elseif k == 3
            % third pass (unc. only) - use rms+unc for start and rms-unc for end
            if is_sag
                a_rms = v_rms + u_rms;
                b_rms = v_rms - u_rms;
            else
                a_rms = v_rms - u_rms;
                b_rms = v_rms + u_rms;
            end
        end
        
        
        % no event detected yet:
        t_start(k) = NaN;
        t_stop(k) = NaN;
        % no rms extreme detected yet:
        rms_xtr(k) = NaN;
        rms_xtr_id(k) = 0;
                           
        if is_sag
            eia = find(a_rms(1:end-1) > range(1) & a_rms(2:end) <= range(1),1);
        else
            eia = find(a_rms(1:end-1) < range(1) & a_rms(2:end) >= range(1),1);
        end    
        if ~isempty(eia)
            % start event detected:
            if is_sag
                eib = find(b_rms(eia:end-1) < range(2) & b_rms(eia+1:end) >= range(2),1);            
            else
                eib = find(b_rms(eia:end-1) > range(2) & b_rms(eia+1:end) <= range(2),1);
            end
            eia = eia + 1;
                    
            % interpolate exact boundary crossing:
            t_start(k) = t(eia);
            if int
                eia = eia - 1;
                t_start(k) = t(eia) + (range(1) - a_rms(eia))/(a_rms(eia+1) - a_rms(eia))*(t(eia+1) - t(eia));
            end
                    
            if ~isempty(eib)
                % stop event detected:
                %eib = eib + 1;
                eib = eib + eia - 1;
                            
                % interpolate exact boundary crossing:            
                t_stop(k)  = t(eib);
                if int
                    t_stop(k)  = t(eib) + (range(2) - b_rms(eib))/(b_rms(eib+1) - b_rms(eib))*(t(eib+1) - t(eib));
                end
                
                if is_sag
                    [rms_xtr(k),rms_xtr_id(k)] = min(v_rms(eia:eib));                
                else
                    [rms_xtr(k),rms_xtr_id(k)] = max(v_rms(eia:eib));                    
                end
                rms_xtr_id(k) = rms_xtr_id(k) + eia-1;
            
            else
                % no stop event detected:
                t_stop(k) = inf;                 
            end
                 
        end
        
        % found complete flag:
        found(k) = ~isinf(t_start(k)) && ~isinf(t_stop(k)) && ~isnan(t_stop(k)) && ~isnan(t_start(k));
    
    end
    
    if do_unc
    
        if all(found)
            % all events found:
                                    
            u_start = max(abs(t_start - t_start(1)));
            u_stop  = max(abs(t_stop - t_stop(1)));
            u_xtr = max(abs(rms_xtr - rms_xtr(1)));
            
            found = 1;
        
        else
            % result for some combination of uncertainty bound not found - cannot evaluate uncertainty
            
            u_start = 0;
            u_stop  = 0;
            u_xtr = 0;
            
            found = 0;
                                            
        end
               
        % return central values:
        t_start = t_start(1);
        t_stop = t_stop(1);
        rms_xtr = rms_xtr(1);
        
        % estimate residual uncertainty (abs):
        if rms_xtr_id(1)
            u_rms_xtr = u_rms(rms_xtr_id(1));
        else
            u_rms_xtr = 0;
        end
        
        % add alg. uncertainty estimate:
        eia = find(t_start >= t,1);
        eib = find(t_stop >= t,1);
        if found
            dT = t(eia+1) - t(eia+0);            
            u_start = u_start + dT;         
            u_stop  = u_stop + dT;
        end
        
        u_dur = u_stop + u_start;
                        
    end
     
    
    % get duration:
    t_dur = t_stop - t_start;
    if isinf(t_dur)
        t_dur = NaN;
    end
    
end



% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
