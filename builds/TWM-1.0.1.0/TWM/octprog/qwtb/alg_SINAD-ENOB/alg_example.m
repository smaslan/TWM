%% Ratio of signal to noise and distortion and Effective number of bits (time space)
% Example for algorithm SINAD-ENOB.
%
% Algorithm calculates Ratio of signal to noise and distortion and Effective number of bits in time
% space. First signal is generated, then estimates of signal parameters are calculated by Four
% parameter sine wave fitting and next SINAD and ENOB are calculated. This example do not take
% into account a quantisation noise.
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
% Add a noise with normal distribution probability:
noisestd = 1e-4;
DI.y.v = DI.y.v + noisestd.*randn(size(DI.y.v));
%%
% Lets make an estimate of frequency 0.2 percent higher than nominal value:
DI.fest.v = 100.2;

%% Calculate estimates of signal parameters
% Use QWTB to apply algorithm |FPNLSF| to data |DI|.
CS.verbose = 1;
DO = qwtb('FPNLSF', DI, CS);

%% Copy results to inputs
% Take results of |FPNLSF| and put them as inputs |DI|.
DI.f = DO.f;
DI.A = DO.A;
DI.ph = DO.ph;
DI.O = DO.O;
%%
% Suppose the signal was sampled by a 20 bit digitizer with full scale range |FSR| of 6 V (+- 3V). (The
% signal is not quantised, so the quantization noise is not present. Thus the simulation and results
% are not fully correct.):
DI.bitres.v = 20;
DI.FSR.v = 3;

%% Calculate SINAD and ENOB
% 
DO = qwtb('SINAD-ENOB', DI, CS);

%% Display results:
% Results are:
SINADdB = DO.SINADdB.v
ENOB = DO.ENOB.v
%%
% Theoretical value of SINADdB is 20*log10(Anom./(noisestd.*sqrt(2))). Theoretical value of ENOB is
% log2(DI.range.v./(noisestd.*sqrt(12))). Absolute error of results are:
SINADdBtheor = 20*log10(Anom./(noisestd.*sqrt(2)));
ENOBtheor = log2(DI.FSR.v./(noisestd.*sqrt(12)));
SINADerror = SINADdB - SINADdBtheor
ENOBerror = ENOB - ENOBtheor
