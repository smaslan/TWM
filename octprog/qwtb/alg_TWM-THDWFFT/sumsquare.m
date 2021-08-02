% Sum of squares of elements along dimension DIM.
%
% This function was created only because Matlab's 'sumsqr' is part of some costly package, while GNU
% Octave has got 'sumsq' as a core function. Therefore the name 'sumsquare' was selected to not
% interfere with either GNU Octave nor Matlab functions.
%
% This function calculates 'square of the numbers', not 'square of the absolute value of the
% numbers'. Therefore:
%   this function:  sumsquare(i) = -1
%   GNU Octave:     sumsq(i) = 1 (same as abs(i)^2 = 1)
%   Matlab:         sumsqr(i) -> Error

function [s] = sumsquare(val,dim)
  if nargin < 2
    dim = 1;
  end
  if isvector(val)
    val = val(:);
  end
  s = sum(val.^2,dim);
end
