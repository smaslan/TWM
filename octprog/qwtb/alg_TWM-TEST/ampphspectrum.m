function [f, amp, ph] = ampphspectrum(y,fs)
% Calcualtes discrete fourier transformation of vector of sampled values |y| with sampling
% frequency |fs|, normalize values and returns frequency vector |f|, amplitudes |amp| and
% phases |ph|.
% 
% Example with signal of frequency 1 Hz, sampled by 50 Hz 
% frequency, two harmonic components at 1 and 8 Hz and one
% interharmonic component at 15.5 Hz with various
% amplitudes and phases:
% 
% fr=1; fs=50;
% x=[0:1/fs:1/fr];
% x = x(1:end-1);
% y=sin(2*pi*fr*x+1)+0.5*sin(2*pi*8*fr*x+2)+0.3*sin(2*pi*15.5*fr*x+3);
% [f,amp,ph]=ampphspectrum(y,fs);
% 

        % ---- check input values ----
        if (nargin > 3 || nargin < 2)
                print_usage();
        end

        if ~isvector(y)
                error('y has to be a vector!');
        end

        if ~isscalar(fs)
                error('fs has to be a scalar!');
        end

        % ---- DFT ----
        % (DFT is maybe slightly complicated because the input can contain odd number of samples)
        % number of samples:
        N = length(y);
        % calculate frequency spacing
        df = fs / N;
        % calculate unshifted frequency vector
        f = [0:(N - 1)]*df;
        % move all frequencies that are greater than fs/2 to the negative side of the axis
        f(f >= fs / 2) = f(f >= fs / 2) - fs;
        % fft calculation:
        Y = fft(y);
        % now, Y and f are aligned with one another; if you want frequencies in strictly
        % increasing order, fftshift() them
        Y = fftshift(Y);
        f = fftshift(f);
        % select negative frequencies part of results:
        Y = Y(1:find(f == 0));
        f = f(1:find(f == 0));
        % change sort order and make neg. freq. positive:
        f = abs(f(end:-1:1));
        Y = Y(end:-1:1);
        % power values normalized:
        amp = 2 * abs(Y) / N;
        % calculate phases (and correctly multiply by minuses etc. because we used negative part of
        % spectra):
        ph = -1.*angle(-i.*Y);
end

% vim settings line: vim: foldmarker=%{{{,%}}} fdm=marker fen ft=octave
