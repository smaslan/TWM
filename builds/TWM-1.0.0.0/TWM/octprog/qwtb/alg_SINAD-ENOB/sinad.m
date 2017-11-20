function [SINAD, ENOB] = sinad(t, y, f, A, ph, O, NoB, FSR)
%% Function calculates effective number of bits and ratio of signal to noise and
% distortion according IEEE Std 1241-2000
% Inputs:
% t - time series
% y - samples
% f, A, ph, O - frequency, amplitude, phase and offset of the applied signal. If
% these values are estimated by four parameter sine wave fit, it is done
% according IEEE Std 1241-2000.
% NoB - bit resolution of an ADC
% FSR - full scale range (i.e. ADC with FSR 2 V can sample signal from -1 V to 1 V)
%
% According IEEE Std 1241-2000, page 52, top:
% To estimate SINAD, apply a sine wave of specified frequency and amplitude to the ADC input.
% A large signal is preferred. The frequency of the input sine wave is called the fundamental frequency.
% Almost any error source in the sine wave input other than gain accuracy and dc offset can affect
% the test result. So, it is recommended that a sine wave source of good short-term stability be
% used and that the sine wave input be highly filtered to remove distortion and random noise from
% the input signal.

% generate signal waveform without noise:
wvfrm = A.*sin(2.*pi.*f.*t + ph) + O;

% get rms noise:
% IEEE Std 1241-2000, page 52, eq. 93:
residuals = y - wvfrm;
rms_noise = sqrt( 1/length(residuals) .* sum(residuals.^2) );

% get SINAD
% IEEE Std 1241-2000, page 52, eq. 94:
SINAD = (A./sqrt(2))./rms_noise;

% get ENOB
% IEEE Std 1241-2000, page 54, eq. 102:
ENOB = log2( FSR ./ (rms_noise .* sqrt(12)) );
if (ENOB > NoB)
    ENOB = NoB; %Saturating ENOB to the theoretical bit number
end

end

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
