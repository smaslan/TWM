function [vec,res] = qwtb_mcm_exec(fun,par,calcset)        
% QWTB wrapper function for single/multicore processing of Monte-Carlo.
% The function executes function 'fun' for each parameter in 'par'
% if 'par' is cell array or repeats it 'calcset.mcm.repeats' times if 
% 'par' is scalar (or struct).
% 'calcset' is QWTB calculation setup as receive to the alg. wrapper.
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
%   

    % repetitions count:
    if iscell(par)
        N = numel(par);
    else
        N = calcset.mcm.repeats;
    end
    
    if strcmpi(calcset.mcm.method,'singlecore')
        % use simple loop for single core:
        %   note: cellfun() would be more elegant solution but older Matlab 
        %         needs manual duplication of 'sig' for each iteration - 
        %         lot of wasted memory, maybe even too much for some machines...
        %         so rather using ordinary loop  
        if iscell(par)
            for k = 1:N
                res{k} = fun(par{k});                
            end
        else
            for k = 1:N
                res{k} = fun(par);
            end
        end
        
    else
        % multicore processing enabled:
        
        is_multicore = strcmpi(calcset.mcm.method,'multistation');
        is_parcellfun = strcmpi(calcset.mcm.method,'multicore');
        
        if ~isOctave && is_parcellfun
            % MATLAB and multicore - use parfor:                
            
            if iscell(par)
                parfor k = 1:N
                    res{k} = fun(par{k});
                end
            else
                parfor k = 1:N
                    res{k} = fun(par);
                end
            end
             
        elseif ~isOctave
            % MATLAB and unsuported mode:
            error(sprintf('Monte-Carlo calculation method ''%s'' not supported for Matlab (yet)!',calcset.mcm.method));
                            
        else
                        
            % -- setup multicore package:
            % multicore cores count
            mc_setup.cores = calcset.mcm.procno;
            % multicore method {'cellfun','parcellfun','multicore'}
            if is_multicore
                mc_setup.method = 'multicore';
            else
                mc_setup.method = 'parcellfun';
            end
            % multicore options: jobs grouping for 'parcellfun' 
            mc_setup.ChunksPerProc = 0;
            % multicore jobs directory:
            if strcmpi(calcset.mcm.tmpdir,'.') || isempty(calcset.mcm.tmpdir)
                % generate temporary folder if not defined:
                mc_setup.share_fld = tempname;
            else
                mc_setup.share_fld = calcset.mcm.tmpdir;
            end
            % multicore behaviour:
            mc_setup.min_chunk_size = 1;
            % paths required for the calculation:
            %  note: multicore slaves need to know where to find the algorithm functions 
            mc_setup.user_paths = {fileparts(mfilename('fullpath'))}; 
            if ispc
                % windoze - most likely small CPU:
                % use only small count of job files, coz windoze may get mad...    
                mc_setup.max_chunk_count = 200;
                % run only master if cores count set to 0 (assuming slave servers are already running on background)
                mc_setup.run_master_only = (calcset.mcm.procno == 0);
                % lest master work as well, it won't do any harm:
                mc_setup.master_is_worker = (calcset.mcm.procno <= 4); 
            else
                % Unix: possibly supercomputer - assume large CPU:
                % set large number of job files, coz Linux or supercomputer should be able to handle it well:    
                if isfield(calcset.mcm,'max_jobs')
                    mc_setup.max_chunk_count = calcset.mcm.max_jobs; % user limit
                else
                    mc_setup.max_chunk_count = 10000;
                end                
                % run only master if cores count set to 0 (assuming slave servers are already running on background)
                mc_setup.run_master_only = (calcset.mcm.procno == 0);
                % do not let master work, assuming there is fuckload of slave servers to do stuff:
                mc_setup.master_is_worker = (calcset.mcm.procno <= 4);
            end
            % user function to execute before running MC?
            if isfield(mc_setup,'user_fun')
                % yaha, some function referenced:
                if exist(mc_setup.user_fun,'file')
                    % it exist, assign it:            
                    mc_setup.run_after_slaves = mc_setup.user_fun;
                else
                    error('Monte Carlo option ''user_fun'' contains a link to non-existent function! Either fix the function name or do not assign ''mcm.user_fun''.');
                end
            end
                            
            % create jobs list:
            if ~iscell(par)
                par = repmat({par},[N 1]);
            end
            
            % -- processing start:
            res = runmulticore(mc_setup.method,fun,par,mc_setup.cores,mc_setup.share_fld,(~~calcset.verbose)*2,mc_setup);                            
        end                                    
    end
    
    % vectorize cell array of struct of elements:
    vec = vectorize_structs_elements(res);
            
end