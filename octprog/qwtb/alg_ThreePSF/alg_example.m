%% Four parameter sine wave fitting
% Example for algorithm ThreePSF.
%
% ThreePSF is an algorithm for estimating the amplitude, phase and offset of the sine waveform
% according standard IEEE Std 1241-2000';

%% Generate sample data
% Two quantities are prepared: |t| and |y|, representing 1 second of sinus waveform of nominal
% frequency 1 kHz, nominal amplitude 1 V, nominal phase 1 rad and offset 1 V sampled at sampling
% frequency 10 kHz.
DI = [];
Anom = 2; fnom = 100; phnom = 1; Onom = 0.2;
t = [0:1/1e4:1-1/1e4];
DI.y.v = Anom*sin(2*pi*fnom*t + phnom) + Onom;
DI.Ts.v = 1e-4;
DI.f.v = fnom;

%% Call algorithm
% Use QWTB to apply algorithm |ThreePSF| to data |DI|.
CS.verbose = 1;
DO = qwtb('ThreePSF', DI, CS);

%% Display results
% Results is the amplitude, phase and offset of sampled waveform.
A = DO.A.v
ph = DO.ph.v
O = DO.O.v
%%
% Errors of estimation in parts per milion:
Aerrppm = (DO.A.v - Anom)/Anom .* 1e6
pherrppm = (DO.ph.v - phnom)/phnom .* 1e6
Oerrppm = (DO.O.v - Onom)/Onom .* 1e6
