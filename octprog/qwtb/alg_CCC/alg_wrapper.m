function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm CCC.
%
% See also qwtb

% How to select used model --------------------------- %<<<1
% Based on D114 of NEW04:
%   x is independent/explanatory variable
%   y is dependent/explained variable
%   e is error (of fit)
% Model 1:
%   multiple linear regression with independent and identically distributed zero
%   mean normal errors
% Model 1a:
%   y(i) = beta'.*x(i) + e(i);   i=1:N
%   x is with negligible/without uncertainty
%   y is known from measurement with uncertainty
%   e are all independent, has normal distribution of mean 0 and known variance
%   sigma^2 (sigma same for all e values)
% Model 1b:
%   as Model 1a, but errors e has unknown variance
% Model 2:
%   Model 1 with heteroscedasticity
% Model 2a:
%   y(i,j) = beta'.*x(i) + e(i,j);   i=1:N, j=1:M
%   x is with negligible/without uncertainty
%   y is known from measurement with uncertainty
%   e(i,j) are all independent, has normal distribution of mean 0 and known
%   variance sigma(i).^2 (sigma different for e values)
% Model 2b:
%   as Model 2a, but errors e has unknown variance
% Model 3:
%   general model with correlations
% Model 3a:
%   y(i) = beta'.*xc(i) + e(i);   i=1:N
%   x(i) = xc(i) + delta(i)
%   delta has multivariate normal distribution with known covariance matrix Vq
%   e has multivariate normal distribution with known covariance matrix Vk
% Model 3b:
%   as Model 3a, but unknown covariance matrices Vq and Vk

% Static variables  --------------------------- %<<<1
% algorithm related: %<<<2
% directory of this algorithm:
curalgdir = 'alg_CCC';
% possible exponents values accepted by CCC algorithm:
possibleexps = [-5 -4 -3 -2 -1 -0.5 0 0.5 1 2 3 4 5];

% executable and MCR: %<<<2
% unix executable:
unixbinary = ['./' curalgdir filesep 'run_CCC_SoftwareNoGUI.sh'];
% windows executable:
windowsbinary = [curalgdir filesep 'CCC_SoftwareNoGUI.exe'];
% file with path to matlab runtime
runtimepathfile = [curalgdir filesep 'path_to_matlab_runtime.txt'];
% required matlab Compiler Runtime version description:
mcr_ver = 'R2013a (8.1) 32-bit';
% general Matlab Compiler Runtime web address:
mcr_www = 'https://www.mathworks.com/products/compiler/mcr.html';
% required Matlab Compiler Runtime installer web address:
mcr_unix_inst_www = 'https://www.mathworks.com/supportfiles/MCR_Runtime/R2013a/MCR_R2013a_glnxa64_installer.zip';
mcr_win_inst_www = 'https://www.mathworks.com/supportfiles/MCR_Runtime/R2013a/MCR_R2013a_win32_installer.exe';
% required matlab Compiler Runtime dll for windows:
mcr_dll = 'mclmcrrt8_1.dll';

% source code handling: %<<<2
% directory of the source code if present:
src_code_dir = [curalgdir filesep 'CCC'];
% filename of source code main function:
src_code = [src_code_dir filesep 'CCC_SoftwareNoGUI.m'];

% error messages: %<<<2
% missing algorithm output:
msg_no_output = '1, Data was invalid.\n 2, MATLAB Compiler Runtime is not installed.';
% file with path to mcr is missing:
msg_unix_mcr_path_file_missing = sprintf('File `%s` not found!', runtimepathfile);
msg_unix_mcr_path_not_exist = sprintf('Directory with MATLAB Compiler Runtime not found! Following path was specified in file `%s`:', runtimepathfile);
% how to install MCR in unix:
msg_unix_install_mcr = sprintf('\n===========================================\nTo use a CCC in unix environment, one have to:\n1, install MATLAB Compiler Runtime version %s, see\n%s\nand\n%s\n2, create a text file named `%s` (i.e. placed in algorithm directory `%s`)\n3, write down path to the installed MATLAB Compiler Runtime into the text file `%s`.\n===========================================', mcr_ver, mcr_www, mcr_unix_inst_www, runtimepathfile, curalgdir, runtimepathfile);
% how to install MCR in windows:
msg_win_install_mcr = sprintf('\n============================================\nTo use a CCC in windows environment, one have to:\n1, install Matlab Compiler Runtime version %s, see\n%s\nand\n%s\n2, restart windows.\n============================================', mcr_ver, mcr_www, mcr_win_inst_www);

