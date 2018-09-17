function [] = valid_report(res,vr)

    fprintf('-----------------------------\n');
    fprintf(' Algorithm validation report \n');
    fprintf('-----------------------------\n\n');
    
    if ischar(res)
        % file mode - load result:
        res = load(res,'res','vr');
        vr = res.vr;
        res = res.res;
    end
    
    % total test setups:
    tot = numel(res);
    
    % test setups per combination:
    R = tot/vr.var_n;
    
    fprintf('combinations = %d\n',vr.var_n);
    fprintf('tests per setup combination = %d\n\n',R);
    
    fprintf('Passed tests [%%]:\n');
    fprintf('-----------------\n\n');
    
    % --- for each variation combination:
    va = 1;
    for v = 1:vr.var_n
    
        % get test setups for given combination:
        rc = res(va:va+R-1);        
        rv = vectorize_structs_elements(rc);
        
        % print combination setup:
        head = {'',''};
        P = sum(vr.par_n>1);
        for p = 1:P
            head{p} = sprintf('%s = %d',vr.names{p},getfield(rc{1}.par.simcom,vr.names{p}));    
        end
        head_len = max(cellfun(@length,head));
        head_fmt = sprintf('%%-%ds',head_len);
                
        pp = [];
        com = [];
        for r = 1:R
            pp(r) = mean(abs(rc{r}.punc(:,1)) < 1);
            
            com(end+1:end+size(rc{r}.punc,1),:) = rc{r}.punc(:,:);
        end
        [v,id] = min(pp)        
        figure
        plot(pp)
        
        figure
        axnm = {'\Delta{}thd/u(thd) [-]', '\Delta{}A(1)/u(A(1)) [-]', '\Delta{}A(2..H)/u(A(2..H)) [-]'};
        for k = 1:3
            subplot(1,3,k);
            hist(com(:,k),50,1);
            xlabel(axnm{k});
            ylabel('p [-]');
            %set(gca, 'yscale', 'log')
        end

        
%         fid = find(rv.pass == 0);
%         fid        
%         plot(rc{fid(1)}.punc)
%         size()
        
                
        % %-of-unc value [%]:          
        punc = mean(rv.pass,1)*100;        
        
        % print results:
        qu_names = sprintf('%-6s ',rc{1}.name_list{:});
        qu_puncs = sprintf('%6.2f ',punc);
        fprintf(['  ' head_fmt ' | %s| TOT\n  ' head_fmt ' | %s| %6.2f\n'],head{1},qu_names,head{2},qu_puncs,min(punc));
        for p = P+1:numel(head)
            fprintf(['  ' head_fmt '\n'],head{p});
        end
        fprintf('\n');
        
        
           
        % next combination test setups:
        va = va + R;
    end  
        


end