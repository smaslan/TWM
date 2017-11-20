function w = blackmannuttall(m, opt)
% -- Function File: blackmannuttall (M)
% -- Function File: blackmannuttall (M, "periodic")
% -- Function File: blackmannuttall (M, "symmetric")
%     Return the filter coefficients of a Blackman-Nuttall window of
%     length M.
%
%     If the optional argument '"periodic"' is given, the periodic form
%     of the window is returned.  This is equivalent to the window of
%     length M+1 with the last coefficient removed.  The optional
%     argument '"symmetric"' is equivalent to not specifying a second
%     argument.
%
%     See also: nuttallwin, kaiser.

% Copyright (C) 2007 Muthiah Annamalai <muthiah.annamalai@uta.edu>
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
    error ('blackmannuttall: M must be a positive integer');
  end

  N = m - 1;
  if (nargin == 2)
    switch (opt)
      case 'periodic'
        N = m;
      case 'symmetric'
        N = m - 1;
      otherwise
        error ('blackmannuttall: window type must be either `periodic` or `symmetric`');
    end
  end

  if (m == 1)
    w = 1;
  else
    a0 = 0.3635819;
    a1 = 0.4891775;
    a2 = 0.1365995;
    a3 = 0.0106411;
    n = [0:m-1]';
    w = a0 - a1.*cos(2.*pi.*n./N) + a2.*cos(4.*pi.*n./N) - a3.*cos(6.*pi.*n./N);
  end

end

%!assert (blackmannuttall (1), 1)
%!assert (blackmannuttall (2), 0.0003628 * ones (2, 1), eps)
%!assert (blackmannuttall (15), flipud (blackmannuttall (15)), 10*eps);
%!assert (blackmannuttall (16), flipud (blackmannuttall (16)), 10*eps);
%!assert (blackmannuttall (15), blackmannuttall (15, "symmetric"));
%!assert (blackmannuttall (16)(1:15), blackmannuttall (15, "periodic"));

%% Test input validation
%!error blackmannuttall ()
%!error blackmannuttall (0.5)
%!error blackmannuttall (-1)
%!error blackmannuttall (ones (1, 4))
%!error blackmannuttall (1, 2)
%!error blackmannuttall (1, "invalid")

