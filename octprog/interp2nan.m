function [zi] = interp2nan(x,y,z,xi,yi,varargin)
% This is a crude wrapper for interp2() function that should avoid unwanted NaN
% results if the 'xi' or 'yi' is on the boundary of NaN data in 'z'.
%
% Note: Not all parameter combinations for interp2() are implemented!
%       It is just very basic wrapper.
%
% Example:
% x = [1 2 3]
% y = [1;2;3]
% z = [1 2 3;
%      4 5 6;
%      7 8 NaN]
% interp2(x,y,z,3,2,'linear') may return NaN because the 'xi = 2' and 'yi = 3' 
% is on the boundary of the valid 'z' data.  
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
% 

    % maximum allowable tolerance: 
    max_eps_x = 5*eps*xi;
    max_eps_y = 5*eps*yi;
    
    % try to interpolate with offsets xi = <xi +/- max_eps>, yi = <yi +/- max_eps>:
    tmp(:,:,1) = interp2(x,y,z,xi + max_eps_x,yi + max_eps_y,varargin{:});
    tmp(:,:,2) = interp2(x,y,z,xi + max_eps_x,yi - max_eps_y,varargin{:});
    tmp(:,:,3) = interp2(x,y,z,xi - max_eps_x,yi - max_eps_y,varargin{:});
    tmp(:,:,4) = interp2(x,y,z,xi - max_eps_x,yi + max_eps_y,varargin{:});
    
    % select non NaN results from the candidates:
    zi = nanmean(tmp,3);    

end