% Check the installation --------------------------- %<<<1
if exist(src_code, 'file')
    use_src_code = 1;
else
    use_src_code = 0;
    % check for matlab runtime libraries:
    if isunix
        if ~exist(runtimepathfile, 'file')
            error(sprintf('QWTB: CCC wrapper: %s\n%s', msg_unix_mcr_path_file_missing, msg_unix_install_mcr));
        end
        fid = fopen(runtimepathfile, 'r'); 
        runtimepath = fgetl(fid);
        fclose(fid);
        if ~exist(runtimepath, 'dir')
            error(sprintf('QWTB: CCC wrapper: %s\n%s', msg_unix_mcr_path_not_exist, msg_unix_install_mcr));
        end
    else
        % nothing required to do for windows, just try it.
    end
end

% Format input data --------------------------- %<<<1
% find if input data are multiple measurements, i.e. test if x is vector or
% matrix (i.e. user provided multiple datasets in rows):
if ( min(size(datain.y.v)) == 1 );
    multipledata = 0;
else
    multipledata = 1;
end

% select model: %<<<2
if isfield(datain, 'model')
    model = datain.model.v;
else
    if multipledata
        % models type b - groups. uncertainties of variables are neglected.
        % 2 or 3? XXX
        model = 'Model 2b';
        if calcset.verbose
            if isfield(datain.x, 'u') || isfield(datain.y, 'u')
                disp('QWTB: CCC wrapper: uncertainties of `x` and `y` are neglected for the selected model')
            end
        end
    else
        % models type a - no groups
        if all(datain.x.u == 0)
            if all(datain.y.u == datain.y.u(1))
                % all uncertainties of y are the same -> homoscedasticity
                % Model 1a
                model = 'Model 1a';
            else
                % uncertainties of y are different -> heteroscedasticity
                % Model 2a
                model = 'Model 2a';
                
            end
        else
            % Model 3a
            model = 'Model 3a';
        end
    end
    if calcset.verbose
        disp(['QWTB: CCC wrapper: model was set by CCC wrapper to a value `' model '`.'])
    end
end

% findout required exponents of polynomial: %<<<2
% round coefficients to prevent some float precision problems:
ex = round(datain.exponents.v.*10)./10;
% check if datain.exponents.v contains some not permitted exponents:
if ( length(intersect(possibleexps, ex)) < length(ex) )
    warning('QWTB: CCC wrapper: All exponents but following were ignored: -5, -4, -3, -2, -1, -0.5, 0, 0.5, 1, 2, 3, 4, 5.')
end
for i = 1:length(possibleexps)
    exponents(i) = any(ex == possibleexps(i));
end
% XXX
% % % % generate vector of booleans for required exponents:
% % % exponents = zeros(1,11);
% % % for i = -5:1:5
% % %     exponents(i+6) = any(ex == i);
% % % end
% % % exponents = [exponents(1:5) 0 exponents(6) 0 exponents(7:11)];
% % % % fractional exponents:
% % % if any(datain.exponents.v == -0.5)
% % %     exponents(6) = 1;
% % % end
% % % if any(datain.exponents.v == 0.5)
% % %     exponents(8) = 1;
% % % end

% set temporary file names: %<<<2
datafile = [curalgdir filesep 'tmp.txt'];
outputfile = [curalgdir filesep 'tmp.res'];
if exist(datafile, 'file') == 2
    delete(datafile);
end
if exist(outputfile, 'file') == 2
    delete(outputfile);
end

% save data into temporary data file: %<<<2
s = '';
s = [s infosettext('Data_x_tag', 'x')];
s = [s infosettext('Data_y_tag', 'y')];
if multipledata
    % convert matrix of multiple measurements to matrix required by CCC (i.e.
    % insert NaNs at correct places):
    tmp = [datain.x.v'; zeros(1,size(datain.x.v',2))+NaN];
    mat = tmp(:);
    tmp = [datain.y.v'; zeros(1,size(datain.y.v',2))+NaN];
    mat = [mat tmp(:)];
    % remove last unneeded line of NaN:
    mat = mat(1:end-1,:);
