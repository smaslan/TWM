## Copyright (C) 2011 Martin Šíra
##

## -*- texinfo -*-
## @deftypefn {Function File} @var{res} = runmulticore (@var{method}, @var{funh}, @var{parc})
## @deftypefnx {Function File} runmulticore (@var{method}, @var{funh}, @var{parc}, @var{procno}, @var{tmpdir})
## @deftypefnx {Function File} runmulticore (@var{method}, @var{funh}, @var{parc}, @var{procno}, @var{tmpdir}, @var{verb})
## @deftypefnx {Function File} runmulticore (@var{method}, @var{funh}, @var{parc}, @var{procno}, @var{tmpdir}, @var{verb}, @var{opt})
## Evaluate a function by parallel computing on multiple cores or computers by means of either
## @emph{parallel} or @emph{multicore} Octave packages,
## or use serial computing. It enables to easly change between
## methods for easy debugging or running at different machines/Octaves
## with different installed packages. For now only one input and one output 
## of function defined in @var{funh} is possible.
## @table @var
## @item method
##    Set to 'cellfun' to use only serial calculation.
##    Set to 'parcellfun' to use function 'parcellfun' from package 'general.
##    Set to 'multicore' to use function 'startmulticoremaster' from package 'general.
## @item funh
##    Handle of the function to calculate (with at sign at the beginning).
## @item parc
##    Cell with parameters for function @var{funh}.
## @item procno
##    When specified, number of parallel processes will be limited. If ommited, set to 0, negative value or Inf, number of processes will be equal to number of local computer cores.
## @item tmpdir
##    When specified, temporary directory for function 'startmulticoremaster' will be set, otherwise temporary directory is given by octave function 'tempdir'. Not used for function 'parcellfun'.
## @item res
##    Cell of the same size as @var{parc} with all results.
## @item verb
##    Verbose level. If equal to zero, messages will be supressed. Set 2 to get all messages.
## @item opt
##    Structure with following fields:
##    @table @var
##    @item chunks_per_proc
##       (parcellfun only) Control the number of chunks which contains elementary jobs.  This option particularly useful when time execution of function is small.
##    @item run_master_only
##       (multicore only) Slave processes will not be started. Usefull if user needs to control running of octave processes with 'startmulticoreslave'.
##    @item min_chunk_size
##       (multicore only) Number of function evaluations gathered to a single job.
##    @item max_chunk_count
##       (multicore only) Limits maximum job files count. Has higher priority than parameter min_chunk_size. Use 0 if you don't want to use this (default).
##    @item master_is_worker
##       (multicore only) If true, master process acts as worker and coordinator, if false the master acts only as coordinator.
##    @item run_after_slaves
##       (multicore only) Handle to function that will be run after slaves have been started. The input parameter of the function will be vector with process ids of the slaves.
##    @end table
## @end table
##
## Example 1: compare calculation times. Note overhead when using multicore.
## @example
## paramcell = num2cell(repmat(1,10,1));
## tic; res=runmulticore('cellfun', @@mc_testfun, paramcell); toc
## tic; res=runmulticore('parcellfun', @@mc_testfun, paramcell); toc
## tic; res=runmulticore('multicore', @@mc_testfun, paramcell); toc
## @end example
##
## Example 2: more complex use. Take a look into directory './multicore' during calculation.
## @example
## paramcell = num2cell(repmat(1,10,1));
## opt.master_is_worker=false;
## res=runmulticore('multicore', @@mc_testfun, paramcell, 2, '', 2, opt);
## @end example
## @end deftypefn


## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2010
## Version: 1.4
## Keywords: cellfun parcellfun multicore
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: yes
##   Contains tests: yes
##   Contains demo: no
##   Checks inputs: partially
##   Optimized: N/A

