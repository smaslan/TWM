%% Allan Deviation
% Example for algorithm ADEV.
%
% ADEV is an algorithm to compute the Allan deviation for a set of time-domain frequency data.
%
% See also W. J. Riley, "The Calculation of Time Domain Frequency Stability". Implementation: M. A. Hopcroft, mhopeng@gmail.com, Matlab Central.'

%% Generate sample data
% A random numbers with normal probability distribution function will be generated into input data |DI.y.v|. Next a drift will be added.
DI = [];
DI.y.v = 1.5 + 3.*randn(1, 1e3);
DI.y.v = DI.y.v + [1:1:1e3]./100;
%%
% Lets suppose a sampling frequency is 1 Hz. The algorithm will generate all possible tau values automatically.
DI.fs.v = 1;

%% Call algorithm
% Use QWTB to apply algorithm |ADEV| to data |DI|.
DO = qwtb('ADEV', DI);

%% Display results
% Log log figure is the best to see allan deviation results:
figure; hold on
loglog(DO.tau.v, DO.adev.v, '-b')
loglog(DO.tau.v, DO.adev.v + DO.adev.u, '-k')
loglog(DO.tau.v, DO.adev.v - DO.adev.u, '-k')
xlabel('\tau (sec)');
ylabel('\sigma_y(\tau)');
title(['period = ' num2str(1/DI.fs.v)]);
grid('on'); hold off