else
    mat = [datain.x.v(:) datain.y.v(:)];
end
s = [s infosetmatrix('Data_xy', mat)];
if multipledata
    s = [s infosetmatrix('Var_x', [])];
    s = [s infosetmatrix('Var_y', [])];
else
    if strcmpi(model, 'Model 1a')
        s = [s infosetmatrix('Var_y', datain.y.u(1).^2)];
    elseif strcmpi(model, 'Model 2a')
        s = [s infosetmatrix('Var_y', diag(datain.y.u(:).^2))];
    else
        s = [s infosetmatrix('Var_x', diag(datain.x.u(:).^2))];
        s = [s infosetmatrix('Var_y', diag(datain.y.u(:).^2))];
    end
end
fid = fopen(datafile, 'w'); 
fprintf(fid, '%s', s);
fclose(fid);

% Call algorithm ---------------------------  %<<<1
if use_src_code
    % source code will be used: %<<<2
    addpath(src_code_dir);
    [data, par, res] = CCC_SoftwareNoGUI(datafile, outputfile, model, exponents, 'NoHumanReadable', 'NoPlot');
    rmpath(src_code_dir);
else
    % no source code, suppose compiled executable file exist: %<<<2
    if isunix
        cmd = [unixbinary ' ' runtimepath];
    else
        % check 
        cmd = windowsbinary;
    end
    cmd = [cmd ' "' datafile '" "' outputfile '" "' model '" "[' num2str(exponents) ']" "NoHumanReadable" "NoPlot"'];
    [status, cmdout] = system(cmd);
end

% Check existence of output ---------------------------  %<<<1
if exist(outputfile, 'file') ~= 2
    % no output, explain why
    shellout = sprintf('\n\nIssued command:\n%s\nStatus of shell command:\n%d\nOutput from the command:\n%s', cmd, status, cmdout);
    if ~isunix
        % check for existence of MCR in windows:
        if ~exist_file_in_path_win(mcr_dll)
            msgbox(msg_win_install_mcr, 'Matlab Compiler Library is missing.')
            error(sprintf('QWTB: CCC wrapper: the Matlab Compiler Library is missing.\n%s', msg_win_install_mcr));
        end % ~exist_file_in_path_win
    end % if ~isunix
    if isunix
        tmp = msg_unix_install_mcr;
    else
        tmp = msg_unix_install_mcr;
    end % isunic
    error(sprintf('QWTB: CCC wrapper: the CCC software did not generated output.\n%s\n%s', msg_no_output, tmp))
else
    if ~use_src_code
        if calcset.verbose && ~isempty(cmdout)
            disp(sprintf('CCC: %s', cmdout))
        end
    end
end

% Format output data:  --------------------------- %<<<1
% load output file: %<<<2
fid = fopen(outputfile,'r');
[str,count] = fread(fid, [1,inf], 'uint8=>char');  % s will be a character array, count has the number of bytes
fclose(fid);

% set output data: %<<<2
dataout = [];
s = infogetsection(str, 'Results');
% coefficients: %<<<3
dataout.coefs.v = infogetmatrix(s, 'Coefficients (a to o)');
dataout.coefs.v = dataout.coefs.v(:);
dataout.coefs.u = infogetmatrix(s, 'Coefficient uncertainties (u(a) to u(o))');
dataout.coefs.u = dataout.coefs.u(:);
% covariance matrix:
covm = infogetmatrix(s, 'Covariance matrix associated with parameter estimates');
% calculate correlation matrix:
d = diag(dataout.coefs.u,0);
dataout.coefs.c = inv(d)*covm*inv(d);
% fitted values: %<<<3
dataout.yhat.v = infogetmatrix(s, 'Fitted values y');
dataout.yhat.v = dataout.yhat.v(:);
% covariance matrix:
covm = infogetmatrix(s, 'Covariance matrix associated with fitted values y');
% get uncertainties:
d = diag(covm).^0.5;
dataout.yhat.u = d(:);
% calculate correlation matrix:
d = diag(d, 0);
dataout.yhat.c = inv(d)*covm*inv(d);

