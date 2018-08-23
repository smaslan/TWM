function dout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm TWM-InDiSwell.
%
% See also qwtb
%
% Format input data --------------------------- %<<<1
    
    % Restore orientations of the input vectors to originals (before passing via QWTB)
    % This is critical for the correction data! 
    %[din,cfg] = qwtb_restore_twm_input_dims(datain,1);

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
    
    % timestamp phase compensation state:
    do_plots = isfield(datain, 'plot') && ((isnumeric(datain.plot.v) && datain.plot.v) || (ischar(datain.plot.v) && strcmpi(datain.plot.v,'on')));
    
    if ~isfield(calcset,'dbg_plots')
        calcset.dbg_plots = 0;
    end        
    
    
    % --------------------------------------------------------------------
    % Start of the algorithm
    % --------------------------------------------------------------------
    
    % --- calculate rms envelope using desired settings:
    rem_flds = {'nom_rms','hyst','sag_tres','swell_tres','int_tres'};
    for k = 1:numel(rem_flds)
        try
            datain = rmfield(datain,rem_flds{k});
        end
    end
    
    cset = calcset;
    cset.loc = 0.681; % calculate with standard unc.
    din = datain;
    try
        din = rmfield(din,'plot');
    end
    dout = qwtb('TWM-HCRMS',din,cset);
    
    % restore path:
    qwtb('TWM-InDiSwell','addpath');  
    
    % extract envelope:   
    env_time = dout.t.v;
    u_tw = max(dout.t.u);
    env_rms = dout.rms.v;    
    u_env_rms = dout.rms.u/cset.loc; % estimate of 'worst case' error
    
    % extract estimate of fundamental frequency:
    f0_avg = dout.f0.v;
    
       
    if calcset.verbose
        fprintf('Detecting events...\n');
    end
               
    % define event setups:
    event_list{1}.tr_start = nom_rms*0.01*(sag_tres);
    event_list{1}.tr_stop  = nom_rms*0.01*(sag_tres + hyst);
    event_list{1}.name     = 'sag';
    event_list{1}.qu_name  = 'sag';
    
    event_list{2}.tr_start = nom_rms*0.01*(swell_tres);
    event_list{2}.tr_stop  = nom_rms*0.01*(swell_tres - hyst);
    event_list{2}.name     = 'swell';
    event_list{2}.qu_name  = 'swell';    
    
    event_list{3}.tr_start = nom_rms*0.01*(int_tres);
    event_list{3}.tr_stop  = nom_rms*0.01*(int_tres + hyst);
    event_list{3}.name     = 'interruption';
    event_list{3}.qu_name  = 'int';
    
    % -- for each event:
    for k = 1:numel(event_list)
    
        % get event definition:
        ev = event_list{k};
        
        % expand the rms envelope uncertainty to 'worst case':
        u_env_rms_det = u_env_rms; 
    
        % detect event:
        [t_start,t_dur,rms_xtr,found,u_start,u_dur,u_rms_xtr] = env_event_detect(env_time,env_rms,u_env_rms_det,[ev.tr_start, ev.tr_stop], mode == 'S');
        
        % worst case time error of each sample:
        u_tev = u_tw*2;
        % add time uncertainty to the event times:
        u_start = u_start + u_tev;
        u_dur = u_dur + u_tev;
                
        % minimum detector. error:
        u_start   = max(u_start,0.5/f0_avg)*calcset.loc/0.95;
        u_dur     = max(u_dur,1.0/f0_avg)*calcset.loc/0.95;
        u_rms_xtr = u_rms_xtr*calcset.loc/0.95;
        
        if strcmpi(calcset.unc,'none')
            % clear uncertainty if it's disbaled:
            u_start = 0;
            u_dur = 0;
            u_rms_xtr = 0;
        end
        
        
        % residual ratio to nominal:
        resid = 100*rms_xtr/nom_rms;
        u_resid = 100*u_rms_xtr/nom_rms;
        
        % store results:
        dout = setfield(dout, [ev.qu_name '_start'], struct('v',t_start,'u',u_start));
        dout = setfield(dout, [ev.qu_name '_dur'], struct('v',t_dur,'u',u_dur));
        dout = setfield(dout, [ev.qu_name '_res'], struct('v',resid,'u',u_resid));
                
        if do_plots
            % plot basic rms and tresholds:    
            figure
            plot(env_time,env_rms,'b','LineWidth',1.5) % rms(t)
            hold on;
            plot([env_time(1),env_time(end)],[1 1]*nom_rms,'r:')
            plot([env_time(1),env_time(end)],[1 1]*ev.tr_start,'r--')
            plot([env_time(1),env_time(end)],[1 1]*ev.tr_stop,'r--')
            
            ylim_tmp = ylim();
            ylim_tmp(1) = 0;               
            
            if found
            
                % plot event markers:
                ev_ts = [t_start t_start+t_dur];
                ev_rs = interp1(env_time,env_rms,ev_ts,'linear','extrap');           
                plot(ev_ts,ev_rs,'r.');
                
                plot([env_time(1),env_time(end)],[1 1]*rms_xtr,'k:') % extreme rms              
                plot([1 1]*ev_ts(1),ylim_tmp,'r-')
                plot([1 1]*ev_ts(2),ylim_tmp,'r-')
                
                % autoscale the event:
                left = max(t_start - 1.5*t_dur,env_time(1));
                right = min(t_start + 2.5*t_dur,env_time(end));            
                xlim([left right]);
                
            end
            
            ylim(ylim_tmp);    
            hold off;
            
            tit = sprintf('%s (none)',ev.name);
            if found
                tit = sprintf('%s (duration = %.3fs)',ev.name,t_dur);
            end
            
            title(tit);
            xlabel('time [s]');
            ylabel('rms [V or A]');
        end
        
    end

    % apply time scale uncertainty to the event times:
%     dout.sag_start.u = dout.sag_start.u + interp1(t,u_tb_corr,dataout.sag_start.v,'linear','extrap');
%     dout.sag_dur.u   = dout.sag_dur.u   + interp1(t,u_tb_corr,dataout.sag_start.v + 0.5*dataout.sag_dur.v,'linear','extrap');
%     dout.swell_start.u = dout.swell_start.u + interp1(t,u_tb_corr,dataout.swell_start.v,'linear','extrap');
%     dout.swell_dur.u   = dout.swell_dur.u   + interp1(t,u_tb_corr,dataout.swell_start.v + 0.5*dataout.swell_dur.v,'linear','extrap');
%     dout.int_start.u = dout.int_start.u + interp1(t,u_tb_corr,dataout.int_start.v,'linear','extrap');
%     dout.int_dur.u   = dout.int_dur.u   + interp1(t,u_tb_corr,dataout.int_start.v + 0.5*dataout.int_dur.v,'linear','extrap');
    
           
    
    % --- returning results ---    
    
           
    % --------------------------------------------------------------------
    % End of the algorithm.
    % --------------------------------------------------------------------


end % function



% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
