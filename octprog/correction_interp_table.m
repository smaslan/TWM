function [tbl] = correction_interp_table(tbl,ax,ay)
% TWM: Interpolator of the correction tables loaded by 'correction_load_table'.
% It will return interpolated value(s) from the correction table.
%
% Parameters:
%   tbl - input table
%   ax  - 1D vector of the new x-axis values (optional)
%   ay  - 1D vector of the new y-axis values (optional)
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
        % interpolate by x-axis (source is independent on the x-axis - just replicate the quantities for each 'ax'):
        for q = 1:Q
            quants{q} = repmat(quants{q},[numel(ay) 1]);
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