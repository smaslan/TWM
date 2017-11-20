function dataout = alg_wrapper(datain, calcset) %<<<1
% Part of QWTB. Wrapper script for algorithm test(G)(M). Algorithm is usefull
% only for testing QWTB toolbox. It calculates maximal and minimal value of the
% record. GUF/MCM are calculated by wrapper.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% test(G)(M) definition is: function [maxval, minval] = test(G)(M)(xseries, yseries)

% Call algorithm --------------------------- %<<<1
[maxval, minval] = testM(datain.x.v, datain.y.v);

% Calculate uncertainty --------------------------- %<<<1
if strcmpi(calcset.unc, 'none')
    maxunc = 0;
    minunc = 0;
elseif strcmpi(calcset.unc, 'mcm')
    M = calcset.mcm.repeats;
    [tmp2, tmp] = find(maxval == datain.y.v);
    tmp = tmp(1);
    maxunc = maxval + datain.y.u(tmp).*randn(1, M, 1);
    [tmp2, tmp] = find(minval == datain.y.v);
    tmp = tmp(1);
    minunc = minval + datain.y.u(tmp).*randn(1, M, 1);
else
    error(['qwtb wrapper testM: value ' calcset.unc ' of calcset.unc not implemented'])
end

% Format output data:  --------------------------- %<<<1
dataout.max.v = maxval;
dataout.min.v = minval;
dataout.max.u = std(maxunc);
dataout.min.u = std(minunc);
dataout.max.r = maxunc;
dataout.min.r = minunc;

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
