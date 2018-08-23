%% -----------------------------------------------------------------------------
%% QWTB TracePQM: Tests if the QWTB toolbox is available in the load path.
%% It also tries to load INFO file with the list of the supported algorithms.
%% -----------------------------------------------------------------------------
function [] = qwtb_test(list_file)
    
  if ~exist('qwtb.m','file')
    error('QWTB toolbox not found! Maybe wrong path was selected.');
  end
  
  % try to load algorithms filter file if path of the file entered
  if nargin > 0 && numel(list_file)
    qwtb_parse_alg_filter(list_file);
  end
  
end