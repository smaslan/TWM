function [res] = proc_wrms(sig)
% Core of the PWRTDI algorithm - RMS power by ime integration of windowed waveforms.
% This function can either calculate RMS levels of the input signals or it can 
% synthesize signal with kown harmonics and then calculate the RMS levels from it
% (that is for monte carlo uncertainty evaluation only).
% 
% The method of power calculation is based on the papers:
% [1] K. B. Ellingsberg, "Predictable maximum RMS-error for windowed RMS (RMWS),"
%     2012 Conference on Precision electromagnetic Measurements, 
%     Washington, DC, 2012, pp. 308-309. doi: 10.1109/CPEM.2012.6250925
% [2] R. Lapuh, B. Voljč and M. Lindič, "Measurement and estimation of arbitrary
%     signal power using a window technique," 2016 Conference on Precision
%     Electromagnetic Measurements (CPEM 2016), Ottawa, ON, 2016, pp. 1-2.
%     doi: 10.1109/CPEM.2016.7540739
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
%

    % interpolation mode (default 'pchip'):
    i_mode = sig.i_mode;
    
    % list of virtual channels data:
    vcl = sig.vc;
    
    % sampling rate [Hz]:
    fs = sig.fs;
    
    % frequency vector matching the gain/phase correction data 'adc_*':
    fh = sig.fh;
    
        
    if sig.is_sim
        % --- SIMULATION MODE: synthesize known U,I waveforms ---
        
        % generate window for the DC elimination (periodic!):
        w = blackmanharris(sig.N,'periodic');
        w = w(:);                 
        w_gain = mean(w);
        
        % DFT bin step [Hz]:
        bin_step = 0.5*sig.fs/sig.N;
        
        % randomize harmonics frequency positions +-bin because we don't exact position: 
        fx = sig.sim.fx + (2*rand(size(sig.sim.fx)) - 1)*bin_step;
        
        % randomize frequencies of spurrs:
        f_sp_rnd = (2*rand(size(sig.sim.f_spurr)) - 1)*bin_step;
        
        % randmonize spurr phase angles:
        % note: assume U and I are synchronized - worst case situation
        p_sp_rnd = rand(size(sig.sim.f_spurr))*2*pi; 
        
        % random common phase of harmonics:
        %  note: same for both v.channels, so it should not affect results
        phr = rand(size(fx))*2*pi; 
        
        % -- for each v.channel:
        for v = 1:numel(vcl)
            
            % v.channel setup:
            vc = vcl{v};            
            sim = vc.sim;
            
            if vc.is_diff
                % discard differential mode:
                vcl{v}.is_diff = 0;
                % set result expansion coeficient:
                % note: this should emulate uncertainty rise caused by the second channel of the diff. pair
                vcl{v}.exp_coef = 2^0.5;
            else
                vcl{v}.exp_coef = 1;
            end
            
            % generate time vector:
            t(:,1) = [0:sig.N-1]/sig.fs*2*pi;
            
            % randomize harmonics:
            A = sim.A + sim.u_A.*randn(size(sim.A));
            ph = sim.ph + sim.u_ph.*randn(size(sim.ph)) + phr;
            
            % generate some spurrs with random phase:
            fxs = [fx;sig.sim.f_spurr + f_sp_rnd];
            A = [A;sim.spurr];
            ph = [ph;p_sp_rnd];
            
            % generate signal:
            y = sum(bsxfun(@times,A',sin(bsxfun(@plus,bsxfun(@times,t,fxs'),ph'))),2);
            
            % add rms noise:
            %  ###todo: this is not very accurate as the noise gain 
            %           should change the noise level for each frequency... may be improved
            y = y + sim.noise*randn(size(y));
            
            % emulate quantisation:
            y = round(y/sim.lsb)*sim.lsb;
            
            % estimate and eliminate DC offset:
            dc = mean(y.*w)/w_gain;
            y = y - dc; 
            
            % get tfer correction filter values for the harmonics:
            fg = interp1(fh,vc.adc_gain.gain,fx,i_mode,'extrap');
            fp = interp1(fh,vc.adc_phi.phi,fx,i_mode,'extrap');
                       
            % store reference harmonic values:
            vcl{v}.ref.A = sim.A.*fg;
            vcl{v}.ref.ph = sim.ph + fp;
            vcl{v}.ref.rms = sum(0.5*vcl{v}.ref.A.^2)^0.5;
                                    
            % store generated signal:
            vcl{v}.y = y;
        
        end
        
        % calculate reference generated values:
        sig.ref.U = vcl{1}.ref.rms;  
        sig.ref.I = vcl{2}.ref.rms;
        sig.ref.P = sum(0.5*vcl{1}.ref.A.*vcl{2}.ref.A.*cos(vcl{2}.ref.ph - vcl{1}.ref.ph));
            
    end
    % at this point we have U/I waveforms from user input or from simulation,
    % so from now the rest of calculation is identic for both modes...    
    
    
    
    % --- Apply the calculated tfer correction in the time-domain:
    % note: here we subtract phase of ref. channel from all others in order to reduce
    %       total absolute value of the phase corrections
    
    % FFT filter size:
    fft_size = sig.fft_size;
    
    % reference channel phase (voltage, high-side):    
    ap_ref = vcl{1}.adc_phi;
       
    % -- for each virtual (u/i) channel:
    for k = 1:numel(vcl)
        % get v.channel:
        vc = vcl{k};
                
        % apply DC gain to DC value:
        if ~sig.is_sim
            vc.dc = vc.dc*vc.adc_gain.gain(1);
            vc.u_dc = ((vc.u_dc*vc.adc_gain.gain(1))^2 + (vc.dc*vc.adc_gain.u_gain(1))^2)^0.5;
        end                  
                
        % subtract reference channel phase:
        %  note: this is to reduce total phase correction value
        vc.adc_phi.phi = vc.adc_phi.phi - ap_ref.phi;
        
        % apply tfer FFT filter for high-side:
        [vc.y, a,b, ff,fg,fp] = td_fft_filter(vc.y, fs, fft_size, fh,vc.adc_gain.gain,vc.adc_phi.phi ,i_mode);                       
        
        if ~sig.is_sim
            % calculate actual phase correction made:
            adc_phi_real = interp1(ff,fp,fh,i_mode,'extrap');
            
            % phase correction uncertainty contribution:
            u_phi_corr = abs(adc_phi_real - vc.adc_phi.phi)/3^0.5;
        
            % add uncertainty to the spectrum estimate components:        
            vc.u_ph = (vc.u_ph.^2 + u_phi_corr.^2).^0.5;
        end        
        
        %semilogx(fh,vc.adc_phi.phi)
        %semilogx(fh,vc.adc_gain.gain) 
        
        if vc.is_diff
            % -- differential mode:
            
            % apply DC gain to DC value:
            if ~sig.is_sim
                vc.dc_lo = vc.dc_lo*vc.adc_gain_lo.gain(1);
                vc.u_dc_lo = ((vc.u_dc_lo*vc.adc_gain_lo.gain(1))^2 + (vc.dc_lo*vc.adc_gain_lo.u_gain(1))^2)^0.5;
            end           
            
            % subtract reference channel phase:
            %  note: this is to reduce total phase correction value 
            vc.adc_phi_lo.phi = vc.adc_phi_lo.phi - ap_ref.phi;
            
            % apply tfer filter for low-side:
            [vc.y_lo, a,b, ff,fg,fp] = td_fft_filter(vc.y_lo, fs, fft_size, fh,vc.adc_gain_lo.gain,vc.adc_phi_lo.phi, i_mode);
            
            if ~sig.is_sim
                % calculate actual phase correction made:
                adc_phi_real = interp1(ff,fp,fh,i_mode,'extrap');
                
                % phase correction uncertainty contribution:
                u_phi_corr = abs(adc_phi_real - vc.adc_phi_lo.phi)/3^0.5;
                
                % add uncertainty to the spectrum estimate components:
                vc.u_ph = (vc.u_ph.^2 + u_phi_corr.^2).^0.5;
            end
            
            % calculate high-low-side difference:
            vc.y = vc.y - vc.y_lo;
            
            % calculate differential DC offset:
            vc.dc = vc.dc - vc.dc_lo;
            vc.u_dc = (vc.u_dc^2 + vc.u_dc_lo^2)^0.5; 
                        
        end
        
        % store v.channel:
        vcl{k} = vc;            
    end
    
    
    
    
    % --- Calculate RMS power ---
    % this is the main time-domain-integration calculation 
    
    % get corrected u,i waveforms:
    u = vcl{1}.y;
    i = vcl{2}.y;
    N = numel(u);

    % generate window for the RMS algorithm (periodic!):
    w = blackmanharris(N,'periodic');
    w = w(:);
    
    % calculate inverse RMS of the window (needed for scaling of the result): 
    W = mean(w.^2)^-0.5;
    
    % calculate RMS levels of u,i:
    res.U = W*mean((w.*u).^2)^0.5;
    res.I = W*mean((w.*i).^2)^0.5;
       
    % calculate RMS active power value:
    res.P = W^2*mean(w.^2.*u.*i);
    
    
    
    
    
    if sig.is_sim
        % SIMULATION:
        % calculate deviation from simulated values:
        res.dU = (res.U/sig.ref.U - 1)*vcl{1}.exp_coef;
        res.dI = (res.I/sig.ref.I - 1)*vcl{2}.exp_coef;
        res.dP = (res.P/sig.ref.P - 1)*vcl{1}.exp_coef*vcl{2}.exp_coef;
    else
        % REAL PROCESSING:
        % return updated v.channels:
        res.vc = vcl;        
    end

end