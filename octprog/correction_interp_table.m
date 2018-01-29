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
        if isscalar(ay)
            if new_axis_dim == 2
                ay = repmat(ay,size(ax));
            else
                error('Correction table interpolator: Cannot expand axis ''ay'' because the ''new_axis_dim'' requests this axis as a new independnet axis of the table!');
            end
        elseif isscalar(ax)
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
    
    % flip axes to proper orientation:
    ax = ax(:).';
    ay = ay(:);
    
    % count of the quantities in the table:
    q_names = tbl.quant_names;
    Q = numel(tbl.quant_names);
    
    % load all quantities:
    quants = {};
    for q = 1:Q
        quants{end+1} = getfield(tbl,q_names{q});
    end
    
    
    % interpolate each quantity:    
    if ~isempty(ax) && tbl.size_x
        % interpolate by x-axis:        
        for q = 1:Q
            quants{q} = interp1nan(ox,quants{q}.',ax.').';
        end
    elseif ~isempty(ax) && ~tbl.size_x
        % interpolate by x-axis (source is independent on the x-axis - just replicate the quantities for each 'ax'):
        for q = 1:Q
            quants{q} = repmat(quants{q},[1 numel(ax)]);
        end                
    end
    if ~isempty(ay) && tbl.size_y
        % interpolate by y-axis:
        for q = 1:Q
            quants{q} = interp1nan(oy,quants{q},ay);
        end
    elseif ~isempty(ay) && ~tbl.size_y
        % interpolate by y-axis (source is independent on the y-axis - just replicate the quantities for each 'ay'):
        for q = 1:Q
            quants{q} = repmat(quants{q},[numel(ay) 1]);
        end
    end
    
    
    if ~in2d
        
        % get only just one item per item of 'ay'/'ax':
        % orient it according the user demand
        idx = (1:numel(ax)+1:numel(quants{1}));
        if new_axis_dim == 1
            for q = 1:Q
                tmp = quants{q}(idx);
                quants{q} = tmp(:);
            end
        else
            for q = 1:Q
                tmp = quants{q}(idx);
                quants{q} = tmp;
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
            %tbl = setfield(tbl, new_axis_name, ay);
        else
            % select 'ax' as the new axis:
            tbl.axis_x = new_axis_name;
            tbl.axis_y = '';
            tbl.has_x = 1;
            tbl.has_y = 0;
            %tbl = setfield(tbl, new_axis_name, ax);
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