function dataout = alg_wrapper(datain, calcset) %<<<1
% Part of QWTB. Wrapper script for algorithm testQ. Algorithm is usefull only
% for testing QWTB toolbox. It calculates maximal and minimal value of the
% record.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% reflect definition is:
% function [out1, out2] = reflect(in) % Returns input on the first output, the second output is always empty matrix

if isfield(datain, 'x')
    in = datain.x.v;
else
    in = datain.y.v;
end
% just tap rest of required input quantities to check they are present:
if isfield(datain, 'u')
    in2 = datain.u.v;
else
    in2 = datain.v.v;
end
datain.a.v;
datain.c.v;

% Call algorithm --------------------------- %<<<1
[out1, out2] = reflect(in);

% Format output data:  --------------------------- %<<<1
dataout.o.v = out1;
dataout.e.v = out2;

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
