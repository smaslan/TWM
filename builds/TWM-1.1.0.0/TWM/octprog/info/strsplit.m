function [sarr] = strsplit(str,delim)
% This is simplified SARR = STRFIND(STR, DELIM) function for old Matlab where it is not
% Splits string STR into cell array SARR of strings. DELIM is separator string.
%
    
    if ~exist('delim','var')
        error('Delimiter not defined!');
    end
    
    if ~exist('str','var')
        error('String to split not defined!');
    end

    % size of dleimiter
    len = numel(delim);
    
    % search all occurencies of delimiter
    ids = strfind(str,delim);

    % multiple segments
    sarr = {};
    pstr = 1;
    for k = 1:numel(ids)
        sarr{end+1} = char(str(pstr:ids(k)-1));
        pstr = ids(k) + len;
    end
    %if pstr < numel(str) + 1
        sarr{end+1} = char(str(pstr:end));
    %end

end