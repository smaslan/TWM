function [txt, desc, var_names, chn_index, num] = qwtb_get_results(meas_root, res_id, alg_id, cfg, var_list)
% TracePQM: Get result from measurement folder. This function will read one
% or more results, perform averaging if requested and formats the values
% to the CSV table string that will be returned. 
%
%   inputs:
%     meas_root - root folder of the measurement
%     res_id - order index of the result for selected algorithm:
%               -1: last calculated result
%               0:  average all results
%               >0: single result by index
%     alg_id - algorithm's ID ('PSFE', 'SP-FFT', ...) or empty string for
%              loading last calculated algorithm 
%     cfg - confiuration structure (all elements are optional):
%           cfg.max_dim - maximum displayable dimension of variable
%                          0: only scalars
%                          1: scalars, vectors
%                          2: scalars, vectors, matrices
%           cfg.max_array - maximum array elements to be displayed
%                           if exeeded, function will write 'graph' insted of
%                           the values into the results table
%           cfg.unc_mode - uncertainty display mode:
%                           0: display none
%                           1: value ± uncertainty
%                           2: alternate rows: 1. row values, 2. row uncertainty
%           cfg.group_mode - ordering of the variables and phases/channels:
%                             0 - group all phases for each variable together
%                             1 - group all variables for each phase together                             
%           cfg.phi_mode - display mode of the phase:
%                           0 - +-pi [rad]
%                           1 - 0 - 2*pi [rad]
%                           2 - +-180 [deg]
%                           3 - 0-360 [deg]
%           cfg.amp_mode - real number for scaling amplitudes or 'dB', 'dBmV' or 'dBuV'
%           cfg.phi_ref_chn - reference channel ID for phase difference calculation
%
%     var_list - cell array with names of the variables to load.
%                If empty, loads all variables.
%
%   outputs:
%     txt - formatted CSV table data for displaying
%     desc - CSV table data with descriptions of 'txt' table rows
%     var_names - CSV table data with names of the quantities of 'txt' table 
%     chn_index - channel/phase index for each row of 'txt' table
%     num - matrix corresponding to txt matrix with numeric data
%           invalids are returned as NaNs
%
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2018-2022, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
%


    if ~exist('cfg','var') || ~isstruct(cfg)
        % --- default configuration
        cfg = struct();   
    end
    if ~exist('var_list','var') || ~iscell(var_list)
        % --- load all variables if no list supplied
        var_list = {};
    end
    
    % --- default values of configuration  
    if ~isfield(cfg,'max_dim')
        % maximum dimension of the variables to display 
        cfg.max_dim = 1;  
    end
    if ~isfield(cfg,'group_mode')
        % group mode of the quantities (0: group phases, 1: group quantities)
        cfg.group_mode = 0;
    end
    if ~isfield(cfg,'unc_mode')
        % uncertainty mode (0: none, 1: plusminus, 2: alternate (qunat1, unc1, qunat2, unc2))
        cfg.unc_mode = 0;
    end
    if ~isfield(cfg,'max_array')
        % maximum array size for displaying
        cfg.max_array = 50;
    end
    if ~isfield(cfg,'phi_mode')
        % default phase display mode
        cfg.phi_mode = 0;
    end
    if ~isfield(cfg,'amp_mode')
        % default amplitude scaling
        cfg.amp_mode = 1.0;
    end
            
    
    % --- load and process results
    [results, avg, unca, res_id, are_scalar, is_avg] = qwtb_load_results(meas_root, res_id, alg_id, cfg, var_list);
    %[results, avg, unca, res_id, are_scalar, is_avg] = qwtb_load_results(meas_root, res_id, alg_id, cfg);
    
