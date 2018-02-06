function [f,sig,fs,f_bin_step,f_sig,f_std,rms_v] = thd_proc_waves(t,w_sig,init_freq,fit_freq,f_fund_zc,window_type,verbose)
% Part of non-coherent, windowed FFT, THD meter.
% Calculates windowed amplitude spectrum of the signals.
%
% Input parameters:
%   t(:,1)      - input time vector [s]
%   w_sig(:,n)  - input waveforms, each column 'n' for one repeated measurement
%   init_freq   - initial guess of the fundamental frequency [Hz]
%   fit_freq    - search mode of fundamental freq.:
%                  0 - user value 'init_freq' (no search)
%                  1 - 4-param sine wave fitting (uses 'init_freq' as initial guess)
%                  2 - PSFE algorithm (uses 'init_freq' as initial guess)
%   f_fund_zc   - moving average filter size for zero-cross method (usually 20)
%   window_type - name string of the used window function
%   verbose     - 0: shut up mode, 1: some information will be printed
%
% Outputs:
%   f           - frequency axis of the returned spectra [Hz]
%   sig(:,n)    - signal spectra, one column per signal 'n'
%   fs          - detected sampling rate [Hz]
%   f_bin_step  - frequency step of the DFT bins [Hz]
%   f_sig       - mean detected frequency of the input signals 
%   f_std       - stdev of the detected frequency [Hz]
%   rms_v       - RMS estimates of the signals 
%
%
% License:
% --------
% This is part of the non-coherent, windowed FFT, THD meter.
% (c) 2017, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT
%  
  
  if verbose
    disp('Processing signal waveforms:');
  end
  
  % calculate window rms gain coeficient
  WN = 100;
  wc = window_coeff(window_type, WN, 'periodic');
  w_gain = mean(wc);
  w_rms = sum(wc.^2)^0.5/WN^0.5;
      
  % sampling rate [Hz]
  fs = 1./(t(2) - t(1));
    
  %%% for each input signal %%%
  n = size(w_sig,2);
  sig = [];
  s_freq = zeros(1,n);
  rms_v = [];
  for k = 1:n
  
    %% print progress
    if verbose
      disp([' - wave #' int2str(k)]);
    end 
        
    %% find fundamental frequency of the signal
    if init_freq ~= 0
      % fixed freq is defined
      s_freq(k) = init_freq;
    else
      % zeros-cross or fitting mehod enabled
      s_freq(k) = thd_find_freq(t,w_sig(:,k),fit_freq,f_fund_zc,0);             
    end
        
    %% get waveform spectrum
    [f,amp] = ampphspectrum(w_sig(:,k), fs, 0, 0, window_type, [], 0);
        
    %% allocate results buffer
    if k == 1      
      sig = zeros(length(amp),n);
    end
    
    % estimate RMS value of the signal
    rms_v(1,k) = sum(0.5*(amp*w_gain).^2)^0.5/w_rms;
    
    %% add new result into buffer
    sig(:,k) = amp;
  end
    
    
  %% average fundamental freqs.
  if ~init_freq  
    f_sig = mean(s_freq);
    f_std = std(s_freq);
  else
    f_sig = init_freq;
    f_std = 0;
  end
  
  %% sampling rate
  fs = 1/(t(2) - t(1));
  
  %% bin frequency step [Hz]
  f_bin_step = f(2) - f(1);
  
  % frequency vector to vertical
  f = f(:);

  
  if(verbose)
    disp('');
    printf('Fundamental f = %s\n',unc2str_si(f_sig,f_std,' Hz'));    
  end
   
end
