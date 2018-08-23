function [f, A, P, O] = iDFT2pHann(Record,Ts)
% iDFT2p_Hann 2-point interpolated DFT frequency estimator using
% Hann window
%
%    [f, A, P] = iDFT2pHann(Record,Ts)
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
t = linspace(0,2*pi*(N-1)/N,N);
Wc0 = .5;                  % window coefficients
Wc1 = .5;                  
w = (Wc1 - Wc0*cos(t));    % Hann window vector
sp = fft(Record .* w);     % apply window on data and compute FFT
Sp = sp(1:fix(N/2));       % bound to even number of samples
M = sqrt(Sp .* conj(Sp));  % compute the magnitude spectrum of the Record
O    = M(1)/sum(w);        % save offset
M(1) = 0;                  % remove DC component
M(2) = 0;                  % and the first spectral line, affected by DC
[~,k] = max(M);            % find the fundamental as the strongest spectral component
% calculate relative distance of peak spectral amplitude (Eq. 37)
d = (2*M(k+1) - M(k)) / (M(k) + M(k+1));
% frequency estimation (Eq. 13)
f = (d + (k-1)) * fs / N;
% amplitude estimation (Eq. 38)
A1 = M(k);
A2 = abs((pi/2)/sin(d*pi));
A3 = abs(-0.25/(d-1) + 0.5/d - 0.25/(d+1));
A4 = 2/sum(w); % window amplitude FFT scaling
A = A1 * A2 / A3 * A4;
% phase estimation (Eq. 46)
P = angle(Sp(k)) - d*(pi/N)*(N-1) + pi/2;
if P > pi           % wrap phase within <-pi,pi>
    P = P - 2*pi;
end
if P < -pi
    P = P + 2*pi;
end

