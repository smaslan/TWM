%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% DO NOT EDIT THIS DIRECTLY, THIS IS GENERATED AUTOMATICALLY! %%%
%%% Edit source in the ./source folder, then run 'make.bat'     %%%
%%% to rebuild this function.                                   %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

    persistent is_octave;  % speeds up repeated calls  
    if isempty (is_octave)
        is_octave = (exist ('OCTAVE_VERSION', 'builtin') > 0);
    end

    if any(isnan(z))
    
        % maximum allowable tolerance: 
        max_eps_x = 5*eps*xi;
        max_eps_y = 5*eps*yi;
        
        if any(strcmpi(varargin,'linear')) || is_octave
    
            % try to interpolate with offsets xi = <xi +/- max_eps>, yi = <yi +/- max_eps>:
            tmp(:,:,1) = interp2(x,y,z,xi + max_eps_x,yi + max_eps_y,varargin{:});
            tmp(:,:,2) = interp2(x,y,z,xi + max_eps_x,yi - max_eps_y,varargin{:});
            tmp(:,:,3) = interp2(x,y,z,xi - max_eps_x,yi - max_eps_y,varargin{:});
            tmp(:,:,4) = interp2(x,y,z,xi - max_eps_x,yi + max_eps_y,varargin{:});
        
        else
        
            % try to interpolate with offsets xi = <xi +/- max_eps>, yi = <yi +/- max_eps>:
            tmp(:,:,1) = interp2p(x,y,z,xi + max_eps_x,yi + max_eps_y,varargin{:});
            tmp(:,:,2) = interp2p(x,y,z,xi + max_eps_x,yi - max_eps_y,varargin{:});
            tmp(:,:,3) = interp2p(x,y,z,xi - max_eps_x,yi - max_eps_y,varargin{:});
            tmp(:,:,4) = interp2p(x,y,z,xi - max_eps_x,yi + max_eps_y,varargin{:});
        
        end
      
        % select non NaN results from the candidates:
        zi = nanmean(tmp,3);
    
    else
        
        if any(strcmpi(varargin,'linear')) || is_octave    
            zi = interp2(x,y,z,xi,yi,varargin{:});        
        else
            zi = interp2p(x,y,z,xi,yi,varargin{:});
        end
    end

end

function [zi] = interp2p(x,y,z,xi,yi,varargin)
% very crude replacement of the interp2() to enable support for 'pchip' in 2D in Matlab
% it is designed just for function in this file! Not general interp2 replacement!
% note it was designed for long y-dim and short x-dim
% when it is the other way, it will be painfully slow in Matlab 
    
    if sum(size(xi) > 1) > 1
        % xi, yi are most likely meshes - reduce:
        xi = xi(1,:);
        yi = yi(:,1);
    end
    
    tmp = interp1(x.',z.',xi,varargin{:}).';    
    zi = interp1(y,tmp,yi,varargin{:});
    %tmp = interp1(y,z,yi,varargin{:});
    %zi = interp1(x.',tmp.',xi,varargin{:}).';

end

