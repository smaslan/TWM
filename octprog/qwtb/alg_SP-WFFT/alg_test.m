function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm SP-WFFT.
%
% See also qwtb

% Test proper results for odd and even samples --------------------------- %<<<1
DI.t.v = [0:1/3:1];
DI.t.v = DI.t.v(1:end-1);
DI.y.v = sin(2*pi*1*DI.t.v+1);
DO = qwtb('SP-WFFT', DI);
assert(all(abs(DO.f.v - [0 1]) < 1e-14));
assert(all(abs(DO.A.v - [0 1]) < 1e-14));
assert(all(abs(DO.ph.v(2) - 1) < 1e-14));

clear DI
DI.t.v=[0:1/4:1];
DI.t.v = DI.t.v(1:end-1);
DI.y.v=sin(2*pi*1*DI.t.v+1);
DO = qwtb('SP-WFFT', DI);
assert(all(abs(DO.f.v - [0 1 2]) < 1e-14));
assert(all(abs(DO.A.v - [0 1 0]) < 1e-14));
assert(all(abs(DO.ph.v(2)   - 1) < 1e-14));

% Test proper results for complex signal --------------------------- %<<<1
clear DI
DI.fs.v = 50;
DI.t.v = [0 : 1/DI.fs.v : 1];
DI.t.v = DI.t.v(1:end-1);
fnom = [1; 8; 15];
Anom = [1; 0.5; 0.3];
pnom = [0; 1; 2];
DI.y.v = zeros(size(DI.t.v));
for i = 1:length(fnom)
    DI.y.v = DI.y.v + Anom(i).*sin(2.*pi.*fnom(i).*DI.t.v + pnom(i));
end
DO = qwtb('SP-WFFT', DI);
assert(all(abs(DO.A.v(2)  -   1) < 1e-14));
assert(all(abs(DO.A.v(9)  - 0.5) < 1e-14));
assert(all(abs(DO.A.v(16) - 0.3) < 1e-14));

% Test windowing - cheb window --------------------------- %<<<1
clear DI
DI.fs.v = 50;
DI.t.v = [0 : 1/DI.fs.v : 1];
DI.t.v = DI.t.v(1:end-1);
DI.y.v = sin(2.*pi.*10.*DI.t.v);
DI.window.v = 'cheb';
DO = qwtb('SP-WFFT', DI);
assert (abs(DO.A.v(11)   - 1) < 1e-4);
DI.cheb_att.v = 200;
DO = qwtb('SP-WFFT', DI);
assert (abs(DO.A.v(11)   - 1) < 1e-7);

% Test windowing - gaussian window --------------------------- %<<<1
clear DI
DI.fs.v = 50;
DI.t.v = [0 : 1/DI.fs.v : 1];
DI.t.v = DI.t.v(1:end-1);
DI.y.v = sin(2.*pi.*10.*DI.t.v);
DI.window.v = 'gaussian';
DO = qwtb('SP-WFFT', DI);
assert (abs(DO.A.v(11) - 0.956) < 1e-3)
DI.gaussian_width.v = 2;
DO = qwtb('SP-WFFT', DI);
assert (abs(DO.A.v(11) - 0.385) < 1e-3)

% Test windowing - kaiser window --------------------------- %<<<1
clear DI
DI.fs.v = 50;
DI.t.v = [0 : 1/DI.fs.v : 1];
DI.t.v = DI.t.v(1:end-1);
DI.y.v = sin(2.*pi.*10.*DI.t.v);
DI.window.v = 'kaiser';
DO = qwtb('SP-WFFT', DI);
assert (abs(DO.A.v(12) - 0.012) < 1e-3)
DI.kaiser_att.v = 1e2;
DO = qwtb('SP-WFFT', DI);
assert (abs(DO.A.v(12) - 0.952) < 1e-3)

% Test windowing - tukey window --------------------------- %<<<1
clear DI
DI.fs.v = 50;
DI.t.v = [0 : 1/DI.fs.v : 1];
DI.t.v = DI.t.v(1:end-1);
DI.y.v = sin(2.*pi.*10.*DI.t.v);
DI.window.v = 'tukey';
DO = qwtb('SP-WFFT', DI);
assert (abs(DO.A.v(12) - 0.283) < 1e-3)
DI.tukey_ratio.v = 1;
DO = qwtb('SP-WFFT', DI);
assert (abs(DO.A.v(12)  - 0.5) < 1e-3)

% Test windowing and zero padding --------------------------- %<<<1
clear DI
DI.fs.v = 50;
DI.t.v = [0 : 1/DI.fs.v : 1];
DI.t.v = DI.t.v(1:end-1);
DI.y.v = sin(2.*pi.*10.*DI.t.v);
DI.window.v = 'cheb';
DI.fft_padding.v = 10.*length(DI.y.v);
DO = qwtb('SP-WFFT', DI);
assert (abs(DO.A.v(101) -  1) < 1e-4)
DI.cheb_att.v = 200;
DO = qwtb('SP-WFFT', DI);
assert (abs(DO.A.v(101) -  1) < 1e-7)

% Check alternative inputs --------------------------- %<<<1
clear DI
fs = 4;
t=[0:1/fs:1];
t = t(1:end-1);
DI.y.v=sin(2*pi*1*t+1);
DI.fs.v = fs;
DO = qwtb('SP-WFFT', DI);
assert(all(abs(DO.A.v - [0 1 0]) < 1e-14));

DI = rmfield(DI, 'fs');
DI.Ts.v = 1/fs;
DO = qwtb('SP-WFFT', DI);
assert(all(abs(DO.A.v - [0 1 0]) < 1e-14));

DI = rmfield(DI, 'Ts');
DI.t.v = t;
DO = qwtb('SP-WFFT', DI);
assert(all(abs(DO.A.v - [0 1 0]) < 1e-14));
% 
end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
