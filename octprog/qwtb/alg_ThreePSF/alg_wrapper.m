function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm ThreePSF.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% ThreePSF definition is:
% function [A phi O] = ThreePSF(Record,f,Ts)
verbose = calcset.verbose;

if isfield(datain, 'Ts')
    Ts = datain.Ts.v;
elseif isfield(datain, 'fs')
    Ts = 1./datain.fs.v;
    if calcset.verbose
        disp('QWTB: ThreePSF wrapper: sampling time was calculated from sampling frequency')
    end
else
    Ts = mean(diff(datain.t.v));
    if calcset.verbose
        disp('QWTB: ThreePSF wrapper: sampling time was calculated from time series')
    end
end

% Call algorithm ---------------------------  %<<<1
[A phi O] = ThreePSF(datain.y.v,datain.f.v(1),Ts);

% Format output data:  --------------------------- %<<<1
dataout.A.v = A;
dataout.ph.v = phi;
dataout.O.v = O;

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
