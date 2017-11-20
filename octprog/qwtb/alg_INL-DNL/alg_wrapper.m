function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm INL-DNL.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% INL definition is:
% function INL = ProcessHistogramTest(dsc,display_settings,varargin)
dsc.data = datain.codes.v;
dsc.NoB = datain.bitres.v;

% some data required by algorithm but not affecting result:
dsc.name = 'tst';
dsc.comment = {['comment']};
dsc.model = 'MatlabSim';
dsc.serial = 'N/A';
dsc.channel = 1;
dsc.simulation = 1;

% do not show figures:
display_settings.results_win = 0;
display_settings.summary_win = 0;
display_settings.warning_dialog = 0;

% Call algorithm ---------------------------  %<<<1
INL = ProcessHistogramTest(dsc,display_settings);
DNL = diff(INL);

% Format output data:  --------------------------- %<<<1
% INL definition is:
% function INL = ProcessHistogramTest(dsc,display_settings,varargin)
dataout.INL.v = INL;
dataout.DNL.v = DNL;

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
