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
                
        % %-of-unc value [%]:          
        punc = mean(rv.pass,1)*100;
        
%         Q = numel(rc{1}.name_list);
%         for k = 1:numel(rc)
%             for q = 1:Q
%                 [t,neg,pos] = scovint(rc{k}.punc(:,q),0.95);
%                 pass(k,q) = (neg >= -1) && (pos <= 1);
%             end            
%         end
%         punc = mean(pass,1)*100;        
    
%         Q = numel(rc{1}.name_list);
%         for k = 1:numel(rc)
%             pp(k,:) = mean(rc{k}.punc,1);                        
%         end
%         plot(pp(:,1:4))
%         [v,id]=max(pp(:,4))

        %find(~rv.pass(:,4))
        
        figure;
        hist([[[rc{:}].punc](:,4:10:end)](:),50,1);
        xlabel('%-of-uncertainty');
        ylabel('probability [-]');
        
        
        
        

        
        
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