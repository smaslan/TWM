function [env_time,u_env_time,env_rms,u_env_rms,dout] = hcrms_calc_pq(dout,t0,u_t0,fs,y,cfg,calcset)
% Measurement of rms level in time for sag/swell/interruption PQ events.
%
% What it does:
% 1) if 'nom_f' is present, it assumes it's coherently sampled and the 'nom_f'
%    is exact value. If 'nom_f' is NaN, it detects frequency in time using PSFE.
% 2) resampling of the 'y' so the signal is coherent and has desired number
%    of samples per period. To avoid resampling, fs/nom_f must be multiple of 20.
% 3) Phase detection for each period and reconstructing phase for missing
%    periods.
% 4) Fine phase synchronization based on 3) by next resampling.
% 5) RMS level detection with selected step (see 'cfg.mode').
%
% The algorithm also can calculate uncertainty estimate for the rms envelope
% and sample times.    
% 
% Parameters:
%  dout - QWTB style output quantities (may be empty struct())
%         note it will pass 'dout' content to the output and adds calc. quantities
%  fs - sampling rate in [Hz]
%  t0 - initial sample timestamp [s] 
%  u_t0 - initial sample timestamp uncertainty [s]
%  y - vertical vector with scaled sample data
%  cfg.mode - event detection mode
%             'A' - class A meter according 61000-4-30
%                   rms window sync. to zero cross, moving by 1/2-period
%             'S' - sliding window with 20 steps per period
%  cfg.nom_f - nominal fundamental freq. (NaN to auto detect)
%  cfg.corr.f - frequency axis of correction data
%  cfg.corr.gain.gain - relative gain normalized to nominal frequency gain
%                       note it must cover full frequency range from 0 to 0.5*fs! 
%  cfg.corr.gain.unc - absolute standard uncertainty of gain
%  cfg.corr.sfdr - sfdr value (scalar) related to the nominal frequency
%                  e.g.: +120 dBc means spurrs As = 1e-6*A0
%  calcset.dbg_plots - plot some debug graphs
%  calcset.unc - uncertainty calculation mode (default: 'none', or 'guf')
%
% Returns:
%  env_time - time vector of centers of rms windows
%       note the 't' is not necessarily equidistant!
%  u_env_time - absolute uncertainties of 'env_time'  
%  env_rms - calculate rms value rms(env_time)
%  u_env_rms - absolute uncertainties of rms(env_time)
%  dout - QWTB style quantities and uncertainties:
%  dout.t - time vector and uncertainty of 'env_time'
%  dout.rms - rms values and uncertainties corresponding to the 'env_rms'
%  dout.f0 - measured fundamental frequency
%   
%
% License:
% --------
% This is part of the TWM - Traceable PQ Wattmeter
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.
%
       
    if ~isfield(calcset,'dbg_plots')
        calcset.dbg_plots = 0;        
    end
       
    % get waveform size:
    N = numel(y);
    
    % restore time vector:
    t0 = t0 + [0:N-1]/fs;

    
    if isnan(cfg.nom_f)
        % --- NOT coherent mode with known frequency:
    
        % --- analyze fundamental frequency
        if calcset.verbose
            fprintf('Fitting frequency...\n');
        end
           
        % rough smples count per period:
        N1T = fs/cfg.f0_est;    
        
        % scan through the waveform, estimate frequency in time:
        blk_n = 200;
        blk_sz = round(max(3*N1T,N/blk_n));    
        blk_step = round((N - blk_sz)/blk_n);    
        pos = 1;
        for k = 1:blk_n       
        
            pose = min(pos + blk_sz - 1 + round(rand*100),N);                 
            yb = y(pos:pose);
            
            [fb(k) Ab(k)] = PSFE(yb,1/fs);
            tb(k) = 0.5*(pos + pose - 2)/fs;
            
            pos = pos + blk_step;
            
        end
        
        % most likely fundamental frequency:
        %  ###note: this may not work if there is too long interruption (no signal)
        f_med = median(fb);
        
        % mask sudden frequency deviations over the time:
        msk = abs(diff(fb)) > 0.005*f_med;
        msk = [msk,0] | [0,msk];
        
        if numel(msk) < 2
            error('Frequency seems to be too unstable in time! Check the signal level.');
        end
        
        % detect maximum level from the unmasked signal:
        A_max = max(Ab(~msk));
        
        % mask levels below treshold, because PSFE won't work properly:
        msk = msk | Ab < A_max*0.02;
        
        % mask sudden amplitude deviations:
        msk_A = abs(diff(Ab)) > 0.02*(mean([Ab(1:end-1);Ab(2:end)],1));
        msk = msk | [msk_A,0] | [0,msk_A];
            
        % expand mask by two elements:
        msk = [msk(2:end),0] | [0,msk(1:end-1)];
        msk = [msk(2:end),0] | [0,msk(1:end-1)];
        
        % extract usable frequencies:
        tbm = tb(~msk);
        fbm = fb(~msk);
        Abm = Ab(~msk);
        
        if sum(~msk) < 0.1*blk_n || sum(~msk) < 20
            error('Error on fitting frequency! Signal is probably too distorted. If this is coherent measurement, try enter nominal frequency manually.');
        end
        
        
        % smooth the detected phase to get rid of ouliers and noise:
        end_avg = 10; % no touchy! this generates some fake samples before and after the data to smooth to make the smoother work better
        fil_ord = 51; % span of the smoother
        fil_opt = {fil_ord,'moving'}; % mode of the smoother
        dTb = tb(2)-tb(1);
        tbm_tmp = [linspace(tb(1)-dTb,tb(1)-end_avg*dTb,floor(fil_ord/2)),tbm,linspace(tb(end)+dTb,tb(end)+end_avg*dTb,floor(fil_ord/2))];
        fbm_tmp = [repmat(mean(fbm(1:end_avg)),[1 floor(fil_ord/2)]),fbm,repmat(mean(fbm(end-end_avg+1:end)),[1 floor(fil_ord/2)])];
        if isOctave
            fbf = smooth_oct(tbm_tmp,fbm_tmp,fil_opt{:});
        else
            fbf = smooth_mat(tbm_tmp,fbm_tmp,fil_opt{:});
        end        
        % expand the smoothed data to full sampling time:
        fbf = interp1(tbm,fbf(floor(fil_ord/2):end-floor(fil_ord/2)-1),t0,'linear','extrap');
        
        % show how it went...            
        if calcset.dbg_plots
            figure;
            plot(tbm,fbm,'o')
            hold on;
            plot(t0,fbf,'r')
            hold off;            
            title('Frequency vs time');
            xlabel('time [s]');
            ylabel('frequency [Hz]');
            legend('PSFE fits','Smoothed, fitted, ...');
        end
        
        % mean fundamental frequency:
        f0_avg = mean(fbm);
        %f0_mn = mean(fbf);
        
        % relative frequency modulation envelope:
        f_env = fbf/f0_avg;
        
    else
        % --- coherent mode - user defined nominal frequency:
        
        % mean fundamental frequency:
        f0_avg = cfg.nom_f;
        %f0_mn = cfg.nom_f;

        % no relative devition of requency in time (assuming no drift):
        f_env = ones([1 N]);

    end
        


    % --- resampling the signal to coherent: 
    if calcset.verbose
        fprintf('Resampling to coherent...\n');
    end  
    
    if cfg.mode == 'S'
        % -- sliding window mode:
        
        % subwindows per period:
        SP = 20;
    else
        % -- 'A class' - synchronous mode, half period step:
        
        % subwindows per period:
        SP = 2;        
    end
        
    % get rounded samples per period, always even!:
    %  note: this is the desired value to which the signal will be sampled
    N1T = ceil(fs/f0_avg/SP)*SP;
    
    % rough estimate of samples count of resamples signal to covere entire sampling tame of original:
    NX = round(N*N1T/(fs/f0_avg));
    
    % interpolate detected frequency envelope to new samples:
    fsx = NX/(t0(end)-t0(1));
    tx = linspace(t0(1),t0(end),NX);
    f_env = interp1(t0,f_env,tx,'linear','extrap');
    
    % generate time vector of the new samples: 
    dTs = 1./(f_env*fs*N1T/(fs/f0_avg));
    tx = cumsum([t0(1),dTs(1:end-1)]);
    tx = tx(tx <= t0(end));       
    
    % resample the signal to new samples times:
    yx = interp1(t0',y,tx','spline','extrap');
    N = numel(yx);
    % round signal size to whole periods:
    N = floor(N/N1T)*N1T;
    yx = yx(1:N);
    tx = tx(1:N);   
        

    % --- detection of the phase offset of each period
    if calcset.verbose
        fprintf('Period-phase detection...\n');
    end
            
    % -- filter the signal to get rid of harmonics:
    % cut off frequency:
    fc = f0_avg*(1 + [-0.1 +0.1]);
    % low pass butterworth filter:
    % this filter will be used only for zero crossing detection,
    % for rest of calculations original signal will be used
    if isOctave
        [b,a] = butter(1, fc/(fsx/2));
    else
        [b,a] = butter(1, fc/(fsx/2), 'bandpass');
    end
    % there and back filter to decrease phase error:
    yxf = filtfilt(b, a, yx);
    
