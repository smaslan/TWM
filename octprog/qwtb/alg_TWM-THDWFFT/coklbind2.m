## Copyright (C) 2018 Martin Šíra
##

## -*- texinfo -*-
## @deftypefn {Function File} coklbind2 (@var{pids}, [@var{verbose}])
## Assigns processes to free cores. Usefull only on supercomputer cokl.
## First a `numabind` is run to find free cores. Next `taskset` is used to 
## assign processes with process ids @var{pids} to a free cores.
## @var{verbose} is verbosity level.
##

## Author: Martin Šíra <msiraATcmi.cz>
## Created: 2018
## Version: 0.1
## Keywords: cellfun parcellfun multicore
## Script quality:
##   Tested: yes
##   Contains help: yes
##   Contains example in help: no
##   Contains tests: no
##   Contains demo: no
##   Checks inputs: no
##   Optimized: no

function coklbind2(pids, verbose = 0)
        pause(1)
        procno = length(pids);
        if verbose disp(['Number of processes to assign: ' num2str(procno)]) endif

        % ask numabind for empty cores:
        command = ["numabind --offset " num2str(procno) " --flags=best 2>/dev/null"];
        [sstat, sout] = system(command);
        
        freecores = str2num(sout);
        if verbose
                disp('List of free cores:')
                disp(freecores)
        endif

        % check that freecores are sensfull numbers:
        if ~all(freecores > 0)
                error('Free cores are strange numbers!')
        endif
        if length(freecores) < procno
                error('Not enough empty cores!')
        endif

        for i = 1:procno
                command = ["taskset -pc " num2str(freecores(i)) " " num2str(pids(i))];
                [sstat, sout] = system(command);
        endfor
endfunction

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
