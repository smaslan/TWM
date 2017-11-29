%% testM
% Example for algorithm testM. Algorithm is usefull only for testing QWTB toolbox. It calculates
% maximal and minimal value of the record. MCM is calculated by wrapper.
%
% See also |qwtb|

%% Generate sample data
% Two quantities are prepared: |x| and |y|.
x = []; y = [];
x.v = [1:20];
y.v = [1:14 13:-1:8];
%%
% All uncertainties are set to 1.
x.u = x.v.*0 + 1;
y.u = y.v.*0 + 1;
%%
% Quantities are put into data input structure |DI|.
DI = [];
DI.x = x;
DI.y = y;
%%
% Create calculation settings |CS| and set uncertainty calculation method to Monte Carlo method.
% Allow randomization of uncertainties by the QWTB toolbox.
CS = [];
CS.unc = 'mcm';
CS.mcm.randomize = 1;

%% Call algorithm
% Use QWTB to apply algorithm |testM| to data |DI| with calculation settings |CS|.
DO = qwtb('testM', DI, CS);

%% Plot results
% Plot input data and calculated maximal and minimal values as a red and green lines with
% uncertainties represented by dashed lines.
figure  
hold on
errorbar(DI.x.v, DI.y.v, DI.y.u, 'xb')
plot([DI.x.v(1) DI.x.v(end)], [DO.max.v DO.max.v], '-r', 'linewidth', 3)
plot([DI.x.v(1) DI.x.v(end)], [DO.max.v - DO.max.u DO.max.v - DO.max.u], '--r', 'linewidth', 3)
plot([DI.x.v(1) DI.x.v(end)], [DO.min.v DO.min.v], '-g', 'linewidth', 3)
plot([DI.x.v(1) DI.x.v(end)], [DO.min.v - DO.min.u DO.min.v - DO.min.u], '--g', 'linewidth', 3)
plot([DI.x.v(1) DI.x.v(end)], [DO.max.v + DO.max.u DO.max.v + DO.max.u], '--r', 'linewidth', 3)
plot([DI.x.v(1) DI.x.v(end)], [DO.min.v + DO.min.u DO.min.v + DO.min.u], '--g', 'linewidth', 3)
legend('original data (DI.x.v, DI.y.v)', 'line at maximum value (DO.max.v)', 'uncertainty',  'line at minimum value (DO.min.v)', 'uncertainty', 'location', 'southoutside')
xlabel('quantity x')
ylabel('quantity y')
title('input data and results of testM algorithm')
hold off
%%
% Plot histogram of calculated maximal value, i.e. probability density function simulated by Monte
% Carlo method.
figure
hist(DO.max.r, 50)
title('histogram of Monte Carlo method results of maximum value (DO.max.r)')
