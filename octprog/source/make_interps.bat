@ECHO OFF

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
