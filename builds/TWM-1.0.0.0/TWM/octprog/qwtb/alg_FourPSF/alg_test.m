function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm FourPSF
%
% See also qwtb

% Generate sample data --------------------------- %<<<1
DI = [];
Anom = 2; fnom = 100; phnom = 1; Onom = 0.2; Ts = 1e-4;
DI.t.v = [0:Ts:1-Ts];
DI.y.v = Anom*sin(2*pi*fnom*DI.t.v + phnom) + Onom;
% estimate of frequency 
DI.fest.v = 100.2;

% Call algorithm
DO = qwtb('FourPSF', DI);

% Check results --------------------------- %<<<1
maxerr = 1e-10;
assert((DO.f.v > fnom.*(1-maxerr)) & (DO.f.v < fnom.*(1+maxerr)));
assert((DO.A.v > Anom.*(1-maxerr)) & (DO.A.v < Anom.*(1+maxerr)));
assert((DO.ph.v > phnom.*(1-maxerr)) & (DO.ph.v < phnom.*(1+maxerr)));
assert((DO.O.v > Onom.*(1-maxerr)) & (DO.O.v < Onom.*(1+maxerr)));

% Check alternative inputs --------------------------- %<<<1
DI = rmfield(DI, 't');
DI.fs.v = 1/Ts;
DO = qwtb('FourPSF', DI);
assert((DO.f.v > fnom.*(1-maxerr)) & (DO.f.v < fnom.*(1+maxerr)));
assert((DO.A.v > Anom.*(1-maxerr)) & (DO.A.v < Anom.*(1+maxerr)));
assert((DO.ph.v > phnom.*(1-maxerr)) & (DO.ph.v < phnom.*(1+maxerr)));
assert((DO.O.v > Onom.*(1-maxerr)) & (DO.O.v < Onom.*(1+maxerr)));

DI = rmfield(DI, 'fs');
DI.Ts.v = Ts;
DO = qwtb('FourPSF', DI);
assert((DO.f.v > fnom.*(1-maxerr)) & (DO.f.v < fnom.*(1+maxerr)));
assert((DO.A.v > Anom.*(1-maxerr)) & (DO.A.v < Anom.*(1+maxerr)));
assert((DO.ph.v > phnom.*(1-maxerr)) & (DO.ph.v < phnom.*(1+maxerr)));
assert((DO.O.v > Onom.*(1-maxerr)) & (DO.O.v < Onom.*(1+maxerr)));
end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
