function [f, A, P, O] = iDFT2pRect(Record,Ts)
% iDFT2p_Rect 2-point interpolated DFT frequency estimator using
% Rectangular window
%    
%    [f, A, P] = iDFT2pRect(Record,Ts)
%
%    Input arguments
%       Record     - sampled input Record
%       Ts         - sampling time (in s)
%    Output arguments
%       f          - estimated frequency
%       A          - estimated amplitude
%       P          - estimated phase
%       O          - estimated offset
%
%  reference: Krzysztof Duda: Interpolation algorithms of DFT for 
%  parameters estimation of sinusoidal and damped sinusoidal signals. 
%  In S. M. Salih, editor, Fourier Transform - Signal Processing, 
%  chapter 1, pages 3?32, InTech, 2012.
%  http://www.intechopen.com/books/fourier-transform-signal-processing/interpolated-dft
%  (c) Rado Lapuh, 2016

fs = 1/Ts;
N = length(Record);        % determine the number of samples
sp = fft(Record);          % Rectangular window used
Sp = sp(1:fix(N/2));       % bound to even number of samples
M = sqrt(Sp .* conj(Sp));  % compute the magnitude spectrum of the Record
O    = M(1)/N;             % save offset data
M(1) = 0;                  % remove DC component
M(2) = 0;                  % and the first spectral line, affected by DC
[~,k] = max(M);            % find the fundamental as the strongest spectral component
% calculate relative distance of peak spectral amplitude (Eq. 24)
d = M(k+1) / (M(k) + M(k+1));
% frequency estimation (Eq. 13)
f = ((k-1) + d) * fs / N;
if M(k+1) <= M(k-1)
    f = ((k-1) - d) * fs / N;
end
% amplitude estimation (Eq. 26)
A = (pi)/sin(d*pi)*d* M(k) * 2/N;
% phase estimation (Eq. 28)
P = angle(Sp(k)) - d*(pi/N)*(N-1) + pi/2;
if M(k+1) <= M(k-1)
    P = angle(Sp(k)) + d*(pi/N)*(N-1) + pi/2;
end
if P > pi           % wrap phase within <-pi,pi>
    P = P - 2*pi;
end
if P < -pi
    P = P + 2*pi;
end
                                                
