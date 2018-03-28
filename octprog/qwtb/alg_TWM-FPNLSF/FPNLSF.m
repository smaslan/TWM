function [A, f, ph, O] = FPNLSF(t, y, estf, verbose);
% Fits a sine wave to the recorded data by means of non-linear least squares using four
% parameter model. Requires good estimate of frequency. Different functions are
% used when run in MATLAB or GNU Octave.
% t - time series
% y - samples series
% estf - estimate of frequency
% A - calculated amplitude
% f - calculated frequency
% ph - calculated phase
% O - calculated offset

isOctave = (exist('OCTAVE_VERSION') ~= 0);

% ensure same row/column vectors
t = t(:);
y = y(:);

% estimates:
estA = max(y) - (max(y)+min(y))/2;
% 2DO not really good estimate (however zero estimate is not really good one
% because of minimization method):
estph = 1;
estO = mean(y);

% estimates vector:
est=[estA estf estph estO];

if isOctave
    % fitting:
    % model function: A*sin(2*Pi*f*t+phase):
    fun = inline(' pin(1).*sin( 2.*pi.*pin(2).*t + pin(3) ) + pin(4) ', 't', 'pin');

    stol = .00001;
    niter = 100;
    % leasqr in Octave based on Bard, Nonlinear Parameter Estimation, Academic Press, 1974.
    % Draper and Smith, Applied Regression Analysis, John Wiley and Sons, 1981.
    if verbose
        disp('Fitting started')
    end
    % run fit:
    [fcomp,p,kvg,iter,corp,covp,covr,stdresid,Z,r2] = leasqr(t, y, est, fun, stol, niter);
    if verbose
        disp('Fitting finished')
    end

    if ( kvg == 0 )
        if verbose
            disp('Convergence not achieved!')
        end
        p = -inf.*[1 1 1 1];
    end
    % % control plot:
    % plot(t, y, 'x', t, fun(t, p));

else % matlab code
    % check existence of required toolbox:
    if exist('lsqnonlin') ~= 2
        error('>>>>>>>>>>>>> FPNLSF: your Matlab is missing optimization toolbox! <<<<<<<<<<<<<<');
    end

    fun = @(p) (p(1).*sin(2.*pi.*p(2).*t + p(3)) + p(4)) - y;
    if verbose
        options = [];
        disp('Fitting started')
    else
        options.Display = 'off';
    end
    p = lsqnonlin(fun, est, [], [], options);
    if verbose
        disp('Fitting finished')
    end

end %if isOctave

A = p(1);
f = p(2);
ph = p(3);
O = p(4);

% problem of negative amplitude - sometimes fitting can result in negative amplitude, than a change
% of sign is required and phase shift is needed:
if ( A < 0 )
    % invert amplitude
    A = -1.*A;
    % and invert phase
    ph = ph + pi;
end

% ensure phase is in good limits:
ph = mod(ph, 2*pi);

end

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
