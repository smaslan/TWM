function dataout = alg_wrapper(datain, calcset) %<<<1
% Part of QWTB. Wrapper script for algorithm PSFE.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% PSFE definition is:
% function [fa A ph] = PSFE(Record,Ts,init_guess)
% Record     - sampled input signal
% Ts         - sampling time (in s)
% init_guess: 0 - FFT max bin, 1 - IPDFT, negative initial frequency estimate

if isfield(datain, 'Ts')
    Ts = datain.Ts.v;
elseif isfield(datain, 'fs')
    Ts = 1/datain.fs.v;
    if calcset.verbose
        disp('QWTB: PSFE wrapper: sampling time was calculated from sampling frequency')
    end
else
    Ts = mean(diff(datain.t.v));
    if calcset.verbose
        disp('QWTB: PSFE wrapper: sampling time was calculated from time series')
    end
end

init_guess = 1;

% Call algorithm ---------------------------  %<<<1
[fa A ph] = PSFE(datain.y.v,Ts,init_guess);

% Format output data:  --------------------------- %<<<1
% PSFE definition is:
% function [fa A ph] = PSFE(Record,Ts,init_guess)
% fa     - estimated signal's frequency
% A      - estimated signal's amplitude
% ph     - estimated signal's phase

dataout.f.v = fa;
dataout.A.v = A;
dataout.ph.v = ph;

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
