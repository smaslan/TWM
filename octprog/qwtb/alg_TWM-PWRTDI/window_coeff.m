function w = window_coeff(varargin)
% -- Function File: W = window_coeff ()
% -- Function File: W = window_coeff (WIN, L)
% -- Function File: W = window_coeff (WIN, L, [ PAR ] )
% -- Function File: W = window_coeff (..., 'periodic')
%     Obtains window coefficients of window function WIN for length L.
%     Some windows requires additional parameter PAR.  If not specified,
%     a default value of window function is used.
%
%     If keyword 'periodic' is supplied, a window wraps around the cyclic
%     interval and is intended for use with the DFT.
%
%     Without input arguments, a list of known window functions is
%     returned.
%
%     Example: Generate window coefficients for welch window function:
%          window_coeff('kaiser', 3, 'periodic');
%
%     See also demo for this function:
%          demo window_coeff

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

% Authors: Martin Šíra <msiraATcmi.cz>
% Created: 2017
% Version: 0.1
% Keywords: window, fft 

% ---- available windows ---- %<<<1
avail_windows = {...
        'barthann',...
        % Modified Bartlett-Hann window.
        % No additional arguments.
        % Implementation: 2007 Sylvain Pelissier <sylvain.pelissier@gmail.com>.
        % License: GNU GPL v3.
        'bartlett',...
        % Bartlett (triangular) window.
        % No additional arguments.
        % Citation: A. V. Oppenheim & R. W. Schafer, Discrete-Time Signal Processing.
        % Implementation: AW <Andreas.Weingessel@ci.tuwien.ac.at>.
        % License: GNU GPL v3.
        'blackman',...
        % Blackman window.
        % No additional arguments.
        % Citation: A. V. Oppenheim & R. W. Schafer, Discrete-Time Signal Processing. 
        % Implementation: AW <Andreas.Weingessel@ci.tuwien.ac.at>.
        % License: GNU GPL v3.
        'blackmanharris',...
        % Blackman-Harris window.
        % Additional arguments: 1: 'symmetric' (default) or 'periodic'.
        % Implementation: Sylvain Pelissier <sylvain.pelissier@gmail.com>.
        % License: GNU GPL v3.
        'blackmannuttall',...
        % Blackman-Nuttall window.
        % Additional arguments: 1: 'symmetric' (default) or 'periodic'.
        % Implementation: Muthiah Annamalai <muthiah.annamalai@uta.edu>.
        % License: GNU GPL v3.
        'bohman',...
        % Bohman window.
        % No additional arguments.
        % Implementation: Sylvain Pelissier <sylvain.pelissier@gmail.com>.
        % License: GNU GPL v3.
        'cheb',...
        % Dolph-Chebyshev window.
        % Additional arguments: 1: The Fourier transform of the window has a stop-band attenuation of `at` dB. The default attenuation value is 100 dB.
        % Citation: Peter Lynch, "The Dolph-Chebyshev Window: A Simple Optimal Filter", Monthly Weather Review, Vol. 125, pp. 655-660, April 1997, http://www.maths.tcd.ie/~plynch/Publications/Dolph.pdf. C. Dolph, "A current distribution for broadside arrays which optimizes the relationship between beam width and side-lobe level", Proc. IEEE, 34, pp. 335-348.
        % Implementation: André Carezia <acarezia@uol.com.br>.
        % License: GNU GPL v3.
        'flattop_matlab',...
        % Flat top window.
        % No additional arguments.
        % Citation: https://www.mathworks.com/help/signal/ref/flattopwin.html. D'Antona, Gabriele, % and A. Ferrero. Digital Signal Processing for Measurement Systems. New York: Springer % Media, 2006, pp. 70–72. Gade, Svend, and Henrik Herlufsen. "Use of Weighting Functions in DFT/FFT Analysis (Part I)." Windows to FFT Analysis (Part I): Brüel & Kjær Technical Review, No. 3, 1987, pp. 1–28.
        % Implementation: Věra Nováková Zachovalová, <msira@cmi.cz>
        % License: MIT License.
        'flattop_SFT3F',...
        % Flat top window.
        % No additional arguments.
        % Citation: G. Heinzel, ‘Spectrum and spectral density estimation by the Discrete Fourier transform (DFT), including a comprehensive list of window functions and some new flat-top windows’, IEEE, 2003.
        % Implementation: Věra Nováková Zachovalová, <msira@cmi.cz>
        % License: MIT License.
        'flattop_SFT4F',...
        % Flat top window.
        % No additional arguments.
        % Citation: G. Heinzel, ‘Spectrum and spectral density estimation by the Discrete Fourier transform (DFT), including a comprehensive list of window functions and some new flat-top windows’, IEEE, 2003.
        % Implementation: Věra Nováková Zachovalová, <msira@cmi.cz>
        % License: MIT License.
        'flattop_SFT5F',...
        % Flat top window.
        % No additional arguments.
        % Citation: G. Heinzel, ‘Spectrum and spectral density estimation by the Discrete Fourier transform (DFT), including a comprehensive list of window functions and some new flat-top windows’, IEEE, 2003.
        % Implementation: Věra Nováková Zachovalová, <msira@cmi.cz>
        % License: MIT License.
        'flattop_SFT3M',...
        % Flat top window.
        % No additional arguments.
        % Citation: G. Heinzel, ‘Spectrum and spectral density estimation by the Discrete Fourier transform (DFT), including a comprehensive list of window functions and some new flat-top windows’, IEEE, 2003.
        % Implementation: Věra Nováková Zachovalová, <msira@cmi.cz>
        % License: MIT License.
        'flattop_SFT4M',...
        % Flat top window.
        % No additional arguments.
        % Citation: G. Heinzel, ‘Spectrum and spectral density estimation by the Discrete Fourier transform (DFT), including a comprehensive list of window functions and some new flat-top windows’, IEEE, 2003.
        % Implementation: Věra Nováková Zachovalová, <msira@cmi.cz>
        % License: MIT License.
        'flattop_SFT5M',...
        % Flat top window.
        % No additional arguments.
        % Citation: G. Heinzel, ‘Spectrum and spectral density estimation by the Discrete Fourier transform (DFT), including a comprehensive list of window functions and some new flat-top windows’, IEEE, 2003.
        % Implementation: Věra Nováková Zachovalová, <msira@cmi.cz>
        % License: MIT License.
        'flattop_248D',...
        % Flat top window.
        % No additional arguments.
        % Citation: G. Heinzel, ‘Spectrum and spectral density estimation by the Discrete Fourier transform (DFT), including a comprehensive list of window functions and some new flat-top windows’, IEEE, 2003.
        % Implementation: Věra Nováková Zachovalová, <msira@cmi.cz>
        % License: MIT License.
        'gaussian',...
        % Gaussian convolution window.
        % Additional arguments: 1: The width of the window is inversely proportional to the parameter `a`. Width a is measured in frequency units (sample rate/num samples). It should be f when multiplying in the time domain, but 1/f when multiplying in the frequency domain (for use in convolutions).
        % Implementation: Paul Kienzle <pkienzle@users.sf.net>
        % License: GNU GPL v3.
        'hamming',...
        % Hamming window.
        % No additional arguments.
        % Citation: A. V. Oppenheim & R. W. Schafer, Discrete-Time Signal Processing.
        % Implementation: AW <Andreas.Weingessel@ci.tuwien.ac.at>.
        % License: GNU GPL v3.
        'hanning',...
        % Hanning window.
        % No additional arguments.
        % Citation: A. V. Oppenheim & R. W. Schafer, Discrete-Time Signal Processing.
        % Implementation: AW <Andreas.Weingessel@ci.tuwien.ac.at>.
        % License: GNU GPL v3.
        'kaiser',...
        % Kaiser window.
        % Additional arguments: 1: The Fourier transform of the window has a stop-band attenuation that is derived from the parameter `beta`.
        % Citation: A. V. Oppenheim & R. W. Schafer, Discrete-Time Signal Processing.
        % License: GNU GPL v3.
        'nuttall',...
        % Blackman-Harris window defined by Nuttall.
        % Additional arguments: 1: 'symmetric' (default) or 'periodic'.
        % Implementation: Sylvain Pelissier <sylvain.pelissier@gmail.com>.
        % License: GNU GPL v3.
        'parzen',...
        % Parzen window.
        % No additional arguments.
        % Implementation: Sylvain Pelissier <sylvain.pelissier@gmail.com>.
        % License: GNU GPL v3.
        'rect',...
        % Rectangular window.
        % No additional arguments.
        % Implementation: Sylvain Pelissier <sylvain.pelissier@gmail.com>.
        % License: GNU GPL v3.
        'triang',...
        % Triangular window.
        % No additional arguments.
        % Implementation: Paul Kienzle <pkienzle@users.sf.net>.
        % License: GNU GPL v3.
        'tukey',...
        % Tukey (cosine-tapered) window.
        % Additional arguments: 1: `r` defines the ratio between the constant section and and the cosine section.
        % Citation: Fredric J. Harris, "On the Use of Windows for Harmonic Analysis with the Discrete Fourier Transform, Proceedings of the IEEE", Vol. 66, No. 1, January 1978, Page 67, Equation 38.
        % Implementation: Laurent Mazet <mazet@crm.mot.com.
        % License: GNU GPL v3.
        'welch'
        % Welch window.
        % Additional arguments: 1: 'symmetric' (default) or 'periodic'.
        % Implementation: Muthiah Annamalai <muthiah.annamalai@uta.edu>, Mike Gross <mike@appl-tech.com>, Peter V. Lanspeary <pvl@mecheng.adelaide.edu.au>.
        % License: GNU GPL v3.
        };

