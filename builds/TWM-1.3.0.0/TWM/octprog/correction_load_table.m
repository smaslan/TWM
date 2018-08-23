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
  
    persistent is_octave;  % speeds up repeated calls  
    if isempty(is_octave)
        is_octave = (exist ('OCTAVE_VERSION', 'builtin') > 0);
    end
  
    % try to load the table
    
    if is_octave
        csv = csv2cell(file,';'); % Octave version
    else 
        csv = csv2cell_matlab(fileread(file)); % Matlab version        
        % parse numerics to numbers:
        numz = str2double(csv);        
        emp = cellfun(@isempty,csv);
        numz(emp) = NaN;        
        csv(~isnan(numz)) = num2cell(numz(~isnan(numz)));
    end
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
        is_missing = size(nanz,1) ~= numel(vid);
        
        % build primary axis
        if isempty(prim)
          p = [];
        else
          p = prim(vid);
        end
        % build column
        d = [vv{vid,a}].';
  
        if numel(p) > 1 && is_missing
          % interpolate data to fill in gaps and replace ends by NaNs     
          vv(1:end,a) = num2cell(interp1(p,d,prim,i_mode));
        elseif ~is_missing
          vv(1:end,a) = num2cell(d);            
        else
          % just one row, cannot interpolate
          tmp = vv(1:end,a);
          vv(1:end,a) = num2cell(repmat(NaN,[1:size(vv,1) 1]));
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



