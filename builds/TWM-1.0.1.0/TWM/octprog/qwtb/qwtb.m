function varargout = qwtb(varargin) 
% QWTB: Q-Wave Toolbox for data processing algorithms
%   alginfo = QWTB()
%       Gives informations on available algorithms.
%   dataout = QWTB('algid', datain, [calcset])
%       Apply algorithm with id `algid` to input data `datain` with calculation
%       settings `calcset`.
%   [] = QWTB('algid', 'example')
%       Runs example associated with algorithm 'algid'.
%   [] = QWTB('algid', 'test')
%       Runs test associated with algorithm 'algid'.
%   [] = QWTB('algid', 'addpath')
%   [] = QWTB('algid', 'rempath')
%       Add or remove algorithm path to a load path.
%   [license] = QWTB('algid', 'license')
%       Returns license of the algorithm.

% Copyright (c) 2015 by Martin Šíra

% 2DO rem all qwtb paths, add own, restore paths?
% 2DO what if path to alg_ already exist!?
% 2DO remove .par from datain on output

    % start of qwtb function --------------------------- %<<<1
    % remove old alg_paths because if previous instance of qwtb ends with error,
    % it could left some alg directory in the path
    path_rem_all_algdirs();
    % check inputs:
    if nargin == 0
        % returns all algorithms info
        varargout{1} = get_all_alg_info();

    elseif nargin == 1 || nargin > 3
        error(err_msg_gen(1)) % incorrect number of inputs!

    else
        algid = varargin{1};
        % check second argument for control string:
        if ischar(varargin{2});
            if strcmpi(varargin{2}, 'test')
                % run test of the algorithm
                run_alg_test(algid);
            elseif strcmpi(varargin{2}, 'example')
                % run example of the algorithm in user space
                run_alg_example(algid);
            elseif strcmpi(varargin{2}, 'addpath')
                % add algorithm path to path()
                path_add_algdir(algid);
            elseif strcmpi(varargin{2}, 'rempath')
                % remove algorithm path from path()
                path_rem_algdir(algid);
            elseif strcmpi(varargin{2}, 'info')
                % returns info on the algorithm
                varargout{1} = get_one_alg_info(algid);
            elseif strcmpi(varargin{2}, 'license')
                % show license of the algorithm
                varargout{1} = show_license(algid);
            else
                % unknown qwtb call
                error(err_msg_gen(2)); % incorrect second input argument!
            end % if strcmpi
        else
        % second argument is considered as input data:
            datain = varargin{2};
            if nargin == 2
                % calculation settings is missing, generate a standard one:
                calcset = get_standard_calcset();
            else
                calcset = varargin{3};
            end

            % process data:
            [dataout, datain, calcset] = check_and_run_alg(algid, datain, calcset);
            varargout{1} = dataout;
            varargout{2} = datain;
            varargout{3} = calcset;
        end % if ischar
    end % if - input arguments

end % end qwtb function

% -------------------------------- path related functions %<<<1
function pth = qwtbdirpath() %<<<1
% returns full path to the directory with qwtb script
    % get full path to this (qwtb.m) script:
    pth = fileparts(mfilename('fullpath'));

end % function qwtbdirpath

function pth = algpath(algid) %<<<1
% returns full path to the algorithm directory
    pth = [qwtbdirpath filesep() 'alg_' algid];
end % function algpath

function alginfo = get_all_alg_info() %<<<1
% checks for directories with algorithms and returns info on all available
% algorithms

    % XXX in this function, if there is only one directory alg_X, dir cannot
    % find it and nothing is returned. if there are at least 2 directories,
    % output is correct. It seems to be problem of dir function in octave
    % get directory listings:
    lis = dir([qwtbdirpath filesep() 'alg_*']);
    % get only directories:
    lis = lis([lis.isdir]);
    % prepare found algorithm counter:
    algcnt = 1;
    % for all directories
    for i = 1:size(lis,1)
        % generate full path of current tested algorithm directory:
        % maybe add algdir should be here !!! XXX
        algdir = [qwtbdirpath filesep() lis(i).name];
        if is_alg_dir(algdir)
            addpath(algdir);
            tmp = alg_info();
            tmp.fullpath = algdir;
            msg = check_alginfo(tmp);
            if isempty(msg)
                alginfo(algcnt) = tmp;
                algcnt = algcnt + 1;
            else
                warning(['QWTB: algorithm info returned by alg_info.m in `' algdir '` has incorrect format and is excluded from results'])
                disp(msg)
            end % if check_alginfo
            % maybe path_rem_algdir should be here!!! XXX
            rmpath(algdir);
        end % if is_alg_dir(algdir)
    end % for i = 1:size(lis,1)
    % following if is because of Matlab. It cannot assign algorithm info
    % structure (i.e. some existing structure) to an empty structure. Following
    % is to assure at least empty variable is assigned to an output.
    if ~exist('alginfo','var')
        alginfo = [];
    end
end % function get_all_alg_info

function res = get_one_alg_info(algid) %<<<1
% return info structure of one algorithm
        path_add_algdir(algid);
        tmp = alg_info();
        tmp.fullpath = algpath(algid);
        msg = check_alginfo(tmp);
        if isempty(msg)
            res = tmp;
        else
            warning(['QWTB: algorithm info returned by alg_info.m in `' algdir '` has incorrect format'])
            disp(msg)
        end % if check_alginfo
        path_rem_algdir(algid);
end % function get_one_alg_info


function res = is_alg_dir(pth) %<<<1
% checks if directory in pth is directory with algorithm, i.e. path exists
% and contains scripts alg_info and alg_wrapper
% returns boolean

    res = exist(pth,'dir') == 7;
    res = res && (exist([pth '/alg_info.m'], 'file') == 2);
    res = res && (exist([pth '/alg_wrapper.m'], 'file') == 2);

end % function is_alg_dir

function path_add_algdir(algid) %<<<1
% checks and adds path of algorithm to load path
    % check directory is algorithm directory:
    if ~is_alg_dir(algpath(algid))
            error(err_msg_gen(90, algid)) % algid not found!
    end
    % add wrapper to a load path:
    addpath(algpath(algid));
end % path_add_algdir

function path_rem_algdir(algid) %<<<1
% removes path of algorithm from load path
    % get full path to this (qwtb.m) script:
    algdir = algpath(algid);
    % pathsep is added because algdir could be only part of name of other
    % algdir, and path returns path without pathsep at the end, thus if algdir
    % would be last path, it would not be found
    if ~isempty(strfind([path pathsep], [algdir pathsep]))
        rmpath(algdir);
    end
end % path_rem_algdir

function path_rem_all_algdirs() %<<<1
% removes all alg directories from paths. if qwtb ends with error, it could left
% some alg directory in the path

    % get directory listings:
    lis = dir([qwtbdirpath filesep() 'alg_*']);
    % get only directories:
    lis = lis([lis.isdir]);
    % for all directories
    for i = 1:size(lis,1)
        % generate full path of current tested algorithm directory:
        algdir = [qwtbdirpath filesep() lis(i).name];
        if is_alg_dir(algdir)
            % pathsep is added because algdir could be only part of name of other
            % algdir, and path returns path without pathsep at the end, thus if algdir
            % would be last path, it would not be found
            if ~isempty(strfind([path pathsep], [algdir pathsep]))
                rmpath(algdir)
            end
        end % if is alg dir
    end % for all dirs
end % path_rem_all_algdirs


