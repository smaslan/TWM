function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm FourPSF
%
% See also qwtb

alginfo.id = 'FourPSF';
alginfo.name = 'Standard Four Parameter Sine Wave Fit according IEEE Std 1241-2000';
alginfo.desc = 'Fits a sine wave to the recorded data using 4 parameter (frequency, amplitude, phase and offset) model. The algorithm is according IEEE Standard for Terminology and Test methods for Analog-to-Digital Converters 1241-2000';
alginfo.citation = 'IEEE Std 1241-2000, Implementation written by Zoltán Tamás Bilau, modified by Janos Markus. Id: sfit4.m,v 3.0 2004/04/19 11:20:09 markus Exp. Copyright (c) 2001-2004 by Istvan Kollar and Janos Markus. Modified 2016 Rado Lapuh';
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
