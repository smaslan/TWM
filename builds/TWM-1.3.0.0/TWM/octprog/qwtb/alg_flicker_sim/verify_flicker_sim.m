function [alltestspassed, T1maxerr, T2maxerr, T5maxerr]= verify_flicker_sim(IECedition, fs, verbose) 
% [ALLTESTSPASSED, T1MAXERR, T2MAXERR, T3MAXERR] = verify_flicker_sim(IECEDITION, FS)
% Verifies flicker calculations according to IEC61000-4-15.
% Simulates signals and calculates instantaneous flicker
% sensation P_inst,max and short-term flicker severity P_st
% and compares results to tables in the standard. Requires
% script sim_meas_and_calc.m and script flicker_sim.m.
% 
% Input variables:
% IECEDITION: Edition of the standard. Values and tests are
%   different for each edition:
%     1 - edition 1 (1997)
%     2 - edition 1 with change A1 (2003)
%     3 - edition 2 (2010)
% FS: sampling frequency of the simulated signal.
% 
% Output variables:
% ALLTESTSPASSED: If result is 1, all tests were correct
% T1MAXERR: Maximal error of all tests in table 1.
% T2MAXERR: Maximal error of all tests in table 2.
% T5MAXERR: Maximal error of all tests in table 5.
% 
% Examples: 
%
% alltestspassed=verify_flicker_sim(1,20e3)
% alltestspassed=verify_flicker_sim(2,20e3)
% alltestspassed=verify_flicker_sim(3,20e3)

% Author: Martin Šíra <msira@cmi.cz>
% Created: 2012-12-13
% Version: 1.3.0
% Keywords: flicker, IEC61000-4-15
% status: working, finished, checked.

% Copyright 2012 Martin Šíra
% 
% Permission is hereby granted, free of charge, to any person
% obtaining a copy of this software and associated
% documentation files (the "Software"), to deal in the
% Software without restriction, including without limitation
% the rights to use, copy, modify, merge, publish, distribute,
% sublicense, and/or sell copies of the Software, and to
% permit persons to whom the Software is furnished to do so,
% subject to the following conditions:
% 
% The above copyright notice and this permission notice shall
% be included in all copies or substantial portions of the
% Software.
% 
% THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY
% KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
% WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
% PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
% OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR
% OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
% OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
% SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

% check inputs %<<<1
       
        if (nargin < 2 || nargin > 3)
                error('Invalid number of arguments');
        end

        if ~(IECedition == 1 || IECedition == 2 || IECedition == 3)
                error('IECedition must only be numbers: 1 (ed. 1, 1997), 2 (ed. 1, change A1, 2003) or 3 (ed. 2, 2010)')
        end

        if ~isscalar(fs)
                error('Sampling frequency fs must be a scalar')
        end
        if (fs <= 0)
                error('Sampling frequency fs must be a nonzero positive number')
        end
        % set value of verbose:
        if (nargin < 3)
                verbose = 1;
        end


% starting parameter values: %<<<1
        % sampling frequency:
        par_common.f_s = fs;
        % length of the test signal:
        % (There has to be quite a long signal. Flickermeter
        % needs 600 seconds to calculate Pst. First 120 seconds
        % is used to charge filters of the flickermeter)
        par_common.siglen = 720;
        % string for current test edition:
        % in this script, IECedition 1 is edition 1 (1997), IECedition 2 is edition 1 with change A1 (2003), IECedition 3 is edition 2 (2010)
        if IECedition == 1
                editiontext = 'IEC 61000-4-15 ed. 1, 1997, ';
        elseif IECedition == 2
                editiontext = 'IEC 61000-4-15 ed. 1A1, 2003, ';
        elseif IECedition == 3
                editiontext = 'IEC 61000-4-15 ed. 2, 2010, ';
        else
                error('unknown IECedition value')
        end
        % cell with 0 / 1 values for tests:
        testresultstr{1}='FAILED!';
        testresultstr{2}='passed.';
        % test limits differs for diferent IEC editions:
        if ( IECedition == 1 || IECedition == 2 )
                table1and2limit=0.05;
        elseif IECedition == 3
                table1and2limit=0.08;
        end
        if verbose; disp(['table 1 and 2 pass/fail limits of results for ' editiontext 'are 1 +- ' num2str(table1and2limit)]); end
        % test limits for table 5 is the same for all IEC editions:
        table5limit=0.05;
        if verbose; disp(['table 5 pass/fail limits of results for ' editiontext 'are 1 +- ' num2str(table5limit)]); end

