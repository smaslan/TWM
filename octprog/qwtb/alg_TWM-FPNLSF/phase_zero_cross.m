function [phi] = phase_zero_cross(ux)
% Schmutzig zero-cross phase detector.

  % to columnt vector
  ux = ux(:);

  % find voltage peaks
  umax = max(ux);
  umin = min(ux);
  
  T = 0; 
  % generate "zero" cross tresholds (uses multiple treshold instead of just zero to icrease resolution)
  tresholds = [(umax + umin), 0.5*umin:0.05:0.5*umax];
  % for each treshold
  for k = 1:numel(tresholds)
    % treshold value
    tr = tresholds(k);
    % find coarse zero crossings (rising edges)
    id = find(ux(2:end) > tr & ux(1:end-1) < tr);
    if numel(id) > 1
      % interpolate to increase time resolution
      zcs = real(id) - 1 + (tr - ux(id))./(ux(id+1) - ux(id));
      % average zero cross periods
      T += mean(diff(zcs))/numel(tresholds);  
    endif           
    if numel(id) > 1 && k == 1
      % store zero crosses (this is actual zero treshold)
      zc0 = zcs;
    endif
  endfor
  
  if exist('zc0','var') && numel(zc0) && T > 0.1
    % calculate phase shift guess
    phi = -angle(mean(exp(j*rem(zc0,T)/T*2*pi)));
  else
    % possibly too short or differently fucked up waveform, cannot find phase
    phi = inf;
  endif  

endfunction








