%% -----------------------------------------------------------------------------
%% TracePQM: Checks if there is result file in the measurement folder.
%% Returns list of available results for selected algorithm.
%%  inputs:
%%    meas_file - full path of the measurement header
%%    alg_id - algorithm ID string, if empty, last calculated alg. is used
%%
%%  outputs:
%%    res_files - CSV file data with list of the avalable results
%%    res_exist - non-zero if result file exist
%% -----------------------------------------------------------------------------
function [res_files, res_exist] = qwtb_get_results_info(meas_root, alg_id)

  res_files = '';
  res_exist = 0;
  
  % path of the results header
  res_header = [meas_root filesep() 'results.info'];
  
  try
    % load results header
    inf = infoload(res_header);    
  catch
    return;
  end
  
  % try load last algorithm ID
  try 
    last_alg = infogettext(inf, 'last algorithm');
  catch
    last_alg = '';
  end
  if isempty(alg_id)
    alg_id = last_alg;
  end
  
  % list of calculated algorithms
  try 
    algs = infogetmatrixstr(inf, 'algorithms');
  catch
    res_exist = 0;
    return
  end
  
  % check algorithm selection validity
  aid = find(strcmpi(algs, alg_id), 1);
  if ~numel(aid)
    error('QWTB results viewer: Index of the algorithm out of range of the available algorithms!');
  end
  
  % list of calculated algorithms
  try 
    res_files = infogetmatrixstr(inf, algs{aid});
  catch
    error('QWTB results viewer: Desired algorithm''s result not available in the results header! Possibly inconsitent results header file.');
  end
  
  % result file exist
  res_exist = 1;
  
  % convert list of result to CSV file 
  res_files = catcellcsv(res_files(:)');
  
end