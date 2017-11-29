function number = infogetnumber(infostr, key, varargin)%<<<1
% -- Function File: TEXT = infogetnumber (INFOSTR, KEY)
% -- Function File: TEXT = infogetnumber (INFOSTR, KEY, SCELL)
%     Parse info string INFOSTR, finds line with content "key:: value"
%     and returns the value as number
%
%     If SCELL is set, the key is searched in section(s) defined by
%     string(s) in cell.
%
%     Example:
%          infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n1;  2; 3; \n4;5;         6;  \n#endmatrix:: simple matrix \nC:: 2\n#startsection:: section 1 \n  C:: 3 \n  #startsection:: subsection\n    C:: 4\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: 5\n#endsection:: section 2\n')
%          infogetnumber(infostr,'A')
%          infogetnumber(infostr,'C')
%          infogetnumber(infostr,'C', {'section 1', 'subsection'})
%          infogetnumber(infostr,'C', {'section 2'})

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
                error('infogetnumber: infostr and key must be strings')
        end
        if (~all(cellfun(@ischar, scell)))
                error('infogetnumber: scell must be a cell of strings')
        end

        % get number %<<<2
        % get number as text:
        try
                s = infogettext(infostr, key, scell);
        catch
                [msg, msgid] = lasterr;
                id = findstr(msg, 'infogettext: key');
                if isempty(id)
                        % unknown error
                        error(msg)
                else
                        % infogettext error change to infogetnumber error:
                        msg = ['infogetnumber' msg(12:end)];
                        error(msg)
                end
        end
        number = str2num(s);
        if isempty(number)
                error(['infogetnumber: key `' key '` does not contain numeric data'])
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
%! infostr = sprintf('A:: 1\nsome note\nB([V?*.])::    !$^&*()[];::,.\n#startmatrix:: simple matrix \n1;  2; 3; \n4;5;         6;  \n#endmatrix:: simple matrix \nC:: 2\n#startsection:: section 1 \n  C:: 3\n  #startsection:: subsection\n    C:: 4\n  #endsection:: subsection\n#endsection:: section 1\n#startsection:: section 2\n  C:: 5\n#endsection:: section 2\n');
%!assert(infogetnumber(infostr,'A') == 1)
%!assert(infogetnumber(infostr,'C') == 2)
%!assert(infogetnumber(infostr,'C', {'section 1'}) == 3)
%!assert(infogetnumber(infostr,'C', {'section 1', 'subsection'}) == 4)
%!assert(infogetnumber(infostr,'C', {'section 2'}) == 5)
%!error(infogetnumber('', ''));
%!error(infogetnumber('', infostr));
%!error(infogetnumber(infostr, ''));
%!error(infogetnumber(infostr, 'A', {'section 1'}));

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
