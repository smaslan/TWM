function [f, amp, ph] = ampphspectrum(y, fs, verbose, stem_plot, win, winparam, padding)
% original definition removed for Matlab compatibility. Wrapper always defines all inputs,
% therefore default values are not needed. Do NOT use without wrapper, or use original 
% source code (see alg_sources)
% function [f, amp, ph] = ampphspectrum(y, fs, verbose=0, stem_plot=1, win='', winparam=[], padding=0)

% -- Function File: [F, AMP, PH] = ampphspectrum (Y, FS, [VERBOSE,
%          STEM_PLOT, WIN, WINPARAM, PADDING])
%
%     Calcualtes amplitude and phase spectrum by means of discrete
%     fourier transformation of vector of sampled values Y with sampling
%     frequency FS.  Function returns returns frequency vector F,
%     amplitudes AMP and phases PH.
%
%     If VERBOSE is set, two figures with amplitude and phase will be
%     plotted as stem plots (or line plots if STEM_PLOT is set to 0).
%
%     Window function will be used if if WIN contains name of window
%     function.  Some window functions are parametric, its value can be
%     set in WINPARAM.
%
%     If PADDING is set, signal will be zero padded at right side to the
%     total length of PADDING.
%
%     Example with signal of frequency 1 Hz, sampled by frequency 50
%     samples/s.  Two harmonic components at 1 and 8 Hz and one
%     interharmonic component at 15.5 Hz with various amplitudes and
%     phases:
%
%          fr=1; fs=50;
%          x=[0:1/fs:1/fr](1:end-1);
%          y=sin(2*pi*fr*x+1)+0.5*sin(2*pi*8*fr*x+2)+0.3*sin(2*pi*15.5*fr*x+3);
%          [f,amp,ph]=ampphspectrum(y,fs,1);
%
%     See demo for more detailed example.
%

% Copyright (C) 2017 Martin Šíra
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; If not, see <http://www.gnu.org/licenses/>.

% Author: Martin Šíra <msira@cmi.cz>
% Created: 2013-02-27
% Version: 1.1

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
        if (nargin > 7 || nargin < 2)
                print_usage();
        end
        if ~( isnumeric(y) && isvector(y))
                error('ampphspectrum: y has to be a vector!');
        end
        if ~( isnumeric(fs) && isscalar(fs) && fs > 0)
                error('amppphspectrum: fs has to be a positive nonzero scalar');
        end
        if ~ischar(win)
                error('win has to be a string!');
        end
        if ~( isnumeric(padding) && isscalar(padding) && padding >= 0)
                error('amppphspectrum: padding has to be a non-negative scalar');
        end

        % ---- windowing ---- %<<<1
        % number of samples:
        N = length(y);

        if isempty(win)
                normalisation_factor = N;
        else
                % get window coefficients
                if isempty(winparam)
                        w = window_coeff(win, N, 'periodic');
                else
                        w = window_coeff(win, N, winparam, 'periodic');
                end
                % apply window function:
                w = reshape(w, size(y));
                y = w.*y;
                normalisation_factor = sum(w);
        end

        % ---- zero padding ---- %<<<1
        if padding
                % update number of samples:
                N = padding;
        end

        % ---- DFT ---- %<<<1
        % (DFT is maybe slightly complicated because the input can contain odd number of samples)
        % calculate frequency spacing
        df = fs / N;
        % calculate unshifted frequency vector
        f = [0:(N - 1)]*df;
        % move all frequencies that are greater than fs/2 to the negative side of the axis
        f(f >= fs / 2) = f(f >= fs / 2) - fs;
        % dft calculation:
        Y = fft(y, N);
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
        amp = 2 * abs(Y) ./ normalisation_factor;
        % calculate phases (and correctly multiply by minuses etc. because we used negative part of
        % spectra):
        ph = -1.*angle(-i.*Y);

        % ---- plot ---- %<<<1
        % plot figures in the case of verbose:
        if verbose
                figure
                if stem_plot
                        stem(f, amp(1:length(f)),'-o','filled')
                else
                        plot(f, amp(1:length(f)),'-')
                end
                title('Amplitude spectrum');
                xlabel('Frequency [Hz]');
                ylabel('Amplitude');

                figure
                if stem_plot
                        stem(f, ph ,'-o','filled')
                else
                        plot(f, ph ,'-')
                end
                title('Phase spectrum');
                xlabel('Frequency [Hz]');
                ylabel('Phase [rad]');
        end

end

