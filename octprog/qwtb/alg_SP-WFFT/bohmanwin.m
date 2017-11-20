function w = bohmanwin(m)
% -- Function File: bohmanwin (M)
%     Return the filter coefficients of a Bohman window of length M.
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
    error ('bohmanwin: M must be a positive integer');
  end

  if (m == 1)
    w = 1;
  else
    N = m - 1;
    n = -N/2:N/2;

    w = (1-2.*abs(n)./N).*cos(2.*pi.*abs(n)./N) + (1./pi).*sin(2.*pi.*abs(n)./N);
    w(1) = 0;
    w(length(w))=0;
    w = w';
  end

end

%!assert (bohmanwin (1), 1)
%!assert (bohmanwin (2), zeros (2, 1))

%% Test input validation
%!error bohmanwin ()
%!error bohmanwin (0.5)
%!error bohmanwin (-1)
%!error bohmanwin (ones (1, 4))
%!error bohmanwin (1, 2)
