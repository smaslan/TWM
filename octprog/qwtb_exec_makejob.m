function [result_path] = qwtb_exec_makejob(meas_file, calc_unc, is_last_avg, avg_id, group_id, verbose, cfg)
% This is equivalent to qwtb_exec_algorithm() which will create job file compatible with 
% Multicore package. The job file(s) are then processed by slave processes running startmulticoreslave().
% 
% Parameters are identical to qwtb_exec_algorithm(). Only additional parameter is parallel config:
%  cfg.parallel_cfg.mc_tmpdir - jobs sharing folder
%  cfg.parallel_cfg.time - time struct with elements: year, month, day, hour, minute, second
%                          this time stamp should be unique for jobs batch
%
% Returns:
%  result_path - absolute path to file that will receive parallel processing result
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2020, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
%  

    if ~isfield(cfg,'parallel_cfg')
        error('QWTB Algorithm Executer: Missing parallel exection setup! Cannot make processing job file.');
    end
    
    % default group id
    if ~exist('group_id','var')
        group_id = -1;
    end
    
    % default verbose:
    if ~exist('verbose','var')
        verbose = 1;
    end
    
    % default uncertainty override mode
    if ~exist(calc_unc)
        calc_unc = '';        
    end
    
    % ensure default processing configuration:
    if ~isfield(cfg,'mc_method')
        cfg.mc_method = 'singlecore';
    end
    if ~isfield(cfg,'mc_procno')
        cfg.mc_procno = 1;
    end
    if ~isfield(cfg,'mc_tmpdir')
        cfg.mc_tmpdir = '';
    end 
    
    
    % override monte carlo mode by single thread as we obviously cannot run parallel processing and parallel monte carlo
    cfg.mc_method = 'singlecore';
    
    % make a job file record
    job.meas_file = meas_file;
    job.calc_unc = calc_unc;
    job.is_last_avg = is_last_avg;
    job.avg_id = avg_id;
    job.group_id = group_id;
    job.verbose = verbose;
    job.cfg = cfg;
    
    % parallel config
    par = cfg.parallel_cfg;
           
    % job sharing folder
    multicoreDir = par.mc_tmpdir;
    % make jobs folder if not exist
    if ~exist(multicoreDir,'file')
        mkdir(multicoreDir);
    end
       
    
    % for compatibility with multicore (do not change)
    CellExpansion = 1;
    
    % make list of necessary search paths
    userPaths{1} = fileparts(mfilename('fullpath'));
    userPaths{2} = fullfile(userPaths{1}, 'info');
    userPaths{3} = fullfile(userPaths{1}, 'qwtb'); %###todo: this should come used defined path    
    
    % generate job batch file name:
    dateStr = sprintf('%04d%02d%02d%02d%02d%02d', round([par.time.year par.time.month par.time.month  par.time.hour par.time.minute par.time.second]));
    parameterFileName     = fullfile(multicoreDir, sprintf('parameters_%s_%04d.mat', dateStr, avg_id));
    parameterFileName_tmp = fullfile(multicoreDir, sprintf('parameters_%s_%04d.tmp', dateStr, avg_id));  

    % rebuild function handles for the batch:
    functionHandleCell = @qwtb_exec_cell;
    [functionHandles,functionHandlesStr] = mc_getFunctionHandles(functionHandleCell, 1); %#ok
    % get jobs list:
    parameters = {job}; %#ok
    
    % save temp job batch file:
    save('-binary',parameterFileName_tmp,'parameters','functionHandlesStr','functionHandles','userPaths','CellExpansion'); %% file access %%
    
    % activate job file (rename to final name - should be atomic operation):
    [err,msg] = rename(parameterFileName_tmp,parameterFileName);    
    if err
        % failed - possibly there was old file?
        unlink(parameterFileName_tmp);
        error(sprintf('QWTB Algorithm Executer: Creating job file ''%s'' failed!',parameterFileName));
    end
    
    % return path with the result
    result_path = parameterFileName;
        
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%		Stanislav Mašláň
%		Last modified 27.11.2015
function [fHandles,fStr] = mc_getFunctionHandles(functionHandleCell, index)  
  
  if isa(functionHandleCell, 'function_handle')
    % return function handle as it is
    fHandles = functionHandleCell;
    fStr = func2str(fHandles);
  elseif iscell(functionHandleCell) 
    if all(size(functionHandleCell) == [1 1])
      % return function handle
      fHandles = functionHandleCell{1};
      fStr = func2str(fHandles);
    else
      if numel(index) == 1
        % return function handle
        fHandles = functionHandleCell{index};
        fStr = func2str(fHandles);       
      else
        % return function handle cell
        fHandles = functionHandleCell(index);
        fStr = cell(size(index));
        for k = 1:numel(index)
          fStr{k} = func2str(fHandles{k}); 
        endfor
      end
    end
  else
    error('Input type unknown.');
  end
  
endfunction % function