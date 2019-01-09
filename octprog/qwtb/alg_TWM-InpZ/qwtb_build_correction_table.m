function [tab] = qwtb_build_correction_table(din,names,name_ax,default,default_unc,default_ax,var_names,var_axes)
% TWM: This will take the input quantities from QWTB and creates a correction table from them.
% The TWM itself operates with the single tables structures at the loading stage from the correction files.
% Before the table can be sent via the QWTB toolbox, it must be decomposed to simple vectors/matrices,
% and then in the alg_wrapper.m it can be restored to the original state by this function.
%
% License:
% --------
% This is part of the TWM - Traceable PQ Wattmeter
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
            if isfield(data,'u') && all(size(data.v) == size(data.u))
                default_unc{k} = data.u;
            else
                default_unc{k} = [];
            end            
        end
        default_ax = {};
        for k = 1:(has_x+1)
            ct = getfield(din,name_ax{k});
            default_ax{k} = ct.v;
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
        if numel(default_unc) >= k && all(size(default{k}) == size(default_unc{k}))
            q_data{end+1} = default_unc{k};
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






% ###NOTE: COPY OF STANDALONE correction_load_table() JUST TO HAVE IT IN A SINGLE FILE ### 
function [tbl] = correction_load_table(file,second_ax_name,quant_names)
% TWM: Loader of the correction CSV file.
%
% This will load single CSV file of 1D or 2D dependence into structure.
%
% Parameters:
%  file - full file path to the CSV file
%       - may be replaced by cell array {quant. 1, quant. 2, ...},
%         that will fake the CSV table with the values defined in the cells
%         both axis of dependence will be empty. 
%  second_ax_name - if secondary CSV is 2D dependence, this is name of
%                   of the variable to which the secondary axis values
%                   will be placed.
%  quant_names - names of the quantities in the CSV file
%              - first one is always independent quantity (primary axis),
%                following strings are names of the dependent quantities
%
% Returns:
%  tbl.name - CSV file comment
%  tbl.'quant_names{1}' - primary axis values
%  tbl.'second_ax_name' - secondary axis values (optional)
%  tbl.'quant_names{2}' - quantity 1 data
%  ...
%  tbl.'quant_names{N+1}' - quantity N data
%  tbl.quant_names - names of the data quantities
%  tbl.axis_x - name of the secondary axis quantity
%  tbl.axis_y - name of the primary axis quantity
%  tbl.has_x - secondary axis exist (even if it is empty)
%  tbl.has_y - primary axis exist (even if it is empty)
%  tbl.size_x - secondary axis size (0 when quantities independent on X)
%  tbl.size_y - primary axis size (0 when quantities independent on Y)
%
%
% Notes:
% Missing quantity values in the middle of the data will be interpolated
% per rows (linear).
% Missing (empty) cells on the starting and ending rows will be replaced
% by NaN.
%
% CSV format example (2D dependence):
% My CSV title ;         ;         ;            ;
%              ; Rs(Ohm) ; Rs(Ohm) ; u(Rs)(Ohm) ; u(Rs)(Ohm)
% f(Hz)\U(V)   ; 0.1     ; 1.0     ; 0.1        ; 1.0
% 0            ; 6.001   ; 6.002   ; 0.1        ; 0.1
% 1000         ; 6.010   ; 6.012   ; 0.2        ; 0.2
% 10000        ; 6.100   ; 6.102   ; 0.5        ; 0.5
%
% CSV format example (2D dependence, but independent on U axis):
% My CSV title ;         ;           
%              ; Rs(Ohm) ; u(Rs)(Ohm)
% f(Hz)\U(V)   ;         ;        
% 0            ; 6.001   ; 0.1       
% 1000         ; 6.010   ; 0.2       
% 10000        ; 6.100   ; 0.5       
%
% CSV format example (2D dependence, but independent on f axis):
% My CSV title ;         ;         ;            ;
%              ; Rs(Ohm) ; Rs(Ohm) ; u(Rs)(Ohm) ; u(Rs)(Ohm)
% f(Hz)\U(V)   ; 0.1     ; 1.0     ; 0.1        ; 1.0
%              ; 6.001   ; 6.002   ; 0.1        ; 0.1
%
% CSV format example (2D dependence, but independent on any axis):
% My CSV title ;         ;           
%              ; Rs(Ohm) ; u(Rs)(Ohm)
% f(Hz)\U(V)   ;         ;        
%              ; 6.001   ; 0.1       
%
% CSV format example (1D dependence):
% My CSV title ;         ;         ;            ;
% f(Hz)        ; Rs(Ohm) ; Rs(Ohm) ; u(Rs)(Ohm) ; u(Rs)(Ohm)
% 0            ; 6.001   ; 6.002   ; 0.1        ; 0.1
% 1000         ; 6.010   ; 6.012   ; 0.2        ; 0.2
% 10000        ; 6.100   ; 6.102   ; 0.5        ; 0.5
%
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
% 
  
  % by default assume no secondary axis
  if ~exist('second_ax_name','var')
    second_ax_name = '';  
  end
  
  if iscell(file)
    % default table
    
    % which axes are there?
    has_primary = ~isempty(quant_names{1});
    has_second = ~isempty(second_ax_name);

    % data quantities count
    quant_N = numel(quant_names) - 1;
    
    if numel(file) ~= quant_N + has_primary + has_second
      error('Correction table loader: Number of data quantities does not match number of fake values to assign! Note the primary axis quantity is used even for faking table, so valid example is: quant_names = {''f'',''Rs'',''Xs''}, file = {[], 0, 0}.');
    end
    
    % fake table content
    tbl.name = 'fake table';
    
    fpos = 1;
    
    % store primary axis
    if has_primary
      tbl = setfield(tbl,quant_names{1},file{fpos});
      fpos = fpos + 1;
    end
    % store secondary axis
    if has_second
      tbl = setfield(tbl,second_ax_name,file{fpos});
      fpos = fpos + 1;
    end
    % store quantities 
    for k = 1:quant_N
      tbl = setfield(tbl,quant_names{k+1},file{fpos});
      fpos = fpos + 1;
    end       
    
  else
  
    % try to load the table
    csv = csv2cell(file,';');
    [M,N] = size(csv);
    
    % get rid of empty rows/columns
    for m = M:-1:1
      if ~all(cellfun(@isempty,csv(m,:)))
        M = m;
        break;
      end
    end  
    for n = N:-1:1
      if ~all(cellfun(@isempty,csv(:,n)))
        N = n;
        break;
      end
    end
    
    % check consistency of the table data and desired quantities count
    Q = numel(quant_names);
    if Q < 2
      error('Correction table loader: not enough dependence quantities!');
    end  
    if rem(N - 1,Q - 1)
      error('Correction table loader: quantities count does not match size of the loaded table!');
    end
    
    % number of columns per quantity
    A = round((N - 1)/(Q - 1));  
    if isempty(second_ax_name) && A > 1
      error('Correction table loader: no secondary axis desired but correction data contain more than 1 column per quantity!');
    end
      
    
    % read name of the table
    tbl.name = csv{1,1};
    
    % initial row of correction data
    d_row = 3;
    if ~isempty(second_ax_name)
      d_row = d_row + 1;
    end
  
    
    % load primary axis values
    numz = cellfun(@isnumeric,csv(d_row:end,1)) & ~cellfun(@isempty,csv(d_row:end,1));
    if any(numz) && ~all(numz)
      error('Correction table loader: primary axis contains invalid cells!');
    end
    if numel(numz) == 1 && any(numz)
      error('Correction table loader: primary axis contains invalid cells! There is just one row so there should not be primary axis value, just empty cell!');
    elseif any(numz)
      tbl = setfield(tbl,quant_names{1},cell2mat(csv(d_row:end,1)));
    else
      tbl = setfield(tbl,quant_names{1},[]);    
    end
    prim = getfield(tbl,quant_names{1});
    
    % load secondary axis values
    if ~isempty(second_ax_name)
      numz = cellfun(@isnumeric,csv(d_row-1,2:1+A)) & ~cellfun(@isempty,csv(d_row-1,2:1+A));
      if any(numz) && ~all(numz) 
        error('Correction table loader: secondary axis contains invalid cells!');
      end
      if ~any(numz) && A > 1
        error('Correction table loader: secondary axis contains invalid cells! There are multiple columns per quantity but not all have assigned secondary axis values.');
      elseif any(numz) && A == 1
        error('Correction table loader: secondary axis contains invalid cells! There is just on secondary axis item but it has nonzero value. It should be empty.');
      elseif ~any(numz) || A == 1
        tbl = setfield(tbl,second_ax_name,[]);
      else  
        tbl = setfield(tbl,second_ax_name,cell2mat(csv(d_row-1,2:1+A)));
      end
    end
    
    % --- for each quantity in the table
    for q = 1:Q-1
      
      % load csv portion with correction data
      vv = csv(d_row:end,2+(q-1)*A:1+q*A);
      R = size(vv,1);
      
      % detect invalids
      nanz = cellfun(@isempty,vv) | ~cellfun(@isnumeric,vv);
      
      for a = 1:A
        
        % get id of valid rows
        vid = find(~nanz(:,a));
        if ~numel(vid)
          error('Correction table loader: no valid number in whole column???');  
        end
        
        % build primary axis
        if isempty(prim)
          p = [];
        else
          p = prim(vid);
        end
        % build column
        d = [vv{vid,a}].';
  
        if numel(p) > 1
          % interpolate data to fill in gaps and replace ends by NaNs     
          vv(1:end,a) = num2cell(interp1(p,d,prim,'linear'));
        else
          % just one row, cannot interpolate
          tmp = vv(1:end,a);
          vv(1:end,a) = NaN;
          vv(vid,a) = tmp(vid);
                 
        end
        
      end
      
      
      % convert and store quantity to loaded table
      tbl = setfield(tbl,quant_names{1+q},cell2mat(vv));
          
    end
    
  end
  
  % store axes names
  tbl.axis_x = second_ax_name;
  tbl.has_x = ~isempty(tbl.axis_x);  
  if tbl.has_x
    tbl.size_x = numel(getfield(tbl,second_ax_name));
  else
    tbl.size_x = 0; 
  end  
  tbl.axis_y = quant_names{1};
  tbl.has_y = ~isempty(tbl.axis_y);
  if tbl.has_y    
    tbl.size_y = numel(getfield(tbl,tbl.axis_y));
  else
    tbl.size_y = 0;
  end
  
  % store quantities names
  tbl.quant_names = quant_names(2:end);

end