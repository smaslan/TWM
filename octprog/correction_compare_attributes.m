function [ret, higher] = correction_compare_attributes(a, b, prec, ceps)
% Compares two variables in following way:
%  a: scalar numeric or string
%  b: 1D cell array or numeric or strings
%  prec: allowed relative deviation of the comparison
%  ceps: allowed absolute deviation of the comparison (prec has prefference) 
%
%  It returns index of the matching item of 'b' if 'a' is equal to at least one cell of the 'b'.
%  Otherwise it returns 0.
%
%  if the all the values in the 'a' and 'b' are convertable to numeric
%  the function assumes they are numbers and will perform comparison
%  to the defined level of precision
%
%  The 'higher' value is true if the 'a' is higher than all 'b'.
%

  if nargin < 4
    % use default numeric precison
    ceps = 1e-8;    
  end
  
  if nargin < 3
    % use default numeric precison
    prec = 0.001;    
  end

  higher = 0;
  
  if isnumeric(a) || numel(str2num(a))
    % 'a' is already numeric or can be numeric, can the 'b' be also numeric?
    
    % 'b' is already entire numeric?
    b_is_num = all(cellfun(@isnumeric,b));
    
    if ~b_is_num
      % try to convert 'b' to numeric
      try
        b = cellfun(@str2num,b,'UniformOutput',true);
        b_is_num = 1;
      catch
        % nope! - something was not convertable        
      end
    else
      b = cell2mat(b);
    end
        
    if b_is_num
      % yaha - so both are numerics
      if ~b_is_num
        b = b_num;
      end
      
      % convert 'a' to numeric if not done yet 
      if ~isnumeric(a)
        a = str2num(a);
      end
      
      % is there a match within the allowed precision?
      ret = find(abs((a - b)/a) < prec | abs(a - b) < ceps,1);
      
      % if yaha, then check if: a > b?
      if numel(ret)
        higher = a > b(ret);
      else
        higher = all(a > b);
      end 
    
    else
      % 'b' is not numeric and cannot be numeric

      if ischar(a) && all(cellfun(@ischar,b))
        % 'a' and 'b' strings - compare strings
        
        % match found?
        ret = find(strcmpi(a,b),1);        
      else
        % damn, 'a' and 'b' of different types??? - return no match
        ret = 0;        
      end
         
    end
  else
    % 'a' is obviously not numeric and cannot be numeric  
  
    if ischar(a) && all(cellfun(@ischar,b))
      % kej, 'a' and 'b' are all strings, compare strings
      ret = find(strcmpi(a,b),1);

    else
      % ehm ... 'a' and 'b' are not the same types??? - return no match
      ret = 0;
    end
    
  end 
  
  % not match? return 0
  if ~numel(ret)
    ret = 0;
  end

end
