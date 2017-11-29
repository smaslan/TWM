% test of qwtb functions
% XXX missing tests for matrix input quantities
% XXX add tests for automatic transposing of column/row input vector quantities
clear all
tg = 1;

disp(['------ TEST GROUP ' num2str(tg) ': qwtb without arguments ------------']) % ------------------ %<<<1
tg = tg + 1;
algs = qwtb();

% test for existing algorithm testM: %<<<2
algsids = {algs.id};
assert(any(ismember(algsids, 'testM')))
% test for existing algorithm testG: %<<<2
assert(any(ismember(algsids, 'testG')))
% test for existing algorithm testGM: %<<<2
assert(any(ismember(algsids, 'testGM')))
% test for existing algorithm testQ: %<<<2
assert(any(ismember(algsids, 'testQ')))

disp(['------ TEST GROUP ' num2str(tg) ': error for incorrect numer of input arguments ------------']) % ------------------ %<<<1
tg = tg + 1;
try
    qwtb('a')
catch it
    disp(it.message)
end
assert(strcmpi(it.message(1:5), 'QWTB:'))
clear it

disp(['------ TEST GROUP ' num2str(tg) ': qwtb with two input arguments (no CS) ------------']) % ------------------ %<<<1
tg = tg + 1;
% prepare data: %<<<2
x = [1:20];
y = [1:20];
u = 0.1;

DI.x.v = x;
DI.x.u = x.*0 + u;
% XXX normrnd must be removed in future if these lines will be used:
%DI.t.r = normrnd( repmat(t, M, 1), repmat(u, size(repmat(t, M, 1))) );

DI.y.v = y;
DI.y.u = y.*0 + u;
% XXX normrnd must be removed in future if these lines will be used:
%DI.y.r = normrnd( repmat(y, M, 1), repmat(u, size(repmat(y, M, 1))) );

% test for results for algorithm testGM: %<<<2
[DO, DIout, CSout] = qwtb('testM', DI);
assert(DO.max.v == 20);
assert(DO.min.v == 1);

disp(['------ TEST GROUP ' num2str(tg) ': qwtb with three input arguments ------------']) % ------------------ %<<<1
tg = tg + 1;

% partial calculation settings structure: %<<<2
CS.verbose = 1;
[DO, DIout, CSout] = qwtb('testM', DI, CS);
assert(DO.max.v == 20);

disp(['------ TEST GROUP ' num2str(tg) ': guf by wrapper ------------']) % ------------------ %<<<1
tg = tg + 1;

CS.unc = 'guf';
[DO, DIout, CSout] = qwtb('testG', DI, CS);
assert(DO.max.v == 20);
assert(DO.max.u == 0.1);

disp(['------ TEST GROUP ' num2str(tg) ': for error guf unknown by wrapper ------------']) % ------------------ %<<<1
tg = tg + 1;
try
    [DO, DIout, CSout] = qwtb('testM', DI, CS);
catch it
    disp(it.message)
end
assert(strcmpi(it.message(1:5), 'QWTB:'))
clear it


disp(['------ TEST GROUP ' num2str(tg) ': mcm by wrapper - random test! ------------']) % ------------------ %<<<1
tg = tg + 1;

CS.unc = 'mcm';
CS.mcm.verbose = 1;
CS.mcm.repeats = 1e3;
[DO, DIout, CSout] = qwtb('testGM', DI, CS);
assert(DO.max.v > 19.9 && DO.max.v < 20.1);
assert(DO.max.u > 0.05 && DO.max.u < 0.15);

disp(['------ TEST GROUP ' num2str(tg) ': general mcm - random test! ------------']) % ------------------ %<<<1
tg = tg + 1;

CS.mcm.randomize = 1;
[DO, DIout, CSout] = qwtb('testG', DI, CS);
assert(DO.max.v > 19.9 && DO.max.v < 20.1);
assert(DO.max.u > 0.05 && DO.max.u < 0.15);

