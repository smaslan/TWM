%% Four parameter sine wave fitting
% Example for algorithm FPNLSF.
%
% FPNLSF is an algorithm for estimating the frequency, amplitude, and phase of the sine waveform. The
% algorithm use least squares method. Algorithm requires good estimate of frequency.
%

%% Generate sample data
% Two quantities are prepared: |t| and |y|, representing 1 second of sinus waveform of nominal
% frequency 1 kHz, nominal amplitude 1 V, nominal phase 1 rad and offset 1 V sampled at sampling
% frequency 10 kHz.
DI = [];
Anom = 2; fnom = 100; phnom = 1; Onom = 0.2;
DI.t.v = [0:1/1e4:1-1/1e4];
DI.y.v = Anom*sin(2*pi*fnom*DI.t.v + phnom) + Onom;
%%
% Lets make an estimate of frequency 0.2 percent higher than nominal value:
DI.fest.v = 100.2;

%% Call algorithm
% Use QWTB to apply algorithm |FPNLSF| to data |DI|.
CS.verbose = 1;
DO = qwtb('FPNLSF', DI, CS);

%% Display results
% Results is the amplitude, frequency and phase of sampled waveform.
A = DO.A.v
f = DO.f.v
ph = DO.ph.v
O = DO.O.v
%%
% Errors of estimation in parts per milion:
Aerrppm = (DO.A.v - Anom)/Anom .* 1e6
ferrppm = (DO.f.v - fnom)/fnom .* 1e6
pherrppm = (DO.ph.v - phnom)/phnom .* 1e6
Oerrppm = (DO.O.v - Onom)/Onom .* 1e6
