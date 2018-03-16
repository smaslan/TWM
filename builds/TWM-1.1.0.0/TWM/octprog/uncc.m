function [uc] = uncc(ua,ub)
% combine two complex uncertainties

  uc = bsxfun(@plus,real(ua).^2,real(ub).^2).^0.5 + j*bsxfun(@plus,imag(ua).^2,imag(ub).^2).^0.5;
    
  if iscomplex(ua) || iscomplex(ub)
    uc = complex(uc);
  else
    uc = real(uc);
  end
    
end