function result=runmulticore(method, functionhandle, parametercell, procno, tmpdir, verbose, options)
        % check input arguments: --------------------------- %<<<1

        % correct number of arguments? %<<<2
        if (nargin < 3 || nargin > 7)
                print_usage();
        endif
        % correct first parameter? %<<<2
        if ~(strcmp(method,"cellfun") || strcmp(method,"parcellfun") || strcmp(method,"multicore"))
                error("parralel computing method not specified!");
        endif

        % does the required function exist? %<<<2
        if strcmp(method,"cellfun")
                if ~exist("cellfun")
                        error('function `cellfun` is missing, check installation')
                endif
        endif
        if strcmp(method,"parcellfun")
                if ~exist("parcellfun")
                        error('function `parcellfun` is missing, check if package parallel is installed')
                endif
        endif
        if strcmp(method,"multicore")
                if ~exist("startmulticoremaster")
                        error('function `startmulticoremaster` is missing, check if package multicore is installed')
                endif
        endif
        % verbose level specified? %<<<2
        if (nargin < 6)
                verbose=0;
        endif
        % temporary directory specified? %<<<2
        if (nargin < 5)
                tmpdir=tempdir;
        endif
        % number of processes specified? %<<<2
        if (nargin < 4)
                procno=inf;
        endif

        % determine number of processes: %<<<2
        if ( procno==inf || procno<1 )
                % detect number of cpus:
                cpus=nproc;
                % previous line doesn't work in octave 3.2, one have to use following:
                % if isunix
                        % % unix os
                        % pid = fopen("/proc/cpuinfo"); 
                        % procno = length(strfind(char(fread(pid)'),"processor")); 
                        % fclose(pid);
                % else 
                        % % expecting windows:
                        % [status output]=system("echo %number_of_processors%"); 
                        % procno=str2num(output);
                % endif
        endif

        % options default values: %<<<2
        ChunksPerProc = 1;
        OnlyMaster = 0;
        MinChunkSize = 1;
        MaxChunkCount = 0;
        MasterIsWorker = 1;
        run_after_slaves = '';
        userPaths = {};
        if (nargin == 7)
                if ~isstruct(options)
                        error('`options` must be a structure')
                endif
                if(isfield(options,'chunks_per_proc'))
                        ChunksPerProc = options.chunks_per_proc;
                endif
                if(isfield(options,'run_master_only'))
                        OnlyMaster = options.run_master_only;
                endif
                if(isfield(options,'min_chunk_size'))
                        MinChunkSize = options.min_chunk_size;
                endif
                if(isfield(options,'max_chunk_count'))
                        MaxChunkCount = options.max_chunk_count;
                endif
                if(isfield(options,'master_is_worker'))
                        MasterIsWorker = options.master_is_worker;
                endif
                if(isfield(options,'run_after_slaves'))
                        run_after_slaves = options.run_after_slaves;
                endif
                if(isfield(options,'user_paths'))
                        userPaths = options.user_paths;
                endif
        endif

        % calculate task: --------------------------- %<<<1
        % cellfun: --------------------------- %<<<2
        if strcmp(method,"cellfun")
                % use non parallel computing by means of cellfun:
                % XXX vadne pro vice vstupu, cell of cells se nerozlozi!:
                result=cellfun(functionhandle, parametercell, "UniformOutput", false);

        % parcellfun: --------------------------- %<<<2
        elseif strcmp(method,"parcellfun")
                % use package general and function parcellfun by J.Hajek:
                % XXX vadne pro vice vstupu, cell of cells se nerozlozi!:
                result=parcellfun(procno, functionhandle, parametercell, "VerboseLevel", verbose, "UniformOutput", false, "ChunksPerProc", ChunksPerProc);

        % multicore --------------------------- %<<<2
        elseif strcmp(method,"multicore")
                % use package multicore and function startmulticoremaster by Markus Buehren and Stanislav Maslan:
                % run slave processes: % ----------------------- %<<<3
                if (verbose > 1) disp('Starting background processes ...') endif
                if ~OnlyMaster
                        for i=1:procno-1
                                if isunix
                                        % make command starting octave, loading package multicore if needed and starting slave:
                                        command = ["octave-cli --eval \"" ...
                                                   "if ~exist(\'startmulticoreslave\'); pkg load multicore; endif; " ...
                                                   "startmulticoreslave(\'" tmpdir "\');" ...
                                                   "\""];
                                        % if (verbose > 1) disp(['Starting background process ' num2str(i) ' by command: ' command]) endif
                                        % stdout and stderr are sent to /dev/null, ampersand runs it in background, echo $! prints out process pid:
                                        [sout, stxt] = system([command " > /dev/null 2>&1 & echo $!"]);
                                        % readout pid:
                                        fidPid(i) = str2num(stxt);
                                        % if (verbose > 1) disp(['Pid is: ' num2str(fidPid(i))]) endif
                                else
                                        if (verbose > 1) disp(['Starting background process ' num2str(i) ' by command: ' command]) endif
                                        [fidIn(i), fidOut(i), fidPid(i)] = popen2 ("octave-cli", "-q");
                                        if (verbose > 1) disp(['Pid is: ' num2str(fidPid(i))]) endif
                                        input_str = ["if ~exist('startmulticoreslave'); pkg load multicore; endif; " ...
                                                     "startmulticoreslave('" tmpdir "');"];
                                        fputs (fidIn(i), input_str);
                                        fputs (fidIn(i), sprintf('\n'));
                                        % for windows try to set process priority to 
                                        % "below normal" otherwise windows would be unusable:
                                        syscmd = ['cmd /Q /C "wmic process where handle=' int2str(fidPid(i)) ' CALL SetPriority "Below Normal" "'];
                                        [sout,stxt] = system(syscmd);
                                endif
                        endfor
                endif % OnlyMaster

                % run user function after slaves have been started: % ----------------------- %<<<3
                if ~isempty(run_after_slaves)
                        if (verbose > 1) disp('Running user function:'); disp(run_after_slaves) endif
                        feval(run_after_slaves, fidPid, 0);
                        if (verbose > 1) disp('User function finished.') endif
                endif

                % run master % ----------------------- %<<<3
                % prepare settings structure:
                settings.nrOfEvalsAtOnce = MinChunkSize;
                settings.maxJobFiles = MaxChunkCount;
                settings.multicoreDir = tmpdir;    
                settings.masterIsWorker = MasterIsWorker;
                settings.moreTalk = verbose;
                settings.paths = userPaths;
                % run it:
                result = startmulticoremaster(functionhandle, parametercell, settings);

                % Close the secondary process % ----------------------- %<<<3
                % should be used: 
                % correctly should be: (doesn't work in octave 3.2):
                %pclose(fidPid(i))
                % else use following (leave zombies):
                if ~OnlyMaster
                        for i=1:procno-1
                                if(ispc())
                                        % windows - kill by system command, pclose() not yet implemented 
                                        syscmd=['taskkill /F /PID ' int2str(fidPid(i))];
                                        [sout,stxt] = system(syscmd);
                                else
                                        % kill octave processes immediately:
                                        [err, msg] = kill (fidPid(i), 9);
                                        % clear zombies by reading output status:
                                        % (cannot use 'WNOHANG, otherwise it is too 
                                        % fast and zombies stays in memory
                                        waitpid(fidPid(i));
                                endif
                        endfor % i
                endif % ~OnlyMaster
        endif
endfunction

% --------------------------- tests: %<<<1

%!shared i, parc, funh, procno, tmpdir, verbose, result
%! for i=1:10
%!      parc{i}=0.2;
%! endfor
%! funh=@mc_testfun;
%! procno=0;
%! tmpdir='.';
%! verbose=0;
%! result = {};
%! result=runmulticore('cellfun', funh, parc, procno, tmpdir, verbose);
%!assert(sum([result{:}]), sum([parc{:}]))
%! result = {};
%! result=runmulticore('parcellfun', funh, parc, procno, tmpdir, verbose);
%!assert(sum([result{:}]), sum([parc{:}]))
%! result = {};
%! result=runmulticore('multicore', funh, parc, procno, tmpdir, verbose);
%!assert(sum([result{:}]), sum([parc{:}]))

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
