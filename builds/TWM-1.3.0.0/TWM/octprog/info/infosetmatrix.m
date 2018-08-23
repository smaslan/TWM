function infostr = infosetmatrix(varargin)%<<<1
% -- Function File: INFOSTR = infosetmatrix (KEY, VAL)
% -- Function File: INFOSTR = infosetmatrix (KEY, VAL, SCELL)
% -- Function File: INFOSTR = infosetmatrix (INFOSTR, KEY, VAL)
% -- Function File: INFOSTR = infosetmatrix (INFOSTR, KEY, VAL, SCELL)
%     Returns info string with a numeric matrix formatted in following
%     format: VAL in following format:
%          #startmatrix:: key
%               val(1,1); val(1,2); val(1,3)
%               val(2,1); val(2,2); val(2,3)
%          #endmatrix:: key
%
%     If SCELL is set, the section is put into subsections according
%     SCELL.
%
%     If INFOSTR is set, the section is put into existing INFOSTR
%     sections, or sections are generated if needed and properly
%     appended/inserted into INFOSTR.
%
%     Example:
%          infosetmatrix('small matrix', [1:3; 4:6])

% Copyright (C) 2014 Martin Šíra %<<<1
%

% Author: Martin Šíra <msiraATcmi.cz>
% Created: 2014
% Version: 4.0
% Script quality:
%   Tested: yes
%   Contains help: yes
%   Contains example in help: yes
%   Checks inputs: yes
%   Contains tests: yes
%   Contains demo: no
%   Optimized: no

        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % identify and check inputs %<<<2
        [printusage, infostr, key, val, scell] = set_id_check_inputs('infosetmatrix', varargin{:});
        if printusage
                print_usage()
        end
        % check content of val:
        if (ndims(val) > 2 || ~isnumeric(val))
                error('infosetmatrix: val must be a numeric matrix')
        end

        % make infostr %<<<2
        % convert matrix into text:
        matastext = mat2str(val);
        % remove leading '[' and closing ']':
        if numel(val) > 1
            % #fix: the [] are there only if 'val' has more than one item
            matastext = matastext(2:end-1);
        end
        % replace semicolons to newlines and spaces to semicolons:
        matastext = strrep(matastext, ';', NL);
        matastext = strrep(matastext, ' ', '; ');

        % add matrix to infostr:
        infostr = set_matrix('infosetmatrix', infostr, key, matastext, scell, true);
end

function [printusage, infostr, key, val, scell] = set_id_check_inputs(functionname, varargin) %<<<1
        % function identifies and partially checks inputs used in infoset* functions 
        % if printusage is true, infoset* function should call print_usage()
        %
        % input possibilities:
        %       key, val
        %       key, val, scell
        %       infostr, key, val
        %       infostr, key, val, scell

        printusage = false;
        infostr='';
        key='';
        val='';
        scell={};

        % check inputs %<<<2
        % (one input is functionname - in infoset* functions is not)
        if (nargin < 2+1 || nargin > 4+1)
                printusage = true;
                return
        end
        % identify inputs
        if nargin == 4+1
                infostr = varargin{1};
                key = varargin{2};
                val = varargin{3};
                scell = varargin{4};
        elseif nargin == 2+1;
                infostr = '';
                key = varargin{1};
                val = varargin{2};
                scell = {};
        else
                if iscell(varargin{3})
                        infostr = '';
                        key = varargin{1};
                        val = varargin{2};
                        scell = varargin{3};
                else
                        infostr = varargin{1};
                        key = varargin{2};
                        val = varargin{3};
                        scell = {};
                end
        end

        % check values of inputs infostr, key, scell %<<<2
        % input val have to be checked by infoset* function!
        if (~ischar(infostr) || ~ischar(key))
                error([functionname ': infostr and key must be strings'])
        end
        if isempty(key)
                error([functionname ': key is empty string'])
        end
        if (~iscell(scell))
                error([functionname ': scell must be a cell'])
        end
        if (~all(cellfun(@ischar, scell)))
                error([functionname ': scell must be a cell of strings'])
        end
end

