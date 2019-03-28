function [vr,par] = var_init(par)
% Initialize automatic parameter variation algorithm.
% It will scan the elements of 'par' structure and each vector parameter
% will be used for the automatic parameter combinations generation.
% Note it will consider string elements as scalars. 
% This must be called once before all other 'var_*' function can be used!
%
% License:
% --------
% This is part of VAR library for automatic multidim. variation of simulation parameters.
% (c) 2018, Stanislav Maslan, s.maslan@seznam.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT 

  % add paramter combination ID into the parameters structure
  par.pvpid = 0;
      
  % get input paramter names
  vr.names = fieldnames(par);
  
  % get parameters count
  vr.n = length(vr.names);
  
  % create variation counters for each paramter
  vr.par_cnt = ones(1,vr.n);
      
  % get parameter types and lengths (1 for scalar, N for vector)
  vr.par_n = cellfun(@length,cellfun(@getfield,repmat({par},length(vr.names),1),vr.names,'UniformOutput',false));
  
  % assume char strings are scalars:
  is_charz = cellfun(@ischar,cellfun(@getfield,repmat({par},length(vr.names),1),vr.names,'UniformOutput',false));  
  vr.par_n(~~is_charz) = 1;
  
  % get total variations count
  vr.var_n = prod(vr.par_n);
  par.pvpcnt = vr.var_n;
  
  % no paramter combinations generated yet
  vr.var_id = 0;
  
  % no results measured yet
  vr.res_n = 0;
  
end
