function [res] = proc_wrms(sig)

    % interpolation mode (default 'pchip'):
    i_mode = sig.i_mode;
    
    % list of virtual channels data:
    vcl = sig.vc;
    
    % is this simulation?
    is_sim = sig.is_sim;
    
    fs = sig.fs;
    fft_size = sig.fft_size;
    fh = sig.fh;
        
    if is_sim
    
        % DFT bin step [Hz]:
        bin_step = 0.5*sig.fs/sig.N;
        
        % randomize harmonics positions +-bin: 
        fx = sig.sim.fx + (2*rand(size(sig.sim.fx)) - 1)*bin_step;
        
        % for each v.channel:
        for v = 1:numel(vcl)
        
            % v.channel setup:
            vc = vcl{v};            
            sim = vc.sim;
            
            % generate time vector:
            t(:,1) = [0:sig.N-1]/sig.fs*2*pi;
            
            % randomize harmonics:
            A = sim.A + sim.u_A.*randn(size(sim.A));
            ph = sim.ph + sim.u_ph.*randn(size(sim.ph));
            
            % generate signal:
            y = sum(bsxfun(@times,A',sin(bsxfun(@plus,bsxfun(@times,t,fx'),ph'))),2);
            
            % add noise:
            y = y + sim.noise*randn(size(y));
            
            % get tfer correction filter values for the harmonics:
            fg = interp1(vc.adc_gain.f,vc.adc_gain.gain,fx,i_mode,'extrap');
            fp = interp1(vc.adc_gain.f,vc.adc_phi.phi,fx,i_mode,'extrap');
            
            % store reference values:
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
        
    
      
        
    
    % --- Apply the calcualted correction in the time-domain:
    % note: here we subtract phase of ref. channel from all others in order to reduces
    %       total absolute value of the phase corrections
    
    % reference channel phase (voltage, high-side):    
    ap_ref = vcl{1}.adc_phi;
       
    % for each virtual (u/i) channel:
    for k = 1:numel(vcl)
        % get v.channel:
        vc = vcl{k};
                
        % apply DC gain to DC value:
        if ~is_sim
            vc.dc = vc.dc*vc.adc_gain.gain(1);
            vc.u_dc = vc.dc*vc.adc_gain.u_gain(1);
        end                       
                
        % subtract reference channel phase:
        %  note: this is to reduce total phase correction value
        vc.adc_phi.phi   = vc.adc_phi.phi - ap_ref.phi;
        
        % apply tfer filter for high-side:
        [vc.y, a,b, ff,fg,fp] = td_fft_filter(vc.y, fs, fft_size, fh,vc.adc_gain.gain,vc.adc_phi.phi ,i_mode);
        %vc.y = vc.y(a:b);     
        
        if ~is_sim
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
            if ~is_sim
                vc.dc_lo = vc.dc_lo*vc.adc_gain_lo.gain(1);
                vc.u_dc_lo = vc.dc_lo*vc.adc_gain_lo.u_gain(1);
            end           
            
            % subtract reference channel phase:
            %  note: this is to reduce total phase correction value 
            vc.adc_phi_lo.phi   = vc.adc_phi_lo.phi - ap_ref.phi;
            
            % apply tfer filter for low-side:
            [vc.y_lo, a,b, ff,fg,fp] = td_fft_filter(vc.y_lo, fs, fft_size, fh,vc.adc_gain_lo.gain,vc.adc_phi_lo.phi, i_mode);
            
            if ~is_sim
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
    
    
    
    
    
    
    
    
    
    
    
    % --- Calculate power ---
    % this is the main time-domain-integration calculation 
    
    % get corrected u,i:
    u = vcl{1}.y;
    i = vcl{2}.y;
    N = numel(u);

    % generate window for the RMS algorithm (periodic):
    w = blackmanharris(N,'periodic');
    w = w(:);
    
    % calculate inverse RMS of the window (needed for scaling of the result): 
    W = mean(w.^2)^-0.5;
    
    % calculate RMS levels of u,i:
    res.U = W*mean((w.*u).^2).^0.5;
    res.I = W*mean((w.*i).^2).^0.5;
       
    % calculate RMS active power value:
    res.P = W^2*mean(w.^2.*u.*i);
    
    if is_sim
        res.dU = res.U/sig.ref.U - 1;
        res.dI = res.I/sig.ref.I - 1;
        res.dP = res.P/sig.ref.P - 1;
    end

end