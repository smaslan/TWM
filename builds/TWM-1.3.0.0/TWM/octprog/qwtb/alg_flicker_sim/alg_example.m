%% flicker_sim
% Example for algorithm flicker_sim.
%
% flicker_sim is an algorithm for calculation of flicker short-term flicker severity and instantaneous
% flicker sensation.

%% Generate sample data
% A time series representing voltage measured on a power supply line will be generated. Modulation
% amplitude |dVV| in percents, modulation frequency |CPM| in changes per minute, line frequency
% |f_c|, and line amplitude |A_c| in volts are selected according Table 5 of EN61000-4-15/A1, line
% 4, collumn 3. Measurement time |siglen| and sampling frequency |f_s| are selected according
% recommendations of algorithm flicker_sim. Resulted Pst should be very near 1. 
dVV = 0.894; CPM = 39; A_c = 230.*sqrt(2); f_c = 50; siglen = 720; f_s = 20000;
% Frequency of the modulation (flicker) signal in hertz:
f_F = CPM / ( 60 * 2 );
% Time series:
t = linspace(0, siglen, siglen.*f_s);
% Sampled signal. Modulation is set in such way 10 minutes before end of signal modulation is zero.
y = A_c*sin(2*pi*f_c*t) .* ( 1 + (dVV/100)/2*sign(sin(2*pi*f_F*t - (siglen - 10).*f_F.*2.*pi)) );

%% Set input data.
DI = [];
DI.y.v = y;
DI.fs.v = f_s;
DI.f_line.v = f_c;

%% Call algorithm
% Use QWTB to apply algorithm |flicker_sim| to data |DI|.
DO = qwtb('flicker_sim', DI);

%% Display results
% Short-term flicker severity:
Pst = DO.Pst
% Maximum of instantaneous flicker sensation:
Pinstmax = max(DO.Pinst)
