function alginfo = alg_info() %<<<1
% XXX add it takes up to 5 harmonics? does it?
% Part of QWTB. Info script for algorithm SFDR.
%
% See also qwtb

alginfo.id = 'SFDR';
alginfo.name = 'Spurious Free Dynamic Range';
alginfo.desc = 'Calculates Spurious Free Dynamic Range of an ADC. A FFT method with Blackman windowing is used to calculate a spectrum and SFDR is estimated in decibels relative to carrier amplitude. ADC has to sample a pure sine wave. SFDR is calculated according IEEE Std 1057-2007';
alginfo.citation = 'Implementation: Virosztek, T., Pálfi V., Renczes B., Kollár I., Balogh L., Sárhegyi A., Márkus J., Bilau Z. T., ADCTest project site: http://www.mit.bme.hu/projects/adctest 2000-2014';
alginfo.remarks = 'Based on the ADCTest Toolbox v4.3, November 25, 2014.';
alginfo.license = 'UNKNOWN';

alginfo.inputs(1).name = 'y';
alginfo.inputs(1).desc = 'Sampled values';
alginfo.inputs(1).alternative = 0;
alginfo.inputs(1).optional = 0;
alginfo.inputs(1).parameter = 0;

alginfo.outputs(1).name = 'SFDRdBc';
alginfo.outputs(1).desc = 'Spurious Free Dynamic Range in decibels relative to carrier (dBc)';

alginfo.providesGUF = 0;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