function data = csv2cell_matlab(s) %<<<1
    % Reads string with csv sheet according RFC4180 (with minor modifications, see last three
    % properties) and returns cell of strings.
    %
    % Properties:
    % - quoted fields are properly parsed,
    % - escaped quotes in quoted fields are properly parsed,
    % - newline characters are correctly understood in quoted fields,
    % - spaces in quotes are preserved,
    % - works for CR, LF, CRLF, LFCR newline markers,
    % - if field is not quoted, leading and trailing spaces are intentionally removed,
    % - sheet delimiter is ';',
    % - if not same number of fields on every row, sheet is padded by empty strings as needed.
    
    % Script first tries to find out if quotes are used. If not, fast method is used. If yes, slower
    % method is used.
    
    CELLSEP = ';';          % separator of fields
    CELLSTR = '"';          % quoted fields character
    LF = char(10);          % line feed
    CR = char(13);          % carriage return
    
    if ~any(find(s > char(32)))
        % empty matrix (just white-spaces)
        data = {};
    
    elseif isempty(strfind(s, CELLSTR)) %<<<2
    % no quotes, simple method will be used
    
        % methods converts all end of lines to LF, split by LF,
        % and two methods to parse lines
                
        % replace all CRLF to LF:
        s = strrep(s, [CR LF], LF);
        % replace all LFCR to LF:
        s = strrep(s, [LF CR], LF);
        % replace all CR to LF:
        s = strrep(s, CR, LF);
        % split by LF:
        s = strsplit(s, LF);
        % remove trailing empty lines which can happen in the case of last LF
        % (this would prevent using fast cellfun method)
        if length(s) > 1 && isempty(strtrim(s{end}))
                s = s(1:end-1);
        end
        % strsplit by separators on all lines:
        s = cellfun(@strsplit, s, repmat({CELLSEP}, size(s)), 'UniformOutput', false);
        try %<<<3
                % faster method - use vertcat, only possible if all lines have the same number of fields:
                data = vertcat(s{:});
        catch %<<<3
                % slower method - build sheet line by line.
                % if number of fields on some line is larger or smaller, padding by empty string
                % occur:
                data = {};
                for i = 1:length(s)
                        c = s{i};
                        if i > 1
                                if size(c,2) < size(data,2)
                                        % new line is too short, must be padded:
                                        c = [c repmat({''}, 1, size(data,2) - size(c,2))];
                                elseif size(c,2) > size(data,2)
                                        % new line is too long, whole matrix must be padded:
                                        data = [data, repmat({''}, size(c,2) - size(data,2), 1)];
                                end
                        end
                        % add new line of sheet:
                        data = [data; c];
                end
        end
        
        % ###note: was added to get rid of start/end whites
        data = strtrim(data);
        
    else %<<<2
        % quotes are inside of sheet, very slow method will be used
        % this method parse character by character

        Field = '';             % content of currently processed field
        FieldEnd = false;       % flag if field ended by ; or some newline
        LineEnd = false;        % flag if line ended
        inQuoteField = false;   % flag if now processing inside of quoted field
        wasQuotedField = false; % flag if current field is quoted
        curChar = '';           % currently processed character
        nextChar = '';          % character next after currently processed one
        curCol = 1;             % current collumn
        curRow = 1;             % current row
        i = 0;                  % loop index
        while i < length(s)
            i = i + 1;
            % get current character:
            curChar = s(i);
            % get next character
            if i < length(s)
                nextChar = s(i+1);
            else
                % if at end of string, just add line feed, no harm to do this:
                nextChar = LF;
                % and mark all ends:
                FieldEnd = true;
                LineEnd = true;
            end
            if inQuoteField %<<<3
                    % we are inside quotes of field
                    if curChar == CELLSTR
                        if nextChar == CELLSTR
                            % found escaped quotes ("")
                            i = i + 1;      % increment counter to skip next character, which is already part of escaped "
                            Field = [Field CELLSTR];
                        else
                            % going out of quotes
                            inQuoteField = false;
                            Field = [Field curChar];
                        end
                    else
                        Field = [Field curChar];
                    end
            else %<<<3
                % we are not inside quotes of field
                if curChar == CELLSTR
                    inQuoteField = true;
                    wasQuotedField = true;
                    Field = [Field curChar];
                    % endif
                elseif curChar == CELLSEP
                    % found end of field
                    FieldEnd = true;
                elseif curChar == CR
                    % found end of line (this also ends field)
                    FieldEnd = true;
                    LineEnd = true;
                    if nextChar == LF
                            i = i + 1;      % increment counter to skip next character, which is already part of CRLF newline
                    end
                elseif curChar == LF
                    % found end of line (this also ends field)
                    FieldEnd = true;
                    LineEnd = true;
                    if nextChar == CR
                            i = i + 1;      % increment counter to skip next character, which is already part of LFCR newline
                    end
                else
                    Field = [Field curChar];
                end
            end
            if FieldEnd == true %<<<3
                % add field to sheet:
                Field = strtrim(Field);
                if wasQuotedField
                    wasQuotedField = false;
                    % remove quotes if it is first and last character (spaces are already removed)
                    % if it is not so, the field is bad (not according RFC), something like:
                    % aaa; bb"bbb"bb; ccc
                    % and whole non modified field will be returned
                    if (strcmp(Field(1), '"') && strcmp(Field(end), '"'))
                            Field = Field(2:end-1);
                    end
                end
                data(curCol, curRow) = {Field};
                Field = '';
                FieldEnd = false;
                if LineEnd == true;
                    curRow = curRow + 1;
                    curCol = 1;
                    LineEnd = false;
                else
                    curCol = curCol + 1;
                end
            end
        end
        data = data';
    end

end

function [sarr] = strsplit(str,delim)
% This is simplified SARR = STRFIND(STR, DELIM) function for old Matlab where it is not
% Splits string STR into cell array SARR of strings. DELIM is separator string.
%
    
    if ~exist('delim','var')
        error('Delimiter not defined!');
    end
    
    if ~exist('str','var')
        error('String to split not defined!');
    end

    % size of dleimiter
    len = numel(delim);
    
    % search all occurencies of delimiter
    ids = strfind(str,delim);

    % multiple segments
    sarr = {};
    pstr = 1;
    for k = 1:numel(ids)
        sarr{end+1} = char(str(pstr:ids(k)-1));
        pstr = ids(k) + len;
    end
    %if pstr < numel(str) + 1
        sarr{end+1} = char(str(pstr:end));
    %end

end