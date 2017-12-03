%% -----------------------------------------------------------------------------
%% TracePQM: Executes QWTB algorithm based on the setup from meas. session
%%  inputs:
%%   meas_file - full path of the measurement header
%%   calc_unc - uncertainty calculation mode {0: no, 1: estimate, 2: MCM}
%%   is_last_avg - 1 if last averaging cycle was measured, 0 otherwise
%%   avg_id - id of the repetition cycle to process (optional)
%%          - use 0 or leave empty to use last available 
%%
%% -----------------------------------------------------------------------------
function [] = qwtb_exec_algorithm(meas_file, calc_unc, is_last_avg, avg_id)

  % load measurement file header
  inf = infoload(meas_file);
  
  % measuremet root path 
  meas_root = [fileparts(meas_file) filesep()];
  
  % default repetition cycle id
  if ~exist('avg_id','var')
    avg_id = -1;
  end
  
  % try to load QWTB processing info
  try
    qinf = infogetsection(inf, 'QWTB processing setup');
  catch
    % not present - no calculation, no error
    return    
  end
  
  % process all averaging cycles at once?
  proc_all = infogetnumber(qinf, 'calculate whole average at once');
  
  if proc_all && ~is_last_avg
    % processing should be done when all averages are done, but this is not last averaging cycle - do nothing
    return
  end
  
  % get QWTB algorithm ID
  alg_id = infogettext(qinf, 'algorithm id');
  
  
  % get list of QWTB algorithm parameter names 
  parameter_names = infogetmatrixstr(qinf, 'list of parameter names');
  
  % inputs of the algorithm
  inputs = struct();
  
  % --- try to load values of the parameters
  for p = 1:numel(parameter_names)
  
    % name of the parameter
    name = parameter_names{p};
    
    % create empty parameter in the QWTB inputs list
    inputs = setfield(inputs, name, struct());
  
    % get values of the parameter 
    values = infogetmatrixstr(qinf, name);    
    % try to convert them to numeric
    num_values = cellfun('str2num', values, 'UniformOutput', false);
    
    if all(cellfun('numel', num_values))
      % all values are numeric, assume the parameter is numeric
         
      eval(sprintf('inputs.%s = setfield(inputs.%s, ''v'', cell2mat(num_values));',name,name));
                  
    else
      % at least some of the parameters are not numeric, assume string type
      
      if numel(num_values) == 1
        % scalar - single string parameter
        eval(sprintf('inputs.%s = setfield(inputs.%s, ''v'', values{1});',name,name));
      else
        % vector - cell array of string parameters (note: possibly never used, but just in case...)
        eval(sprintf('inputs.%s = setfield(inputs.%s, ''v'', values);',name,name));
      end
      
    end
    
  end
  
  % --- identify input types of the algorithm
    
  % fetch information struct of the QWTB algorithm
  alginfo = qwtb(alg_id,'info');
  
  % QWTB algorithm input parameters
  q_inp = alginfo.inputs;
  
  is_single_inp = qwtb_find_parameter(q_inp,'y');
  if ~is_single_inp
    % no 'y' input - possibly algorithm with 'u' and 'i' inputs?
    
    if ~(qwtb_find_parameter(q_inp,'u') && qwtb_find_parameter(q_inp,'i'))
      % not even that - error
      error(sprintf('QWTB algorithm executer: the algorithm ''%s'' does not have supported inputs (must have ''y'', or ''u'' and ''i'' inputs)!',alg_id));
    end
    
  end
  
  % check if there is time vector input?
  is_time_vec = qwtb_find_parameter(q_inp,'t');
  if ~is_time_vec
    error(sprintf('QWTB algorithm executer: the algorithm ''%s'' does not have inputs ''t''!',alg_id));
  end
  
  
  % --- load record(s)
  
  if proc_all
    % process all averages at once
    avg_id = 0;
  end
  
  % load last measurement group
  data = tpq_load_record(meas_file,-1,avg_id);
    
  
  % no assigned channel yet
  assgn_channels = zeros(data.channels_count,1);
  
  % get unique phase indexes from the channels list
  phases = unique(data.corr.phase_idx);
  
  % build channel-quantities names ('u1','i1','u2','i2',...)
  channels = {}; 
  uis = {'u';'i'};
  for c = 1:data.channels_count
    channels{c,1} = sprintf('%s%d',uis{1 + strcmpi(data.corr.tran{c}.type,'shunt')},data.corr.phase_idx(c)); 
  end
  
  % duplicate phase and quantity for some channel?
  if numel(unique(channels)) ~= numel(channels)
    error('QWTB algorithm executer: Some channels have the same phase index and the same quantity (current or voltage)!');
  end
  
    
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
  rinf = infosetsection('QWTB parameters', qinf);
  
  
  if ~is_single_inp
    % dual input channel algorithm: we must have always paired 'u' and 'i' for each phase
    
    % store list of phases to the results file
    list = {};
    for p = 1:numel(phases)
      list{p} = sprintf('L%d',phases(p));
    end     
    rinf = infosetmatrixstr(rinf, 'list', list);    
    infosave(rinf, result_path);
    
    % --- for each unique phase:
    for p = 1:numel(phases)
      % build this phase 'u' and 'i' names
      u_name = sprintf('u%d',phases(p)); 
      i_name = sprintf('i%d',phases(p));
      
      % try to find voltage channel
      u_id = find(strcmpi(channels,u_name),1);
      if ~numel(u_id)
        error(sprintf('QWTB algorithm executer: Missing voltage channel for phase #%d!',uniphx(p)));
      end
      
      % try to find current channel 
      i_id = find(strcmpi(channels,i_name),1);
      if ~numel(u_id)
        error(sprintf('QWTB algorithm executer: Missing current channel for phase #%d!',uniphx(p)));
      end
      
      % copy user parameters to the QWTB inputs
      di = inputs;
      
      % store time vector
      di.t.v = data.t;
      
      % store voltage and current vectors     
      di.u.v = data.y(:,u_id:data.averages_count:end);
      di.i.v = data.y(:,i_id:data.averages_count:end);
      
      % execute algorithm
      dout = qwtb(alg_id,di);
      
      % store current channel phase setup info (index; U, I tag)
      phase_info.index = data.corr.phase_idx(p);
      phase_info.tags = {u_name,i_name};
      phase_info.section = list{p};
      
      % store results to the result file
      qwtb_store_results(result_path, dout, alginfo, phase_info);
      
    end
    
    
  end
    
  if is_single_inp
    % single input algorithm
    
    % store list of channels to results file         
    rinf = infosetmatrixstr(rinf, 'list', channels);
    infosave(rinf, result_path);
    
    % --- for each available channel
    for p = 1:numel(channels)
    
      % copy user parameters to the QWTB inputs
      di = inputs;
      
      % store time vector
      di.Ts.v = data.Ts;
      
      % store voltage or current vector
      di.y.v = data.y(:,p:data.channels_count:end);
      
      % execute algorithm
      dout = qwtb(alg_id,di);
      
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
    algs = infogetmatrixstr(rinf, 'algorithms');
    
  catch
    % no algorithms yet
    algs = {};
    
  end
  
  % load lists of available results for each algorithm
  algs_hist = {};
  for a = 1:numel(algs)
    algs_hist{a,1} = infogetmatrixstr(rinf, algs{a});   
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
  rinf = infosetmatrixstr(rinf, 'algorithms', algs);
    
  % store lists of results for each algorithm
  for a = 1:numel(algs)
    rinf = infosetmatrixstr(rinf, algs{a}, algs_hist{a});    
  end
  
  % write updated results header back to the file 
  infosave(rinf, results_header, 1, 1);  
    
  
  
end