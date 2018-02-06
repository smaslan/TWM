function [f1] = thd_find_freq(x, y1, fit, zc_filter, verbose)
% Part of non-coherent, windowed FFT, THD meter.
% Estimates fundamental frequency of the waveform.
% Note it was desgiend for low distortion signals!
%
% Input parameters:
%   x(:,1)      - input time vector [s]
%   y1(:,1)     - input waveform data
%   fit         - calculation mode {0 - zero cross, 1 - 4p fitting with sine, 2 - PSFE}
%   zc_filter   - moving average filter size for zero-cross method (usually 20)
%   verbose     - 0: shut up mode, 1: some information will be printed
%
% Outputs:
%   f           - frequency axis of the returned spectra [Hz]
%   sig(:,n)    - signal spectra, one column per signal 'n'
%   fs          - detected sampling rate [Hz]
%   f_bin_step  - frequency step of the DFT bins [Hz]
%   f_sig       - mean detected frequency of the input signals 
%   f_std       - stdev of the detected frequency [Hz]
%   rms_v       - RMS estimates of the signals 
%
%
% License:
% --------
% This is part of the non-coherent, windowed FFT, THD meter.
% (c) 2017, Martin Sira, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT
% 
        
        %%%% find frequency from zero crossings %%%%              
        % filter wave by moving average with abs(f1) samples  
        yf = conv(y1,ones(1,zc_filter));
        % now cut of yf to original length manually because old conv() doesn't support 'same' option (damn!)
        yf = yf(ceil((zc_filter-1)/2)+1:end-floor((zc_filter-1)/2));           
        
        % guess wave amplitude
        amp = (max(y1) + min(y1))/2;
        
        % center
        amp_m = max(y1) - min(y1);
        
        % repeat the zero-cross measurement for different tresholds
        f1 = 0;
        rep_test = 10;
        for k = -rep_test:rep_test
        
          % detection treshold
          level = amp_m + amp*k/(2*rep_test);
          
          % find rising edges
          idx = find(yf(2:end)>=level & yf(1:end-1)<level);
          % and fit to find frequency
          pa = polyfit([1:length(idx)]',x(idx),1);
          fa = 1/pa(1);
          
          % find falling edges
          idx = find(yf(2:end)<level & yf(1:end-1)>=level);
          % and fit to find frequency
          pb = polyfit([1:length(idx)]',x(idx),1);
          fb = 1/pb(1);
          
          % get average from rising/falling edges
          f1 += (fa + fb)/2;
        
        end
        % average repeated tests
        f1 /= (rep_test*2 + 1);
               
        
        if fit == 1
          %%%% 4-param non lin fit %%%%
        
          [A, f1] = FPNLSF(x, y1, f1, verbose);
                    
        elseif(fit == 2)
          %%%% PSFE mode %%%%
          
          f1 = PSFE(y1,x(2)-x(1),-f1);
          
        elseif(fit != 0)
          error('Unknown frequency measurement method!');
        end

end

% vim nastavovaci radka: vim: foldmarker=%{{{,%}}} fdm=marker fen ft=octave
