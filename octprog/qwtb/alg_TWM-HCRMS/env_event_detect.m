function [t_start,t_dur,rms_xtr,found] = env_event_detect(t,rms,u_rms,range,int)
% This function scans through the rms(t) envelope and detects either 
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
    
    % no event detected yet:
    t_start = NaN;
    t_stop = NaN;
    
    % no rms extreme detected yet:
    rms_xtr = NaN;
    
    if is_sag
        eia = find(rms(1:end-1) > range(1) & rms(2:end) <= range(1),1);
    else
        eia = find(rms(1:end-1) < range(1) & rms(2:end) >= range(1),1);
    end    
    if ~isempty(eia)
        % start event detected:
        if is_sag
            eib = find(rms(eia:end-1) < range(2) & rms(eia+1:end) >= range(2),1);            
        else
            eib = find(rms(eia:end-1) > range(2) & rms(eia+1:end) <= range(2),1);
        end
        eia = eia + 1;
                
        % interpolate exact boundary crossing:
        t_start = t(eia);
        if int
            eia = eia - 1;
            t_start = t(eia) + (range(1) - rms(eia))/(rms(eia+1) - rms(eia))*(t(eia+1) - t(eia));
        end
                
        if ~isempty(eib)
            % stop event detected:
            %eib = eib + 1;
            eib = eib + eia - 1;
                        
            % interpolate exact boundary crossing:            
            t_stop  = t(eib);
            if int
                t_stop  = t(eib) + (range(2) - rms(eib))/(rms(eib+1) - rms(eib))*(t(eib+1) - t(eib));
            end
            
            if is_sag
                rms_xtr = min(rms(eia:eib));
            else
                rms_xtr = max(rms(eia:eib));
            end
        
        else
            % no stop event detected:
            t_stop = inf;                 
        end
                            
    end
    
    % found complete flag:
    found = ~isinf(t_start) && ~isinf(t_stop) && ~isnan(t_stop) && ~isnan(t_start);
    
    % get duration:
    t_dur = t_stop - t_start;
    if isinf(t_dur)
        t_dur = NaN;
    end
    
end



% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
