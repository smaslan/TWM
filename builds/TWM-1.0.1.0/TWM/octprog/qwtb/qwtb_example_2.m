%% Example of the QWTB use
% Data are simulated, QWTB is used with different algorithms.

%% Generate ideal data
% Sample data are generated, representing 1 second of sine waveform of nominal
% frequency |fnom| 1000 Hz, nominal amplitude |Anom| 1 V and nominal phase
% |phnom| 1 rad. Data are sampled at sampling frequency |fsnom| 10 kHz,
% perfectly synchronized, no noise.
Anom = 1; fnom = 1000; phnom = 1; fsnom = 10e4;
timestamps = [0:1/fsnom:0.1-1/fsnom];
ideal_wave = Anom*sin(2*pi*fnom*timestamps + phnom);
%%
% To use QWTB, data are put into two quantities: |t| and |y|. Both quantities
% are put into data in structure |DI|.
DI = [];
DI.t.v = timestamps;
DI.y.v = ideal_wave;

%% Apply three algorithms
% QWTB will be used to apply three algorithms to determine frequency and
% amplitude: |SP-FFT|, |PSFE| and |FPNLSF|. Results are in data out structure
% |DOxxx|. Algorithm |FPNLSF| requires an estimate, select it to 0.1% different
% from nominal frequency. |SP-FFT| requires sampling frequency.
DI.fest.v = fnom.*1.001;
DI.fs.v = fsnom;
DOspfft = qwtb('SP-FFT', DI);
DOpsfe = qwtb('PSFE', DI);
DOfpnlsf = qwtb('FPNLSF', DI);

%% Compare results for ideal signal
% Calculate relative errors in ppm for all algorithm to know which one is best.
% |SP-FFT| returns whole spectrum, so only the largest amplitude peak is
% interesting. One can see for the ideal case all errors are very small.
disp('SP-FFT errors (ppm):')
[tmp, ind] = max(DOspfft.A.v);
ferr  = (DOspfft.f.v(ind) - fnom)/fnom .* 1e6 
Aerr  = (DOspfft.A.v(ind) - Anom)/Anom .* 1e6
pherr = (DOspfft.ph.v(ind) - phnom)/phnom .* 1e6

disp('PSFE errors (ppm):')
ferr  = (DOpsfe.f.v - fnom)/fnom .* 1e6 
Aerr  = (DOpsfe.A.v - Anom)/Anom .* 1e6
pherr = (DOpsfe.ph.v - phnom)/phnom .* 1e6

disp('FPNLSF errors (ppm):')
ferr  = (DOfpnlsf.f.v - fnom)/fnom .* 1e6 
Aerr  = (DOfpnlsf.A.v - Anom)/Anom .* 1e6
pherr = (DOfpnlsf.ph.v - phnom)/phnom .* 1e6

%% Noisy signal
% To simulate real measurement, noise is added with normal distribution and
% standard deviation |sigma| of 100 microvolt. Algorithms are again applied.
sigma = 100e-6;
DI.y.v = ideal_wave + 100e-6.*randn(size(ideal_wave));
DOspfft = qwtb('SP-FFT', DI);
DOpsfe = qwtb('PSFE', DI);
DOfpnlsf = qwtb('FPNLSF', DI);

%% Compare results for noisy signal
% Again relative errors are compared. One can see amplitude and phase errors
% increased to several ppm, however frequency is still determined quite good by
% all three algorithms. FFT is not affected by noise at all.
disp('SP-FFT errors (ppm):')
[tmp, ind] = max(DOspfft.A.v);
ferr  = (DOspfft.f.v(ind) - fnom)/fnom .* 1e6 
Aerr  = (DOspfft.A.v(ind) - Anom)/Anom .* 1e6
pherr = (DOspfft.ph.v(ind) - phnom)/phnom .* 1e6

disp('PSFE errors:')
ferr  = (DOpsfe.f.v - fnom)/fnom .* 1e6 
Aerr  = (DOpsfe.A.v - Anom)/Anom .* 1e6
pherr = (DOpsfe.ph.v - phnom)/phnom .* 1e6

disp('FPNLSF errors:')
ferr  = (DOfpnlsf.f.v - fnom)/fnom .* 1e6 
Aerr  = (DOfpnlsf.A.v - Anom)/Anom .* 1e6
pherr = (DOfpnlsf.ph.v - phnom)/phnom .* 1e6

