function [tab] = qwtb_build_correction_table(din,names,name_ax,default,default_unc,default_ax,var_names,var_axes)
% TWM: This will take the input quantities from QWTB and creates a correction table from them.
% The TWM itself operates with the single tables structures at the loading stage from the correction files.
% Before the table can be sent via the QWTB toolbox, it must be decomposed to simple vectors/matrices,
% and then in the alg_wrapper.m it can be restored to the original state by this function.
%
% License:
% --------
% This is part of the TWM - Traceable PQ Wattemter
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.
%

    has_x = numel(name_ax) > 1;
    
    V = numel(names);
    
    % list of involved 'din' quantities:
    vars = [isfieldvec(din,names) isfield(din,name_ax{1})];
    if has_x
        vars(end+1) = isfield(din,name_ax{2});
    end
    
    % if inputs quantities do not exist, use defaults:
    use_defaults = all(~vars);
    
    if use_defaults && nargin < 6
        error(sprintf('QWTB/TWM correction table builder error: Input quantities related to ''%s'' do not exist but there is also no default value to load instead!',names{1}));
    end
    
    if nargin < 8
        % user defined table variable names not defined - use originals from 'din':
        var_names = names;
        var_axes = name_ax;
    end
    
    if any(vars) && ~all(vars)
        error(sprintf('QWTB/TWM correction table builder error: Some of the input quantities related to ''%s''.',names{1}));
    end
    
    if ~use_defaults
        % override defaults by actual input data from 'din':        
        default = {};
        default_unc = {};        
        for k = 1:V 
            data = getfield(din,names{k});
            default{k} = data.v;
            if isfield(data,'u') && ~isempty(data.u)
                default_unc{k} = data.u;
            else
                default_unc{k} = [];
            end            
        end
        default_ax = {};
        for k = 1:(has_x+1)
            default_ax{k} = getfield(din,name_ax{k}).v;
        end             
    end    
        
    % create primary axis:
    q_data = {default_ax{1}};
    q_names = {var_axes{1}}; 
    
    % create secondary axis:        
    if has_x
        sec_ax = var_axes{2};
        q_data{end+1} = default_ax{2};
    else
        sec_ax = '';
    end
    
    % create data:
    for k = 1:V
        q_data{end+1} = default{k};
        q_names{end+1} = var_names{k};
        % uncertainty:
        if numel(default_unc) >= k && ~isempty(default_unc)
            q_data{end+1} = default_unc{1};
            q_names{end+1} = ['u_' var_names{k}];
        end
    end
    
    % build the correction table
    tab = correction_load_table(q_data,sec_ax,q_names);

end

function [res] = isfieldvec(str,items)
    % note: cannot use cellfun(@isfield,str,items) because of Matlab < 2016b!
    %       it fails at 'str' not having the same size as 'items'...
    res = [];
    for k = 1:numel(items)
        res(k) = isfield(str,items{k}); 
    end
end