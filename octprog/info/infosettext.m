function infostr = infosettext(varargin)%<<<1
% -- Function File: INFOSTR = infosettext (KEY, VAL)
% -- Function File: INFOSTR = infosettext (KEY, VAL, SCELL)
% -- Function File: INFOSTR = infosettext (INFOSTR, KEY, VAL)
% -- Function File: INFOSTR = infosettext (INFOSTR, KEY, VAL, SCELL)
%     Returns info string with key KEY and text VAL in following format:
%          key:: val
%
%     If SCELL is set, the key/value is enclosed by section(s) according
%     SCELL.
%
%     If INFOSTR is set, the key/value is put into existing INFOSTR
%     sections, or sections are generated if needed and properly
%     appended/inserted into INFOSTR.
%
%     Example:
%          infosettext('key', 'value')
%          infostr = infosettext('key', 'value', {'section key', 'subsection key'})
%          infosettext(infostr, 'other key', 'other value', {'section key', 'subsection key'})

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
        %       key, val, scell
        %       infostr, key, val
        %       infostr, key, val, scell

        % Constant with OS dependent new line character:
        % (This is because of Matlab cannot translate special characters
        % in strings. GNU Octave distinguish '' and "")
        NL = sprintf('\n');

        % check inputs %<<<2
        if (nargin < 2 || nargin > 4)
                print_usage()
        end
        % identify inputs
        if nargin == 4
                infostr = varargin{1};
                key = varargin{2};
                val = varargin{3};
                scell = varargin{4};
        elseif nargin == 2;
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
        % check values of inputs
        if (~ischar(infostr) || ~ischar(key) || ~ischar(val))
                error('infosettext: infostr, key and val must be strings')
        end
        if (~iscell(scell))
                error('infosettext: scell must be a cell')
        end
        if (~all(cellfun(@ischar, scell)))
                error('infosettext: scell must be a cell of strings')
        end

        % make infostr %<<<2
        % generate new line with key and val:
        newline = sprintf('%s:: %s', key, val);
        % add new line to infostr according scell
        if isempty(scell)
                if isempty(infostr)
                        before = '';
                else
                        before = [deblank(infostr) NL];
                end
                infostr = [before newline];
        else
                infostr = infosetsection(infostr, newline, scell);
        end
end

% --------------------------- tests: %<<<1
%!shared istxt, iskey, iskeydbl
%! istxt = 'key:: val';
%! iskey = sprintf('#startsection:: skey\n        key:: val\n#endsection:: skey');
%! iskeydbl = sprintf('#startsection:: skey\n        key:: val\n        key:: val\n#endsection:: skey');
%!assert(strcmp(infosettext( 'key', 'val'                               ), istxt));
%!assert(strcmp(infosettext( 'key', 'val', {'skey'}                     ), iskey));
%!assert(strcmp(infosettext( iskey, 'key', 'val'                        ), [iskey sprintf('\n') istxt]));
%!assert(strcmp(infosettext( iskey, 'key', 'val', {'skey'}              ), iskeydbl));
%!error(infosettext('a'))
%!error(infosettext(5, 'a'))
%!error(infosettext('a', 5))
%!error(infosettext('a', 'b', 5))
%!error(infosettext('a', 'b', {5}))
%!error(infosettext('a', 'b', 'c', 'd'))
%!error(infosettext('a', 'b', 'c', {5}))

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