%% Non-coherent signal
% In real measurement coherent measurement does not exist. So in next test the
% frequency of the signal differs by 20 ppm:
fnc = fnom*(1 + 20e-6);
noncoh_wave = Anom*sin(2*pi*fnc*timestamps + phnom);
DI.y.v = noncoh_wave;
DOspfft = qwtb('SP-FFT', DI);
DOpsfe = qwtb('PSFE', DI);
DOfpnlsf = qwtb('FPNLSF', DI);

%% Compare results for non-coherent signal
% Comparison of relative errors. Results of |PSFE| or |FPNLSF| are correct, however
% FFT is affected by non-coherent signal considerably.
disp('SP-FFT errors (ppm):')
[tmp, ind] = max(DOspfft.A.v);
ferr  = (DOspfft.f.v(ind) - fnc)/fnc .* 1e6 
Aerr  = (DOspfft.A.v(ind) - Anom)/Anom .* 1e6
pherr = (DOspfft.ph.v(ind) - phnom)/phnom .* 1e6

disp('PSFE errors:')
ferr  = (DOpsfe.f.v - fnc)/fnc .* 1e6 
Aerr  = (DOpsfe.A.v - Anom)/Anom .* 1e6
pherr = (DOpsfe.ph.v - phnom)/phnom .* 1e6

disp('FPNLSF errors:')
ferr  = (DOfpnlsf.f.v - fnc)/fnc .* 1e6 
Aerr  = (DOfpnlsf.A.v - Anom)/Anom .* 1e6
pherr = (DOfpnlsf.ph.v - phnom)/phnom .* 1e6

%% Harmonically distorted signal.
% In other cases a harmonic distortion can appear. Suppose a signal with second
% order harmonic of 10% amplitude as the main signal.
hadist_wave = Anom*sin(2*pi*fnom*timestamps + phnom) + 0.1*Anom*sin(2*pi*fnom*2*timestamps + 2);
DI.y.v = hadist_wave;
DOspfft = qwtb('SP-FFT', DI);
DOpsfe = qwtb('PSFE', DI);
DOfpnlsf = qwtb('FPNLSF', DI);

%% Compare results for harmonically distorted signal.
% Comparison of relative errors. |SP-FFT| or |PSFE| are not affected by harmonic
% distortion, however |FPNLSF| is thus is not suitable for such signal.
disp('SP-FFT errors (ppm):')
[tmp, ind] = max(DOspfft.A.v);
ferr  = (DOspfft.f.v(ind) - fnom)/fnom .* 1e6 
Aerr  = (DOspfft.A.v(ind) - Anom)/Anom .* 1e6
pherr = (DOspfft.ph.v(ind) - phnom)/phnom .* 1e6

disp('PSFE errors:')
ferr  = (DOpsfe.f.v - fnom)/fnom .* 1e6 
Aerr  = (DOpsfe.A.v - Anom)/Anom .* 1e6
pherr = (DOpsfe.ph.v - phnom)/phnom .* 1e6

disp('FPNLSF errors:')
ferr  = (DOfpnlsf.f.v - fnom)/fnom .* 1e6 
Aerr  = (DOfpnlsf.A.v - Anom)/Anom .* 1e6
pherr = (DOfpnlsf.ph.v - phnom)/phnom .* 1e6

%% Harmonically distorted, noisy, non-coherent signal.
% In final test all distortions are put in a waveform and results are compared.
err_wave = Anom*sin(2*pi*fnc*timestamps + phnom) + 0.1*Anom*sin(2*pi*fnc*2*timestamps + 2) + 100e-6.*randn(size(ideal_wave));
DI.y.v = err_wave;
DOspfft = qwtb('SP-FFT', DI);
DOpsfe = qwtb('PSFE', DI);
DOfpnlsf = qwtb('FPNLSF', DI);

%% Compare results for harmonically distorted, noisy, non-coherent signal.
% 
disp('SP-FFT errors (ppm):')
[tmp, ind] = max(DOspfft.A.v);
ferr  = (DOspfft.f.v(ind) - fnc)/fnc .* 1e6 
Aerr  = (DOspfft.A.v(ind) - Anom)/Anom .* 1e6
pherr = (DOspfft.ph.v(ind) - phnom)/phnom .* 1e6

disp('PSFE errors:')
ferr  = (DOpsfe.f.v - fnc)/fnc .* 1e6 
Aerr  = (DOpsfe.A.v - Anom)/Anom .* 1e6
pherr = (DOpsfe.ph.v - phnom)/phnom .* 1e6

disp('FPNLSF errors:')
ferr  = (DOfpnlsf.f.v - fnc)/fnc .* 1e6 
Aerr  = (DOfpnlsf.A.v - Anom)/Anom .* 1e6
pherr = (DOfpnlsf.ph.v - phnom)/phnom .* 1e6