% -------------------------------- algorithm related functions %<<<1
function [dataout, datain, calcset] = check_and_run_alg(algid, datain, calcset) %<<<1
% checks data, settings and calls wrapper

    dataout = [];
    path_add_algdir(algid);
    % get info structure:
    alginfo = alg_info();
    % XXX when algorithm run, it is checked that algorithm exists, however it is
    % not checked that alginfo is correct. is it really needed here?

    % check calculation settings structure:
    calcset = check_gen_calcset(calcset);
    % check input data structure:
    datain = check_gen_datain(alginfo, datain, calcset);

    % all ok, call wrapper:
    % decide calculation mode:
    if strcmpi(calcset.unc, 'none') % no uncertainty, just calculate value: %<<<2
        if calcset.verbose
            disp('QWTB: no uncertainty calculation')
        end
        % calculate with specified algorithm:
        dataout = alg_wrapper(datain, calcset);
    elseif ( strcmpi(calcset.unc, 'guf') && not(alginfo.providesGUF) )
        % GUF required and cannot calculate GUF, raise error:
        error(err_msg_gen(91, alginfo.id));
    elseif ( strcmpi(calcset.unc, 'guf') && alginfo.providesGUF ) || ( strcmpi(calcset.unc, 'mcm') && alginfo.providesMCM )
        % uncertainty is calculated by algorithm or wrapper:
        if calcset.verbose
            disp('QWTB: uncertainty calculation by means of wrapper or algorithm')
        end
        dataout = alg_wrapper(datain, calcset);
    elseif strcmpi(calcset.unc, 'mcm') % MCM is calculated by general method: %<<<2
        if calcset.verbose 
            disp('QWTB: general mcm uncertainty calculation')
        end
        dataout = general_mcm(alginfo, datain, calcset);
    else
        % unknown settings of calcset.unc or algorithm. this shouldn't happen because calcset should be checked.
        error(err_msg_gen(-5, calcset.unc));
    end % if calcset.unc
    % remove algorithm path from path:
    path_rem_algdir(algid);
end % function check_and_run_alg

function run_alg_test(algid) %<<<1
    path_add_algdir(algid);
    if ~exist('alg_test.m','file')
        disp(['QWTB: self test of algorithm `' algid '` is not implemented']);
    else
        calcset = get_standard_calcset();
        calcset.verbose = 0;
        calcset.mcm.verbose = 0;
        alg_test(calcset);
    end % if exist
    path_rem_algdir(algid);
end % run_alg_test

function run_alg_example(algid) %<<<1
    path_add_algdir(algid);
    if ~exist('alg_example.m','file')
        disp(['QWTB: example of algorithm `' algid '` is not implemented']);
    else
        calcset = get_standard_calcset();
        % run example script in base workspace so user can operate with datain,
        % dataout and calcset:
        disp(['For description of example, please take a look at script `alg_' algid filesep 'alg_example.m`.']);
        disp('Take a look at data input structure `DI`, output data structure `DO` and optionally at calculation settings structure `CS`.')
        evalin('base', 'alg_example');
    end
    path_rem_algdir(algid);
end % run_alg_example function

function [license]= show_license(algid) %<<<1
% Display license of specified algorithm.
    % construct path to the license file:
    licfilpath = [algpath(algid) filesep 'LICENSE.txt'];
    % test for license file:
    if ~exist(licfilpath, 'file')
        error(err_msg_gen(92, licfilpath, algid)); % license file does not exist!
    else
        license = fileread(licfilpath);
    end
end % show_license function

function msg = check_alginfo(alginfo) %<<<1
% returns empty string if algorithm info structure complies to the qwtb format,
% else returns description of what is wrong

    % check number of fields %<<<2
    if ~(length(fieldnames(alginfo)) == 11)
        msg = 'some fields are missing or redundant';

    % check fields %<<<2
    elseif ~isfield(alginfo, 'id');
        msg = 'missing field `id`';
    elseif ~ischar(alginfo.id);
        msg = 'field `id` is not char type';
    elseif ~isfield(alginfo, 'name');
        msg = 'missing field `name`';
    elseif ~ischar(alginfo.name);
        msg = 'field `name` is not char type';
    elseif ~isfield(alginfo, 'desc');
        msg = 'missing field `desc`';
    elseif ~ischar(alginfo.desc);
        msg = 'field `desc` is not char type';
    elseif ~isfield(alginfo, 'citation');
        msg = 'missing field `citation`';
    elseif ~ischar(alginfo.citation);
        msg = 'field `citation` is not char type';
    elseif ~isfield(alginfo, 'remarks');
        msg = 'missing field `remarks`';
    elseif ~ischar(alginfo.remarks);
        msg = 'field `remarks` is not char type';
    elseif ~isfield(alginfo, 'license');
        msg = 'missing field `license`';
    elseif ~ischar(alginfo.license);
        msg = 'field `license` is not char type';

    % check inputs array:
    elseif ~isfield(alginfo, 'inputs');
        msg = 'missing field `inputs`';
    elseif ~isstruct(alginfo.inputs);
        msg = 'field `inputs` is not a structure';
    elseif ~isvector(alginfo.inputs);          % not isvectorP but isvector!
        msg = 'field `inputs` is not a scalar nor vector array';

    % check outputs array:
    elseif ~isfield(alginfo, 'outputs');
        msg = 'missing field `outputs`';
    elseif ~isstruct(alginfo.outputs);
        msg = 'field `outputs` is not a structure';
    elseif ~isvector(alginfo.outputs);          % not isvectorP but isvector!
        msg = 'field `outputs` is not a scalar nor vector array';

    elseif ~isfield(alginfo, 'providesGUF');
        msg = 'missing field `providesGUF`';
    elseif ~isfield(alginfo, 'providesMCM');
        msg = 'missing field `providesMCM`';
    elseif ~isfield(alginfo, 'fullpath');
        msg = 'missing field `fullpath`';
    elseif ~ischar(alginfo.fullpath);
        msg = 'field `fullpath` is not char type';
    else
        msg = '';
    end

    % check input quantities definitions %<<<2
    if isempty(msg)
            for i = 1:length(alginfo.inputs)
                    Q = alginfo.inputs(i);
                    if ~(length(fieldnames(Q)) == 5)
                        msg = ['some fields are missing or redundant in input quantity number ' num2str(i)];

                    % name
                    elseif ~isfield(Q, 'name');
                        msg = ['missing field `name` in input quantity number ' num2str(i)];
                    elseif isempty(Q.name);
                        msg = ['empty field `name` in input quantity number ' num2str(i)];
                    elseif ~ischar(Q.name);
                        msg = ['field `name` is not char type in input quantity `' Q.name '`'];

                    % desc
                    elseif ~isfield(Q, 'desc');
                        msg = ['missing field `desc` in input quantity `' Q.name '`'];
                    elseif isempty(Q.desc);
                        msg = ['empty field `desc` in input quantity `' Q.name '`'];
                    elseif ~ischar(Q.desc);
                        msg = ['field `desc` is not char type in input quantity `' Q.name '`'];

                    % alternative
                    elseif ~isfield(Q, 'alternative');
                        msg = ['missing field `alternative` in input quantity `' Q.name '`'];
                    elseif isempty(Q.alternative);
                        msg = ['empty field `alternative` in input quantity `' Q.name '`'];
                    elseif ~isnumeric(Q.alternative);
                        msg = ['field `alternative` is not numeric in input quantity `' Q.name '`'];
                    elseif ~isscalar(Q.alternative);
                        msg = ['field `alternative` is not scalar in input quantity `' Q.name '`'];

                    % optional
                    elseif ~isfield(Q, 'optional');
                        msg = ['missing field `optional` in input quantity `' Q.name '`'];
                    elseif isempty(Q.optional);
                        msg = ['empty field `optional` in input quantity `' Q.name '`'];
                    elseif ~isnumeric(Q.optional);
                        msg = ['field `optional` is not numeric in input quantity `' Q.name '`'];
                    elseif ~isscalar(Q.optional);
                        msg = ['field `optional` is not scalar in input quantity `' Q.name '`'];

                    % parameter
                    elseif ~isfield(Q, 'parameter');
                        msg = ['missing field `parameter` in input quantity `' Q.name '`'];
                    elseif isempty(Q.parameter);
                        msg = ['empty field `parameter` in input quantity `' Q.name '`'];
                    elseif ~isnumeric(Q.parameter);
                        msg = ['field `parameter` is not numeric in input quantity `' Q.name '`'];
                    elseif ~isscalar(Q.parameter);
                        msg = ['field `parameter` is not scalar in input quantity `' Q.name '`'];
                    end % if
            end % for i = length(alginfo.inputs)
    end % if isempty(msg)

    % check output quantities definitions %<<<2
    if isempty(msg)
            for i = 1:length(alginfo.outputs)
                    Q = alginfo.outputs(i);
                    if ~(length(fieldnames(Q)) == 2)
                        msg = ['some fields are missing or redundant in output quantity number ' num2str(i)];
                    % name
                    elseif ~isfield(Q, 'name');
                        msg = ['missing field `name` in output quantity number ' num2str(i)];
                    elseif ~ischar(Q.name);
                        msg = ['field `name` is not char type in output quantity `' Q.name '`'];

                    % desc
                    elseif ~isfield(Q, 'desc');
                        msg = ['missing field `desc` in output quantity `' Q.name '`'];
                    elseif ~ischar(Q.desc);
                        msg = ['field `desc` is not char type in output quantity `' Q.name '`'];
                    end % if
            end % for i = length(alginfo.inputs)
    end % if isempty(msg)

