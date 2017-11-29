function alg_test(calcset) %<<<1
% Part of QWTB. Testing script for algorithm test(G)(M). Algorithm is usefull
% only for testing QWTB toolbox. It calculates maximal and minimal value of the
% record. GUF/MCM are calculated by wrapper.
%
% See also qwtb

% Generate sample data --------------------------- %<<<1
% test(G)(M) definition is: function [maxval, minval] = test(G)(M)(tseries, yseries)
datain.x.v = [1:20];
datain.x.u = [1:20];
datain.y.v = [1:20];
datain.y.u = [1:20];
calcset.unc = 'mcm';
calcset.mcm.randomize = 1;

% Call algorithm --------------------------- %<<<1
[dataout] = qwtb('testM', datain, calcset);

% Check results --------------------------- %<<<1
assert(dataout.max.v == 20);
assert(dataout.min.v == 1);

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
