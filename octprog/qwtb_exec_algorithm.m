function [] = qwtb_exec_algorithm(meas_file, calc_unc, is_last_avg, avg_id, group_id, verbose, cfg)
% TWM: Executes QWTB algorithm based on the setup from meas. session
%
%  Usage:
%   qwtb_exec_algorithm(meas_file, calc_unc, is_last_avg)
%   qwtb_exec_algorithm(meas_file, calc_unc, is_last_avg, avg_id)
%   qwtb_exec_algorithm(meas_file, calc_unc, is_last_avg, avg_id, group_id)
%   qwtb_exec_algorithm(meas_file, calc_unc, is_last_avg, avg_id, group_id, verbose) 
%
%  inputs:
%   meas_file - full path of the measurement header
%   calc_unc - uncertainty calculation mode override (use '' to default from QWTB session file)
%   is_last_avg - 1 if last averaging cycle was measured, 0 otherwise
%   avg_id - id of the repetition cycle to process (optional)
%          - use 0 or leave empty to use last available 
%   group_id - id of the measurement group (optional)
%            - use -1 or leave empty to use last available
%   verbose - verbose level of the executer (optional)
%           - use 0 to disable any reports from QWTB and loader.
%   cfg - processing configuration structure (optional)
%         cfg.mc_method - Monte Carlo execution mode {'singlecore', 'multicore', 'multistation'}
%         cfg.mc_procno - number of parallel instances to run ('multicore' or 'multistation')
%         cfg.mc_tmpdir - 'multistation' mode jobs sharing folder
%         cfg.mc_user_fun - user function to be executed after 'multistation' starts servers
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
%
    
    if ~exist(meas_file)
        error('QWTB algorithm executer: Selected session path does not exist!');
    end
    
    % measuremet root path 
    meas_root = [fileparts(meas_file) filesep()];
    
    % load QWTB processing setup file
    qwtb_file = [meas_root 'qwtb'];
    
    % default group id
    if ~exist('group_id','var')
        group_id = -1;
    end
    
    % default repetition cycle id
    if ~exist('avg_id','var')
        avg_id = -1;
    end
    
    % default verbose:
    if ~exist('verbose','var')
        verbose = 1;
    end 
    
    % try to load QWTB processing info
    try
        % load the file:
        qinf_txt = infoload(qwtb_file);
        qinf = infoparse(qinf_txt);
        % try to get the content section:
        qinf = infogetsection(qinf, 'QWTB processing setup');
    catch
        % not present - no calculation, no error
        warning('QWTB algorithm executer: No QWTB calculation setup found for given measurement session!');
        return    
    end
    
    % get QWTB algorithm ID:
    alg_id = infogettext(qinf, 'algorithm id');
    
    % fetch information struct of the QWTB algorithm:
    alginfo = qwtb(alg_id,'info');
       
    
    % process all averaging cycles at once?
    proc_all = infogetnumber(qinf, 'calculate whole average at once');
    
    if proc_all && ~is_last_avg
        % processing should be done when all averages are done, but this is not last averaging cycle - do nothing
        return
    end
    
    % uncertainty mode:
    unc_mode = infogettext(qinf,'uncertainty mode');
    
    % try to load MC cycles count:
    try
        calcset.mcm.repeats = infogetnumber(qinf, 'monte carlo cycles');
    catch
        calcset.mcm.repeats = 100;
    end
    
    % ensure default processing configuration:
    if ~exist('cfg','var')
        cfg = struct();
    end
    if ~isfield(cfg,'mc_method')
        cfg.mc_method = 'singlecore';
    end
    if ~isfield(cfg,'mc_procno')
        cfg.mc_procno = 1;
    end
    if ~isfield(cfg,'mc_tmpdir')
        cfg.mc_tmpdir = '';
    end
    
    % override uncertainty setup from file:
    if exist('calc_unc','var') && ~isempty(calc_unc)
        % yaha
        unc_mode = calc_unc;
    end
    % set uncertainty mode to calc. setup:
    if isempty(unc_mode)
        unc_mode = 'none';
    end 
    
    % assign processing setup to QWTB calcset:
    calcset.mcm.method = cfg.mc_method;
    calcset.mcm.procno = cfg.mc_procno;
    if ~isempty(cfg.mc_tmpdir) && strcmpi(unc_mode,'mcm')
        calcset.mcm.tmpdir = cfg.mc_tmpdir;
    end    
    if isfield(cfg,'mc_user_fun')
        calset.mcm.user_fun = cfg.user_fun;
    end
        
    
    % try to load unc. coverage interval:
    try
        calcset.loc = infogetnumber(qinf, 'level of confidence [-]');
    catch
        calcset.loc = 0.95;
    end        
    
    % uncertainty mode:  
    calcset.unc = unc_mode;
    calcset.cor.req = 0;
    calcset.cor.gen = 0;
    calcset.dof.req = 0;
    calcset.dof.gen = 0;
    
    % some fixed options:
    calcset.checkinputs = 1;
    calcset.verbose = verbose;
    
    % get data segmentaion options:
    %  note: this allows to select range of sample data to process    
    % initial sample offset (optional):
    try
        sdata_ofs = infogetnumber(qinf,'sample data offset');
    catch
        sdata_ofs = 0;
    end
    % maximum sample count (optional):
    try
        sdata_lim = infogetnumber(qinf,'sample data limit');
    catch
        sdata_lim = 0;
    end
    
    
    % get list of QWTB algorithm parameter names 
    parameter_names = infogettextmatrix(qinf, 'list of parameter names');
    
    % inputs of the algorithm
    inputs = struct();
  
    % --- try to load values of the parameters
    for p = 1:numel(parameter_names)
    
        % name of the parameter
        name = parameter_names{p};
          
        % get values of the parameter 
        values = infogettextmatrix(qinf, name);    
        % try to convert them to numeric
        num_values = str2double(values);
        
        if ~isempty(values)
        
            % create empty parameter in the QWTB inputs list
            inputs = setfield(inputs, name, struct());
          
            if ~any(isnan(num_values))
                % all values are numeric, assume the parameter is numeric
                
                inputs = setfield(inputs, name, struct('v',num_values));
                          
            else
                % at least some of the parameters are not numeric, assume string type
                
                if numel(values) == 1
                    % scalar - single string parameter
                    inputs = setfield(inputs, name, struct('v',values{1})); 
                else
                    % vector - cell array of string parameters (note: possibly never used, but just in case...)
                    inputs = setfield(inputs, name, struct('v',values));
                end
                  
            end
          
        end
      
    end
  

    % --- identify input types of the algorithm
    
    % QWTB algorithm input parameters
    q_inp = alginfo.inputs;
    
    % is this single input algorithm?
    is_single_inp = qwtb_find_parameter(q_inp,'y');
    if ~is_single_inp
        % no 'y' input - possibly algorithm with 'u' and 'i' inputs?
        
        if ~(qwtb_find_parameter(q_inp,'u') && qwtb_find_parameter(q_inp,'i'))
            % not even that - error
            error(sprintf('QWTB algorithm executer: the algorithm ''%s'' does not have supported inputs (must have ''y'', or ''u'' and ''i'' inputs)!',alg_id));
        end
      
    end
    
    % check if there is timestep input?
    is_time_vec = qwtb_find_parameter(q_inp,'Ts');
    if ~is_time_vec
        error(sprintf('QWTB algorithm executer: the algorithm ''%s'' does not have inputs ''Ts''!',alg_id));
    end
    
    % algorithm supports differential inputs?
    has_diff = qwtb_find_parameter(q_inp,'support_diff');
    
    % algorithm supports multiple waveform input?
    has_multi = qwtb_find_parameter(q_inp,'support_multi_inputs');
    
    % check compatibility:
    if proc_all && ~has_multi
        error(sprintf('QWTB algorithm executer: the algorithm ''%s'' cannot process multiple records at the time!',alg_id));
    end
    
  
    % --- load record(s)
    
    if proc_all
        % process all averages (repetitions) at once
        avg_id = 0;
    end
    
    % load last measurement group
    data = tpq_load_record(meas_file,group_id,avg_id,sdata_ofs,sdata_lim);
    
    % get unique phase indexes from the channels list
    phases = unique(data.corr.phase_idx);
    
    % build channel-quantities names ('u1','i1','u2','i2',...)
    channels = {}; 
    uis = {'u';'i'};
    for c = 1:numel(data.corr.tran)
        channels{c,1} = sprintf('%s%d',uis{1 + strcmpi(data.corr.tran{c}.type,'shunt')},data.corr.phase_idx(c));
        
        % check differential input capability of the algorithm:
        if data.corr.tran{c}.is_diff && ~has_diff
            error(sprintf('QWTB algorithm executer: the algorithm ''%s'' cannot process differential inputs!',alg_id));
        end 
    end
    

    % --- set some specific parameters to the input quantities (common for entire digitizer): 
    
    % store apertures (one for each repetition cycle):
    inputs.adc_aper.v = data.apertures;
    
    % store bit resolution:
    inputs.adc_bits.v = data.bitres;
    
    % store sampling period [s]:
    inputs.Ts.v = data.Ts;
    
    % load timestamps matrix: 
    tm_stamp = data.timestamp;
    
    % load inter-channel time shifts: 
    its = data.corr.dig.time_shifts.its;
    its = bsxfun(@minus,its,its(:,1)); % make it relative to 1. channel
    
    % combine the timestamp and time shift correction to get absolute record start shifts:
    tm_stamp   = bsxfun(@plus,tm_stamp,its);
    u_tm_stamp = repmat(data.corr.dig.time_shifts.u_its,[size(tm_stamp,1) 1]); % uncertainty   
    % ####todo: in future here should be override of time-shift calibration data by self-calibration
    
    
    
    
    % --- prepare result files:
    
    % get file name of the record that is currently loaded (only fist one if multiple loaded)
    result_name = data.record_filenames{1};
    
    % build result folder path
    result_folder = 'RESULTS';
      
    % try make result folder
    if ~exist([meas_root result_folder],'file') 
        mkdir(meas_root, result_folder);
    end
    
    % build result file path base (no extension)
    result_rel_path = [result_folder filesep() alg_id '-' result_name];
    result_path = [meas_root result_rel_path];
    
    % try to remove eventual existing results
    if exist([result_path '.mat'],'file') delete([result_path '.mat']); end
    if exist([result_path '.info'],'file') delete([result_path '.info']); end
      
    % insert copy of QWTB parameters to the result
    rinf = qinf_txt;
    
    
    % --- execute algorithms:
  
    if ~is_single_inp
        % dual input channel algorithm: we must have always paired 'u' and 'i' for each phase
        
        % store list of phases to the results file ('L1','L2',...)
        list = {};
        for p = 1:numel(phases)
            list{p} = sprintf('L%d',phases(p));
        end     
        rinf = infosettextmatrix(rinf, 'list', list);    
        infosave(rinf, result_path);
        
        tags = {};
        
        % --- for each unique phase:
        for p = 1:numel(phases)
            
            % phase index:
            pid = phases(p);
            
            % copy user parameters to the QWTB inputs
            di = inputs;
            
            % phase-channel names:
            pchn_list = {'u','i'};
            
            % for each phase channel (u/i):
            for k = 1:numel(pchn_list)
            
                % phase channel name:
                pchn_pfx = pchn_list{k};
                
                % try to find associated transducer:
                is_shunt = []; % crippled for Matlab < 2016b
                for t = 1:numel(data.corr.tran)
                    is_shunt(t,1) = strcmpi(data.corr.tran{t}.type,'shunt');
                end
                cid = find(data.corr.phase_idx(:) == pid & ~xor(is_shunt,strcmpi(pchn_pfx,'i')));
                
                % check validity:
                if isempty(cid)
                    error(sprintf('QWTB algorithm executer: Missing ''%s'' channel of phase #%d!',pchn_pfx,phases(p)));
                elseif numel(cid) > 1
                    error(sprintf('QWTB algorithm executer: Multiple transducers found for ''%s'' channel of phase #%d!',pchn_pfx,phases(p)));
                end
                % ok, we have found transducer...
                
                % add phase-channel name to list:
                tags{end+1} = [pchn_pfx int2str(cid)];
                
                % transducer:
                tran = data.corr.tran{cid};
                
                % store transducer type:
                if strcmpi(tran.type,'divider')
                    tran_type_str = 'rvd';
                else
                    tran_type_str = 'shunt';
                end
                di = setfield(di,[pchn_pfx '_tr_type'],struct('v',tran_type_str));
                
                if pchn_pfx == 'u'
                    % -- voltage channel:
                    % store measurement time-stamps (one per record, but only for first phase-channel):
                    di.time_stamp.v =   tm_stamp(:,tran.channels(1));
                    di.time_stamp.u = u_tm_stamp(:,tran.channels(1));
                    
                    % remember voltage transducer digitizer main channel (or high-side channel):
                    u_tran_id = tran.channels(1);
                    
                else
                    % -- current channel:                    
                    i_tran_id = tran.channels(1);
                    
                    % store u/i channel timeshift:
                    di.time_shift.v =  diff(tm_stamp(:,[i_tran_id u_tran_id]),[],2);
                    di.time_shift.u = sum(u_tm_stamp(:,[i_tran_id u_tran_id]).^2,2).^0.5; % uncertainty
                    
                end
                
                % for differential mode store low-side channel timeshift:
                if tran.is_diff
                    ts.v =  diff(tm_stamp(:,tran.channels),[],2);
                    ts.u = sum(u_tm_stamp(:,tran.channels).^2,2).^0.5; % uncertainty
                    di = setfield(di, [pchn_pfx '_time_shift_lo'], ts);
                end
                
                
                % generate assigned channel prefixes:
                if tran.is_diff
                    % differential connection:
                    dig_pfx = {pchn_pfx;[pchn_pfx '_lo']};            
                else
                    % single-ended connection:
                    dig_pfx = {pchn_pfx};            
                end 
                             
                % for each digitizer channel assigned to the transducer:
                for c = 1:numel(tran.channels)
                
                    % channel name:
                    pfx = dig_pfx{c};
                    
                    % store range value:
                    di = setfield(di, [pfx '_adc_nrng'], struct('v',data.ranges(c)));                
                
                    % store waveform data:
                    % note stores all available repetitions, one column per repetition:
                    di = setfield(di, pfx, struct('v', data.y(:, tran.channels(c):data.channels_count:end)));
                    
                    % store channel corrections:
                    di = qwtb_alg_insert_corrs(di, data.corr.dig.chn{tran.channels(c)}, pfx);
                
                end
                
                % store transducer corrections:
                di = qwtb_alg_insert_corrs(di,tran,pchn_pfx);
            
            end
            
            % store global digitizer corrections:
            di = qwtb_alg_insert_corrs(di,data.corr.dig,'');
            
            %fieldnames(di)
            
            if ~strcmpi(calcset.unc,'none')
                % generates fake uncertainty vectors complementary to the data:
                di = qwtb_add_unc(di,alginfo.inputs); % ###TODO: remove when QWTB can ignore missing uncertainty
            end            
                       
            % execute algorithm
            dout = qwtb(alg_id,di,calcset);
            
            % discard uncertainties if unc. disabled:
            if strcmpi(unc_mode,'none')
                dout = qwtb_rem_unc(dout);    
            end
            
            % store current channel phase setup info (index; U, I tag)
            phase_info.index = data.corr.phase_idx(p);
            phase_info.tags = tags;
            phase_info.section = list{p};
            
            % store results to the result file
            qwtb_store_results(result_path, dout, alginfo, phase_info);
          
        end
          
    else  
        % --- SINGLE INPUT ALGORITHM ---
        
        % store list of channels to results file         
        rinf = infosettextmatrix(rinf, 'list', channels);
        infosave(rinf, result_path);
        
        % --- for each available transducer:
        for p = 1:numel(data.corr.tran)
        
            % get transducer:
            tran = data.corr.tran{p};
                    
            % generate assigned channel prefixes:
            if tran.is_diff
                % differential connection:
                dig_pfx = {'';'lo'};            
            else
                % single-ended connection:
                dig_pfx = {''};            
            end         
        
            % copy user parameters to the QWTB input quantities:
            di = inputs;
            
            % store transducer type:
            if strcmpi(tran.type,'divider')
                di.tr_type.v = 'rvd';
            else
                di.tr_type.v = 'shunt';
            end
                       
            % store measurement time-stamps (one per record):
            di.time_stamp.v =   tm_stamp(:,tran.channels(1));
            di.time_stamp.u = u_tm_stamp(:,tran.channels(1));
            
            %###TODO: add interchannel timeshifts like for u/i input algorithms!
            % note: already is working, I think..
            
            % for differential mode store low-side channel timeshift:
            if tran.is_diff
                di.time_shift_lo.v =  diff(tm_stamp(:,tran.channels),[],2);
                di.time_shift_lo.u = sum(u_tm_stamp(:,tran.channels).^2,2).^0.5; % uncertainty
                % ###note: summing high+low side unc. which is maybe not correct?
            end
          
            
            % for each digitizer channel assigned to the transducer:
            for c = 1:numel(tran.channels)
            
                % waveform data quantity name:
                pfx = dig_pfx{c};
                d_pfx = 'y';
                if ~isempty(pfx)                    
                    d_pfx = [d_pfx '_' pfx];
                    pfx = [pfx '_'];                
                end
                
                % store range value:
                di = setfield(di,[pfx 'adc_nrng'],struct('v',data.ranges(c)));                
            
                % store waveform data:
                % note stores all available repetitions, one column per repetition:
                di = setfield(di, d_pfx, struct('v', data.y(:, tran.channels(c):data.channels_count:end)));
                
                % store channel corrections:
                di = qwtb_alg_insert_corrs(di,data.corr.dig.chn{tran.channels(c)},dig_pfx{c});
            
            end
            
            % store transducer corrections:
            di = qwtb_alg_insert_corrs(di,tran,'');
            
            % store global digitizer corrections:
            di = qwtb_alg_insert_corrs(di,data.corr.dig,'');
            
            %fieldnames(di)         
            
            if ~strcmpi(calcset.unc,'none')
                % generates fake uncertainty vectors complementary to the data:
                di = qwtb_add_unc(di,alginfo.inputs); % ###TODO: remove when QWTB can ignore missing uncertainty
            end
            
            % execute algorithm
            dout = qwtb(alg_id,di,calcset);
            
            % discard uncertainties if unc. disabled:
            if strcmpi(unc_mode,'none')
                dout = qwtb_rem_unc(dout);    
            end
            
            % store current channel phase setup info (index; U, I tag)
            phase_info.index = data.corr.phase_idx(p);
            phase_info.tags = channels(p);
            phase_info.section = channels{p};
            
            % store results to the result file
            qwtb_store_results(result_path, dout, alginfo, phase_info);
        
        end
      
    end
  
  
    % --- build results header
    
    % full file path to the results header
    results_header = [meas_root 'results.info'];
    
    rinf = '';
    try 
        % try to load the results header
        rinf = infoload(results_header);
        
        % try to get algorithms list
        algs = infogettextmatrix(rinf, 'algorithms');
      
    catch
        % no algorithms yet
        algs = {};
      
    end
  
    % load lists of available results for each algorithm
    algs_hist = {};
    for a = 1:numel(algs)
        algs_hist{a,1} = infogettextmatrix(rinf, algs{a});   
    end
    
    % check if this algorithm is already listed?
    aid = strcmpi(algs, alg_id);
    if any(aid)
        % yaha - find its index in the list    
        aid = find(aid, 1);
    else
        % nope - add new into the list
        algs{end+1,1} = alg_id;
        algs_hist{end+1,1} = {};
        aid = numel(algs);      
    end
    
    % get list of results for this algorithm 
    alg_res_list = algs_hist{aid};
    
    % try to find if there is already this result (previous call of the QWTB with the same algorithm)
    rid = strcmpi(alg_res_list, result_rel_path);
    if any(rid)
        % found - overwrite
        rid = find(rid,1);
        alg_res_list{rid,1} = result_rel_path;
    else
        % not found - add
        alg_res_list{end+1,1} = result_rel_path;
        rid = numel(alg_res_list);
    end
    
    % sort results
    alg_res_list = sort(alg_res_list);  
    rid = find(strcmpi(alg_res_list,result_rel_path),1);
    
    % store back the results list for this algorithm
    algs_hist{aid} = alg_res_list;
      
    
    rinf = '';
    
    % store last calculated algorithm id
    rinf = infosettext(rinf, 'last algorithm', alg_id);
    rinf = infosetnumber(rinf, 'last result id', rid);
    
    % store updated list of algorithms
    rinf = infosettextmatrix(rinf, 'algorithms', algs);
      
    % store lists of results for each algorithm
    for a = 1:numel(algs)
        rinf = infosettextmatrix(rinf, algs{a}, algs_hist{a});    
    end
    
    % write updated results header back to the file 
    infosave(rinf, results_header, 1, 1);  
  
