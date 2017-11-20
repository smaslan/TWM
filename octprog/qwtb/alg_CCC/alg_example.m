close all
%% Calibrations Curve Computing
% Example for algorithm CCC.
%
% Calibration Curves Computing is a software for the evaluation of instrument calibration curves

%% Generate sample data
% An dependence of amplitude error (Volts, ppm) on signal frequency (Hz) of an ADC was measured and
% uncertainties of measurement was estimated. The uncertainty of frequency can be considered as
% negligible.
%3.7+12.*x+3.*x.^2
f = [10 1e2 1e3 1e4 1e5];
err = [19.700 32.700 69.700 90.700 148.700];
err_unc = [4 10 13 20 33];
%%
% Set independent and dependent variables for |CCC| algorithm. Lets operate in semi logarithm space
% for easy plotting.
DI = [];
DI.x.v = log10(f);
DI.x.u = [];
DI.y.v = err;
DI.y.u = err_unc;
%%
% Suppose the ADC has quadratic dependence of the error on the signal frequency.
DI.exponents.v = [0 1 2];

%% Call algorithm
% Use QWTB to apply algorithm |CCC| to data |DI|.
DO = qwtb('CCC', DI);

%% Display results
% Results is 
disp(['offset          : ' num2str(DO.coefs.v(1)) ' +- ' num2str(DO.coefs.u(1))])
disp(['linear coeff.   : ' num2str(DO.coefs.v(2)) ' +- ' num2str(DO.coefs.u(2))])
disp(['quadratic coeff.: ' num2str(DO.coefs.v(3)) ' +- ' num2str(DO.coefs.u(3))])

%% Interpolate values
% Interpolate fitted polynom at values |t|.
t = [0:0.1:6];
ty = DO.func.v(t, DO.coefs.v);
%%
% Calculate uncertainties of interpolated values (|S| is sensitivity matrix, |CC| is covariance
% matrix of coefficients, |CT| is covariance matrix of interpolated values, |uty| is uncertainty of
% interpolated values).
for i = 1:length(t);
        S = t(i).^DI.exponents.v;
        CC = diag(DO.coefs.u,0)*DO.coefs.c*diag(DO.coefs.u,0);
        CT(i)=S*CC*S';
end
uty=CT.^0.5;

%% Plot results
hold on
errorbar(DI.x.v, DI.y.v, DI.y.u, 'xb')
errorbar(DI.x.v, DO.yhat.v, DO.yhat.u, 'og')
plot(t, ty, '-r');
plot(t, ty + uty, '-r');
plot(t, ty - uty, '-r');
xlabel('log(f)')
ylabel('error of amplitude')
legend('original data','fitted values','interpolated values', 'uncer. of int. val.','location','southeast')
hold off
