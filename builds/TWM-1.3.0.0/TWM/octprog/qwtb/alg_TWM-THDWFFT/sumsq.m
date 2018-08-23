function [s] = sumsq(val,dim)
  if nargin < 2
    dim = 1;
  end
  if isvector(val)
    val = val(:);
  end
  s = sum(val.^2,dim);
end