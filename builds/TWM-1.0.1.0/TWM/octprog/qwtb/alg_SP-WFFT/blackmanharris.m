function w = blackmanharris(m, opt)
% -- Function File: blackmanharris (M)
% -- Function File: blackmanharris (M, "periodic")
% -- Function File: blackmanharris (M, "symmetric")
%     Return the filter coefficients of a Blackman-Harris window of
%     length M.
%
%     If the optional argument '"periodic"' is given, the periodic form
%     of the window is returned.  This is equivalent to the window of
%     length M+1 with the last coefficient removed.  The optional
%     argument '"symmetric"' is equivalent to not specifying a second
%     argument.
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

  if (nargin < 1 || nargin > 2)
    print_usage ();
  elseif not( (isscalar (m) && (m == fix (m)) && (m > 0)))
    error ('blackmanharris: M must be a positive integer');
  end

  N = m - 1;
  if (nargin == 2)
    switch (opt)
      case 'periodic'
        N = m;
      case 'symmetric'
        N = m - 1;
      otherwise
        error ('blackmanharris: window type must be either `periodic` or `symmetric`');
    end
  end

  if (m == 1)
    w = 1;
  else
    a0 = 0.35875;
    a1 = 0.48829;
    a2 = 0.14128;
    a3 = 0.01168;
    n = [0:m-1]';
    w = a0 - a1.*cos(2.*pi.*n./N) + a2.*cos(4.*pi.*n./N) - a3.*cos(6.*pi.*n./N);
  end

end

%!assert (blackmanharris (1), 1);
%!assert (blackmanharris (2), 0.00006 * ones (2, 1), eps);
%!assert (blackmanharris (15), flipud (blackmanharris (15)), 10*eps);
%!assert (blackmanharris (16), flipud (blackmanharris (16)), 10*eps);
%!assert (blackmanharris (15), blackmanharris (15, "symmetric"));
%!assert (blackmanharris (16)(1:15), blackmanharris (15, "periodic"));

%% Test input validation
%!error blackmanharris ()
%!error blackmanharris (0.5)
%!error blackmanharris (-1)
%!error blackmanharris (ones (1, 4))
%!error blackmanharris (1, 2)
%!error blackmanharris (1, "invalid")

