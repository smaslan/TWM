function w = barthannwin(m)
% -- Function File: barthannwin (M)
%     Return the filter coefficients of a modified Bartlett-Hann window
%     of length M.
%
%     See also: rectwin, bartlett.

% Copyright (C) 2007 Sylvain Pelissier <sylvain.pelissier@gmail.com>
%
% This program is free software; you can redistribute it and/or modify it under
% the terms of the GNU General Public License as published by the Free Software
% Foundation; either version 3 of the License, or (at your option) any later
% version.
%
% This program is distributed in the hope that it will be useful, but WITHOUT
% ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
% FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
% details.
%
% You should have received a copy of the GNU General Public License along with
% this program; if not, see <http://www.gnu.org/licenses/>.

  if (nargin ~= 1)
    print_usage ();
  elseif not( (isscalar (m) && (m == fix (m)) && (m > 0)))
    error ('barthannwin: M must be a positive integer');
  end

  if (m == 1)
    w = 1;
  else
    N = m - 1;
    n = 0:N;

    w = 0.62 -0.48.*abs(n./(m-1) - 0.5)+0.38*cos(2.*pi*(n./(m-1)-0.5));
    w = w';
  end

end

%!assert (barthannwin (1), 1)
%!assert (barthannwin (2), zeros (2, 1))

%% Test input validation
%!error barthannwin ()
%!error barthannwin (0.5)
%!error barthannwin (-1)
%!error barthannwin (ones (1, 4))
%!error barthannwin (1, 2)
