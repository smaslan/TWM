function [outp] = var_get_all_fast(par,vr,step,verbose)
% Generate all parameters combinations. This function will take the structure
% 'par', and will replicate is for each combination of each value of each
% vector parameter, while leaving the scalar parameters constant.
%
% Example:
%   par.f0 = 1000;
%   par.fs = [10000 20000];
%   par.A0 = [1 2 3];
%
%   [vr, pp] = var_init(par);
%   cc = var_get_all_fast(ppp, vr, 5000, 1)
%
%   cc{1}.f0  = 1000
%   cc{1}.fs  = 10000
%   cc{1}.A0  = 1
%
%   cc{2}.f0  = 1000
%   cc{2}.fs  = 20000
%   cc{2}.A0  = 1
%
%   cc{3}.f0  = 1000
%   cc{3}.fs  = 10000
%   cc{3}.A0  = 2
%
%   cc{4}.f0  = 1000
%   cc{4}.fs  = 20000
%   cc{4}.A0  = 2
%
%   cc{5}.f0  = 1000
%   cc{5}.fs  = 10000
%   cc{5}.A0  = 3
%
%   cc{6}.f0  = 1000
%   cc{6}.fs  = 20000
%   cc{6}.A0  = 3
%
% It will work for any count of vector variables. Note string parameters are not
% variated.
% Parameter 'step' is number of combination create at one iteration. This is just
% for showing progress for really large combination sets. 'verbose' enables
% progress status display.
%
% See also 'var_init()' function help.
% 
%
% License:
% --------
% This is part of VAR library for automatic multidim. variation of simulation parameters.
% (c) 2018, Stanislav Maslan, s.maslan@seznam.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT   


    if verbose
        fprintf('Generating parameter combinations ... \r');
    end
    
    % total combinations:
    N = prod(vr.par_n);
        
    % create prototype:
    p_prot = par;
    
    c_prot = {}; 
    % replace all vector parameters by default scalars:
    for v = 1:numel(vr.names)                
        if vr.par_n(v) > 1
            p_prot = setfield(p_prot,vr.names{v},0); 
        end
        c_prot{v,1} = getfield(p_prot,vr.names{v});
    end
    
    vidid = find(strcmpi(vr.names,'pvpid'));
    
    % vector variables count:
    vn = sum(vr.par_n > 1);
    
    % vector variables ids:
    vids = [1:numel(vr.par_n)];
    vids = vids(vr.par_n > 1);

    % load vectors:
    vars = {};        
    for v = 1:vn
    
        % get variable vector:
        v_val = getfield(par,vr.names{vids(v)});
        
        % reshape the vector to v-dim:
        dimn = eye(vn);
        dimn = [dimn(v,:)*(numel(v_val)-1) + 1];
        if vn == 1
            dimn = [dimn 1];
        end
        vars{v} = reshape(v_val,dimn);
    
    end
    
    % create combinations matrix (combination,variable):
    vc_lists = [];
    for v = 1:vn    
        v_prod = 1;
        for d = 1:vn
            if d == v
                v_part = vars{d};                
            else
                v_part = ones(size(vars{d}));
            end
            v_prod = bsxfun(@times,v_part,v_prod);
        end        
        vc_lists(:,v) = v_prod(:);
    end
    
    
    % initialize vector of parameters:
    c_list = repmat({c_prot},[1 N]);
    
    % store variable combinations:
    tot = 0;
    while tot < N             
        todo = min(N - tot,step);
        for k = (tot+1):(tot+todo)
            for v = 1:vn
                c_prot{vids(v)} = vc_lists(k,v);
                
            end
            c_prot{vidid} = k;
            c_list{k} = c_prot;
        end
        tot = tot + todo;
        if verbose
            fprintf('Generating parameter combinations ... %3.0f%%  \r',100*tot/N);
        end   
    end
  
    if verbose
        fprintf('\n');
    end
    
    % make cell array of parameter structs:
    if isOctave
        outp = cellfun(@cell2struct,c_list,{vr.names},{1});        
    else
        outp = cellfun(@cell2struct,c_list,repmat({vr.names},size(c_list)),repmat({1},size(c_list)));
    end
    
    % convert to cells
    outp = num2cell(outp);

end