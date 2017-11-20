function dataout = alg_wrapper(datain, calcset) %<<<1
% Part of QWTB. Wrapper script for algorithm test(G)(M). Algorithm is usefull
% only for testing QWTB toolbox. It calculates maximal and minimal value of the
% record. GUF/MCM are calculated by wrapper.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% test(G)(M) definition is: function [maxval, minval] = test(G)(M)(xseries, yseries)

% Call algorithm --------------------------- %<<<1
[maxval, minval] = testG(datain.x.v, datain.y.v);

% Calculate uncertainty --------------------------- %<<<1
if strcmpi(calcset.unc, 'none')
    maxunc = 0;
    minunc = 0;
    maxdof = 0;
    mindof = 0;
elseif strcmpi(calcset.unc, 'guf')
    [tmp2, tmp] = find(maxval == datain.y.v);
    tmp = tmp(1);
    maxunc = datain.y.u(tmp);
    maxdof = datain.y.d(tmp);
    [tmp2, tmp] = find(minval == datain.y.v);
    tmp = tmp(1);
    minunc = datain.y.u(tmp);
    mindof = datain.y.d(tmp);
else
    error(['qwtb wrapper testM: value ' calcset.unc ' of calcset.unc not implemented'])
end

% Format output data:  --------------------------- %<<<1
dataout.max.v = maxval;
dataout.min.v = minval;
dataout.max.u = maxunc;
dataout.min.u = minunc;
dataout.max.d = maxdof;
dataout.min.d = mindof;

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
