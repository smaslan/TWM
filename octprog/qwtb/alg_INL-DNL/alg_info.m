function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm INL-DNL.
%
% See also qwtb

alginfo.id = 'INL-DNL';
alginfo.name = 'Integral and Differential Non-Linearity of ADC';
alginfo.desc = 'Calculates Integral and Differential Non-Linearity of an ADC. The histogram of measured data is used to calculate INL and DNL estimators. ADC has to sample a pure sine wave. To estimate all transition levels the amplitude of the sine wave should overdrive the full range of the ADC by at least 120%. If not so, non estimated transition levels will be assumed to be 0 and the results may be less accurate. As an input ADC codes are required.';
alginfo.citation = 'Estimators are based on Tamás Virosztek, MATLAB-based ADC testing with sinusoidal excitation signal (in Hungar- ian), B.Sc. Thesis, 2011. Implementation: Virosztek, T., Pálfi V., Renczes B., Kollár I., Balogh L., Sárhegyi A., Márkus J., Bilau Z. T., ADCTest project site: http://www.mit.bme.hu/projects/adctest 2000-2014';
alginfo.remarks = 'Based on the ADCTest Toolbox v4.3, November 25, 2014.';
alginfo.license = 'UNKNOWN';

alginfo.inputs(1).name = 'bitres';
alginfo.inputs(1).desc = 'Bit resolution of an ADC';
alginfo.inputs(1).alternative = 0;
alginfo.inputs(1).optional = 0;
alginfo.inputs(1).parameter = 0;

alginfo.inputs(2).name = 'codes';
alginfo.inputs(2).desc = 'Sampled values represented as ADC codes (not converted to voltage)';
alginfo.inputs(2).alternative = 0;
alginfo.inputs(2).optional = 0;
alginfo.inputs(2).parameter = 0;

alginfo.outputs(1).name = 'INL';
alginfo.outputs(1).desc = 'Integral Non-Linearity';

alginfo.outputs(2).name = 'DNL';
alginfo.outputs(2).desc = 'Differential Non-Linearity';

alginfo.providesGUF = 0;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
