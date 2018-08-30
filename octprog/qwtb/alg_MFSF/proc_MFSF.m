function res = proc_MFSF(sim)
% Monte Carlo single iteration function for algorithm MHFE.
% It synthesizes waveform with known parameters, calculates MHFE once
% and compares the MFSF results with the expected parameters of the 
% waveform.
% This is designed to be called in a loop or via cellfun() style function
% preferrably in parallel (parfor, parcellfun, multicore, ...). One call
% per Monte Carlo iteration.
%
% Usage:
%   res = proc_MFSF(sim)
%
% Inputs:
%   sim.N - samples count 
%   sim.fs - sampling rate [Hz]
%   sim.har - harmonic factors (e.g. 1 for fundamental, 2 for 2nd harmonic, etc.)
%   sim.f0 - fundamental component frequency [Hz]
%   sim.f0_unc - is estimate of 'f0' uncertainty, note it is used only to 
%                randomize generated signals, but the ref. value for MHFE
%                result comparison is always the randomized one.
%                So this won't add directly to resulting uncertainty of 'f'! 
%                It will just reflect MHFE sensitivity to f0/fs ratio
%                which will appear in the resulting uncertainty.
%   sim.jitter - rms jitter of the sampling [s]
%   sim.lsb - absolute resolution
%   sim.noise_rms - rms noise estimate (we expect gaussian)
%   sim.ofs - estimated DC offset
%   sim.ofs_unc - estimated DC offset uncertainty
%   sim.A - vector of harmonic amplitudes
%   sim.h_amp_unc - relative uncertainty of harmonics estimation
%                   note this is because the full spectrum of actual signal
%                   is calculated using some window with finite scalloping 
%                   note: same meaning as for 'f0_unc'  
%   sim.ph - vector of harmonic phase angles [rad]
%   sim.sfdr - SFDR related to fundamental component [-]
%              e.g. 1e-4 means spurs up to (1e-4*A(1))
%   sim.h_id - ids of additional harmonics
%              e.g.: 5,6,7,9,21,...
%   sim.h_amp - max harmonic amplitudes (matching to sim.h_id)
%   sim.ih_f - list of interharmonic frequencies [Hz]
%   sim.ih_f_unc - DFT bin step [Hz], this is used to simulate limited 
%                  resolution of FFT used to find the interharmonics
%   sim.ih_amp - list of interharmonic amplitudes matching the 'ih_f'  
%
% Outputs:
%   res.f0_dev - relative deviation of fundamental frequency [-]
%   res.A_dev - absolute deviation of aplitudes of harmonics
%   res.ph_dev - absolute deviation of phases of harmonics
%   res.ofs_dev - absolute deviation of dc offset
%                      
%   
% This is part of the QWTB MHFE wrapper.
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.    
 

    % --- Simulator:
    
    % fitted components count:    
    sim.H = numel(sim.har);
    % fitted component relative frequencies:    
    sim.har = reshape(sim.har,[1 sim.H]);
    
    % noisify estimate of fundamental frequency to simulate:
    f0_sim = sim.f0*(1 + randn*sim.f0_unc);
    
    % time vector of simulation:
    tw(:,1) = ([0:sim.N-1]/sim.fs + sim.jitter*randn(1,sim.N))*2*pi;
    
    % estimated harmonics: 
    fx = f0_sim*sim.har;    
    Ax = sim.A.*(1 + randn(size(sim.A))*sim.h_amp_unc);
    phx = rand(1,sim.H)*2*pi; % ###note: overriding actually estimated phase because we aint got no adea how accurate it was
    
    % add random SFDR voltage vectors to the synthesized harmonics (but not to the reference values!):  
    Usfdr = [0, (sim.sfdr*Ax(1)*exp(j*rand(1,sim.H-1)*2*pi))];
    Ux = Ax.*exp(j*phx) + Usfdr;
    
    % synthesize estimated harmonics (crippled for Matlab < 2016b):
    %  u = sum(abs(Ux).*sin(tw.*fx + angle(Ux)),2)
    u = sin(bsxfun(@plus,tw*fx,angle(Ux)))*abs(Ux(:));
        
    
    % exact harmonics of f0:
    if ~isempty(sim.h_id) 
        fh  = sim.h_id*f0_sim;
        Ah  = sim.h_amp.*(1 + randn(size(sim.h_amp))*sim.h_amp_unc);
        phh = rand(size(fh))*2*pi; % random phase
        
        % synthesize estimated harmonics (crippled for Matlab < 2016b):
        %  ux = sum(Ah*sin(tw.*fh + phh),2)        
        u = u + sin(bsxfun(@plus,tw*fh,phh))*Ah(:);;
    end
    
         
    % additional interharmonics:
    if ~isempty(sim.ih_f) 
        fh  = sim.ih_f + randn(size(sim.ih_f))*sim.ih_f_unc; % randomize f. by +-1 DFT bin becasue we don't have accurate freq.
        Ah  = sim.ih_amp.*(1 + randn(size(sim.ih_f))*sim.h_amp_unc);
        phh = rand(size(fh))*2*pi; % random phase
        
        % synthesize estimated harmonics (crippled for Matlab < 2016b):
        %  ux = sum(Ah*sin(tw.*fh + phh),2)
        u = u + sin(bsxfun(@plus,tw*fh,phh))*Ah(:);
    end   
    
    % add rms noise:
    u = u + randn(sim.N,1)*sim.noise_rms;
    
    % generate randomized dc offset:
    ofsx = sim.ofs + sim.ofs_unc*(2*rand - 1);
    
    % add offset voltage:
    u = u + ofsx;
        
    % emulate quantisation:
    u = round(u/sim.lsb)*sim.lsb;
        
    
    % --- Calculation:
    
    if sim.mfsf_ig < 0
        % better initial estimate:
        fest = ipdft_spect(fft(u),sim.fs);
    else
        % standard mode:
        fest = sim.mfsf_ig;
    end
    
    % call MFSF to get estimes of the simulated signal:
    [fa A ph O] = MFSF(u, 1/sim.fs, sim.har, fest, sim.mfsf_cft);
    
    % calculate deviation of estimated parameters:        
    res.f0_dev = fa/f0_sim - 1;
    res.A_dev = A - Ax;
    res.ph_dev = mod(ph - phx + pi,2*pi) - pi;
    res.ofs_dev = O - ofsx;
           
end