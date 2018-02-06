function [amp_vec] = fft_window_leak_fix_amp(win_leak,U_vec,noise_vec)
% Part of non-coherent, windowed FFT, THD meter.
%
% This is itterative solver that will find original harmonic amplitude
% before it was amplified by the noise leakage into the harmonic DFT bin.
%
% Parameters:
%  win_leak    - window spectral leakage correction lookup (see functions 'fft_window_leak_gen_lookup')
%  U_vec       - uncorrected harmonic amplitude(s)
%  noise_vec   - near-band noise amplitude(s)
%
% Note the 'U_vec' and 'noise_vec' may be scalar, vectors, or matrices of the same sizes.
%
% Returns:
%  amp_vec - corrected harmonic amplitude(s)
%
%
% License:
% --------
% This is part of the non-coherent, windowed FFT, THD meter.
% (c) 2017, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.
%
            
  % fix harmonic level (spectral leakage correction)
  amp_vec = U_vec;
  for m = 1:40
    amp_vec = U_vec./(fft_window_leak_interp(win_leak,noise_vec./amp_vec));  
  end  
    
end


function [gain] = fft_window_leak_interp(win_leak,ratio)
  
  % limit ratios to the valid range
  ratio = min(max(ratio,win_leak.a_ratios(1)),win_leak.a_ratios(end)*(1-1e-6));
    
  % interpolate with limits
  %gain = interp1q(win_leak.a_ratios,win_leak.a_gains,ratio);
  % ###note: may need extrapolation to make it safe
  % ###note: may be painfully slow, interp1q was faster but not supported anymore
  gain = interp1(win_leak.a_ratios,win_leak.a_gains,ratio,'linear','extrap');
   
end