function [sig,fs_out,k1_out,h_amps] = thd_sim_wave(p)
% Part of non-coherent, windowed FFT, THD meter.
% Simulates waveform(s) with known THD or levels of the harmonics.
%
%
% License:
% --------
% This is part of the non-coherent, windowed FFT, THD meter.
% (c) 2017, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.
%

    % generate harmonics frequency vector
    f(:,1) = p.f0*(1:p.H);
    
    % limit harmonics by frequency range 
    h_num = find(f < p.fs*0.4,1,'last');
    
    % samples count
    N = p.sample_count;
    
    % averages count
    avg = p.avg_count;
      
    
    % get time jitter value
    if isfield(p,'t_jitter') && p.randomize
        t_jitt = p.t_jitter;
    else
        t_jitt = 0.0;
    end
    
    % get signal noise level
    if isfield(p,'adc_noise_lev')
        adc_noise_lev = p.adc_noise_lev;
    else
        adc_noise_lev = 0.0;
    end
    
    % get sampling rate
    if isfield(p,'fs_unc') && p.randomize
        fs = p.fs + randn(1,p.avg_count)*p.fs_unc;
    else
        fs = p.fs;
    end
    
    % return mean sampling rate
    fs_out = mean(fs);
    
                  
    if isfield(p,'k1')
        % --- simulate defined THD (fundamental referenced) ---
        
        % calculate harmonics for desired THD (fundamental referenced)
        a = 0.01*p.k1*p.A0/(h_num - 1).^0.5;
        
        % generate harmonics for the THD
        h_amps = repmat(a,[h_num 1]);
         
    elseif isfield(p,'A')
        % --- simulate harmonic amplitudes (fixed amplitude for all) ---
           
        h_amps = repmat(p.A,[h_num 1]);               

    elseif isfield(p,'A_max') && isfield(p,'A_min')
        % --- simulate harmonic amplitudes (random in range) ---
        
        h_amps = 10.^(log10(p.A_min) + (log10(p.A_max) - log10(p.A_min))*rand([h_num 1]));
        
    else
        error('THD simulator: Unrecognized mode of generation of the harmonics!');    
    end
    
    % override fundamental by fixed first harmonic
    h_amps(1) = p.A0;
    
    % repeat measurements
    h_amps = repmat(h_amps,[1 avg]);
    
    % maximum used frequency
    f_max = 0.5*fs;
    
    % calculate rms values of the actual signal
    a_rms = sum(0.5*h_amps.^2,1).^0.5;
    
    % calculate actually generated THD 
    k1_out = mean(sumsq(h_amps(2:end,:),1).^0.5./h_amps(1,:))*100;
            
    
    if isfield(p,'corr')
    
        % get corrections
        c = p.corr;
        tab = p.tab;
        
        % get transducer gain transfer:
        tr_gain = correction_interp_table(c.tr_gain, a_rms, f);
        if ~p.randomize
            % discard uncertainty if no unc. simulation allowed:
            tr_gain.u_gain = 0*tr_gain.u_gain;
        end
        
        if any(isnan(tr_gain.gain))
            error('THD simulator, corrections: Range of transducer correction not sufficient!');
        end
        
        % get transducer SFDR:
        tr_sfdr = correction_interp_table(c.tr_sfdr, h_amps(1,1), f);
        
        if any(isnan(tr_sfdr.sfdr))
            error('THD simulator, corrections: Range of transducer SFDR not sufficient!');
        end
        
        % convert to spur:fundamental ratio:
        tr_sfdr = 10.^(-tr_sfdr.sfdr/20);
        tr_sfdr(1,:) = 0; % no SFDR to fundamental itself
        
        if p.randomize
            % randomize SFDR:
            tr_sfdr = (0.5*tr_sfdr/3^0.5).*randn(1);
        end
        
        % apply transducer gain and SFDR:
        h_amps = h_amps./(tr_gain.gain + tr_gain.u_gain*randn(1));
        h_amps = bsxfun(@plus, h_amps, h_amps(1,:).*tr_sfdr);
        
        % maximum used amplitude:
        a_max = 1.05*max(h_amps(:));
        
        
        
        % get digitizer gain transfer:
        adc_gain = correction_interp_table(c.adc_gain, h_amps(:,1), f, 'f', 2);
        if ~p.randomize
            % discard uncertainty
            adc_gain.u_gain = 0*adc_gain.u_gain;
        end
        
        if any(isnan(adc_gain.gain))
            error('THD simulator, corrections: Range of digitizer gain correction not sufficient!');    
        end
        
        % get digitizer SFDR:
        adc_sfdr = correction_interp_table(c.tr_sfdr, h_amps(1,1), f, 'f', 2);
        
        if any(isnan(adc_sfdr.sfdr))
            error('THD simulator, corrections: Range of digitizer SFDR not sufficient!');
        end
        
        % convert to spur:fundamental ratio
        adc_sfdr = 10.^(-adc_sfdr.sfdr/20);
        adc_sfdr(1,:) = 0;
        
        if p.randomize
            % randomize SFDR
            adc_sfdr = (0.5*adc_sfdr/3^0.5).*randn(1);
        end
        
        % apply ADC gain and SFDR
        h_amps = h_amps./(adc_gain.gain + adc_gain.u_gain*randn(1));
        h_amps = h_amps + h_amps(1,:).*adc_sfdr;
                
        % total gain of fundamental 
        gain = c.adc_gain.v(1,1)*c.tr_gain.v(1,1);
                
        % get LSB value of the ADC
        if isfield(c,'lsb')
            % get absolute LSB value
            lsb = c.lsb.v;
        elseif isfield(c,'adc_nrng') && isfield(c,'adc_bits')
            % estimate LSB from range and bitres
            lsb = 2*c.adc_nrng.v*2^(-c.adc_bits.v);
        else
            error('THD simulator: LSB undefined or range and bitres undefined!');   
        end
   
    else
        % default correction data
        lsb = 1e-12;
    end
    
    %h_amps

    
    % generate signal noise with desired level (sample, average)
    adc_noise = randn(N,avg)*adc_noise_lev/4*N^0.5;
        
    % generate time vectors (sample, average)
    t_nom = reshape(0:N - 1,[N 1])./fs;
    t_nom = bsxfun(@plus,t_nom,randn(N,p.avg_count)*t_jitt);
    
    % change the dims for easier synthesis
    h_amps = reshape(h_amps.',[1 avg h_num]);
    f = reshape(f,[1 1 h_num]);
        
    % simulate random triggering
    t_nom = bsxfun(@plus,t_nom,rand(1,p.avg_count));
        
    % synthesize distorted wave, add wave noise
    % ###note: it was crippled to make it compatible with Matlab < 2016
    %sig = sum((h_amps.*sin(2*pi*t_nom.*f)),3) + adc_noise;
    sig = bsxfun(@plus,sum(bsxfun(@times,h_amps,sin(2*pi*bsxfun(@times,t_nom,f))),3),adc_noise);    
    
    % simulate vertical quantisation
    sig = round(sig./lsb)*lsb;
    
    % return mean amplitudes
    h_amps = reshape(mean(h_amps,2),[h_num 1]);

end