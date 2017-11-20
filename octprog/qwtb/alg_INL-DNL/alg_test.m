function alg_test(calcset) %<<<1
% %2DO check results are correct
% Part of QWTB. Test script for algorithm INL-DNL.
%
% See also qwtb

% Generate sample data --------------------------- %<<<1
t=[0:1/1e4:1-1/1e4];
Anom = 1; fnom = 1e1; phnom = 0;
DI.y.v = Anom*sin(2*pi*fnom*t + phnom);
DI.bitres.v = 4;
% Calculate codes values. It is simualted by quantization and scaling. Usually
% it can be obtained directly by the ADC. Suppose ADC range is -1..1:
codes = DI.y.v;
rmin = -1;
rmax = 1;
levels = 2.^DI.bitres.v - 1;
codes(codes<rmin) = rmin;
codes(codes>rmax) = rmax;
codes = round((codes-rmin)./2.*levels);

%%
% Introduce ADC error.
codes(codes==2) = 3;
codes(codes==11) = 10;
codes = codes + min(codes);
DI.codes.v = codes;

% Call algorithm --------------------------- %<<<1
DO = qwtb('INL-DNL', DI);

% Check results --------------------------- %<<<1
assert((DO.INL.v(3) > -1.1) & (DO.INL.v(3) < -0.9));
assert((DO.INL.v(11) > 0.9) & (DO.INL.v(11) < 1.1));

assert((DO.DNL.v(2) > -1.1) & (DO.DNL.v(2) < -0.9));
assert((DO.DNL.v(3) >  0.9) & (DO.DNL.v(3) <  1.1));
assert((DO.DNL.v(10) >  0.9) & (DO.DNL.v(10) <  1.1));
assert((DO.DNL.v(11) > -1.1) & (DO.DNL.v(11) < -0.9));

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
