%% Integral and Differential Non Linearity of ADC
% Example for algorithm INL-DNL
%
% INL-DNL is an algorithm for estimating Integral and Differential Non-Linearity of an ADC. ADC has
% to sample a pure sine wave. To estimate all transition levels the amplitude of the sine wave
% should overdrive the full range of the ADC by at least 120%. If not so, non estimated transition
% levels will be assumed to be 0 and the results may be less accurate. As an input ADC codes are
% required.';
%
% See also 'Virosztek, T., Pálfi V., Renczes B., Kollár I., Balogh L., Sárhegyi
% A., Márkus J., Bilau Z. T., ADCTest project site: http://www.mit.bme.hu/projects/adctest 2000-2014';

%% Generate sample data
% Suppose a sine wave of nominal frequency 10 Hz and nominal amplitude 1.5 V is sampled by ADC with
% bit resolution of 4 and full range of 1 V. First quantity |bitres| with number of bits of
% resolution of the ADC is prepared and put into input data structure |DI|.
DI = [];
DI.bitres.v = 4;
%%
% Waveform is constructed. Amplitude is selected to overload the ADC.
t=[0:1/1e4:1-1/1e4];
Anom = 3.5; fnom = 2; phnom = 0;
wvfrm = Anom*sin(2*pi*fnom*t + phnom);
%%
% Next ADC code values are calculated. It is simulated by quantization and scaling of the sampled
% waveform. In real measurement code values can be obtained directly from the ADC. Suppose ADC range
% is -2..2.
codes = wvfrm;
rmin = -2; rmax = 2;
levels = 2.^DI.bitres.v - 1;
codes(codes<rmin) = rmin;
codes(codes>rmax) = rmax;
codes = round((codes-rmin)./(rmax-rmin).*levels);
%%
% Now lets introduce ADC error. Instead of generating code 2 ADC erroneously generates
% code 3 and instead of 11 it generates 10.
codes(codes==2) = 3;
codes(codes==11) = 10;
codes = codes + min(codes);
%%
% Create quantity |codes| and plot a figure with sampled sine wave and codes.
DI.codes.v = codes;
figure
hold on
stairs(t, codes);
wvfrm = (wvfrm - rmin)./(rmax-rmin).*levels;
plot(t, wvfrm, '-r');
xlabel('t (s)')
ylabel('Codes / Voltage (scaled)');
legend('Codes generated by ADC','Original waveform scaled to match codes');
hold off

%% Call algorithm 
% Apply INL algorithm to the input data |DI|.
DO = qwtb('INL-DNL', DI);

%%
% Plot results of integral non-linearity. One can clearly observe defects on codes 3 and
% 11.
figure
plot(DO.INL.v, '-x');
xlabel('Transition levels')
ylabel('INL (k)')
%%
% Plot results of differential non-linearity. One can clearly observe defects on transitions 2-3 and
% 10-11.
figure
plot(DO.DNL.v, '-x');
xlabel('Code bins')
ylabel('DNL (k)')
