function text = infogettext(infostr, key, varargin)%<<<1
% -- Function File: TEXT = infogettext (INFOSTR, KEY)
% -- Function File: TEXT = infogettext (INFOSTR, KEY, SCELL)
%     Parse info string INFOSTR, finds line with content "key:: value"
%     and returns the value as text.
%
%     If SCELL is set, the key is searched in section(s) defined by
%     string(s) in cell.
%
%     Example:
%          infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n1;  2; 3; \n4;5;         6;  \n#endmatrix:: simple matrix \nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n')
%          infogettext(infostr,'A')
%          infogettext(infostr,'B([V?*.])')
%          infogettext(infostr,'C')
%          infogettext(infostr,'C', {'section 1', 'subsection'})
%          infogettext(infostr,'C', {'section 2'})

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
                error('infogettext: infostr and key must be strings')
        end
        if (~all(cellfun(@ischar, scell)))
                error('infogettext: scell must be a cell of strings')
        end

        % get text %<<<2
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
                                error('infogettext: infinite loop happened!')
                        end
                end
        end
        % find key and get value
        % regexp for rest of line after a key:
        rol = '\s*::([^\n]*)';
        %remove leading spaces of key and escape characters:
        key = regexpescape(strtrim(key));
        % find line with the key:
        % (?m) is regexp flag: ^ and $ match start and end of line
        [S, E, TE, M, T, NM] = regexpi (infostr,['(?m)^\s*' key rol]);
        % return key if found:
        if isempty(T)
                error(['infogettext: key `' key '` not found'])
        else
                if isscalar(T)
                        text = strtrim(T{1}{1});
                else
                        error(['infogettext: key `' key '` found on multiple places'])
                end
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
%! infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n1;  2; 3; \n4;5;         6;  \n#endmatrix:: simple matrix \nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n');
%!assert(strcmp(infogettext(infostr,'A'),'1'))
%!assert(strcmp(infogettext(infostr,'B([V?*.])'),'!$^&*()[];::,.'));
%!assert(strcmp(infogettext(infostr,'C'),'c without section'))
%!assert(strcmp(infogettext(infostr,'C', {'section 1'}),'c in section 1'))
%!assert(strcmp(infogettext(infostr,'C', {'section 1', 'subsection'}),'c in subsection'))
%!assert(strcmp(infogettext(infostr,'C', {'section 2'}),'c in section 2'))
%!error(infogettext('', ''));
%!error(infogettext('', infostr));
%!error(infogettext(infostr, ''));
%!error(infogettext(infostr, 'A', {'section 1'}));

% NOVY TESTOVACI INFOSTR:
% 
% infostr = "A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n1;  2; 3; \n4;5;         6;  \n#endmatrix:: simple matrix \nC:: c without section\n#startsection:: section 1 \n  C:: c in section 1 \n  #startsection:: subsection\n    C:: c in subsection\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: c in section 2\n#endsection:: section 2\n"

% A:: 1
% some note
% B([V?*.])::    !$^&*()[];::,.
% #startmatrix:: simple matrix 
% 1;  2; 3; 
% 4;5;         6;  
% #endmatrix:: simple matrix 
% C:: c without section
% #startsection:: section 1 
  % C:: c in section 1 
  % #startsection:: subsection
    % C:: c in subsection
  % #endsection:: subsection
% #endsection:: section 1
% #startsection:: section 2
  % C:: c in section 2
% #endsection:: section 2

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
