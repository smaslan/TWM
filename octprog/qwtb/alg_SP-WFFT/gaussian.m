function w = gaussian(m, a)
% -- Function File: gaussian (M)
% -- Function File: gaussian (M, A)
%
%     Return a Gaussian convolution window of length M.  The width of the
%     window is inversely proportional to the parameter A.  Use larger A
%     for a narrower window.  Use larger M for longer tails.
%
%     w = exp ( -(a*x)^2/2 )
%
%     for x = linspace ( -(m-1)/2, (m-1)/2, m ).
%
%     Width a is measured in frequency units (sample rate/num samples).
%     It should be f when multiplying in the time domain, but 1/f when
%     multiplying in the frequency domain (for use in convolutions).

% Copyright (C) 1999 Paul Kienzle <pkienzle@users.sf.net>
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
    error ('gaussian: M must be a positive integer');
  elseif (nargin == 1)
    a = 1;
  end

  w = exp(-0.5*(([0:m-1]'-(m-1)/2)*a).^2);

end

%!assert (gaussian (1), 1)

%% Test input validation
%!error gaussian ()
%!error gaussian (0.5)
%!error gaussian (-1)
%!error gaussian (ones (1, 4))
%!error gaussian (1, 2, 3)
