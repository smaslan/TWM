@ECHO OFF

@ECHO --- Building: correction_interp_table.m ---

copy /b ^
make_head.m+^
correction_interp_table.m+^
interp1nan.m+^
interp2nan.m ^
..\correction_interp_table.m


@ECHO --- Building: interp1nan.m ---

copy /b ^
make_head.m+^
interp1nan.m ^
..\interp1nan.m


@ECHO --- Building: interp2nan.m ---

copy /b ^
make_head.m+^
interp2nan.m ^
..\interp2nan.m
