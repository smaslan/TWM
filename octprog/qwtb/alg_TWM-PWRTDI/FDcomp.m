function [Uo] = FDcomp(Ui, PhicompVector)
% This is part of Frequency Dependant Phase and Gain Compensation alg.
% Compensation of Frequency-dependent gain and phase errors.
% Raw time-frequency-time domain. Windowing is done Pre. and Post. this function
% ------------------------------------------
% Ui1 Sampled data
% PhicompVecto: Complex array, containing phase and gain correction over the spectrum
%
% This is part of the PWRTDI - TimeDomainIntegration power alg.
% (c) 2018, Kristian Ellingsberg
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.
%
% Modified: Stanislav Maslan (smaslan@cmi.cz)                
%

    % Check Input arguments
    if ~isequal(size(Ui,1), size(PhicompVector,1),1)  
        error('In function ''FDcomp(Ui,PhicompVector)'', Vector(s) not 1-domentional!');
    end
    if ~isequal(size(Ui,2), size(PhicompVector,2))  
        error('In function ''FDcomp(Ui1,PhicompVector)'', function was called with vector length mismatch!');
    end
    
    % samples count
    fft_size=size(Ui,2);
    
    % Check Input array-length
    if ~isequal(fft_size, 2^nextpow2(fft_size))  
        error('In function ''FDcomp(Ui1,Ui2,PhicompVector)'', Array lengt not exactly 2^N. Length mismatch!');
    end
    
    % Time-to-Frequenzy of sampled chunk Current-channel
    F_domain = fft(Ui,fft_size);  
    
    % Phase and Gain is corrected according to PhiCompVector
    Fcmpt = F_domain.* PhicompVector;  
    
    % ###todo: this should be somehow fixed, because in FFT filtering it is not possible to make phase
    %          correction of the nyquist component! So far just removing imaginary part...
    Fcmpt(fft_size/2+1) = real(Fcmpt(fft_size/2+1));
    
    % reconstruct time-domain:
    %###note: changed for Octave compatibility
    %Uo = ifft(Fcmpt,'symmetric'); % Uo2=ifft(YF,fft_size);
    Uo = real(ifft(Fcmpt)); % Uo2=ifft(YF,fft_size);

end


