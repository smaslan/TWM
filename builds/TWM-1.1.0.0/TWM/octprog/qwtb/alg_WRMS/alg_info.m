function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm PSFE.
%
% See also qwtb

alginfo.id = 'WRMS';
alginfo.name = 'Non-coherent RMS value using windowing';
alginfo.desc = 'Calculates RMS value of non-coherent signal using windowing function (Hann). Needs at least 7 signal periods in order to reduce algorithm''s error below 1 ppm.';
alginfo.citation = 'don''t know';
alginfo.remarks = 'nope';
alginfo.license = 'don''t know';

pid = 1;
alginfo.inputs(pid).name = 'Ts';
alginfo.inputs(pid).desc = 'Sampling time';
alginfo.inputs(pid).alternative = 1;
alginfo.inputs(pid).optional = 0;
alginfo.inputs(pid).parameter = 0;
pid = pid + 1;

alginfo.inputs(pid).name = 'fs';
alginfo.inputs(pid).desc = 'Sampling frequency';
alginfo.inputs(pid).alternative = 1;
alginfo.inputs(pid).optional = 0;
alginfo.inputs(pid).parameter = 0;
pid = pid + 1;

alginfo.inputs(pid).name = 't';
alginfo.inputs(pid).desc = 'Time series';
alginfo.inputs(pid).alternative = 1;
alginfo.inputs(pid).optional = 0;
alginfo.inputs(pid).parameter = 0;
pid = pid + 1;

alginfo.inputs(pid).name = 'y';
alginfo.inputs(pid).desc = 'Sampled values';
alginfo.inputs(pid).alternative = 0;
alginfo.inputs(pid).optional = 0;
alginfo.inputs(pid).parameter = 0;
pid = pid + 1;


pid = 1;
% outputs
alginfo.outputs(pid).name = 'rms';
alginfo.outputs(pid).desc = 'RMS value';
pid = pid + 1;

alginfo.outputs(pid).name = 'f';
alginfo.outputs(pid).desc = 'spectrum - frequency';
pid = pid + 1;

alginfo.outputs(pid).name = 'A';
alginfo.outputs(pid).desc = 'spectrum - amplitude';
pid = pid + 1;

alginfo.providesGUF = 0;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
