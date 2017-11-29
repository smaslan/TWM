%
% A simple RMS calculation routine for non-coherent signals.
% 1) Uses Hann window on the signal.
% 2) Calculates ordinary RMS.
% 3) Corrects the RMS by the RMS value of the window.
%
% Note: I have no idea how is this method called or who inveted it.
%       I made that code ad hoc.
%
% Note: Needs at least 2 full periods of the signal.
% Note: Uncertainty estimator is veeeery basic.
%
% Coder:   Stanislav Maslan, smaslan@cmi.cz
% Version: V0.1, 1.11.2017
%
function [rms, unc, spec_f, spec_Y] = wrms(y, fs)

  % samples count
  N = numel(y);

  % generate window (periodic)
  w = hanning(N + 1);
  w = w(1:end-1);
  w = reshape(w,size(y));
  
  % calculate inverse RMS of the window 
  W = mean(w.^2)^-0.5;
  
  % calculate signal RMS value
  rms = W*mean((w.*y).^2).^0.5;
  
  
  
  % --- not the fun part - estimate uncertainty ---
  
  % get spectrum 
  [spec_f, spec_Y] = ampphspectrum(y, fs, 0, 0, 'flattop_matlab', [], 0);
    
  % find fundamental freq.
  [v,mid] = max(spec_Y(2:end));
  
  % fundamental periods count per record
  P = fs/spec_f(mid);
  
  % worst case relative error
  err = max(0.03*P^-5,1e-9);
  
  % uncertainty estimate
  unc = err/3^0.5;
  
end