% sorted exponents on the output: %<<<3
dataout.exponents.v = possibleexps(exponents == 1);
dataout.exponents.v = dataout.exponents.v(:);

% generate inline function: %<<<3
fin = '';
for i = 1:length(dataout.exponents.v)
    fin = [fin ' + p(' num2str(i) ').*x.^' num2str(dataout.exponents.v(i))];
end
dataout.func.v = inline(fin, 'x', 'p');

% used model: %<<<3
dataout.model.v = infogettext(s, 'Regression model');

end % function

function text = infogettext(infostr,key) %<<<1
% Copyright (C) 2013 Martin Šíra 
%
%
% -*- texinfo -*-
% @deftypefn {Function File} @var{text} = infogettext (@var{infostr}, @var{key})
% Parse info string @var{infostr}, finds line with content 'key:: value' and returns 
% the value as text.
%
% Whitecharacters can be before key, after key, before or after delimiter (::) or after key.
% Keys can contain any character but newline. Value can be anything but newline. Any text 
% can be inserted in between lines. Matrices are stored as semicolon delimited values, space
% characters are not important, however semicolon must be right after a numeric value. Sections
% are used e.g. for multiple keys with same values.
%
% Example:
% @example
% infostr='A:: a\n  B   ::    b \nC:: c1 \ncC:: c2 \nD:: 4 \nsome note \n  another note \nE([V?*.]):: e \n#startmatrix:: smallmat \n        1; 2; 3; \n   4;5;         6;  \n#endmatrix:: smallmat \n#startsection:: section 1 \n        D:: 44 \n#endsection:: section 1'
% infogettext(infostr,'E([V?*.])')
% @end example
% @end deftypefn
%
% Author: Martin Šíra <msiraATcmi.cz>
% Created: 2013
% Version: 1.5
% Script quality:
%   Tested: yes
%   Contains help: yes
%   Contains example in help: yes
%   Checks inputs: yes
%   Contains tests: yes
%   Contains demo: no
%   Optimized: yes
        % check inputs
        if (nargin~=2)
                print_usage()
        end

        if (~ischar(infostr) || ~ischar(key))
                error('infogettext: infostr and key must be strings')
        end

        % regexp for rest of line after a key:
        rol = '\s*::([^\n]*)';

        % first remove all sections, to prevent finding
        % key inside of some section
        while 1
                % fid key of some section:
                [S, E, TE, M, T, NM] = regexpi (infostr,['#startsection' rol], 'once');
                if isempty(T)
                        % no more keys, break loop
                        break
                else
                        seckey = strtrim(T{1});
                        % escape characters:
                        seckey = regexpescape(seckey);
                        % find whole section:
                        [S, E, TE, M, T, NM] = regexpi (infostr,['#startsection\s*::\s*' seckey '.*' '#endsection\s*::\s*' seckey], 'once');
                        % remove section from string:
                        infostr = [infostr(1:S-1) infostr(E+1:end)];
                end
                % this is infinite loop, however in every loop 
                % reduction of str should happen, therefore 
                % loop should end every time, hopefully...
        end

        %remove leading spaces of key:
        key = strtrim(key);
        % escape characters:
        key = regexpescape(key);
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