end % function check_alginfo

% -------------------------------- structures related functions %<<<1
function calcset = get_standard_calcset() %<<<1
% creates a standard calculation settings
    calcset.strict = 0;
    calcset.verbose = 1;
    calcset.unc = 'none';
    calcset.cor.req = 0;
    calcset.cor.gen = 1;
    calcset.dof.req = 0;
    calcset.dof.gen = 1;
    calcset.mcm.repeats = 100;
    calcset.mcm.verbose = 1;
    calcset.mcm.method = 'singlecore';
    calcset.mcm.procno = 0;
    calcset.mcm.tmpdir = '.';
    calcset.mcm.randomize = 1;
end % function get_standard_calcset

function calcset = check_gen_calcset(calcset) %<<<1
% Checks if calculation settings complies to the qwtb format. If .strict is set
% to 0, missing fields are generated. Boolean values are reformatted to 0/1.

    % strict %<<<2
    if ~( isfield(calcset, 'strict') )
        calcset.strict = 0;
    end
    % verbose %<<<2
    if ~( isfield(calcset, 'verbose') )
        if calcset.strict
            error(err_msg_gen(30)) % .verbose missing!
        else
            calcset.verbose = 1;
        end
    end
    if calcset.verbose
        calcset.verbose = 1;
    else 
        calcset.verbose = 0;
    end
    % unc %<<<2
    if ~( isfield(calcset, 'unc') )
        if calcset.strict
            error(err_msg_gen(31)) %.unc missing!
        else
            calcset.unc = 'none';
        end
    end
    if ~( strcmpi(calcset.unc, 'none') || strcmpi(calcset.unc, 'guf') || strcmpi(calcset.unc, 'mcm') )
        error(err_msg_gen(32)); % unc unkwnown value!
    end
    % cor %<<<2
    if ~( isfield(calcset, 'cor') )
        if calcset.strict
            error(err_msg_gen(33)); % cor is missing!
        else
            calcset.cor.req = 1;
            calcset.cor.gen = 1;
        end
    end
    % cor.req %<<<2
    if ~( isfield(calcset.cor, 'req') )
        if calcset.strict
            error(err_msg_gen(34)); %cor.req is missing!
        else
            calcset.cor.req = 1;
        end
    end
    if calcset.cor.req
        calcset.cor.req = 1;
    else
        calcset.cor.req = 0;
    end
    % cor.gen %<<<2
    if ~( isfield(calcset.cor, 'gen') )
        if calcset.strict
            error(err_msg_gen(35)); % cor.gen is missing!
        else
            calcset.cor.gen = 1;
        end
    end
    if calcset.cor.gen
        calcset.cor.gen = 1;
    else
        calcset.cor.gen = 0;
    end
    if ~( isfield(calcset, 'dof') )
        if calcset.strict
            error(err_msg_gen(36)); % dof is missing!
        else
            calcset.dof.req = 1;
            calcset.dof.gen = 1;
        end
    end
    % dof.req %<<<2
    if ~( isfield(calcset.dof, 'req') )
        if calcset.strict
            error(err_msg_gen(37)); % dof.req is missing!
        else
            calcset.dof.req = 1;
        end
    end
    if calcset.dof.req
        calcset.dof.req = 1;
    else
        calcset.dof.req = 0;
    end
    % dof.gen %<<<2
    if ~( isfield(calcset.dof, 'gen') )
        if calcset.strict
            error(err_msg_gen(38)); % dof.gen is missing!
        else
            calcset.dof.gen = 1;
        end
    end
    if calcset.dof.gen
        calcset.dof.gen = 1;
    else
        calcset.dof.gen = 0;
    end
    % mcm %<<<2
    if ~( isfield(calcset, 'mcm') )
        if calcset.strict
            error(err_msg_gen(39)); % mcm is missing!
        else
            calcset.mcm.repeats = 100;
            calcset.mcm.verbose = 1;
            calcset.mcm.method = 'singlecore';
            calcset.mcm.procno = 0;
            calcset.mcm.tmpdir = '.';
            calcset.mcm.randomize = 1;
        end
    end
    % mcm.repeats %<<<2
    if ~( isfield(calcset.mcm, 'repeats') )
        if calcset.strict
            error(err_msg_gen(40)); % mcm.repeats is missing!
        else
            calcset.mcm.repeats = 100;
        end
    end
    tmp = calcset.mcm.repeats;
    if ~(isscalarP(tmp) && tmp > 0 && abs(fix(tmp)) == tmp)
        error(err_msg_gen(41)); % mcm.repeats incorrect!
    end
    % mcm.verbose %<<<2
    if ~( isfield(calcset.mcm, 'verbose') )
        if calcset.strict
            error(err_msg_gen(42)); % mcm.verbose is missing!
        else
            calcset.mcm.verbose = 1;
        end
    end
    if calcset.mcm.verbose
        calcset.mcm.verbose = 1;
    else
        calcset.mcm.verbose = 0;
    end
    % mcm.method %<<<2
    if ~( isfield(calcset.mcm, 'method') )
        if calcset.strict
            error(err_msg_gen(43)); % mcm.method is missing!
        else
            calcset.mcm.method = 'singlecore';
        end
    end
    tmp = calcset.mcm.method;
    if ~( strcmpi(tmp, 'singlecore') || strcmpi(tmp, 'multicore') || strcmpi(tmp, 'multistation') )
        error(err_msg_gen(44)); % unknown mcm.method!
    end
    % mcm.procno %<<<2
    if ~( isfield(calcset.mcm, 'procno') )
        if calcset.strict
            error(err_msg_gen(45)); % mcm.procno is missing!
        else
            calcset.mcm.procno = 0;
        end
    end
    tmp = calcset.mcm.procno;
    if ~(isscalarP(tmp) && abs(fix(tmp)) == tmp)
        error(err_msg_gen(46)); % mcm.procno unknown value!
    end
    % mcm.tmpdir %<<<2
    if ~( isfield(calcset.mcm, 'tmpdir') )
        if calcset.strict
            error(err_msg_gen(47)); % mcm.tmpdir is missing!
        else
            calcset.mcm.tmpdir = '.';
        end
    end
    if ~( ischar(calcset.mcm.tmpdir) )
        error(err_msg_gen(48)); % mcm.tmpdir not a string!
    end
    if ~( exist(calcset.mcm.tmpdir, 'dir') )
        error(err_msg_gen(49, calcset.mcm.tmpdir)); % dir mcm.tmpdir does not exist!
    end
    % mcm.randomize %<<<2
    if ~( isfield(calcset.mcm, 'randomize') )
        if calcset.strict
            error(err_msg_gen(50)); % mcm.randomize is missing!
        else
            calcset.mcm.randomize = 1;
        end
    end
    if calcset.mcm.randomize
        calcset.mcm.randomize = 1;
    else
        calcset.mcm.randomize = 0;
    end
