function w = parzenwin(m)
% -- Function File: parzenwin (M)
%     Return the filter coefficients of a Parzen window of length M.
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
    error ('parzenwin: M must be a positive integer');
  end

  N = m - 1;
  n = -(N/2):N/2;
  n1 = n(find(abs(n) <= N/4));
  n2 = n(find(n > N/4));
  n3 = n(find(n < -N/4));

  w1 = 1 -6.*(abs(n1)./(m/2)).^2 + 6*(abs(n1)./(m/2)).^3;
  w2 = 2.*(1-abs(n2)./(m/2)).^3;
  w3 = 2.*(1-abs(n3)./(m/2)).^3;
  w = [w3 w1 w2]';

end

%!assert (parzenwin (1), 1)
%!assert (parzenwin (2), 0.25 * ones (2, 1))

%% Test input validation
%!error parzenwin ()
%!error parzenwin (0.5)
%!error parzenwin (-1)
%!error parzenwin (ones (1, 4))
%!error parzenwin (1, 2)
