function [t,rms,dout] = hcrms_calc_pq(dout,t0,fs,y,cfg,calcset)
% Measurement of rms level in time for sag/swell/interruption PQ events.
%
% What it does:
% 1) if 'nom_f' is present, it assumes it's coherently sampled and the 'nom_f'
%    is exact value. If 'nom_f' is NaN, it detects frequency in time using PSFE.
% 2) resampling of the 'y' so the signal is coherent and has desired number
%    of samples per period. To avoid resampling, fs/nom_f must be multiple of 20.
% 3) Phase detection for each period and reconstructing phase for missing
%    periods.
% 4) Phase synchronization based on 3) by next resampling.
% 5) RMS level detection with selected step.
% 6) Events detection from rms values.    
% 
% parameters:
%  dout - QWTB output quantities (may be empty struct())
%  fs - sampling rate in [Hz]
%  t0 - initial sample timestamp [s] 
%  y - vertical vector with scaled sample data
%  cfg.mode - event detection mode
%             'A' - class A meter according 61000-4-30
%                   rms window sync. to zero cross, moving by 1/2-period
%             'S' - sliding window with 20 steps per period
%  cfg.nom_f - nominal fundamental freq. (NaN to auto detect)
%  cfg.nom_rms - nominal rms level to which the event detection is related
%  cfg.ev.hyst - event detector hysteresis [%] (default 2%)
%  cfg.ev.sag_tres - sag event treshold [%] (default 90%)
%  cfg.ev.swell_tres - swell event treshold [%] (default 110%)
%  cfg.ev.int_tres - interruption event treshold [%] (default 10%)
%  cfg.do_plots - non-zero enables plotting the found events to graphs
%  calcset.dbg_plots - non-zero enables plotting of debug graphs
%
% returns:
%  t - time vector of centers of rms windows
%  rms - calculate rms value rms(t)
%  dout - QWTB style quantities and uncertainties:
%  dout.*_start - starting time of detected event [s] or NaN for no event 
%  dout.*_dur - duration time of detected event [s] or NaN for no complete event
%  dout.*_res - residual rms ratio to nominal rms in [%] or NaN for no complete event
%   * - event name: 'sag', 'swell' or 'int'
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
        fprintf('Fitting frequency...\n');
           
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
            fbf = smooth(tbm_tmp,fbm_tmp,fil_opt{:});
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
            title('Frequency in time');
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
    fprintf('Resampling to coherent...\n');  
    
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
    tx = cumsum([0,dTs(1:end-1)]);
    tx = tx(tx >= t0(1) & tx <= t0(end));        
    
    % resample the signal to new samples times:
    yx = interp1(t0',y,tx','spline','extrap');
    N = numel(yx);
    % round signal size to whole periods:
    N = floor(N/N1T)*N1T;
    yx = yx(1:N);
    tx = tx(1:N); 
    
        

    % --- detection of the phase offset of each period
    fprintf('Period-phase detection...\n');
            
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
        phi_p_fit = smooth(phi_t,phi_p,fil_opt{:});
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
    end
        
    
    
    % --- resampling 2: phase synchronization:
    fprintf('Synchronizing phase...\n');
        
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
            phi_p_fit = smooth(phi_t,phi_p,fil_opt{:});
        end
        % interpolate the smoothed phase for all signal periods:
        phi_p_fit = interp1(phi_t,phi_p_fit,per_mid,'nearest','extrap');                
        
        figure
        plot(tx(phi_t),phi_p,'o')
        hold on;
        plot(tx(per_mid),phi_p_fit,'r')
        hold off;
        title('Phase of the signal after phase sync.');
        
    end
    
    
    


    % --- calculation of the rms values
    fprintf('Calculating rms...\n');
        
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
    
    
    
    
    
    % -- maximum rms error vs freq. syncronization error:
    % maximum relative deviation of sampling rate for each period:
    %  note: worst case etimate from many tests under heavily distorted signals
    df = 0.2/2/pi/N1T;
    % Formula from:
    % XIX IMEKO World Congress, Fundamental and Applied Metrology, September 6-11, 2009, Lisbon, Portugal
    % ACCURACY ANALYSIS OF VOLTAGE DIP MEASUREMENT, Daniele Gallo, Carmine Landi, Mario Luiso
    % Note: it was validated by monte-carlo just in case...       
    % N = 10000;    
    % mcc = 1000;    
    % df = 1/100;
    % dp = 0.00;
    % tw(:,1) = [0:N-1]/N*2*pi;        
    % rmsx = mean(sin(tw.*(1 + (2*rand(1,mcc)-1)*df) + (2*rand(1,mcc)-1)*dp).^2,1).^0.5;
    % drms = rmsx - 2^-0.5;
    % u_rms_coh = max(abs(drms))*2^-0.5/3^0.5
    u_rms_coh_rel = (0.5*df/(1+df))/3^0.5;
       
    % -- spectrum analysis: 
        
    [fh, amp] = ampphspectrum(yx, fsx, 0, 0, 'flattop_248D', [], 0);
    d_fh = fh(2) - fh(1);
    
    % window half-width:
    w_size = 11;
    
    % -- look for and remove harmonics:
    % note: exact harmonics should not affect rms calculation at all
        
    % fundamental component:
    [v,f0id] = min(abs(f0_avg - fh));
    
    % expected harmonics:    
    fhx = f0_avg:f0_avg:max(fh);
    
    % mask all harmonics:
    msk = [max(w_size,floor(0.1*f0id)):numel(fh)];        
    for k = 1:numel(fhx)
        [v,fid] = min(abs(fhx(k) - fh));
        h_bins = [(fid - w_size):(fid + w_size)];
        % remove harmonic bins from remaining list:
        msk = setdiff(msk,h_bins);            
    end
    h_msk = msk(msk <= N & msk > 0);
    % at this point spectrum should contain only non-harmonic content...
        
    
    % -- look for interhamonics:
    
    % max. analyzed components:
    h_max = 100;
    
    % identify harmonic/interharmonic components:
    h_list = [];
    for h = 1:h_max
        
        % look for highest harmonic:
        [v,id] = max(amp(msk));        
        hid = msk(id);
        
        % found harmonics list:
        h_list(h) = hid;
        
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
    end
    
      
        
       
    
    fprintf('Detecting events...\n');
               
    % define event setups:
    event_list{1}.tr_start   = cfg.nom_rms*0.01*(cfg.ev.sag_tres);
    event_list{1}.tr_stop    = cfg.nom_rms*0.01*(cfg.ev.sag_tres + cfg.ev.hyst);
    event_list{1}.name       = 'sag';
    event_list{1}.qu_name    = 'sag';
    
    event_list{2}.tr_start   = cfg.nom_rms*0.01*(cfg.ev.swell_tres);
    event_list{2}.tr_stop    = cfg.nom_rms*0.01*(cfg.ev.swell_tres - cfg.ev.hyst);
    event_list{2}.name       = 'swell';
    event_list{2}.qu_name    = 'swell';    
    
    event_list{3}.tr_start   = cfg.nom_rms*0.01*(cfg.ev.int_tres);
    event_list{3}.tr_stop    = cfg.nom_rms*0.01*(cfg.ev.int_tres + cfg.ev.hyst);
    event_list{3}.name       = 'interruption';
    event_list{3}.qu_name    = 'int';
        
    
    % -- for each event:
    for k = 1:numel(event_list)
    
        % get event definition:
        ev = event_list{k};
    
        % detect event:
        [t_start,t_dur,rms_xtr,found] = env_event_detect(env_time,env_rms,[],[ev.tr_start, ev.tr_stop],cfg.mode == 'S');
        
        % residual ratio to nominal:
        resid = 100*rms_xtr/cfg.nom_rms;        
        
        % store results:
        dout = setfield(dout, [ev.qu_name '_start'], struct('v',t_start,'u',1/f0_avg));
        dout = setfield(dout, [ev.qu_name '_dur'], struct('v',t_dur,'u',1/f0_avg));
        dout = setfield(dout, [ev.qu_name '_res'], struct('v',resid,'u',0.002*resid));
                
        if cfg.do_plots
            % plot basic rms and tresholds:    
            figure
            plot(env_time,env_rms,'b','LineWidth',1.5) % rms(t)
            hold on;
            plot([env_time(1),env_time(end)],[1 1]*cfg.nom_rms,'r:')
            plot([env_time(1),env_time(end)],[1 1]*ev.tr_start,'r--')
            plot([env_time(1),env_time(end)],[1 1]*ev.tr_stop,'r--')
            
            ylim_tmp = ylim();
            ylim_tmp(1) = 0;  
            
            if found
            
                % plot event markers:
                ev_ts = [t_start t_start+t_dur];
                ev_rs = interp1(env_time,env_rms,ev_ts,'linear','extrap');           
                plot(ev_ts,ev_rs,'r.');
                
                plot([env_time(1),env_time(end)],[1 1]*rms_xtr,'k:') % extreme rms              
                plot([1 1]*ev_ts(1),ylim_tmp,'r-')
                plot([1 1]*ev_ts(2),ylim_tmp,'r-')
                
                % autoscale the event:
                left = max(t_start - 1.5*t_dur,env_time(1));
                right = min(t_start + 2.5*t_dur,env_time(end));            
                xlim([left right]);
                
            end
            
            ylim(ylim_tmp);    
            hold off;
            
            tit = sprintf('%s (none)',ev.name);
            if found
                tit = sprintf('%s (duration = %.3fs)',ev.name,t_dur);
            end
            
            title(tit);
            xlabel('time [s]');
            ylabel('rms [V or A]');
        end
        
    end
    
end


