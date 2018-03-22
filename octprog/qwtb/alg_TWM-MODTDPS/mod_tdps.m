function [me, dc,f0,A0, fm,Am] = mod_tdps(fs,u,wshape,comp_err)
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
    [me, dc,f0,A0, fm,Am,phm] = mod_fit_sin(fs,u,wshape);

    
    if comp_err && strcmpi(wshape,'sine')
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
            [me, dcx,f0x,A0x, fmx,Amx,phmx] = mod_fit_sin(fs,ux,wshape);
            
            % update the model to next iteration
            dci = dci + (dci - dcx);
            f0i = f0i*f0/f0x;
            A0i = A0i*A0/A0x;                
            fmi = fmi*fm/fmx;
            Ami = Ami*Am/Amx;
            phmi = phmi + mod((phm - phmx) + pi,2*pi) - pi;            
        end
        
        % override initial estimation:
        dc = dci;
        f0 = f0i;
        A0 = A0i;
        fm = fmi;
        Am = Ami;
        phm = phmi;
        
    end

end