% IEC table 1 / 1a 1b  - sinusoidal modulation with sqrt(max(s))==(1 +- 0.05) %<<<1
        if verbose; fprintf(1,'IEC table 1 / 1a 1b: '); end
        par_common.typmodul = 0;

        % 230V, 50Hz - common for all IEC editions: %<<<2
        par_common.A_c = 230*2/2^0.5;
        par_common.f_c = 50;
        if (IECedition == 1)
                IECtable1R230f50sinCPM=60*2*[ [0.5:0.5:8.0] 8.8 [9.5:0.5:12] [13:1:25]];
                IECtable1R230f50sindVV=[2.340 1.432 1.080 0.882 0.754 0.654 0.568 0.5 0.446 0.398 0.360 0.328 0.3 0.280 0.266 0.256 0.250 0.254 0.260 0.270 0.282 0.296 0.312 0.348 0.388 0.432 0.480 0.530 0.584 0.640 0.7 0.76 0.824 0.890 0.962 1.042];
        elseif (IECedition == 2)
                IECtable1R230f50sinCPM=60*2*[ [0.5:0.5:8.0] 8.8 [9.5:0.5:12] [13:1:25] 33.33];
                IECtable1R230f50sindVV=[2.340 1.432 1.080 0.882 0.754 0.654 0.568 0.5 0.446 0.398 0.360 0.328 0.3 0.280 0.266 0.256 0.250 0.254 0.260 0.270 0.282 0.296 0.312 0.348 0.388 0.432 0.480 0.530 0.584 0.640 0.7 0.76 0.824 0.890 0.962 1.042 2.130];
        elseif (IECedition == 3)
                IECtable1R230f50sinCPM=60*2*[ [0.5:0.5:8.0] 8.8 [9.5:0.5:12] [13:1:25] 33+1/3];
                IECtable1R230f50sindVV=[2.325 1.397 1.067 0.879 0.747 0.645 0.564 0.497 0.442 0.396 0.357 0.325 0.3 0.280 0.265 0.256 0.250 0.254 0.261 0.271 0.283 0.298 0.314 0.351 0.393 0.438 0.486 0.537 0.590 0.646 0.704 0.764 0.828 0.894 0.964 1.037 2.128];
        end
        par_common.ind = 1;
        par_common.marker = 'IECtable1R230f50sin';
        [IECtable1R230f50sinres, IECtable1R230f50sinresPst, IECtable1R230f50sinresPinstmax]=calcres(par_common, IECtable1R230f50sinCPM, IECtable1R230f50sindVV, verbose);

        % 120V, 60Hz - common for editions 2 and 3: %<<<2
        if ( IECedition == 2 || IECedition == 3 )
                par_common.A_c = 120*2/2^0.5;
                par_common.f_c = 60;
                if (IECedition == 2)
                        IECtable1R120f60sinCPM=60*2*[ [0.5:0.5:8.0] 8.8 [9.5:0.5:12] [13:1:25] 40];
                        IECtable1R120f60sindVV=[2.457 1.463 1.124 0.940 0.814 0.716 0.636 0.569 0.514 0.465 0.426 0.393 0.366 0.346 0.332 0.323 0.321 0.330 0.339 0.355 0.374 0.394 0.420 0.470 0.530 0.593 0.662 0.737 0.815 0.897 0.981 1.071 1.164 1.262 1.365 1.472 4.424];
                elseif (IECedition == 3)
                        IECtable1R120f60sinCPM=60*2*[ [0.5:0.5:8.0] 8.8 [9.5:0.5:12] [13:1:25] 33+1/3 40];
                        IECtable1R120f60sindVV=[2.453 1.465 1.126 0.942 0.815 0.717 0.637 0.570 0.514 0.466 0.426 0.393 0.366 0.346 0.332 0.323 0.321 0.329 0.341 0.355 0.373 0.394 0.417 0.469 0.528 0.592 0.660 0.734 0.811 0.892 0.977 1.067 1.160 1.257 1.359 1.464 2.570 4.393];
                end
                par_common.ind = 2;
                par_common.marker = 'IECtable1R120f60sin';
                [IECtable1R120f60sinres, IECtable1R120f60sinresPst, IECtable1R120f60sinresPinstmax]=calcres(par_common, IECtable1R120f60sinCPM, IECtable1R120f60sindVV, verbose);
        end

        % 120V, 50Hz - only in edition 3: %<<<2
        if IECedition == 3
                par_common.A_c = 120*2/2^0.5;
                par_common.f_c = 50;
                IECtable1R120f50sinCPM=60*2*[ [0.5:0.5:8.0] 8.8 [9.5:0.5:12] [13:1:25] 33+1/3];
                IECtable1R120f50sindVV=[2.453 1.465 1.126 0.942 0.815 0.717 0.637 0.570 0.514 0.466 0.426 0.393 0.366 0.346 0.332 0.323 0.321 0.329 0.341 0.355 0.373 0.394 0.417 0.469 0.528 0.592 0.660 0.734 0.811 0.892 0.978 1.068 1.162 1.261 1.365 1.476 3.111];
                par_common.ind = 3;
                par_common.marker = 'IECtable1R120f50sin';
                [IECtable1R120f50sinres, IECtable1R120f50sinresPst, IECtable1R120f50sinresPinstmax]=calcres(par_common, IECtable1R120f50sinCPM, IECtable1R120f50sindVV, verbose);
        end

        % 230V, 60Hz - only in edition 3: %<<<2
        if IECedition == 3
                par_common.A_c = 230*2/2^0.5;
                par_common.f_c = 60;
                IECtable1R230f60sinCPM=60*2*[ [0.5:0.5:8.0] 8.8 [9.5:0.5:12] [13:1:25] 33+1/3 40];
                IECtable1R230f60sindVV=[2.325 1.397 1.067 0.879 0.747 0.645 0.564 0.497 0.442 0.396 0.357 0.325 0.3 0.280 0.265 0.256 0.250 0.254 0.261 0.271 0.283 0.298 0.314 0.351 0.393 0.438 0.486 0.537 0.590 0.645 0.703 0.764 0.826 0.892 0.959 1.029 1.758 2.963];
                par_common.ind = 4;
                par_common.marker = 'IECtable1R230f60sin';
                [IECtable1R230f60sinres, IECtable1R230f60sinresPst, IECtable1R230f60sinresPinstmax]=calcres(par_common, IECtable1R230f60sinCPM, IECtable1R230f60sindVV, verbose);
        end
        if verbose; fprintf(1,'\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b'); end

