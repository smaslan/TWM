function [tbl] = correction_interp_table(tbl,ax,ay,new_axis_name,new_axis_dim)
% TWM: Interpolator of the correction tables loaded by 'correction_load_table'.
% It will return interpolated value(s) from the correction table either in 2D
% mode or 1D mode.
% 
% Usage:
%   tbl = correction_interp_table(tbl, ax, [])
%   tbl = correction_interp_table(tbl, [], ay)
%   tbl = correction_interp_table(tbl, ax, ay)
%   tbl = correction_interp_table(tbl, ax, ay, new_axis_name, new_axis_dim)
%
%   tbl = correction_interp_table()
%     - run self-test/validation
%
% Parameters:
%   tbl           - Input table
%   ax            - 1D vector of the new x-axis values (optional)
%   ay            - 1D vector of the new y-axis values (optional)
%   new_axis_name - If non-empty, the interpolation will be in 1D (optional)
%                   in this case the 'ax' and 'ay' must have the same size
%                   or one may be vector and one scalar, the scalar one will
%                   be replicated to size of the other. The function will 
%                   return 1 item per item of 'ax'/'ay'/
%                   It will also create a new 1D table with the one axis name
%                   'new_axis_name'.
%   new_axis_dim  - In the 1D mode this defines which axis 'ax' or 'ay' will be
%                   used for the new axis 'new_axis_name'.  
%
% note: leave 'ax' or 'ay' empty [] to not interpolate in that axis.
% note: if the 'ax' or 'ay' is not empty and the table have not x or y
% axis it will return an error.  
%
% Returns:
%   tbl - table with interpolated quantities
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
% 

    if ~nargin
        % initiate self-test/validation:
        tbl = correction_interp_table_test();
        return
    end
    
    % default parameters:
    if ~exist('ax','var')
        ax = [];
    end
    if ~exist('ay','var')
        ay = [];
    end

    % desired axes to interpolate:
    has_ax = ~isempty(ax);
    has_ay = ~isempty(ay);
    
    if has_ax && ~isvector(ax)
        error('Correction table interpolator: Axis X is not a vector!');
    end
    if has_ay && ~isvector(ay)
        error('Correction table interpolator: Axis Y is not a vector!');
    end
    
    % is it 2D interpolation?
    in2d = ~exist('new_axis_name','var');
    
    % input checking for the 2D mode
    if ~in2d
        
        if ~has_ax || ~has_ay 
            error('Correction table interpolator: 2D interpolation requsted, but some of the new axes is empty?');
        end
        
        if numel(ax) > 1 && numel(ay) > 1 && numel(ax) ~= numel(ay)
            error('Correction table interpolator: Both axes must have the same items count or one must be scalar!');
        end
        
        % expand axes:
        if isscalar(ay) && ~isvector(ax)
            if new_axis_dim == 2
                ay = repmat(ay,size(ax));
            else
                error('Correction table interpolator: Cannot expand axis ''ay'' because the ''new_axis_dim'' requests this axis as a new independnet axis of the table!');
            end
        elseif isscalar(ax) && ~isvector(ay)
            if new_axis_dim == 1
                ax = repmat(ax,size(ay));
            else
                error('Correction table interpolator: Cannot expand axis ''ax'' because the ''new_axis_dim'' requests this axis as a new independnet axis of the table!');
            end            
        end
        
    end
    
    
    % check compatibility with data:
    if has_ax && ~tbl.has_x
        error('Correction table interpolator: Interpolation by nonexistent axis X required!');
    end
    if has_ay && ~tbl.has_y
        error('Correction table interpolator: Interpolation by nonexistent axis Y required!');    
    end
    
    % original independent axes data:
    if tbl.has_x
        ox = getfield(tbl,tbl.axis_x);
    else
        ox = [];
    end
    if tbl.has_y
        oy = getfield(tbl,tbl.axis_y);
    else
        oy = [];
    end
        
    % if interpolation axis data 'ax' and/or 'ay' are not defined, return all table's elements in that axis/axes: 
    if isempty(ax)
        ax = ox;
    end
    if isempty(ay)
        ay = oy;
    end
    
    % count of the quantities in the table:
    q_names = tbl.quant_names;
    Q = numel(tbl.quant_names);
    
    % load all quantities:
    quants = {};
    for q = 1:Q
        quants{end+1} = getfield(tbl,q_names{q});
    end

    
    % flip axes to proper orientation:
    ax = ax(:).';
    ay = ay(:);
    
    if ~in2d
        % --- mode 1: one value per item of 'ax'/'ay':
        
    
        % interpolate each quantity:
        if tbl.size_x && tbl.size_y
            for q = 1:Q
                quants{q} = interp2nan(ox,oy,quants{q},ax.',ay);
            end
        elseif tbl.size_x
            for q = 1:Q
                quants{q} = interp1nan(ox,quants{q},ax);
            end
        elseif tbl.size_y
            for q = 1:Q
                quants{q} = interp1nan(oy,quants{q},ay);
            end
        else
            if new_axis_dim == 1
                for q = 1:Q
                    quants{q} = repmat(quants{q},size(ay));
                end
            else
                for q = 1:Q
                    quants{q} = repmat(quants{q},size(ax));
                end
            end            
        end
        
        % set correct orientation:
        if new_axis_dim == 1
            for q = 1:Q
                quants{q} = quants{q}(:);
            end
        else
            for q = 1:Q
                quants{q} = quants{q}(:).';
            end    
        end
        
        % --- modify the axes, because not it became just 1D table dependent on unknown new axis:
        
        % remove original axes of the table:
        tbl = rmfield(tbl,{tbl.axis_x, tbl.axis_y});

        % create new axis:
        if new_axis_dim == 1
            % select 'ay' as the new axis:
            tbl.axis_x = '';
            tbl.axis_y = new_axis_name;
            tbl.has_x = 0;
            tbl.has_y = 1;
        else
            % select 'ax' as the new axis:
            tbl.axis_x = new_axis_name;
            tbl.axis_y = '';
            tbl.has_x = 1;
            tbl.has_y = 0;
        end        
    
    else
        % --- mode 2: regular 2D interpolation:
        
        if ~isempty(ax) && ~isempty(ay)
            if tbl.size_x && tbl.size_y
                for q = 1:Q
                    quants{q} = interp2nan(ox,oy,quants{q},ax,ay);
                end
            elseif tbl.size_x
                for q = 1:Q
                    quants{q} = repmat(interp1nan(ox,quants{q},ax),size(ay));
                end
            elseif tbl.size_y
                for q = 1:Q
                    quants{q} = repmat(interp1nan(oy,quants{q},ay),size(ax));
                end
            else
                for q = 1:Q
                    quants{q} = repmat(quants{q},[numel(ay) numel(ax)]);
                end
            end        
        elseif ~isempty(ax)
            if tbl.size_x
                for q = 1:Q
                    quants{q} = interp1nan(ox,quants{q},ax);
                end
            else
                for q = 1:Q
                    quants{q} = repmat(quants{q},size(ax));
                end
            end        
        elseif ~isempty(ay)
            if tbl.size_y
                for q = 1:Q
                    quants{q} = interp1nan(oy,quants{q},ay);
                end
            else
                for q = 1:Q
                    quants{q} = repmat(quants{q},size(ay));
                end
            end        
        end 
    end  
    
    % store back the interpolated quantities:
    for q = 1:Q
        tbl = setfield(tbl,q_names{q},quants{q});
    end
        
    % set interpolated table's flags@stuff:
    szx = size(quants{1},2)*(~~numel(quants{1}));
    szy = size(quants{1},1)*(~~numel(quants{1}));    
    tbl.size_x = (szx > 1)*szx;
    tbl.size_y = (szy > 1)*szy;
    if ~tbl.has_x && tbl.size_x 
        tbl.axis_x = 'ax';    
    end
    if ~tbl.has_y && tbl.size_y 
        tbl.axis_y = 'ay';    
    end    
    tbl.has_x = tbl.has_x | szx > 1;
    tbl.has_y = tbl.has_y | szy > 1;
    
    % store new x and y axis data:
    if szx < 2
        ax = [];
    end
    if szy < 2
        ay = [];
    end
    if tbl.has_x 
        tbl = setfield(tbl,tbl.axis_x,ax);
    end
    if tbl.has_y
        tbl = setfield(tbl,tbl.axis_y,ay);
    end


end





% ====== SELF-TEST SECTION ======

%!test correction_interp_table()
function [res] = correction_interp_table_test()

    % high tolerance needed because of NaN tolerant interps - they cause some additional error:
    ep = 100*eps;
    
    tab.name = 'test';
    tab.a = [1 2 3];
    tab.f = [1;2;3];
    tab.qu1 = [1 2 3;4 5 6;7 8 9];    
    tab.quant_names = {'qu1'};
    tab.axis_x = 'a';
    tab.axis_y = 'f';
    tab.has_x = ~isempty(tab.axis_x);
    tab.has_y = ~isempty(tab.axis_y);
    tab.size_x = size(tab.a,2)*tab.has_x;
    tab.size_y = size(tab.f,1)*tab.has_y;
    
    tin = correction_interp_table(tab,[1 2],[2 3],'g',1);        
    if ~isfield(tin,'g') || ~strcmpi(tin.axis_y,'g') || any(abs(tin.g - [2;3]) > ep) || any(abs(tin.qu1 - [4;8]) > ep) || tin.has_x || ~tin.has_y
        error('Correction table validation failed at: ''correction_interp_table(tab,[1 2],[2 3],''g'',1)''!');    
    end
    
    tin = correction_interp_table(tab,[1 2],[2 3],'g',2);
    if ~isfield(tin,'g') || ~strcmpi(tin.axis_x,'g') || any(abs(tin.g - [1 2]) > ep) || any(abs(tin.qu1 - [4 8]) > ep) || ~tin.has_x || tin.has_y
        error('Correction table validation failed at: ''correction_interp_table(tab,[1 2],[1 2],''g'',1)''!');    
    end
    
    tin = correction_interp_table(tab,[1 2],[2 3]);
    if any(abs(tin.qu1 - [4 5;7 8]) > ep) || tin.size_x ~= 2 || tin.size_y ~= 2
        error('Correction table validation failed at: ''correction_interp_table(tab,[1 2],[2 3])''!');    
    end
    
    tin = correction_interp_table(tab,[1 2],[]);
    if any(abs(tin.qu1 - [1 2;4 5;7 8]) > ep) || tin.size_x ~= 2 || tin.size_y ~= 3
        error('Correction table validation failed at: ''correction_interp_table(tab,[1 2])''!');    
    end
    
    tin = correction_interp_table(tab,[],[2 3]);
    if any(abs(tin.qu1 - [4 5 6;7 8 9]) > ep) || tin.size_x ~= 3 || tin.size_y ~= 2
        error('Correction table validation failed at: ''correction_interp_table(tab,[],[2 3])''!');    
    end
    
    
    
    tab.name = 'test';
    tab.a = [];
    tab.f = [1;2;3];
    tab.qu1 = [1;2;3];    
    tab.quant_names = {'qu1'};
    tab.axis_x = 'a';
    tab.axis_y = 'f';
    tab.has_x = ~isempty(tab.axis_x);
    tab.has_y = ~isempty(tab.axis_y);
    tab.size_x = size(tab.a,2)*tab.has_x;
    tab.size_y = size(tab.f,1)*tab.has_y;
    
    tin = correction_interp_table(tab,[1 2],[2 3],'g',1);
    if ~isfield(tin,'g') || ~strcmpi(tin.axis_y,'g') || any(abs(tin.g - [2;3]) > ep) || any(abs(tin.qu1 - [2;3]) > ep) || tin.has_x || ~tin.has_y
        error('Correction table validation failed at: ''correction_interp_table(tab,[1 2],[2 3],''g'',1)''!');    
    end
    
    tin = correction_interp_table(tab,[1 2],[2 3],'g',2);
    if ~isfield(tin,'g') || ~strcmpi(tin.axis_x,'g') || any(abs(tin.g - [1 2]) > ep) || any(abs(tin.qu1 - [2 3]) > ep) || ~tin.has_x || tin.has_y
        error('Correction table validation failed at: ''correction_interp_table(tab,[1 2],[1 2],''g'',1)''!');    
    end
    
    tin = correction_interp_table(tab,[1 2],[2 3]);
    if any(abs(tin.qu1 - [2 2;3 3]) > ep) || tin.size_x ~= 2 || tin.size_y ~= 2
        error('Correction table validation failed at: ''correction_interp_table(tab,[1 2],[2 3])''!');    
    end
    
    tin = correction_interp_table(tab,[],[2 3]);
    if any(abs(tin.qu1 - [2;3]) > ep) || tin.size_x ~= 0 || tin.size_y ~= 2
        error('Correction table validation failed at: ''correction_interp_table(tab,[],[2 3])''!');    
    end
    
    tin = correction_interp_table(tab,[1 2],[]);
    if any(abs(tin.qu1 - [1 1;2 2;3 3]) > ep) || tin.size_x ~= 2 || tin.size_y ~= 3
        error('Correction table validation failed at: ''correction_interp_table(tab,[1 2],[])''!');    
    end
    
    tin = correction_interp_table(tab,[],[]);
    if any(abs(tin.qu1 - [1;2;3]) > ep) || tin.size_x ~= 0 || tin.size_y ~= 3
        error('Correction table validation failed at: ''correction_interp_table(tab,[],[])''!');    
    end
    
    
    
    tab.name = 'test';
    tab.a = [];
    tab.f = [1;2;3];
    tab.qu1 = [1;2;3];    
    tab.quant_names = {'qu1'};
    tab.axis_x = '';
    tab.axis_y = 'f';
    tab.has_x = ~isempty(tab.axis_x);
    tab.has_y = ~isempty(tab.axis_y);
    tab.size_x = size(tab.a,2)*tab.has_x;
    tab.size_y = size(tab.f,1)*tab.has_y;
        
    tin = correction_interp_table(tab,[],[2 3]);
    if any(abs(tin.qu1 - [2;3]) > ep) || tin.size_x ~= 0 || tin.size_y ~= 2
        error('Correction table validation failed at: ''correction_interp_table(tab,[],[2 3])''!');    
    end
        
    tin = correction_interp_table(tab,[],[]);
    if any(abs(tin.qu1 - [1;2;3]) > ep) || tin.size_x ~= 0 || tin.size_y ~= 3
        error('Correction table validation failed at: ''correction_interp_table(tab,[],[])''!');    
    end
    
    
    
    tab.name = 'test';
    tab.a = [1 2 3];
    tab.f = [];
    tab.qu1 = [1 2 3];    
    tab.quant_names = {'qu1'};
    tab.axis_x = 'a';
    tab.axis_y = 'f';
    tab.has_x = ~isempty(tab.axis_x);
    tab.has_y = ~isempty(tab.axis_y);
    tab.size_x = size(tab.a,2)*tab.has_x;
    tab.size_y = size(tab.f,1)*tab.has_y;
    
    tin = correction_interp_table(tab,[1 2],[2 3],'g',1);
    if ~isfield(tin,'g') || ~strcmpi(tin.axis_y,'g') || any(abs(tin.g - [2;3]) > ep) || any(abs(tin.qu1 - [1;2]) > ep) || tin.has_x || ~tin.has_y
        error('Correction table validation failed at: ''correction_interp_table(tab,[1 2],[2 3],''g'',1)''!');    
    end
    
    tin = correction_interp_table(tab,[1 2],[2 3],'g',2);
    if ~isfield(tin,'g') || ~strcmpi(tin.axis_x,'g') || any(abs(tin.g - [1 2]) > ep) || any(abs(tin.qu1 - [1 2]) > ep) || ~tin.has_x || tin.has_y
        error('Correction table validation failed at: ''correction_interp_table(tab,[1 2],[1 2],''g'',1)''!');    
    end
    
    tin = correction_interp_table(tab,[1 2],[2 3]);
    if any(abs(tin.qu1 - [1 2;1 2]) > ep) || tin.size_x ~= 2 || tin.size_y ~= 2
        error('Correction table validation failed at: ''correction_interp_table(tab,[1 2],[2 3])''!');    
    end
    
    tin = correction_interp_table(tab,[],[2 3]);
    if any(abs(tin.qu1 - [1 2 3;1 2 3]) > ep) || tin.size_x ~= 3 || tin.size_y ~= 2
        error('Correction table validation failed at: ''correction_interp_table(tab,[],[2 3])''!');    
    end
    
    tin = correction_interp_table(tab,[1 2],[]);
    if any(abs(tin.qu1 - [1 2]) > ep) || tin.size_x ~= 2 || tin.size_y ~= 0
        error('Correction table validation failed at: ''correction_interp_table(tab,[1 2],[])''!');    
    end
    
    tin = correction_interp_table(tab,[],[]);
    if any(abs(tin.qu1 - [1 2 3]) > ep) || tin.size_x ~= 3 || tin.size_y ~= 0
        error('Correction table validation failed at: ''correction_interp_table(tab,[],[])''!');    
    end
    
    
    tab.name = 'test';
    tab.a = [1 2 3];
    tab.f = [];
    tab.qu1 = [1 2 3];    
    tab.quant_names = {'qu1'};
    tab.axis_x = 'a';
    tab.axis_y = '';
    tab.has_x = ~isempty(tab.axis_x);
    tab.has_y = ~isempty(tab.axis_y);
    tab.size_x = size(tab.a,2)*tab.has_x;
    tab.size_y = size(tab.f,1)*tab.has_y;
        
    tin = correction_interp_table(tab,[1 2],[]);
    if any(abs(tin.qu1 - [1 2]) > ep) || tin.size_x ~= 2 || tin.size_y ~= 0
        error('Correction table validation failed at: ''correction_interp_table(tab,[1 2],[])''!');    
    end
            
    tin = correction_interp_table(tab,[],[]);
    if any(abs(tin.qu1 - [1 2 3]) > ep) || tin.size_x ~= 3 || tin.size_y ~= 0
        error('Correction table validation failed at: ''correction_interp_table(tab,[],[])''!');    
    end
    
    
    
    
    tab.name = 'test';
    tab.a = [];
    tab.f = [];
    tab.qu1 = [2];    
    tab.quant_names = {'qu1'};
    tab.axis_x = 'a';
    tab.axis_y = 'f';
    tab.has_x = ~isempty(tab.axis_x);
    tab.has_y = ~isempty(tab.axis_y);
    tab.size_x = size(tab.a,2)*tab.has_x;
    tab.size_y = size(tab.f,1)*tab.has_y;
    
    tin = correction_interp_table(tab,[1 2],[2 3],'g',1);        
    if ~isfield(tin,'g') || ~strcmpi(tin.axis_y,'g') || any(abs(tin.g - [2;3]) > ep) || any(abs(tin.qu1 - [2;2]) > ep) || tin.has_x || ~tin.has_y
        error('Correction table validation failed at: ''correction_interp_table(tab,[1 2],[2 3],''g'',1)''!');    
    end
    
    tin = correction_interp_table(tab,[1 2],[2 3],'g',2);
    if ~isfield(tin,'g') || ~strcmpi(tin.axis_x,'g') || any(abs(tin.g - [1 2]) > ep) || any(abs(tin.qu1 - [2 2]) > ep) || ~tin.has_x || tin.has_y
        error('Correction table validation failed at: ''correction_interp_table(tab,[1 2],[1 2],''g'',1)''!');    
    end
    
    tin = correction_interp_table(tab,[1 2],[2 3]);
    if any(abs(tin.qu1 - [2 2;2 2]) > ep) || tin.size_x ~= 2 || tin.size_y ~= 2
        error('Correction table validation failed at: ''correction_interp_table(tab,[1 2],[2 3])''!');    
    end
    
    tin = correction_interp_table(tab,[1 2],[]);
    if any(abs(tin.qu1 - [2 2]) > ep) || tin.size_x ~= 2 || tin.size_y ~= 0
        error('Correction table validation failed at: ''correction_interp_table(tab,[1 2])''!');    
    end
    
    tin = correction_interp_table(tab,[],[2 3]);
    if any(abs(tin.qu1 - [2;2]) > ep) || tin.size_x ~= 0 || tin.size_y ~= 2
        error('Correction table validation failed at: ''correction_interp_table(tab,[],[2 3])''!');    
    end
    
    
    
    
    
    tab.name = 'test';
    tab.a = [];
    tab.f = [];
    tab.qu1 = [2];    
    tab.quant_names = {'qu1'};
    tab.axis_x = '';
    tab.axis_y = '';
    tab.has_x = ~isempty(tab.axis_x);
    tab.has_y = ~isempty(tab.axis_y);
    tab.size_x = size(tab.a,2)*tab.has_x;
    tab.size_y = size(tab.f,1)*tab.has_y;
        
    tin = correction_interp_table(tab,[],[]);
    if any(abs(tin.qu1 - [2]) > ep) || tin.size_x ~= 0 || tin.size_y ~= 0
        error('Correction table validation failed at: ''correction_interp_table(tab,[],[])''!');    
    end       
    
    res = 1;
    
end



% ====== SUB-FUNCTIONS SECTION ======

