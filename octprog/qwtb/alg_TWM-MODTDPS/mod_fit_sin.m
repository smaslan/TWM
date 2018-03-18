function [dc,f0,A0,fm,Am,phm] = mod_fit_sin(fs,u)

    % samples count:
    N = numel(u);
    
    % estimate DC value
    w = blackman(N);
    dc = mean(u.*w)/mean(w);
    
    % remove DC offset:
    u = u - dc;        
    
    % estimae carrier freq.:
    [f0] = PSFE(u,1/fs);
    
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
    ure  = interp1(txa,u,txa(ida:idb),imode,'extrap');
    uimp = interp1(txa,u,txb(ida:idb),imode,'extrap');
    uimm = interp1(txa,u,txc(ida:idb),imode,'extrap');
    txa = txa(ida:idb);
    Nx = numel(ure);
    
    % build complex signal from the original and shifted signals:
    ucp = complex(ure,uimp);
    ucm = complex(ure,uimm);
    
    % detect envelope:
    uc = 0.5*abs(ucp + conj(ucm));
    
    % estimate modulation frequency:
    [fm,Am,phm] = PSFE(uc,1/fs);    
    phm = phm - txa(1)*fm*2*pi;
    
    % estimate DC value of envelope - carrier amplitude:
    w = blackman(Nx);
    A0 = mean(uc.*w)/mean(w);
                
    % fit the envelope by sine:
    %[Am,fm,phm,A0] = FPNLSF(txa,uc,fm,0);

end