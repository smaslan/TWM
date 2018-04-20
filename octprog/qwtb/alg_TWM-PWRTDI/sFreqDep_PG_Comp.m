function [Uc1, first, last] = sFreqDep_PG_Comp(U1, fft_size, CmpVector1)
% Frequency Dependant Phase and Gain Compensation
%
% Input arguments:
% U1         : Sampling buffer data array (uncompensated) 
% fft_size   : FFT size
% CmpVector1 : Complex vector holding Gain and Phase compensation

% Output: 
% Uc1         : Compensated output data array
% first, last : Index of which part of the input buffer is used for output
%
% This is part of the PWRTDI - TimeDomainIntegration power alg.
% (c) 2018, Kristian Ellingsberg
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.
%
% Modified: Stanislav Maslan (smaslan@cmi.cz)                
%

    if ~isequal(fft_size, 2^nextpow2(fft_size))  
        error('Compensation vector must be of size 2^N!');
    end
    N = 2^nextpow2(fft_size); % Size of FFT
    Hw = HannFcompMask(N)/2;  % Masking for overlapping processing windows
    
    % set startconditions
    C1 = zeros(1,N/4); 
    Uc1 = []; % Start with empty output array
    [Bs Be Tp]=PackMan(size(U1,2),N,N/4,1);           
    %[Bs Be Tp]
    for frame = 1:Tp
        % find frame:
        [Bs Be Tp]=PackMan(size(U1,2),N,N/4,frame);  %Find Frame Position         
        %[frame Bs Be]
        
        Uo1 = FDcomp(U1(Bs:Be),CmpVector1); % Run compensation over frame data:
        % Windowing the result 
        Uo1 = Uo1.*Hw;  
                
        if frame ~=1,
            % pick data for sum and concatenation
            Uc1 = [Uc1,C1+Uo1(N*1/4+1:N*2/4)]; %data for morhping with prew. frame
        end
        C1 = Uo1(N*2/4+1:N*3/4); %data for morhping with next frame
    end
    
    first =N/2+1;
    last = Be-N/2;

end
