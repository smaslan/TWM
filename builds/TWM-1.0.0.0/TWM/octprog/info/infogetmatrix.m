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
        NL = sprintf('\n');

        % check inputs %<<<2
        if (nargin < 2 || nargin > 3)
                print_usage()
        end
        % set default value
        % (this is because Matlab cannot assign default value in function definition)
        if nargin < 3
                scell = {};
        else
                scell = varargin{1};
        end
        % check values of inputs
        if (~ischar(infostr) || ~ischar(key))
                error('infogetmatrix: infostr and key must be strings')
        end
        if (~all(cellfun(@ischar, scell)))
                error('infogetmatrix: scell must be a cell of strings')
        end

        % find proper section and remove subsections %<<<2
        % find proper section(s):
        for i = 1:length(scell)
                infostr = infogetsection(infostr, scell{i});
        end
        % remove all other sections in infostr, to prevent finding
        % key inside of some section
        while (~isempty(infostr))
                % search sections one by one from start of infostr to end
                [S, E, TE, M, T, NM] = regexpi(infostr, ['#startsection\s*::\s*(.*)\s*\n(.*)\n\s*#endsection\s*::\s*\1'], 'once');
                if isempty(T)
                        % no section found, quit:
                        break
                else
                        % some section found, remove it from infostr:
                        infostr = [deblank(infostr(1:S-1)) NL fliplr(deblank(fliplr(infostr(E+1:end))))];
                        if S-1 >= E+1
                                % danger of infinite loop! this should never happen
                                error('infogetmatrix: infinite loop happened!')
                        end
                end
        end

        % get matrix %<<<2
        % prepare matrix:
        key = strtrim(key);
        % escape characters of regular expression special meaning:
        key = regexpescape(key);
        % find matrix:
        [S, E, TE, M, T, NM] = regexpi (infostr,['#startmatrix\s*::\s*' key '(.*)' '#endmatrix\s*::\s*' key], 'once');
        if isempty(T)
                error(['infogetmatrix: matrix named `' key '` not found'])
        end
        infostr=strtrim(T{1});

        % parse matrix %<<<2
        % prepare error message:
        errorline = 'infogetmatrix: empty matrix found';
        % get first line to determine number of columns of the matrix:
        s = strsplit(infostr, sprintf('\n'));
        if isempty(s)
                error(errorline);
        end
        s = s{1,1};
        % split by semicolons:
        s = strsplit(s, ';');
        % no of columns, -1 is because after last semicolon is also (maybe empty) string:
        cols = length(s) - 1;
        if cols
                % get the full matrix, split by ; and change to number:
                c = cellfun(@str2num, strsplit(infostr, ';'), 'UniformOutput', false);
                % because of (even empty) string after last semicolon:
                c = c(1:end-1);
                % check matrix size:
                if ( mod(length(c),cols) || length(c)./cols < 1 )
                        error(errorline);
                end
                % convert from cell to matrix, and fix orientation:
                matrix = cell2mat(reshape(c, cols, length(c)./cols));
                matrix = matrix';
        else
                matrix = [];        
        end
        
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
