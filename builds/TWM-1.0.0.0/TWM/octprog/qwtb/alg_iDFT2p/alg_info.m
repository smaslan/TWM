function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm iDFT2p.
%
% See also qwtb

alginfo.id = 'iDFT2p';
alginfo.name = '2-point interpolated DFT frequency estimator';
alginfo.desc = 'An algorithm for estimating the frequency, amplitude, phase and offset of the fundamental component using interpolated discrete Fourier transform. Rectangular or Hann window can be used for DFT.';
alginfo.citation = 'Krzysztof Duda: Interpolation algorithms of DFT for parameters estimation of sinusoidal and damped sinusoidal signals. In S. M. Salih, editor, Fourier Transform - Signal Processing, chapter 1, pages 3-32, InTech, 2012. http://www.intechopen.com/books/fourier-transform-signal-processing/interpolated-dft Implemented by Rado Lapuh, 2016.';
alginfo.remarks = 'If sampling time |Ts| is not supplied, wrapper will calculate |Ts| from sampling frequency |fs| or if not supplied, mean of differences of time series |t| is used to calculate |Ts|. The optional parameter |window| can be set to values `rectangular` or `Hann`. If parameter is not supplied, Hann window will be used.';
alginfo.license = 'Implementation: MIT License';

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

alginfo.inputs(5).name = 'window';
alginfo.inputs(5).desc = 'DFT window: `Hann` or `rectangular`';
alginfo.inputs(5).alternative = 0;
alginfo.inputs(5).optional = 1;
alginfo.inputs(5).parameter = 1;

alginfo.outputs(1).name = 'f';
alginfo.outputs(1).desc = 'Frequency of main signal component';

alginfo.outputs(2).name = 'A';
alginfo.outputs(2).desc = 'Amplitude of main signal component';

alginfo.outputs(3).name = 'ph';
alginfo.outputs(3).desc = 'Phase of main signal component';

alginfo.outputs(4).name = 'O';
alginfo.outputs(4).desc = 'Offset of main signal component';

alginfo.providesGUF = 0;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
