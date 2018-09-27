function [me, dc,f0,A0, fm,Am,phm, u_A0,u_Am,u_f0x,u_fmx] = mod_tdps(fs,u,wshape,comp_err,unc)
% Simple algorithm for detection of modulation envelope and estimation
% of modulation parameters.
%
% [] = mod_tdps(fs,u,wshape,comp_err)
%
% Parameters:
%   fs       - sampling rate [Hz]
%   u        - signal waveform (vector of any direction)
%   wshape   - expected waveshape: 'sine' or 'rect'
%   comp_err - try to self-compensate error of the algorithm
%   unc      - enable uncertainty estimation 
%
% Returns:
%   me - modulation envelope vector
%   dc - DC offset of the signal
%   f0 - carrier frequency [Hz]
%   A0 - carrier amplitude
%   fm - modulation frequency [Hz]
%   Am - modulation amplitude
%   
% License:
% --------
% This is part of the modulation detector algorithm TDPS.
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT

    % wave to vertical vector:
    u = u(:);
    
    % samples count:
    N = numel(u);
    
    % detect envelope and estimate parameters:
    [me, dc,f0,A0, fm,Am,phm, u_A0,u_Am] = mod_fit_sin(fs,u,wshape);
    
    
    if strcmpi(wshape,'sine')
        % --- error self-compesantion ---
        % 1) this code will reconstruct the wave model from the detected parameters
        % 2) then in few iterations it will fiddle the model parameters so the 
        % 3) algorithm applied to the model returns the same parameters as used for 1)
        % this should eliminate any error of the algorithm but of course noise
        % or any harmonic content may mess up the result...
        
        % iterative parameters to fit    
        dci = dc;
        f0i = f0;
        A0i = A0;
        fmi = fm;
        Ami = Am;
        phmi = phm;
        
        % --- iterative correction loop:
        for k = 1:3
            
            % synth signal form the current model:
            ux = mod_synth(fs,N, dci, f0i,A0i,0, fmi,Ami,phmi);
            
            % calculate parameters of the model:
            [me_t, dcx,f0x,A0x, fmx,Amx,phmx] = mod_fit_sin(fs,ux,wshape);
            
            % update the model to next iteration
            dci = dci + (dci - dcx);
            f0i = f0i*f0/f0x;
            A0i = A0i*A0/A0x;                
            fmi = fmi*fm/fmx;
            Ami = Ami*Am/Amx;
            phmi = phmi + mod((phm - phmx) + pi,2*pi) - pi;            
        end
        
        if comp_err
            % override initial estimation:
            dc = dci;
            f0 = f0i;
            A0 = A0i;
            fm = fmi;
            Am = Ami;
            phm = phmi;
        else
            % do not override, just estimate uncertainty:
            
            u_A0 = (u_A0^2 + abs(A0-A0i)^2/3)^0.5;
            u_Am = (u_Am^2 + abs(Am-Ami)^2/3)^0.5;        
        end
        
    end
    
    
    
    if unc
    
        % empiric range of fm where artifacts for near integer f0/fm ratios occures [Hz]: 
        ca = fm/f0/N*5000;
            
        A0x = [];
        Amx = [];
        fmx = [];
        f0x = [];
        M = 30;    
        for k = 1:M
            
            % try various mod phases:
            phi = 2*pi*(k-1)/M;
            
            % randomize f0 a bit:
            df0 = 0;
            
            % randomize fm a bit:
            dfm = randn*2*ca;
            
            % synth signal form the current model:
            ux = mod_synth(fs,N, dc, f0+df0,A0,phi, fm+dfm,Am,phm, wshape);
            
            % calculate parameters of the model:
            [me_t, dcx,f0x(k),A0x(k), fmx(k),Amx(k),phmx] = mod_fit_sin(fs,ux,wshape);
            
            % fix fm back to mominal:
            fmx(k) = fmx(k) - dfm;
            % fix f0 back to mominal:
            f0x(k) = f0x(k) - df0;
                    
        end
        
        
    %     A0x = [];
    %     Amx = [];
    %     fmx = [];
    %     f0x = [];
    %     M = 100;    
    %     for k = 1:M
    %         
    %         % randomize fm a bit:
    %         dfm(k) = randn*0.0005*fm;
    %         
    %         % synth signal form the current model:
    %         ux = mod_synth(fs,N, dc, f0,A0,phi, fm+dfm(k),Am,phm, wshape);
    %         
    %         % calculate parameters of the model:
    %         [me_t, dcx,f0x(k),A0x(k), fmx(k),Amx(k),phmx] = mod_fit_sin(fs,ux,wshape);
    %         
    %     end    
    %     figure
    %     plot(dfm,fmx,'o')
        
        
        
        % add some estimate of unc. of the modulating signal initial phase shift:
        u_Am = (u_Am^2 + 4*std(Amx)^2/3)^0.5;
        u_A0 = (u_A0^2 + 4*std(A0x)^2/3)^0.5;    
        u_f0x = 2*std(f0x);
        u_fmx = 2*std(fmx);
    
    else
        
        u_Am = 0;
        u_A0 = 0;
        u_f0x = 0;
        u_fmx = 0;
        
    end
    
    
    
    %(N/fs*fm)
    %u_fm_rect = abs(1/(1/fs + 1/fm) - fm)/1

end