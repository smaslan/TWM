@ECHO OFF


CALL :MAKEIT ..\correction_interp_table.m ^
make_head.m+^
correction_interp_table.m+^
interp1nan.m+^
interp2nan.m

CALL :MAKEIT ..\correction_expand_tables.m ^
make_head.m+^
correction_expand_tables.m+^
interp1nan.m+^
interp2nan.m

CALL :MAKEIT ..\interp1nan.m ^
make_head.m+^
interp1nan.m

CALL :MAKEIT ..\interp2nan.m ^
make_head.m+^
interp2nan.m


EXIT




:MAKEIT
@ECHO BUILDING: %1
copy /b %2 _temp_ >NUL
CALL :MOVEIT %1
EXIT /B


:MOVEIT
CALL :COMPARE _temp_ %1 >NUL
IF %errorlevel% NEQ 0 (
	move /Y _temp_ %1 >NUL
) ELSE (
	DEL _temp_
)
EXIT /B


:COMPARE
@ECHO n|2>NUL comp %1 %2
EXIT /B
