function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm FPNLSF
%
% See also qwtb

alginfo.id = 'FPNLSF';
alginfo.name = 'Four Parameter Non-Linear Sine Fit';
alginfo.desc = 'Fits a sine wave to the recorded data by means of non-linear least squares fitting method using 4 parameter (frequency, amplitude, phase and offset) model. An estimate of signal frequency is required. Due to non-linear characteristic, convergence is not always achieved. When run in Matlab, function `lsqnonlin` in Optimization toolbox is used. When run in GNU Octave, function `leasqr` in GNU Octave Forge package optim is used. Therefore results can differ.';
alginfo.citation = '';
alginfo.remarks = 'Algorithm works essentially only for simple sine wave. Algorithm is very sensitive to distortion. Algorithm requires good estimate of signal frequency.';
alginfo.remarks = 'If Time series |t| is not supplied, wrapper will calculate |t| from sampling frequency |fs| or if not supplied, sampling time |Ts| is used to calculate |t|.';
alginfo.license = 'MIT License';

alginfo.inputs(1).name = 't';
alginfo.inputs(1).desc = 'Time series';
alginfo.inputs(1).alternative = 1;
alginfo.inputs(1).optional = 0;
alginfo.inputs(1).parameter = 0;

alginfo.inputs(2).name = 'fs';
alginfo.inputs(2).desc = 'Sampling frequency';
alginfo.inputs(2).alternative = 1;
alginfo.inputs(2).optional = 0;
alginfo.inputs(2).parameter = 0;

alginfo.inputs(3).name = 'Ts';
alginfo.inputs(3).desc = 'Sampling time';
alginfo.inputs(3).alternative = 1;
alginfo.inputs(3).optional = 0;
alginfo.inputs(3).parameter = 0;

alginfo.inputs(4).name = 'y';
alginfo.inputs(4).desc = 'Sampled values';
alginfo.inputs(4).alternative = 0;
alginfo.inputs(4).optional = 0;
alginfo.inputs(4).parameter = 0;

alginfo.inputs(5).name = 'fest';
alginfo.inputs(5).desc = 'Estimate of signal frequency';
alginfo.inputs(5).alternative = 0;
alginfo.inputs(5).optional = 0;
alginfo.inputs(5).parameter = 0;

alginfo.outputs(1).name = 'f';
alginfo.outputs(1).desc = 'Frequency of main signal component';

alginfo.outputs(2).name = 'A';
alginfo.outputs(2).desc = 'Amplitude of main signal component';

alginfo.outputs(3).name = 'ph';
alginfo.outputs(3).desc = 'Phase of main signal component';

alginfo.outputs(4).name = 'O';
alginfo.outputs(4).desc = 'Offset of signal';

alginfo.providesGUF = 0;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
