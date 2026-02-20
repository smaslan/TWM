function [k] = loc2covg(loc,v)
    % level of confidence 'loc' to coverage factor for degrees of freedom 'v'
    k = tinv(0.5 + loc/2,v);
end