%      figure
%      plot(yx);
%      hold on;
%      plot(yxf,'r');
%      hold off
               
    % calculate rough rms estimates of each period of filtered signal:
    yxf = reshape(yxf,[N1T N/N1T]);        
    rms_f = mean(yxf.^2,1).^0.5;
        
    % period center indexes (or indices?):
    per_mid = [(N1T/2):N1T:N] + 1;
    % generate usable signal-mask (the filter has high-Q so it takes some tome to get usable amplitude):
    per_msk = zeros(size(per_mid));
    per_msk(1:numel(rms_f)) = rms_f > 0.02*max(rms_f);
    per_msk(1:10) = 0;
    per_msk(end-10:end) = 0;
    
    % detect period-phase over the signal length using FFT:
    w = hanning(N1T+1);
    w = w(1:end-1);
    Yp = angle(fft(bsxfun(@times,w,yxf))*exp(j*pi/2));    
    phi_p = Yp(2,:);
            
    % extract only valid periods:
    phi_p = unwrap(phi_p(~~per_msk));
    phi_t = per_mid(~~per_msk);
    
    % smooth the detected phase to get rid of ouliers and noise:
    fil_opt = {25,'moving'};
    if isOctave
        phi_p_fit = smooth_oct(phi_t,phi_p,fil_opt{:});
    else
        phi_p_fit = smooth_mat(phi_t,phi_p,fil_opt{:});
    end
    % interpolate the smoothed phase for all signal periods:
    phi_p_fit = interp1(phi_t,phi_p_fit,per_mid,'nearest','extrap');
                  
    % show how it went...
    if calcset.dbg_plots    
        figure
        plot(tx(phi_t),phi_p,'o')
        hold on;
        plot(tx(per_mid),phi_p_fit,'r')
        hold off;
        title('Phase of the signal before phase sync.');
        xlabel('time [s]');
        ylabel('period-phase [rad]');
        legend('period phase','smoothed, fitted, ...');
    end
        
    
    
    % --- resampling 2: phase synchronization:
    if calcset.verbose
        fprintf('Synchronizing phase...\n');
    end
        
    % get sampling times per periods:
    Tsx = tx(per_mid+1) - tx(per_mid);
    
    % calculate time correction for each period:
    t_corr = (2*pi - phi_p_fit)/2/pi.*Tsx.*N1T;
    % expand it for each sample of each period
    %t_corr = repmat(t_corr,[N1T 1]);
    %t_corr = t_corr(:);
    t_corr = interp1(tx(per_mid)',t_corr,tx','linear','extrap');
    
    % apply time correction:
    tx = tx + t_corr';    
    tx = tx(tx >= t0(1) & tx <= t0(end));
    
    % resample the signal to new samples times:
    yx = interp1(t0',y,tx','spline','extrap');
    N = numel(yx);
    % round signal size to whole periods:
    N = floor(N/N1T)*N1T;
    yx = yx(1:N);
    tx = tx(1:N);
    
    
    % show how it went...
    if calcset.dbg_plots
    
        % -- filter the signal to get rid of harmonics:
        % cut off frequency:
        fc = f0_avg*(1 + [-0.1 +0.1]);
        % low pass butterworth filter:
        % this filter will be used only for zero crossing detection,
        % for rest of calculations original signal will be used
        if isOctave
            [b,a] = butter(1, fc/(fsx/2));
        else
            [b,a] = butter(1, fc/(fsx/2), 'bandpass');
        end
        % there and back filter to decrease phase error:
        yxf = filtfilt(b, a, yx);
        
        % calculate rough rms estimates of each period of filtered signal:
        yxf = reshape(yxf,[N1T N/N1T]);        
        rms_f = mean(yxf.^2,1).^0.5;
            
        % period center indexes (or indices?):
        per_mid = [(N1T/2):N1T:N] + 1;
        % generate usable signal-mask (the filter has high-Q so it takes some tome to get usable amplitude):
        per_msk = zeros(size(per_mid));
        per_msk(1:numel(rms_f)) = rms_f > 0.02*max(rms_f);
        per_msk(1:10) = 0;
        per_msk(end-10:end) = 0;
        
        % detect period-phase over the signal length using FFT:
        w = hanning(N1T+1);
        w = w(1:end-1);
        Yp = angle(fft(bsxfun(@times,w,yxf))*exp(j*pi/2));    
        phi_p = Yp(2,:);
                
        % extract only valid periods:
        phi_p = unwrap(phi_p(~~per_msk));
        phi_t = per_mid(~~per_msk);
        
        % smooth the detected phase to get rid of ouliers and noise:
        fil_opt = {25,'moving'};
        if isOctave
            phi_p_fit = smooth_oct(phi_t,phi_p,fil_opt{:});
        else
            phi_p_fit = smooth_mat(phi_t,phi_p,fil_opt{:});
        end
        % interpolate the smoothed phase for all signal periods:
        phi_p_fit = interp1(phi_t,phi_p_fit,per_mid,'nearest','extrap');                
        
        figure
        plot(tx(phi_t),phi_p,'o')
        hold on;
        plot(tx(per_mid),phi_p_fit,'r')
        hold off;
        title('Phase of the signal after phase sync.');
        xlabel('time [s]');
        ylabel('period-phase [rad]');
        legend('period phase','smoothed, fitted, ...');
        
    end
    
    
    


    % --- calculation of the rms values
    if calcset.verbose
        fprintf('Calculating rms...\n');
    end
        
    mode = 1;
    if mode == 1
        % -- faster & memory saving:
        
        % full periods in the signal:
        NP = floor((N - 1*N1T)/N1T);
        
        yxp = yx.^2;
        
        % calculate rms of all periods for each window offset:
        env_rms = [];
        for k = 1:SP
            a = (k-1)*N1T/SP + 1;
            b = a + NP*N1T - 1;
            yxr = reshape(yxp(a:b),[N1T NP]);
            env_rms(k,:) = mean(yxr,1).^0.5;
        end
        % restore linear order:
        env_rms = env_rms(:);        
        E = numel(env_rms);
        
        % generate time vector:        
        env_time = tx([0:E-1]*(N1T/SP) + N1T/2 + 1);
    
    
    else
        % -- old & slow:
    
        % generate window:
        w = hanning(N1T,'periodic');
        w = ones(size(w)); % no window
        w_rms = mean(w.^2).^-0.5;
        
        fr = 1;        
        for k = 1:(N1T/SP):(N-4*N1T)        
            yw = yx(k:k+N1T-1);
            env_rms(end+1) = mean((w.*yw).^2)^0.5;
            env_time(end+1) = tx(k + N1T/2);
            fr = fr + 1;                              
        end
        env_rms = env_rms*w_rms;
    
    end
    
    
    % --- Uncertainty estimation ---
    if strcmpi(calcset.unc,'guf')
    
        if calcset.verbose
            fprintf('Calculating uncertainty...\n');
        end
                  
    
        % -- spectrum analysis:
        
        w = window_coeff('flattop_248D', N, 'periodic'); w = w(:);
        W_gain = mean(w);
        W_rms = mean(w.^2)^0.5;
            
        [fh, amp] = ampphspectrum(yx, fsx, 0, 0, 'flattop_248D', [], 0);
        fh = fh(:);
        amp(1) = 0.5*amp(1); % ###todo: fixing FFT DC error, to be removed when implemented in ampphspectrum()
            
        
        % relative tfer of the signal path:
        gain_f = cfg.corr.gain.f;
        gain   = cfg.corr.gain.gain;
        gain_u = cfg.corr.gain.unc;    
        % interpolate tfer to analysed DFT bins:
        gain   = interp1(gain_f,gain,fh,'pchip','extrap');
        gain_u = interp1(gain_f,gain_u,fh,'pchip','extrap');
        
        % rms estimate:    
        rms_orig = rmswfft(amp,W_gain,W_rms);
        % rms with correction to the actual input tfer:
        rms_fixed = rmswfft(gain.*amp,W_gain,W_rms);
        % rms_fixed with worst case uncertainty:
        rms_max = rmswfft((gain + 3*gain_u).*amp,W_gain,W_rms);
        
        % total corrections induced max. error:    
        u_rms_corr = abs(rms_max - rms_orig);
           
        % fix spectrum to match the actual freq. tfer (with worst case uncertainty):
        amp = amp.*(gain + 3*gain_u);
         
        
        % window half-width:
        w_size = 11;
        
        % -- look for and remove harmonics:
        % note: exact harmonics should not affect rms calculation at all, so we just remove those from calculation
    
        % fundamental component:
        [v,f0id] = min(abs(f0_avg - fh));
        
        % expected harmonics:    
        fhx = f0_avg:f0_avg:max(fh);
        
        % mask all harmonics:
        msk = [max(w_size,floor(0.1*f0id)):numel(fh)];        
        h_list = [];
        for k = 1:numel(fhx)
            [v,fid] = min(abs(fhx(k) - fh));
            h_list(end+1) = fid;
            h_bins = [(fid - w_size):(fid + w_size)];
            % remove harmonic bins from remaining list:
            msk = setdiff(msk,h_bins);            
        end
        h_msk = msk(msk <= N & msk > 0);
        % at this point spectrum should contain only non-harmonic content...
            
        
        % -- look for interhamonics:
        % note: these affect the rms since they are not coherent with the window
        
        % max. analyzed components:
        h_max = 100;
        
        % identify harmonic/interharmonic components:
        ih_list = [];
        for h = 1:h_max
            
            % look for highest harmonic:
            [v,id] = max(amp(msk));        
            hid = msk(id);
            
            % found harmonics list:
            ih_list(h) = hid;
            
            % DFT bins occupied by the harmonic
            h_bins = max((msk(id) - w_size),1):min(msk(id) + w_size,N);
            
            % remove harmonic bins from remaining list:
            msk = setdiff(msk,h_bins);
            msk = msk(msk <= N & msk > 0);        
        end
        % at this point spectrum should contain only noise...
        
        if calcset.dbg_plots
            figure
            loglog(fh,amp)
            hold on;
            loglog(fh(h_msk),amp(h_msk),'r')
            loglog(fh(msk),amp(msk),'k')
            hold off;
            title('Spectrum analysis');
            xlabel('frequency [Hz]');
            ylabel('amplitude [rad]');
            legend('total spectrum','removed harmonics','remove interharmonics');
        end
        
        
        % -- maximum rms error vs freq. syncronization error:
        % maximum relative deviation of sampling rate for each period:
        %  note: worst case etimate from many tests under heavily distorted signals
        df = 0.3/2/pi/N1T;
        
        
        
        % --- analyze interharmonic effect:        
        % DFT in step 
        d_fh = fh(2)-fh(1);
                
        % monte carlo cycles:
        F = 200;
        
        % hamonics list to simulate
        ih_per = [1, (fh(ih_list)/f0_avg).'];
        ih_amp = [amp(f0id), amp(ih_list).'];
        
        % randomizing frequencies:
        d_fh = repmat(d_fh,size(ih_per));
        d_fh(1) = df;   
        
        % monte-carlo loop:
        %  generates fundamental and inter-harmonics, calculates total rms        
        wt = [0:N1T-1].'/N1T.*2*pi;
        rms_mc = [];
        for k = 1:F
            % note: don not remove bsxfun - intendedly crippled for Matlab          
            wts = bsxfun(@plus, bsxfun(@times,wt,(ih_per + (2*rand(1,numel(ih_per)) - 1).*d_fh)), rand(1,numel(ih_per))*2*pi);
            sim = sum(bsxfun(@times,ih_amp,sin(wts)),2); 
            rms_mc(k) = mean(sim.^2)^0.5;
        end
        
        % estimate of worst case rms error due to interharmonics/harmonics:
        ih_unc_med = median(rms_mc);
        %ih_unc = (max(rms_mc) - min(rms_mc))*1.0
        ih_unc = max(abs(max(rms_mc) - median(rms_mc)),abs(min(rms_mc) - median(rms_mc)));
        
        
        
        % extension of the rms based on the event depth:
        % this is necessary because we do the analysis for mean rms condition
        rms_ext = (env_rms/ih_unc_med);
        
        % expand the uncertainty +- 2 cycles to sides to cover the transitions
        exp_size = ceil(0.5*SP);
        for k = 1:exp_size
            rms_ext = max([[rms_ext(2:end);0],[0;rms_ext(1:end-1)]],[],2);
        end        
        
%         figure
%         plot(env_rms/ih_unc_med)
%         hold on;
%         plot(rms_ext,'r');
%         hold off;    
        
        % -- estimate SFDR effect:
        % max harmonics count:
        h_count = (0.5*fsx)/f0_avg - 1;
            
        % absolute SFDR induced rms: 
        u_rms_sfdr = (h_count*(amp(f0id)*10^-(cfg.corr.sfdr/20))^2)^0.5;
                       
    
        % -- total uncertainty:
        % total measured rms envelope uncertainty (without interharmonic caused noise):
        u_env_rms = (u_rms_corr + u_rms_sfdr + ih_unc)*rms_ext;     
        
        
        
        % -- time samples uncertainty:
        % time uncertainty from the resampling algorithm:
        u_tx = df/f0_avg/3^0.5;
        
        % combined time uncertainty:
        u_tw = (u_tx^2 + u_t0^2)^0.5; % (internal)
        
        % expand to desired level of confidence:
        ke = loc2covg(calcset.loc,50);        
        u_tx = u_tw*ke; % (to return)
        
    else        
        % no uncertainty mode:
        
        u_env_rms = zeros(size(env_rms));
        u_tw = 0;
        u_tx = 0;
                    
    end
    
    % time samples to vertical:
    env_time = env_time.';
    
    % generate time samples uncertainty:
    u_env_time = repmat(u_tx,size(env_time));
    
    % return rms envelope
    dout.t.v   = env_time;
    dout.t.u   = u_env_time;
    dout.rms.v = env_rms;
    dout.rms.u = u_env_rms*calcset.loc;
    
    % return measured fundamental frequency:
    dout.f0.v = f0_avg;
    dout.f0.u = 0;

end


% rms level from windowed normalized FFT half-spectrum (positive freqs. only):
function [rms] = rmswfft(y,w_gain,w_rms)
    rms = sum(0.5*y.^2)^0.5*w_gain/w_rms;
end


