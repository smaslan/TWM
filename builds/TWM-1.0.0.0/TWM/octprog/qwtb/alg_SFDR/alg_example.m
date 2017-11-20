%% Spurious Free Dynamic Range by means of Fast fourier transform
% Example for algorithm SFDR.
%
% Calculates SFDR by calculating FFT spectrum.

%% Generate sample data
% First quantity |y| representing 1 second of signal containing spurious component is prepared. Main
% signal component has nominal frequency 1 kHz, nominal amplitude 2 V, nominal phase 1 rad and
% offset 1 V sampled at sampling frequency 10 kHz. 
DI = [];
fsnom = 1e4; Anom = 4; fnom = 100; phnom = 1; Onom = 0.2;
t = [0:1/fsnom:1-1/fsnom];
DI.y.v = Anom*sin(2*pi*fnom*t + phnom);
%%
% A spurious component with amplitude at 1/100 of main carrier frequency is added. Thus by
% definition the SFDR in dBc has to be 40.
DI.y.v = DI.y.v + Anom./100*sin(2*pi*fnom*3.5*t + phnom);

%% Call algorithm
% Use QWTB to apply algorithm |SFDR| to data |DI|.
DO = qwtb('SFDR', DI);

%% Display results
% Result is the SFDR (dBc).
SFDR = DO.SFDRdBc.v
