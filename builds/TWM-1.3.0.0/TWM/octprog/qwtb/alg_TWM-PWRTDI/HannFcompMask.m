function  maskWindow = HannFcompMask(N)
% This is part of Frequency Dependant Phase and Gain Compensation alg. Generates padded Hann window.
% Note the window itself is normalized.
%
% N = fft data buffer size
%
% This is part of the PWRTDI - TimeDomainIntegration power alg.
% (c) 2018, Kristian Ellingsberg
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.
%
% Modified: Stanislav Maslan (smaslan@cmi.cz)                
%    
    
    NFFTh = 2^nextpow2(N)/4; % Next power of 2 from length of y
    
    % normalized hanning window (periodic):
    w = hanning(NFFTh*2+1);
    w = w(1:end-1)/mean(w(1:end-1));

    % generate padded window:
    maskWindow = [zeros(1,NFFTh) w.' zeros(1,NFFTh)];

end
 
