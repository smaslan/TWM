%% 3-point interpolated DFT frequency estimator
% Example for algorithm iDFT3p.
%
% iDFT3p is an algorithm for estimating the frequency, amplitude, phase and offset of the fundamental
% component using interpolated discrete Fourier transform. Rectangular or Hann window can be used
% for DFT.';
% See also Krzysztof Duda: Interpolation algorithms of DFT for parameters estimation of sinusoidal
% and damped sinusoidal signals. In S. M. Salih, editor, Fourier Transform - Signal Processing,
% chapter 1, pages 3-32, InTech, 2012.
% http://www.intechopen.com/books/fourier-transform-signal-processing/interpolated-dft
% Implemented by Rado Lapuh, 2016.';

%% Generate sample data
% Two quantities are prepared: |Ts| and |y|, representing 0.5 second of sinus waveform of nominal
% frequency 100 Hz, nominal amplitude 1 V and nominal phase 1 rad, sampled with sampling time 0.1
% ms, with offset 0.1 V. The sampling is not coherent.
DI = [];
Anom = 1; fnom = 100; phnom = 1; Onom = 0.1;
DI.Ts.v = 1e-4;
t = [0:DI.Ts.v:0.5];
DI.y.v = Anom*sin(2*pi*fnom*t + phnom) + Onom;

%% Call algorithm
% First a rectangular window will be selected to estimate main signal properties. Use QWTB to apply
% algorithm |iDFT3p| to data |DI| and put results into |DOr|.
DI.window.v = 'rectangular';
DOr = qwtb('iDFT3p', DI);
%%
% Next a Hann window will be selected to estimate main signal properties Results will be put into |DOh|.
DI.window.v = 'Hann';
DOh = qwtb('iDFT3p', DI);

%% Display results
% Results is the amplitude, frequency and phase of sampled waveform. For rectangular window, the
% error from nominal in parts per milion is:
f_re = (DOr.f.v - fnom)./fnom .* 1e6
A_re = (DOr.A.v - Anom)./Anom .* 1e6
ph_re = (DOr.ph.v - phnom)./phnom .* 1e6
O_re = (DOr.O.v - Onom)./Onom .* 1e6
%%
% For Hann window:
f_he = (DOh.f.v - fnom)./fnom .* 1e6
A_he = (DOh.A.v - Anom)./Anom .* 1e6
ph_he = (DOh.ph.v - phnom)./phnom .* 1e6
O_he = (DOh.O.v - Onom)./Onom .* 1e6