% test results for IEC table 1 / 1a 1b: %<<<1
        testtable1R230f50 = ~( ( max(IECtable1R230f50sinresPinstmax) > 1+table1and2limit ) || ( min(IECtable1R230f50sinresPinstmax) < 1-table1and2limit ) );
        if verbose; disp([ 'test ' editiontext 'table 1, 230 V RMS, 50 Hz: ' testresultstr{testtable1R230f50+1} ]); end
        if ( IECedition == 2 || IECedition == 3 )
                testtable1R120f60 = ~( ( max(IECtable1R120f60sinresPinstmax) > 1+table1and2limit ) || ( min(IECtable1R120f60sinresPinstmax) < 1-table1and2limit ) );
                if verbose; disp([ 'test ' editiontext 'table 1, 120 V RMS, 60 Hz: ' testresultstr{testtable1R120f60+1} ]); end
        end
        if IECedition == 3
                testtable1R120f50 = ~( ( max(IECtable1R120f50sinresPinstmax) > 1+table1and2limit ) || ( min(IECtable1R120f50sinresPinstmax) < 1-table1and2limit ) );
                testtable1R230f60 = ~( ( max(IECtable1R230f60sinresPinstmax) > 1+table1and2limit ) || ( min(IECtable1R230f60sinresPinstmax) < 1-table1and2limit ) );
                if verbose; disp([ 'test ' editiontext 'table 1, 120 V RMS, 50 Hz: ' testresultstr{testtable1R120f50+1} ]); end
                if verbose; disp([ 'test ' editiontext 'table 1, 230 V RMS, 60 Hz: ' testresultstr{testtable1R230f60+1} ]); end
        end

