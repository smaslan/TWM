function [dPx,dSx,dIx,dUx] = wrms_unc_spurr(lut, amp_a,amp_b, f_spurr,a_spurr,b_spurr, f0_per,fs_rat)
% Estimator of the uncertainty for windowed time-integration power or rms value algorihm.
%
% ###TODO: fix help
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
    a_spurr = nc*a_spurr;
    b_spurr = nc*b_spurr;
    
    
    % -- P,S unc calculation:
    
    % default uncertainty multiploier:
    mult = 1;
    
    % under U/I range multiplier:
    if amp_b < lut.ref_ab_rat
       mult = mult*lut.ref_ab_rat/amp_b; 
    end
    
    % under spurr/(U|I) range multiplier:
    min_s_amp = lut.lut_PS.ax.s_amp.values(1);
    mult_a = mult;
    if a_spurr < min_s_amp
       mult_a = mult*a_spurr/min_s_amp; 
    end
        
    % set LUT axes:
    axi = struct();
    axi.ab_rat.val = amp_b/amp_a;
    axi.f0_per.val = f0_per;
    axi.fs_rat.val = fs_rat;
    axi.s_amp.val = a_spurr*mult;
    axi.s_freq.val = f_spurr;
                
    % get no noise unc. value:
    unc_PS_a = interp_lut(lut.lut_PS,axi);
    
    
    % under spurr/(U|I) range multiplier:
    min_s_amp = lut.lut_PS.ax.s_amp.values(1);
    mult_b = mult;
    if b_spurr < min_s_amp
       mult_b = mult*b_spurr/min_s_amp; 
    end
    
    % get no noise unc. value (second channel):
    axi.s_amp.val = b_spurr*mult;
    unc_PS_b = interp_lut(lut.lut_PS,axi);
        
    
    
    % -- ref level unc calculation:    
    % set LUT axes:           
    axi = struct();
    axi.f0_per.val = f0_per;
    axi.fs_rat.val = fs_rat;
    axi.s_amp.val = a_spurr/amp_a;
    axi.s_freq.val = f_spurr;
        
    % get reference unc. value:
    unc_I_a = interp_lut(lut.lut_I,axi);
    
    % get reference unc. value:
    axi.s_amp.val = b_spurr/amp_b;
    unc_I_b = interp_lut(lut.lut_I,axi);
    
    
    
    % calculate alg. errors:
    dPx = (unc_PS_a.dP.val^2 + unc_PS_b.dP.val^2)^0.5;
    dSx = (unc_PS_a.dS.val^2 + unc_PS_b.dS.val^2)^0.5;
    dUx = unc_I_a.dI.val;
    dIx = unc_I_b.dI.val;

end