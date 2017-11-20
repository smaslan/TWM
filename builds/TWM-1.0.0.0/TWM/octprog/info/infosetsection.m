function infostr = infosetsection(varargin)%<<<1
% -- Function File: INFOSTR = infosetsection (KEY, VAL)
% -- Function File: INFOSTR = infosetsection (VAL, SCELL)
% -- Function File: INFOSTR = infosetsection (INFOSTR, KEY, VAL)
% -- Function File: INFOSTR = infosetsection (INFOSTR, VAL, SCELL)
% -- Function File: INFOSTR = infosetsection (INFOSTR, KEY, VAL, SCELL)
%     Returns info string with a section made from KEY and string VAL in
%     following format:
%          #startsection:: key
%               val
%          #endsection:: key
%
%     If SCELL is set, the section is put into subsections according
%     SCELL.  If KEY is not specified, last element of SCELL is
%     considered as KEY.
%
%     If INFOSTR is set, the section is put into existing INFOSTR
%     sections, or sections are generated if needed.
%
%     Example:
%          infosetsection('section key', sprintf('multi\nline\nvalue'))
%          infostr = infosetsection('value', {'section key', 'subsection key'})
%          infosetsection(infostr, 'subsubsection key', 'other value', {'section key', 'subsection key'})

% Copyright (C) 2014 Martin Šíra %<<<1
%

% Author: Martin Šíra <msiraATcmi.cz>
% Created: 2014
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
        %       key, val
        %       val, scell
        %       key, val, scell - this possibility is not permitted because it cannot be distinguished between infostr and key, one can do: '', key, val, scell
        %       infostr, key, val
        %       infostr, val, scell
        %       infostr, key, val, scell

        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % constant - number of spaces in indented section:
        INDENT_LEN = 8;

        % check inputs %<<<2
        if (nargin < 2 || nargin > 4)
                print_usage()
        end
        % identify inputs
        if nargin == 2;
                if ~iscell(varargin{2})
                        infostr = '';
                        key = varargin{1};
                        val = varargin{2};
                        scell = {};
                else
                        infostr = '';
                        key = '';
                        val = varargin{1};
                        scell = varargin{2};
                end
        elseif nargin == 3
                if iscell(varargin{3})
                        infostr = varargin{1};
                        key = '';
                        val = varargin{2};
                        scell = varargin{3};
                else
                        infostr = varargin{1};
                        key = varargin{2};
                        val = varargin{3};
                        scell = {};
                end
        elseif nargin == 4
                infostr = varargin{1};
                key = varargin{2};
                val = varargin{3};
                scell = varargin{4};
        end
        % check values of inputs
        if (~ischar(infostr) || ~ischar(key) || ~ischar(val))
                error('infosetsection: infostr, key and val must be strings')
        end
        if (~iscell(scell))
                error('infosetsection: scell must be a cell')
        end
        if (~all(cellfun(@ischar, scell)))
                error('infosetsection: scell must be a cell of strings')
        end

        % format inputs %<<<2
        if ~isempty(key)
                scell = [scell {key}];
        end

        % make infostr %<<<2
        if (isempty(infostr) && length(scell) == 1)
                % just simply generate info string
                % add newlines to a value, indent lines by INDENT_LEN, remove indentation from last line:
                spaces = repmat(' ', 1, INDENT_LEN);
                val = [deblank(strrep([NL strtrim(val) NL], NL, [NL spaces])) NL];
                % create infostr:
                infostr = [infostr sprintf('#startsection:: %s%s#endsection:: %s', scell{end}, val, scell{end})];
        else
                % make recursive preparation of info string
                % find out how many sections from scell already exists in infostr:
                position = length(infostr);
                for i = 1:length(scell)
                        % through deeper and deeper section path
                        try
                                % check section path scell(1:i):
                                [tmp, position] = infogetsection(infostr, scell(1:i));
                        catch
                                % error happened -> section path scell(1:i) do not exist:
                                i = i - 1;
                                break
                        end
                end
                % split info string according found position:
                infostrA = infostr(1:position);
                infostrB = infostr(position+1:end);
                % remove leading spaces and keep newline in part A:
                if isempty(infostrA)
                        before = '';
                else
                        before = [deblank(infostrA) NL];
                end
                % remove leading new lines if present in part B:
                infostrB = regexprep(infostrB, '^\n', '');
                % create sections if needed:
                if i < length(scell) - 1;
                        % make recursion to generate new sections:
                        toinsert = infosetsection(val, scell(i+2:end));
                else
                        % else just use value with proper indentation:
                        spaces = repmat(' ', 1, i.*INDENT_LEN);
                        toinsert = [deblank(strrep([NL strtrim(val) NL], NL, [NL spaces])) NL];
                end
                % create main section if needed
                if i < length(scell);
                        % simply generate section
                        % (here could be a line with sprintf, or subfunction can be used, but recursion 
                        % seems to be the simplest solution
                        toinsert = infosetsection(scell{i+1}, toinsert);
                        spaces = repmat(' ', 1, i.*INDENT_LEN);
                        toinsert = [deblank(strrep([NL strtrim(toinsert) NL], NL, [NL spaces])) NL];
                end
                toinsert = regexprep(toinsert, '^\n', '');
                % create new infostr by inserting new part at proper place of old infostr:
                infostr = deblank([before deblank(toinsert) NL infostrB]);
        end
end

% --------------------------- tests: %<<<1
%!shared iskey, iskeysubkey, iskey2, isvalval2, isvalsubval2
%! iskey = sprintf('#startsection:: skey\n        key:: val\n#endsection:: skey');
%! iskeysubkey = sprintf('#startsection:: skey\n        #startsection:: subskey\n                key:: val\n        #endsection:: subskey\n#endsection:: skey');
%! iskey2 = sprintf('#startsection:: skey2\n        key:: val\n#endsection:: skey2');
%! isvalval2 = sprintf('#startsection:: skey\n        #startsection:: subskey\n                key:: val\n        #endsection:: subskey\n        key:: val2\n#endsection:: skey');
%! isvalsubval2 = sprintf('#startsection:: skey\n        #startsection:: subskey\n                key:: val\n                key:: val2\n        #endsection:: subskey\n#endsection:: skey');
%!assert(strcmp(infosetsection( 'skey', 'key:: val'                             ), iskey));
%!assert(strcmp(infosetsection( 'key:: val', {'skey'}                           ), iskey));
%!assert(strcmp(infosetsection( 'key:: val', {'skey', 'subskey'}                ), iskeysubkey));
%!assert(strcmp(infosetsection( iskey, 'skey2', 'key:: val'                     ), [iskey  sprintf('\n') iskey2]));
%!assert(strcmp(infosetsection( iskey, 'key:: val', {'skey2'}                   ), [iskey  sprintf('\n') iskey2]));
%!assert(strcmp(infosetsection( iskey2, 'subskey', 'key:: val', {'skey'}        ), [iskey2 sprintf('\n') iskeysubkey]));
%!assert(strcmp(infosetsection( iskeysubkey, 'key:: val2', {'skey'}             ), isvalval2));
%!assert(strcmp(infosetsection( iskeysubkey, 'subskey', 'key:: val2', {'skey'}  ), isvalsubval2));
%!error(infosetsection('a'))
%!error(infosetsection(5))
%!error(infosetsection('a', 'b', 'c', 'd'))
%!error(infosetsection('a', 'b', 'c', {5}))

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