% plot results for IEC table 1 / 1a 1b: %<<<1
        if verbose
                figure
                xi=0; xm=41;
                plot([xi xm],[1-table1and2limit 1-table1and2limit],'r-')
                hold on
                plot([xi xm],[1+table1and2limit 1+table1and2limit],'r-')
                plot([xi xm],[1 1],'k-')
                plot(IECtable1R230f50sinCPM/120,IECtable1R230f50sinresPinstmax, 'b-*');
                if ( IECedition == 2 || IECedition == 3 )
                        plot(IECtable1R120f60sinCPM/120,IECtable1R120f60sinresPinstmax, 'g-*');
                end
                if IECedition == 3
                        plot(IECtable1R120f50sinCPM/120,IECtable1R120f50sinresPinstmax, 'm-*');
                        plot(IECtable1R230f60sinCPM/120,IECtable1R230f60sinresPinstmax, 'c-*');
                end

                hold off
                if IECedition == 1
                        title([ editiontext 'table 1, sinusoidal modulation'])
                        legend('upper limit to pass test', 'lower limit to pass test', 'line y=1', '230 V RMS, 50 Hz')
                        fixedaxis = testtable1R230f50;
                elseif IECedition == 2
                        title([ editiontext 'table 1, sinusoidal modulation'])
                        legend('upper limit to pass test', 'lower limit to pass test', 'line y=1', '230 V RMS, 50 Hz', '120 V RMS, 60 Hz')
                        fixedaxis = testtable1R230f50 & testtable1R120f60;
                elseif IECedition == 3
                        title([ editiontext 'tables 1a and 1b, sinusoidal modulation'])
                        legend('upper limit to pass test', 'lower limit to pass test', 'line y=1', '230 V RMS, 50 Hz', '120 V RMS, 60 Hz', '120 V RMS, 50 Hz', '230 V RMS, 60 Hz')
                        fixedaxis = testtable1R230f50 & testtable1R120f60 & testtable1R120f50 & testtable1R230f60;
                end
                xlabel('Modulation frequency (Hz)')
                ylabel('Maximum of instanteous flicker sensation P_{inst,max}')
                if fixedaxis
                        axis([xi, xm, 1-2*table1and2limit, 1+2*table1and2limit])
                else
                        axis('auto');
                end
        end % verbose

% max error of results for IEC table 1 / 1a 1b: %<<<1
        T1maxerr = max(abs(1-IECtable1R230f50sinresPinstmax));
        if ( IECedition == 2 || IECedition == 3 )
                T1maxerr = max([T1maxerr abs(1-IECtable1R120f60sinresPinstmax)]);
        end
        if IECedition == 3
                T1maxerr = max([T1maxerr abs(1-IECtable1R120f50sinresPinstmax)]);
                T1maxerr = max([T1maxerr abs(1-IECtable1R230f60sinresPinstmax)]);
        end

