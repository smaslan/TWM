function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm SFDR.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% ProcessFFTTest definition is:
% function testresults = ProcessFFTTest(dsc)
dsc.data = datain.y.v;

% some data required by algorithm but not affecting result:
dsc.NoB = 10;
dsc.name = 'tst';
dsc.comment = {['comment']};
dsc.model = 'MatlabSim';
dsc.serial = 'N/A';
dsc.channel = 1;
dsc.simulation = 1;

% Call algorithm ---------------------------  %<<<1
testresults = ProcessFFTTest(dsc);

% Format output data:  --------------------------- %<<<1
% ProcessFFTTest definition is:
% function testresults = ProcessFFTTest(dsc)
dataout.SFDRdBc.v = testresults{1}.FFT.SFDRdBc;

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
