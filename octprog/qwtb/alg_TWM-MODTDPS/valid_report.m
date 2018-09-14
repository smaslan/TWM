function [] = valid_report(res,vr,pass_loc)

    fprintf('-----------------------------\n');
    fprintf(' Algorithm validation report \n');
    fprintf('-----------------------------\n\n');
    
    if ischar(res)
        % file mode - load result:
        res = load(res,'res','vr');
        vr = res.vr;
        res = res.res;
    end
    
    if ~exist('pass_loc','var')
        % default pass results level of confidence:
        pass_loc = 0.681;
    end
    
    % total test setups:
    tot = numel(res);
    
    % test setups per combination:
    R = tot/vr.var_n;
    
    % desired level of confidence:
    loc = res{1}.par.calcset.loc;
    
    % get expected count of runs per test setup:
    N = res{1}.par.val.max_count;
    if isfield(res{1}.par.val,'min_count')
        N = res{1}.par.val.min_count;
    end
    
    % very crude estimate of the pass condition:
    %   We have N repeated measurements, so the set is limited and we cannot state the test passed easily
    %   if pass rate "mean(abs(deviation(n)) < uncertainty(n),n=1..N)" is 95% (for level of confidence 0.95).
    %   The pass rate will be different for each N runs. So following crude calculation estimates
    %   the uncertainty of repeated sets of N measurements for gaussian distribution of algorithm uncertainties.
    %   Note this is very schmutzig solution, but I have no clue how to state the pass/fail better, as 
    %   for Monte Carlo the pass rate is (should be) exactly level-of-confidence. Without this 
    %   tweak, the pass probability of the group of N runs would be about 50%...
    %   This may (should) be improved!  
    pass_unc = std(mean(abs(randn(N,1000)) < loc2covg(loc,50),1))*loc2covg(pass_loc,50);
    pass_prob = loc - pass_unc; 
        
        
    fprintf('combinations = %d\n',vr.var_n);
    fprintf('tests per setup combination = %d\n',R);
    fprintf('tests runs per test setup = %d (desired)\n',N);
    fprintf('tests setup pass rate threshold = %.3f%% (i.e. %.3f%% of test runs must pass)\n',pass_prob,pass_prob);
    fprintf('pass rate uncertainty = <-%.3f;0>%% (i.e. level of confidence %.3f)\n\n',100*2*pass_unc/R^0.5,pass_loc);
    
    fprintf('Passed rate of all test setups [%%]:\n');
    fprintf('-----------------\n\n');
    
    % --- for each variation combination:
    va = 1;
    for v = 1:vr.var_n
    
        % get test setups for given combination:
        rc = res(va:va+R-1);        
        %rv = vectorize_structs_elements(rc);
        %pass = rv.pass; % original pass rate
                
        punc = [];
        punc_id = [];
        for k = 1:R
            if ~isempty(rc{k}.punc)
                punc(end+1,:) = mean(abs(rc{k}.punc) < 1,1);
                punc_id(end+1) = k; 
            end
        end                                  
                        
%         figure
%         plot(punc(:,4))
%         [v,id] = min(punc(:,4));
%         punc_id(id)
%         figure
%         plot(rc{punc_id(id)}.punc(:,4))

%         mcc = 1000;
%         trsh = loc + randn(1,size(punc,2),mcc)*pass_unc;
%         punc = mean(punc > trsh,1);       
%         hist(punc(1,4,:)(:),50)
%         [x,a,b] = scovint(punc(1,1,:)(:),0.95)     
%         punc = mean(punc,3)*100;
        

        
        % mean %-of-unc value [%]:
        cunc = mean(punc,1)*100;
        
        % %-of-unc value [%]:          
        punc = mean(punc > pass_prob,1)*100;             
        
        % print combination setup:
        head = {'','',''};
        P = sum(vr.par_n>1);
        for p = 1:P
            head{p} = sprintf('%s = %d',vr.names{p},getfield(rc{1}.par.simcom,vr.names{p}));    
        end
        head_len = max(cellfun(@length,head));
        head_fmt = sprintf('%%-%ds',head_len);
        
        % print results:
        qu_names = sprintf('%-6s ',rc{1}.name_list{:});
        qu_puncs = sprintf('%6.2f ',punc);
        qu_cuncs = sprintf('%6.2f ',cunc);
        fprintf(['  ' head_fmt ' | %s| TOT\n  ' head_fmt ' | %s| %6.2f\n  ' head_fmt ' | %s| %6.2f <= average pass rates\n'],head{1},qu_names,head{2},qu_puncs,min(punc),head{2},qu_cuncs,min(cunc));
        for p = P+1:numel(head)
            fprintf(['  ' head_fmt '\n'],head{p});
        end
        fprintf('\n');
        
        
           
        % next combination test setups:
        va = va + R;
    end  
        


end