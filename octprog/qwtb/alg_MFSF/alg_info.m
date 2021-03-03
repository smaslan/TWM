function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm MFSF.
%
% See also qwtb

alginfo.id = 'MFSF';
alginfo.name = 'Multi-frequency sine fit';
alginfo.desc = 'An algorithm for estimating the frequency, amplitude, and phase of the fundamental and harmonic components in a waveform. Amplitudes and phases of harmonic components are adjusted to find minimal sum of squared differences between sampled signal and multi-harmonic model. When all sampled signal harmonics are included in the model, the algorithm is efficient and produces no bias. It can even handle aliased harmonics, if they are not aliased back exactly at frequencies where other harmonics are already present. Further, it can also handle non harmonic components, when their frequency ratio to the fundamental frequency is exactly known a-priori.';
alginfo.citation = 'J. Schoukens, R. Pintelon, and G. Vandersteen, "A sinewave fitting procedure for characterizing data acquisition  channels in the presence of time base distortion and time jitter," IEEE Trans. Instrum. Meas., Vol. 46, No. 4, Aug. 1997, 1005-1010 and R. Lapuh, "Sampling with 3458A", Left Right d.o.o., September 2018, ISBN 978-961-94476-0-4';
alginfo.remarks = 'If sampling time |Ts| is not supplied, wrapper will calculate |Ts| from sampling frequency |fs| or if not supplied, mean of differences of time series |t| is used to calculate |Ts|. If not supplied, Cost Function Threshold |CFT| is set to 3.5e-11 by algorithm itself. If initial estimate |fest| value is negative or ''ipdft'', initial guess is done using ipdft. If |fest| value is ''psfe'', initial guess is done using ''PSFE'' algorithm. Otherwise actual value is used. Calculation of uncertainty using GUM method works only for |CFT| equal to 3.5e-11 and |fest| equal to -1.';
alginfo.license = 'License not specified.';


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

alginfo.inputs(5).name = 'fest';
alginfo.inputs(5).desc = 'Estimate of main signal component';
alginfo.inputs(5).alternative = 0;
alginfo.inputs(5).optional = 1;
alginfo.inputs(5).parameter = 1;

alginfo.inputs(6).name = 'ExpComp';
alginfo.inputs(6).desc = 'Expected signal components in multiples of main signal frequency';
alginfo.inputs(6).alternative = 0;
alginfo.inputs(6).optional = 0;
alginfo.inputs(6).parameter = 1;

alginfo.inputs(7).name = 'CFT';
alginfo.inputs(7).desc = 'Cost Function Threshold';
alginfo.inputs(7).alternative = 0;
alginfo.inputs(7).optional = 1;
alginfo.inputs(7).parameter = 1;


alginfo.inputs(8).name = 'sfdr';
alginfo.inputs(8).desc = 'Spurious free dynamic range (positive dBc)';
alginfo.inputs(8).alternative = 0;
alginfo.inputs(8).optional = 1;
alginfo.inputs(8).parameter = 1;

alginfo.inputs(9).name = 'adcres';
alginfo.inputs(9).desc = 'Absolute resolution of the ADC';
alginfo.inputs(9).alternative = 0;
alginfo.inputs(9).optional = 1;
alginfo.inputs(9).parameter = 1;

alginfo.inputs(10).name = 'jitter';
alginfo.inputs(10).desc = 'RMS jitter of the sampling time';
alginfo.inputs(10).alternative = 0;
alginfo.inputs(10).optional = 1;
alginfo.inputs(10).parameter = 1;



alginfo.outputs(1).name = 'f';
alginfo.outputs(1).desc = 'Frequencies of signal components';

alginfo.outputs(2).name = 'A';
alginfo.outputs(2).desc = 'Amplitudes of signal components';

alginfo.outputs(3).name = 'ph';
alginfo.outputs(3).desc = 'Phases of signal components';

alginfo.outputs(4).name = 'O';
alginfo.outputs(4).desc = 'Offset of signal';

alginfo.outputs(5).name = 'THD';
alginfo.outputs(5).desc = 'Total Harmonic Distortion';

alginfo.outputs(6).name = 'spec_f';
alginfo.outputs(6).desc = 'Frequencies of spectrum components';

alginfo.outputs(7).name = 'spec_A';
alginfo.outputs(7).desc = 'Amplitudes of spectrum components';

alginfo.providesGUF = 1;
alginfo.providesMCM = 1;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