% IEC table 2 / 2a 2b - rectangular modulation with sqrt(max(s))==(1 +- 0.05): %<<<1
        if verbose; fprintf(1,'IEC table 2 / 2a 2b: '); end
        par_common.typmodul = 1;

        % 230V, 50Hz - common for all IEC editions: %<<<2
        par_common.A_c = 230*2/2^0.5;
        par_common.f_c = 50;
        if (IECedition == 1)
                IECtable2R230f50recCPM=60*2*[ [0.5:0.5:8.0] 8.8 [9.5:0.5:12] [13:1:24]];
                IECtable2R230f50recdVV=[0.514 0.471 0.432 0.401 0.374 0.355 0.345 0.333 0.316 0.293 0.269 0.249 0.231 0.217 0.207 0.201 0.199 0.2 0.205 0.213 0.223 0.234 0.246 0.275 0.308 0.344 0.376 0.413 0.452 0.498 0.546 0.586 0.604 0.680 0.743];
        elseif (IECedition == 2)
                IECtable2R230f50recCPM=60*2*[ [0.5:0.5:8.0] 8.8 [9.5:0.5:12] [13:1:24] 33.33];
                IECtable2R230f50recdVV=[0.514 0.471 0.432 0.401 0.374 0.355 0.345 0.333 0.316 0.293 0.269 0.249 0.231 0.217 0.207 0.201 0.199 0.2 0.205 0.213 0.223 0.234 0.246 0.275 0.308 0.344 0.376 0.413 0.452 0.498 0.546 0.586 0.604 0.680 0.743 1.67];
        elseif (IECedition == 3)
                IECtable2R230f50recCPM=60*2*[ [0.5:0.5:8.0] 8.8 [9.5:0.5:12] [13:1:21] 21.5 [22:1:25] 25.5 28 30.5 33+1/3];
                IECtable2R230f50recdVV=[0.509 0.467 0.429 0.398 0.370 0.352 0.342 0.332 0.312 0.291 0.268 0.248 0.231 0.216 0.207 0.199 0.196 0.199 0.203 0.212 0.222 0.233 0.245 0.272 0.308 0.341 0.376 0.411 0.446 0.497 0.553 0.585 0.592 0.612 0.680 0.743 0.764 0.806 0.915 0.847 1.671];
        end
        par_common.ind = 5;
        par_common.marker = 'IECtable2R230f50rec';
        [IECtable2R230f50recres, IECtable2R230f50recresPst, IECtable2R230f50recresPinstmax]=calcres(par_common, IECtable2R230f50recCPM, IECtable2R230f50recdVV, verbose);

        % 120V, 60Hz - common for editions 2 and 3: %<<<2
        if ( IECedition == 2 || IECedition == 3 )
                par_common.A_c = 120*2/2^0.5;
                par_common.f_c = 60;
                if (IECedition == 2)
                        IECtable2R120f60recCPM=60*2*[ [0.5:0.5:8.0] 8.8 [9.5:0.5:12] [13:1:24] 40];
                        IECtable2R120f60recdVV=[0.600 0.547 0.504 0.471 0.439 0.421 0.407 0.394 0.371 0.349 0.323 0.302 0.282 0.269 0.258 0.255 0.253 0.257 0.264 0.280 0.297 0.309 0.323 0.369 0.411 0.459 0.513 0.580 0.632 0.692 0.752 0.818 0.853 0.946 1.072 3.46];
                elseif (IECedition == 3)
                        IECtable2R120f60recCPM=60*2*[ [0.5:0.5:8.0] 8.8 [9.5:0.5:12] [13:1:21] 21.5 [22:1:25] 25.5 28 30.5 33+1/3 37 40];
                        IECtable2R120f60recdVV=[0.598 0.548 0.503 0.469 0.439 0.419 0.408 0.394 0.373 0.348 0.324 0.302 0.283 0.269 0.258 0.253 0.252 0.258 0.266 0.278 0.292 0.308 0.324 0.367 0.411 0.457 0.509 0.575 0.626 0.688 0.746 0.815 0.837 0.851 0.946 1.067 1.088 1.072 1.383 1.602 1.823 1.304 3.451];
                end
                par_common.ind = 6;
                par_common.marker = 'IECtable2R120f60rec';
                [IECtable2R120f60recres, IECtable2R120f60recresPst, IECtable2R120f60recresPinstmax]=calcres(par_common, IECtable2R120f60recCPM, IECtable2R120f60recdVV, verbose);
        end

        % 120V, 50Hz - only in edition 3: %<<<2
        if IECedition == 3
                par_common.A_c = 120*2/2^0.5;
                par_common.f_c = 50;
                IECtable2R120f50recCPM=60*2*[ [0.5:0.5:8.0] 8.8 [9.5:0.5:12] [13:1:21] 21.5 [22:1:25] 25.5 28 30.5 33+1/3];
                IECtable2R120f50recdVV=[0.597 0.547 0.503 0.468 0.438 0.420 0.408 0.394 0.372 0.348 0.323 0.302 0.283 0.269 0.259 0.253 0.252 0.258 0.265 0.278 0.293 0.308 0.325 0.363 0.413 0.460 0.511 0.562 0.611 0.683 0.768 0.811 0.820 0.852 0.957 1.052 1.087 1.148 1.303 1.144 2.443];
                par_common.ind = 7;
                par_common.marker = 'IECtable2R120f50rec';
                [IECtable2R120f50recres, IECtable2R120f50recresPst, IECtable2R120f50recresPinstmax]=calcres(par_common, IECtable2R120f50recCPM, IECtable2R120f50recdVV, verbose);
        end

        % 230V, 60Hz - only in edition 3: %<<<2
        if IECedition == 3
                par_common.A_c = 230*2/2^0.5;
                par_common.f_c = 60;
                IECtable2R230f60recCPM=60*2*[ [0.5:0.5:8.0] 8.8 [9.5:0.5:12] [13:1:21] 21.5 [22:1:25] 25.5 28 30.5 33+1/3 37 40];
                IECtable2R230f60recdVV=[0.510 0.468 0.429 0.399 0.371 0.351 0.342 0.331 0.313 0.291 0.269 0.249 0.231 0.217 0.206 0.200 0.196 0.199 0.203 0.212 0.222 0.233 0.244 0.275 0.306 0.338 0.376 0.420 0.457 0.498 0.537 0.584 0.600 0.611 0.678 0.753 0.778 0.768 0.962 1.105 1.258 0.975 2.327];
                par_common.ind = 8;
                par_common.marker = 'IECtable2R230f60rec';
                [IECtable2R230f60recres, IECtable2R230f60recresPst, IECtable2R230f60recresPinstmax]=calcres(par_common, IECtable2R230f60recCPM, IECtable2R230f60recdVV, verbose);
        end
        if verbose; fprintf(1,'\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b'); end

