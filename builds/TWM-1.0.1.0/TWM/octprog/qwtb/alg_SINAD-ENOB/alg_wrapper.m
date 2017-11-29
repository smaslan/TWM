function dataout = alg_wrapper(datain, calcset) %<<<1
% Part of QWTB. Wrapper script for algorithm SINAD-ENOB.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% algorithm definition is:
% function [SINAD, ENOB] = sinad(t, y, f, A, ph, O, NoB, FSR)

N = length(datain.y.v);
if isfield(datain, 't')
    t = datain.t.v;
elseif isfield(datain, 'fs')
    Ts = 1./datain.fs.v;
    t = [0 : Ts : N.*Ts-Ts];
    if calcset.verbose
        disp('QWTB: SINAD-ENOB wrapper: time series were calculated from sampling frequency')
    end
else
    Ts = datain.Ts.v;
    t = [0 : Ts : N.*Ts-Ts];
    if calcset.verbose
        disp('QWTB: SINAD-ENOB wrapper: time series were calculated from sampling time')
    end
end

% Call algorithm ---------------------------  %<<<1
[SINAD, ENOB] = sinad(t, datain.y.v, datain.f.v, datain.A.v, datain.ph.v, datain.O.v, datain.bitres.v, datain.FSR.v);

% Format output data:  --------------------------- %<<<1
dataout.ENOB.v = ENOB;
% convert to decibels (relative to main signal component):
dataout.SINADdB.v = 20.*log10(SINAD);

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
