%% -----------------------------------------------------------------------------
%% TracePQM: Store QWTB algorithm's results to a file. It stores small variables
%% to the INFO file directly. Large ones are store to complementary MAT file
%% and the INFO header will contains only name of the variable in the MAT file,
%% where the data is. 
%%
%%   inputs:
%%     result_path - full path of the result file with no extension
%%     result - result structure returned by the QWTB
%%     alg_info - algorithm info as returned by GWTB(alg_id, 'info')
%%     phase_info - structure with information about each phase/channel to save
%%                  phase_info.index - order index of the phase/channel
%%                  phase_info.tag - cell array of the names the channels
%%                                   related to the phase/channel {eg.: u1, i1}                                
%%                  phase_info.section - INFO file section name for each phase/
%%                                       channel {eg.: L1, L2, ... or u1, i1, ...}
%%     limits.max_array - maximum array elements count to be stored into INFO
%%                        bigger variables are stored to complemetary MAT file
%% -----------------------------------------------------------------------------
function [] = qwtb_store_results(result_path, result, alg_info, phase_info, limits)

  if ~exist('limits','var')
    % --- default setup of the exporter
    % maximum array elements to be stores to INFO
    limits.max_array = 200;
  end
  
  % complementary result MAT file path 
  result_mat = [result_path '.mat'];
  
  % try to load existing result 
  inf = infoload(result_path);
   
  % get value names in the QWTB result
  resvars = fieldnames(result);
  
   
  % store phase index
  res = infosetnumber('phase index', phase_info.index);
  
  % store channel tag (u1, i1, ...)
  res = infosettextmatrix(res, 'channel tag', phase_info.tags);
  
  % store list of variables
  res = infosettextmatrix(res, 'variable names', resvars);
  
  
  % TODO: filtering of the variables to save maybe????
  
  % if the MAT file already exists, we will just append the new var
  % ###note: this is because of Matlab, Octave's save('-append') works even with nonexistent file  
  if exist(result_mat,'file')
    app_mat = '-append';
  else
    app_mat = '';
  end 
  
  % --- for each variable
  vars = {};
  for p = 1:numel(resvars)
  
    % this variable name
    variable_name = resvars{p};
    
    % find variable in the algorihtm outputs list
    vid = qwtb_find_parameter(alg_info.outputs, variable_name);
    if ~vid
      error(sprintf('QWTB result saver: Variable ''%s'' not found in the algorithm output variables info??? Wtf? QWTB wrapper inconsistent.',variable_name));
    end
    varinf = alg_info.outputs(vid);
    
    % write variable info   
    ovar = infosettext('name', varinf.name);
    ovar = infosettext(ovar, 'description', varinf.desc);
    
    % get this variable
    variable = getfield(result, variable_name);
    
    % store variable size
    ovar = infosetmatrix(ovar, 'dimensions', size(variable.v));
    
    if numel(variable.v) > limits.max_array && ~ischar(variable.v)
      % the variable is some badass array - it is tooo big to store it in text file, it goes to MAT file insted
      
      % store value to the MAT
      if isnumeric(variable.v)

        % variable to store
        var_name = sprintf('%s_v_%s', varinf.name, phase_info.section);
      
        % store value variable name 
        ovar = infosettext(ovar, 'MAT file variable - value', var_name);
        
        % numeric - save
        eval(sprintf('%s = variable.v;', var_name));        
        save(result_mat, '-V4', app_mat, var_name);
        clear(var_name);
        
        % we have stored something, so next MAT save will be appending:
        app_mat = '-append';
        
      else
        % non numeric output???
        % TODO: decide what to do
        
      end
      
      
      % store uncertainty to the MAT
      if isfield(variable,'u')
        
        % variable to store
        var_name = sprintf('%s_u_%s', varinf.name, phase_info.section);
        
        % store uncertainty variable name
        ovar = infosettext(ovar, 'MAT file variable - uncertainty', var_name);
        
        % numeric - save
        eval(sprintf('%s = variable.u;', var_name));
        save(result_mat, '-V4', app_mat, var_name);
        clear(var_name);
        
        % we have stored something, so next MAT save will be appending:
        app_mat = '-append';
        
      end
      
      
    else
      % some small variable
      
      if isnumeric(variable.v)
        % numeric value, store numeric matrix
        ovar = infosetmatrix(ovar, 'value', variable.v);
        
      elseif ischar(variable.v)
        % character string:
        
        ovar = infosettext(ovar, 'value', variable.v);
              
      else
        % non numeric output???
        % TODO: decide what to do
        
        
        
      end
      
      if isfield(variable,'u')
        % uncertainty exists - assuming it is numeric
        ovar = infosetmatrix(ovar, 'uncertainty', variable.u);
              
      end
    
    end
    
    % generate variable's section:
    vars{end+1} = [infosetsection('', variable_name, ovar) sprintf('\n')];
  
  end
  
  % merge variable data and insert to the results file:
  res = [res sprintf('\n') vars{:}];
  
  % store variable to the result info
  inf = infosetsection(inf, phase_info.section, res);
  
  % save info file
  infosave(inf, result_path, 1, 1);

end