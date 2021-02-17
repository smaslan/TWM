% Converts path to dos notation if running under windows system. Converts slashes '/' to
% back slashes '\'.
%
% Usage:
%   PTH = path_unix2dos(PTH)
% Inputs:
%   PTH - path to a directory or file. Can be STR of a cell array of strings, in which case the
%    replacement is done for each element and a cell array is returned.
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2020, Martin Sira, msira@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
%

function pth = path_unix2dos(pth)
    if isunix
        pth = strrep(pth, '/', '\');
    end % isunix
end
