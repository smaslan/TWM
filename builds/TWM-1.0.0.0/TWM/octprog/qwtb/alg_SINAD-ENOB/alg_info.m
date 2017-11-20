function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm SINAD-ENOB
%
% See also qwtb

alginfo.id = 'SINAD-ENOB';
alginfo.name = 'Ratio of signal to noise and distortion and Effective number of bits (in time space)';
alginfo.desc = ' Algorithm calculates Ratio of signal to noise and distortion and Effective number of bits in time space, therefore it is suitable for noncoherent measurements. Requires estimates of the main signal component parameters: frequency, amplitude, phase and offset. If these values are estimated by four parameter sine wave fit, the SINAD and ENOB will be calculated according IEEE Std 1241-2000. A large sine wave should be applied to the ADC input. Almost any error source in the sine wave input other than gain accuracy and dc offset can affect the test result.';
alginfo.citation = 'IEEE Std 1241-2000, pages 52 - 54';
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

alginfo.inputs(5).name = 'f';
alginfo.inputs(5).desc = 'Frequency of main signal component';
alginfo.inputs(5).alternative = 0;
alginfo.inputs(5).optional = 0;
alginfo.inputs(5).parameter = 0;

alginfo.inputs(6).name = 'A';
alginfo.inputs(6).desc = 'Amplitude of main signal component';
alginfo.inputs(6).alternative = 0;
alginfo.inputs(6).optional = 0;
alginfo.inputs(6).parameter = 0;

alginfo.inputs(7).name = 'ph';
alginfo.inputs(7).desc = 'Phase of main signal component';
alginfo.inputs(7).alternative = 0;
alginfo.inputs(7).optional = 0;
alginfo.inputs(7).parameter = 0;

alginfo.inputs(8).name = 'O';
alginfo.inputs(8).desc = 'Offset of signal';
alginfo.inputs(8).alternative = 0;
alginfo.inputs(8).optional = 0;
alginfo.inputs(8).parameter = 0;

alginfo.inputs(9).name = 'bitres';
alginfo.inputs(9).desc = 'Bit resolution of an ADC';
alginfo.inputs(9).alternative = 0;
alginfo.inputs(9).optional = 0;
alginfo.inputs(9).parameter = 0;

alginfo.inputs(10).name = 'FSR';
alginfo.inputs(10).desc = 'Full scale range of an ADC';
alginfo.inputs(10).alternative = 0;
alginfo.inputs(10).optional = 0;
alginfo.inputs(10).parameter = 0;

alginfo.outputs(1).name = 'SINADdB';
alginfo.outputs(1).desc = 'Ratio of signal to noise and distortion in decibels relative to the amplitude of the main signal component';

alginfo.outputs(2).name = 'ENOB';
alginfo.outputs(2).desc = 'Effective number of bits';

alginfo.providesGUF = 0;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
