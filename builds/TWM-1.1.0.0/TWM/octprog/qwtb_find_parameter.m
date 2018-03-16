%% -----------------------------------------------------------------------------
%% TracePQM: Searches input or output parameter of the QWTB by name
%%   inputs:
%%     list - list of the input or output parameters returned
%%            by the QWTB(..., 'info')
%%     name - name of the parameter to search
%%     is_last_avg - 1 if last averaging cycle was measured, 0 otherwise
%%
%%   outputs:
%%     index - index of the variable in the list, returns 0 if not found
%%     description - text description of the variable
%% -----------------------------------------------------------------------------
function [index, description] = qwtb_find_parameter(list, name)

  index = 0;
  description = '';

  for n = 1:numel(list)
    if strcmp(list(n).name, name)
      % found
      index = n;
      description = list(n).desc;    
      return
    end
  end
  
end