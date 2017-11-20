function alginfo = alg_info() %<<<1
% Part of QWTB. Info script for algorithm SP-WFFT.
%
% See also qwtb

alginfo.id = 'SP-WFFT';
alginfo.name = 'Spectrum by means of Windowed Discrete Fourier Transform';
alginfo.desc = 'Calculates amplitude and phase spectrum by means of Discrete Fourier Transform with windowing and/or zero padding. Result is normalized. Follwing windows are implemented: barthann, bartlett, blackman, blackmanharris, blackmannuttall, bohman, cheb, flattop_matlab, flattop_SFT3F, flattop_SFT4F, flattop_SFT5F, flattop_SFT3M, flattop_SFT4M, flattop_SFT5M, flattop_248D, gaussian, hamming, hanning, kaiser, nuttall, parzen, rect, triang, tukey, welch.';
alginfo.citation = ' Various sources. See algorithm scripts for details. A. V. Oppenheim and R. W. Schafer, Discrete-Time Signal Processing. Peter Lynch, "The Dolph-Chebyshev Window: A Simple Optimal Filter", Monthly Weather Review, Vol. 125, pp. 655-660, April 1997, http://www.maths.tcd.ie/~plynch/Publications/Dolph.pdf . C. Dolph, "A current distribution for broadside arrays which optimizes the relationship between beam width and side-lobe level", Proc. IEEE, 34, pp. 335-348. https://www.mathworks.com/help/signal/ref/flattopwin.html . D`Antona, Gabriele, and A. Ferrero. Digital Signal Processing for Measurement Systems. New York: Springer Media, 2006, pp. 70–72. Gade, Svend, and Henrik Herlufsen. "Use of Weighting Functions in DFT/FFT Analysis (Part I)." Windows to FFT Analysis (Part I): Bruel and Kjaer Technical Review, No. 3, 1987, pp. 1-28. G. Heinzel, `Spectrum and spectral density estimation by the Discrete Fourier transform (DFT), including a comprehensive list of window functions and some new flat-top windows`, IEEE, 2003. Fredric J. Harris, "On the Use of Windows for Harmonic Analysis with the Discrete Fourier Transform, Proceedings of the IEEE", Vol. 66, No. 1, January 1978, Page 67, Equation 38. Implemented by: Sylvain Pelissier, Andreas Weingessel, Muthiah Annamalai, Andre Carezia, Vera Novaková Zachovalova, Paul Kienzle, Paul Kienzle, Laurent Mazet, Muthiah Annamalai, Mike Gross, Peter V. Lanspeary.'; 
alginfo.remarks = 'If sampling frequency |fs| is not supplied, wrapper will calculate |fs| from sampling time |Ts| or if not supplied, first two elements of time series |t| are used to calculate |fs|. If |window| is not specified, a rectangular (none) window will be used. If |window| is `cheb` and |cheb_att| is not specified, a value of 100 dB is set. If |window| is `gaussian` and |gaussian_width| is not specified, a value of 1 is set. If |window| is `kaiser` and |kaiser_att| is not specified, a value of 0.5 is set. If |window| is `tukey` and |tukey_ratio| is not specified, a value of 0.5 is set.';
alginfo.license = 'Mixed license - every window function has its own license.';

alginfo.inputs(1).name = 'fs';
alginfo.inputs(1).desc = 'Sampling frequency';
alginfo.inputs(1).alternative = 1;
alginfo.inputs(1).optional = 0;
alginfo.inputs(1).parameter = 0;

alginfo.inputs(2).name = 'Ts';
alginfo.inputs(2).desc = 'Sampling time';
alginfo.inputs(2).alternative = 1;
alginfo.inputs(2).optional = 0;
alginfo.inputs(2).parameter = 0;

alginfo.inputs(3).name = 't';
alginfo.inputs(3).desc = 'Time series';
alginfo.inputs(3).alternative = 1;
alginfo.inputs(3).optional = 0;
alginfo.inputs(3).parameter = 0;

alginfo.inputs(4).name = 'y';
alginfo.inputs(4).desc = 'Sampled values';
alginfo.inputs(4).alternative = 0;
alginfo.inputs(4).optional = 0;
alginfo.inputs(4).parameter = 0;

alginfo.inputs(5).name = 'window';
alginfo.inputs(5).desc = 'Name of window function';
alginfo.inputs(5).alternative = 0;
alginfo.inputs(5).optional = 1;
alginfo.inputs(5).parameter = 1;

alginfo.inputs(6).name = 'cheb_att';
alginfo.inputs(6).desc = 'Only for Dolph-Chebyshev window: stop-band attenuation in dB';
alginfo.inputs(6).alternative = 0;
alginfo.inputs(6).optional = 1;
alginfo.inputs(6).parameter = 1;

alginfo.inputs(7).name = 'gaussian_width';
alginfo.inputs(7).desc = 'Only for Gaussian window: width of the window in Hz';
alginfo.inputs(7).alternative = 0;
alginfo.inputs(7).optional = 1;
alginfo.inputs(7).parameter = 1;

alginfo.inputs(8).name = 'kaiser_att';
alginfo.inputs(8).desc = 'Only for Kaiser window: stop-band attenuation in FFT bins';
alginfo.inputs(8).alternative = 0;
alginfo.inputs(8).optional = 1;
alginfo.inputs(8).parameter = 1;

alginfo.inputs(9).name = 'tukey_ratio';
alginfo.inputs(9).desc = 'Only for Tukey window: ratio between constant and cosine section';
alginfo.inputs(9).alternative = 0;
alginfo.inputs(9).optional = 1;
alginfo.inputs(9).parameter = 1;

alginfo.inputs(9).name = 'fft_padding';
alginfo.inputs(9).desc = 'Zero padding of signal in samples';
alginfo.inputs(9).alternative = 0;
alginfo.inputs(9).optional = 1;
alginfo.inputs(9).parameter = 1;


alginfo.outputs(1).name = 'f';
alginfo.outputs(1).desc = 'Frequency series';

alginfo.outputs(2).name = 'A';
alginfo.outputs(2).desc = 'Amplitude spectrum';

alginfo.outputs(3).name = 'ph';
alginfo.outputs(3).desc = 'Phase spectrum';

alginfo.providesGUF = 0;
alginfo.providesMCM = 0;

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