function mat = infogetmatrix(infostr, key) %<<<1
% Copyright (C) 2013 Martin Šíra 
%
%
% -*- texinfo -*-
% @deftypefn {Function File} @var{matrix} = infogetmatrix (@var{infostr}, key)
% Parse info string @var{infostr}, finds lines between lines #startmatrix:: key and 
% #endmatrix:: key, parse data and returns matrix of numbers separeted by
% semicolons.
%
% Whitecharacters can be before key, after key, before or after delimiter (::) or after key.
% Keys can contain any character but newline. Value can be anything but newline. Any text 
% can be inserted in between lines. Matrices are stored as semicolon delimited values, space
% characters are not important, however semicolon must be right after a numeric value. Sections
% are used e.g. for multiple keys with same values.
%
% Example:
% @example
% infostr='A:: a\n  B   ::    b \nC:: c1 \ncC:: c2 \nD:: 4 \nsome note \n  another note \nE([V?*.]):: e \n#startmatrix:: smallmat \n        1; 2; 3; \n   4;5;         6;  \n#endmatrix:: smallmat \n#startsection:: section 1 \n        D:: 44 \n#endsection:: section 1'
% infogetmatrix(infostr,'smallmat')
% @end example
% @end deftypefn
%
% Author: Martin Šíra <msiraATcmi.cz>
% Created: 2013
% Version: 1.5
% Script quality:
%   Tested: yes
%   Contains help: yes
%   Contains example in help: yes
%   Checks inputs: yes
%   Contains tests: yes
%   Contains demo: no
%   Optimized: N/A
        % check inputs
        if (nargin~=2)
                print_usage()
        end

        if (~ischar(infostr) || ~ischar(key))
                error('infogetmatrix: infostr and key must be strings')
        end

        % first find section with matrix:

        key = strtrim(key);
        % escape characters of regular expression special meaning:
        key = regexpescape(key);

        [S, E, TE, M, T, NM] = regexpi (infostr,['#startmatrix\s*::\s*' key '(.*)' '#endmatrix\s*::\s*' key], 'once');
        if isempty(T)
                error(['infogetmatrix: matrix named `' key '` not found'])
        end
        infostr=strtrim(T{1});

        errorline = 'infogetmatrix: empty matrix found';

        % get first line to determine number of columns of the matrix:
        s = strsplit(infostr,sprintf('\n'));
        if isempty(s)
                error(errorline);
        end
        s = s{1,1};
        mat = sscanf(s,'%f;',Inf);
        cols = length(mat);
        if (cols < 1)
                error(errorline);
        end
        % get the full matrix:
        s = infostr(infostr ~= sprintf('\n'));
        mat = sscanf(s,'%f;',Inf);
        if ( mod(length(mat),cols) || length(mat)./cols < 1 )
                error(errorline);
        end
        mat = reshape(mat,cols,length(mat)./cols);
        mat = mat';
end


function key = regexpescape(key) %<<<1
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

