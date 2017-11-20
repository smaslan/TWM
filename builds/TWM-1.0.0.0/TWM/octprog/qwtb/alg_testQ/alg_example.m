%% testQ
% Example for algorithm testQ. Algorithm is usefull only for testing QWTB toolbox. It returns
% values from the input. This script has no real sense.
%
% See also |qwtb|

%% Generate sample data
% Quantities are prepared.
DI = [];
DI.x.v = [-5:-1:-1];
DI.v.v = [1:10];
DI.a.v = 5;
DI.c.v = 'variable c';
%% Call algorithm
% Use QWTB to apply algorithm |testQ| to data |DI|.
DO = qwtb('testQ', DI);
%%
% The result is value of |v|:
DO.e.v
%% Different input
% Add quantity |u|, which has precedence over |v|:
DI.u.v = [100:110];
DO = qwtb('testQ', DI);
%%
% The result is value of |u|:
DO.e.v
