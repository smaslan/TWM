%% -----------------------------------------------------------------------------
%% QWTB TracePQM: Returns the list of the allowed QWTB algorithms.
%%  If 'list_file' file with the allowed algorithms is entered, it will
%%  return only the allowed algorithms. 
%% -----------------------------------------------------------------------------
function [ids, names] = qwtb_load_algorithms(list_file)

  % load all algorithms info
  algs = qwtb();
  
  % list of the allowed algorithms
  if nargin > 0 && numel(list_file)
    allowed_list = qwtb_parse_alg_filter(list_file);
  end
  
  if exist('allowed_list','var')
    % allowed algorithms filter exist - filter available algs.
    
    % available alg. ids 
    all_ids = {algs.id};
    
    % build list of allowed algorithms
    allowed_index = [];        
    for k = 1:numel(algs)
      if any(strcmpi(all_ids(k),allowed_list))
        allowed_index(end+1) = k;
      end
    end
  else
    % no filter - allow all available algorithms    
    allowed_index = [1:numel(algs)];
  end
  
  % pack the filtered list to '\t' separated string
  names = catcellcsv({algs(allowed_index).name});
  ids = catcellcsv({algs(allowed_index).id}); 

end