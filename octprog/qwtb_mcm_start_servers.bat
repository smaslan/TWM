rem - USAGE: qwtb_mcm_start_servers.bat octave_bin_folder octave_exe cores_count jobs_sharing_folder_path
@ECHO OFF
title="GNU Octave multicore console"

REM ==== SETUP ====

REM --- Cores count ---
SET /a CORE_N=%3

REM --- GNU Octave path ---
SET OCT_FLD=%1
SET OCT_NAME=%2

REM --- Job share folder ---
SET SHARE_PATH=%4

REM --- Options ---
SET OPT=/BELOWNORMAL

REM --- Set this script priority ---
wmic process where name="cmd.exe" CALL SetPriority "Below Normal"

REM ==== RUN SERVERS ====
SET FUNC_NAME=run_mc_slave("'%SHARE_PATH%'")
SET /a i=0
:loop
START "GNU Octave - multicore server #%i%" /D "%OCT_FLD%" %OPT% "%OCT_NAME%" -q -p "%CD%" --exec-path "%CD%" --eval %FUNC_NAME% --persist -i
SET /a i=%i%+1
IF %CORE_N% GTR %i% GOTO loop








