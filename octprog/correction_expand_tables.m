function [tout,ax,ay] = correction_expand_tables(tin,reduce_axes)
% TWM: Expander of the correction tables loaded by 'correction_load_table'.
%
% This will take cell array of tables, looks for largest common range of 
% axes, then interpolates the tables data so all tables have the same axes.
% It uses linear interpolation and no extrapolation. NaNs will be inserted
% when range of new axis is outside range of source data.
% Note it will repeat the process for all data quantities in the table.
%
% Example: x_axis_1 = [1 2 3 5], x_axis_2 = [3 4 6] will result in new axis:
%          x_axis = [3 4 5]. The same for second axis.
% If the table is independent to one or both axes, the function lets
% them independent (will not create new axis).
%
% Parameters:
%  tin         - cell array of input tables
%  reduce_axes - reduces new axes to largest common range if set '1' (default)
%                if set to '0', it will merge the source axes to largest
%                needed range, but the data of some tables will contain NaNs!
%
% Returns:
%  tout - cell array of the modfied tables
%  ax   - new x axis (empty if not exist)
%  ay   - new y axis (empty if not exist) 
%
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2017, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
% 

  % by default reduce axes to largest common range
  if ~exist('reduce_axes','var')
    reduce_axes = 1;
  end
  
  % tables count
  T = numel(tin);
  
  % find unique x,y axis vlues for each table:
  ax = [];
  ay = [];
  ax_min = [];
  ax_max = [];
  ay_min = [];
  ay_max = [];
  for t = 1:T
    tab = tin{t};
    if tab.has_x
      xdata = getfield(tab,tab.axis_x);
      ax = union(ax,xdata);
      ax_min(end+1) = min(xdata);
      ax_max(end+1) = max(xdata);   
    end
    if tab.has_y
      ydata = getfield(tab,tab.axis_y);
      ay = union(ay,ydata);
      ay_min(end+1) = min(ydata);
      ay_max(end+1) = max(ydata); 
    end
  end
  % find largest common range of the axes:
  ax_min = max(ax_min);
  ax_max = min(ax_max);
  ay_min = max(ay_min);
  ay_max = min(ay_max);
  
  if reduce_axes
    % reduce output x,y axes ranges to largest common range:
    ax = ax(ax >= ax_min & ax <= ax_max);
    ay = ay(ay >= ay_min & ay <= ay_max);
  end
  
  % flip axes to right orientations:
  ax = ax(:).';
  ay = ay(:);
  
  % new axes have some items?
  has_x = ~~numel(ax);
  has_y = ~~numel(ay);
  
  % build meshgrid for 2D inetrpolation to the new axes:
  if has_x && has_y
    [axi,ayi] = meshgrid(ax,ay);
  end
  
  % --- now interpolate table data to new axes ---
  for t = 1:T
    % get one table:
    tab = tin{t};
    
    % get table's quantitites
    qnames = tab.quant_names;
    Q = numel(qnames);
    
    % load current axes
    if tab.has_x
      xdata = getfield(tab,tab.axis_x);
    end
    if tab.has_y
      ydata = getfield(tab,tab.axis_y);
    end
    
    % --- interpolate each quantity:
    for q = 1:Q
      if has_x && has_y && tab.has_x && tab.has_y
        % table has both axes, interpolate in 2D
        tab = setfield(tab,qnames{q},interp2(xdata,ydata,getfield(tab,qnames{q}),axi,ayi,'linear'));
      elseif has_y && tab.has_y
        % only primary axis (Y), interpolate 1D
        tab = setfield(tab,qnames{q},interp1(ydata,getfield(tab,qnames{q}),ay,'linear'));
      elseif has_x && tab.has_x
        % only secondary axis (X), interpolate 1D
        tab = setfield(tab,qnames{q},interp1(xdata,getfield(tab,qnames{q}),ax,'linear')); 
      end
    end
    
    % overwrite axes by new axes:
    if tab.has_x
      if numel(ax) > 1
        tab = setfield(tab,tab.axis_x,ax);
      else
        tab = setfield(tab,tab.axis_x,[]);
        tab.has_x = 0;
      end        
    end
    if tab.has_y
      if numel(ay) > 1
        tab = setfield(tab,tab.axis_y,ay);
      else
        tab = setfield(tab,tab.axis_y,[]);
        tab.has_y = 0;
      end        
    end
    
    % return modified table table:
    tout{t} = tab;
    
  end
  
  % delete axes with just one item:
  if numel(ax) < 2
    ax = [];
  end
  if numel(ay) < 2
    ay = [];
  end

end