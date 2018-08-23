%% -----------------------------------------------------------------------------
%% TracePQM: Searches variable by its name in the loaded result variables list.
%% 
%% inputs: variables - variables list as returned by qwtb_parse_result()
%%         name - name of the variable to find
%% outputs: vid - index of the found variable, otherwise 0
%%
%% -----------------------------------------------------------------------------
function [vid] = qwtb_find_results_variable(variables, name)

  % not found yet
  vid = 0;

  % total variables count 
  V = numel(variables);
  
  % scan through the variables list
  for v = 1:V
    if strcmp(variables{v}.name, name)
      % found it
      vid = v;
      return
    end
  end

end