%     size(results)
%     size(avg)
      
  
    res = results{1};
    % counts: [phases/channels, variables]
    R = numel(results);
    C = numel(res);
    V = numel(res{1});
    E = [numel(res) numel(res{1})];
    if cfg.group_mode
        E = fliplr(E);
    end
  
  
  
  
  

    % numeric output
    num = [];
    % text matrix output
    csv = {};
    row = 1;
    
        
    % write header of the result table
    if are_scalar
        % scalar variable: write [average, unc. A, readings]
        
        csv{row,2} = 'avg';
        csv{row,3} = 'ua';
        num(row,2) = NaN;
        num(row,3) = NaN;
        for r = 1:R
            csv{row,r+3} = sprintf('#%d',r);
            num(row,r+3) = NaN;
        end
  
    end
    row = row + 1;
  
   
    % --- for each phase/channel and each variable
    desc = {};
    var_names = {};
    chn_index = [];
    for e1 = 1:E(1)
        for e2 = 1:E(2)
            % pick variable and phase/channel
            if cfg.group_mode
                p = e2; v = e1;
            else
                p = e1; v = e2;
            end
            
            ref = results{1}{p}{v};
            
            % build variable size info string
            if ref.is_string
                sstr = ' (string)';
            elseif ref.dims == 0
                sstr = ' (scalar)';
            elseif ref.dims == 1
                sstr = sprintf(' (vector of %d items)',prod(ref.size));
            else
                sstr = sprintf(' (matrix of size %dx%d)',ref.size(1),ref.size(2));
            end
                       
            % build variable name
            if C > 1
                var_name = sprintf('%s[%s]', ref.name, ref.tag); % 'variable_name[phase_name/channel_name]'
            else
                var_name = sprintf('%s', ref.name); % 'variable_name' only for single channel/phase to make it readable 
            end
            var_unc = sprintf('U(%s)', var_name);
            % build variable description
            full_var_desc = sprintf('%s of channel/phase %s%s',ref.desc,ref.tag,sstr);
            full_unc_desc = sprintf('Uncertainty of %s',full_var_desc);
            
            % store variable name and phase/channel index
            var_names{end+1} = ref.name;
            chn_index(end+1) = p;
            
            % write variable row headers
            col = 1;
            csv{row,col} = var_name;
            num(row,col) = NaN;
            desc{end+1} = full_var_desc;
            if cfg.unc_mode == 2 && ~ref.is_string
                csv{row+1,col} = var_unc;
                num(row+1,col) = NaN;
                desc{end+1} = full_unc_desc;
                % store variable name and phase/channel index
                var_names{end+1} = ref.name;
                chn_index(end+1) = p;
            end      
            col = col + 1;
                
            if are_scalar
                % scalar variable: write [average, unc. A, readings]
                %  also includes strings!
                
                if numel(avg{p}{v}.val) || ref.is_string
                
                    % write average
                    if ref.is_string
                        csv{row,col} = ref.val;
                        num(row,col) = NaN;                        
                    else 
                        [vc,vv,vu,vs, numv,numu] = qwtb_result_unc2str(avg{p}{v},[],cfg);        
                        if cfg.unc_mode == 0
                            csv{row,col} = [vv vs];
                            num(row,col) = numv;
                        elseif cfg.unc_mode == 1
                            csv{row,col} = vc;
                            num(row,col) = numv;
                        else
                            csv{row+0,col} = [vv vs];
                            csv{row+1,col} = [vu vs];
                            num(row+0,col) = numv;
                            if ~isempty(avg{p}{v}.unc)
                                num(row+1,col) = numu;
                            else
                                num(row+1,col) = NaN;
                            end
                        end
                    end
                    col = col + 1;
                    
                    % write unc. A                
                    if ref.is_string
                        csv{row,col} = '';
                        num(row,col) = NaN;                        
                    else
                        if avg{p}{v}.is_amplitude && ischar(cfg.amp_mode) 
                            % for dBx modes only
                            val = avg{p}{v};                        
                            val.unc = unca{p}{v}.val;
                            val.min_unc_abs = 0; 
                            val.min_unc_rel = 0;
                            val.num_format = 'f';
                            [vc,vv,vu,vs, numv,numu] = qwtb_result_unc2str(val,[],cfg);
                            csv{row,col} = [vu vs];
                            num(row,col) = numu;
                        else
                            % for all other numerics            
                            val = unca{p}{v};                        
                            val.unc = unca{p}{v}.val;
                            val.min_unc_abs = 0; 
                            val.min_unc_rel = 0;
                            [vc,vv,vu,vs, numv,numu] = qwtb_result_unc2str(val,[],cfg);
                            csv{row,col} = [vu vs];
                            num(row,col) = numu;
                            %[vc,vv,vu,vs, numv,numu] = qwtb_result_unc2str(unca{p}{v},[],cfg);        
                            %csv{row,col} = [vv vs];
                            %num(row,col) = numv;
                        end                                                
                    end
                    col = col + 1;
                    
                    % write readings
                    for r = 1:R
                    
                        if ref.is_string
                            csv{row,col} = results{r}{p}{v}.val;
                            num(row,col) = NaN;                            
                        else
                            [vc,vv,vu,vs, numv,numu] = qwtb_result_unc2str(results{r}{p}{v},[],cfg);        
                            if cfg.unc_mode == 0
                                csv{row,col} = [vv vs];
                                num(row,col) = numv;
                            elseif cfg.unc_mode == 1
                                csv{row,col} = vc;
                                num(row,col) = NaN;
                            else
                                csv{row+0,col} = [vv vs];
                                csv{row+1,col} = [vu vs];
                                num(row+0,col) = numv;
                                if ~isempty(results{r}{p}{v}.unc)
                                    num(row+1,col) = numu;
                                else
                                    num(row+1,col) = NaN;
                                end
                            end
                        end
                        col = col + 1;
                      
                    end
                
                else
                  % empty variable or big variable that cannot be displayed
                  csv{row,col} = 'only graph';
                  num(row,col) = NaN;
                  col = col + 1;           
                
                end
    
            else
                % non-scalar: write full variable
                
                if ref.is_big && ~ref.is_string
                    % variable too big - write just info, that it is too big
                    csv{row,col} = 'only graph';
                    num(row,col) = NaN;
                    col = col + 1;
                  
                else
                    % variable is not big - write full variable
                    
                    if ref.dims > 1
                        % 2D variable - not supported yet
                        csv{row,col} = '2D not supported';
                        num(row,col) = NaN;
                        col = col + 1;
                    else
                        % scalar or 1D: write full value
            
                        % select source: average or reading
                        if is_avg
                            data = avg{p}{v};
                        else
                            data = results{res_id}{p}{v};
                        end
                        
                        % write variable data
                        for k = 1:prod(data.size)
                        
                            csv{1,k + 1} = sprintf('item %d',k);
                            num(1,k + 1) = NaN;
                                                    
                            if ref.is_string
                                if k == 1
                                    csv{row,col} = results{res_id}{p}{v}.val;
                                else
                                    csv{row,col} = '';
                                end
                                num(row,col) = NaN;                                
                            else
                                [vc,vv,vu,vs, numv,numu] = qwtb_result_unc2str(data,k,cfg);        
                                if cfg.unc_mode == 0
                                    csv{row,col} = [vv vs];
                                    num(row,col) = numv;
                                elseif cfg.unc_mode == 1
                                    csv{row,col} = vc;
                                    num(row,col) = NaN;
                                else
                                    csv{row+0,col} = [vv vs];
                                    csv{row+1,col} = [vu vs];
                                    num(row+0,col) = numv;
                                    if ~isempty(data.unc)
                                        num(row+1,col) = numu;
                                    else
                                        num(row+1,col) = NaN;
                                    end
                                end
                            end
                            col = col + 1;                 
                         
                        end
                      
                    end
                                 
                end
                   
            end
          
            % move to next row
            row = row + 1;
            if cfg.unc_mode == 2 && ~ref.is_string
                row = row + 1;
            end  
               
        end
      
    end
    
    % fill in rest of the numeric output by NaNs
    %  ###todo: optimize maybe? 
    for r = 1:size(csv,1)
        for c = 1:size(csv,2)
            if isempty(csv{r,c})
                num(r,c) = NaN;
            end
        end
    end
        
    % --- convert results table to CSV data ---
    txt = char(catcellcsv(csv));
    
    % --- convert table descriptions to CSV data ---
    desc = char(catcellcsv(desc(:)'));
  
    % --- convert returned variable names to CSV data ---
    var_names = char(catcellcsv(var_names(:)'));
    
end