%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DO NOT EDIT THIS DIRECTLY, THIS IS GENERATED AUTOMATICALLY! %%%
%%% Edit source in the ./source folder, then run 'make.bat'     %%%
%%% to rebuild this function.                                   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