function infostr = set_matrix(functionname, infostr, key, matastext, scell, indent) %<<<1
        % make info line from matastext and key and put it into a proper section (and subsections according scell)
        %
        % functionname - name of the main function for proper error generation after concatenating
        % infostr - info string with all data
        % key - key for a new matrix
        % matastext - matrix as a string
        % scell - cell of strings with name of section and subsections
        % indent - boolean true if shall do indentation
        %
        % function suppose all inputs are ok!

        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % number of spaces in indented section:
        if indent
                INDENT_LEN = 8;
        else
                INDENT_LEN = 0;
        end

        % add newline to beginning and to end:
        matastext = [NL matastext NL];
        % indent lines:
        matastext = strrep(matastext, NL, [NL repmat(' ', 1, INDENT_LEN)]);
        % remove indentation from last line:
        matastext = matastext(1:end-INDENT_LEN);

        % put matrix values between keys:
        matastext = sprintf('#startmatrix:: %s%s#endmatrix:: %s', key, matastext, key);

        % add new line to infostr according scell
        if isempty(scell)
                if isempty(infostr)
                        before = '';
                else
                        before = [deblank(infostr) NL];
                end
                infostr = [before matastext];
        else
                infostr = set_section('infosetnumber', infostr, matastext, scell, indent);
        end
end

