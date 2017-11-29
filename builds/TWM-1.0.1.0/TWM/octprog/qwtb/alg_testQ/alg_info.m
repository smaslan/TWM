function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm testQ. Algorithm is usefull only
% for testing QWTB toolbox. It calculates maximal and minimal value of the
% record.
%
% See also qwtb

alginfo.id = 'testQ';
alginfo.name = 'Test of various input Quantities settings';
alginfo.desc = 'Returns value of |x| quantity, or |y| quantity if present, and an empty matrix.';
alginfo.citation = 'see EMRP Q-Wave';
alginfo.remarks = 'Do not use. This is only for testing QWTB';
alginfo.license = 'MIT License';
% non optional group:
alginfo.inputs(1).name = 'x';
alginfo.inputs(1).desc = 'test x';
alginfo.inputs(1).alternative = 5;
alginfo.inputs(1).optional = 0;
alginfo.inputs(1).parameter = 0;

alginfo.inputs(2).name = 'y';
alginfo.inputs(2).desc = 'test y';
alginfo.inputs(2).alternative = 5;
alginfo.inputs(2).optional = 0;
alginfo.inputs(2).parameter = 0;
% partially optional group (i.e. non optional):
alginfo.inputs(3).name = 'u';
alginfo.inputs(3).desc = 'test u';
alginfo.inputs(3).alternative = 2;
alginfo.inputs(3).optional = 0;
alginfo.inputs(3).parameter = 0;

alginfo.inputs(4).name = 'v';
alginfo.inputs(4).desc = 'test v';
alginfo.inputs(4).alternative = 2;
alginfo.inputs(4).optional = 1;
alginfo.inputs(4).parameter = 0;
% fully optional group:
alginfo.inputs(5).name = 'r';
alginfo.inputs(5).desc = 'test r';
alginfo.inputs(5).alternative = 3;
alginfo.inputs(5).optional = 1;
alginfo.inputs(5).parameter = 0;

alginfo.inputs(6).name = 's';
alginfo.inputs(6).desc = 'test s';
alginfo.inputs(6).alternative = 3;
alginfo.inputs(6).optional = 1;
alginfo.inputs(6).parameter = 0;
% non optional quantity:
alginfo.inputs(7).name = 'a';
alginfo.inputs(7).desc = 'test a';
alginfo.inputs(7).alternative = 0;
alginfo.inputs(7).optional = 0;
alginfo.inputs(7).parameter = 0;
% optional quantity:
alginfo.inputs(8).name = 'b';
alginfo.inputs(8).desc = 'test b';
alginfo.inputs(8).alternative = 0;
alginfo.inputs(8).optional = 1;
alginfo.inputs(8).parameter = 0;
% non optional parameter:
alginfo.inputs(9).name = 'c';
alginfo.inputs(9).desc = 'test c';
alginfo.inputs(9).alternative = 0;
alginfo.inputs(9).optional = 0;
alginfo.inputs(9).parameter = 1;
% optional parameter:
alginfo.inputs(10).name = 'd';
alginfo.inputs(10).desc = 'test d';
alginfo.inputs(10).alternative = 0;
alginfo.inputs(10).optional = 1;
alginfo.inputs(10).parameter = 1;

alginfo.outputs(1).name = 'o';
alginfo.outputs(1).desc = 'the same as the input x or y';

alginfo.outputs(2).name = 'e';
alginfo.outputs(2).desc = 'empty matrix';

alginfo.providesGUF = 0;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
