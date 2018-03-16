function [win_leak,noise_gain] = fft_window_leak_gen_lookup(min_ratio,max_ratio,steps,iter,wtype)
% Part of non-coherent, windowed FFT, THD meter
%
% This precalculates apparent gain of the harmonic component by near-band noise.
% This effect happens due to the spectral leakage of the noise to the harmonic
% DFT bin via the window function. 
%
% Inputs:
%   min_ratio - minimum ratio of the harmonic-to-noise amplitude (10^min_ratio)
%   max_ratio - minimum ratio of the harmonic-to-noise amplitude (10^max_ratio)
%   steps     - number of lookup steps (at least some 20)
%   iter      - number of iterations for numeric evaluation (at least 10000)
%   wtype     - window function name string
%
% Outputs:
%   win_leak - precalculated noise gain: 
%     win_leak.a_ratios - nominal SNR ratios
%     win_leak.a_gains - calculated amplitude gains 
%   noise_gain - amplification of the noise amplitude due to the windowing  
%
%
% License:
% --------
% This is part of the non-coherent, windowed FFT, THD meter.
% (c) 2017, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.
%
  
  % window amplitude spectrum coeficients
  [ws] = thd_window_spectrum(1000,1000,1,wtype);
  w = abs(ws);
  
  % generate random angles for every window 'w' component
  p = rand(length(w),iter)*2*pi;
  % angles to exponential form
  P = exp(i*p);
  
  % generate signal/noise ratios in desired range  
  a_ratios(:,1) = logspace(min_ratio,max_ratio,steps);

  % Calcualte signal gain for each ratio SNR
  % This complicated looking line of code does very simple thing.
  % From definition the windowing of signal in timedomain is equal to 
  % convolution of the images of signal and window.
  % So each coefficient of the window spectrum multiples the noise
  % DFT bin and adds up to the signal DFT bin. If the complex spectrum is 
  % evaluated used, this will cause only more noise in the signal DFT bin,
  % because the noise has random amplitude and phase. But we are calculating
  % amplitude spectrum from the windowed FFT and this will lead to the
  % systematic error. 
  %
  % Assuming simple example:
  %  spectrum has frequencies: f1, f2, f3
  %  window spectrum has coeficients (amplitudes): w1, w2, w3
  %  noise has mean amplitude: b 
  %  signal is pure real with amplitude: a2
  %  iterations count: I 
  %
  % Then the aparent gain due to the noise leakage is:
  % a1_gain = sum( abs( sum(w(k)*e^(-j*2*pi*R(i,k)), k=0..2)*b + a2 ), i=1..I)/I/a2,
  % where R() is uniform random number 0..1.   
  %  
  a_gains = mean(abs(1 + a_ratios*sum(bsxfun(@times,w,P))),2);
  
  % expand lookup range to zero SNR
  win_leak.a_ratios = [0;a_ratios];
  win_leak.a_gains = [1;a_gains];
  
  
  % Calculate gausinan noise gain for the window
  % This is one more useful paramter, because not only signal is amplified by the noise.
  % The same effect happens for noise itsels.
  % Following code estimates noise gain using random number generator and windowed and 
  % not windowed FFT. 
  %
  % generate gaussian noise
  NN = 100000;
  un = randn(NN,1)/2*NN^0.5;
  
  % spectrum with window
  [nfs, A, ph] = ampphspectrum(un, 1, 0, 0, wtype, [], 0);
  ns_w = A.*exp(j*ph);
  
  % spectrum wihtout window
  [nfs, A, ph] = ampphspectrum(un, 1, 0, 0, '', [], 0);
  ns = A.*exp(j*ph);
  
  % noise gain of amplitude spectrum
  noise_gain = mean(abs(ns_w).^2)^0.5/mean(abs(ns).^2)^0.5;
      
end