function infostr = set_section(functionname, infostr, content, scell, indent) %<<<1
        % put content into a proper section (and subsections according scell)
        %
        % functionname - name of the main function for proper error generation after concatenating
        % infostr - info string with all data
        % content - what to put into the section
        % scell - cell of strings with name of section and subsections
        % indent - boolean true if shall do indentation
        %
        % function suppose all inputs are ok!
        
        % input is parsed?
        in_is_parsed = isstruct(infostr) && isfield(infostr,'this_is_infostring');
        % new stuff is parsed? 
        new_is_parsed = isstruct(content) && isfield(content,'this_is_infostring');
        
        % check parameter compatibility
        if new_is_parsed ~= in_is_parsed
                error(sprintf('%s: input inf-string and new content must be of the same type',functionname));
        end
        
        if in_is_parsed
                % --- PARSED INFO-STRING MODE ---
                
                % ###todo: implement recorusive insertion, so far it can just put stuff to global (not to subsections)
                
                if ~isempty(scell)
                        error(sprintf('%s: in parsed mode it can so far only insert data to global, not to subsections, sorry, too lazy...',functionname));                
                end
                
                try
                        sections = infostr.sections;
                        sec_names = infostr.sec_names;
                catch
                        sections = {};
                        sec_names = {};
                end
                
                try
                        scalars = infostr.scalars;
                        scalar_names = infostr.scalar_names;
                catch
                        scalars = {};
                        scalar_names = {};
                end
                
                try
                        matrix = infostr.matrix;
                        matrix_names = infostr.matrix_names;
                catch
                        matrix = {};
                        matrix_names = {};
                end
                
                %    all_parsed - true when mode 'all'
                %    matrix_parsed - true when mode 'all' or 'matrix'
                %    data - unparsed section content, note it is removed vhen mode is 'all'
                
                % merge info-strings
                infostr.sections = {sections{:} content.sections{:}};  
                infostr.sec_names = {sec_names{:} content.sec_names{:}};
                infostr.sec_count = numel(infostr.sections);                
                infostr.scalars = {scalars{:} content.scalars{:}};  
                infostr.scalar_names = {scalar_names{:} content.scalar_names{:}};
                infostr.scalar_count = numel(infostr.scalars);                
                infostr.matrix = {matrix{:} content.matrix{:}};  
                infostr.matrix_names = {matrix_names{:} content.matrix_names{:}};
                infostr.matrix_count = numel(infostr.matrix);
                infostr.all_parsed = 1;
                infostr.matrix_parsed = 1;
                infostr.this_is_infostring = 1;
                
        else
                % --- RAW INFO-STRING MODE ---
                
                % Constant with OS dependent new line character:
                % (This is because of Matlab cannot translate special characters
                % in strings. GNU Octave distinguish '' and "")
                NL = sprintf('\n');
        
                % number of spaces in indented section:
                if indent
                        INDENT_LEN = 8;
                else
                        INDENT_LEN = 0;
                end
        
                % make infostr %<<<2
                if (isempty(infostr) && length(scell) == 1)
                        % just simply generate info string
                        % add newlines to a content, indent lines by INDENT_LEN, remove indentation from last line:
                        spaces = repmat(' ', 1, INDENT_LEN);
                        content = [deblank(strrep([NL strtrim(content) NL], NL, [NL spaces])) NL];
                        % create infostr:
                        infostr = [infostr sprintf('#startsection:: %s%s#endsection:: %s', scell{end}, content, scell{end})];
                else
                        % make recursive preparation of info string
                        % find out how many sections from scell already exists in infostr:
                        position = length(infostr);
                        for i = 1:length(scell)
                                % through deeper and deeper section path
                                try
                                        % check section path scell(1:i):
                                        [tmp, position] = get_section(functionname, infostr, scell(1:i));
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
                                toinsert = set_section(functionname, '', content, scell(i+2:end), indent);
                        else
                                % else just use content with proper indentation:
                                spaces = repmat(' ', 1, i.*INDENT_LEN);
                                toinsert = [deblank(strrep([NL strtrim(content) NL], NL, [NL spaces])) NL];
                        end
                        % create main section if needed
                        if i < length(scell);
                                % simply generate section
                                % (here could be a line with sprintf, or subfunction can be used, but recursion 
                                % seems to be the simplest solution
                                toinsert = set_section(functionname, '', toinsert, scell(i+1), indent);
                                spaces = repmat(' ', 1, i.*INDENT_LEN);
                                toinsert = [deblank(strrep([NL strtrim(toinsert) NL], NL, [NL spaces])) NL];
                        end
                        toinsert = regexprep(toinsert, '^\n', '');
                        % create new infostr by inserting new part at proper place of old infostr:
                        infostr = deblank([before deblank(toinsert) NL infostrB]);
                end
        end
end

function [section, endposition] = get_section(functionname, infostr, scell) %<<<1
        % finds content of a section (and subsections according scell)
        %
        % functionname - name of the main function for proper error generation after concatenating
        % infostr - info string with all data (raw string or parsed struct)
        % scell - cell of strings with name of section and subsections
        %
        % function suppose all inputs are ok!

        if isstruct(infostr)
                % --- PARSED INFO-STRING ---
                
                % recoursive section search:
                for s = 1:numel(scell)
                
                        % look for subsection:
                        sid = find(strcmp(infostr.sec_names,scell{s}),1);
                        if isempty(sid)
                                error(sprintf('%s: subsection ''%s'' not found',functionname,scell{s}));
                        end
                        
                        % go deeper:
                        infostr = infostr.sections{sid};
                end
                
                % assing result
                section = infostr;
                
        else
                % --- RAW INFO-STRING ---                
                section = '';
                endposition = 0;
                if isempty(scell)
                        % scell is empty thus current infostr is required:
                        section = infostr;
                else
                        while (~isempty(infostr))
                                % search sections one by one from start of infostr to end
                                [S, E, TE, M, T, NM] = regexpi(infostr, ['#startsection\s*::\s*(.*)\s*\n(.*)\n\s*#endsection\s*::\s*\1'], 'once');
                                if isempty(T)
                                        % no section found
                                        section = '';
                                        break
                                else
                                        % some section found
                                        if strcmp(strtrim(T{1}), scell{1})
                                                % wanted section found
                                                section = strtrim(T{2});
                                                endposition = endposition + TE(end,end);
                                                break
                                        else
                                                % found section is not the one wanted
                                                if E < 2
                                                        % danger of infinite loop! this should never happen
                                                        error([functionname ': infinite loop happened!'])
                                                end
                                                % remove previous parts of infostr to start looking for 
                                                % wanted section after the end of found section:
                                                infostr = infostr(E+1:end);
                                                % calculate correct position that will be returned to user:
                                                endposition = endposition + E;
                                        end
                                end
                        end
                        % if nothing found:
                        if isempty(section)
                                error([functionname ': section `' scell{1} '` not found'])
                        end
                        % some result was obtained. if subsections are required, do recursion:
                        if length(scell) > 1
                                % recursively call for subsections:
                                tmplength = length(section);
                                [section, tmppos] = get_section(functionname, section, scell(2:end));
                                endposition = endposition - (tmplength - tmppos);
                        end
                end
        end
end

% --------------------------- tests: %<<<1
%!shared ismat, ismatcplx, ismatsec
%! ismat = sprintf('#startmatrix:: mat\n        1; 2; 3\n        4; 5; 6\n#endmatrix:: mat');
%! ismatcplx = sprintf('#startmatrix:: mat\n        1+3i; 2+3i\n#endmatrix:: mat');
%! ismatsec = sprintf('#startsection:: skey\n        #startmatrix:: mat\n                1; 2; 3\n                4; 5; 6\n        #endmatrix:: mat\n#endsection:: skey');
%!assert(strcmp(infosetmatrix( 'mat', [1:3; 4:6]                          ), ismat));
%!assert(strcmp(infosetmatrix( 'mat', [1 2]+3i                            ), ismatcplx));
%!assert(strcmp(infosetmatrix( 'mat', [1:3; 4:6], {'skey'}                ), ismatsec));
%!assert(strcmp(infosetmatrix( 'testtext', 'mat', [1:3; 4:6], {'skey'}     ), ['testtext' sprintf('\n') ismatsec]));
%!error(infosetmatrix('a'))
%!error(infosetmatrix(5, 'a'))
%!error(infosetmatrix('a', 'b'))
%!error(infosetmatrix('a', 5, 'd'))
%!error(infosetmatrix('a', 5, {5}))
%!error(infosetmatrix('a', 'b', 5, 'd'))
%!error(infosetmatrix('a', 'b', 5, {5}))