function infostr = infosetmatrix(key, val) %<<<1
% Copyright (C) 2014 Martin Šíra 
%
%
% -*- texinfo -*-
% @deftypefn {Function File} @var{infostr} = infosetmatrix (@var{key}, @var{val})
% Returns info string with numeric matrix formatted in following format:
% @example
% #startmatrix:: key
%         val(1,1); val(1,2); val(1,3);
%         val(2,1); val(2,2); val(2,3);
% #endmatrix:: key
% @end example
%
% Example:
% @example
% infosetmatrix('smallmat', [1:3; 4:6])
% @end example
% @end deftypefn
%
% Author: Martin Šíra <msiraATcmi.cz>
% Created: 2014
% Version: 1.3
% Script quality:
%   Tested: yes
%   Contains help: yes
%   Contains example in help: yes
%   Checks inputs: yes
%   Contains tests: no
%   Contains demo: no
%   Optimized: N/A
        % check inputs
        if (nargin~=2)
                print_usage()
        end

        if ~ischar(key)
                error('infosetmatrix: key must be string')
        end

        if (~ismatrix(val) || ~isnumeric(val))
                error('infosetmatrix: val must be a numeric matrix')
        end

        % format values
        val = sprintf([repmat(' %.20e;', 1, size(val, 2)) '\n'], val');

        % add newline to beginning:
        val = [sprintf('\n') val];
        % indent lines:
        val = strrep(val, sprintf('\n'), [sprintf('\n') '        ']);
        % remove indentation from last line:
        val = val(1:end-8);

        % put matrix values between keys:
        infostr = sprintf('#startmatrix:: %s%s#endmatrix:: %s\n', key, val, key);

end

function infostr = infosetnumber(key,val) %<<<1
% Copyright (C) 2014 Martin Šíra 
%
%
% -*- texinfo -*-
% @deftypefn {Function File} @var{infostr} = infosetnumber (@var{key}, @var{val})
% Returns info string with key @var{key} and numeric value @var{val} in following format:
% @example
% key:: val
%
% @end example
%
% Example:
% @example
% infosetnumber('voltage',5)
% @end example
% @end deftypefn
%
% Author: Martin Šíra <msiraATcmi.cz>
% Created: 2014
% Version: 1.4
% Script quality:
%   Tested: yes
%   Contains help: yes
%   Contains example in help: yes
%   Checks inputs: yes
%   Contains tests: no
%   Contains demo: no
%   Optimized: N/A
        % check inputs
        if (nargin~=2)
                print_usage()
        end

        if (~ischar(key))
                error('infosetnumber: key must be string')
        end

        if (~isscalar(val) || ~isnumeric(val))
                error('infosetnumber: val must be a numeric scalar')
        end

        if (val == fix(val))
                % value is integer:
                infostr = sprintf('%s:: %d\n', key, val);
        else
                infostr = sprintf('%s:: %.20e\n', key, val);
        end
end

function infostr = infosettext(key,val) %<<<1
% Copyright (C) 2014 Martin Šíra 
%
%
% -*- texinfo -*-
% @deftypefn {Function File} @var{infostr} = infosettext (@var{key}, @var{val})
% Returns info string with key @var{key} and text value @var{val} in following format:
% @example
% key:: val
%
% @end example
%
% Example:
% @example
% infosettext('type','voltmeter')
% @end example
% @end deftypefn
%
% Author: Martin Šíra <msiraATcmi.cz>
% Created: 2014
% Version: 1.3
% Script quality:
%   Tested: yes
%   Contains help: yes
%   Contains example in help: yes
%   Checks inputs: yes
%   Contains tests: no
%   Contains demo: no
%   Optimized: N/A
        % check inputs
        if (nargin~=2)
                print_usage()
        end

        if (~ischar(key) || ~ischar(val))
                error('infosettext: key and val must be strings')
        end

        infostr = sprintf('%s:: %s\n', key, val);
end

function section = infogetsection(infostr, key) %<<<1
% Copyright (C) 2013 Martin Šíra 
%
%
% -*- texinfo -*-
% @deftypefn {Function File} @var{section} = infogetsection (@var{infostr}, @var{key})
% Parse info string @var{infostr} and returns lines preceded by line with content
% "#startsection:: key" and succeeded by line "#endsection:: key".
%
% Whitecharacters can be before key, after key, before or after delimiter (::) or after key.
% Keys can contain any character but newline. Value can be anything but newline. Any text 
% can be inserted in between lines. Matrices are stored as semicolon delimited values, space
% characters are not important, however semicolon must be right after a numeric value. Sections
% are used e.g. for multiple keys with same values.
%
% Example:
% @example
% infostr="A:: a\n  B   ::    b \nC:: c1 \ncC:: c2 \nD:: 4 \nsome note \n  another note \nE([V?*.]):: e \n#startmatrix:: smallmat \n        1; 2; 3; \n   4;5;         6;  \n#endmatrix:: smallmat \n#startsection:: section 1 \n        D:: 44 \n#endsection:: section 1"
% infogetnumber(infogetsection(infostr,'section 1'), 'D')
% @end example
% @end deftypefn
%
% Author: Martin Šíra <msiraATcmi.cz>
% Created: 2013
% Version: 1.5
% Script quality:
%   Tested: yes
%   Contains help: yes
%   Contains example in help: yes
%   Checks inputs: yes
%   Contains tests: yes
%   Contains demo: no
%   Optimized: yes

        % check inputs
        if (nargin~=2)
                print_usage()
        end

        if (~ischar(infostr) || ~ischar(key))
                error('infogetsection: str and key must be strings')
        end

        key = strtrim(key);
        % escape characters of regular expression special meaning:
        key = regexpescape(key);

        [S, E, TE, M, T, NM] = regexpi (infostr,['#startsection\s*::\s*' key '(.*)' '#endsection\s*::\s*' key], 'once');
        if isempty(T)
                error(['infogetsection: section `' key '` not found'])
        end
        section=strtrim(T{1});
end

function B = exist_file_in_path_win(filename) %<<<1
    % checks if file 'filename' exists in any directory specified in Windows variable PATH
    % filename = 'mclmcrrt8_1.dll';
    B = 0;
    [status, output] = system('PATH');
    [S, E, TE, M, T, NM, SP] = regexpi (output, 'PATH=')
    % remove path=
    [pths] = strsplit(output(E(1)+1:end), pathsep);
    for i = 1:length(pths)
            file = [pths{i} filesep filename];
            if exist(file, 'file')
                    B = 1;
                    return
            end
    end % for i
end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
