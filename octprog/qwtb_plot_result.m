%% -----------------------------------------------------------------------------
% TracePQM: Plots result from measurement folder. This function will read one
% or more results, perform averaging if requested and plots the graph
% of the selected quantity.
% 
%   usage:
%     grp_setup = qwtb_plot_result(grp_setup)
%       - to refresh eventually existing plot using last setup returned last call
%       - ignores errors, cleansup grp_setup in case of error
%
%     grp_setup = qwtb_plot_result(meas_root, res_id, alg_id, chn_id, cfg, var_name, plot_cfg)
%       - to display new plot
%
%   inputs:
%     meas_root - root folder of the measurement
%    res_id - order index of the result for selected algorithm:
%               -1: last calculated result
%               0:  average all results
%               >0: single result by index
%     alg_id - algorithm's ID ('PSFE', 'SP-FFT', ...) or empty string for
%              loading last calculated algorithm
%     chn_id - index of channel/phase to display (0 to show all) 
%     cfg - confiuration structure (all elements are optional):
%           cfg.max_dim - maximum displayable dimension of variable
%                          0: only scalars
%                          1: scalars, vectors
%                          2: scalars, vectors, matrices
%           cfg.phi_mode - display mode of the phase:
%                           0 - +-pi [rad]
%                           1 - 0 - 2*pi [rad]
%                           2 - +-180 [deg]
%                           3 - 0-360 [deg]
%           cfg.amp_mode - scaling factor for amplitude quantities
%           cfg.phi_ref_chn - reference channel ID for phase difference calculation
%
%     plot_cfg - structure of plot setup:
%                plot_cfg.keep_update - allow update plot with next calls?
%                plot_cfg.xlog - is x logarithmic?                             
%                plot_cfg.ylog - is y logarithmic?
%                plot_cfg.box - show plot box?
%                plot_cfg.grid - show plot grid?
%                plot_cfg.legend - plot legend position, empty string to disable
%   outputs:
%     grp_setup - compact struct with last configuration and hRef to figure
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2018-2026, Stanislav Maslan, stanislav.maslan@cmi.gov.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.               
%% -----------------------------------------------------------------------------
function [grp_setup] = qwtb_plot_result(meas_root, res_id, alg_id, chn_id, cfg, var_name, plot_cfg)

    is_refresh = false;    
    if nargin == 1
        % load setup from struct
        grp_setup = meas_root;
        
        if ~isfield(grp_setup,'meas_root') || ~isfield(grp_setup,'alg_id') || ~isfield(grp_setup,'alg_id') || ~isfield(grp_setup,'chn_id') || ~isfield(grp_setup,'res_id') || ~isfield(grp_setup,'cfg') || ~isfield(grp_setup,'var_name') || ~isfield(grp_setup,'plot_cfg') || ~isfield(grp_setup,'fig_href')
            grp_setup = struct();
            return;
        end
        
        meas_root = grp_setup.meas_root;
        alg_id = grp_setup.alg_id;
        chn_id = grp_setup.chn_id;
        res_id = grp_setup.res_id;
        cfg = grp_setup.cfg;
        var_name = grp_setup.var_name;
        plot_cfg = grp_setup.plot_cfg;    
        is_refresh = true;
                
    elseif nargin ~= 7
        error('Wrong parameters count!');
    end
  
    if ~exist('cfg','var') || ~isstruct(cfg)
        % --- default configuration
        cfg = struct();   
    end
      
    % --- default values of configuration  
    if ~isfield(cfg,'max_dim')
        % maximum dimension of the variables to display 
        cfg.max_dim = 1;  
    end
    %if ~isfield(cfg,'max_array')
        % maximum array size for displaying
        cfg.max_array = 10e6;
    %end
    if ~isfield(cfg,'phi_mode')
        % default phase display mode
        cfg.phi_mode = 0;
    end
    if ~isfield(cfg,'amp_mode')
        % default amplitude scaling factor
        cfg.amp_mode = 1.0;
    end
    
    if ~isfield(plot_cfg,'keep_update') || ~plot_cfg.keep_update
        grp_setup = struct();
        if is_refresh
            return;
        end             
    elseif ~is_refresh
        % store old setup
        grp_setup.meas_root = meas_root;
        grp_setup.alg_id = alg_id;
        grp_setup.chn_id = chn_id;
        grp_setup.res_id = res_id;
        grp_setup.cfg = cfg;
        grp_setup.var_name = var_name;
        grp_setup.plot_cfg = plot_cfg;
    end    
      
    % --- load and process results
    [results, avg, unca, res_id, are_scalar, is_avg] = qwtb_load_results(meas_root, res_id, alg_id, cfg, {var_name});
    
    
    % select data source to display
    if is_avg
        data = avg;
    elseif res_id && res_id <= numel(results);
        data = results{res_id};
    else
        if is_refresh
            grp_setup = struct();
            return;
        end
        error('QWTB graph plotter: Result not found??? This should not happen.');
    end
        
    % create figure
    if is_refresh
        if ~isOctave()
            % not implemented in Matlab
            grp_setup = struct();
            return;            
        end
        
        try
            fig_href = findobj(grp_setup.fig_href)(1);
        catch
            grp_setup = struct();
            return;        
        end
        
        try
            figure(fig_href);
        catch
            grp_setup = struct();
            return;
        end
    else
        grp_setup.fig_href = figure;
    end
    
    % plot colors set
    colors = {'b','r','k','m','y','c'};
    
    leg_text = {};
    if are_scalar
        % --- Scalar quantities - show history ---
      
        for p = 1:numel(data)
            % select channel/phase
            chn = data{p};
            
            if chn_id && p ~= chn_id
                continue;
            end
            
            % look for variable to display 
            vid = qwtb_find_results_variable(chn, var_name);        
            if ~vid
                % wat??? This should not happen.
                if is_refresh
                    grp_setup = struct();
                    return;
                end
                error(sprintf('QWTB graph plotter: Desired quantity ''%s'' not found!',var_name));      
            end
                  
            % load the history y-data to display
            y_data = [];
            for r = 1:numel(results)
                  
                % get variable
                y_var = results{r}{p}{vid};
                
                % colect values
                y_data(r) = y_var.val;
              
            end
            
            % phase display mode
            if y_var.is_phase
                if cfg.phi_mode == 0 || cfg.phi_mode == 2
                    % +-180
                    y_data = mod(y_data + pi,2*pi) - pi;
                else
                    % 0-360
                    y_data = mod(y_data,2*pi);
                end
                if cfg.phi_mode >= 2
                    y_data = y_data/pi*180.0;  
                end
            end
            
            % select amplitude display mode
            if isfield(y_var,'is_amplitude') && y_var.is_amplitude
                y_data = y_data*cfg.amp_mode;
            end
                  
            % store phase/channel label for legend
            leg_text{end + 1} = y_var.tag;
            
            % plot the graph
            plot(y_data,'x-','Color',colors{p});
            title(escapify(sprintf('Quantity history: %s (%s)',y_var.name,y_var.desc)));
            xlabel('record number');
            ylabel(escapify(y_var.name));
            hold on;
          
        end
    
    else
        % --- Vector quantities - show plot for each phase/channel ---
        for p = 1:numel(data)
            % select channel/phase
            chn = data{p};
            
            if chn_id && p ~= chn_id
                continue;
            end
            
            % look for variable to display 
            vid = qwtb_find_results_variable(chn, var_name);
            
            if ~vid
                % wat??? This should not happen.
                if is_refresh
                    grp_setup = struct();
                    return;
                end
                error(sprintf('QWTB graph plotter: Desired variable ''%s'' not found!',var_name));      
            end    
            y_var = chn{vid};
            
            % store phase/channel label for legend
            leg_text{end + 1} = y_var.tag;
            
            % phase display mode
            y_data = y_var.val;
            if y_var.is_phase
                if cfg.phi_mode == 0 || cfg.phi_mode == 2
                    % +-180
                    y_data = mod(y_data + pi,2*pi) - pi;
                else
                    % 0-360
                    y_data = mod(y_data,2*pi);
                end
                if cfg.phi_mode >= 2
                    y_data = y_data/pi*180.0;  
                end
            end
            
            % select amplitude display mode
            if isfield(y_var,'is_amplitude') && y_var.is_amplitude
                y_data = y_data*cfg.amp_mode;
            end
            
            if y_var.is_graph
                % is graph variable, so it should have assigned independent variable - find it in the result
                vid = qwtb_find_results_variable(chn, y_var.graph_x);
                
                if ~vid
                    % wat??? This should not happen.
                    error(sprintf('QWTB graph plotter: Graph''s independent variable ''%s'' not found!',y_var.graph_x));      
                end
                x_var = chn{vid};
                
                % plot it
                plot(x_var.val,y_data,'Color',colors{p});
                title(escapify(sprintf('Function: %s(%s) (%s)',y_var.name,x_var.name,y_var.desc)));
                xlabel(escapify(x_var.name));
              
            else
                % no graph - display just Y values
                
                plot(y_data,'Color',colors{p});
                title(escapify(sprintf('Quantity: %s (%s)',y_var.name,y_var.desc)));
                   
            end
            ylabel(escapify(y_var.name));
            hold on;
          
        end
    end
     
    hold off;
    
    % set display format
    if plot_cfg.grid
        grid on;
    end
    if plot_cfg.box
        box on;
    end  
    scale = {'linear','log'};
    set(gca,'xscale',scale{1 + plot_cfg.xlog});
    set(gca,'yscale',scale{1 + plot_cfg.ylog});
    
    if ~isempty(plot_cfg.legend)
        % show legend
        legend(leg_text,'Location',lower(plot_cfg.legend));
    end
  
    
end

function [str] = escapify(str,list)  
  if nargin < 2
    list = ['_'];
  end
  for c = 1:numel(list)
    str = strrep(str, list(c), ['\' list(c)]);
  end
end