disp(['------ TEST GROUP ' num2str(tg) ': for error dof required but missing ------------']) % ------------------ %<<<1
tg = tg + 1;
CS.unc = 'guf';
CS.dof.req = 1;
CS.dof.gen = 0;
CS.cor.req = 1;
CS.cor.gen = 1;
try
    [DO, DIout, CSout] = qwtb('testG', DI, CS);
catch it
    disp(it.message)
end
assert(strcmpi(it.message(1:5), 'QWTB:'))
clear it

disp(['------ TEST GROUP ' num2str(tg) ': for error cor required but missing ------------']) % ------------------ %<<<1
tg = tg + 1;
CS.unc = 'guf';
CS.dof.req = 1;
CS.dof.gen = 1;
CS.cor.req = 1;
CS.cor.gen = 0;
try
    [DO, DIout, CSout] = qwtb('testG', DI, CS);
catch it
    disp(it.message)
end
assert(strcmpi(it.message(1:5), 'QWTB:'))
clear it

disp(['------ TEST GROUP ' num2str(tg) ': guf dof ------------']) % ------------------ %<<<1
tg = tg + 1;
CS.unc = 'guf';
CS.dof.req = 1;
CS.dof.gen = 0;
CS.cor.req = 0;
CS.cor.gen = 0;
DI.x.d = zeros(size(x)) + 123;
DI.y.d = zeros(size(y)) + 123;

[DO, DIout, CSout] = qwtb('testG', DI, CS);
assert(DO.max.d(1) == 123);
assert(DO.min.d(1) == 123);

% 2DO XXX  test calculation with cor

disp(['------ TEST GROUP ' num2str(tg) ': for error when CS is not correct but strict set ------------']) % ------------------ %<<<1
tg = tg + 1;
CS.strict = 1;
try
    [DO, DIout, CSout] = qwtb('testG', DI, CS);
catch it
    disp(it.message)
end
assert(strcmpi(it.message(1:5), 'QWTB:'))
clear it

disp(['------ TEST GROUP ' num2str(tg) ': missing and optional quantities ------------']) % ------------------ %<<<1
tg = tg + 1;
% prepare quantities: %<<<2
DIq.x.v = 1;
DIq.y.v = 1;
DIq.u.v = 1;
DIq.v.v = 1;
DIq.r.v = 1;
DIq.s.v = 1;
DIq.a.v = 1;
DIq.b.v = 1;
DIq.c.v = 1;
DIq.d.v = 1;

% all quantities present: %<<<2
[DO] = qwtb('testQ', DIq);

% only minimal required number of quantities: %<<<2
DIq2 = DIq;
DIq2 = rmfield(DIq2, 'y'); 
DIq2 = rmfield(DIq2, 'v'); 
DIq2 = rmfield(DIq2, 'r'); 
DIq2 = rmfield(DIq2, 's'); 
DIq2 = rmfield(DIq2, 'b'); 
DIq2 = rmfield(DIq2, 'd'); 
[DO] = qwtb('testQ', DIq2);

% only minimal required number of quantities with different selection of grouped quantities: %<<<2
DIq3 = DIq;
DIq3 = rmfield(DIq3, 'x'); 
DIq3 = rmfield(DIq3, 'u'); 
DIq3 = rmfield(DIq3, 'r'); 
DIq3 = rmfield(DIq3, 's'); 
DIq3 = rmfield(DIq3, 'b'); 
DIq3 = rmfield(DIq3, 'd'); 
[DO] = qwtb('testQ', DIq3);

% for error when one of non optional group missing: %<<<2
try
    [DO] = qwtb('testQ', rmfield(DIq2, 'x') );
catch it
    disp(it.message)
end
assert(strcmpi(it.message(1:5), 'QWTB:'))
clear it

% for error when one of partially optional group missing: %<<<2
try
    [DO] = qwtb('testQ', rmfield(DIq2, 'u') );
catch it
    disp(it.message)
end
assert(strcmpi(it.message(1:5), 'QWTB:'))
clear it