% test results for IEC table 2 / 2a 2b: %<<<1
        testtable2R230f50 = ~( ( max(IECtable2R230f50recresPinstmax) > 1+table1and2limit ) || ( min(IECtable2R230f50recresPinstmax) < 1-table1and2limit ) );
        if verbose; disp([ 'test ' editiontext 'table 2, 230 V RMS, 50 Hz: ' testresultstr{testtable2R230f50+1} ]); end
        if ( IECedition == 2 || IECedition == 3 )
                testtable2R120f60 = ~( ( max(IECtable2R120f60recresPinstmax) > 1+table1and2limit ) || ( min(IECtable2R120f60recresPinstmax) < 1-table1and2limit ) );
                if verbose; disp([ 'test ' editiontext 'table 2, 120 V RMS, 60 Hz: ' testresultstr{testtable2R120f60+1} ]); end
        end
        if IECedition == 3
                testtable2R120f50 = ~( ( max(IECtable2R120f50recresPinstmax) > 1+table1and2limit ) || ( min(IECtable2R120f50recresPinstmax) < 1-table1and2limit ) );
                testtable2R230f60 = ~( ( max(IECtable2R230f60recresPinstmax) > 1+table1and2limit ) || ( min(IECtable2R230f60recresPinstmax) < 1-table1and2limit ) );
                if verbose; disp([ 'test ' editiontext 'table 2, 120 V RMS, 50 Hz: ' testresultstr{testtable2R120f50+1} ]); end
                if verbose; disp([ 'test ' editiontext 'table 2, 230 V RMS, 60 Hz: ' testresultstr{testtable2R230f60+1} ]); end
        end

% plot results for IEC table 2 / 2a 2b: %<<<1
        if verbose
                figure
                xi=0; xm=41;
                plot([xi xm],[1-table1and2limit 1-table1and2limit],'r-')
                hold on
                plot([xi xm],[1+table1and2limit 1+table1and2limit],'r-')
                plot([xi xm],[1 1],'k-')
                plot(IECtable2R230f50recCPM/120,IECtable2R230f50recresPinstmax, 'b-*');
                if ( IECedition == 2 || IECedition == 3 )
                        plot(IECtable2R120f60recCPM/120,IECtable2R120f60recresPinstmax, 'g-*');
                end
                if IECedition == 3
                        plot(IECtable2R120f50recCPM/120,IECtable2R120f50recresPinstmax, 'm-*');
                        plot(IECtable2R230f60recCPM/120,IECtable2R230f60recresPinstmax, 'c-*');
                end

                hold off
                if IECedition == 1
                        title([ editiontext 'table 2, rectangular modulation'])
                        legend('upper limit to pass test', 'lower limit to pass test', 'line y=1', '230 V RMS, 50 Hz')
                        fixedaxis = testtable2R230f50;
                elseif IECedition == 2
                        title([ editiontext 'table 2, rectangular modulation'])
                        legend('upper limit to pass test', 'lower limit to pass test', 'line y=1', '230 V RMS, 50 Hz', '120 V RMS, 60 Hz')
                        fixedaxis = testtable2R230f50 & testtable2R120f60;
                elseif IECedition == 3
                        title([ editiontext 'tables 2a and 2b, rectangular modulation'])
                        legend('upper limit to pass test', 'lower limit to pass test', 'line y=1', '230 V RMS, 50 Hz', '120 V RMS, 60 Hz', '120 V RMS, 50 Hz', '230 V RMS, 60 Hz')
                        fixedaxis = testtable2R230f50 & testtable2R120f60 & testtable2R120f50 & testtable2R230f60;
                end
                xlabel('Modulation frequency (Hz)')
                ylabel('Maximum of instanteous flicker sensation P_{inst,max}')
                if fixedaxis
                        axis([xi, xm, 1-2*table1and2limit, 1+2*table1and2limit])
                else
                        axis('auto');
                end
        end % verbose

% max error of results for IEC table 2 / 2a 2b: %<<<1
        T2maxerr = max(abs(1-IECtable2R230f50recresPinstmax));
        if ( IECedition == 2 || IECedition == 3 )
                T2maxerr = max([T2maxerr abs(1-IECtable2R120f60recresPinstmax)]);
        end
        if IECedition == 3
                T2maxerr = max([T2maxerr abs(1-IECtable2R120f50recresPinstmax)]);
                T2maxerr = max([T2maxerr abs(1-IECtable2R230f60recresPinstmax)]);
        end

