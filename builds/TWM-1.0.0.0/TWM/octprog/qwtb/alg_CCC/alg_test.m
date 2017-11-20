function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm CCC
%
% See also qwtb

% Pearson data test (correct calculation test) --------------------------- %<<<1
% Generate data %<<<2
DI = [];
tmp = [
                0  5.900000000000000;
0.900000000000000  5.400000000000000;
1.800000000000000  4.400000000000000;
2.600000000000000  4.600000000000000;
3.300000000000000  3.500000000000000;
4.400000000000000  3.700000000000000;
5.200000000000000  2.800000000000000;
6.100000000000000  2.800000000000000;
6.500000000000000  2.400000000000000;
7.400000000000000  1.500000000000000;
];
DI.x.v = tmp(:, 1);
DI.y.v = tmp(:, 2);
DI.x.u = diag([
0.001     0     0       0     0      0            0    0            0 0;
    0 0.001     0       0     0      0            0    0            0 0;
    0     0 0.002       0     0      0            0    0            0 0;
    0     0     0 0.00125     0      0            0    0            0 0;
    0     0     0       0 0.005      0            0    0            0 0;
    0     0     0       0     0 0.0125            0    0            0 0;
    0     0     0       0     0      0 0.0166666667    0            0 0;
    0     0     0       0     0      0            0 0.05            0 0;
    0     0     0       0     0      0            0    0 0.5555555556 0;
    0     0     0       0     0      0            0    0            0 1;
].^0.5);
DI.y.u = diag([
1            0    0     0    0    0            0            0    0     0;
0 0.5555555556    0     0    0    0            0            0    0     0;
0            0 0.25     0    0    0            0            0    0     0;
0            0    0 0.125    0    0            0            0    0     0;
0            0    0     0 0.05    0            0            0    0     0;
0            0    0     0    0 0.05            0            0    0     0;
0            0    0     0    0    0 0.0142857143            0    0     0;
0            0    0     0    0    0            0 0.0142857143    0     0;
0            0    0     0    0    0            0            0 0.01     0;
0            0    0     0    0    0            0            0    0 0.002;
].^0.5);
DI.exponents.v = [0 1];
%DI.model.v = 'Model 3a';

