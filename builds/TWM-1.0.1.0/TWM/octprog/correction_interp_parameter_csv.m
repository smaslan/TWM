%% -----------------------------------------------------------------------------
%% TracePQM: Parser of the digitizer correction CSV data.
%%
%% Note: INVALID - OLD VERSION, WILL BE FIXED
%% -----------------------------------------------------------------------------
function [data] = correction_interp_parameter_csv(files, w, is_scalar, correction_name, N)

  % default number of x-points for reinterpolation 
  if nargin < 5
    N = 10000;
  end
  
  % get rid of elements with zero weights
  for k = size(w,1)
    if any(w(k,:) ~= 0)
      w_tmp(k,:) = w(k,:);
      files_tmp(k,:) = files(k,:);
    end
  end
  for k = size(w_tmp,2)
    if any(w_tmp(:,k) ~= 0)
      w(:,k) = w_tmp(:,k);
      files(:,k) = files_tmp(:,k);
    end
  end
  
  % load and parse the CSV files
  file = {};
  for m = size(files,1)
    for n = size(files,2)
      % try to read the numeric portion of the CSV file
      csv = dlmread(files{m,n},';',[4 0]);
      % TODO: some format validity checking???
      
      % parse the file
      file{m,n}.x = csv(:,1);
      file{m,n}.y = csv(:,2:end);           
    end
  end
    
  if is_scalar
    % --- there should be only up to 4 non-zero weights from which the result must be interpolated ---
    
    % find common range of x-values from the correction related CSV files
    max_x = min(cellfun('max',{file{:}.x}));
    min_x = max(cellfun('min',{file{:}.x}));
    
    % reinterpolate all CSVs to the new common x-series in the common range for all CSVs
    % assume logarithmic displacement of the new x-series (both freq. and ampl. dep should be logscale)
    x_new =logspace(log10(min_x),log10(max_x),N);    
    for m = size(file,1)
      for n = size(file,2)
        file{m,n}.y = interp1(file{m,n}.x,file{m,n}.y,x_new,'extrap');
        file{m,n}.x = x_new;
      end
    end         
    
    if size(w,1) > 2 || file(w,2) > 2
      error(sprintf('Correction parser: Interpolation/selection of items of correction ''%s'' failed! This should never happen so if it did, the function correction_interp_paramter() somehow failed at generating interpolation weights.',correction_name));
    end
    
    if size(w) == [1 1]
      % just one CSV file - easy pie, select one...
      data = file;
    elseif size(w,1) == 1 || size(w,2) == 1
      % just two items - interpolate in 1D
      data.x = file{1}.x
      data.y = file{1}.y*w{1} + file{2}.y*w{2};      
    else
      % four items - interpolate in 2D
      data.x = file{1}.x
      data.y = file{1,1}.y*w{1,1} + file{2,1}.y*w{2,1} + file{2,1}.y*w{2,1} + file{2,2}.y*w{2,2};
    end
  
  else
    % --- nonscalar mode: interpolate per columns ---
    
    if size(w,1) > 2
      error(sprintf('Correction parser: Interpolation/selection of items of correction ''%s'' failed! This should never happen so if it did, the function correction_interp_paramter() somehow failed at generating interpolation weights.',correction_name));
    end
    
    for n = 1:size(w,2)
      % --- for each column ---
      
      % find common range of x-values from the correction related CSV files
      max_x = min(max(file{1,n}.x),max(file{2,n}.x));
      min_x = max(min(file{1,n}.x),min(file{2,n}.x));
      
      % reinterpolate all CSVs to the new common x-series in the common range for all CSVs
      % assume logarithmic displacement of the new x-series (both freq. and ampl. dep should be logscale)
      x_new =logspace(log10(min_x),log10(max_x),N);    
      for m = size(file,1)
        file{m,n}.y = interp1(file{m,n}.x,file{m,n}.y,x_new,'extrap');
        file{m,n}.x = x_new;
      end
      
      if size(w,1) == 1
         % just one CSV file - easy pie, select one...
         data = file{m,n};
      else
        % just two items - interpolate in 1D
        data.x = file{1,n}.x
        data.y = file{1,n}.y*w{1,n} + file{2,n}.y*w{2,n};      
      else         
    
    end
    
  end
  
end
