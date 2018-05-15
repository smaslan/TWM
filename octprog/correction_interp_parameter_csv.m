%% -----------------------------------------------------------------------------
%% TracePQM: Parser of the digitizer correction CSV data.
%%
%% Note: INVALID - OLD VERSION, WILL BE FIXED
%% -----------------------------------------------------------------------------
function [data] = correction_interp_parameter_csv(files, w, csvcfg, correction_name)
  
  % get rid of elements with zero weights and convert inputs to vector
  files = files(w ~= 0);
  w = w(w ~= 0);  
    
  % build complete list of table quantities
  q_names = {csvcfg.primary_ax,csvcfg.quant_names{:}};
  if isfield(csvcfg,'second_ax')
    second_ax = csvcfg.second_ax;
  else
    second_ax = '';
  end
  
  % load and parse the CSV tables files  
  tab = {};
  for m = 1:size(files,1)
    tab{m} = correction_load_table(files{m},second_ax,q_names);
  end
  
  % merge tables axes to largest common range
  if numel(w > 0) > 1
    tab = correction_expand_tables(tab);
  end   

  % --- there should be only up to 4 non-zero weights from which the result must be interpolated ---        
  if numel(w,1) > 4
    error(sprintf('Correction parser: Interpolation/selection of items of correction ''%s'' failed! This should never happen so if it did, the function correction_interp_paramter() somehow failed at generating interpolation weights.',correction_name));
  end
  
  % calculate the weighted sum
  data = correction_wsum_tables(tab(:),w(:));   

  
end
