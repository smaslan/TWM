function res=sim_meas_and_calc(par)
% RES = sim_meas_and_calc(PAR)
% Generate voltage time series with flickers of 50% duty and
% calls script flicker_sim.m to calculate results. Modulation 
% is set in such a way the phase of modulation is zero at 
% time 10 minutes before end of time series.
% 
% Input variable:
% PAR: Structure with following fields:
%   .ind: General index, useful for parallel computing.
%   .marker: Marker of the data set, useful for parallel computing.
%   .verbose: Verbosity of the script and called scripts.
%   .dVV: Relative voltage change (V/V), carrier amplitude
%     oscillates between two values, their difference is equal to
%     voltage change.
%   .CPM: Changes per minute,  changes per minute = modulation
%     frequency * 60 * 2.
%   .typmodul: Type of modulation (0: sinusoidal, 1: rectangular).
%   .A_c: Amplitude of the carrier signal (V).
%   .f_c: Frequency of the carrier signal (Hz).
%   .siglen: Measurement time (length of signal) (s) (should be 
%     longer than 10 minutes).
%   .f_s: Sampling frequency (Hz).
%   .noise: a normal dist. noise will be added to the signal with
%     sigma equal to value of this parameter
% 
% Output variable:
% RES: Structure with all fields as input variable par and two
%   additional:
%     res.P_st: Short-term flicker severity.
%     res.P_inst: Instantaneous flicker sensation.
% 
% Example:
% Settings for Table 5 of EN61000-4-15/A1, line 4, collumn 3.
% Resulted P_st should be very near 1:
%
% par.ind = 1; par.marker = "test"; par.verbose=1; par.dVV = 0.894;
% par.CPM = 39; par.typmodul = 1; par.A_c = 230.*sqrt(2);
% par.f_c = 50; par.siglen = 720; par.f_s = 20000; par.noise = 0;
% res=sim_meas_and_calc(par); res.P_st

% Author: Martin Šíra <msira@cmi.cz>
% Created: 2012-12-13
% Version: 1.3.0
% Keywords: flicker IEC61000-4-15
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

        if (nargin ~= 1)
          error('Invalid number of arguments');
        end

        if (~isstruct(par))
          error('Input argument must be a structure');
        end

        if ~(isfield(par, 'ind'))
                error('Field `ind` is missing in input structure!')
        end
        if ~(isfield(par, 'marker'))
                error('Field `marker` is missing in input structure!')
        end
        if ~(isfield(par, 'dVV'))
                error('Field `dVV` is missing in input structure!')
        end
        if ~(isfield(par, 'verbose'))
                error('Field `verbose` is missing in input structure!')
        end
        if ~(isfield(par, 'CPM'))
                error('Field `CPM` is missing in input structure!')
        end
        if ~(isfield(par, 'typmodul'))
                error('Field `typmodul` is missing in input structure!')
        end
        if ~(isfield(par, 'A_c'))
                error('Field `A_c` is missing in input structure!')
        end
        if ~(isfield(par, 'f_c'))
                error('Field `f_c` is missing in input structure!')
        end
        if ~(isfield(par, 'siglen'))
                error('Field `siglen` is missing in input structure!')
        end
        if ~(isfield(par, 'f_s'))
                error('Field `f_s` is missing in input structure!')
        end
        if ~(isfield(par, 'noise'))
                error('Field `noise` is missing in input structure!')
        end

% generate voltage signal %<<<1

        % frequency of the modulation (flicker) signal:
        f_F = par.CPM / ( 60 * 2 );
        % time vector:
        y = linspace(0,par.siglen,par.siglen.*par.f_s);
        % According Note 2 in Table 5 in IEC standard the signal should
        % be synchronized in such a way that at in the first 5 seconds of
        % last 10 minutes of the signal the phase of the modulation
        % (phase of flicker, not line) should be 0.
        % so the phase/2pi of the signal at beginning of the time axis is:
        modphase = (par.siglen - 10).*f_F;
        % flicker signal (in such way the modulation at time of beginning of last 10
        % minutes is going up):
        if ( par.typmodul == 0 )
                % sine:
                y = par.A_c*sin(2*pi*par.f_c*y) .* ( 1 + (par.dVV/100)/2*sin(2*pi*f_F*y - modphase.*2.*pi) );
                if par.noise > 0
                        y = y + normrnd(0, par.noise, size(y));
                end
        elseif ( par.typmodul == 1 )
                % rectangle:
                y = par.A_c*sin(2*pi*par.f_c*y) .* ( 1 + (par.dVV/100)/2*sign(sin(2*pi*f_F*y - modphase.*2.*pi)) );
                if par.noise > 0
                        y = y + normrnd(0, par.noise, size(y));
                end
        end

% calculate results %<<<1

        res = par;
        [res.P_st, res.P_inst]=flicker_sim(y,par.f_s,par.f_c, par.verbose);

        % to save results to disk, uncomment following line:
        %% save([res.marker num2str(res.ind, '%010d')],'res');

end
% vim settings line: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave
