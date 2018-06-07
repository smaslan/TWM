function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm flicker_sim
%
% See also qwtb

alginfo.id = 'flicker_sim';
alginfo.name = 'Flickermeter simulator';
alginfo.desc = 'Calculates instantaneous flicker sensation Pinst and short-term flicker severity Pst.';
alginfo.citation = 'Implemented according: IEC 61000-4-15, Electromagnetic compatibility (EMC), Testing and measurement techniques, Flickermeter, Edition 2.0, 2010-08; Wilhelm Mombauer: "Messung von Spannungsschwankungen und Flickern mit dem IEC-Flickermeter", ISBN 3-8007-2525-8, VDE-Verlag; Solcept Open Source Flicker Measurement-Simulator https://www.solcept.ch/en/tools/flickersim/; NPL Reference Flickermeter Design http://www.npl.co.uk/electromagnetics/electrical-measurement/products-and-services/npl-reference-flickermeter-design';
alginfo.remarks = 'If sampling frequency |fs| is not supplied, wrapper will calculate |fs| from sampling time |Ts| or if not supplied, mean of differences of time series |t| is used to calculate |Ts|. Sampling frequency has to be higher than 7 kHz. If sampling f. is higher than 23 kHz, signal will be down sampled by algorithm. More than 600 s of signal is required. Requires either Signal Processing Toolbox when run in MATLAB or signal package when run in GNU Octave. Frequency of line (carrier frequency) |f_line| can be only 50 or 60 Hz';

alginfo.license = 'Boost Software License';

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

alginfo.inputs(5).name = 'f_line';
alginfo.inputs(5).desc = 'Line frequency';
alginfo.inputs(5).alternative = 0;
alginfo.inputs(5).optional = 0;
alginfo.inputs(5).parameter = 0;

alginfo.outputs(1).name = 'Pst';
alginfo.outputs(1).desc = 'Short-term flicker severity';

alginfo.outputs(2).name = 'Pinst';
alginfo.outputs(2).desc = 'Instantaneous flicker sensation';

alginfo.providesGUF = 0;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
