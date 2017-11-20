function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm FourPSF.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% FourPSF definition is:
% function [f A ph O]=FourPSF(data, Ts)
verbose = calcset.verbose;

if isfield(datain, 'Ts')
    Ts = datain.Ts.v;
elseif isfield(datain, 'fs')
    Ts = 1./datain.fs.v;
    if calcset.verbose
        disp('QWTB: FourPSF wrapper: sampling time was calculated from sampling frequency')
    end
else
    Ts = mean(diff(datain.t.v));
    if calcset.verbose
        disp('QWTB: FourPSF wrapper: sampling time was calculated from time series')
    end
end

% Call algorithm ---------------------------  %<<<1
[f A ph O]=FourPSF(datain.y.v, Ts);

% Format output data:  --------------------------- %<<<1
dataout.f.v = f;
dataout.A.v = A;
dataout.ph.v = ph;
dataout.O.v = O;

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
