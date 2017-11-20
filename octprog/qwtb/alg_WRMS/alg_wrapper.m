function dataout = alg_wrapper(datain, calcset) %<<<1
  % Part of QWTB. Wrapper script for algorithm PSFE.
  %
  % See also qwtb
  
  % Format input data --------------------------- %<<<1
  
  if isfield(datain, 'Ts')
      Ts = datain.Ts.v;
  elseif isfield(datain, 'fs')
      Ts = 1/datain.fs.v;
      if calcset.verbose
          disp('QWTB: WRMS wrapper: sampling time was calculated from sampling frequency')
      end
  else
      Ts = mean(diff(datain.t.v));
      if calcset.verbose
          disp('QWTB: WRMS wrapper: sampling time was calculated from time series')
      end
  end
  
  init_guess = 1;
  
  % Call algorithm ---------------------------  %<<<1
  
  [rms, unc, sp_f, sp_A] = wrms(datain.y.v, 1/Ts);
  
  % Format output data:  --------------------------- %<<<1
  dataout.rms.v = rms;
  dataout.rms.u = unc;
  dataout.f.v = sp_f;
  dataout.A.v = sp_A;
     

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
