function dataout = alg_wrapper(datain, calcset) %<<<1
% Part of QWTB. Wrapper script for algorithm flicker_sim.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% flicker_sim definition is:
% [Pst, Pinst] = flicker_sim(u, fs, f_line, verbose)

if isfield(datain, 'fs')
    fs = datain.fs.v;
elseif isfield(datain, 'Ts')
    fs = 1/datain.Ts.v;
    if calcset.verbose
        disp('QWTB: flicker_sim wrapper: sampling frequency was calculated from sampling time')
    end
else
    fs = 1./mean(diff(datain.t.v));
    if calcset.verbose
        disp('QWTB: flicker_sim wrapper: sampling frequency was calculated from time series')
    end
end

% Call algorithm ---------------------------  %<<<1
[Pst, Pinst] = flicker_sim(datain.y.v, datain.fs.v, datain.f_line.v, 0);

% Format output data:  --------------------------- %<<<1
dataout.Pst.v = Pst;
dataout.Pinst.v = Pinst;

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
