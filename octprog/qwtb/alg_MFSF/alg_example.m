%% Multi-frequency sine fit
% Example for algorithm MFSF.
%
% MFSF is an algorithm for estimating the frequency, amplitude, and phase of the fundamental and harmonic
% components in a waveform. Amplitudes and phases of harmonic components are adjusted to find minimal
% sum of squared differences between sampled signal and multi-harmonic model. When all sampled signal
% harmonics are included in the model, the algorithm is efficient and produces no bias. It can even
% handle aliased harmonics, if they are not aliased back exactly at frequencies where other harmonics
% are already present. Further, it can also handle non harmonic components, when their frequency ratio
% to the fundamental frequency is exactly known a-priori.';
%
% See also:
% J. Schoukens, R. Pintelon, and G. Vandersteen, "A sinewave fitting procedure for characterizing
% data acquisition  channels in the presence of time base distortion and time jitter," IEEE Trans.
% Instrum. Meas., Vol. 46, No. 4, Aug. 1997, 1005-1010
% R. Lapuh, "Sampling % with 3458A", Left Right d.o.o., September 2018, ISBN 978-961-94476-0-4';

%% Generate sample data
% Two quantities are prepared: |Ts| and |y|, representing 1 second of sinus
% waveform of nominal frequency 1 Hz, nominal amplitude 1 V and nominal phase
% 0.1 rad, sampled with sampling time 0.1 ms, with three additional harmonics.
DI = [];
Anom = [1 0.5 0.3 0.2];
fnom = [1   2   3   4];
phnom = [0.1 0.2 0.3 0.4];
Onom = [1];
DI.Ts.v = 1e-4;
t = [0:DI.Ts.v:1-DI.Ts.v];
DI.y.v = Anom'.*sin(2.*pi.*fnom'.*t + phnom');
DI.y.v = sum(DI.y.v, 1) + Onom;
% tell algorithm which component to expect:
DI.ExpComp.v = [1 2 3 4];
% set estimate of main component frequency:
DI.fest.v = 1.1;
%%
% Add noise:
DI.y.v = DI.y.v + 1e-3.*randn(size(DI.y.v));

%% Call algorithm
% Use QWTB to apply algorithm |PSFE| to data |DI|.
DO = qwtb('MFSF', DI);

%% Display results
% Results is the amplitude, frequency and phase of sampled waveform.
f = DO.f.v
A = DO.A.v
ph = DO.ph.v
O = DO.O.v
%%
% Errors of estimation in parts per milion:
ferrppm = (DO.f.v - fnom)./fnom .* 1e6
Aerrppm = (DO.A.v - Anom)./Anom .* 1e6
pherrppm = (DO.ph.v - phnom)./phnom .* 1e6
Oerrppm = (DO.O.v - Onom)./Onom .* 1e6
