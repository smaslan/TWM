function [f, A, P, O] = iDFT3pRect(Record,Ts)
% IDFT3p_Rect 3-point interpolated DFT frequency estimator using
% Rectangular window
%
%    [f, A, P] = iDFT3pRect(Record,Ts)
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
sp = fft(Record);          % no window on data and compute FFT
Sp = sp(1:fix(N/2));       % bound to even number of samples
M = sqrt(Sp .* conj(Sp));  % compute the magnitude spectrum of the Record
O    = M(1)/N;             % save offset
M(1) = 0;                  % remove DC component
M(2) = 0;                  % and the first spectral line, affected by DC
[~,k] = max(M);            % find the fundamental as the strongest spectral component
% calculate relative distance of peak spectral amplitude (Eq. 30)
d = (M(k+1) + M(k-1)) / (-M(k-1) + 2*M(k) + M(k+1));
% frequency estimation (Eq. 13)
f = (d + (k-1)) * fs / N;
if M(k+1) <= M(k-1)
    f = ((k-1) - d) * fs / N;
end
% calculate summations (Eq. 18)(3.1.3 Higher order RVCI windows)
S1 =  1/abs(d+1);
S2 =  1/abs(d);
S3 =  1/abs(d-1);
% amplitude estimation (Eq. 45)
A1 = (2*pi)/sin(d*pi);
A2 = (M(k-1)+2*M(k)+M(k+1));
A3 = (S1+2*S2+S3);
A4 = 1/N;
A  = A1 * A2 / A3 * A4;
% phase estimation (Eq. 46)
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
                                                
