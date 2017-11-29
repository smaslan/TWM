%% -----------------------------------------------------------------------------
%% TracePQM: Parser of the digitizer correction data.
%%
%% Note: INVALID - OLD VERSION, WILL BE FIXED
%% -----------------------------------------------------------------------------

function [values,w] = correction_interp_parameter(values, w, par, dim, correction_name)

  % decided dimension of interpolation
  % note: the selected/inerpolated dimension will be always row
  if dim == 2
    values = values.';
  end

  if par.interp
    % --- interpolable parameter, obviously numeric
    
    % convert parameter to numeric 
    x_vals = cellfun('str2num',par.values,'UniformOutput',false);
    if any(~cellfun('numel',num2cell(x_vals)))
      error(sprintf('Correction parser: Some of the values of the dependence parameter ''%s'' are not numeric in the correction ''%s''!',par.name,correction_name));
    end
    
    % convert measurement header parameter to numeric                 
    xi = str2num(par.meas_value);
    if ~numel(xi)
      error(sprintf('Correction parser: The value of the dependence parameter ''%s'' in the measurement header is not numeric in the correction ''%s''!',par.name,correction_name));
    end
    
    sz = size(values,1);
    
    if sz == 1
      % there is just one item, so just check if the value from the measurement header is equal to the listed paramter values
      if ~correction_compare_attributes(xi,x_vals)
        error(sprintf('Correction parser: The value of the dependence parameter ''%s'' in the measurement header is outside the range of listed values of that parameter in the correction ''%s''!',par.name,correction_name));
      end
      
      % so it is ok, return the only item  
      
    else
      % multiple items in the interpolated dimension - interpolate
      
      [equ_a,high_a] = correction_compare_attributes(xi,x_vals(1));
      [equ_b,high_b] = correction_compare_attributes(xi,x_vals(end));
      if (~high_a && ~equ_a) || (high_b && ~equ_b)
        % the 'xi' value is outside the range of 'x_vals' (inlcuding rounding errors) - error 
        error(sprintf('Correction parser: The value of the dependence parameter ''%s'' in the measurement header is outside the range of listed values of that parameter in the correction ''%s''!',par.name,correction_name));        
      else 
        % the 'xi' is somewhere inside the range of 'x_vals' or at least damn close (rounding errors range) - interpolate   
               
        if isempty(w)
          % numeric - interpolate       
          values = interp1(cell2mat(x_vals)(:),values,xi,'extrap');
        else
          % strings (CSV mode) - just update interpolation weigth matrix
          
          % convert parameter to vertical vector
          x_vals = cell2mat(x_vals)(:);
          
          w = zeros(size(values));
          
          if xi <= x_vals(1)
            % minimum
            w(2:end,:) = 0;
          elseif xi >= x_vals(end)
            % maximum
            w(1:end-1,:) = 0;
          else
            % something in the middle - interpolate rows
            
            % calculate linear interpolation weight 
            id = find(xi >= x_vals,1);            
            wei = (xi - x_vals(id))./(x_vals(id+1) - x_vals(id));
            
            % first, mask out all unused rows
            w(1:end ~= id & 1:end ~= id+1,:) = 0;
            
            % now apply interpolation to the remaining rows
            w(id + 0,:) .*= (1 - wei); 
            w(id + 1,:) .*= wei;       
          
          end
                      
        end
        
      end
      
    end
   
  else
    % --- enumeration type
    
    % try to find the matching value of the parameter from correction and from the measurement header 
    id = correction_compare_attributes(par.meas_value,par.values);
    if ~id
      % not found!
      error(sprintf('Correction parser: Value ''%s'' of the dependence parameter ''%s'' out of range of available values in the correction ''%s''!',par.meas_value,par.name,correction_name));
    end
    
    % ok, so we have found the match - check the range
    if id > size(values,1)
      error(sprintf('Correction parser: Inconsistent data of the correction ''%s''! There possibly more listed values of the parameter ''%s'' than rows of the correction value.',correction_name,par.name));
    end
    
    % ok, selected item(s) exist
    if isempty(w)
      % numeric - return selection       
      values = values(id,:);
    else
      % strings (CSV mode) - just update interpolation weigth matrix (clear W for nonused items)      
      w(1:end ~= id,:) = 0;            
    end 
  
  end
  
  % restore original orientation of the 
  if dim == 2
    values = values.';
  end
  
end
