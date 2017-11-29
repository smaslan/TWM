function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm iDFT2p.
%
% See also qwtb

% Generate sample data --------------------------- %<<<1
DI = [];
fs = 1e4;
Anom = 1; fnom = 100; phnom = 1; Onom = 0.1;
t = [0:1/fs:1-1/fs];
DI.y.v = Anom*sin(2*pi*fnom*t + phnom) + Onom;
DI.Ts.v = 1/fs;

% Call algorithm --------------------------- %<<<1
% rectangular window:
DI.window.v = 'rectangular';
DO_r = qwtb('iDFT2p', DI);
% Hann window:
DI.window.v = 'Hann';
DO_h = qwtb('iDFT2p', DI);

% Check results --------------------------- %<<<1
feps = 1e-7;
Aeps = 1e-7;
pheps = 1e-7;
Oeps = 1e-7;

assert((DO_r.f.v > fnom.*(1-feps))    & (DO_r.f.v < fnom.*(1+feps)));
assert((DO_r.A.v > Anom.*(1-Aeps))    & (DO_r.A.v < Anom.*(1+Aeps)));
assert((DO_r.ph.v > phnom.*(1-pheps)) & (DO_r.ph.v < phnom.*(1+pheps)));
assert((DO_r.O.v > Onom.*(1-Oeps))  & (DO_r.O.v < Onom.*(1+Oeps)));

assert((DO_h.f.v > fnom.*(1-feps))    & (DO_h.f.v < fnom.*(1+feps)));
assert((DO_h.A.v > Anom.*(1-Aeps))    & (DO_h.A.v < Anom.*(1+Aeps)));
assert((DO_h.ph.v > phnom.*(1-pheps)) & (DO_h.ph.v < phnom.*(1+pheps)));
assert((DO_h.O.v > Onom.*(1-Oeps))  & (DO_h.O.v < Onom.*(1+Oeps)));

% Check alternative inputs --------------------------- %<<<1
DI = rmfield(DI, 'window');
DO = qwtb('iDFT2p', DI);
assert((DO.f.v > fnom.*(1-feps))    & (DO.f.v < fnom.*(1+feps)));
assert((DO.A.v > Anom.*(1-Aeps))    & (DO.A.v < Anom.*(1+Aeps)));
assert((DO.ph.v > phnom.*(1-pheps)) & (DO.ph.v < phnom.*(1+pheps)));
assert((DO.O.v > Onom.*(1-Oeps))    & (DO.O.v < Onom.*(1+Oeps)));

DI = rmfield(DI, 'Ts');
DI.fs.v = fs;
DO = qwtb('iDFT2p', DI);
assert((DO.f.v > fnom.*(1-feps))    & (DO.f.v < fnom.*(1+feps)));
assert((DO.A.v > Anom.*(1-Aeps))    & (DO.A.v < Anom.*(1+Aeps)));
assert((DO.ph.v > phnom.*(1-pheps)) & (DO.ph.v < phnom.*(1+pheps)));
assert((DO.O.v > Onom.*(1-Oeps))    & (DO.O.v < Onom.*(1+Oeps)));

DI = rmfield(DI, 'fs');
DI.t.v = t;
DO = qwtb('iDFT2p', DI);
assert((DO.f.v > fnom.*(1-feps))    & (DO.f.v < fnom.*(1+feps)));
assert((DO.A.v > Anom.*(1-Aeps))    & (DO.A.v < Anom.*(1+Aeps)));
assert((DO.ph.v > phnom.*(1-pheps)) & (DO.ph.v < phnom.*(1+pheps)));
assert((DO.O.v > Onom.*(1-Oeps))    & (DO.O.v < Onom.*(1+Oeps)));

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
