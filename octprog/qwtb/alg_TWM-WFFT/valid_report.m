function [] = valid_report(res,vr,pass_loc,do_plot)

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
    
    if ~exist('do_plot','var')
        do_plot = 0;
    end
    
    % total test setups:
    tot = numel(res);
    
    % test setups per combination:
    R = tot/vr.var_n;
    
    % desired level of confidence:
    loc = res{1}.par.calcset.loc;
        
    % get expected count of runs per test setup:
    N = res{1}.par.val.max_count;
%     if isfield(res{1}.par.val,'min_count')
%         N = res{1}.par.val.min_count;
%     end
    
    % very crude estimate of the pass condition:
    %   We have N repeated measurements, so the set is limited and we cannot state the test passed easily
    %   if pass rate "mean(abs(deviation(n)) < uncertainty(n),n=1..N)" is 95% (for level of confidence 0.95).
    %   The pass rate will be different for each N runs. So following crude calculation estimates
    %   the uncertainty of repeated sets of N measurements for gaussian distribution of algorithm uncertainties.
    %   Note this is very schmutzig solution, but I have no clue how to state the pass/fail better, as 
    %   for Monte Carlo the pass rate is (should be) exactly level-of-confidence. Without this 
    %   tweak, the pass probability of the group of N runs would be about 50%...
    %   This may (should) be improved!  
    pass_unc = std(mean(abs(randn(N,1000)) < loc2covg(loc,50),1)')*loc2covg(pass_loc,50)
    pass_prob = loc - pass_unc;
    
        
    fprintf('combinations = %d\n',vr.var_n);
    fprintf('tests per setup combination = %d\n',R);
    fprintf('tests runs per test setup = %d (desired)\n',N);
    fprintf('tests setup pass rate threshold = %.3f%% (i.e. %.3f%% of test runs must pass)\n',pass_prob,pass_prob);
    fprintf('pass rate uncertainty = <-%.3f;0>%% (i.e. level of confidence %.3f)\n\n',100*2*pass_unc/R^0.5,pass_loc);
    
    fprintf('Passed rate of all test setups [%%]:\n');
    fprintf('-----------------------------------\n\n');
    
    % --- for each variation combination:
    va = 1;
    for v = 1:vr.var_n
    
        % get test setups for given combination:
        rc = res(va:va+R-1);        
        %rv = vectorize_structs_elements(rc);
        %pass = rv.pass; % original pass rate
        
        % parameters count:
        P = size(rc{1}.punc,2);
                
        punc = zeros(R,P);
        h_list = [];
        for k = 1:R
            punc(k,:) = mean(abs(rc{k}.punc) < 1,1);
            %h_list(end+1:end+size(rc{k}.punc,1),:) = rc{k}.punc;
        end
        
        p_id = 1;
        pass = zeros(R,P);
        for k = 1:R
            pass(k,:) = mean(abs(rc{k}.punc) < 1,1);
        end        
        
        % get worst runs per parameters:
        [v,min_ids] = min(pass,[],1);                
        
        if do_plot
        
            figure
            for p = 1:P
                subplot(1,P,p);
                plot(pass(:,p));
                title(rc{1}.name_list{p});
            end
            
            figure
            for p = 1:P
                subplot(1,P,p);
                plot(rc{min_ids(p)}.punc(:,p))
                title(sprintf('%s[%d]',rc{1}.name_list{p},min_ids(p) + (va-1)));
            end
            
        end        
        

%         figure
%         hist(h_list(:,4),50,1);
%         %semilogy(xx,nn);
%         xlabel('\Delta{}P [-]');
%         ylabel('p [-]');
          
        
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
        fprintf(['  ' head_fmt ' | %s| TOT\n  ' head_fmt ' | %s| %6.2f\n  ' head_fmt ' | %s| %6.2f <= average pass rates\n'],head{1},qu_names,head{2},qu_puncs,min(punc),head{3},qu_cuncs,min(cunc));
        for p = 4:numel(head)
            fprintf(['  ' head_fmt '\n'],head{p});
        end
        fprintf('\n');
        
        disp(' - worst test runs for each parameter:');
        disp(min_ids(:)' + (va-1));
        fprintf('\n\n');
        
        
           
        % next combination test setups:
        va = va + R;
    end  
        


end