% ---- function body ---- %<<<1
if nargin == 0
        % return available windows:
        w = avail_windows;
else
        if nargin == 1
                print_usage
        end
        if nargin >= 2
                win = varargin{1};
                L = varargin{2};
        end
        if ~ischar(win)
                print_usage
        end
        if ~any( cellfun(@strcmpi, avail_windows, repmat({win}, size(avail_windows))) )
                error(['window_coeff: unknown window `' win '`']);
        end
        if ~( (isscalar (L) && (L == fix (L)) && (L > 0)))
                error ('window_coeff: L must be a positive integer');
        end
        % set default value for periodic/symmetric:
        periodic = 0;
        % set default value for third argument:
        thirdarg = [];
        if nargin > 2
                restin = varargin(3:end);
                charinids = cellfun(@ischar, restin);
                charin = restin(charinids);
                if ~isempty(charin)
                        if any( cellfun(@strcmpi, charin, repmat({'periodic'}, size(charin))) )
                                % found keyword periodic:
                                periodic = 1;
                        end
                end
                restin = restin(not(charinids));
                if ~isempty(restin)
                        thirdarg = restin{1};
                end
        end% nargin > 2
        % get window coefficients:
        if periodic
                L = L + 1;
        end
        switch win
                case {'bartlett' 'blackman' 'blackmanharris' 'blackmannuttall' 'hamming' 'hanning' 'triang'}
                % windows without additional argument or special treatment:
                        w = feval(win, L);
                case {'barthann' 'bohman' 'nuttall' 'parzen' 'rect' 'welch'}
                % windows needed to add 'win' to get function name:
                        w = feval([win 'win'], L);
                % windows from function flattop:
                case 'flattop_matlab'
                        w = flattop(L, 1);
                case 'flattop_SFT3F'
                        w = flattop(L, 2);
                case 'flattop_SFT4F'
                        w = flattop(L, 3);
                case 'flattop_SFT5F'
                        w = flattop(L, 4);
                case 'flattop_SFT3M'
                        w = flattop(L, 5);
                case 'flattop_SFT4M'
                        w = flattop(L, 6);
                case 'flattop_SFT5M'
                        w = flattop(L, 7);
                case 'flattop_248D'
                        w = flattop(L, 8);
                % windows with additional arguments:
                case 'cheb'
                        if isempty(thirdarg)
                                w = chebwin(L);
                        else
                                w = chebwin(L, thirdarg);
                        end
                case 'gaussian'
                        if isempty(thirdarg)
                                w = gaussian(L);
                        else
                                w = gaussian(L, thirdarg);
                        end
                case 'kaiser'
                        if isempty(thirdarg)
                                w = kaiser(L);
                        else
                                w = kaiser(L, thirdarg);
                        end
                case 'tukey'
                        if isempty(thirdarg)
                                w = tukeywin(L);
                        else
                                w = tukeywin(L, thirdarg);
                        end
        end
        if periodic
                w = w(1:end-1);
        end
