function [qu_f,qu_gain,qu_phi] = gen_adc_tfer(f_max,f_count, dc_gain,u_dc_gain,gain_fm,u_gain_fm,gain_pwr, gain_rper,gain_ramp, phi_max,u_phi_max,u_phi_min,phi_pwr)

    % generate freq. vector:
    f(:,1) = linspace(0,f_max,f_count);
    
    % generate smooth gain tfer:   
    gain(:,1) = dc_gain*(1 + sign(gain_fm)*linspace(0,abs(gain_fm),numel(f)).^gain_pwr/(abs(gain_fm)^(gain_pwr - 1)));
    
    % generate uncertainty of gain tfer:
    u_gain(:,1) = (u_dc_gain^2 + (linspace(0,u_gain_fm,numel(f)).^gain_pwr/(u_gain_fm^(gain_pwr - 1))).^2).^0.5;
    
    if gain_rper && gain_ramp
        
        % convert logscale to linear:
        gain_ramp = 10^(gain_ramp/20) - 1;
        
        % generate oscillating gain tfer (5922 FIR filter-like shape):
        gain_osc = gain_ramp.*sin(f/gain_rper*2*pi);
        % add to smooth gain:
        gain = gain + gain_osc;
    end
    
    % return frequency vector:
    qu_f.v = f;
    
    % return gain tfer quantity:
    qu_gain.v = gain;
    qu_gain.u = u_gain;
    
%      figure;
%      semilogx(f,gain)
%      hold on;
%      semilogx(f,gain + u_gain,'r')
    
    % generate smooth gain tfer:   
    phi(:,1) = sign(phi_max)*linspace(0,abs(phi_max),numel(f)).^phi_pwr/(abs(phi_max)^(phi_pwr - 1));
    u_phi(:,1) = (u_phi_min^2 + (linspace(0,u_phi_max,numel(f)).^phi_pwr/(u_phi_max^(phi_pwr - 1))).^2).^0.5;
    
%     figure;
%     semilogx(f,phi)
%     hold on;
%     semilogx(f,phi + u_phi,'r')
    
    % return phase tfer quantity: 
    qu_phi.v = phi;
    qu_phi.u = u_phi;
    
    

end