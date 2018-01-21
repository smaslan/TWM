%% -----------------------------------------------------------------------------
%% QWTB TracePQM: Loads list of the supported algorithms.
%% Reads INFO file with the list of the algorithms.
%% Returns cell array of the algorithm IDs.
%% -----------------------------------------------------------------------------
function [alg_list] = qwtb_parse_alg_filter(list_file)

  % try to load filter file
  inf = infoload(list_file);
  
  % check file type
  if ~strcmpi(infogettext(inf,'type'),'qwtb list')
    error('QWTB algorithms filter loader: Not an algorithm filter file type!');
  end
  
  % try to load list of the algorithms (algorithm IDs)
  alg_list = infogettextmatrix(inf, 'list of supported algorithms');

end