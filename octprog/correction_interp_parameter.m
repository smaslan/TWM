%% -----------------------------------------------------------------------------
%% TracePQM: Parser of the digitizer correction data.
%%
%% Note: INVALID - OLD VERSION, WILL BE FIXED
%% -----------------------------------------------------------------------------

function [values,w] = correction_interp_parameter(values, w, par, dim, correction_name)

  % decided dimension of interpolation/selection
  % note: the selected/inerpolated dimension will be always row
  if dim == 2
    values = values.';
    w = w.';
  end

  if par.interp
    % --- interpolable parameter, it is obviously numeric
    
    % get parameter values 
    x_vals = par.values;
    if ~par.is_numeric
      % this should never happen as it is checked before, but what the heck...
      error(sprintf('Correction parser: Interpolation is requested for dependence parameter ''%s'' for the correction ''%s'' but the parameter''s values or measurement header value is not numeric!',par.name,correction_name));
    end
    
    % convert measurement header parameter to numeric                 
    xi = par.meas_value;
    
    sz = size(values,1);    
    if sz == 1
      % there is just one item for this parameter, 
      % so just check the parameter's value match to the meas. header value
      if ~correction_compare_attributes(xi,x_vals)
        error(sprintf('Correction parser: The value of the dependence parameter ''%s'' in the measurement header is outside the range of listed values of that parameter in the correction ''%s''!',par.name,correction_name));
      end
      
      % no fail, so it is ok, return the only item  
      
    else
      % multiple items in the interpolated dimension - interpolate
      
      % compare limiting values of the parameter to the 'xi'
      [equ_a,high_a] = correction_compare_attributes(xi,x_vals(1));
      [equ_b,high_b] = correction_compare_attributes(xi,x_vals(end));
      
      if (~high_a && ~equ_a) || (high_b && ~equ_b)
        % the 'xi' value is outside the range of 'x_vals' (inlcuding rounding errors) - error 
        error(sprintf('Correction parser: The value of the dependence parameter ''%s'' in the measurement header is outside the range of listed values of that parameter in the correction ''%s''!',par.name,correction_name));        
      else 
        % the 'xi' is somewhere inside the range of 'x_vals' or at least damn close (rounding errors range) - interpolate   
               
        if isempty(w)
          % numeric - interpolate       
          x_val_tmp = cell2mat(x_vals);
          values = interp1(x_val_tmp(:),values,xi,'extrap');
        else
          % CSV mode - just update interpolation weigth matrix
          
          % convert parameter to vertical vector
          x_vals = cell2mat(x_vals);
          x_vals = x_vals(:);
          
          %w = zeros(size(values));
          
          if xi <= x_vals(1)
            % we are at minimum boundary, keep only first row
            w(2:end,:) = 0;
          elseif xi >= x_vals(end)
            % we are at maximum boundary, keep only last row
            w(1:end-1,:) = 0;
          else
            % we are somewhere in the middle - interpolate rows
            
            % calculate linear interpolation weight 
            id = find(xi >= x_vals,1);            
            wei = (xi - x_vals(id))./(x_vals(id+1) - x_vals(id));
            
            % first, mask out all unused rows
            w(1:end ~= id & 1:end ~= id+1,:) = 0;
            
            % now apply interpolation to the remaining rows
            w(id + 0,:) = w(id + 0,:).*(1 - wei); 
            w(id + 1,:) = w(id + 1,:).*wei;
          
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
      error(sprintf('Correction parser: Inconsistent data of the correction ''%s''! There is possibly more listed values of the parameter ''%s'' than rows of the correction value.',correction_name,par.name));
    end
    
    % ok, selected item(s) exist
    if isempty(w)
      % numeric - return selection       
      values = values(id,:);
    else
      % CSV mode - just update interpolation weigth matrix (clear W for unused items)      
      w(1:end ~= id,:) = 0;            
    end 
  
  end
  
  % restore original orientation of the 
  if dim == 2
    values = values.';
    w = w.';
  end
  
end
