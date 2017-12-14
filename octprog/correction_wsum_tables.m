function [tout] = correction_wsum_tables(tin,w)
% TWM: Weighted sum of the correction tables loaded by 'correction_load_table'.
%
% This will calculate weighted sum of each quantity of each input table.
% Note the tables must be equal in parameters, axes ranges, etc., 
% i.e. call 'correction_expand_table' first!
%
% Parameters:
%  tin         - cell array of input tables
%  w           - weight matrix, matching size to 'tin'
%
% Returns:
%  tout - table with the weighted sum
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2017, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
% 

  if any(size(tin) ~= size(w))
    error('Correction table loader: size of the table matrix does not match size of the weight matrix!');
  end
  
  % convert data to vector
  tin = tin(:);
  w = reshape(w(:),[1 1 numel(w)]);
  
  % make output table prototype
  tout = tin{1};
  
  % list of quantities in the table(s)
  q_names = tout.quant_names;
  Q = numel(q_names);
  
  % clear the sum(s)
  for q = 1:Q
    tout = setfield(tout,q_names{q},getfield(tout,q_names{q}).*0);
  end
  
  % for each table:
  % for each quantity
  for q = 1:Q
    q_name = q_names{q};
    
    % load quantity for each table
    qsum = [];
    for t = 1:T
      qsum(:,:,t) = getfield(tin{t},q_name);
    end
    
    % calculate weghted sum
    qsum = sum(bsxfun(@times,qsum,w),3);
    
    % store the sum to the output table
    tout = setfield(tout,q_name,qsum);
      
  end

end