% for error when non optional quantity missing: %<<<2
try
    [DO] = qwtb('testQ', rmfield(DIq2, 'a') );
catch it
    disp(it.message)
end
assert(strcmpi(it.message(1:5), 'QWTB:'))
clear it

% for error when non optional parameter missing: %<<<2
try
    [DO] = qwtb('testQ', rmfield(DIq2, 'c') );
catch it
    disp(it.message)
end
assert(strcmpi(it.message(1:5), 'QWTB:'))
clear it

% test mcm on optional quantities and parameters %<<<2
CS = [];
CS.unc = 'mcm';
CS.mcm.repeats = 10;
DIq.x.u = 1;
DIq.y.u = 1;
DIq.u.u = 1;
DIq.v.u = 1;
DIq.r.u = 1;
DIq.s.u = 1;
DIq.a.u = 1;
DIq.b.u = 1;
[DO] = qwtb('testQ', DIq, CS);

disp(['------ TEST GROUP ' num2str(tg) ': general mcm test with vectors and matrices as input - random test! ------------']) % ------------------ %<<<1
tg = tg + 1;

CS.unc = 'mcm';
CS.mcm.randomize = 1;
CS.mcm.verbose = 1;
CS.mcm.repeats = 100;

% test mcm on vectors %<<<2
DIq.x.v = [1:5];
DIq.x.u = [1:5].*0.001;
[DO] = qwtb('testQ', DIq, CS);
assert( all(size(DO.o.v) == [1 5]) );
assert( all(size(DO.o.u) == [1 5]) );
assert( all(DO.o.u < 0.01) );
% XXX what is correct? : assert( all(size(DO.o.c,1) == [1 5]) );
% XXX what is correct? : assert( all(size(DO.o.d,1) == [1 5]) );
assert( all(size(DO.o.r) == [100 5]) );

DIq.x.v = [1:5]';
DIq.x.u = [1:5]'.*0.001;
[DO] = qwtb('testQ', DIq, CS);
assert( all(size(DO.o.v) == [1 5]) );
assert( all(size(DO.o.u) == [1 5]) );
assert( all(DO.o.u < 0.01) );
% XXX what is correct? : assert( all(size(DO.o.c,1) == [1 5]) );
% XXX what is correct? : assert( all(size(DO.o.d,1) == [1 5]) );
assert( all(size(DO.o.r) == [100 5]) );

% FINISH!
% % test mcm on matrices %<<<2
% DIq.x.v = ones(5,5);
% DIq.x.u = ones(5,5).*0.001;
% [DO] = qwtb('testQ', DIq, CS);
% assert( all(size(DO.o.v) == [5 5]) );
% assert( all(size(DO.o.u) == [5 5]) );
% assert( all(DO.o.u < 0.01) );
% % XXX what is correct? : assert( all(size(DO.o.c,1) == [1 5]) );
% % XXX what is correct? : assert( all(size(DO.o.d,1) == [1 5]) );
% assert( all(size(DO.o.r) == [100 5]) );

disp(['------ TEST GROUP ' num2str(tg) ': test algorithms one by one ------------']) % ------------------ %<<<1
tg = tg + 1;

for i = 1:length(algsids)
    disp(['test of algorithm: ' algsids{i}]);
    qwtb(algsids{i}, 'test');
end % for all algorithms

disp(['------ TEST GROUP ' num2str(tg) ': test getting algorithm info one by one ------------']) % ------------------ %<<<1
tg = tg + 1;

for i = 1:length(algsids)
    disp(['test of algorithm: ' algsids{i}]);
    qwtb(algsids{i}, 'info');
end % for all algorithms

disp(['------ TEST GROUP ' num2str(tg) ': test for existence of algorithms licenses ------------']) % ------------------ %<<<1
tg = tg + 1;

for i = 1:length(algsids)
    disp(['test of algorithm: ' algsids{i}]);
    qwtb(algsids{i}, 'license');
end % for all algorithms
disp(['------ ALL ' num2str(tg) ' GROUPS OF TESTS OK! ------------']) %<<<1
% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