% ---- demo ---- %<<<1
%!demo
%!  % Example showing effect of coherent and non-coherent sampling,
%!  % windowing and zero padding on estimating amplitude and phase
%!  % by means of DFT.
%!  
%!  % Construct signal with two harmonic components at 1
%!  % and 8 Hz and one interharmonic component at 15.5 Hz
%!  % with various amplitudes and phases:
%!  sf = [1;   8; 15.5];
%!  sA = [1; 0.5;  0.3];
%!  sp = [0;   1;    2];
%!  % Sampling frequency:
%!  fs = 50;
%!  % Create time vector - one period of first harmonic is sampled coherently:
%!  t = [0 : 1/fs : 1.*sf(1)](1:end-1);
%!  y = sA.*sin(2.*pi.*sf.*t + sp);
%!  % Calculate amplitude and phase spectrum:
%!  [f,amp,ph]=ampphspectrum(sum(y,1),fs, 0);
%!  % Calculate amplitude and phase spectrum with windowing:
%!  [fw,ampw,phw]=ampphspectrum(sum(y,1),fs, 0, 0, 'blackman');
%!  % Calculate amplitude and phase spectrum with windowing and zero padding:
%!  [fwz,ampwz,phwz]=ampphspectrum(sum(y,1),fs, 0, 0, 'blackman', [], 10.*length(y));
%!  % Plot signal:
%!  figure; hold on;
%!  plot(t, y,'-')
%!  plot(t, sum(y,1),'-k','linewidth',2)
%!  title('Sampled signal and components'); legend('1st harmonic', '8th harmonic', 'interharmonic', 'signal')
%!  xlabel('time (s)'); ylabel('amplitude (V)');
%!  hold off;
%!  figure; hold on;
%!  plot(sf, sA, '+r', 'markersize', 10, 'linewidth', 2);
%!  stem(f, amp, '-ob', 'filled', 'markersize', 3);
%!  plot(fw, ampw, '-g','linewidth',2);
%!  plot(fwz, ampwz, '-k');
%!  legend('nominal values','DFT', 'blackman window', 'blck. w. + zero padding')
%!  title('Amplitude spectrum')
%!  xlabel('frequency (Hz)'); ylabel('amplitude (V)');
%!  hold off
%!  figure; hold on;
%!  plot(sf, sp, '+r', 'markersize', 10, 'linewidth', 2);
%!  stem(f, ph, '-ob', 'filled', 'markersize', 3);
%!  plot(fw, phw, '-g','linewidth',2);
%!  plot(fwz, phwz, '-k');
%!  legend('nominal values','DFT', 'blackman window', 'blck. w. + zero padding', 'location', 'southwest')
%!  title('Phase spectrum');
%!  xlabel('frequency (Hz)'); ylabel('phase (rad)');
%!  hold off

% ---- tests ---- %<<<1
% tests %<<<1
%!shared fs, t, y, f, amp, ph
%! % Test proper results for odd and even samples:
%!  t=[0:1/3:1](1:end-1);
%!  y=sin(2*pi*1*t+1);
%!  [f,amp,ph]=ampphspectrum(y,3);
%!assert(f,   [0 1],  1e-14);
%!assert(amp, [0 1],  1e-14);
%!assert(ph(2),   1,  1e-14);
%!  t=[0:1/4:1](1:end-1);
%!  y=sin(2*pi*1*t+1);
%!  [f,amp,ph]=ampphspectrum(y,4);
%!assert(f,   [0 1 2],  1e-14);
%!assert(amp, [0 1 0],  1e-14);
%!assert(ph(2),     1,  1e-14);
%! % Test proper results for complex signal:
%!  fs = 50;
%!  t = [0 : 1/fs : 1](1:end-1);
%!  y = [1; 0.5; 0.3].*sin(2.*pi.*[1; 8; 15].*t + [0; 1; 2]);
%!  [f,amp,ph]=ampphspectrum(sum(y,1),fs);
%!assert (amp(2),    1, 1e-14)
%!assert (amp(9),  0.5, 1e-14)
%!assert (amp(16), 0.3, 1e-14)
%! % Test windowing:
%!  y = sin(2.*pi.*10.*t);
%!  [f,amp,ph]=ampphspectrum(y, fs, 0, 0, 'cheb');
%!assert (amp(11),   1, 1e-4)
%!  [f,amp,ph]=ampphspectrum(y, fs, 0, 0, 'cheb', 200);
%!assert (amp(11),   1, 1e-7)
%! % Test windowing and zero padding:
%!  [f,amp,ph]=ampphspectrum(y, fs, 0, 0, 'cheb', [], 10.*length(y));
%!assert (amp(101),  1, 1e-4)
%!  [f,amp,ph]=ampphspectrum(y, fs, 0, 0, 'cheb', 200, 10.*length(y));
%!assert (amp(101),  1, 1e-7)
%!
%! % Test proper error generation:
%!error ampphspectrum (5)
%!error ampphspectrum (1, 2, 3, 4, 5, 6, 7, 8)
%!error ampphspectrum ('a', 1)
%!error ampphspectrum (1, 'a')
%!error ampphspectrum (1, [1:5])
%!error ampphspectrum (1, 1, 1, 1, '', 5, -5)
%!error ampphspectrum (1, 1, 1, 1, 'somewin', 5, 5)

% vim settings line: vim: foldmarker=%{{{,%}}} fdm=marker fen ft=octave
