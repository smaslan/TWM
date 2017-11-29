function w = kaiser(m, beta)
% original definition changed for Matlab compatibility.
% function w = kaiser(m, beta=0.5)
% -- Function File: kaiser (M)
% -- Function File: kaiser (M, BETA)
%
%     Return the filter coefficients of a Kaiser window of length M.  The
%     Fourier transform of the window has a stop-band attenuation that is
%     derived from the parameter BETA.
%
%     For the definition of the Kaiser window, see A. V. Oppenheim & R.
%     W. Schafer, "Discrete-Time Signal Processing".
%
%     The continuous version of width m centered about x=0 is:
%
%                  besseli(0, beta * sqrt(1-(2*x/m).^2))
%          k(x) =  -------------------------------------,  m/2 <= x <= m/2
%                         besseli(0, beta)
%
%     See also: kaiserord.

% Copyright (C) 1995, 1996, 1997 Kurt Hornik <Kurt.Hornik@ci.tuwien.ac.at>
% Copyright (C) 2000 Paul Kienzle <pkienzle@users.sf.net>
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
  end
  % added because of matlab compatibility:
  if nargin < 2
          beta = 0.5;
  end
  if not( (isscalar (m) && (m == fix (m)) && (m > 0)))
    error ('kaiser: M must be a positive integer');
  elseif not( (isscalar (beta) && isreal (beta)))
    error ('kaiser: BETA must be a real scalar');
  end

  if (m == 1)
    w = 1;
  else
    N = m - 1;
    k = (0 : N)';
    k = 2 * beta / N * sqrt (k .* (N - k));
    w = besseli (0, k) / besseli (0, beta);
  end

end

%!demo
%! % use demo("kaiserord");

%!assert (kaiser (1), 1)

%% Test input validation
%!error kaiser ()
%!error kaiser (0.5)
%!error kaiser (-1)
%!error kaiser (ones (1, 4))
%!error kaiser (1, 2, 3)
