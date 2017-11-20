function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm test(G)(M). Algorithm is usefull only
% for testing QWTB toolbox. It calculates maximal and minimal value of the
% record. GUF/MCM are calculated by wrapper.
%
% See also qwtb

alginfo.id = 'testGM';
alginfo.name = 'Test with GUF and MCM';
alginfo.desc = 'Calculates maximum value of the measured record';
alginfo.citation = 'see EMRP Q-Wave';
alginfo.remarks = 'Do not use. This is only for testing QWTB';
alginfo.license = 'MIT License';
alginfo.inputs(1).name = 'x';
alginfo.inputs(1).desc = 'independent quantity';
alginfo.inputs(1).alternative = 0;
alginfo.inputs(1).optional = 0;
alginfo.inputs(1).parameter = 0;
alginfo.inputs(2).name = 'y';
alginfo.inputs(2).desc = 'dependent quantity';
alginfo.inputs(2).alternative = 0;
alginfo.inputs(2).optional = 0;
alginfo.inputs(2).parameter = 0;
alginfo.outputs(1).name = 'max';
alginfo.outputs(1).desc = 'maximal dependent quantity';
alginfo.outputs(2).name = 'min';
alginfo.outputs(2).desc = 'minimal dependent quantity';
alginfo.providesGUF = 1;
alginfo.providesMCM = 1;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
