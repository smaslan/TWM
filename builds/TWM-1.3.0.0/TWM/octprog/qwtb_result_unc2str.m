%% -----------------------------------------------------------------------------
%% TracePQM: Formatting of the result variable item. Automatically formats
%% the value by its uncertainty (two digitis of precision).
%% It decides the format of the number (float or float with SI suffix)
%% based on the configuration in the 'val'. 
%%  
%% value: result's variable item returned by the qwtb_parse_result()
%% index: if the items val/unc are vectors, 'index' selects the vector item
%% cfg: structure of configurations:
%%      cfg.phi_mode: 0 - [rad]
%%                    1 - [deg]
%%     
%% -----------------------------------------------------------------------------

function [full_str,val_str,unc_str,unit_str] = qwtb_result_unc2str(value,index,cfg)

  % load low limits of the uncertainty 
  cfg.min_unc_abs = value.min_unc_abs;
  cfg.min_unc_rel = value.min_unc_rel;
  
  % default item index
  if ~exist('index','var') || isempty(index)
    index = 1;
  end
  
  % build default options
  if ~exist('cfg','var')
    cfg = struct();
  end
  if ~isfield(cfg,'phi_mode')
    cfg.phi_mode = 0;
  end
  
  % load value and its uncertainty from the result item
  val = value.val(index);
  if numel(value.unc)
    unc = value.unc(index);
  else
    unc = 0;
  end
    
  % select phase display mode
  if value.is_phase
    if cfg.phi_mode == 0 || cfg.phi_mode == 2
      % +-180
      val = mod(val + pi,2*pi) - pi;
    else
      % 0-360
      val = mod(val,2*pi);
    end
    if cfg.phi_mode >= 2
       val = val/pi*180.0;
       unc = unc/pi*180.0;
    end
  end
            
  if strcmpi(value.num_format,'si')
    % SI suffix mode
    [full_str, val_str, unc_str, unit_str] = unc2str_si(val, unc, '', cfg);
  elseif strcmpi(value.num_format,'f')
    % float mode
    [full_str, val_str, unc_str] = unc2str(val, unc, '', cfg);
    unit_str = '';
  else
    error(sprintf('QWTB number formatter: Number format ''%s'' not recognized!',val.num_format));
  end

end
