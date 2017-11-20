function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm ThreePSF
%
% See also qwtb

alginfo.id = 'ThreePSF';
alginfo.name = 'Standard Three Parameter Sine Wave Fit according IEEE Std 1241-2000';
alginfo.desc = 'Fits a sine wave to the recorded data using 3 parameter (amplitude, phase and offset) model. The algorithm is according IEEE Standard for Terminology and Test methods for Analog-to-Digital Converters 1241-2000. Algorithm requires exact value of signal frequency.';
alginfo.citation = 'IEEE Std 1241-2000, Implementation written Rado Lapuh, 2016';
alginfo.remarks = '';
alginfo.remarks = 'If sampling time |Ts| is not supplied, wrapper will calculate |Ts| from sampling frequency |fs| or if not supplied, mean of differences of time series |t| is used to calculate |Ts|.';
alginfo.license = 'UNKNOWN';

alginfo.inputs(1).name = 'Ts';
alginfo.inputs(1).desc = 'Sampling time';
alginfo.inputs(1).alternative = 1;
alginfo.inputs(1).optional = 0;
alginfo.inputs(1).parameter = 0;

alginfo.inputs(2).name = 'fs';
alginfo.inputs(2).desc = 'Sampling frequency';
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

alginfo.inputs(4).name = 'f';
alginfo.inputs(4).desc = 'Signal frequency';
alginfo.inputs(4).alternative = 0;
alginfo.inputs(4).optional = 0;
alginfo.inputs(4).parameter = 0;

alginfo.outputs(1).name = 'A';
alginfo.outputs(1).desc = 'Amplitude of main signal component';

alginfo.outputs(2).name = 'ph';
alginfo.outputs(2).desc = 'Phase of main signal component';

alginfo.outputs(3).name = 'O';
alginfo.outputs(3).desc = 'Offset of signal';

alginfo.providesGUF = 0;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
