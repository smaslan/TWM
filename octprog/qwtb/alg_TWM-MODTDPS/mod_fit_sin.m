function [me, dc,f0,A0, fm,Am,phm, u_A0,u_Am] = mod_fit_sin(fs,u,wshape)
% Simple algorithm for detection of modulation envelope and estimation
% of modulation parameters.
%
% License:
% --------
% This is part of the modulation detector algorithm TDPS.
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT

    % samples count:
    N = numel(u);
    
    % estimate DC value
    w = blackman(N);
    dc = mean(u.*w)/mean(w);
    
    % remove DC offset:
    u = u - dc;        
    
    % estimae carrier freq.:
    [f0] = PSFE(u,1/fs);
    
%     fest = ipdft_spect(fft(u),fs);
%     [f0] = MFSF(u, 1/fs, [1 2 3 4 5 6],fest)
        
%     if strcmpi(wshape,'rect')
%         f_N = [0   3000 7000 10000 1e9];
%         f_w = [1.5 1.5  1.2  1.05  1.05];
%         f_w = interp1(f_N,f_w,N,'linear','extrap') 
%         % filter the signal with narrow band-pass filter:
%         fc = f0*[1/f_w,f_w];
%         if isOctave
%             [b,a] = butter(1, fc/(fs/2));
%         else
%             [b,a] = butter(1, fc/(fs/2), 'bandpass');
%         end
%         uf = filtfilt(b, a, u);
%         % reestimate the carrier again:
%         [f0] = PSFE(uf,1/fs);
%         clear uf;
%     end
    
%     plot(u)
%     hold on;
%     plot(uf)
%     hold off;
       
    
    % calculate 90deg timeshift:
    ts = 1/f0*0.25;
    
    % generate time vectors:
    txa(:,1) = [0:N-1]/fs; % original
    txb = txa + ts; % shifted+
    txc = txa - ts; % shifted-
    
    % resample (interpolate) original signal to shifter time series:    
    imode = 'spline'; % using 'spline' mode as it shows lowest errors on harmonic waveforms
    t_max = (N-1)/fs;
    ida = find(txa >= 0    & txb >= 0    & txc >= 0,1);
    idb = find(txa < t_max & txb < t_max & txc < t_max,1,'last');    
    %ure  = interp1(txa,u,txa(ida:idb),imode,'extrap');
    ure  = u(ida:idb);
    uimp = interp1(txa,u,txb(ida:idb),imode,'extrap');
    uimm = interp1(txa,u,txc(ida:idb),imode,'extrap');
    txa = txa(ida:idb);
    Nx = numel(ure);
    
    % build complex signal from the original and shifted signals:
    ucp = complex(ure,uimp);
    ucm = complex(ure,uimm);
    
    % detect envelope:
    me = 0.5*abs(ucp + conj(ucm));
    
    % estimate modulation frequency:
    [fm,Am,phm] = PSFE(me,1/fs);    
    phm = phm - txa(1)*fm*2*pi;
    
    % estimate DC value of envelope - carrier amplitude:
    w = blackman(Nx);
    A0 = mean(me.*w)/mean(w);
    
    if strcmpi(wshape,'sine')
        % --- SINE WAVE:
        
        % no estimate of the unc. for sine:
        u_A0 = 0;
        u_Am = 0;
        
    else
        % --- RECTANGULAR WAVE:
        
        if fm/f0 < 0.33
            % suitable modulation freq.:
            
            
            % -- filter the signal to get rid of spikes:
            % carrier should have max f0 < 0.1*fs and modulating fm < 0.33*f0
            % so cut off somewhere around f0 max 
            %if isOctave
                [b,a] = butter(1,0.33);
            %else
                % Matlab: ?
            %    error('not done broh...')
            %end
            % there and back filter to decrease phase error:
            mef = filtfilt(b, a, me);
            
            %figure
            %plot(u)
            %plot(me)
            %hold on;
            %plot(mef,'r')
            %hold off;                       
            
            % modulation signal phase:
            mod_ph = mod(txa*fm*2*pi + phm,2*pi);
            
%             figure(2)
%             plot(txa,mef)
%             hold on;
%             plot(txa,mod_ph > 0.25*pi & mod_ph < 0.75*pi,'r');
%             hold off;
                        
            
            % detect tops and lows of the rect.:
            u_tops = mef(mod_ph > 0.30*pi & mod_ph < 0.70*pi);
            u_lows = mef(mod_ph > 1.30*pi & mod_ph < 1.70*pi);
            
            % modulation amplitude:
            Am = 0.5*abs(mean(u_tops) - mean(u_lows));
            u_Am = (std(u_tops)^2 + std(u_lows)^2)^0.5/numel(u_tops)^0.5;
            
            % carrier amplitude:
            A0 = 0.5*abs(mean(u_tops) + mean(u_lows));
            u_A0 = u_Am;
            
        else
            % to high mod f:
            error('Modulation frequency is too high for the rectangular modulation estimator! f_mod/f0 must be lower than 0.33.');
        end
        
        
                    
    end

end