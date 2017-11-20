function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm SINAD-ENOB.
%
% See also qwtb

% Generate sample data --------------------------- %<<<1
% Two quantities are prepared: |t| and |y|, representing 1 second of sinus waveform of nominal
% frequency 1 kHz, nominal amplitude 1 V, nominal phase 1 rad and offset 1 V sampled at sampling
% frequency 10 kHz.
DI = [];
Ts = 1e-4;
Anom = 2; fnom = 100; phnom = 1; Onom = 0.2;
DI.t.v = [0:Ts:1-Ts];
DI.y.v = Anom*sin(2*pi*fnom*DI.t.v + phnom) + Onom;
% add noise:
noisestd = 1e-4;
DI.y.v = DI.y.v + noisestd.*randn(size(DI.y.v));
% set main signal component properties:
DI.f.v = fnom;
DI.A.v = Anom;
DI.ph.v = phnom;
DI.O.v = Onom;
% Suppose the signal was sampled by a 20 bit digitizer with full scale range of 6 V (+- 3V). (The
% signal is not quantised, so the quantization noise is not present. Thus the simulation and results
% are not fully correct.):
DI.bitres.v = 20;
DI.FSR.v = 3;

% Call algorithm --------------------------- %<<<1
DO = qwtb('SINAD-ENOB', DI);

% Check results --------------------------- %<<<1
SINADdBnom = 20*log10(Anom./(noisestd.*sqrt(2)));
% IEEE Std 1241-2000, page 54, eq. 102:
ENOBnom = log2(DI.FSR.v./(noisestd.*sqrt(12)));
% these limits are based on experience, are affected by the length of the signal and averaging of
% random numbers:
SINADdBmaxerr = 0.005;
ENOBmaxerr = 0.005;
assert((DO.ENOB.v > ENOBnom.*(1-ENOBmaxerr)) & (DO.ENOB.v < ENOBnom.*(1+ENOBmaxerr)));
assert((DO.SINADdB.v > SINADdBnom.*(1-SINADdBmaxerr)) & (DO.SINADdB.v < SINADdBnom.*(1+SINADdBmaxerr)));

% Check alternative inputs --------------------------- %<<<1
DI = rmfield(DI, 't');
DI.fs.v = 1/Ts;
DO = qwtb('SINAD-ENOB', DI);
assert((DO.ENOB.v > ENOBnom.*(1-ENOBmaxerr)) & (DO.ENOB.v < ENOBnom.*(1+ENOBmaxerr)));
assert((DO.SINADdB.v > SINADdBnom.*(1-SINADdBmaxerr)) & (DO.SINADdB.v < SINADdBnom.*(1+SINADdBmaxerr)));

DI = rmfield(DI, 'fs');
DI.Ts.v = Ts;
DO = qwtb('SINAD-ENOB', DI);
assert((DO.ENOB.v > ENOBnom.*(1-ENOBmaxerr)) & (DO.ENOB.v < ENOBnom.*(1+ENOBmaxerr)));
assert((DO.SINADdB.v > SINADdBnom.*(1-SINADdBmaxerr)) & (DO.SINADdB.v < SINADdBnom.*(1+SINADdBmaxerr)));

end
