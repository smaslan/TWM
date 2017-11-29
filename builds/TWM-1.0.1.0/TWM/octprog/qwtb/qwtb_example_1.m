%% Simple example of the QWTB use
% Sample data are simulated. QWTB is used to apply two different algorithms on the
% same data. Uncertainty of the results is calculated by means of Monte Carlo
% Method.

%% Generate sample data
% Two quantities are prepared: |t| and |y|, representing 0.5 second of sinus
% waveform of nominal frequency 1 kHz, nominal amplitude 1 V and nominal phase
% 1 rad, sampled at sampling frequency |fsnom| 10 kHz.
DI = [];
Anom = 1; fnom = 1e3; phnom = 1; fsnom = 1e4;
DI.t.v = [0:1/fsnom:0.5];
DI.y.v = Anom*sin(2*pi*fnom*DI.t.v + phnom);
%%
% Add noise of standard deviation 1 mV:
DI.y.v = DI.y.v + 1e-3.*randn(size(DI.y.v));

%% Analyzing data
% To get a frequency spectrum, algorithm |SP-FFT| can be used. This algorithm
% requires sampling frequency, so third quantity |fs| is added.
DI.fs.v = fsnom;
DO = qwtb('SP-FFT', DI);
plot(DO.f.v, DO.A.v, '-xb'); xlim([980 1020])
%%
% One can see it is not a coherent measurement. Therefore to get 'unknown'
% amplitude and frequency of the signal algorithm |PSFE| can be used:
DO = qwtb('PSFE', DI);
f = DO.f.v
A = DO.A.v

%% Uncertainties
% Uncertainties are added to the |t| (time stamps) and |y| (sampled data) structures.
DI.t.u = zeros(size(DI.t.v)) + 1e-5;
DI.y.u = zeros(size(DI.y.v)) + 1e-4;
%%
% Calculations settings is created with Monte Carlo uncertainty calculation
% method, 1000 repeats and singlecore calculation. The output of messages is supressed to increase
% calculation speed.
CS.unc = 'mcm';
CS.mcm.repeats = 1000;
CS.mcm.method = 'singlecore';
CS.verbose = 0;
%%
% An uncertainty of sampling frequency has to be added. Let suppose the value:
DI.fs.u = 1e-3;
%%
% Run PSFE algorithm on input data |DI| and with calculattion settings |CS|.
DO = qwtb('PSFE',DI,CS);
%%
% Result is displayed as a histogram of calculated frequency.
figure; hist(DO.f.r,50);
%%
% One can see the histogram is not Gaussian function. To get correct
% uncertainties, a shortest coverage interval has to be used.
