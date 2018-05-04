function [y_out, first, last, fr,fg,fp] = td_fft_filter(y, fs, fft_size, f,gain,phi, i_mode, nyquist_fix)
% Wrapper for "Frequency Dependant Phase and Gain Compensation" function
% sFreqDep_PG_Comp() made by Kristian Ellingsberg.
%
% This is part of the PWRTDI - TimeDomainIntegration power alg.
% (c) 2018, Stanislav Maslan (smaslan@cmi.cz)
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.
%
%  

    if ~isequal(fft_size, 2^nextpow2(fft_size))  
        error('Filter size must be 2^N!');
    end
    
    % default interpolation mode:
    if nargin < 7
        i_mode = 'pchip';
    end
    
    % nyquist problem fix value:
    %  this defines portion of the near nyquist band where the algorithm will not apply phase correction  
    if nargin < 8
        nyquist_fix = 0.02;
    end
    
    
    % --- build the filter:
    
    % half filter size:    
    fft_half = fft_size/2;
        
    % relative frequency of the filter component (positive freq. half only):
    fr(:,1) = [0:fft_half]/fft_size*fs;
    
    % interpolate filter data to filter frequencies:
    fg = interp1(f,gain,fr,i_mode,'extrap');
    fp = interp1(f,phi,fr,i_mode,'extrap');
    
    % -- near-nyquist errors fix: 
    if nyquist_fix > 0
        % maskout phase correction near nyquist to prevent massive errors at the end of spectrum
        % but it's not possible to just mask the DFT bins phase, it must be smooth, so apply window
        % to the end of phase correction data:
        
        % mask width (size from nyquist bin):
        msk_w = round(nyquist_fix*fft_half);
        
        % generate mask:
        msk = 0.5 + 0.5*cos([0:msk_w]'/msk_w*pi);
        
        % apply the mask to the end of spectrum:
        fp((end-msk_w):end) = fp((end-msk_w):end).*msk;
        %fg((end-msk_w):end) = fg((end-msk_w):end).*msk;
        
        % -- apply mask for nead dc
        % mask width (size from nyquist bin):
        msk_w = 4;
        
        % generate mask:
        msk = 0.5 + 0.5*cos([msk_w:-1:0]'/msk_w*pi);

        % apply the mask to the end of spectrum:
        fp(1:msk_w+1) = fp(1:msk_w+1).*msk;
    
    end
               
    % generate first half of the filter:
    ff(:,1) = fg.*exp(j*fp);
    % remove DC phase:
    ff(1) = fg(1);
    % build the upper half of the spectrum:
    ff(fft_half+2:fft_size) = conj(ff(end-1:-1:2));
    
    % ###todo: fix this very bad solution for the nyquist bin
    %  It is not right because the nyq. DFT bin is equal to: A_nyquist*sin(phi_nyquist),
    %  so it is not possible to just multiply it by the correction vector as the other DFT bins...
    ff(fft_half+1) = 1*fg(end)*cos(fp(end));
    
    
    % --- run the filter:
    [y_out, first, last] = sFreqDep_PG_Comp(y.', fft_size, ff.');    
    y_out = y_out.';
    
end


function [yi] = interp1nan(x,y,xi,varargin)
% This is a crude wrapper for interp1() function that should avoid unwanted NaN
% results if the 'xi' is on the boundary of NaN data in 'y'.
%
% Note: Not all parameter combinations for interp1() are implemented!
%       It is just very basic wrapper.
%
% Example:
% x = [1 2 3], y = [1 2 NaN]
% interp1(x,y,2,'linear') may return NaN because the 'xi = 2' is on the boundary
% of the valid 'y' data.  
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
% 

    if any(isnan(y))

        % maximum allowable tolerance: 
        max_eps = 5*eps*xi;
        
        % try to interpolate with offsets xi = <xi +/- max_eps>:
        tmp(:,:,1) = interp1(x,y,xi + max_eps,varargin{:});
        tmp(:,:,2) = interp1(x,y,xi - max_eps,varargin{:});
        
        % select non NaN results from the candidates:
        yi = nanmean(tmp,3);
        
    else
        yi = interp1(x,y,xi,varargin{:});    
    end   

end
