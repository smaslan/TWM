function [r] = thd_wfft(y,fs,s,corr,tab,cfg)
% Part of non-coherent, windowed FFT, THD meter.
%
% Evaluates THD of the time domain signal using windowed FFT.
% 
%
% Input parameters:
%   y(:,n) - signal waveform data, one column per record
%          - algorithm prefers at least n = 5 repetitions
%   fs     - sampling frequency
%   s      - configuration structure
%   corr   - correction structure
%   tab    - correction tables (TWM style)
%   cfg    - TWM configuration flags & stuff
%
% 'corr' is a structure from QWTB. It contains the corrections sent by TWM tool.
% Following are used by this script:
%   corr.adc_aper.v       - aperture time of ADC
%   corr.adc_aper_corr.v  - non-zero to enable aperture effect correction
%   corr.adc_freq.v       - frequency correction of the digitizer timebase
%                .u       - absolute uncertainty
%   corr.lsb.v            - LSB voltage step of the ADC (opt. 1)
%   corr.adc_nrng.v       - nominal range of the ADC (opt. 1)
%   corr.adc_bits.v       - bit resolution of the ADC (opt. 1)
%
% 'tab' are TWM-style correction tables created from data passed from TWM system:
%   tab.adc_gain - digitizer gain correction (dependent on freq and amp)
%   tab.adc_sfdr - digitizer SFDR value (dependent on fund. freq and amp)
%                - note: only quantity, not uncertainty!
%   tab.tr_gain  - transducer gain correction (dependent on freq and rms)
%   tab.tr_sfdr  - transducer SFDR value (dependent on fund. freq and rms)
%                - note: only quantity, not uncertainty!
%   ###todo: cable/loading corrections
%
% 'cfg' signal configurtion flags related to the TWM caller:
%   cfg.y_is_diff - non-zero if input signal is differential
%   cfg.is_multi  - multiple records in 'y'
%   ###todo: any other used flags?
%
%  Note: opt 1) there must be either 'lsb' defined, or 'adc_nrng' and 'adc_bits'! 'lsb' has priority.
%
%  The algorithm checks the frequency and amplitude range of all the corrections and if the ranges
%  are not sufficient for the desired harmonics analysis range, it will throw an error.
%
%
% 's' is configuration structure with following items:
%   s.verbose          - verbose level {0-stfu, 1-basic status, 2-full status}
%   s.f_fund           - fundamental frequency setup [Hz], set 0 for autodetection
%   s.f_fund_fit       - fundamental frequency autodetection:
%                        0 - zero-cross (fast, usable for high signal periods count),
%                        1 - fitting (slow, accurate)
%                        2 - PSFE
%   s.f_fund_zc_filter - moving average filter for zero-cross method (usually 20),
%                        ZC is used also for initial guess for a fitting algorithm!
%   s.h_num            - maximum harmonics count to analyze
%   s.h_f_max          - maximum harmonic frequnecy [Hz]
%   s.f_dev_max        - maximum harmonic freq. deviation from ideal position [bin]
%   s.mc_cycles        - Monte Carlo uncertainty evaluation: cycles count
%   s.mc_cover         - Monte Carlo uncertainty evaluation: coverage interval
%   s.save_spec        - return spectrum?
%
% Outputs structure 'r' with elements:
%   r.f_lst        - harmonic frequencies used for the calculation [Hz]
%   r.f_sig        - measured average fundamental frequency of the signal [Hz]
%   r.a_noise      - mean value of near-band noise amplitude for each harmonic 
%   r.a_lst        - mean uncorrected harmonic amplitudes
%   r.a_lst_a      - left uncertainty boundary for 'r.a_lst'
%   r.a_lst_b      - right uncertainty boundary for 'r.a_lst'
%   r.a_comp_lst   - mean uncorrected harmonic amplitudes
%   r.a_comp_lst_a - left uncertainty boundary for 'r.a_comp_lst'
%   r.a_comp_lst_b - right uncertainty boundary for 'r.a_comp_lst'
%   r.sfdr         - negative SFDR value estimate [dBc]
%   optional if 's.save_spec = 1':
%   r.f(:,1)       - frequency axis of the spectrum [Hz]
%   r.sig(:,1)     - averaged spectrum of the signals
%   r.f_noise(:,4) - frequency ranges of the near-noise bands:
%                    [left_start left_stop right_start right_stop] [Hz]
%
%
% License:
% --------
% This is part of the non-coherent, windowed FFT, THD meter.
% (c) 2018, Martin Sira, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT
% 

  % get samples count per record
  N = size(y,1);
  
  % window type used for the input spectrum - rather do not modify!
  window_type = 'flattop_248D';
    
  % get spectrum of each waveform (one waveform - one averaging cycle)
  [f,sig,fs,f_bin_step,r.f_sig,f_std,rms] = thd_proc_waves(fs, y, s.f_fund, s.f_fund_fit, s.f_fund_zc_filter, window_type, s.verbose);
  
  
  % calculate harmonics distance in [DFT bins]
  harm_dist = r.f_sig/f_bin_step;
  % check minimum harmonics spacing
  min_h_dist = 30;
  if harm_dist < min_h_dist
    error(sprintf('Distance between the harmonics in spectrum must be at least %d (detected %d)!',min_h_dist,round(harm_dist)));
  end
  
  
  % evaluate thd coefficients
  [thd,r.f_lst,f_noise,r.a_noise,r.a_lst,r.a_lst_a,r.a_lst_b,r.a_comp_lst,r.a_comp_lst_a,r.a_comp_lst_b,sig_m,f,r.sfdr] = thd_eval_thd(f,sig,r.f_sig,s.h_num,s.h_f_max,s.f_dev_max,s.mc_cover,s.mc_cycles,window_type,fs,corr,tab,cfg);
  
  % store the results into the results struct
  r = [[fieldnames(r);fieldnames(thd)],[struct2cell(r);struct2cell(thd)]]';
  r = struct(r{:});
  
  % optionally store the full spectrum
  if s.save_spec
    r.f = f;
    r.sig = sig_m;
    r.f_noise = f_noise;
  end   

end
