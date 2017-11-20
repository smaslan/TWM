function [f A ph O]=FourPSF(data, Ts)
%SFIT4  IEEE-STD-1241 Standard four parameter fit of a sine wave to measured data
%
%       [f A ph j]=sfit4(data, Ts)
%
%       Input arguments:
%         data: vector of measured samples
%         Ts:   sampling time
%         init_guess: 0 - FFT max bin, 1 - IPDFT, negative initial
%         frequency estimate
%         werror: cost function treshold
%       Output arguments:
%         f    - frequency of the fitted cosine
%         A    - amplitude of the fitted cosine
%         ph   - phase of the fitted cosine
%         j    - number of iterations taken

% Written by Zolt?n Tam?s Bilau, modified by Janos Markus
% $Id: sfit4.m,v 3.0 2004/04/19 11:20:09 markus Exp $
% Copyright (c) 2001-2004 by Istvan Kollar and Janos Markus
% Modified 2016 Rado Lapuh
% All rights reserved.

werror = 3.5e-9;
maxCycN=100;

N=length(data);
if N<4, error('Less than four samples'); end
t = (0:N-1)*Ts;

% find initial frequency guess
Fc=fft(data);
F=abs(Fc);
[Mfft,w]=max(F(1:round(N/2)));
fa = (w-1)/(N*Ts);
w=2*pi*fa;
        
data=data(:); %Force column vector

% three parameters (step 0):
D0=[cos(w*t);sin(w*t);ones(1,N)]';
x0=D0\data;
x0(4)=0;

icyc=0;
while 1
    icyc=icyc+1;
    D0=[cos(w*t);sin(w*t);ones(1,N);-x0(1)*t.*sin(w*t)+x0(2)*t.*cos(w*t)]';    
    x0=D0\data;
    if abs(x0(4))<0.05*w 
       w=w+x0(4); %adjust w
    else
       w=w+.05*x0(4);
    end
    
    if abs(x0(4))<werror/Ts 
        break; 
    end
    if icyc>=maxCycN 
        break; 
    end
end

%Compose output:
A=sqrt(x0(1)^2+x0(2)^2);
f=w/2/pi;
O = x0(3);
if x0(1)>0
    ph=atan(-x0(2)/x0(1))+pi/2;
elseif x0(1)<0
    ph=atan(-x0(2)/x0(1))-pi/2;
else %x0(1)==0
    if x0(2)<0, ph=pi/2;
    else ph=3*pi/2;
    end
end

