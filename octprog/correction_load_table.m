function [tbl] = correction_load_table(file,second_ax_name,quant_names)
% TWM: Loader of the correction CSV file.
%
% This will load single CSV file of 1D or 2D dependence into structure.
%
% [tbl] = correction_load_table(file, second_ax_name, quant_names)
% [tbl] = correction_load_table(file, second_ax_name, quant_names, i_mode)
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
%  i_mode      - interpolation mode (default: 'linear')
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
% per rows (linear mode by default).
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
% This is part of the TWM - TracePQM WattMeter (https://github.com/smaslan/TWM).
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
% 
  
  % by default assume no secondary axis
  if isempty(second_ax_name)
    second_ax_name = '';  
  end
  
  % identify interpolation mode:
  if ~exist('i_mode','var')
    i_mode = 'linear';
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
          vv(1:end,a) = num2cell(interp1(p,d,prim,i_mode));
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