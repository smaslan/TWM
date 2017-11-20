function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm SFDR.
%
% See also qwtb

% Generate sample data --------------------------- %<<<1
%% Generate sample data
% First quantity |y| representing 1 second of signal containing spurious component is prepared. Main
% signal component has nominal frequency 1 kHz, nominal amplitude 2 V, nominal phase 1 rad and
% offset 1 V sampled at sampling frequency 10 kHz. 
DI = [];
fsnom = 1e4; Anom = 4; fnom = 100; phnom = 1; Onom = 0.2;
t = [0:1/fsnom:1-1/fsnom];
DI.y.v = Anom*sin(2*pi*fnom*t + phnom);
% Next a spurious component with amplitude at 1/100 of main carrier frequency is added. By definition the SFDR in dBc has to be 40.
DI.y.v = DI.y.v + Anom./100*sin(2*pi*fnom*3.5*t + phnom);

% Call algorithm --------------------------- %<<<1
DO = qwtb('SFDR', DI);

% Check results --------------------------- %<<<1
eps = 1e-6;
assert(DO.SFDRdBc.v > 20*log10(100/1) - eps);
assert(DO.SFDRdBc.v < 20*log10(100/1) + eps);

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
