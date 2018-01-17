function matrix = infogetmatrix(infostr, key, varargin)%<<<1
% -- Function File: TEXT = infogetmatrix (INFOSTR, KEY)
% -- Function File: TEXT = infogetmatrix (INFOSTR, KEY, SCELL)
%     Parse info string INFOSTR, finds lines after line '#startmatrix::
%     key' and before '#endmatrix:: key', parse numbers from lines and
%     return as matrix.
%
%     If SCELL is set, the key is searched in section(s) defined by
%     string(s) in cell.
%
%     Example:
%          infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n1;  2; 3; \n4;5;         6;  \n#endmatrix:: simple matrix \nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n')
%          infogetmatrix(infostr,'simple matrix')

% Copyright (C) 2013 Martin Šíra %<<<1
%

% Author: Martin Šíra <msiraATcmi.cz>
% Created: 2013
% Version: 2.0
% Script quality:
%   Tested: yes
%   Contains help: yes
%   Contains example in help: yes
%   Checks inputs: yes
%   Contains tests: yes
%   Contains demo: no
%   Optimized: no

        % input possibilities:
        %       infostr, key,
        %       infostr, key, scell

        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        
        cells = infogetmatrixstr(infostr, key, varargin{:});
        
        matrix = str2double(cells);
        
end

function key = regexpescape(key)
        % Translate all special characters (e.g., '$', '.', '?', '[') in
        % key so that they are treated as literal characters when used
        % in the regexp and regexprep functions. The translation inserts
        % an escape character ('\') before each special character.
        % additional characters are translated, this fixes error in octave
        % function regexptranslate.

        key = regexptranslate('escape', key);
        % test if octave error present:
        if strcmp(regexptranslate('escape','*(['), '*([')
                % fix octave error not replacing other special meaning characters:
                key = regexprep(key, '\*', '\*');
                key = regexprep(key, '\(', '\(');
                key = regexprep(key, '\)', '\)');
        end
end

% --------------------------- tests: %<<<1
%!shared infostr
%! infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n1;  2   ; 3; \n4;5;         6  ;  \n#endmatrix:: simple matrix \nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n#startmatrix:: simple matrix \n2;  3; 4; \n5;6;         7;  \n#endmatrix:: simple matrix \n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n');
%!assert(all(all( infogetmatrix(infostr,'simple matrix') == [1 2 3; 4 5 6] )))
%!assert(all(all( infogetmatrix(infostr,'simple matrix', {'section 1', 'subsection'}) == [2 3 4; 5 6 7] )))
%!error(infogetmatrix('', ''));
%!error(infogetmatrix('', infostr));
%!error(infogetmatrix(infostr, ''));
%!error(infogetmatrix(infostr, 'A', {'section 1'}));

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
