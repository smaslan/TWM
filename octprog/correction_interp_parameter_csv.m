%% -----------------------------------------------------------------------------
%% TracePQM: Parser of the digitizer correction CSV data.
%%
%% Note: INVALID - OLD VERSION, WILL BE FIXED
%% -----------------------------------------------------------------------------
function [data] = correction_interp_parameter_csv(files, w, csvcfg, correction_name)
  
  % get rid of elements with zero weights
  for k = size(w,1)
    if any(w(k,:) ~= 0)
      w_tmp(k,:) = w(k,:);
      files_tmp(k,:) = files(k,:);
    end
  end
  for k = size(w_tmp,2)
    if any(w_tmp(:,k) ~= 0)
      w(:,k) = w_tmp(:,k);
      files(:,k) = files_tmp(:,k);
    end
  end
  
  % build complete list of table quantities
  q_names = csvcfg.quant_names;
  q_names{end+1} = csvcfg.primary_ax;
  
  % load and parse the CSV tables files
  tab = {};
  for m = size(files,1)
    for n = size(files,2)
      % try to read the numeric portion of the CSV file 
      tab{m,n} = correction_load_table(files{m,n},csvcfg.second_ax,q_names);
    end
  end
  
  % merge tables axes to largest common range
  tab = reshape(correction_expand_tables(tab(:)),size(tab));   

  % --- there should be only up to 4 non-zero weights from which the result must be interpolated ---        
  if size(w,1) > 2 || file(w,2) > 2
    error(sprintf('Correction parser: Interpolation/selection of items of correction ''%s'' failed! This should never happen so if it did, the function correction_interp_paramter() somehow failed at generating interpolation weights.',correction_name));
  end
  
  % calculate the weighted sum
  data = correction_wsum_tables(tab,w);   

  
end
