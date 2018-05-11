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
                % windoze - most likely small CPU    
                mc_setup.max_chunk_count = 200;
                % if cores count set to 0, run only master, assuming slave servers are already running on background
                mc_setup.run_master_only = (calcset.mcm.procno == 0);
                mc_setup.master_is_worker = 1; 
            else
                % Unix: most likely cokl supercomputer - large CPU    
                mc_setup.max_chunk_count = 10000;
                mc_setup.run_master_only = 0;
                mc_setup.master_is_worker = 0;
                if exist(coklbind2,'file')
                    % ###todo: maybe removed - this is specific for CMI's supercomputer but should not do any harm...
                    mc_setup.run_after_slaves = @coklbind2;
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