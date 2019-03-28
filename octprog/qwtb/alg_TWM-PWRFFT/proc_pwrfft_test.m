function [res] = proc_pwrtdi_test(par)
% TWM-PWRFFT validation - execution of test runs for given test setup.

    % test runs execution setup:
    mc_setup = par.mc_setup_runs;
    
    % create test run jobs:
    jobs = repmat({par},[par.val.max_count,1]);
    
    % execute the jobs:
    runres = runmulticore(mc_setup.method, @proc_pwrfft_test_run, jobs, mc_setup.cores, mc_setup.share_fld, 2, mc_setup);
       
    % merge the results:
    punc = [];
    for k = 1:par.val.max_count
        punc_t = runres{k}.punc;
        if ~isempty(punc_t)
            punc(end+1,:) = punc_t;
        end
    end       
    
    if ~size(punc,1)
        % empty list - failed all times!
        punc = zeros(1,10);
        pass = zeros(1,10);
                
    elseif size(punc,1) == 1
        % one test only - all deviations ok? 
        pass = abs(punc) < 1.0;
        
    else
        % more tests - calculate probability:        
        pass_prob = mean(abs(punc) < 1.0,1);
        
        % pass?
        pass = pass_prob > par.calcset.loc;
        
        if isfield(par.val,'dbg_print') && par.val.dbg_print
            fprintf(' --- runs = %.0f, pass rate = %.1f%%, mean %%-of-unc = %.0f%%, pass = %.0f\n', size(punc,1), min(pass_prob(1:5))*100, max(mean(punc(:,1:5),1))*100, all(pass(1:5)));
        end
                 
    end
    
    % --- store results:
    % test setup:
    res.par = par;
    % pass flags:
    res.pass = single(pass);
    % %-of-unc histogram:
    res.punc = single(punc);
    % store name list:
    res.name_list = runres{1}.name_list;      
    
end