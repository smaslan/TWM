function [U_org,U_org_m,U_org_a,U_org_b,U_fix,U_fix_m,U_fix_a,U_fix_b,is_high] = thd_eval_harmonic(win_leak,noise_gain,U_noise,U_nstd,U_harm,ua_harm,u_flat,u_gain,u_spur,probab,MC)
% Part of non-coherent, windowed FFT, THD meter.
%
% This will take harmonic component amplitude, surounding noise level and:
%  1) apply correction to the spectral leakage due to the noise
%  2) randomizes the amplitude using input uncertainties for Monte Carlo evaluation
%  3) evaluates uncertainty limits of the harmonic for given coverage interval
%
% Parameters:
%  win_leak   - window spectral leakage correction lookup (see functions 'fft_window_leak_gen_lookup')
%  noise_gain - gaussian noise amplitude gain for currently used window [-]
%  U_noise    - mean noise amplitude near to the analyzed harmonic(s)
%  U_nstd     - std() of the near-band noise
%  U_harm     - mean harmonic amplitude(s)
%  ua_harm    - type A uncertainty of the harmonic amplitude(s)
%  u_flat     - flatness of the window (maximum scalloping loss +/- 0.5 DFT bin) 
%  u_gain     - standard uncertainty of the combined ADC+transducer gain for each harmonic
%  u_spur     - maximum absolute spurious voltages due to THD of the transducer and ADC (for each harmonic)
%  probab     - coverage interval for uncertainty of the harmonics [-]
%  MC         - Monte Carlo cycles count
%
% Returns:
%  U_org(:,n)   - randomized harmonic voltage vector(s)
%  U_org_m      - mean amplitude(s)
%  U_org_a      - left uncertainty bound(s)
%  U_org_b      - right uncertainty bound(s)
%  U_fix...     - the same, but corrected for window leakage
%  is_high      - 1 if higher harmonics power is significantly above noise
%               - empirical value, see for better definition in code
%
%
% License:
% --------
% This is part of the non-coherent, windowed FFT, THD meter.
% (c) 2017, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.
%
  
  % harmonics count in input list
  H = length(U_harm);
      
  % input parameter lengths must be the same
  if sum(abs(diff(cellfun(@length,{U_noise,U_nstd,U_harm,ua_harm,u_gain,u_spur}))))
    error('Invalid input parameters sizes!');
  end
   
  % reshape inputs to vertical
  U_noise = U_noise(:);
  U_nstd = U_nstd(:);
  U_harm = U_harm(:);
  ua_harm = ua_harm(:);
  u_gain = u_gain(:);
  u_spur = u_spur(:);


  % mean offset caused by spur
  spur_ofs = -0.5*u_spur;
  

  % --- ORIGINAL HARMONIC ---
  % randomize noise level 
  U_n_org = zeros(H,MC);
  for h = 1:H
    a = U_noise(h).^2/U_nstd(h).^2;
    U_n_org(h,:) = gamrnd(a,U_noise(h)/a,1,MC);
  end  
  % case A, harmonic is higher than noise: randomize harmonic level:
  % ###note: was crippled to make it compatible with Matlab < 2016
  %U_a_org = (1.0 + 2*(rand(H,MC) - 0.5)*u_flat + randn(H,MC).*u_gain).*U_harm + ua_harm.*randn(H,MC) + u_spur.*2*(rand(1,MC) - 0.5);
  U_a_org = (1.0 + 2*(rand(H,MC) - 0.5)*u_flat + bsxfun(@times,randn(H,MC),u_gain));
  U_a_org = bsxfun(@times,U_a_org,U_harm) + bsxfun(@times,ua_harm,randn(H,MC)) + bsxfun(@times,1.6*u_spur,2*(rand(1,MC) - 0.333)) + repmat(spur_ofs,[1,MC]);
  
  
  
  % rectify because amplitude cannot be negative
  U_a_org = abs(U_a_org);
  
  % case B, harmonic lower than noise: randomize harmonic level within <0;U_noise> bounds
  U_b_org = rand(H,MC).*U_n_org;
  
  % decide case A or B
  is_a = (U_a_org > U_n_org);
  U_org = (is_a).*U_a_org + (~is_a).*U_b_org;

%   h = 2;
%   figure;
%   hist(U_a_org(h,:),20)  
%   figure;
%   hist(U_org(h,:),20)
    
  % find uncerainty bounds for every harmonic
  U_org_a = zeros(H,1);
  U_org_b = zeros(H,1);
  for h = 1:H
    [sci,U_org_a(h),U_org_b(h)] = scovint(U_org(h,:),probab,U_harm(h));
  end
      
  % return mean amplitudes
  % note: normally I would go for arithmetic mean of the randomized data but it is so assymetric
  %       that it is not a good estimate. Instead I assume mean is equal to the input amplitudes:
  %U_org_m = mean(U_org,2);
  U_org_m = abs(U_harm + spur_ofs);
  
  
    
  % --- FIXED HARMONICS ---
  % corrections to the noise leakage  
    
  % apply noise gain to the noise level (effect of the window leakage)
  U_n = U_n_org/noise_gain;
  
  % case A, harmonic is higher than noise: fix the leakage gain
  U_a = reshape(fft_window_leak_fix_amp(win_leak,U_a_org(:),U_n(:)),H,MC);
     
  % case B: harmonic amplitude is lower or the same as noise: assume it is anywhere in the noise
  % cannot say much about it, so uniform distribution
  %U_b = rand(H,MC).*U_n;
      
  % decide between A and B according to the randomized uncorrected amplitude
  %is_a = bsxfun(@gt,U_a_org,(U_noise + 0*U_nstd));
  %U_fix = U_a.*(is_a) + U_b.*(~is_a);
  U_fix = U_a;
  
  % rectify randomized data
  U_fix = abs(U_fix);
  
  
  % --- now calculate estimate of the corrected harmonic values ---
  %U_fix_m = mean(U_fix,2);
  % All stuff above was just for uncertainty distribution, but we cannot use mean value
  % because it's an amplitude, thus it would produce a shift in the mean value (effect of abs() function).
  % So now I simply repeat the calculation with input measured values directly without randomization.
  % magic constant (this is purely empirical correction):
  mk = 1.1;
  % mean input noise:
  U_noise_fix = U_noise/noise_gain*mk;
  % corrected harmonics from the mean input harmonic levels:
  %U_fix_m = fft_window_leak_fix_amp(win_leak,U_harm,U_noise_fix);
  U_fix_m = fft_window_leak_fix_amp(win_leak,U_org_m,U_noise_fix);
      
  % --- calculate uncertainty ---
  % find uncertainty bounds for every harmonic
  U_fix_a = zeros(H,1);
  U_fix_b = zeros(H,1);
  for h = 1:H
    [sci,U_fix_a(h),U_fix_b(h)] = scovint(U_fix(h,:),probab,U_fix_m(h));
  end
    
  
  
  
  
  % --- decide if most of the harmonics are above noise level ---
  % harmonic/noise ratios
  ratios = U_harm(2:end)./U_noise(2:end);
  % harmonics are signifficantly above noise:
  is_high = mean(ratios.^2)^0.5 > 2.0;
  
    
end