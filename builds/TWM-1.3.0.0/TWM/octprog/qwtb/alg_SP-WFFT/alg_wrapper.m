function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm SP-WFFT.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% ampphspectrum definition is:
% function [f, amp, ph] = ampphspectrum(y, fs, verbose=0, stem_plot=1, win='', winparam=[], padding=0)
if isfield(datain, 'fs')
    fs = datain.fs.v;
elseif isfield(datain, 'Ts')
    fs = 1/datain.Ts.v;
    if calcset.verbose
        disp('QWTB: SP-WFFT wrapper: sampling frequency was calculated from sampling time')
    end
else
    fs = 1/mean(diff(datain.t.v));
    if calcset.verbose
        disp('QWTB: SP-WFFT wrapper: sampling frequency was calculated from time series')
    end
end

win = 'rect';
winparam = [];
if isfield(datain, 'window')
    win = datain.window.v;
    % get all available windows:
    avail_windows = window_coeff();
    % check for correct window:
    if ~any( cellfun(@strcmpi, avail_windows, repmat({win}, size(avail_windows))) )
            error(['QWTB: WFFT wrapper: unknown window `' win '`. Available windows are: ' strjoin(avail_windows, ', ')]);
    end

    % determine window parameter if needed:
    if ( strcmpi(win, 'cheb') && isfield(datain, 'cheb_att') )
        winparam = datain.cheb_att.v;
    end
    if ( strcmpi(win, 'gaussian') && isfield(datain, 'gaussian_width') )
        winparam = datain.gaussian_width.v;
    end
    if ( strcmpi(win, 'kaiser') && isfield(datain, 'kaiser_att') )
        winparam = datain.kaiser_att.v;
    end
    if ( strcmpi(win, 'tukey') && isfield(datain, 'tukey_ratio') )
        winparam = datain.tukey_ratio.v;
    end
end

padding = 0;
if isfield(datain, 'fft_padding')
    padding = datain.fft_padding.v;
end

% Call algorithm ---------------------------  %<<<1
[f, amp, ph, w] = ampphspectrum(datain.y.v, fs, 0, 0, win, winparam, padding);

% Format output data:  --------------------------- %<<<1
dataout.f.v = f(:)';
dataout.A.v = amp(:)';
dataout.ph.v = ph(:)';
dataout.w.v = w(:)'; % window coeficients

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