end



function [di] = qwtb_alg_insert_corrs(di,tables,prefix)
% Parameters:
%   di     - QWTB input data
%   table  - correction tables
%   prefix - prefix string of the channel correction (e.g. 'u' or 'i_lo')

    if ~isempty(prefix) 
        prefix = [prefix '_'];
    end
        
    % copy all listed correction tables to the QWTB input data: 
    for k = 1:numel(tables.qwtb_list)        
        di = qwtb_alg_conv_corr(di,getfield(tables,tables.qwtb_list{k}),prefix);                
    end
       
end




function [di] = qwtb_alg_conv_corr(di,tab,prefix)
% This will convert correction table 'correction_load_table()'
% to the QWTB format.
% 
% Parameters:
%   di  - QWTB input data
%   tab - corrections table loaded by 'correction_load_table()'
%         the table must contain struct qwtb:
%           ax_prim - name of the primary axis (optional, may be empty)                
%           ax_sec  - name of the secondary axis (optional, may be empty)
%           v_names - cell array of QWTB variable names
%           v_list  - cell array of the table's variables
%           u_list  - cell array of the table's uncertainties
%   prefix - prefix string of the correction (e.g. 'u_' or 'u_lo_')
%
% example:
%   qwtb.ax_prim = 'Yin_f'
%   qwtb.ax_sec = ''
%   qwtb.v_names = {'Yin_rp','Yin_cp'}
%   qwtb.v_list = {'Rp','Cp'}
%   qwtb.u_list = {'u_Rp','u_Cp'}
%  will create:
%   di.[prefix]Yin_f.v  - primary axis of 'tab'
%   di.[prefix]Yin_rp.v - quantity 'Rp' from 'tab'
%   di.[prefix]Yin_rp.u - quantity 'u_Rp' from 'tab'
%   di.[prefix]Yin_cp.v - quantity 'Cp' from 'tab'
%   di.[prefix]Yin_cp.u - quantity 'u_Cp' from 'tab'
%
    
    % get naming data for QWTB passing from the correction tables:
    if ~isfield(tab,'qwtb')
        error('TWM QWTB algorithm executer: One of corrections contains no naming data ''qwtb'' for passing to the QWTB! Most likely caused by error in the corrections loaders.');
    end
    qw = tab.qwtb;
    
    % set primary axis:
    if ~isempty(qw.ax_prim)    
        ax_data = getfield(tab,tab.axis_y);
        di = setfield(di, [prefix qw.ax_prim], struct('v',ax_data));    
    end
    
    % set secondary axis:
    if ~isempty(qw.ax_sec)    
        ax_data = getfield(tab,tab.axis_x);
        di = setfield(di, [prefix qw.ax_sec], struct('v',ax_data));    
    end
    
    % set all quantities: 
    Q = numel(qw.v_names);
    for q = 1:Q
        % init. QWTB variable:
        qu = struct();
        
        % set quantity value:
        qu.v = getfield(tab,qw.v_list{q});
        
        % set quantity uncertainty (optional):
        if ~isempty(qw.u_list{q})
            qu.u = getfield(tab,qw.u_list{q});
        end
        
        % set parameter to the QWTB input data: 
        di = setfield(di, [prefix qw.v_names{q}], qu);
    end

end


function [din] = qwtb_add_unc(din,pin)
% this will create fake uncertainty for each non-parameter quantity
% ###TODO: to be removed, when QWTB will support no-unc checking
% It is just a temporary workaround.

    names = fieldnames(din);
    N = numel(names);

    p_names = {pin(~~[pin.parameter]).name};
    
    for k = 1:N
        if ~any(strcmpi(p_names,names{k}))
            v_data = getfield(din,names{k});
            if ~isfield(v_data,'u')
                v_data.u = 0*v_data.v;
                din = setfield(din,names{k},v_data);
            end
        end        
    end    
end


function [din] = qwtb_rem_unc(din)
% this removes uncertainties from all din QWTB quantities
    names = fieldnames(din);
    N = numel(names);
    for k = 1:N
        v_data = getfield(din,names{k});
        if isfield(v_data,'u')
            v_data = rmfield(v_data,'u');
            din = setfield(din,names{k},v_data);
        end        
    end    
end