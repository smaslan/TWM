function yy = smooth_mat(varargin)
% -- Function File: YY = smooth (Y)
% -- Function File: YY = smooth (Y, SPAN)
% -- Function File: YY = smooth (Y, METHOD)
% -- Function File: YY = smooth (Y, SPAN, METHOD)
% -- Function File: YY = smooth (Y, "sgolay", DEGREE)
% -- Function File: YY = smooth (Y, SPAN, 'sgolay', DEGREE)
% -- Function File: YY = smooth (X, Y, ...)
%
%     This is an implementation of the functionality of the 'smooth'
%     function in Matlab's Curve Fitting Toolbox.
%
%     Smooths the Y data with the chosen method, see the table below for
%     available methods.
%
%     The X data does not need to have uniform spacing.
%
%     For the methods "moving" and "sgolay" the SPAN parameter defines
%     how many data points to use for the smoothing of each data point.
%     Default is 5, i.e.  the center point and two neighbours on each
%     side.
%
%     Smoothing methods specified by METHOD:
%
%     "moving"
%          Moving average (default).  For each data point, the average
%          value of the span is used.  Corresponds to lowpass filtering.
%
%     "sgolay"
%          Savitzky-Golay filter.  For each data point a polynomial of
%          degree DEGREE is fitted (using a least-square regression) to
%          the span and evaluated for the current X value.  Also known as
%          digital smoothing polynomial filter or least-squares smoothing
%          filter.  Default value of DEGREE is 2.
%
%     "lowess"
%
%     "loess"
%
%     "rlowess"
%
%     "rloess"
%
%     Documentation of the Matlab smooth function:
%     <http://www.mathworks.se/help/curvefit/smooth.html>
%     <http://www.mathworks.se/help/curvefit/smoothing-data.html>
%

