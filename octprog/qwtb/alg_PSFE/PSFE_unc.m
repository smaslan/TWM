function uncertainty = PSFE_unc(f, fs, N, jitter, rel_res, rel_harm_amp, rel_inter_amp)
%   uncertainty = PSFE_unc(f, fs, N, jitter, rel_res, rel_harm_amp, rel_inter_amp)
%   The function calculates uncertanty of the frequency estimation of the
%   PSFE algorithm.
%
%   uncertainty = PSFE_unc(100, 1e4, 1e5, 1e-9, 1e-5, 0.05, 0.01)
%
% Input parameters:
%   f              estimated frequency (default value 100 Hz)
%   fs             sampling frequency (default value 10 kHz)
%   N              number of samples (default value 100 kSa)
%   jitter         effective rms jitter in seconds (default value 1ns) 
%   rel_res        relative resolution i.e. resolution divided by the signal's amplitude
%                    (default value 1e-5, optimal value for DMM 3458 1e-8)
%   rel_harm_amp   relative amplitude of the harmonic, i.e. amplitude
%                     of the harmonic divided by amplitude of the fundamental signal 
%                    (parameter estimated by user)
%                    (defauld value 0.05)
%   rel_inter_amp  relative amplitude of the interharmonic, i.e. amplitude
%                     of the inteharmonic divided by amplitude of the fundamental signal 
%                    (parameter estimated by user)
%                    (default value 0.01)
%
% Output parameters:
%  uncertainty estimate in Hz (k=2)
%
% This is complementary function of the PSFE algorithm.
% (c) 2018, Marko Berginc, SIQ
% The script is distributed under MIT license, https://opensource.org/licenses/MIT. 

            %% Contributions
            % Jitter, normal distribution
            E_jitter = (1.341/(2.981+(0.622*N)^0.521))*f*jitter;

            % Resolution, rectangular distribution (only half interval)
            E_resolution = 2.8e-9*(rel_res)*(1/1e-5)*(N/100000)^-1.5*(fs/10000)^0.9;

            % Interharmonics, rectangular distribution (only half interval)
            E_interharmonics = 0.046*rel_inter_amp*(N/100000)^-1*(fs/10000);

            % Harmonics, rectangular distribution (only half interval)
            E_harmonics = 2e-3*20*rel_harm_amp;

            %% Overall uncertainty
            uncertainty = 2*sqrt((E_jitter)^2 + (E_resolution/sqrt(3))^2 + (E_interharmonics/sqrt(3))^2 + (E_harmonics/sqrt(3))^2);
            
end