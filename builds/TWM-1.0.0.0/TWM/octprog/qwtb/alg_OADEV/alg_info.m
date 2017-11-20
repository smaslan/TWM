function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm OADEV.
%
% See also qwtb

alginfo.id = 'OADEV';
alginfo.name = 'Overlapping Allan Deviation';
alginfo.desc = 'Compute the overlapping Allan deviation for a set of time-domain frequency data.';
alginfo.citation = 'D.A. Howe, D.W. Allan and J.A. Barnes, "Properties of Signal Sources and Measurement Methods'', Proc. 35th Annu. Symp. on Freq. Contrl., pp. 1-47, May 1981. Implementation: Implementation by M. A. Hopcroft, mhopeng@gmail.com, Matlab Central, online: http://www.mathworks.com/matlabcentral/fileexchange/26441-allan-overlap Test data by W. J. Riley, "The Calculation of Time Domain Frequency Stability", online: http://www.wriley.com/paper1ht.htm';
alginfo.remarks = 'If sampling frequency |fs| is not supplied, wrapper will calculate |fs| from sampling time |Ts| or if not supplied, mean of differences of time series |t| is used to calculate |Ts|. If observation time(s) |tau| is not supplied, tau values are automatically generated. Tau values must be divisible by 1/|fs|. Invalid values are ignored. For tau values really used in the calculation see the output.';
% XXX 2DO Using sigma as uncertainty is probably not correct.';
alginfo.license = 'BSD License';

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

alginfo.inputs(5).name = 'tau';
alginfo.inputs(5).desc = 'Observation time';
alginfo.inputs(5).alternative = 0;
alginfo.inputs(5).optional = 1;
alginfo.inputs(5).parameter = 0;

alginfo.outputs(1).name = 'oadev';
alginfo.outputs(1).desc = 'Overlapping Allan deviation';

alginfo.outputs(2).name = 'tau';
alginfo.outputs(2).desc = 'Observation time of resulted values';

alginfo.providesGUF = 1;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