% Copyright (C) 2013 Erik Kjellson <erikiiofph7@users.sourceforge.net>
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

  % Default values
  
  span   = 5;
  method = 'moving';
  degree = 2;        %% for sgolay method
  
  % Keep track of the order of the arguments
  argidx_x      = -1;
  argidx_y      = -1;
  argidx_span   = -1;
  argidx_method = -1;
  argidx_degree = -1;
  
  % Check input arguments
  
  if (nargin < 1)
    print_usage ();
  else
    % 1 or more arguments
    if (~isnumeric (varargin{1}))
      error ('smooth: first argument must be a vector')
    end
    if (nargin < 2)
      % first argument is y
      argidx_y = 1;
      y = varargin{1};
    else
      % 2 or more arguments
      if ((isnumeric (varargin{2})) && (length (varargin{2}) > 1))
        % both x and y are provided
        argidx_x = 1;
        argidx_y = 2;
        x = varargin{1};
        y = varargin{2};
        if (length (x) ~= length (y))
          error ('smooth: x and y vectors must have the same length')
        end
      else
        % Only y provided, create an evenly spaced x vector
        argidx_y = 1;
        y    = varargin{1};
        x = 1:length (y);
        if ((isnumeric (varargin{2})) && (length (varargin{2}) == 1))
          % 2nd argument is span
          argidx_span = 2;
          span = varargin{2};
        elseif (ischar (varargin{2}))
          % 2nd argument is method
          argidx_method = 2;
          method = varargin{2};        
        else
          error ('smooth: 2nd argument is of unexpected type')
        end
      end
      if (nargin > 2)
        if ((argidx_y == 2) && (isnumeric (varargin{3})))
          % 3rd argument is span
          argidx_span = 3;
          span = varargin{3};
          if (length (span) > 1)
            error ('smooth: 3rd argument can''t be a vector')
          end
        elseif (ischar (varargin{3}))
          % 3rd argument is method
          argidx_method = 3;
          method = varargin{3};   
        elseif (strcmp (varargin{2}, 'sgolay') && (isnumeric (varargin{3})))
          % 3rd argument is degree
          argidx_degree = 3;
          degree = varargin{3};
          if (length (degree) > 1)
            error ('smooth: 3rd argument is of unexpected type')
          end
        else
          error ('smooth: 3rd argument is of unexpected type')
        end
        if (nargin > 3)
          if (argidx_span == 3)
            % 4th argument is method
            argidx_mehod = 4;
            method = varargin{4};
            if (~ischar (method))
              error ('smooth: 4th argument is of unexpected type')
            end
          elseif (strcmp (varargin{3}, 'sgolay'))
            % 4th argument is degree
            argidx_degree = 4;
            degree = varargin{4};
            if ((~isnumeric (degree)) || (length (degree) > 1))
              error ('smooth: 4th argument is of unexpected type')
            end
          else
            error ('smooth: based on the first 3 arguments, a 4th wasn''t expected')
          end
          if (nargin > 4)
            if (strcmp (varargin{4}, 'sgolay'))
              % 5th argument is degree
              argidx_degree = 5;
              degree = varargin{5};
              if ((~isnumeric (degree)) || (length (degree) > 1))
                error ('smooth: 5th argument is of unexpected type')
              end
            else
              error ('smooth: based on the first 4 arguments, a 5th wasn''t expected')
            end
            if (nargin > 5)
              error ('smooth: too many input arguments')
            end
          end
        end
      end
    end
  end

  % Perform smoothing
  
  if (span > length (y))
    error ('smooth: span cannot be greater than ''length (y)''.')
  end
  yy = [];
  switch method
    % --- Moving average
    case 'moving'
      for i=1:length (y)
        if (mod (span,2) == 0)
          error ('smooth: span must be odd.')
        end
        if (i <= (span-1)/2)
          % We're in the beginning of the vector, use as many y values as 
          % possible and still having the index i in the center.
          % Use 2*i-1 as the span.
          idx1 = 1;
          idx2 = 2*i-1;
        elseif (i <= length (y) - (span-1)/2)
          % We're somewhere in the middle of the vector.
          % Use full span.
          idx1 = i-(span-1)/2;
          idx2 = i+(span-1)/2;
        else
          % We're near the end of the vector, reduce span.
          % Use 2*(length (y) - i) + 1 as span
          idx1 = i - (length (y) - i);
          idx2 = i + (length (y) - i);
        end
        yy(i) = mean (y(idx1:idx2));
      end
      
    % --- Savitzky-Golay filtering
    case 'sgolay'
      % FIXME: Check how Matlab takes care of the beginning and the end. Reduce polynomial degree?
      for i=1:length (y)
        if (mod (span,2) == 0)
          error ('smooth: span must be odd.')
        end
        if (i <= (span-1)/2)
          % We're in the beginning of the vector, use as many y values as 
          % possible and still having the index i in the center.
          % Use 2*i-1 as the span.
          idx1 = 1;
          idx2 = 2*i-1;
        elseif (i <= length (y) - (span-1)/2)
          % We're somewhere in the middle of the vector.
          % Use full span.
          idx1 = i-(span-1)/2;
          idx2 = i+(span-1)/2;
        else
          % We're near the end of the vector, reduce span.
          % Use 2*(length (y) - i) + 1 as span
          idx1 = i - (length (y) - i);
          idx2 = i + (length (y) - i);
        end
        % Fit a polynomial to the span using least-square method.
        p     = polyfit(x(idx1:idx2), y(idx1:idx2), degree);
        % Evaluate the polynomial in the center of the span.
        yy(i) = polyval(p,x(i));
      end
            
    % ---
    case 'lowess'
      % FIXME: implement smoothing method 'lowess'
      error ('smooth: method ''lowess'' not implemented yet')
      
    % ---
    case 'loess'
      % FIXME: implement smoothing method 'loess'
      error ('smooth: method ''loess'' not implemented yet')
      
    % ---
    case 'rlowess'
      % FIXME: implement smoothing method 'rlowess'
      error ('smooth: method ''rlowess'' not implemented yet')
      
    % ---
    case 'rloess'
      % FIXME: implement smoothing method 'rloess'
      error ('smooth: method ''rloess'' not implemented yet')
      
    % ---
    otherwise
      error ('smooth: unknown method')
  end