end % function check_gen_calcset

function datain = check_gen_datain(alginfo, datain, calcset) %<<<1
% Checks if input data has all quantities required by algorithm.
% Checks if input data complies to the qwtb data format.
% Raises error in the case of missing quantities or fields. Fields Q.d and Q.c
% are generated if permitted and required.

    % search for missing quantities in input data structure: %<<<2
    % parse requirements of the algorithm:
    [reqQ, reqQdesc, optQ, optQdesc, reqQG, reqQGdesc, optQG, optQGdesc, parQ, Qlist] = parse_alginfo_inputs(alginfo);
    % compare requirements with datain:
    errmsg = check_Q_present(datain, alginfo, reqQ, reqQdesc, reqQG, reqQGdesc);
    if ~isempty(errmsg)
        error(errmsg) % errmsg 93 (singular) or 94 (plural)
    end

    Qinnames = fieldnames(datain);
    % check individual quantities: %<<<2
    for i = 1:length(Qinnames)
        % for every quantity
        Qname = Qinnames{i};
        Q = datain.(Qname);

        % find if quantity is parameter. add field 'par' to the quantity. it is
        % usefull in other functions (and must be removed before handing it back
        % to user):
        Q.par = 0;
        if ~isempty(parQ)
            Q.par = any(strcmp(Qname, parQ));
        end % if ~isempty(parQ)

        % get which quantity components exist: %<<<3
        Isv = isfield(Q, 'v');
        Isu = isfield(Q, 'u');
        Isd = isfield(Q, 'd');
        Isc = isfield(Q, 'c');
        Isr = isfield(Q, 'r');

        % check if quantities are required: %<<<3
        % Q.v: %<<<4
        if ~(Isv) 
                error(err_msg_gen(60, Qname)); % .v is missing!
        end % is Q.v
        if ~Q.par
            % quantity is not parameter, so other fields are relevant
            % Q.u: %<<<4
            Genu = 0;
            if ~(Isu)
                if ~( strcmpi(calcset.unc, 'none') )
                        error(err_msg_gen(61, Qname)); % .u is missing!
                else
                    Genu = 1;
                end
            end % is Q.u
            % Q.d: %<<<4
            Gend = 0;
            if ~(isfield(Q, 'd'))
                if ( strcmpi(calcset.unc, 'guf') && calcset.dof.req )
                    % if guf uncertainty calculation and dof is required
                    if calcset.dof.gen
                        % degrees of freedom generated automatically
                        Gend = 2;
                    else
                        error(err_msg_gen(62, Qname)); % .d is missing!
                    end % if dof.gen
                else
                    Gend = 1;
                end % if guf & dof.req
            end % if Q.d
            % Q.c: %<<<4
            Genc = 0;
            if ~(isfield(Q, 'c'))
                if ( ~strcmpi(calcset.unc, 'none') && calcset.cor.req )
                    % if uncertainty calculation and correlation required
                    if calcset.cor.gen
                        Genc = 2;
                    else
                        error(err_msg_gen(63, Qname)); % .c is missing!
                    end
                else
                    Genc = 1;
                end % if unc & cor.req
            end % if Q.c
            % Q.r: %<<<4
            Genr = 0;
            if ~( isfield(Q, 'r') )
                if strcmpi(calcset.unc, 'mcm')
                    if ~( calcset.mcm.randomize )
                        error(err_msg_gen(64, Qname)); % .r is missing!
                    else
                        % randomize quantity:
                        Genr = 2;
                    end % if randomize
                else
                    Genr = 1;
                end % if mcm
            end % if Q.r

            % transpose vector quantity if needed: %<<<3
            if isvectorP(Q.v)
                if size(Q.v, 1) > size(Q.v, 2)
                    if calcset.verbose
                        warning(['QWTB: value of quantity `' Qname '` is column vector, it was automatically transposed.'])
                    end
                    Q.v = Q.v';
                end
                if Isu
                    if size(Q.u, 1) > size(Q.u, 2)
                        if calcset.verbose
                            warning(['QWTB: uncertainty of quantity `' Qname '` is column vector, it was automatically transposed.'])
                        end
                        Q.u = Q.u';
                    end
                end
                if Isd
                    if size(Q.d, 1) > size(Q.d, 2)
                        if calcset.verbose
                            warning(['QWTB: degrees of freedom of quantity `' Qname '` is column vector, it was automatically transposed.'])
                        end
                        Q.d = Q.d';
                    end
                end
                if Isr
                    if ( size(Q.v, 1) == size(Q.r, 2) || size(Q.v, 1) == size(Q.r, 2) )
                        if calcset.verbose
                            warning(['QWTB: randomized uncertainties of quantity `' Qname '` was automatically transposed.'])
                        end
                        Q.r = Q.r';
                    end
                end
            end % isvectorP(Q.v)

            % generate missing fields %<<<3
            % Q.u: %<<<4
            if Genu
                % generate empty field:
                Q.u = [];
            end
            % Q.d: %<<<4
            if Gend == 1
                % generate empty field:
                Q.d = [];
            end
            if Gend == 2
                if calcset.verbose
                    disp(['QWTB: default degrees of freedom generated for quantity `' Qname '`'])
                end
                Q.d = 50.*ones(size(Q.v));
            end
            % Q.c: %<<<4
            if Genc == 1
                % generate empty field:
                Q.c = [];
            end
            if Genc == 2
                if calcset.verbose
                    disp(['QWTB: default correlation matrix generated for quantity `' Qname '`'])
                end
                Q.c = zeros(length(Q.v), length(Q.v));
                % XXX previous line do not work for matrix Q!, this only works
                % for scalar and vector!!!
            end
            % Q.r: %<<<4
            if Genr == 1
                % generate empty field:
                Q.r = [];
            end
            if Genr == 2
                if calcset.verbose
                    disp(['QWTB: quantity ' Qname ' was randomized by QWTB']);
                end
                Q.r = rand_quant(Q, calcset.mcm.repeats, Qname);
            end

            % check components sizes: %<<<3
            Sv = size(Q.v);
            Su = size(Q.u);
            Sc = size(Q.c);
            Sd = size(Q.d);
            Sr = size(Q.r);

            % Q.v: %<<<4
            % check that maximal number of non trailing non singleton dimensions is 2:
            if ndims(Q.v) > 2
                error(err_msg_gen(65, Qname)); % .v too many dimensions!
            end
            % Q.u: %<<<4
            if ~( strcmpi(calcset.unc, 'none') )
                % dimensions must fully match Qname.v
                if ~isequal(Sv, Su)
                    error(err_msg_gen(66, Qname)); % .u dims not equal to .v dims!
                end
            end
            % Q.d: %<<<4
            if strcmpi(calcset.unc, 'guf') 
                if calcset.dof.req
                    % dimensions must fully match Qname.v
                    if ~isequal(Sv, Sd)
                        error(err_msg_gen(67, Qname)); % .d dims not equal to .v dims!
                    end
                end % if dof.req
            end % if guf
            % Q.c: %<<<4
            if (strcmpi(calcset.unc, 'guf') || strcmpi(calcset.unc, 'mcm') )
                if calcset.cor.req
                    % XXX how?
                    ok = 1;
                    if isscalarP(Q.v)
                        if ~isequal(Sv, Sc)
                            ok = 0;
                        end
                    elseif isvectorP(Q.v)
                        if ~( Sv(2) == Sc(2) && Sv(2) == Sc(1) )
                            ok = 0;
                        end
                    elseif ismatrixP(Q.v)
                        % XXX 2DO how?
                    else
                        % Qname has too many dimensions. This shouldn't happen, dimensions should be already tested!
                        error(err_msg_gen(-6, Qname));
                    end % if scalar/vector/matrix
                    if ~(ok)
                        error(err_msg_gen(68, Qname)); % .c incorrect dims!
                    end
                end % if cor.req
            end % if guf or mcm
            % Q.r: %<<<4
            if strcmpi(calcset.unc, 'mcm')
                % dimensions are same as Q.v but one dimension is equal calcset.mcm.repeats
                ok = 1;
                %%% if 
                %%%     if strcmpi(calcset.unc, 'mcm')
                %%%         % uncertainty must be randomized if general mcm will be
                %%%         % used.
                %%%         if calcset.mcm.randomize
                %%%             disp(['QWTB: quantity ' Qname ' is randomized']);
                %%%             datain.(Qname) = rand_quant(Q, calcset.mcm.repeats);
                %%%             Q = datain.(Qname);
                %%%         else
                %%%             error(XXX)['QWTB: quantity `' Qname '` is not randomized, but mcm is required and automatic randomization is disabled'])
                %%%         end % if mcm.randomize
                %%%     end % if mcm
                %%% else
                %%%     % not equal dimensions, therefore uncertainty matrix is probably
                %%%     % already randomized and prepared for monte carlo method
                if isscalarP(Q.v)
                    if ~( Sr(2) == Sv(2) && Sr(1) == calcset.mcm.repeats )
                        ok = 0;
                    end
                elseif isvectorP(Q.v)
                    if ~( Sr(2) == Sv(2) && Sr(1) == calcset.mcm.repeats )
                        ok = 0;
                    end
                elseif ismatrixP(Q.v)
                    if ~( Sr(1) == Sv(1) && Sr(2) == Sv(2) && Sr(3) == calcset.mcm.repeats )
                        ok = 0;
                    end
                else
                    % Qname has too many dimensions. This shouldn't happen, dimensions should be already tested!
                    error(err_msg_gen(-6, Qname));
                end % if scalar/vector/matrix
                if ~(ok)
                    error(err_msg_gen(69, Qname, calcset.mcm.repeats)); % .r incorrect dims;
                end
            end % if mcm 

        end % if ~Q.par
        % update datain structure: %<<<3
        datain.(Qname) = Q;
    end % for every Q
