function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm SP-FFT.
%
% See also qwtb

% Generate sample data --------------------------- %<<<1
% Two quantities are prepared: |t| and |y|, representing 1 second of sine waveform with harmonics
% up to order N sampled at sampling frequency 1 kHz.
DI = [];
Ts = 1e-3;
N = 100;
flist = [1:N];
Alist = linspace(20, 1, N);
phlist = linspace(-pi-0.1, pi+0.1, N);
DI.t.v = [0:Ts:1-Ts];
DI.y.v = zeros(size(DI.t.v));
for i = 1:N
        DI.y.v = DI.y.v + Alist(i).*sin(2.*pi.*DI.t.v.*flist(i) + phlist(i));
end

% Call algorithm --------------------------- %<<<1
DO = qwtb('SP-FFT', DI);

% Check results --------------------------- %<<<1
fmaxerr = 1e4*eps;
Amaxerr = 1e4*eps;
phmaxerr = 1e4*eps;

% for comparison wrap phase list to -pi .. pi:
phlistwr = phlist - 2*pi*floor( (phlist+pi)/(2*pi) );

assert((DO.f.v(2:N+1) > flist.*(1-fmaxerr)) & (DO.f.v(2:N+1) < flist.*(1+fmaxerr)));
assert((DO.A.v(2:N+1) > Alist.*(1-Amaxerr)) & (DO.A.v(2:N+1) < Alist.*(1+Amaxerr)));
assert(abs(DO.ph.v(2:N+1) - phlistwr) < phmaxerr);

% Check alternative inputs --------------------------- %<<<1
DI = rmfield(DI, 't');
DI.fs.v = 1/Ts;
DO = qwtb('SP-FFT', DI);
assert((DO.f.v(2:N+1) > flist.*(1-fmaxerr)) & (DO.f.v(2:N+1) < flist.*(1+fmaxerr)));
assert((DO.A.v(2:N+1) > Alist.*(1-Amaxerr)) & (DO.A.v(2:N+1) < Alist.*(1+Amaxerr)));
assert(abs(DO.ph.v(2:N+1) - phlistwr) < phmaxerr);

DI = rmfield(DI, 'fs');
DI.Ts.v = Ts;
DO = qwtb('SP-FFT', DI);
assert((DO.f.v(2:N+1) > flist.*(1-fmaxerr)) & (DO.f.v(2:N+1) < flist.*(1+fmaxerr)));
assert((DO.A.v(2:N+1) > Alist.*(1-Amaxerr)) & (DO.A.v(2:N+1) < Alist.*(1+Amaxerr)));
assert(abs(DO.ph.v(2:N+1) - phlistwr) < phmaxerr);

end
