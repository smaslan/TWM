%% 'Escapification' of formatting characters for GNU Plot title strings.

function [str] = str_insert_escapes(str)

  %% add escape characters for '_'
  tid = find(str=='_');
  for k=1:length(tid)
    str((tid(k)+k-1):end+1) = ['\' str((tid(k)+k-1):end)];
  end

end