function [ws,wfbin,flat] = thd_window_spectrum(f_real,f_bin,f_bin_step,wtype)
% Part of non-coherent, windowed FFT, THD meter
% (c) 2013-2017, Stanislav Maslan, smaslan@cmi.cz, CMI
% Distributed under GNU Lesser General Public License (LGPL).
%
% Returns spectrum of the window for desired peak position in between two DFT bins.
%
%  f_real     - real frequency of the signal
%  f_bin      - frequency of the peak DFT bin from signal spectrum
%  f_bin_step - bin frequency step
%  wtype      - name of the window function
%
% Result:
%  ws - window spectrum
%  wfbin - spectrum frequency ids (0 for maximum peak, 1, 2, 3 ..., -1, -2, -3, ... for others)
%
%
% License:
% --------
% This is part of the non-coherent, windowed FFT, THD meter.
% (c) 2017, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.
%

  % get window's time function
  M = 32;
  w(:,1) = window_coeff(wtype, M, 'periodic');
  
  % relative scalloping loss for +-0.5 DFT bin
  if strcmpi(wtype,'flattop_248D')
    flat = 1.04e-4;
  else
    error(sprintf('Not defined scalloping loss for window ''%s''!',wtype));
  end
      
  % calculate symmetric spectrum
  k = 100;
  N = length(w)*k;
  ws = fft(w,N);
  ws = fftshift(ws);
  
  % interpolate in the spectrum to get coefficients for non coherent signal with frequency f_real 
  n = (f_real - f_bin)/f_bin_step;
  wk = (N/2 + 1 + round(n*k)) + [-M/2:M/2]*k;
  ws = ws(wk(find(wk>=1 & wk<=length(ws))));
  
  % normalize coeffs to unity gain for top peak 
  [v,id] = max(ws);
  ws = ws/v;
  
  % generate frequency ids vector  
  wfbin = (1:length(ws)) - id;
  
end