end % function check_gen_datain

function [reqQ, reqQdesc, optQ, optQdesc, reqQG, reqQGdesc, optQG, optQGdesc, parQ, Qlist] = parse_alginfo_inputs(alginfo) %<<<1
% parse requirements of the algorithm as stated in algorithm info structure
% returns:
% reqQ - cell of strings of names of required quantities
% reqQdesc - cell of strings of descriptions of reqQ
% optQ - cell of strings of names of optional quantities
% optQdesc - cell of strings of descriptions of optQ
% reqQG - cell of cell of strings of names of grouped quantities (one array
%       element is one group) in which at least one quantity is required, therefore
%       whole group is required
% reqQGdesc - cell of cell of strings of descriptions of reqQG
% optQG - cell of cell of strings of names of grouped quantities (one array
%       element is one group) in which all quantities are optional, therefore whole
%       group is optional
% optQGdesc - cell of cell of strings of descriptions of optQG
% parQ - cell of strings of names of parameter quantities (parameters)
% Qlist - cell with {x,1} names and {x,2} descriptions of all input quantities of algorithm, sorted by names of quantities

    reqQ = {};
    reqQdesc = {};
    optQ = {};
    optQdesc = {};
    tmpQG = {};
    tmpQGdesc = {};
    tmpQGopt = {};
    parQ = {};
    Qlist = {};

    for i = 1:length(alginfo.inputs)
        % for every input quantity
        Q = alginfo.inputs(i);
        % prepare list of Quantities:
        Qlist{i, 1} = Q.name;
        Qlist{i, 2} = Q.desc;
        if Q.alternative > 0
            % grouped quantity -> store name, description and optionality:
            tmpQG = add_to_coc(tmpQG, Q.alternative, Q.name);
            tmpQGdesc = add_to_coc(tmpQGdesc, Q.alternative, Q.desc);
            tmpQGopt = add_to_coc(tmpQGopt, Q.alternative, Q.optional);
        else
            % not-grouped quantity:
            if Q.optional
                % optional not-grouped quantity -> store name and description:
                optQ{end+1} = Q.name;
                optQdesc{end+1} = Q.desc;
            else
                % not-optional not-grouped quantity -> store name and
                % description:
                reqQ{end+1} = Q.name;
                reqQdesc{end+1} = Q.desc;
            end
        end % if Q.alternative > 0
        % check for parameter settings
        if Q.parameter
            parQ{end+1} = Q.name;
        end
    end % for every required quantity

    % check that no empty elements are in reqQG (Q.alternative is incremental by
    % one and e.g. 2, 5, 10). separate required and optional groups.
    reqQG = {};
    reqQGdesc = {};
    optQG = {};
    optQGdesc = {};
    for i = 1:length(tmpQG)
        if ~isempty(tmpQG{i}) % some groups numbers maybe do not exist
            % check optionality of group. if all required quantities in this
            % group are NOT optional -> group is NOT optional (and one of
            % quantities in group must be in input data)
            if all([tmpQGopt{i}{:}])
                optQG{end+1} = tmpQG{i};
                optQGdesc{end+1} = tmpQGdesc{i};
            else
                reqQG{end+1} = tmpQG{i};
                reqQGdesc{end+1} = tmpQGdesc{i};
            end % if all
        end % if isempty
    end % for i

    % sort list of Quantities by name:
    [tmp, ind] = sort(Qlist(:,1));
    ind = ind(:,1);
    Qlist = transpose({Qlist{ind,1}; Qlist{ind,2}});

    function coc = add_to_coc(coc, id1, value) %<<<2
    % Matlab (contrary to GNU Octave) cannot do this operation: c{N}{end+1} on
    % empty cell of cells (c = {}) or on non-initialized cell in a cell
    % (c={1:L}, L < N).
    % Therefore this stupid function/hack is required:
        if isempty(coc)
            tmp{1} = value;
            coc{id1} = tmp;
        elseif size(coc, 2) < id1;
            tmp{1} = value;
            coc{id1} = tmp;
        else
            coc{id1}{end+1} = value;
        end
    end

