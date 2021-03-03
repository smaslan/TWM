function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm MFSF.
%
% See also qwtb

% Generate sample data --------------------------- %<<<1
DI = [];
Ts = 1e-4;
Anom = [1 0.5 0.3 0.2];
fnom = [1   2   3   4];
phnom = [0.1 0.2 0.3 0.4];
Onom = [1];
THDnom = sqrt(sum(Anom(2:length(Anom)).^2))/Anom(1);
t = [0:Ts:1-Ts];
DI.Ts.v = Ts;
DI.y.v = Anom'.*sin(2.*pi.*fnom'.*t + phnom');
DI.y.v = sum(DI.y.v, 1) + Onom;
DI.ExpComp.v = [1 2 3 4];
DI.fest.v = 1;

% Call algorithm --------------------------- %<<<1
DO = qwtb('MFSF', DI);

% Check results --------------------------- %<<<1
assert((DO.f.v > fnom.*(1-1e6)) & (DO.f.v < fnom.*(1+1e6)));
assert((DO.A.v > Anom.*(1-1e6)) & (DO.A.v < Anom.*(1+1e6)));
assert((DO.ph.v > phnom.*(1-1e6)) & (DO.ph.v < phnom.*(1+1e6)));
assert((DO.O.v > Onom.*(1-1e6)) & (DO.O.v < Onom.*(1+1e6)));
assert((DO.THD.v > THDnom.*(1-1e6)) & (DO.THD.v > THDnom.*(1-1e6)));

% Check alternative inputs for time/freq/period --------------------------- %<<<1
DI = rmfield(DI, 'Ts');
DI.fs.v = 1/Ts;
DO = qwtb('MFSF', DI);
assert((DO.f.v > fnom.*(1-1e6)) & (DO.f.v < fnom.*(1+1e6)));
assert((DO.A.v > Anom.*(1-1e6)) & (DO.A.v < Anom.*(1+1e6)));
assert((DO.ph.v > phnom.*(1-1e6)) & (DO.ph.v < phnom.*(1+1e6)));
assert((DO.O.v > Onom.*(1-1e6)) & (DO.O.v < Onom.*(1+1e6)));
assert((DO.THD.v > THDnom.*(1-1e6)) & (DO.THD.v > THDnom.*(1-1e6)));

DI = rmfield(DI, 'fs');
DI.t.v = t;
DO = qwtb('MFSF', DI);
assert((DO.f.v > fnom.*(1-1e6)) & (DO.f.v < fnom.*(1+1e6)));
assert((DO.A.v > Anom.*(1-1e6)) & (DO.A.v < Anom.*(1+1e6)));
assert((DO.ph.v > phnom.*(1-1e6)) & (DO.ph.v < phnom.*(1+1e6)));
assert((DO.O.v > Onom.*(1-1e6)) & (DO.O.v < Onom.*(1+1e6)));
assert((DO.THD.v > THDnom.*(1-1e6)) & (DO.THD.v > THDnom.*(1-1e6)));

% Check alternative inputs for frequency estimator --------------------------- %<<<1
DI.fest.v = -1;
[DO, DI2] = qwtb('MFSF', DI);
assert((DO.f.v > fnom.*(1-1e6)) & (DO.f.v < fnom.*(1+1e6)));
DI.fest.v = 'ipdft';
[DO, DI2] = qwtb('MFSF', DI);
assert((DO.f.v > fnom.*(1-1e6)) & (DO.f.v < fnom.*(1+1e6)));
DI.fest.v = 'psfe';
[DO, DI2] = qwtb('MFSF', DI);
assert((DO.f.v > fnom.*(1-1e6)) & (DO.f.v < fnom.*(1+1e6)));

% Check uncertainty calculation - GUF --------------------------- %<<<1
CS.unc = 'guf';
DI = rmfield(DI, 't');
DI.Ts.v = Ts;
DI.Ts.u = Ts.*1e-9;
DI.y.u = DI.y.v.*1e-6;
DI.fest.v = -1;
DO = qwtb('MFSF', DI, CS);
assert(numel(DO.f.u) == 4);
assert(all(DO.f.u > 0));

% Check uncertainty calculation - MCM --------------------------- %<<<1
CS.unc = 'mcm';
DI.CFT.v = 1.2345e-13;
DI.fest.v = 1;
DO = qwtb('MFSF', DI, CS);
assert(numel(DO.f.u) == 4);
assert(all(DO.f.u > 0));

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
