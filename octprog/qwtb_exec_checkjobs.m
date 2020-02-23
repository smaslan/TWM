function [jobs_list,done] = qwtb_exec_checkjobs(jobs_list)
% This is check function that is checks if startmulticoreslave() already returned result.
% The result files to check are stored in 'jobs_list'   
% 
% Parameters:
%   jobs_list - list of jobs in progress to check
%
% Returns:
%   jobs_list - list of jobs in progress after check
%   done - count of done jobs 
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2020, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
%  
    
    % no results loaded
    done = 0;
                   
    if isempty(jobs_list)
        % getout of no results
        return;
    end
    
    % clear output jobs list
    jobs_list_out = {};
    
    % search for all job files
    for k = 1:numel(jobs_list)
    
        % get one job file name
        job_file = jobs_list{k};
        
        % make result file path
        job_file = strrep(job_file,'parameters_','result_');
        
        if exist(job_file,'file')
            % result file seems to exist
            
            % try to get results structure 
            res = load(job_file,'result');
            res = res.result{1};            
            if ~isempty(res.error)
                error(sprintf('QWTB Algorithm Executer: failed with error:\n%s',res.error));
            end            
            % no error
            
            % return index of job just identified as done
            done = done + 1;
            
        else
            % result not calculated - keep in the todo list
            jobs_list_out{end+1,1} = job_file;
        end
        
    end
    
    % return not done jobs
    jobs_list = jobs_list_out;
        
end