end % function parse_alginfo_inputs(alginfo)

function errmsg = check_Q_present(datain, alginfo, reqQ, reqQdesc, reqQG, reqQGdesc) %<<<1
% checks if quantities present in datain meet requirements according required,
% optional and grouped quantities
% if output is empty, all is ok, otherwise errmsg contains error message no. 93 (singular) or 94 (plural)

    % XXX here should be check if datain is not empty and is structure!
    % names of quantities in datain:
    Qinnames = fieldnames(datain);
    % string with missing quantities:
    missingQ = [];
    % count of missing Q:
    missingQno = 0;

    % check not-optional quantities are present in Qinnames (datain): %<<<2
    for i = 1:length(reqQ)
        if ~any(strcmp(reqQ{i}, Qinnames))
            % missing not-optional quantity, generate part of error message with missing quantity informations:
            missingQ = [missingQ sprintf('\n') '`' reqQ{i} '` - ' reqQdesc{i}];
            missingQno = missingQno + 1;
        end
    end

    % check one of required grouped quantities is present in Qinnames (datain): %<<<2
    for i = 1:length(reqQG)
        % for all quantity groups
        tmp = cellfun(@strcmpi, Qinnames, repmat({reqQG{i}}, length(Qinnames), 1), 'uniformoutput', 0);
        if ~any([tmp{:}])
            % not found, add error:
            missingQ = [missingQ sprintf('\n') 'one of following:'];
            for j = 1:length(reqQG{i})
                missingQ = [missingQ ' `' reqQG{i}{j} '`,'];
            end % for j
            missingQ = missingQ(1:end-1);
            missingQno = missingQno + 1;
        end % if ~any
    end % for i = 1:reqQG

    % generate error message %<<<2
    if ( missingQno ~= 0 )
        % some quantities missing, generate singular or plural version of error
        % message:
        if missingQno == 1
            errmsg = err_msg_gen(93, alginfo.id, missingQ);
        else
            errmsg = err_msg_gen(94, alginfo.id, missingQ);
        end
    else
        errmsg = '';
    end % if missingQno

end % function check_Q_present

function r = rand_quant(Q, M, Qname) %<<<1
% generates randomize quantity Q
    if isscalarP(Q.u)
        r = Q.v + Q.u.*randn(M, 1);
    elseif isvectorP(Q.u)
        % normrnd is not used to prevent need of matlab statistical toolbox:
        tmpv = repmat(Q.v, M, 1);
        tmpu = repmat(Q.u, M, 1);
        r = tmpv + tmpu.*randn(size(tmpu));
        % XXX but this generates 2 large matrices, and one large output. maybe
        % mvnrnd with zero covariancies would be more memory efficient?
        % 2 DO correlations - mvnrnd
    elseif ismatrixP(Q.u)
        % normrnd is not used to prevent need of matlab statistical toolbox:
        tmpv = repmat(Q.v, [1, 1, M]);
        tmpu = repmat(Q.u, [1, 1, M]);
        r = tmpv + tmpu.*randn(size(tmpu));
        % 2 DO correlations - mvnrnd
    else
        % Qname has too many dimensions. This shouldn't happen, dimensions should be already tested!
        error(err_msg_gen(-6, Qname));
    end % if scalar/vector/matrix
end % function rand_quant

function res = isscalarP(X) %<<<1
% Return true if X is a scalar in a physics sense. X is scalar if has two dimensions and both
% dimensions are equal to 1.

    S = size(X);
    res = (   length(S) == 2   &&   max(S) == min(S)   &&   min(S) == 1   );

end

function res = isvectorP(X) %<<<1
% Return true if X is a vector in a physics sense. X is vector if has two dimensions, one dimension
% is equal to one, the other dimension is greater than 1.

    S = size(X);
    res = (   length(S) == 2   &&   max(S) > min(S)   &&   min(S) == 1   );

end

function res = ismatrixP(X) %<<<1
% Return true if X is a matrix in a physics sense. X is matrix if has two dimensions and both
% dimensions are greater than 1.

    S = size(X);
    res = (   length(S) == 2   &&   max(S) >= min(S)   &&   min(S) > 1   );

end

% -------------------------------- general mcm functions %<<<1
function dataout = general_mcm(alginfo, datain, calcset) %<<<1
% Applies monte carlo method to an algorithm. It works generally, therefore all
% nuances of monte carlo method are not assured. All quantities should be
% already randomized in Q.u.

    method = calcset.mcm.method;
    M = calcset.mcm.repeats;
    isOctave = exist('OCTAVE_VERSION') ~= 0;

    % single core code --------------------------- %<<<2
    if strcmpi(method, 'singlecore') 
        for MCind = 1:M
            % following if/if section makes 20 s in total on Core i7 for M = 1e6
            if calcset.mcm.verbose
                if rem(MCind, 10000) == 0
                    disp(['QWTB: general mcm: ' num2str(MCind/1000) 'e3 iterations calculated']);
                end
            end
            % call wrapper 
            res(MCind) = call_alg(datain, calcset, MCind);
        end
    % multi core code --------------------------- %<<<2
    elseif strcmpi(method, 'multicore') 
        % 2 DO
        % dve moznosti - cellfun @ call_alg, s tim ze repmat(datain), ale to je
        % pametove narocne, nebo zkonstruovat unc_to_val, do cell a pustit
        % cellfun na algoritmus, ale zkonstruovani muze trvat - casove narocne.
        M = calcset.mcm.repeats;
        procno = calcset.mcm.procno;
        if calcset.mcm.procno < 1
            if isOctave
                procno = nproc;
            else
                % XXX does not work. however it is not relevant because matlab
                % doesn't know how to limit number of processors in parfor
                % probably parpool(procno) should be here. but only with
                % paralllel package?!
                procno = getenv('NUMBER_OF_PROCESSORS')
            end
        end % if procno < 1
        if isOctave
            % XXX where is rand and call?
            % 2DO maybe
            % f = @(in) alg_wrapper(in, calcset);
            % tmp = {datain};
            % tmp = repmat(datain, 1, M);
            % res = parcellfun(f, tmp);
            res = parcellfun(procno, @call_alg, repmat({datain}, 1, M), repmat({calcset}, 1, M), num2cell([1:M]));
        else
            parfor i = 1:M
                res(i) = call_alg(datain, calcset, i);
            end
        end
    % multi station code --------------------------- %<<<2
    elseif strcmpi(method, 'multistation') 
        % 2DO
    else
        % calcset.mcm.method has unknown value. this shouldn't happen, calcset is already checked:
        error(err_msg_gen(-7, method));
    end
        
    % concatenate data into output structure --------------------------- %<<<2
    % .v is created by mean of outputs
    % .u is created by std of outputs % XXX should be there scovint? see issue #4
    % .r is all outputs
    for i = 1:length(alginfo.outputs)
        % through all quantities which should be on the output:
        Qname = alginfo.outputs(i).name;
        rescell = [res.(Qname)];
        rescell = {rescell.v};

        % check all outputs has the same dimensions:
        tst = cellfun('ndims', rescell);
        if ~all(tst == tst(1))
            error(err_msg_gen(120, Qname, alginfo.id)); % different dimensions of algorithm outputs!
        end  % if not all tst
        for j = 1:tst(1)
            % for all dimensions
            tst2 = cellfun('size', rescell, j);
            if ~all(tst2 == tst2(1))
                error(err_msg_gen(121, Qname, alginfo.id)); % different sizes of algorithm outputs!
            end
        end % for all dimensions

        % preparation:
        if isempty(res(1).(Qname).v)
            % quantity is empty
            warning(['QWTB: output quantity `' Qname '` is empty'])
            dataout.(Qname).v = nan;
            dataout.(Qname).u = nan;
            dataout.(Qname).r = nan;
            dataout.(Qname).d = nan;
            dataout.(Qname).c = nan;
        elseif isscalarP(res(1).(Qname).v) == 1
            % quantity is scalar
            dataout.(Qname).v = mean([rescell{:}]);
            dataout.(Qname).u = std([rescell{:}]);
            dataout.(Qname).r = vertcat(rescell{:});
            dataout.(Qname).d = nan;
            dataout.(Qname).c = nan;
        elseif isvectorP(res(1).(Qname).v)
            % quantity is vector
            dataout.(Qname).v = mean(vertcat(rescell{:}));
            dataout.(Qname).u =  std(vertcat(rescell{:}));
            dataout.(Qname).r =      vertcat(rescell{:});
            dataout.(Qname).d = nan;
            dataout.(Qname).c = nan;
        elseif ismatrixP(res(1).(Qname).v)
            % quantity is matrix
            dataout.(Qname).v = mean(vertcat(rescell{:}), 1);
            dataout.(Qname).u =  std(vertcat(rescell{:}), 1);
            dataout.(Qname).r =      vertcat(rescell{:});
            dataout.(Qname).d = nan;
            dataout.(Qname).c = nan;
        else
            error(err_msg_gen(122, Qname, alginfo.id)); % output too many dims!
        end
    end % for concatenate
