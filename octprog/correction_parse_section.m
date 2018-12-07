%% -----------------------------------------------------------------------------
%% TracePQM: Parser of the digitizer correction.
%%
%% Note: INVALID - OLD VERSION, WILL BE FIXED
%% -----------------------------------------------------------------------------
function [data] = correction_parse_section(root_path, inf, meas_inf, correction_name, table_cfg, channel_id, rep_id, group_id)
% root_path           - correction root folder
% inf                 - correction info file
% meas_inf            - measurements info file
% correction_name     - correction section name in the 'inf'
% channel_id          - is of the virtual channel for which the correction is being loaded
% rep_id              - measurement repetition id
% group_id              - measurement group id
% table_cfg           - configuration of the output table (structure)
%  .primary_ax  - name of the primary dependence axis (rows)
%  .second_ax   - name of the secondary dependence axis (columns)
%  .quant_names - list of quantities that are expected to be loaded from the tables
%
% Note: If the correction data are not CSV files, the 'table_cfg' will be used
% to create a fake table where 'value' of the correction will be placed to 'quant_names{1}',
% and 'uncertainty' will be placed to 'quant_names{2}'.
% If the correction data are not scalar, then the returned table will have fake axes [1,2,3,...].
%
  
  % default optional parameters
  if ~exist('group_id','var')
    group_id = 0;
  end
  if ~exist('rep_id','var')
    rep_id = 0;
  end
  if ~exist('channel_id','var')
    channel_id = 1;
  end
  
  % the section is optional?
  is_optional = isfield(table_cfg,'default');
  
  if group_id < 1
    % work with last available group, if not defined explicitly
    group_id = infogetnumber(meas_inf,'groups count');
  end
  % measurement group section name in the meas. file
  group_sec_name = ['measurement group ' num2str(group_id,0)];
  
  if ~rep_id
    % work with last available repetition cycle, if not defined explicitly
    rep_id = infogetnumber(meas_inf,'repetitions count',{group_sec_name});
  end

  % merge selected measurement group INFO section with global meas. INFO file for easier search
  group_sec = infogetsection(meas_inf,group_sec_name);
  meas_inf = infosetsection(group_sec,meas_inf,{});
  

  % get this correction's section from correction file header 
  try
    cinf = infogetsection(inf, correction_name);
  catch
    % section not found, but it may be optional correction
    
    if is_optional
      % is optional, build default result
      
      % generate main axis
      if isfield(table_cfg,'primary_ax')
        primary_ax = table_cfg.primary_ax;
      else
        primary_ax = '';
      end     
      % generate secondary axis
      if isfield(table_cfg,'second_ax')
        second_ax = table_cfg.second_ax;
      else
        second_ax = '';
      end
      csv_quantities = {primary_ax,table_cfg.quant_names{:}};
      % build the default table
      data = correction_load_table(table_cfg.default,second_ax,csv_quantities);
      
      return
      
    else
      error(sprintf('Correction parser: Correction ''%s'' not found!',correction_name));
    end
    
  end
  
  % try get list of the filter attributes
  try    
    attr_filter = infogettextmatrix(cinf,'valid for attributes');    
    if numel(attr_filter) && ~numel(attr_filter{1})
      attr_filter = {};
    end    
  catch
    attr_filter = {};    
  end
  
  % --- read and apply attribute filter ---
  % for each attribute in the filter:
  for a = 1:numel(attr_filter)
  
    % current attribute name
    attr_name = attr_filter{a,1};
    
    % try to fetch attribute's value from the measurement header
    % there must be a key of the same name otherwise user requests filtering by non-existent attribute
    try     
      % is matrix? in that case it is most likely channel dependent attribute
      attr_meas_value = infogettextmatrix(meas_inf, attr_name);
    catch
      % is no matrix, may be scalar?
      attr_meas_value = infogettext(meas_inf, attr_name);
      % if it failes it is not found in the measurement file, therefore we are outahere - error      
    end
    
    if iscell(attr_meas_value)
      % meas. header attribute's value is matrix, we have to select the item of the matrix for filtering
      
      % first, select column:
      if size(attr_meas_value,2) == 1 && channel_id > 1 
        % attribute X-dim too small for desired channel id 
        %  - it seems it is channel independent attribute despite it was stored as a matrix            
        attr_meas_value = attr_meas_value(:,1);
      elseif channel_id <= size(attr_meas_value,2)
        % channel dependent attribute - select channel (column of the matrix)
        attr_meas_value = attr_meas_value(:,channel_id);
      else
        error(sprintf('Correction parser: Filter attribute ''%s'' of correction ''%s'' has smaller columns count the requested correction channel id!',attr_name,correction_name));
      end
      % at this point we should have either scalar or vertical vector...
      
      % now, select row:
      if size(attr_meas_value,1) == 1
        % we have scalar, get rid of cell array around it
        attr_meas_value = attr_meas_value{1};
      elseif rep_id <= size(attr_meas_value,1)
        % the attribute has more than one row
        %  - most likely one row for each repetition
        attr_meas_value = attr_meas_value{rep_id};
      else
        error(sprintf('Correction parser: Filter attribute ''%s'' of correction ''%s'' has smaller rows count than requested by repetition id parameter! Possibly inconsistent measurement INFO file.',attr_name,correction_name));        
      end            
    end
    % at this point we shall have value of the attribute from meas. header loaded and it is scalar...
       
    
    % fetch allowed values of the filter attribute from correction section
    attr_values = infogettextmatrix(cinf, attr_name);
    
    % check if there is match:
    if ~correction_compare_attributes(attr_meas_value,attr_values)
      % nope, this correction section is not applicable for the given meas. header
      error(sprintf('Correction parser: Value of attribute ''%s'' in the correction ''%s'' does not match with measurement data!',attr_name,correction_name));
    end
    
  end  
  % ... we are here, so apparently all attribute filters matched
  
  

  % --- now read correction dependencies ---
  % i.e. each correction can depend on up to two parameters: primary (vertical axis), secondary (horizontal axis)
  % so if the correction data are matrix, the primary parameter will select/interpolate it to a single row
  % and secondary parameter will select/interpolate it to a scalar
  % but in this stage, just loading the parameters
  % note: loading the primary and secondary parameter in the loop to get rid of duplicity in the code
   
  % list of dependency parameters (axes of dependence)
  par = {};
  % list of parameter names (info section names)
  par_name_list = {'primary parameter';'secondary parameter'};
    
  for p = 1:numel(par_name_list)
    
    % parameter's INFO section name (primary or secondary)
    par_name = par_name_list{p};
        
    % try to fetch parameter of the dependence from correction section
    try      
      % get section for the parameter
      pinf = infogetsection(cinf,par_name);
    catch
      % section does not exist - parameter not used
      par{p}.name = '';
      continue        
    end
    
      % get name of the parameter (mandatory)
      par{p}.name = infogettext(pinf,'name');
      
      % is the parameter interpolable (optional)? 
      try
        par{p}.interp = infogetnumber(pinf,'interpolable');
      catch
        % default - nope
        par{p}.interp = 0;     
      end
      
      % try to load listed values of the parameter (mandatory)
      par{p}.values = infogettextmatrix(pinf,'value');

      % try to convert the values to numeric
      try
        num_values = num2cell(cellfun(@str2num,par{p}.values));        
        par{p}.is_numeric = 1;
      catch
        % failed, so the values are considered as string types 
        par{p}.is_numeric = 0;        
      end
      
      if par{p}.interp && ~par{p}.is_numeric
        % failed - interpolate enabled but parameter values not numeric???
        error(sprintf('Correction parser: %s dependence ''%s'' of correction ''%s'' is not numeric, but ''interpolable'' flag is set!',par_name,par{p}.name,correction_name));
      end 
      
      % try to fetch the parameter's value from the measurement header
      % if it's not there, then the correction is not usable for the meas. header
      try
        % channel dependent parameter? (i.e. matrix?)
        par{p}.meas_value = infogettextmatrix(meas_inf, par{p}.name);
      catch
        % nope - so is it scalar parameter?
        par{p}.meas_value = infogettext(meas_inf, par{p}.name);
        % if it failed here the parameter is not there and we are outahere, because something is wrong with the correction data or meas. header...
      end
      
      if iscell(par{p}.meas_value)
        % the parameter's value in the meas. header was found, but it is matrix
        % we have to select the matrix item by channel and repetition id
      
        % first, select column by channel:
        if size(par{p}.meas_value,2) == 1 && channel_id > 1 
          % parameter's matrix X-dim too small for desired channel id 
          %  - possibly it is channel independent parameter afterall, but for some reason it is stored as a matrix             
          par{p}.meas_value = par{p}.meas_value(:,1);
        elseif channel_id <= size(par{p}.meas_value,2)
          % channel dependent parameter - select channel
          par{p}.meas_value = par{p}.meas_value(:,channel_id);
        else
          error(sprintf('Correction parser: %s dependence ''%s'' of correction ''%s'' has smaller columns count than id of desired channel!',par_name,par{p}.name,correction_name));
        end
        
        % next, select row by repetition cycle
        if size(par{p}.meas_value,1) == 1
          % param. has just one item, get rid of cell array
          par{p}.meas_value = par{p}.meas_value{1};
        elseif rep_id <= size(par{p}.meas_value,1)
          % parameter has more rows:
          %  - most likely one row per repetition cycle, select repetition
          par{p}.meas_value = par{p}.meas_value{rep_id};
        else
          error(sprintf('Correction parser: %s dependence ''%s'' of correction ''%s'' has smaller rows count than id of desired repetition! Most likely inconsistent data in the measurement header.',par_name,par{p}.name,correction_name));
        end
        
      end
      
      % try to convert meas. header value of the parameter to numeric
      meas_num = str2num(par{p}.meas_value);
      if numel(meas_num) && par{p}.is_numeric
        % success, both parameter values and meas. header value are numerics, change data type to numeric
        par{p}.meas_value = meas_num;
        par{p}.values = num_values;
      else
        % failed, either parameter values or meas. header values are not numeric, assume they are all text
        par{p}.is_numeric = 0;
      end     

    
  end  
  if ~numel(par{1}.name) && numel(par{2}.name)
    error(sprintf('Correction parser: Missing primary dependence while secondary is present for the correction ''%s''!',correction_name));
  end


  % try to read the matrix with the correction data values
  values = infogettextmatrix(cinf, 'value');
  
  % try to read the matrix with the uncertainties
  try
    uncerts = infogettextmatrix(cinf, 'uncertainty');
    has_unc = 1;
  catch
    % not exist, do nothing as it is optional
    has_unc = 0; 
  end
  
  if has_unc && any(size(values) ~= size(uncerts))
    % sizes of value and uncertainty matrix does not match
    error(sprintf('Correction parser: Size of value and uncertainty matrix for correction ''%s'' does not match!',correction_name));
  end
  
   
  
  % are the 'values' CSV files or numeric data?
  try 
    % try to convert values to numeric
    values_num = reshape(cellfun(@str2num,values(:)),size(values));
    
    % try to convert uncertainties as well
    if has_unc
      uncerts = reshape(cellfun(@str2num,uncerts(:)),size(uncerts));
    end
    
    % so far no error - values are numeric
    values = values_num;
    is_csv = 0;
      
  catch
    % conversion failed, so clearly the values were CSV files (or some other rubbish)
    is_csv = 1;    
  end
  

  if is_csv
    % --- 'value' is matrix of CSV files with 1D or 2D dependencies
    
    % build initial interpolation/selection weights
    % one item for each cell of the 'value' matrix
    w = ones(size(values));
    
    if numel(par{1}.name)
      % primary dependence present
      
      % interpolate/select by primary parameter
      [values, w] = correction_interp_parameter(values, w, par{1}, 1, correction_name);
    
    end
        
    if numel(par{2}.name)
      % secondary parameter present
      
      % interpolate/select by secondary parameter
      [values, w] = correction_interp_parameter(values, w, par{2}, 2, correction_name);
            
    end    
    % at this point the 'w' matrix should contain non-zero values for
    % CSV files that will be used for interpolation/selection
    
        
    % build full paths of the CSV files with the correction data
    values = strcat([root_path filesep()], values);
    
    % interpolate the CSV files
    data = correction_interp_parameter_csv(values, w, table_cfg, correction_name);
        
      
    
  else
    % --- 'value' is matrix of numerics
                                                          
    if numel(par{1}.name)
      % primary dependence present
      
      % interpolate/select by primary parameter
      values = correction_interp_parameter(values, [], par{1}, 1, correction_name);
      if has_unc
        uncerts = correction_interp_parameter(uncerts, [], par{1}, 1, correction_name);
      end
      
    end
        
    if numel(par{2}.name)
      % secondary parameter present
      
      % interpolate/select by secondary parameter
      values = correction_interp_parameter(values, [], par{2}, 2, correction_name);
      if has_unc
        uncerts = correction_interp_parameter(uncerts, [], par{2}, 1, correction_name);
      end
            
    end
    
    if has_unc && numel(table_cfg.quant_names) ~= 2
      error(sprintf('Correction parser: Output table configuration does not match correction data for correction ''%s''! If there is ''value'' and ''uncertainty'' in the correction section, the ''table_cfg'' must contain two quantities.',correction_name)); 
    end
    
    csv = {};
    % generate main axis
    if isfield(table_cfg,'primary_ax')
      primary_ax = table_cfg.primary_ax;
    else
      primary_ax = '';
    end
    if size(values,1) > 1
      csv{end+1} = [1:size(values,1)].';
    elseif ~isempty(primary_ax)
      csv{end+1} = []; 
    end
     
    % generate secondary axis
    if isfield(table_cfg,'second_ax')
      second_ax = table_cfg.second_ax;
    else
      second_ax = '';
    end
    if size(values,2) > 1 && ~isempty(second_ax)
      csv{end+1} = [1:size(values,2)];       
    elseif  ~isempty(second_ax)
      csv{end+1} = [];
    elseif size(values,2) > 1
      error(sprintf('Correction parser: Output table configuration does not contain secondary axis but correction data for correction ''%s'' have more than one column! Inconsitent correction data.',correction_name));    
    end
    % insert data and uncertainty
    csv{end+1} = values;
    % insert uncertainty data
    if has_unc
      csv{end+1} = uncerts;
    end
    csv_quantities = {primary_ax,table_cfg.quant_names{:}};

        
    % generate the table with values and uncertainties
    data = correction_load_table(csv,second_ax,csv_quantities);
  
  end
 
end