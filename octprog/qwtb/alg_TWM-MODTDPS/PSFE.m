function [fa A ph] = PSFE(Record,Ts,init_guess)
% PSFE (Phase Sensitive Frequnecy Estimator)
%    [fa, A, ph] = PSFE(Record,Ts,init_guess)
%
%       Input arguments
%       Record     - sampled input signal
%       Ts         - sampling time (in s)
%       init_guess: 0 - FFT max bin, 1 - IPDFT, negative initial frequency estimate
%
%       Output arguments
%       fa     - estimated signal's frequency
%       A      - estimated signal's amplitude
%       ph     - estimated signal's phase
%
% PSFE requires more than two periods of sampled signal and at least 
% 6 samples in the Record
% Copyright (c) 2012 by Rado Lapuh
% All rights reserved.

twopi = 2*pi;
M = length(Record);
Record = reshape(Record,1,M);
M2 = M/2;
cost_error = 2.4e-12;           % cost function treshold error
max_iter = 20;      % maximum number of algorithm iterations

Record = Record - mean(Record); % remove DC component - this is optional

if (nargin == 2)
    init_guess = 1;
end

if (init_guess >= 0)
    NFFT = 2^nextpow2(M);       % Next power of 2 from length of y
    t = fft(Record,NFFT);       % compute FFT
    tr = abs(t(1:NFFT/2));      % get the amplitude spectrum
    [~,I]=max(tr);              % find the index for the maximum value bin
    fa = (I-1)/(Ts*NFFT);       % and calculate the corresponding frequency
else
    fa = - init_guess;
end

if fa == 0                  % in the case the peak frequency is not found
    %%iter = 0;   
    A = 0;
    ph = 0;
    return 
end

iter = 0;
while 1                     % algorithm loop
    iter = iter+1;
    % selecting optimum window separation d0
    dmax = fix(M2);
    faTs = fa*Ts;
    if dmax < fix(1/(faTs)) 
        d0 = dmax;
    else
        dc = round((round(floor(dmax*faTs)/(faTs)):-(1/(faTs)):dmax/2));   % possible candidates for d0
        dd = dc*faTs;
        [~,I] = min(abs(round(dd)./dd-1)); % find minimum from arguments
        if I                        % I is not zero
            d0 = dc(I);
        else
            d0 = dmax;
        end
    end
    % use remaining samples for window width
    w0 = M - d0;

    % calculating phases from windows W1 and W2
    fTs = twopi*faTs;
    vct = fTs*(0:w0-1);
    D0 = [cos(vct);sin(vct);ones(1,w0)];
    D0T = D0 * D0';
    D0R = D0 * Record(1:w0)';
    x1 = D0T\D0R;
    ph1=atan(-x1(2)/x1(1));
    if x1(1) >= 0 
        ph1=ph1+pi; 
    end
    D0R = D0 * Record(d0+1:d0+w0)';
    x2 = D0T\D0R;
    ph2=atan(-x2(2)/x2(1));
    if x2(1) >= 0 
        ph2=ph2+pi; 
    end
    % calculating phase difference
    c1 = twopi*Ts*d0;
    Dph_a = c1*fa;
    dph_c = ph2 - ph1;
    P = round((Dph_a-dph_c)/twopi);
    Dph_c = dph_c+twopi*P;
    % calculating cost function
    eps = abs(Dph_a - Dph_c)/c1/fa/M;
    % calculating new frequency estimate
    fa = fa - (Dph_a - Dph_c)/c1;
    % check if the final frequency is reached
    if eps == 0 || eps < cost_error || iter >= max_iter
        %[A,ph] = ThreePSF(Record,fa,Ts);
        A = (sqrt(x1(1)^2+x1(2)^2) + sqrt(x2(1)^2+x2(2)^2))/2;
        ph = ph1-pi/2;
        return
    end
end
