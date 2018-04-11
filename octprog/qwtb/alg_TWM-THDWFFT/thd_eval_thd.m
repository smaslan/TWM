function [thd,f_harm,f_noise,U_noise,U_org_m,U_org_a,U_org_b,U_fix_m,U_fix_a,U_fix_b,sig_m,f] = thd_eval_thd(f,sig,f_sig,h_num,h_f_max,f_dev_max,probab,mcc,window_type,fs,corr,tab,cfg)
% Part of non-coherent, windowed FFT, THD meter.
% Calculates THD and its uncertainty from a windowed spectrum.
%
% Parameters:
% -----------
%   f(:,1)      - frequnecy vector [Hz]
%   sig(:,n)    - amplitude spectra [V], n is measurement number
%   f_sig       - fundamental frequency [Hz]
%   h_num       - harmonics count to analyze
%   h_f_max     - max harmonic frequency to analyze [Hz]
%   f_dev_max   - search range for harmonic peak [+/- ? DFT bins]
%   probab      - coverage interval for harmonics and THD uncertainty [-]
%   mcc         - Monte Carlo cycles for the uncertainty calculation
%   fix_thd     - magic correction of THD, ### temporary ###, {0 - none, 1,2 - THD from means, 2 - worst case uncertainties}
%               - for details see source code notes
%   window_type - name string of the window function used for the calculation of input spectra
%   fs          - sampling rate [Hz]
%   corr        - correction data structure from TWM tool passed via QWTB
%   tab         - correction tables (TWM style)
%   cfg         - TWM configuration flags & stuff
%
%
% 'corr' is a structure from QWTB. It contains the corrections sent by TWM tool. Following are used by this script:
% -----------------------------------------------------------------------------------------------------------------
%   corr.adc_aper.v       - aperture time of ADC
%   corr.adc_aper_corr.v  - non-zero to enable aperture effect correction
%   corr.lsb.v            - LSB voltage step of the ADC (opt. 1)
%   corr.adc_nrng.v       - nominal range of the ADC (opt. 1)
%   corr.adc_bits.v       - bit resolution of the ADC (opt. 1)
%   corr.tr_type.v        - type of transducer ('': none, 'rvd': res. divider, 'shunt': res. shunt)
%
% 'tab' are TWM-style correction tables created from data passed from TWM system:
% -------------------------------------------------------------------------------
%   tab.adc_gain - digitizer gain correction (dependent on freq and amp)
%   tab.adc_sfdr - digitizer SFDR value (dependent on fund. freq and amp)
%                - note: only quantity, not uncertainty!
%   tab.tr_gain  - transducer gain correction (dependent on freq and rms)
%   tab.tr_sfdr  - transducer SFDR value (dependent on fund. freq and rms)
%                - note: only quantity, not uncertainty!
%   ###todo: cable/loading corrections
%
% 'cfg' signal configurtion flags related to the TWM caller:
% ----------------------------------------------------------
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
%
% Returns:
% --------
%  thd          - THD structure
%                 thd.k1         - k1 coefficient (uncorrected spectral leakage)
%                 thd.k1_a       - k1 left uncertainty bound
%                 thd.k1_b       - k1 right uncertainty bound
%                 thd.k2...      - the same for k2
%                 thd.k1_comp... - the same for k1 (corrected spectral leakage) 
%                 thd.k2_comp... - the same for k2 (corrected spectral leakage)
%  f_harm       - harmonic frequencies [Hz]
%  f_noise(h,:) - near noise calculation frequency range, h is harmonic, [left_start left_stop right_start right_stop] [Hz]
%  U_noise(h)   - near noise levels [V]
%  U_org...     - uncorrected harmonic voltages [V]
%  U_fix...     - corrected harmonic voltages [V]
%       _m      - mean values
%       _a      - left uncertainty bound
%       _b      - right uncertainty bound
%  sig_m(:,1)   - averaged amplitude spectrum [V]
%  f(:,1)       - frequency scale of the spectrum [Hz]
%
%
% License:
% --------
% This is part of the non-coherent, windowed FFT, THD meter.
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.
%

    % enable scalloping correction?
    fix_scalloping = f_dev_max < 0;

    if f_dev_max < 0
        % window scalloping correction enabled
        
        % harmonic DFT bin search range limited to +/-0.5 bin
        f_dev_max = 0;
        
    end

  
    % --- obtain parameters of the window
    % window +/-0.5*bin relative flatness [-]:
    [a,b,flat,norm_fac] = thd_window_spectrum(1000,1000,10,window_type);
    clear a,b;    
    if fix_scalloping
        % when scalloping error correction enabled, assume about 50% flatness improvement (pessimistic guess):
        flat = flat*0.5;
    else
        % expand flatness to be >100% sure the scalloping won't cause amp. errors outside 95% uncertainty:
        % ###note: is not nice solution, but works, rest of the algorithm is even more empirical... 
        flat = flat*1.4;
    end
    
   
        
    % DFT bin frequency step [Hz]:
    f_bin_step = f(2) - f(1);
    
    % averages count (repeated measurements):
    A = size(sig,2);
    
    % DFT bins count used to estimate noise level around harmonic:
    %
    %           h1                      h2
    %           |                 
    %           |                       |
    % .. ------ + ------- ..... ------- + ------- .....
    %             ^     ^             ^ ^
    %        noise_rel_f_range     noise_start
    %     
    noise_rel_f_range = round(0.45*f_sig/f_bin_step);
    noise_start = 11; % this should be higher then width of the window
    
    
    
    % --- generate window noise leakage coefficients (used for harmonic amplitude correction):
    % this is used to compensate for the leakage of the noise power into the analyzed harmonic
    % it has dominant effect when the analyzed harmonic amplitude is near noise level  
    [win_leak, noise_gain] = fft_window_leak_gen_lookup(-3,+1,100,50000,window_type);
    
    
    % build list of harmonic frequencies:
    f_list(:,1) = f_sig*[1:h_num];
    
    % alimit max freq by nyquist:
    h_f_max = min(0.4*fs,h_f_max);
    
    % limit harmonics count by max. frequency and sampling rate:
    f_list = f_list(find(f_list<h_f_max));
    
    % harmonics count:
    H = length(f_list);
    
    % get range of used DFT bins: 
    [v,idmin] = min(abs(f_list(1) - f));
    [v,idmax] = min(abs(f_list(end) - f));
    
    % get range of used DFT bins used for entire calculation (including side bands):  
    min_fid = max(idmin - noise_rel_f_range,1);
    max_fid = min(idmax + noise_rel_f_range,size(sig,1));
    
    % max/min used frequency - required range of correction data:
    f_min = f(min_fid);
    f_max = f(max_fid);
    
    % get total needed bw:
    f_max = max(f_max,h_f_max);
    
  
    % --- check frequency ranges of the corrections data
    
    % get largest available range of frequency for all correction:
    t_list = {tab.adc_gain,tab.adc_sfdr,tab.tr_gain,tab.tr_sfdr};  
    [fc_min,fc_max] = tab_get_common_range(t_list,'f');
    
    % check the corrections range:
    if f_min < fc_min || f_max > fc_max
        error('THD, corrections: Frequency range of some of the corrections is not sifficient!');
    end
    
    % get rid of spectrum part that is above what is covered by the corrections:
    fid = find(f <= f_max);
    f = f(fid);
    sig = sig(fid,:);
    
    % update actual maximum frequency [Hz]:
    f_max = max(f);
    
    % maximum used amplitude on ADC
    a_max = max(sig(:));
    
    
    % --- apply ADC aperture corrections
    
    % calculate aperture tfer:
    ta = mean(corr.adc_aper.v);   
    if ta > 1e-12 && corr.adc_aper_corr.v
        ap_tfer = pi*f*ta./sin(pi*f*ta);
        ap_tfer(isnan(ap_tfer)) = 1;
    else
        ap_tfer = 1;      
    end  
    
    
    % apply aperture correction (crippled for MATLAB < 2016b version):
    %   sig = sig.*ap_tfer
    sig = bsxfun(@times, sig, ap_tfer);
  
    
    % --- apply digitizer gain corrections
    
    % get digitizer gain correction coefficients:
    adc_gain = correction_interp_table(tab.adc_gain, mean(sig,2), f, 'f', 1);
    
    if any(isnan(adc_gain.gain))
        % not sufficient correction amplitude range:
        error('THD, corrections: Amplitude range of ADC correction not sufficient!');
    end
    
    % apply digitizer gain correction (crippled for MATLAB < 2016b version):
    %   sig = sig.*adc_gain.gain
    sig = bsxfun(@times, sig, adc_gain.gain);
    
    
    
    % --- estimate rough RMS value on the input of the transducer 

    % --- apply transducer gain correction 
    % calculate effective transfer of the transducer:
    if ~isempty(corr.tr_type.v)    
        sig_tmp = mean(sig,2); % ###Todo: denormalize, because now the tr. correction estimates wron RMS!!! 
        [tr_gain,ph_tmp,u_tr_gain] = correction_transducer_loading(tab,corr.tr_type.v,f,[],sig_tmp,0*sig_tmp,0*sig_tmp,0*sig_tmp);    
        tr_gain = tr_gain./sig_tmp;
        u_tr_gain = u_tr_gain./sig_tmp;
    else
        % no transducer defined - no correction:
        tr_gain = 1;
        u_tr_gain = 0;
    end
    
    if any(isnan(tr_gain))
        error('THD, corrections: Amplitude range of transducer correction not sufficient!');
    end
    
    % apply transducer gain correction (crippled for MATLAB < 2016b version):
    %   sig = sig.*tr_gain 
    sig = bsxfun(@times, sig, tr_gain);
    
    % combine relative gain uncertainty of digitizer and transducer (crippled for MATLAB < 2016b version):
    %   gain_u = sqrt(u_tr_gain.^2 + adc_gain.u_gain.^2) 
    gain_u = bsxfun(@plus, u_tr_gain.^2, adc_gain.u_gain.^2).^0.5;
     
  
  
   
    % --- average spectra from all 'A' records
    if A > 1
        % we have more than one averaging cycle - average them:
        sig_m = mean(sig.^2,2).^0.5;
        %sig_ua = (0.5*std((sig.').^2).^0.5).'/size(sig,2)^0.5;
        %sig_ua = (std((sig.').^2).^0.5).'/size(sig,2)^0.5;
        %sig_m = mean(sig,2);
        %sig_ua = std(sig.')'/size(sig,2)^0.5;
        % this is actually stdev(), not ua(), but don't tell nobody... :)
        sig_ua = std(sig.')';
    else
        % for a single records:
        sig_m = sig;
        sig_ua = zeros(size(sig_m));
    end
  
      
    % --- Find harmonics and get near noise levels
    f_harm = zeros(H,1);
    f_noise = zeros(H,4);
    i_sig = zeros(H,1);
    i_noise = zeros(H,4);
    U_harm = zeros(H,1);
    U_hstd = zeros(H,1);
    U_noise = zeros(H,1);
    U_nstd = zeros(H,1);  
    % for each harmonic:
    for h = 1:H
      
        % harmonic freq [Hz]
        f_harm(h) = f_list(h);
          
        % find nearest DFT bin for given harmonic freq
        [v,id] = min(abs(f_harm(h) - f));
                 
        % generate search range for the DFT bin with maximum amplitude 
        ida = max(round(id - f_dev_max), 1);
        idb = min(round(id + f_dev_max), length(sig_m));
           
        % find the DFT bin with maximum amplitude in the defined range
        [v,ida] = max(sig_m(ida:idb));
        id = id + ida - 1 - f_dev_max;
        
        % calculate scalloping error correction factor:
        if fix_scalloping
            werr = thd_window_gain_corr(f_harm(h),f(id),f_bin_step,window_type);
        else
            werr = 0;
        end
        
        % store index of the DFT bin with harmonic
        i_sig(h) = id;
        
        % store found harmonic amplitude
        U_harm(h) = sig_m(id)*(1 + werr);
           
        % store type A uncertainty of the harmonic
        U_hstd(h) = sig_ua(id);
        
        % --- now get near frequency band noise DFT bins
        % left side band search range
        ida = max(id - noise_rel_f_range,1);
        idb = max(id - noise_start,1);
        % right side band search range
        idc = min(id + noise_start,length(sig_m));
        idd = min(id + noise_rel_f_range,length(sig_m));
        % get the sideband noise bins        
        sig_noise = sig([ida:idb,idc:idd],:);
        
        % store noise detection range DFT bin indexes (for future display only)
        i_noise(h,:) = [ida,idb,idc,idd];
        
        % store noise measurement freq range (for future display only)
        f_noise(h,:) = f(i_noise(h,:));    
        
        % near noise mean amplitude
        U_noise(h) = mean(sig_noise(:).^2)^0.5;
        %U_noise(h) = mean(sig_noise(:));
              
        % near noise amplitude stdev.
        %U_nstd(h) = 0.5*std(sig_noise(:).^2).^0.5;
        U_nstd(h) = std(sig_noise(:).^2).^0.5;
        %U_nstd(h) = std(sig_noise(:));
          
    end
  
    % --- estimate noise amplitude for entire freq range:
    % use noise estimates from 2nd harmonic:
    f_noise_est = f_harm(2:end);
    u_noise_est = U_noise(2:end)/noise_gain;
    
    % interpolate noise level to entire used bandwidth:
    noise_est = interp1(f_noise_est,u_noise_est,[f(f <= f_max)],'nearest','extrap');
    
    % estimate noise-rms:
    noise_rms = sum((0.5*noise_est).^2)^0.5;
        
  
  
    % get fundamental harmonic parameters:
    f0 = f_harm(1);
    a0 = U_harm(1);
  
    % --- get SFDR value from the correction data
        
    % get transducer SFDR value:
    tr_sfdr = correction_interp_table(tab.tr_sfdr, a0, f0);
    
    if any(isnan(tr_sfdr.sfdr))
        error('THD, corrections: Amplitude range of transducer SFDR not sufficient!');
    end
  
    % calculate absolute spur value from transducer:
    tr_spur = a0*10^(-tr_sfdr.sfdr/20);
    
    % transducer gain for f0    
    gain0 = correction_interp_table(tab.tr_gain, [], f0);
    gain0 = nanmean(gain0.gain);
    
    % get approximate fundamental amplitude on ADC:
    a0_adc = a0./gain0;

    % get transducer SFDR value:
    adc_sfdr = correction_interp_table(tab.adc_sfdr, a0_adc, f0);
  
    % calculate absolute spur value from ADC scaled to input voltage/current:
    adc_spur = a0*10^(-adc_sfdr.sfdr/20);
    
    % combine spurs:
    % ###note: using worst case scenario = sum, but probably should be sumsq().^0.5?
    spur = tr_spur + adc_spur;
  
  
    % --- get ADC LSB value
    if isfield(corr,'lsb')
        % get LSB value directly
        lsb = corr.lsb.v;
    elseif isfield(corr,'adc_nrng') && isfield(corr,'adc_bits')
        % get LSB value estimate from nominal range and resolution
        lsb = 2*corr.adc_nrng.v*2^(-corr.adc_bits.v);    
    else
        error('THD, corrections: Correction data contain no information about ADC resolution+range or LSB value!');
    end
   
    % scale the LSB value to actual input quantity using DC gains (just estimate):
    gain_dc = tr_gain(1)*nanmean(adc_gain.gain(1,:));
    lsb = lsb*gain_dc;
  
    % --- calculate input uncertaintis of the harmonics (without noise leakage effect):
    % SFDR value is the worst case situation. I assume the randomized SFDR value
    % should be correlated for all harmonics. Otherwise the uncertainty is underestimated.
    % ###todo: I assume each harmonic should produce spurs? This simplified case 
    %          assumes only the first harmonic is dominant, ignores the rest...  
    u_spur = repmat(spur,size(U_hstd));
    % fundamental harmonic should have no spur content:
    u_spur(1) = 0;
            
    
   
    % --- Correction of the harmonis levels based on the noise level ---
    %
    % Note: at this point we may end, and calculate THD from the harmonics.
    % However if the harmonic gets close to the noise level, there will be
    % strong effect of the spectral leakage of the near band noise into it.
    %
    % So what the function does is it corrects the harmonic amplitudes by the
    % estimated noise level around it and it also numerically simulates the
    % unertainty of the harmonics by means of monte-carlo. 
    % So it returnes randomized amplitudes of the harmonics with 'mcc' items
    % each. This approach was used because the distribution function is far
    % from being gaussian. It is assymetric as it gets closer to noise level.
    %
    [U_org,U_org_m,U_org_a,U_org_b, U_fix,U_fix_m,U_fix_a,U_fix_b,is_high] = thd_eval_harmonic(win_leak,noise_gain,U_noise,U_nstd,U_harm,U_hstd,flat,gain_u(i_sig),u_spur,probab,mcc);
  
  
    if is_high
      fix_thd = 1;
    else
      fix_thd = 2;
    end

 
    % --- Now finally evaluate THD for uncorrected harmonics --- 
    % calculate THD from randomized amplitudes U_org
    k1_org = 100*sumsq(U_org(2:end,:),1).^0.5./U_org(1,:);
    k2_org = 100*sumsq(U_org(2:end,:),1).^0.5./sumsq(U_org,1).^0.5;    
      
    % limit to positive values
    k1_org = max(k1_org,0);
    k2_org = max(k2_org,0);
    
    % mean THD values
    k1_org_m = mean(k1_org);
    k2_org_m = mean(k2_org);    
    
    
    % find uncertainty
    [sci,k1_org_a,k1_org_b] = scovint(k1_org,probab);
    [sci,k2_org_a,k2_org_b] = scovint(k2_org,probab);
  
  
    
    % --- Now finally evaluate THD for noise-corrected harmonics --- 
    % calculate THD from randomized amplitudes U_fix
    k1_fix = 100*sumsq(U_fix(2:end,:),1).^0.5./U_fix(1,:);
    k2_fix = 100*sumsq(U_fix(2:end,:),1).^0.5./sumsq(U_fix,1).^0.5;
    k3_fix = 100*(0.5*sumsq(U_fix(2:end,:),1) + noise_rms^2).^0.5./(0.5*U_fix(1,:).^2).^0.5;
    k4_fix = 100*(0.5*sumsq(U_fix(2:end,:),1) + noise_rms^2).^0.5./(0.5*sumsq(U_fix,1) + noise_rms^2).^0.5;
    
    % limit to positive values
    k1_fix = max(k1_fix,0);
    k2_fix = max(k2_fix,0);
    k3_fix = max(k3_fix,0);
    k4_fix = max(k4_fix,0);
    
    % mean THD values
    k1_fix_m = mean(k1_fix);
    k2_fix_m = mean(k2_fix);
    k3_fix_m = mean(k3_fix);
    k4_fix_m = mean(k4_fix);
    
    % find uncertainty
    [sci,k1_fix_a,k1_fix_b] = scovint(k1_fix,probab);
    [sci,k2_fix_a,k2_fix_b] = scovint(k2_fix,probab);      
    [sci,k3_fix_a,k3_fix_b] = scovint(k3_fix,probab);
    [sci,k4_fix_a,k4_fix_b] = scovint(k4_fix,probab);
   
  
  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%% !!! HARDCORE THD CORRECTIONS, TEMPORARY SOLUTION, THIS SHOULD BE FIXED !!! %%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % The problem here is that the uncertainty distributions of the harmonics 
    % are highly assymetric. If they are passed via the THD formula, which contains
    % powers and sqrt() it will be even more assymetric. Therefore the mean value is
    % shifted and uncertainty boundaries are very asymmetric.
    %
    % The following corrections deals with this problem in very trivial, but not
    % very metrological way. So it should be reviewed.
    %   
    if fix_thd == 1      
        %% version 1:
        % 1) recalculate THD from mean() of the harmonic voltages instead of from randomized vectors (Monte Carlo Method)
        % 2) realign the uncertainty limits obtained by the MCM to the newly calculated THD values from step 1)
        % 
        % Note: this version was used for validation of the algorithm:
        %  J. Horska, S. Maslan, J. Streit and M. Sira, "A validation of a THD measurement equipment with a 24-bit digitizer,"
        %  29th Conference on Precision Electromagnetic Measurements (CPEM 2014), Rio de Janeiro, 2014, pp. 502-503.
        %  doi: 10.1109/CPEM.2014.6898479
        %  URL: http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=6898479&isnumber=6898219
        
        %% for uncorrected THD values 
        k1_org_o = k1_org_m;
        k2_org_o = k2_org_m;
        k1_org_m = 100*sumsq(mean(U_org(2:end,:),2),1).^0.5./mean(U_org(1,:),2);
        k2_org_m = 100*sumsq(mean(U_org(2:end,:),2),1).^0.5./sumsq(mean(U_org,2),1).^0.5;
        k1_org_a = max(k1_org_a + (k1_org_m - k1_org_o),0);
        k1_org_b = k1_org_b + (k1_org_m - k1_org_o);
        k2_org_a = max(k2_org_a + (k2_org_m - k2_org_o),0);
        k2_org_b = k2_org_b + (k2_org_m - k2_org_o);
        
        %% for fixed THD values 
        k1_fix_o = k1_fix_m;
        k2_fix_o = k2_fix_m;
        k3_fix_o = k3_fix_m;
        k4_fix_o = k4_fix_m;
        k1_fix_m = 100*sumsq(mean(U_fix(2:end,:),2),1).^0.5./mean(U_fix(1,:),2);
        k2_fix_m = 100*sumsq(mean(U_fix(2:end,:),2),1).^0.5./sumsq(mean(U_fix,2),1).^0.5;
        k3_fix_m = 100*(0.5*sumsq(mean(U_fix(2:end,:),2),1) + noise_rms^2).^0.5./(0.5*mean(U_fix(1,:),2)^2).^0.5;
        k4_fix_m = 100*(0.5*sumsq(mean(U_fix(2:end,:),2),1) + noise_rms^2).^0.5./(0.5*sumsq(mean(U_fix,2),1) + noise_rms^2).^0.5;
        k1_fix_a = max(k1_fix_a + (k1_fix_m - k1_fix_o),0);
        k1_fix_b = k1_fix_b + (k1_fix_m - k1_fix_o);
        k2_fix_a = max(k2_fix_a + (k2_fix_m - k2_fix_o),0);
        k2_fix_b = k2_fix_b + (k2_fix_m - k2_fix_o);
        k3_fix_a = max(k3_fix_a + (k3_fix_m - k3_fix_o),0);
        k3_fix_b = k3_fix_b + (k3_fix_m - k3_fix_o);
        k4_fix_a = max(k4_fix_a + (k4_fix_m - k4_fix_o),0);
        k4_fix_b = k4_fix_b + (k4_fix_m - k4_fix_o);
      
    elseif fix_thd == 2
        %% version 2:
        % 1) recalculate THD from mean() of the harmonic voltages instead of from randomized vectors (Monte Carlo Method) 
        % 2) recalculate uncertainty for the worst possible combination of input voltage uncertainties
        
        %% for uncorrected THD values 
        k1_org_m = 100*sumsq(U_org_m(2:end),1).^0.5./U_org_m(1);
        k2_org_m = 100*sumsq(U_org_m(2:end),1).^0.5./sumsq(U_org_m,1).^0.5;
        k1_org_a = 100*sumsq(U_org_a(2:end),1).^0.5./U_org_b(1);
        k1_org_b = 100*sumsq(U_org_b(2:end),1).^0.5./U_org_a(1);
        k2_org_a = 100*sumsq(U_org_a(2:end),1).^0.5./sumsq(U_org_b,1).^0.5;
        k2_org_b = 100*sumsq(U_org_b(2:end),1).^0.5./sumsq(U_org_a,1).^0.5;
        
        %% for uncorrected THD values 
        k1_fix_m = 100*sumsq(U_fix_m(2:end),1).^0.5./U_fix_m(1);
        k2_fix_m = 100*sumsq(U_fix_m(2:end),1).^0.5./sumsq(U_fix_m,1).^0.5;
        k3_fix_m = 100*(0.5*sumsq(U_fix_m(2:end),1) + noise_rms^2).^0.5./(0.5*U_fix_m(1)^2).^0.5;
        k4_fix_m = 100*(0.5*sumsq(U_fix_m(2:end),1) + noise_rms^2).^0.5./(0.5*sumsq(U_fix_m,1) + noise_rms^2).^0.5;
        k1_fix_a = 100*sumsq(U_fix_a(2:end),1).^0.5./U_fix_b(1);
        k1_fix_b = 100*sumsq(U_fix_b(2:end),1).^0.5./U_fix_a(1);
        k2_fix_a = 100*sumsq(U_fix_a(2:end),1).^0.5./sumsq(U_fix_b,1).^0.5;
        k2_fix_b = 100*sumsq(U_fix_b(2:end),1).^0.5./sumsq(U_fix_a,1).^0.5;        
        k3_fix_a = 100*sumsq(U_fix_a(2:end),1).^0.5./(0.5*U_fix_b(1)^2).^0.5;
        k3_fix_b = 100*sumsq(U_fix_b(2:end),1).^0.5./(0.5*U_fix_a(1)^2).^0.5;
        k4_fix_a = 100*sumsq(U_fix_a(2:end),1).^0.5./(0.5*sumsq(U_fix_b,1) + noise_rms^2).^0.5;
        k4_fix_b = 100*sumsq(U_fix_b(2:end),1).^0.5./(0.5*sumsq(U_fix_a,1) + noise_rms^2).^0.5;    
       
    end
    
    
    
    
    
    % return THD
    thd.noise = noise_rms;
    thd.noise_bw = f_max;
    thd.k1_comp = k1_fix_m; % rms(spur)/amp(fundamental)
    thd.k1_comp_a = k1_fix_a;
    thd.k1_comp_b = k1_fix_b;
    thd.k2_comp = k2_fix_m; % rms(spur)/rms(total)
    thd.k2_comp_a = k2_fix_a;
    thd.k2_comp_b = k2_fix_b;    
    thd.k3_comp = k3_fix_m; % rms(spur+noise)/amp(fundamental)
    thd.k3_comp_a = k3_fix_a;
    thd.k3_comp_b = k3_fix_b;
    thd.k4_comp = k4_fix_m; % rms(spur+noise)/rms(total)
    thd.k4_comp_a = k4_fix_a;
    thd.k4_comp_b = k4_fix_b;    
    thd.k1 = k1_org_m;
    thd.k1_a = k1_org_a;
    thd.k1_b = k1_org_b;
    thd.k2 = k2_org_m;
    thd.k2_a = k2_org_a;
    thd.k2_b = k2_org_b;
    thd.H = H;
  
end



function [ax_min,ax_max] = tab_get_common_range(t_list,ax_name)
% find largest common range axis 'ax_name' of tables listed in 't_list'
     
    ax_min = [];
    ax_max = [];
    for k = 1:numel(t_list)
        ax = getfield(t_list{k}, ax_name);
        if ~isempty(ax)
            ax_max(end+1) = max(ax);
            ax_min(end+1) = min(ax);
        end    
    end
    ax_min = max(ax_min);
    ax_max = max(ax_max);
    
    if isempty(ax_min) || isempty(ax_max) || isnan(ax_min) || isnan(ax_max)
        ax_min = -inf;
        ax_max = +inf;
    end
    
end


function [gain_error] = thd_window_gain_corr(f_real,f_bin,f_bin_step,w_type)
% this calculates error caused by applying normalized-windowed-FFT
% if the analyzed frequency is not exactly matching nearest DFT bin
% i.e. it calculates scalloping error for given frequency 'f_real', 
% analyzed DFT bin of frequency 'f_bin' and frequency step of DFT 'f_bin_step'
    
    % get window's time function
    M = 32;
    w = window_coeff(w_type, M, 'periodic');
    
    % calc. zoomed window spectrum, center it
    Z = 100;
    W = fft(w,M*Z)/M*2;
    W = fftshift(W);    
    C = round(M*Z/2)+1;
    
    % relative position from 'f_bin' [bins]
    k = (f_real - f_bin)/f_bin_step;
    
    % calculate relative error of windowed FFT amplitude guess if the window was normalized 
    gain_error = abs(W(C))./abs(W(C - round(k*Z))) - 1;

end