function dataout = alg_wrapper(datain, calcset) %<<<1
% Part of QWTB. Wrapper script for algorithm PSFE.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% PSFE definition is:
% function [fa A ph] = PSFE(Record,Ts,init_guess)
% Record     - sampled input signal
% Ts         - sampling time (in s)
% init_guess: 0 - FFT max bin, 1 - IPDFT, negative initial frequency estimate

    if isfield(datain, 'Ts')
        Ts = datain.Ts.v;
    elseif isfield(datain, 'fs')
        Ts = 1/datain.fs.v;
        if calcset.verbose
            disp('QWTB: PSFE wrapper: sampling time was calculated from sampling frequency')
        end
    else
        Ts = mean(diff(datain.t.v));
        if calcset.verbose
            disp('QWTB: PSFE wrapper: sampling time was calculated from time series')
        end
    end
    
    init_guess = 1;
    
    % Call algorithm ---------------------------  %<<<1
    [fa A ph] = PSFE(datain.y.v,Ts,init_guess);
    
    
    if strcmpi(calcset.unc,'guf')
        % --- Uncertainty estimator ---
        
        % samples count:
        N = numel(datain.y.v);
        
        % load SFDR value (applies to both harmonic and interhamonic content), related to fundamental freq.:
        if isfield(datain,'sfdr')
            sfdr = -datain.sfdr.v;
        else            
            sfdr = -180; % default
        end
        
        % load ADC resolution (absolute value!):
        if isfield(datain,'adcres')
            adcres = datain.adcres.v;
        else            
            adcres = 1e-12; % default
        end
        
        % load rms jitter value [s]:
        if isfield(datain,'jitter')
            jitter = datain.jitter.v;
        else            
            jitter = 1e-12; % default
        end
        
        
        % --- perform spectrum analysis:
        qwtb('SP-WFFT','addpath'); % ###todo: fix qwtb so it does not loose the path every time another alg. is called        
        % get window parameters (needed later):
        din.window.v = 'flattop_248D';
        w = window_coeff(din.window.v,N,'periodic');
        w_gain = mean(w);        
        w_rms = mean(w.^2).^0.5;         
        % do windowed FFT:
        din.Ts.v = Ts;
        din.y.v = datain.y.v;
        cset.verbose = 0;        
        dout = qwtb('SP-WFFT',din,cset);
        qwtb('PSFE','addpath'); % ###todo: fix qwtb so it does not loose the path every time another alg. is called
        fh  = dout.f.v;
        amp = dout.A.v;
        H = numel(fh); % DFT bins count
        
        
        % window half-width:
        w_size = 11;
        
        % -- look for and remove harmonics:
        % note: exact harmonics should not affect rms calculation at all, so we just remove those from calculation
    
        % fundamental component:
        [v,f0id] = min(abs(fa - fh));
        
        % fundamental amplitude:
        sig_amp = amp(f0id);
        % fundamental rms:
        sig_rms = 2^-0.5*amp(f0id);
        
        % expected harmonics:    
        fhx = fa:fa:max(fh);
        
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
        h_msk = msk(msk <= H & msk > 0);
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
            if isempty(hid)
                break;                
            end
            
            % found harmonics list:
            ih_list(h) = hid;
            
            % DFT bins occupied by the harmonic
            h_bins = max((msk(id) - w_size),1):min(msk(id) + w_size,N);
            
            % remove harmonic bins from remaining list:
            msk = setdiff(msk,h_bins);
            msk = msk(msk <= H & msk > 0);        
        end        
        % at this point spectrum should contain only noise...
        
        if false
            figure
            loglog(fh,amp)
            hold on;
            loglog(fh(h_msk),amp(h_msk),'r')
            loglog(fh(msk),amp(msk),'k')
            hold off;
            title('Spectrum analysis');
        end
        
                
        % effective harmonics to fundamental ratio:
        %  note: was max. harmonic to fundamental but when multiple harmonics are near size, this does more sense...
        rel_harm_amp = sum(amp(h_list(2:end)).^2).^0.5/sig_amp;
                
        % effective inter-harmonics to fundamental ratio:
        %  note: was max. harmonic to fundamental but when multiple harmonics are near size, this does more sense...
        rel_inter_amp = sum(amp(ih_list).^2).^0.5/sig_amp;
        
        % add SFDR to harmonic ratios:
        sfdr = 10^(sfdr/20);
        rel_harm_amp = max(rel_harm_amp,sfdr);
        rel_inter_amp = max(rel_inter_amp,sfdr);
        
        % restore noise in the full spectrum freq range:
        if isempty(msk)
            noise = [0];
        else
            noise = interp1(fh(msk),amp(msk),fh,'nearest','extrap');
        end
        % estimate full bw. rms noise:    
        noise_rms = sum(0.5*noise.^2).^0.5/w_rms*w_gain;
        
        % SNR estimate:
        snr = -10*log10((noise_rms/sig_rms)^2);    
        % SNR equivalent time jitter (yes, very nasty solution...):
        tnj = 10^(-snr/20)/2/pi/fa;
        
        % combine jitter estimate with the noise-jitter estimate:
        jitter = (jitter^2 + tnj^2)^0.5;
                               
        
        % relative ADC resolution:
        rel_res = adcres/A;
        
        % obtain estimate of the frequency error: 
        err = PSFE_unc(fa, 1/Ts, N, jitter, rel_res, rel_harm_amp, rel_inter_amp);
        
        % estimate standard unceratainty:
        u_fa = err/2;
    
    else
        % --- no uncertainty mode ---
         
        % generate empty uncertainties:
        u_fa = 0;                       
    end
    
    % Format output data:  --------------------------- %<<<1
    % PSFE definition is:
    % function [fa A ph] = PSFE(Record,Ts,init_guess)
    % fa     - estimated signal's frequency
    % A      - estimated signal's amplitude
    % ph     - estimated signal's phase
    
    dataout.f.v = fa;
    dataout.f.u = u_fa*loc2covg(calcset.loc,50);
    dataout.A.v = A;
    dataout.ph.v = ph;

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