end% nargin == 0

end

% ---- demo ---- %<<<1
%!demo
%! L = 2^12;
%! avail_windows = window_coeff();
%! figure
%! hold on
%! for i = 1:length(avail_windows)
%!         w = window_coeff(avail_windows{i}, L);
%!         w = max(1e-8, w);
%!         plot(w)
%! endfor
%! legend(avail_windows);
%! title('Window coefficients, symmetric')
%! xlabel('time domain')
%! ylabel('window coefficient')
%! hold off
%!
%! avail_windows = window_coeff();
%! figure
%! L = 32;
%! n = 2^12;
%! col = jet(length(avail_windows));
%! hold on
%! for i = 1:length(avail_windows)
%!         % generate periodic window:
%!         w = window_coeff(avail_windows{i}, L+1);
%!         w = w(1:end-1);
%!         sp = fftshift(abs(fft(postpad(w, n))))./sum(w);
%!         sp = max(1e-8, sp);
%!         plot(sp, '-', 'color', c(i,:))
%! endfor
%! legend(avail_windows);
%! title('Spectrum, periodic window coefficients, zero padded')
%! xlabel('frequency domain')
%! ylabel('amplitude')
%! hold off

% ---- tests ---- %<<<1
%!shared avail_windows, i, res
%! avail_windows = window_coeff();
%!assert ( length(avail_windows) > 0 );
%! for i = 1:length(avail_windows)
%!      res{i} = window_coeff(avail_windows{i}, 10);
%! endfor
%!assert( all(not(cellfun('isempty', res))) )
%!assert( all((cellfun('numel', res)) == 10) )
%!
%!assert (window_coeff('welch', 3), [0; 1; 0]);
%!assert (window_coeff('welch', 2, 'periodic'), [0; 1]);
%!assert (window_coeff('tukey', 3, 0, 'periodic'), [1; 1; 1]);
%!
%!error window_coeff ('bad_window')
%!error window_coeff (5)
%!error window_coeff ('rect', 0.5)
%!error window_coeff ('rect', -1)
%!error window_coeff ('rect', ones (1, 4))

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
