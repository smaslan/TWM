function [u_f1, u_A1, u_Ah] = MFSF_unc(f1, A1, fs, N, res, SNR, jitter)
%   [u_f, u_A1, u_Ah] = MFSF_unc(f1, A1, fs, N, res, SNR, jitter)
%   The function calculates uncertanty of the MHFE algorithm.
%   
%   [u_f1, u_A1, u_Ah] = MFSF_unc(100, 1, 10000, 10000, 1e-6, 1000, 1e-9);
%
% Input parameters:
%   f1                  estimated frequency of the fundamental signal in Hz (default value 100 Hz)
%   A1                  estimated amplitude of the fundamental signal in V (default value 1 V)
%   fs                  sampling frequency in Hz (default value 10 kHz)
%   N                   number of samples (default value 10 kSa)
%   res                 resolution in V (default value 1e-6 V, optimal value for DMM 3458 1e-8 V)
%   SNR                 signal-to-noise ratio (in linear scale, not logarithmic)         
%   jitter              effective jitter in seconds (default value 1ns) 
% Output parameters:
%   u_f1                uncertainty of frequency estimation in Hz (k=2)
%   u_A1                uncertainty of fundamental signal amplitude estimation in V (k=2)
%   u_Ah                uncertainty of other harmonics amplitude estimation in V (k=2)
%
%
% This is part of the QWTB MFSF wrapper.
% (c) 2018, Marko Berginc, SIQ Slovenia
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.   

    %% Contributions
    % Resolution
    u_f1_res=0.52e-9*(fs/1e4)^1.6*(N/1e4)^-2*(A1/1)^-1*(res/1e-6)^1;
    u_A1_res=50e-9*(fs/1e4)^-0.5*(f1/100)^0.5*(res/1e-6)^1;
    u_Ah_res=0.13e-6*(fs/1e4)^-0.5*(f1/100)^0.5*(res/1e-6)^1;
    %Noise
    u_f1_noise=5.5e-6*(fs/1e4)^1*(N/1e4)^-1.5*(SNR/1000)^-1;
    u_A1_noise=1e-5*(N/1e4)^-0.5*(A1/1)^1*(SNR/1000)^-1;
    u_Ah_noise=25e-6*(N/1e4)^-0.5*(A1/1)^1*(SNR/1000)^-1;
    %Jitter
    u_f1_jitter=1e-6*(fs/1e4)^1.2*(N/1e4)^-1.7*(f1/100)^0.55*(jitter/1e-9)^1.2;
    u_A1_jitter=2.1e-6*(A1/1)^1*(f1/100)^1*(jitter/1e-9)^1;
    u_Ah_jitter=5e-6*(N/1e4)^-0.5*(A1/1)^1*(f1/100)^1*(jitter/1e-9)^1;
    
    %% Overall uncertainty
    u_f1=2*sqrt(u_f1_res^2+u_f1_noise^2+u_f1_jitter^2);
    u_A1=2*sqrt(u_A1_res^2+u_A1_noise^2+u_A1_jitter^2);
    u_Ah=2*sqrt(u_Ah_res^2+u_Ah_noise^2+u_Ah_jitter^2);

end