% IEC table 5: %<<<1
        if verbose; fprintf(1,'IEC table 5: '); end
        par_common.typmodul = 1;
        % 230V, 50Hz - common for all IEC editions: %<<<2
        par_common.A_c = 230*2/2^0.5;
        par_common.f_c = 50;
        if (IECedition == 1)
                IECtable5R230f50recCPM=[1 2 7 39 110 1620];
                IECtable5R230f50recdVV=[2.72 2.21 1.46 0.905 0.725 0.402];
        elseif (IECedition == 2)
                IECtable5R230f50recCPM=[1 2 7 39 110 1620 4000];
                IECtable5R230f50recdVV=[2.724 2.211 1.459 0.906 0.725 0.402 2.40];
        elseif (IECedition == 3)
                IECtable5R230f50recCPM=[1 2 7 39 110 1620 4000];
                IECtable5R230f50recdVV=[2.715 2.191 1.450 0.894 0.722 0.407 2.343];
        end
        par_common.ind = 9;
        par_common.marker = 'IECtable5R230f50rec';
        [IECtable5R230f50recres, IECtable5R230f50recresPst, IECtable5R230f50recresPinstmax]=calcres(par_common, IECtable5R230f50recCPM, IECtable5R230f50recdVV, verbose);

        % 120V, 60Hz - common for editions 2 and 3: %<<<2
        if ( IECedition == 2 || IECedition == 3 )
                par_common.A_c = 120*2/2^0.5;
                par_common.f_c = 60;
                if (IECedition == 2)
                        IECtable5R120f60recCPM=[1 2 7 39 110 1620 4800];
                        IECtable5R120f60recdVV=[3.166 2.568 1.695 1.044 0.841 0.547 4.834];
                elseif (IECedition == 3)
                        IECtable5R120f60recCPM=[1 2 7 39 110 1620 4800];
                        IECtable5R120f60recdVV=[3.181 2.564 1.694 1.040 0.844 0.548 4.837];
                end
                par_common.ind = 10;
                par_common.marker = 'IECtable5R120f60rec';
                [IECtable5R120f60recres, IECtable5R120f60recresPst, IECtable5R120f60recresPinstmax]=calcres(par_common, IECtable5R120f60recCPM, IECtable5R120f60recdVV, verbose);
        end

        % 120V, 50Hz - only in edition 3: %<<<2
        if IECedition == 3
                par_common.A_c = 120*2/2^0.5;
                par_common.f_c = 50;
                IECtable5R120f50recCPM=[1 2 7 39 110 1620 4000];
                IECtable5R120f50recdVV=[3.178 2.561 1.694 1.045 0.844 0.545 3.426];
                par_common.ind = 11;
                par_common.marker = 'IECtable5R120f50rec';
                [IECtable5R120f50recres, IECtable5R120f50recresPst, IECtable5R120f50recresPinstmax]=calcres(par_common, IECtable5R120f50recCPM, IECtable5R120f50recdVV, verbose);
        end

        % 230V, 60Hz - only in edition 3: %<<<2
        if IECedition == 3
                par_common.A_c = 230*2/2^0.5;
                par_common.f_c = 60;
                IECtable5R230f60recCPM=[1 2 7 39 110 1620 4800];
                IECtable5R230f60recdVV=[2.719 2.194 1.450 0.895 0.723 0.409 3.263];
                par_common.ind = 12;
                par_common.marker = 'IECtable5R230f60rec';
                [IECtable5R230f60recres, IECtable5R230f60recresPst, IECtable5R230f60recresPinstmax]=calcres(par_common, IECtable5R230f60recCPM, IECtable5R230f60recdVV, verbose);
        end
        if verbose; fprintf(1,'\b\b\b\b\b\b\b\b\b\b\b\b\b'); end

% test results for IEC table 5: %<<<1
        testtable5R230f50 = ~( ( max(IECtable5R230f50recresPst) > 1+table5limit ) || ( min(IECtable5R230f50recresPst) < 1-table5limit ) );
        if verbose; disp([ 'test ' editiontext 'table 5, 230 V RMS, 50 Hz: ' testresultstr{testtable5R230f50+1} ]); end
        if ( IECedition == 2 || IECedition == 3 )
                testtable5R120f60 = ~( ( max(IECtable5R120f60recresPst) > 1+table5limit ) || ( min(IECtable5R120f60recresPst) < 1-table5limit ) );
                if verbose; disp([ 'test ' editiontext 'table 5, 120 V RMS, 60 Hz: ' testresultstr{testtable5R120f60+1} ]); end
        end
        if IECedition == 3
                testtable5R120f50 = ~( ( max(IECtable5R120f50recresPst) > 1+table5limit ) || ( min(IECtable5R120f50recresPst) < 1-table5limit ) );
                testtable5R230f60 = ~( ( max(IECtable5R230f60recresPst) > 1+table5limit ) || ( min(IECtable5R230f60recresPst) < 1-table5limit ) );
                if verbose; disp([ 'test ' editiontext 'table 5, 120 V RMS, 50 Hz: ' testresultstr{testtable5R120f50+1} ]); end
                if verbose; disp([ 'test ' editiontext 'table 5, 230 V RMS, 60 Hz: ' testresultstr{testtable5R230f60+1} ]); end
        end

