function [A phi O] = ThreePSF(Record,f,Ts)
% 3PSF (Three Parameter Sine Fit)
% calculates amplitude, phase and offset
%
%       Input arguments
%       Record     - sampled input signal
%       f          - signal frequency
%       Ts         - sampling time (in s)
%       StartIndex - starting sample
%       Length     - number of samples used
%       harmonic   - harmonic component to be calculated
%
%       Output arguments
%       A      - estimated signal amplitude
%       phi    - estimated signal phase
%       O      - estimated signal offset

% (c) Rado Lapuh

M = length(Record);
Record = Record(:); %Force column vector

fTs = 2*pi*f*Ts;
vct = fTs*(0:M-1);
D0 = [cos(vct);sin(vct);ones(1,M)]';
x1 = D0\Record;

phi =atan(-x1(2)/x1(1))-pi/2;
if x1(1) >= 0 
    phi = phi + pi; 
end
A = sqrt(x1(1)^2+x1(2)^2);
O = x1(3);

