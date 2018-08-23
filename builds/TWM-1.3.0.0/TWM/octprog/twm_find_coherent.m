function [fs_out, N_out, err] = twm_find_coherent(f0, t_min, t_max, rate, max_err, timeout)

  if ~exist('max_err','var') || isempty(max_err)
    % default maximum relative error of the coherent setup
    max_err = 1e-9;
  end
  
  if ~exist('timeout','var') || isempty(timeout)
    % default search timeout
    timeout = 5;
  end
    
  if isfield(rate,'Ts_step')
    % --- equidistant period step mode
    % set mode flag:
    is_equ_fs = 0;
    
    % load period step
    Ts_step = rate.Ts_step;
    
    % round ADC sampling rate range by the step
    % because of potential loss of accuracy on LV -> Octave/Matlab interface
    rate.adc_fs_max = round(rate.adc_fs_max*Ts_step)/Ts_step;    
    rate.adc_fs_min = round(rate.adc_fs_min*Ts_step)/Ts_step;
  
  elseif isfield(rate,'fs_step')
    % --- uquidistant frequency step mode
    % set mode flag:
    is_equ_fs = 1;
    
    % load period step
    fs_step = rate.fs_step;
    
    % round ADC sampling rate range by the step
    % because of potential loss of accuracy on LV -> Octave/Matlab interface
    rate.adc_fs_max = round(rate.adc_fs_max/fs_step)*fs_step;    
    rate.adc_fs_min = round(rate.adc_fs_min/fs_step)*fs_step;
  
  else
    % fail
    error('TWM: Coherent setup finder failed! Not recognized sampling rate mode.');
  end
  
  % get minimum desired sampling rate [Hz]
  fs_min = rate.fs_min - eps;
  
  % get maximum desired sampling rate [Hz]
  if isfield(rate,'fs_rel_tol')
    % relative tolerange of sampling rate available: fs_max = fs_min*(1 + fs_rel_tol)
    fs_max = fs_min*(1 + rate.fs_rel_tol);
  elseif isfield(rate,'fs_max')
    % max. sampling rate given as absolute
    fs_max = rate.fs_max;
  else
    % no maximum sampling rate entered, assume user wanted exact value
    fs_max = fs_min;  
  end
  
  % swap min/max sampling rate if the range was entered wrong way
  if fs_min > fs_max
    tmp = fs_min;
    fs_min = fs_max;
    fs_max = tmp;
  end

  
  % maximum candidate sampling rates for direct solution
  max_for_direct = 10000;
        

  % reset timer for timeout  
  tic();
  
  % fundamental period [s]
  T0 = 1/f0;
           
  % allowed range of integration times [s]
  t_range = [t_min, t_max];
  t_range = sort(t_range);
  
  % limit integration time to at least one period of the fudnamental period T0
  t_range = max(t_range,T0);
  
  % range of fund. periods per record
  P = round(t_range/T0);
  
  % generate list of possible integration times [s]
  t_range = [P(1):P(end)]*T0;


  
  % get rough count of candidate sampling rates
  if is_equ_fs
    count = (fs_max - fs_min)/fs_step;
  else
    count = (1/fs_min - 1/fs_max)/Ts_step;
  end
 
  
  if count < max_for_direct
    % --- reasonably low count of potential sampling rates: use direct solution ---
    % 1) will build list of candidate sampling period Ts
    % 2) will test all candidate integration times for each Ts
      
    % build list of candidate sampling rates:
    if is_equ_fs
      % equidistant fs step mode (DDS clocked):  
      
      % build list of candidate sampling rates
      N_max = floor(1/fs_min*fs_step);     
      N_min = ceil(1/fs_max*fs_step);
      Ts_list = 1./([N_max:-1:N_min].'/fs_step);    
      
    else
      % equidistant Ts step mode (3458A timer clock, 5922 card internal clock, ...):
      
      % build list of candidate sampling rates
      N_max = floor(1/fs_min/Ts_step);     
      N_min = ceil(1/fs_max/Ts_step);
      Ts_list = [N_max:-1:N_min].'*Ts_step;
      
    end
    % count of the Ts candidates
    TN = numel(Ts_list);
    
    
    % --- for each candidate sampling rate: 
    for p = 1:TN
    
      % find possible range of T0:Ts ratios
      Q = round(t_range/Ts_list(p));
      
      % integration times candidates [s]
      t_set = Q*Ts_list(p);
      
      % residues of the 'candidate time':'Ts' (must be zero for coherent setup)
      res = abs(rem(t_set/T0 + 0.5,1) - 0.5);
      min(res)
      
      % find first coherent candidate
      cid = find(res < max_err,1);
      
      if numel(cid)
        % coherent setup found
        
        % return coherent setup:
        fs_out = 1/Ts_list(p);
        N_out = round(t_range(cid)*fs_out);
        
        break;
        
      elseif toc() > timeout
        % leave if timeout reached
        break; 
      end
    
    end
    
  else
  
    % --- fine fs/Ts step -> too much possible sampling rates -> inverse solution: ---
    % 1) find candidate sampling rates (or periods)
    % 2) select suitable candidate
       
    % generate sampling rate candidate ranges 
    N_min = ceil(t_range*fs_min);
    N_max = floor(t_range*fs_max);
    
    % total sampling rate candidates per integration time candidate 
    N_counts = N_max - N_min;
    
    % divide all possible candidates to groups of finite size
    % this will be used to split the calculation in segments, so timeout can be implemented
    groups = unique([find(diff(rem(cumsum(N_counts),3e6)) <=0) numel(N_counts)]);
    G = numel(groups);
       
    pid = [];
    cid = [];  
    if is_equ_fs
      % --- equidistant fs step mode (DDS clocked)
        
      % for each group of integration times:
      ga = 1;    
      for g = 1:G 
      
        % for each candidate integration time:
        for p = ga:groups(g)
          % generate list of candidate Ts
          fs_cand = [N_min(p):N_max(p)]/t_range(p);
          
          % residues of the candidate to step ratios (must be zero for coherent setup)
          rt = fs_cand./fs_step;
          res = abs(rem(rt + 0.5,1) - 0.5);
    
          % look for coherents
          id = find(res < max_err,1);
          if numel(id)
            pid(end + 1) = fs_cand(id);
            cid(end + 1) = p; 
          end
          
        end
        % move to next segment
        ga = groups(g);
        
        if toc() > timeout
          % leave if timeout reached
          break;
        end
        
      end
    
    else
      % --- equidistant Ts step mode (3458A timer clock, 5922 card internal clock, ...)
    
      % for each group of integration times:
      ga = 1;    
      for g = 1:G 
    
        % for each candidate integration time:
        for p = ga:groups(g)
          % generate list of candidate Ts
          Ts_cand = t_range(p)./[N_min(p):N_max(p)];
          
          % residues of the candidate to step ratios (must be zero for coherent setup)
          rt = Ts_cand./Ts_step; 
          res = abs(rem(rt + 0.5,1) - 0.5);
              
          % look for coherents
          id = find(res < max_err,1);
          if numel(id)
            pid(end + 1) = 1/Ts_cand(id);
            cid(end + 1) = p; 
          end
          
        end
        % move to next segment
        ga = groups(g);
              
        if toc() > timeout
          % leave if timeout reached
          break;
        end
        
      end
            
    end
     
    
    % select candidate?
    if numel(pid)
      % ok, something found
      
      % look for coherent setup with minimum sampling rate
      [v,id] = min(pid);
      
      % return coherent setup:
      fs_out = v;
      N_out = round(t_range(cid(id))*fs_out);
      
    end 
       
  end
  
  if ~exist('fs_out','var') && toc() > timeout
    error('TWM: No coherent setup found within the timeout!');
  elseif ~exist('fs_out','var')
    error('TWM: No coherent setup found!');    
  end
  
  % fundamental periods count [-]
  P = N_out/fs_out/T0;
  
  % coherent setup error [-]
  err = abs(rem(P + 0.5,1) - 0.5);

end