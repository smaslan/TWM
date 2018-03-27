function [u,t] = mod_synth(fs,N,ofs, f0,A0,ph0, fm,Am,phm, wshape, cg, cph)
% A simple modulated waveform synthesizer. 
% It can synthesize sine wave modulated by sine or square.
% It can also apply gain/phase correction data to the synthesized signal.
% For sine modulation the gain/phase correction is exact, i.e. each component 
% of the spectrum of the signal is corrected by own g/ph coefficient.
% For rectangular square modulation the correction is just approximate
% by applying the gain/phase for resulting signal and not the components
% because that would be too complex.
% 
% [u,t] = mod_synth(fs,N,ofs, f0,A0,ph0, fm,Am,phm)
% [u,t] = mod_synth(fs,N,ofs, f0,A0,ph0, fm,Am,phm, wshape)
% [u,t] = mod_synth(fs,N,ofs, f0,A0,ph0, fm,Am,phm, wshape, cg, cphi)
%
% Parameters:
%  fs     - sampling rate [Hz]
%  N      - samples count
%  ofs    - dc offset
%  f0     - carrier freq. [Hz]
%  A0     - carrier amplidue
%  ph0    - carrier phase [rad]
%  fm     - modulating frequency [Hz]
%  Am     - modulating amplitude
%  phm    - modulating phase [rad]
%  wshape - optional, modulating waveshape (default: 'sine', 'rect' - square)
%  cg,cp  - optional, gain/phase correction coefficients:
%           scalar values: correction applied to whole signal (time domain)
%           vector of three elements (only for 'sine' wshape):
%             1. correction of the carrier f
%             2. correction of the left sideband f
%             3. correction of the right sideband f
%
% Returns:
%  u - waveform values vector
%  t - time vector [s]
%
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                

    
    % default shape:
    if nargin < 10
        wshape = 'sine';
    end
    
    % default correction data:
    if nargin < 12
        cg = 1;
        cph = 0;
    end
    
    
    % time vector *2*pi:
    t(:,1) = [0:N-1]/fs*2*pi;
    
    if strcmpi(wshape,'sine')
        % SINE - using synthesis from spectral components so we can apply correction data
    
        % frequency components to synthesize:
        fx =  [f0  f0-fm     f0+fm];
        Ax =  [A0  0.5*Am    0.5*Am].*(cg(:)');
        phx = [0   pi/2-phm  -pi/2+phm] + (cph(:)') + ph0;
        
        % synthesize (crippled for Matlab < 2016b):    
        %  ux = ofs + sum(Ax.*sin(t.*fx + phx),2);
        u = ofs + sum(bsxfun(@times,Ax,sin(bsxfun(@plus,bsxfun(@times,t,fx),phx))),2);
        
    elseif strcmpi(wshape,'rect')
        % RECTANGULAR - synthesize in timedomain - simplified
        
        u = ofs + sin(t*f0 + ph0 + cph).*(A0 + Am*(0.5 - (mod(t*fm + phm + cph,2*pi) > pi)))*cg;
    
    else
        error('Unknwon waveshape!');
    end

end