% Call algorithm %<<<2
CS.unc = 'guf';
DO = qwtb('CCC',DI,CS);
% Check results %<<<2
% maximum error for following asserts are: if matlab and source code, 5e-9,
% 1e-9, 5e-9. However if octave and source code, error is up to: 3e-5, 6e-5,
% 3e-5
assert(all(abs(DO.coefs.v(:)' - [5.479903164 -0.4805320302]) < 3e-5));
% Octave: assert(all(abs(DO.coefs.v - [5.47992789668264101977e+00 -4.80534432554723556219e-01]) < 5e-5));
assert(all(abs(DO.coefs.u(:)' - [0.291932616 0.0576165101]) < 6e-5));
% Octave: assert(all(abs(DO.coefs.u - [2.91882690748166639949e-01 5.76040620346257720152e-02]) < 100*eps));
assert(all(abs(DO.yhat.v(:)' -[ 5.4800001313 5.0475708352 4.6145491900 4.2313711041 3.8852515947 3.3838148954 2.9426951164 2.6609978194 2.3968503192 1.5036406075 ]) < 3e-5));
assert(strcmpi(DO.model.v,'Model 3a'));


% Flow measurement data test (correct calculation test) --------------------------- %<<<1
% Generate data %<<<2
DI = [];
DI.x.v = [
 5.950000000000000 10.050000000000001 20.050000000000001 30.000000000000000 ;
49.950000000000003 75.049999999999997 99.950000000000003 99.950000000000003 ;
75.049999999999997 49.950000000000003 30.000000000000000 20.050000000000001 ;
10.050000000000001 5.950000000000000 5.950000000000000 10.050000000000001 ;
20.050000000000001 30.000000000000000 49.950000000000003 75.049999999999997 
];
DI.x.u = zeros(size(DI.x.v));
DI.y.v = [
1.120838481292929 1.047124426417910 1.018101016124688 1.012004271050000 ;
1.007430655821822 1.006733429257828 1.000571555736868 1.000179707640820 ;
1.006328327080613 1.007504568108108 1.011607251950000 1.017498697157107 ;
1.045377222248756 1.114184627393939 1.112317652363636 1.043228230736318 ;
1.015775872224439 1.009792254553333 1.005798080452452 1.005001878748834 
];
DI.y.u = zeros(size(DI.y.v));

DI.exponents.v = [-1 0 1];
%DI.model.v = 'Model 2b';

% Call algorithm %<<<2
CS.unc = 'guf';
DO = qwtb('CCC',DI,CS);
% Check results %<<<2
assert(all(abs(DO.coefs.v(:)' - [5.33121718956569345949e-01 9.92149296340203878941e-01 5.47155571830880188729e-05]) < 1e-12));
assert(all(abs(DO.coefs.u(:)' - [1.42857679484562294370e-01 7.83991519384110574498e-03 8.04368498803759954556e-05]) < 1e-12));
assert(all(abs(DO.yhat.v(:)' -[ 1.08207514280570715748e+00 1.04574612489950280469e+00 1.01983595517975822453e+00 1.01156148702091552849e+00 1.00555544590811707373e+00 1.00335925279029325452e+00 1.00295200041228493859e+00 1.00295200041228493859e+00 1.00335925279029325452e+00 1.00555544590811707373e+00 1.01156148702091552849e+00 1.01983595517975822453e+00 1.04574612489950280469e+00 1.08207514280570715748e+00 1.08207514280570715748e+00 1.04574612489950280469e+00 1.01983595517975822453e+00 1.01156148702091552849e+00 1.00555544590811707373e+00 1.00335925279029325452e+00 ]) < 1e-12));
assert(strcmpi(DO.model.v,'Model 2b'));

% all possibilities of input data tests --------------------------- %<<<1

x = [1:5];
y = 3+2.*x;
ux = zeros(size(x))+0.1;
uy = zeros(size(y))+0.2;
DI=[];
DI.exponents.v = [0 1]; 
CS.unc = 'guf';

% test automatic selection of Model 1a %<<<2
DI.x.v = x;
DI.y.v = y;
DI.x.u = zeros(size(x));
DI.y.u = uy;
DO = qwtb('CCC', DI, CS);
assert(all(abs(DO.coefs.v(:)' - [3 2]) < 1e-10));
assert(all(abs(DO.yhat.v(:)' - y(:)') < 1e-10));
assert(all(abs(DO.exponents.v(:)' - DI.exponents.v(:)') < 1e-10));
assert(abs(DO.func.v(x(end),DO.coefs.v) - y(end)) < 1e-10);
assert(strcmpi(DO.model.v,'Model 1a'));

% test automatic selection of Model 2a %<<<2
DI.x.v = x;
DI.y.v = y;
DI.x.u = zeros(size(x));
DI.y.u = uy + x.*0.1;
DO = qwtb('CCC', DI, CS);
assert(all(abs(DO.coefs.v(:)' - [3 2]) < 1e-10));
assert(all(abs(DO.yhat.v(:)' - y(:)') < 1e-10));
assert(all(abs(DO.exponents.v(:)' - DI.exponents.v(:)') < 1e-10));
assert(abs(DO.func.v(x(end),DO.coefs.v) - y(end)) < 1e-10);
assert(strcmpi(DO.model.v,'Model 2a'));

% test automatic selection of Model 3a %<<<2
DI.x.v = x;
DI.y.v = y;
DI.x.u = zeros(size(x));
DI.x.u = ux;
DO = qwtb('CCC', DI, CS);
assert(all(abs(DO.coefs.v(:)' - [3 2]) < 1e-10));
assert(all(abs(DO.yhat.v(:)' - y(:)') < 1e-10));
assert(all(abs(DO.exponents.v(:)' - DI.exponents.v(:)') < 1e-10));
assert(abs(DO.func.v(x(end),DO.coefs.v) - y(end)) < 1e-10);
assert(strcmpi(DO.model.v,'Model 3a'));

% test automatic selection of Model 2b %<<<2
DI.x.v = [x; x; x];
DI.y.v = [y-0.1; y; y+0.1];
DI.x.u = zeros(size(DI.x.v));
DI.y.u = zeros(size(DI.y.v));
DO = qwtb('CCC', DI, CS);
assert(all(abs(DO.coefs.v(:)' - [3 2]) < 1e-10));
assert(all(abs(DO.yhat.v(:)' - [y, y, y]) < 1e-10));
assert(all(abs(DO.exponents.v(:)' - DI.exponents.v(:)') < 1e-10));
assert(abs(DO.func.v(x(end),DO.coefs.v) - y(end)) < 1e-10);
assert(strcmpi(DO.model.v,'Model 2b'));

% test non-automatic Model 1b %<<<2
DI.x.v = [x-0.1; x; x+0.1];
DI.y.v = [y-0.1; y; y+0.1];
DI.x.u = zeros(size(DI.x.v));
DI.y.u = zeros(size(DI.y.v));
DI.model.v = 'Model 1b';
DO = qwtb('CCC', DI, CS);
assert(all(abs(DO.coefs.v(:)' - [3 2]) < 1e-2));
assert(all(abs(DO.yhat.v(:)' - [y, y, y]) < 0.3));
assert(all(abs(DO.exponents.v(:)' - DI.exponents.v(:)') < 1e-10));
assert(abs(DO.func.v(x(end),DO.coefs.v) - y(end)) < 1e-2);
assert(strcmpi(DO.model.v,'Model 1b'));

% test non-automatic Model 3b %<<<2
DI.x.v = [x-0.1; x; x+0.1];
DI.y.v = [y-0.1; y; y+0.1];
DI.x.u = zeros(size(DI.x.v));
DI.y.u = zeros(size(DI.y.v));
DI.model.v = 'Model 3b';
DO = qwtb('CCC', DI, CS);
assert(all(abs(DO.coefs.v(:)' - [3 2]) < 1e-2));
assert(all(abs(DO.yhat.v(:)' - [y, y, y]) < 0.2));
assert(all(abs(DO.exponents.v(:)' - DI.exponents.v(:)') < 1e-10));
assert(abs(DO.func.v(x(end),DO.coefs.v) - y(end)) < 1e-2);
assert(strcmpi(DO.model.v,'Model 3b'));

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