end % function

function dataout = call_alg(datain, calcset, MCind) %<<<1
% set quantity values and call algorithm

    % copy uncertainty to values for all required quantities:
    Qinnames = fieldnames(datain);
    for i = 1:length(Qinnames)
        % for all quantities
        if datain.(Qinnames{i}).par
            % quantity is parameter, just copy quantity:
            datain2.(Qinnames{i}) = datain.(Qinnames{i});
        else
            % quantity is not parameter, copy uncertainty to value:
            datain2.(Qinnames{i}) = unc_to_val(datain.(Qinnames{i}), MCind, Qinnames{i});
        end
    end % for i
    % disable calculation of uncertainty:
    calcset.unc = 'none';
    % call the algorithm:
    dataout = alg_wrapper(datain2, calcset);

end % function

function Qout = unc_to_val(Qin, MCind, Qname) %<<<1
% function copy values from randomized input uncertainty Qin.u to output value
% Qout.v and sets Qout.u and Qout.d to NaNs. Quantity name Qname is used for
% error message.
    if isscalarP(Qin.v)
        % quantity is scalar
        Qout.v = Qin.r(MCind);
        Qout.r = nan.*ones(size(Qin.v));
        Qout.d = [];
        Qout.c = [];
    elseif isvectorP(Qin.v)
        % quantity is vector
        Qout.v = Qin.r(MCind, :);
        Qout.r = nan.*ones(size(Qin.v));
        Qout.d = [];
        Qout.c = [];
    elseif ismatrixP(Qin.v)
        % quantity is matrix
        Qout.v = Qin.r(MCind, :, :);
        gout.r = nan.*ones(size(Qin.v));
        Qout.d = [];
        Qout.c = [];
    else
        % Qname has too many dimensions. This shouldn't happen, dimensions should be already tested!
        error(err_msg_gen(-6, Qname));
    end
%    % tohle by jenom melo presunout .u(i) do .v
%    if length(Qin.v) == 1
%        % randomizovat jen kdyz neni randomizovane, a to by mel
%        % resit nejaky kontrolor nejistot v datain
%        % XXX
%           % normrnd nemuze byt, protoze v zakladnim matlabu neni!
%        Qout.v = normrnd(Qin.v, Qin.u, [M 1]);
%    else
%        for i = 1:length(Qin.v)
%            % 2DO too slow, mvnrnd has to be used
%            % 2DO, other distributions
%            % 2DO, paralelize if no other possibility?
%           % normrnd nemuze byt, protoze v zakladnim matlabu neni!
%            Qout.v(:,i) = normrnd(Qin.v(i), Qin.u(i), [1 1]);
%        end
%    end
end % function

