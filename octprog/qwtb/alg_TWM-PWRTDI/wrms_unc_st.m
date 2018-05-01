function [dPx,dSx,dIx] = wrms_unc_st(lut, amp_a,amp_b, rms_noise_a,rms_noise_b, bits_a,bits_b, f0_per,fs_rat)
% Estimator of the uncertainty for windowed time-integration power or rms value algorihm.
%
% Parameters:
%   lut - lookup table created by make_lut():
%          lut.ax.f0_per - harmonic periods count in the waveform  
%          lut.ax.fs_rat - samples per harmonic period
%          lut.ax.rms_noise - rms noise, two values only: {no noise; any ref. value}
%          lut.qu.dP - max deviation of power W/VA
%          lut.qu.dS - max deviation of power VA/VA
%          lut.qu.dI - max deviation of power V/V (A/A)
%          lut.ref_ab_rat - reference B/A channel ratio for which the LUT was made (def.: 0.01)
%         Note the LUT is made for unity amplitude Ua on channel A and Ub = Ua*lut.ref_ab_rat
%         on channel B.
%   amp_a - channel A amplitude 
%   amp_b - channel B amplitude
%   rms_noise_a - channel A rms noise 
%   rms_noise_b - channel B rms noise
%   bits_a - bit resolution per channel A pk-pk harmonic range 
%   bits_b - bit resolution per channel B pk-pk harmonic range
%   f0_per - harmonic periods in WRMS window
%   fs_rat - samples per harmonic periods
%  

    % normalize:
    nc = 1/amp_a;
    amp_a = nc*amp_a;
    amp_b = nc*amp_b;
    rms_noise_a = nc*rms_noise_a;
    rms_noise_b = nc*rms_noise_b;
    
    % set LUT axes:
    axi = struct();
    axi.f0_per.val = f0_per;
    axi.fs_rat.val = fs_rat;
    
    
    % -- start calculation:
    
    % limit B channel amplitude to minimum available value:
    %amp_b = max(amp_b,lut.ref_ab_rat);
        
    % get LUT axes:
    ax = lut.ax;
    
    % get no noise unc. value:
    axi.rms_noise.val = ax.rms_noise.values(1);
    unc_0 = interp_lut(lut,axi);
    
    % get reference unc. value:
    axi.rms_noise.val = ax.rms_noise.values(end);
    unc_r = interp_lut(lut,axi);
    
    % get effective noise from bit resolution:
    bits_coef = 1.5; % empirical coef.
    bits_noise_a = bits_coef*amp_a.*2.^-bits_a;
    bits_noise_b = bits_coef*amp_b.*2.^-bits_b;
    
    % effective noise of channels:
    rms_noise_a = (bits_noise_a^2 + rms_noise_a^2).^0.5;
    rms_noise_b = (bits_noise_b^2 + rms_noise_b^2).^0.5;
    
    
    % combined relative dependence on rms noise and A amplitude:
    rat_noise_a = (rms_noise_a./ax.rms_noise.values(end))./(amp_a./lut.ref_ab_rat);
    % combined relative dependence on rms noise and B amplitude:
    rat_noise_b = (rms_noise_b./ax.rms_noise.values(end))./(amp_b./lut.ref_ab_rat);
    
    % calculate alg. errors:
    dPx = ((unc_0.dP.val).^2 + (unc_r.dP.val*rat_noise_a).^2 + (unc_r.dP.val*rat_noise_b).^2).^0.5;
    dSx = ((unc_0.dS.val).^2 + (unc_r.dS.val*rat_noise_a).^2 + (unc_r.dS.val*rat_noise_b).^2).^0.5;
    dIx = ((unc_0.dI.val).^2 + (unc_r.dI.val*rat_noise_b).^2).^0.5;

end