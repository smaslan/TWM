@ECHO OFF
title="GNU Octave multicore console"

REM ==== SETUP ====

REM --- Cores count ---
SET /a CORE_N=4

REM --- GNU Octave path ---
SET OCT_FLD=D:\Octave\Octave-4.2.2\bin\
SET OCT_NAME=octave-cli.exe
SET OCT_PATH=%OCT_FLD%\%OCT_NAME%

REM --- Job share folder ---
SET SHARE_FLD=mc_rubbish
SET SHARE_PATH=%CD%\%SHARE_FLD%
rem SET SHARE_PATH=M:\mc_rubbish

REM --- Options ---
SET OPT=/BELOWNORMAL /B

REM --- Set this script priority ---
wmic process where name="cmd.exe" CALL SetPriority "Below Normal"

REM ==== RUN PROCESSES ====
SET FUNC_NAME=run_mc_slave("'%SHARE_PATH%'")
SET /a i=0
:loop
START "GNU Octave - multicore slave #%i%" /D "%OCT_FLD%" %OPT% "%OCT_NAME%" -q -p "%CD%" --exec-path "%CD%" --eval %FUNC_NAME% --persist -i
SET /a i=%i%+1
IF %CORE_N% GTR %i% GOTO loop








