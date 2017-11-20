function w = nuttallwin(m, opt)
% -- Function File: nuttallwin (M)
% -- Function File: nuttallwin (M, "periodic")
% -- Function File: nuttallwin (M, "symmetric")
%     Return the filter coefficients of a Blackman-Harris window defined
%     by Nuttall of length M.
%
%     If the optional argument '"periodic"' is given, the periodic form
%     of the window is returned.  This is equivalent to the window of
%     length M+1 with the last coefficient removed.  The optional
%     argument '"symmetric"' is equivalent to not specifying a second
%     argument.
%
%     See also: blackman, blackmanharris.

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
    error ('nuttallwin: M must be a positive integer');
  end

  N = m - 1;
  if (nargin == 2)
    switch (opt)
      case 'periodic'
        N = m;
      case 'symmetric'
        N = m - 1;
      otherwise
        error ('nuttallwin: window type must be either `periodic` or `symmetric`');
    end
  end

  if (m == 1)
    w = 1;
  else
    a0 = 0.355768;
    a1 = 0.487396;
    a2 = 0.144232;
    a3 = 0.012604;
    n = [-N/2:(m-1)/2]';
    w = a0 + a1.*cos(2.*pi.*n./N) + a2.*cos(4.*pi.*n./N) + a3.*cos(6.*pi.*n./N);
  end

end

%!assert (nuttallwin (1), 1)
%!assert (nuttallwin (2), zeros (2, 1), eps)
%!assert (nuttallwin (15), flipud (nuttallwin (15)), 10*eps);
%!assert (nuttallwin (16), flipud (nuttallwin (16)), 10*eps);
%!assert (nuttallwin (15), nuttallwin (15, "symmetric"));
%!assert (nuttallwin (16)(1:15), nuttallwin (15, "periodic"));

%% Test input validation
%!error nuttallwin ()
%!error nuttallwin (0.5)
%!error nuttallwin (-1)
%!error nuttallwin (ones (1, 4))
%!error nuttallwin (1, 2)
%!error nuttallwin (1, "invalid")

