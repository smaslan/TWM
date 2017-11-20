%% Signal Spectrum by means of Fast fourier transform
% Example for algorithm SP-FFT.
%
% Calculates frequency and phase spectrum by means of Fast Fourier Transform algorithm. Result is
% normalized.

%% Generate sample data
% Two quantities are prepared: |y| and |fs|, representing 1 second of signal containing 5 harmonic
% components and one inter-harmonic component. Main signal component has nominal frequency 1 kHz,
% nominal amplitude 2 V, nominal phase 1 rad and offset 1 V sampled at sampling frequency 10 kHz.
DI = [];
fsnom = 1e4; Anom = 2; fnom = 100; phnom = 1; Onom = 0.2;
t = [0:1/fsnom:1-1/fsnom];
DI.y.v = Anom*sin(2*pi*fnom*t + phnom);
for i = 2:45
        DI.y.v = DI.y.v + Anom./i*sin(2*pi*fnom*i*t + phnom + i - 1);
end
DI.y.v = DI.y.v + 1*sin(2*pi*fnom*1.456*t + phnom);
DI.fs.v = fsnom;

%% Call algorithm
% Use QWTB to apply algorithm |SP-FFT| to data |DI|.
DO = qwtb('SP-FFT', DI);

%% Display results
% Results is the amplitude and phase spectrum.
figure
plot(DO.f.v, DO.A.v, '-x')
xlabel('f (Hz)'); ylabel('A (V)'); title('Amplitude spectrum of the signal');
figure
plot(DO.f.v, DO.ph.v, '-x')
xlabel('f (Hz)'); ylabel('phase (rad)'); title('Phase spectrum of the signal');
