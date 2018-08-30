function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm PSFE.
%
% See also qwtb

% Generate sample data --------------------------- %<<<1
DI = [];
Ts = 1e-4;
Anom = 1; fnom = 1; phnom = 1;
t = [0:Ts:1-Ts];
DI.Ts.v = Ts;
DI.y.v = Anom*sin(2*pi*fnom*t + phnom);

% Call algorithm --------------------------- %<<<1
DO = qwtb('PSFE', DI);

% Check results --------------------------- %<<<1
assert((DO.f.v > fnom.*(1-1e6)) & (DO.f.v < fnom.*(1+1e6)));
assert((DO.A.v > Anom.*(1-1e6)) & (DO.A.v < Anom.*(1+1e6)));
assert((DO.ph.v > phnom.*(1-1e6)) & (DO.ph.v < phnom.*(1+1e6)));

% Check alternative inputs --------------------------- %<<<1
DI = rmfield(DI, 'Ts');
DI.fs.v = 1/Ts;
DO = qwtb('PSFE', DI);
assert((DO.f.v > fnom.*(1-1e6)) & (DO.f.v < fnom.*(1+1e6)));
assert((DO.A.v > Anom.*(1-1e6)) & (DO.A.v < Anom.*(1+1e6)));
assert((DO.ph.v > phnom.*(1-1e6)) & (DO.ph.v < phnom.*(1+1e6)));

DI = rmfield(DI, 'fs');
DI.t.v = t;
DO = qwtb('PSFE', DI);
assert((DO.f.v > fnom.*(1-1e6)) & (DO.f.v < fnom.*(1+1e6)));
assert((DO.A.v > Anom.*(1-1e6)) & (DO.A.v < Anom.*(1+1e6)));
assert((DO.ph.v > phnom.*(1-1e6)) & (DO.ph.v < phnom.*(1+1e6)));

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
