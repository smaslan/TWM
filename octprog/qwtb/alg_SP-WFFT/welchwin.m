function w = welchwin(m, opt)
% -- Function File: welchwin (M)
% -- Function File: welchwin (M, "periodic")
% -- Function File: welchwin (M, "symmetric")
%     Return the filter coefficients of a Welch window of length M.  The
%     Welch window is given by W(n)=1-(n/N-1)^2, n=[0,1, ...  M-1].  The
%     optional argument specifies a "symmetric" window (the default) or a
%     "periodic" window.
%
%     A symmetric window has zero at each end and maximum in the middle,
%     and the length must be an integer greater than 2.  The variable N
%     in the formula above is '(M-1)/2'.
%
%     A periodic window wraps around the cyclic interval [0,1, ...  M-1],
%     and is intended for use with the DFT. The length must be an integer
%     greater than 1.  The variable N in the formula above is 'M/2'.
%
%     See also: blackman, kaiser.

% Copyright (C) 2007 Muthiah Annamalai <muthiah.annamalai@uta.edu>
% Copyright (C) 2008-2009 Mike Gross <mike@appl-tech.com>
% Copyright (C) 2008-2009 Peter V. Lanspeary <pvl@mecheng.adelaide.edu.au>
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
    error ('welchwin: M must be a positive integer');
  end

  N = (m - 1) / 2;
  mmin = 3;
  if (nargin == 2)
    switch (opt)
      case 'periodic'
        N = m / 2;
        mmin = 2;
      case 'symmetric'
        N = (m - 1) / 2;
      otherwise
        error ('welchwin: window type must be either `periodic` or `symmetric`');
    end
  end

  % Periodic window is not properly defined for m < 2.
  % Symmetric window is not properly defined for m < 3.
  if (m < mmin)
    error ('welchwin: M must be an integer greater than %d', mmin);
  end

  n = [0:m-1]';
  w = 1 - ((n-N)./N).^2;

end

%!demo
%! m = 32;
%! t = [0:m-1];
%! printf ("Graph: single period of ");
%! printf ("%d-point periodic (blue) and symmetric (red) windows\n", m);
%! xp = welchwin (m, "periodic");
%! xs = welchwin (m, "symmetric");
%! plot (t, xp, "b", t, xs, "r")

%!demo
%! m = 32;
%! t = [0:4*m-1];
%! printf ("Graph: 4 periods of ");
%! printf ("%d-point periodic (blue) and symmetric (red) windows\n", m);
%! xp = welchwin (m, "periodic");
%! xs = welchwin (m, "symmetric");
%! xp2 = repmat (xp, 4, 1);
%! xs2 = repmat (xs, 4, 1);
%! plot (t, xp2, "b", t, xs2, "r")

%!demo
%! m = 32;
%! n = 512;
%! xp = welchwin (m, "periodic");
%! s = fftshift (max (1e-2, abs (fft (postpad (xp, n)))));
%! f = [-0.5:1/n:0.5-1/n];
%! printf ("%dx null-padded, power spectrum of %d-point window\n", n/m, m);
%! semilogy (f, s)

%!assert (welchwin (3), [0; 1; 0]);
%!assert (welchwin (15), flipud (welchwin (15)));
%!assert (welchwin (16), flipud (welchwin (16)));
%!assert (welchwin (15), welchwin (15, "symmetric"));
%!assert (welchwin (16)(1:15), welchwin (15, "periodic"));

%% Test input validation
%!error welchwin ()
%!error welchwin (0.5)
%!error welchwin (-1)
%!error welchwin (ones (1, 4))
%!error welchwin (1, 2, 3)
%!error welchwin (1, "invalid")

