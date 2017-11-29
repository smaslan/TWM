function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm SP-FFT.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% ampphspectrum definition is:
% function [f, amp, ph] = ampphspectrum(y,fs)
if isfield(datain, 'fs')
    fs = datain.fs.v;
elseif isfield(datain, 'Ts')
    fs = 1/datain.Ts.v;
    if calcset.verbose
        disp('QWTB: SP-FFT wrapper: sampling frequency was calculated from sampling time')
    end
else
    fs = 1/mean(diff(datain.t.v));
    if calcset.verbose
        disp('QWTB: SP-FFT wrapper: sampling frequency was calculated from time series')
    end
end
y = datain.y.v;

% Call algorithm ---------------------------  %<<<1
[f, amp, ph] = ampphspectrum(y,fs);

% Format output data:  --------------------------- %<<<1
dataout.f.v = f;
dataout.A.v = amp;
dataout.ph.v = ph;

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