end

%

%!test
%! ## 5 y values (same as default span)
%! y = [42 7 34 5 9];
%! yy2    = y;
%! yy2(2) = (y(1) + y(2) + y(3))/3;
%! yy2(3) = (y(1) + y(2) + y(3) + y(4) + y(5))/5;
%! yy2(4) = (y(3) + y(4) + y(5))/3;
%! yy = smooth (y);
%! assert (yy, yy2);

%!test
%! ## x vector provided
%! x = 1:5;
%! y = [42 7 34 5 9];
%! yy2    = y;
%! yy2(2) = (y(1) + y(2) + y(3))/3;
%! yy2(3) = (y(1) + y(2) + y(3) + y(4) + y(5))/5;
%! yy2(4) = (y(3) + y(4) + y(5))/3;
%! yy = smooth (x, y);
%! assert (yy, yy2);

%!test
%! ## span provided
%! y = [42 7 34 5 9];
%! yy2    = y;
%! yy2(2) = (y(1) + y(2) + y(3))/3;
%! yy2(3) = (y(2) + y(3) + y(4))/3;
%! yy2(4) = (y(3) + y(4) + y(5))/3;
%! yy = smooth (y, 3);
%! assert (yy, yy2);

%!test
%! ## x vector & span provided
%! x = 1:5;
%! y = [42 7 34 5 9];
%! yy2    = y;
%! yy2(2) = (y(1) + y(2) + y(3))/3;
%! yy2(3) = (y(2) + y(3) + y(4))/3;
%! yy2(4) = (y(3) + y(4) + y(5))/3;
%! yy = smooth (x, y, 3);
%! assert (yy, yy2);

%!test
%! ## method 'moving' provided
%! y = [42 7 34 5 9];
%! yy2    = y;
%! yy2(2) = (y(1) + y(2) + y(3))/3;
%! yy2(3) = (y(1) + y(2) + y(3) + y(4) + y(5))/5;
%! yy2(4) = (y(3) + y(4) + y(5))/3;
%! yy = smooth (y, 'moving');
%! assert (yy, yy2);

%!test
%! ## x vector & method 'moving' provided
%! x = 1:5;
%! y = [42 7 34 5 9];
%! yy2    = y;
%! yy2(2) = (y(1) + y(2) + y(3))/3;
%! yy2(3) = (y(1) + y(2) + y(3) + y(4) + y(5))/5;
%! yy2(4) = (y(3) + y(4) + y(5))/3;
%! yy = smooth (x, y, 'moving');
%! assert (yy, yy2);

%!test
%! ## span & method 'moving' provided
%! y = [42 7 34 5 9];
%! yy2    = y;
%! yy2(2) = (y(1) + y(2) + y(3))/3;
%! yy2(3) = (y(2) + y(3) + y(4))/3;
%! yy2(4) = (y(3) + y(4) + y(5))/3;
%! yy = smooth (y, 3, 'moving');
%! assert (yy, yy2);

%!test
%! ## x vector, span & method 'moving' provided
%! x = 1:5;
%! y = [42 7 34 5 9];
%! yy2    = y;
%! yy2(2) = (y(1) + y(2) + y(3))/3;
%! yy2(3) = (y(2) + y(3) + y(4))/3;
%! yy2(4) = (y(3) + y(4) + y(5))/3;
%! yy = smooth (x, y, 3, 'moving');
%! assert (yy, yy2);

%

%!demo
%! ## Moving average & Savitzky-Golay
%! x     = linspace (0, 4*pi, 150);
%! y     = sin (x) + 1*(rand (1, length (x)) - 0.5);
%! y_ma  = smooth (y, 21, 'moving');
%! y_sg  = smooth (y, 21, 'sgolay', 2);
%! y_sg2 = smooth (y, 51, 'sgolay', 2);
%! figure
%! plot (x,y, x,y_ma, x,y_sg, x,y_sg2)
%! legend('Original', 'Moving Average (span 21)', 'Savitzky-Golay (span 21, degree 2)', 'Savitzky-Golay (span 51, degree 2)')