% plot results for IEC table 5: %<<<1
        if verbose
                figure
                xi=0.7; xm=8000;
                semilogx([xi xm],[1-table5limit 1-table5limit],'r-')
                hold on         % hold on must be after (not before) semilogx otherwise Matlab change semilogx to normal plot
                semilogx([xi xm],[1+table5limit 1+table5limit],'r-')
                semilogx([xi xm],[1 1],'k-')
                semilogx(IECtable5R230f50recCPM,IECtable5R230f50recresPst, 'b-*');
                if ( IECedition == 2 || IECedition == 3 )
                        semilogx(IECtable5R120f60recCPM,IECtable5R120f60recresPst, 'g-*');
                end
                if IECedition == 3
                        semilogx(IECtable5R120f50recCPM,IECtable5R120f50recresPst, 'm-*');
                        semilogx(IECtable5R230f60recCPM,IECtable5R230f60recresPst, 'c-*');
                end

                hold off
                title([ editiontext 'table 5, rectangular modulation'])
                if IECedition == 1
                        legend('upper limit to pass test', 'lower limit to pass test', 'line y=1', '230 V RMS, 50 Hz')
                        fixedaxis = testtable5R230f50;
                elseif IECedition == 2
                        legend('upper limit to pass test', 'lower limit to pass test', 'line y=1', '230 V RMS, 50 Hz', '120 V RMS, 60 Hz')
                        fixedaxis = testtable5R230f50 & testtable5R120f60;
                elseif IECedition == 3
                        legend('upper limit to pass test', 'lower limit to pass test', 'line y=1', '230 V RMS, 50 Hz', '120 V RMS, 60 Hz', '120 V RMS, 50 Hz', '230 V RMS, 60 Hz')
                        fixedaxis = testtable5R230f50 & testtable5R120f60 & testtable5R120f50 & testtable5R230f60;
                end
                xlabel('Changes per minute (1/min)')
                ylabel('Short-term flicker severity P_{st}')
                if fixedaxis
                        axis([xi, xm, 1-2*table5limit, 1+2*table5limit])
                else
                        axis('auto');
                end
        end % verbose

% max error of results for IEC table 5: %<<<1
        T5maxerr = max(abs(1-IECtable5R230f50recresPst));
        if ( IECedition == 2 || IECedition == 3 )
                T5maxerr = max([T5maxerr abs(1-IECtable5R120f60recresPst)]);
        end
        if IECedition == 3
                T5maxerr = max([T5maxerr abs(1-IECtable5R120f50recresPst)]);
                T5maxerr = max([T5maxerr abs(1-IECtable5R230f60recresPst)]);
        end


% return fail/pass result %<<<1

        if IECedition == 1
                alltestspassed = testtable1R230f50 & testtable2R230f50 & testtable5R230f50;
        end
        if IECedition == 2
                alltestspassed = testtable1R230f50 & testtable1R120f60 & testtable2R230f50 & testtable2R120f60 & testtable5R230f50 & testtable5R120f60;
        end
        if IECedition == 3
                alltestspassed = testtable1R230f50 & testtable1R120f60 & testtable1R120f50 & testtable1R230f60 & testtable2R230f50 & testtable2R120f60 & testtable2R120f50 & testtable2R230f60 & testtable5R230f50 & testtable5R120f60 & testtable5R120f50 & testtable5R230f60;
        end

% calcres - subfunction to calculate through a set of table values %<<<1

function [res, P_st, P_instmax]=calcres(par_common, CPM, dVV, verbose)

        res=[];      % results
        P_st=[];   % result Pst
        P_instmax=[];   % result max(Pinst)

        % calculate pst:
        if verbose; fprintf(1, '%03d V, %02d Hz: ', round(par_common.A_c./sqrt(2)), round(par_common.f_c)); end
        for i = 1:length(CPM)
                if verbose; fprintf(1,'%02d/%02d', i, length(CPM)); end
                par=par_common;
                par.ind=i;
                par.CPM=CPM(i);
                par.dVV=dVV(i);
                par.verbose=0;
                % here you can add noise:
                par.noise = 0;
                % calculate pst:
                oneres=sim_meas_and_calc(par);
                res=[ res oneres ];
                P_st=[ P_st oneres.P_st ];
                % Although Tubitak put here sqrt(max(Pinst)), 
                % according standard there should be only simple max():
                P_instmax=[ P_instmax max(oneres.P_inst) ];
                if verbose; fprintf(1,'\b\b\b\b\b'); end
        end
        if verbose; fprintf(1, '\b\b\b\b\b\b\b\b\b\b\b\b\b\b'); end

% vim settings line: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
