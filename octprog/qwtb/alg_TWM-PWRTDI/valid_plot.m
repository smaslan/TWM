function [] = valid_report(res,vr,pass_loc)

    fprintf('---------------------------\n');
    fprintf(' Algorithm validation plot \n');
    fprintf('---------------------------\n\n');
    
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
    
    
    
    % --- for each variation combination:
    va = 1;
    for v = 1:vr.var_n
    
        % get test setups for given combination:
        rc = res(va:va+R-1);
        
        f0 = zeros(R,1);
        S = zeros(R,1);
        fs = zeros(R,1);
        punc = [];
        for r = 1:R
            f0(r) = rc{r}.par.cfg.chn{1}.fx(1);
            S(r)  = rc{r}.par.cfg.N;
            fs(r) = rc{r}.par.din.fs.v;            
            punc(r,:) = mean(abs(rc{r}.punc) < 1,1);    
        end
                
        l_f0_per = S./fs.*f0;
        l_fs_rat = fs./f0;
        
        Q = 10;
        ax_f0_per = linspace(log10(min(l_f0_per)),log10(max(l_f0_per)),Q);      
        ax_fs_rat = linspace(log10(min(l_fs_rat)),log10(max(l_fs_rat)),Q);
        
        cut = zeros([numel(ax_f0_per) numel(ax_fs_rat) R])*NaN;
        zbuf = zeros([numel(ax_f0_per) numel(ax_fs_rat)]);                
        for r = 1:R
                        
            pass = min(mean(punc(r,[1:5]) > pass_prob));
            
            y = interp1(ax_f0_per, [1:Q]', log10(l_f0_per(r)), 'nearest');
            x = interp1(ax_fs_rat, [1:Q]', log10(l_fs_rat(r)), 'nearest');
            
            zbuf(y,x) = zbuf(y,x) + 1;
            cut(y,x,zbuf(y,x)) = pass;
                                
        end
        
        cut = nanmean(cut,3);
        cut(isnan(cut)) = 0;
        
        contourf(10.^(ax_f0_per),10.^(ax_fs_rat),cut)
        set(gca,'xscale','log')
        set(gca,'yscale','log')
        
        %return
                   
        % next combination test setups:
        va = va + R;
    end  
        


end