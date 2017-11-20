function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm FFT.
%
% See also qwtb

alginfo.id = 'SP-FFT';
alginfo.name = 'Spectrum by means of Fast Fourier Transform';
alginfo.desc = 'Calculates frequency and phase spectrum by means of Fast Fourier Transform algorithm. Result is normalized.';
alginfo.citation = '';
alginfo.remarks = 'If sampling frequency |fs| is not supplied, wrapper will calculate |fs| from sampling time |Ts| or if not supplied, mean of differences of time series |t| is used to calculate |fs|.';
alginfo.license = 'MIT License';

alginfo.inputs(1).name = 'fs';
alginfo.inputs(1).desc = 'Sampling frequency';
alginfo.inputs(1).alternative = 1;
alginfo.inputs(1).optional = 0;
alginfo.inputs(1).parameter = 0;

alginfo.inputs(2).name = 'Ts';
alginfo.inputs(2).desc = 'Sampling time';
alginfo.inputs(2).alternative = 1;
alginfo.inputs(2).optional = 0;
alginfo.inputs(2).parameter = 0;

alginfo.inputs(3).name = 't';
alginfo.inputs(3).desc = 'Time series';
alginfo.inputs(3).alternative = 1;
alginfo.inputs(3).optional = 0;
alginfo.inputs(3).parameter = 0;

alginfo.inputs(4).name = 'y';
alginfo.inputs(4).desc = 'Sampled values';
alginfo.inputs(4).alternative = 0;
alginfo.inputs(4).optional = 0;
alginfo.inputs(4).parameter = 0;

alginfo.outputs(1).name = 'f';
alginfo.outputs(1).desc = 'Frequency series';

alginfo.outputs(2).name = 'A';
alginfo.outputs(2).desc = 'Amplitude spectrum';

alginfo.outputs(3).name = 'ph';
alginfo.outputs(3).desc = 'Phase spectrum';

alginfo.providesGUF = 0;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