% -------------------------------- others %<<<1
function msg = err_msg_gen(varargin) %<<<1
    % generates error message, so all errors are at one place. after each
    % message a " QWTB err #X" is added, where X is number of error.
    % 2DO - condider generating an error structure with error ids and message so it can be try-catched.

    % groups of errors:
    % negative - QWTB internal errors:
    % just continued negative integer sequence
    % 0 - empty output (no error)
    % positive - user errors:
    %  1  -  29  base input errors
    % 30  -  59  CS errors
    % 60  -  89  datain errors
    % 90  - 119  algorithm errors
    % 120 - 149  general mcm errors

    % check inputs: %<<<2
    if (nargin < 1)
        errid = -1;
    else
        % error message number:
        errid = varargin{1};
        % check errid is scalar:
        if ~( size(errid, 1) == 1 && size(errid, 2) == 1 )
            errid = -2;
        end
        % check errid is integer number:
        if ~(errid == fix(errid) && isreal(errid));
            errid = -2;
        end
    end
    % common parts of error message: %<<<2
    % beginning of all errors:
    prefix = 'QWTB: ';
    % this is appended in the case of internal error:
    interr = ' This is QWTB internal error. This should not happen. Please report this bug.';
    % this is appended to all errors:
    suffix = [' QWTB error #' num2str(errid, '%03d') '|'];
    % %>>>2

    % select error message:
    try
        switch (errid)
            % ------------------- internal errors: %<<<2
            case -1
                msg = 'incorrect call of error handler: missing first argument';
            case -2
                msg = 'incorrect call of error handler: incorrect type of first argument.';
            case -3 % one input - errid - this error is used for recursion from this switch statement otherwise
                msg = ['unknown error number ' num2str(varargin{2}) '.'];
            case -4 % one input - errid - this error is used for recursion from this switch statement otherwise
                msg = ['insufficient number of input arguments for function err_msg_gen and QWTB error ' num2str(varargin{2}) '.'];
            case -5 % one input - calcset.unc
                msg = ['Unknown settings of .unc of calculation settings: `' varargin{2} '` or algorithm info structure concerning uncertainty calculation.'];
            case -6 % one input - Qname
                msg = ['Value of quantity `' varargin{2} '` has too many dimensions.'];
            case -7 % one input - calcset.unc.method
                msg = ['Unknown settings of .mcm.method of calculation settings: `' varargin{2} '`.'];
            % ------------------- base input errors 1-29: %<<<2
            case 1
                msg = 'Incorrect number of input arguments. Please read QWTB documentation.';
            case 2
                msg = 'Second argument must be either structure with input data or `test`, `example`, `info`, `license`, `addpath`, `rempath`. Please read QWTB documentation.';
            % ------------------- calculation settings errors 30-59: %<<<2
            case 30
                msg = 'Field `verbose` is missing in calculation settings structure. Please read QWTB documentation.';
            case 31
                msg = 'Field `unc` is missing in calculation settings structure. Plese read QWTB documentation.';
            case 32
                msg = 'Field `unc` of calculation settings structure has unknown value. Only `none`, `guf` and `mcm` are permitted. Plese read QWTB documentation.';
            case 33
                msg = 'Field `cor` is missing in calculation settings structure. Plese read QWTB documentation.';
            case 34
                msg = 'Field `cor.req` is missing in calculation settings structure. Plese read QWTB documentation.';
            case 35
                msg = 'Field `cor.gen` is missing in calculation settings structure. Plese read QWTB documentation.';
            case 36
                msg = 'Field `dof` is missing in calculation settings structure. Plese read QWTB documentation.';
            case 37
                msg = 'Field `dof.req` is missing in calculation settings structure. Plese read QWTB documentation.';
            case 38
                msg = 'Field `dof.gen` is missing in calculation settings structure. Plese read QWTB documentation.';
            case 39
                msg = 'Field `mcm` is missing in calculation settings structure. Plese read QWTB documentation.';
            case 40
                msg = 'Field `mcm.repeats` is missing in calculation settings structure. Plese read QWTB documentation.';
            case 41
                msg = 'Field `mcm.repeats` must be a scalar positive non-zero integer. Plese read QWTB documentation.';
            case 42
                msg = 'Field `mcm.verbose` is missing in calculation settings structure. Plese read QWTB documentation.';
            case 43
                msg = 'Field `mcm.method` is missing in calculation settings structure. Plese read QWTB documentation.';
            case 44
                msg = 'Field `mcm.method` in calculation settings has unknown value. Only values `singlecore`, `multicore` or `multistation` are permitted. Plese read QWTB documentation.';
            case 45
                msg = 'Field `mcm.procno` is missing in calculation settings structure. Plese read QWTB documentation.';
            case 46
                msg = 'Field `calcset.mcm.procno` must be a scalar zero or positive integer. Plese read QWTB documentation.';
            case 47
                msg = 'Field `mcm.tmpdir` is missing in calculation settings structure. Plese read QWTB documentation.';
            case 48
                msg = 'Field `mcm.tmpdir` must be a string. Plese read QWTB documentation.';
            case 49 % one input - calcset.mcm.tmpdif %XXX dif nebo dir? !!!
                msg = ['Directory `' varargin{2} '` specified in `mcm.tmpdir` in calculation settings structure does not exist. Plese read QWTB documentation.'];
            case 50
                msg = 'Field `mcm.randomize` is missing in calculation settings structure. Plese read QWTB documentation.';
            % ------------------- datain errors 60-89: %<<<2
            case 60 % one input - Qname
                msg = ['Field `v` (value) missing in quantity `' varargin{2} '`. Please read QWTB documentation.'];
            case 61 % one input - Qname
                msg = ['Field `u` (uncertainty) is missing in quantity `' varargin{2} '` and uncertainty calculation is required. Please read QWTB documentation.'];
            case 62 % one input - Qname
                msg = ['Field `d` (degrees of freedom) is missing in quantity `' varargin{2} '`, automatic generation is disabled but GUF uncertainty calculation is required. Please read QWTB documentation.'];
            case 63 % one input - Qname
                msg = ['Field `c` (correlation matrix) is missing in quantity `' varargin{2} '`, automatic generation is disabled but uncertainty calculation is required. Please read QWTB documentation.'];
            case 64 % one input - Qname
                msg = ['Field `r` (randomized uncertainties) is missing in quantity `' varargin{2} '`, automatic randomization is disabled but MCM uncertainty calculation is required. Please read QWTB documentation.'];
            case 65 % one input - Qname
                msg = ['Value matrix of quantity `' varargin{2} '` has too many dimensions. Please read QWTB documentation.'];
            case 66 % one input - Qname
                msg = ['Dimensions of uncertainty matrix do not match dimensions of value matrix of quantity `' varargin{2} '`. Please read QWTB documentation.'];
            case 67 % one input - Qname
                msg = ['Dimensions of degrees of freedom matrix do not match dimensions of value matrix of quantity `' varargin{2} '`. Please read QWTB documentation.'];
            case 68 % one input - Qname
                msg = ['Correlation matrix of quantity `' varargin{2} '` has incorrect dimensions. Please read QWTB documentation.'];
            case 69 % two inputs - Qname, calcset.mcm.repeats
                msg = ['Randomized values matrix of quantity `' varargin{2} '` has incorrect dimensions (calcset.mcm.repeats = ' num2str(varargin{3}) '). Please read QWTB documentation.'];
            % ------------------- algorithm errors 90-119: %<<<2
            case 90 % one input - algid
                msg = ['Algorithm `' varargin{2} '` not found. Please check available algorithms.'];
            case 91 % one input - algiid
                msg = ['Uncertainty calculation by GUF method required, but algorithm `' varargin{2} '` does not provide GUF uncertainty calculation. Please check algorithm documentation.'];
            case 92 % two inputs - licfilpath and algid
                msg = ['License file `' varargin{2} '` for algorithm `' varargin{3} '` does not exist. Please check installed files.'];
            case 93 % two inputs - alginfo.id, quantity
                msg = ['Followinq quantity is required by algorithm `' varargin{2} '` but missing in input data structure:' varargin{3} sprintf('\nPlease read Algorithm documentation.')];
            case 94 % two inputs - alginfo.id, quantities
                msg = ['Followinq quantities are required by algorithm `' varargin{2} '` but missing in input data structure:' varargin{3} sprintf('\n')];
            % ------------------- general mcm errors 120-149: %<<<2
            case 120 %  two inputs - Qname, algid
                msg = ['Output quantity `' varargin{2} '` generated by algorithm `' varargin{3} '` during general mcm has inconsistent number of dimensions. Please check algorithm functions or algorithm wrapper.'];
            case 121 %  two inputs - Qname, algid
                msg = ['Output quantity `' varargin{2} '` generated by algorithm `' varargin{3} '` during general mcm has inconsistent size. Please check algorithm functions or algorithm wrapper.'];
            case 122 %  two inputs - Qname, algid
                msg = ['Output quantity `' varargin{2} '` generated by algorithm `' varargin{3} '` during general mcm has too many dimensions. Please check algorithm functions or algorithm wrapper.'];
            otherwise
                msg = err_msg_gen(-3, errid);
        end %>>>2
    catch ERR
        % try to catch index out of bound error, i.e. not enough input arguments (varargin out of bounds):
        isOctave = exist('OCTAVE_VERSION') ~= 0;
        if isOctave
            if strcmpi(ERR.identifier, 'Octave:index-out-of-bounds')
                % throw internal QWTB error:
                msg = err_msg_gen(-4, errid);
            end
        else
            if (strcmpi(ERR.identifier,'MATLAB:badsubscript'))
                % throw internal QWTB error:
                msg = err_msg_gen(-4, errid);
            end
        end
    end
    % compose final error message:
    msg = [prefix msg];
    if (errid < 0)
        msg = [msg interr];
    end
    msg = [msg suffix];
    % make empty output for zero errid:
    if errid == 0
        msg = '';
    end
end % err_msg_gen
    
% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
