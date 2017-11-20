%% -----------------------------------------------------------------------------
%% TracePQM: Parser of the digitizer correction.
%%
%% Note: INVALID - OLD VERSION, WILL BE FIXED
%% -----------------------------------------------------------------------------
function [] = correction_parse_section(root_path, inf, meas_inf, correction_name, channel_id)
  
  if nargin < 5
    channel_id = 1;
  end
  
  % get correction section from header 
  cinf = infogetsection(inf, correction_name);
  
  % try get list of filter attributes
  try    
    attr_filter = infogetmatrixstr(cinf,'valid for attributes');    
    if numel(attr_filter) && ~numel(attr_filter{1})
      attr_filter = {};
    end    
  catch
    attr_filter = {};    
  end
  
  % --- read and apply attribute filter ---
  for a = 1:numel(attr_filter)
  
    % current attribute name
    attr_name = attr_filter{a,1};
    
    % try to fetch attribute value from the measurement file
    try     
      % is matrix? in that case it is most likely channel dependent attribute
      attr_meas_value = infogetmatrixstr(meas_inf, attr_name);
      attr_channel_type = 1;
    catch
      % is no matrix, may scalar?
      attr_meas_value = infogettext(meas_inf, attr_name);
      attr_channel_type = 0;
      % if it failes it is not found in the measurement file, therefore we are outahere      
    end
    
    if attr_channel_type
      if size(attr_meas_value,2) == 1 && channel_id > 1 
        % attribute X-dim too small for desired channel id 
        %  - possibly it is channel independent attribute afterall             
        attr_meas_value = attr_meas_value{1,1};
      elseif channel_id <= size(attr_meas_value,2)
        % channel dependent attribute - select channel
        attr_meas_value = attr_meas_value{1,channel_id};
      else
        error('Correction parser: Filter attribute ''%s'' of correction ''%s'' has smaller columns count the requested correction channel id!',attr_name,correction_name);
      end
    end
    
    % fetch allowed values of the filter attribute
    attr_values = infogetmatrixstr(cinf, attr_name);
    
    if ~correction_compare_attributes(attr_meas_value,attr_values)
      error(sprintf('Correction parser: Value of attribute ''%s'' in the correction ''%s'' does not match with measurement data!',attr_name,correction_name));
    end
    
  end  
  % ... we are here, so apparently all attribute filters matched.
  
  

  % --- now read correction dependencies ---
  % note: loading the primary and secondary parameter in the loop to get rid of duplicity in the code
   
  % list of parameters
  par = {};
  % list of parameter prefixes in the correction file
  par_name_list = {'primary';'secondary'};
    
  for p = 1:numel(par_name_list)
    
    % parameter prefix (primary or secondary)
    par_name = par_name_list{p};
  
    % try to fetch parameter of the dependence from correction section
    try
      % get name of the parameter
      par{p}.name = infogettext(cinf,[par_name ' parameter']);
      
      % is the parameter interpolable? 
      try
        par{p}.interp = infogetnumber(cinf,[par_name ' is interpolable']);
      catch
        % default - nope
        par{p}.interp = 0;     
      end
      
      % try to load listed values of the parameter
      if numel(par{p}.name) 
        par{p}.values = infogetmatrixstr(cinf,par{p}.name);
      end
      
      % try to fetch the parameter's value from the measurement header
      if numel(par{p}.name)
      
        try
          % channel dependent parameter? (matrix?)
          par{p}.meas_value = infogetmatrixstr(meas_inf, par{p}.name);
          channel_type = 1;
        catch
          % nope - scalar parameter?
          par{p}.meas_value = infogettext(meas_inf, par{p}.name);
          channel_type = 0;
          % if it failed here the parameter is not there and we are outahere, because something is wrong with the correction...
        end     
            
      end
      
    catch
      % primary dependence not exit 
      par{p}.name = '';
      par{p}.interp = 0;
      par{p}.values = {};
      par{p}.meas_value = '';
    end
    
    if numel(par{p}.name) && channel_type
      % paramter was not scalar - possibly channel dependent?
      
      if size(par{p}.meas_value,2) == 1 && channel_id > 1 
        % parameter's matrix X-dim too small for desired channel id 
        %  - possibly it is channel independent parameter afterall             
        par{p}.meas_value = par{p}.meas_value{1,1};
      elseif channel_id <= size(par{p}.meas_value,2)
        % channel dependent parameter - select channel
        par{p}.meas_value = par{p}.meas_value{1,channel_id};
      else
        error('Correction parser: %s dependence parameter ''%s'' of correction ''%s'' has smaller columns count than id of desired channel!',par_name,par{p}.name,correction_name);
      end
      
    end
    
  end  
  if ~numel(par{1}.name) && numel(par{2}.name)
    error(sprintf('Correction parser: Missing primary dependence while secondary is present for the correction ''%s''!',correction_name));
  end
 


  % try to read the matrix with the correction data values
  values = infogetmatrixstr(cinf, correction_name);
  
  % are those values CSV files?
  try 
    % try to convert to numeric
    values_num = reshape(cellfun('str2num',values(:),'UniformOutput',false),size(values));
    
    % values were actually CSV files? 
    is_csv = ~all(cellfun('numel',values_num(:)));
    
    % replace the values matrix by its numeric conversion? 
    if ~is_csv
      values = values_num;
    end
      
  catch
    % conversion failed, so clearly the values were CSV files
    is_csv = 1;    
  end
  
  if is_csv
    % --- CSV
    
    % load values of the correction
    values = infogetmatrixstr(cinf, correction_name);
    
    % build initial interpolation/selection weights
    w = ones(size(values));
    
    if numel(par{1}.name)
      % primary dependence present
      
      % interpolate/select by primary parameter
      [values, w] = correction_interp_parameter(values, w, par{1}, 1, correction_name);
    
    end
        
    if numel(par{2}.name)
      % secondary parameter present and not vector
      
      % interpolate/select by secondary parameter
      [values, w] = correction_interp_parameter(values, w, par{2}, 2, correction_name);
            
    end
    
    % build full paths of the CSV files with the correction data
    values = strcat([root_path filesep()], values);
    
    correction_interp_parameter_csv(values, w, numel(par{2}.name))
        
    
    
  else
    % --- scalar or vector
    
    % load values of the correction
    values = infogetmatrix(cinf, correction_name);
    
    if numel(par{1}.name)
      % primary dependence present
      
      % interpolate/select by primary parameter
      values = correction_interp_parameter(values, [], par{1}, 1, correction_name);
    
    end
        
    if numel(par{2}.name)
      % secondary parameter present and not vector
      
      % interpolate/select by secondary parameter
      values = correction_interp_parameter(values, [], par{2}, 2, correction_name);
            
    end
  
  end
  
  values
  
  
  
  
  
  
  
end