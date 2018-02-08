% format number to string for uncertainty printing
% format: 'val' +- 'uncv' rounded to 2 valid digits of 'uncv'
% if 'unit' parameter is used output format is: ('val' +- 'uncv') 'unit'
% for asymetric uncertainties the uncv is vector: [left_unc right_unc]
% cfg.min_unc_abs: minimum allowed absolute uncertainty
% cfg.min_unc_rel: minimum allowed relative uncertainty

function [str,str_val,str_unc,str_int] = unc2str(val,uncv,unit,cfg)
    
  if ~exist('cfg','var')
    cfg = struct();
  end
  
  % default lower limit of the uncertainty
  if ~isfield(cfg,'min_unc_abs')
    cfg.min_unc_abs = 1e-9;
  end
  if ~isfield(cfg,'min_unc_rel')
    cfg.min_unc_rel = 1e-9;
  end
  
  
  if(numel(uncv)>1)
    % asymetric uncertainty unc = [left right]
    % use larger bound
    unc = max(abs(uncv));
  else
    unc = uncv;
  end
  
  % limit uncertainty by absolute minimum
  if abs(unc) < cfg.min_unc_abs
    unc = cfg.min_unc_abs;
  end
  
  % limit uncertainty by relative minimum
  if abs(unc) < abs(val)*cfg.min_unc_rel 
    unc = abs(val)*cfg.min_unc_rel;
  end
  
  dig = ceil(log10(1/unc)+1)+0;
  mul = 10^dig;  
  str_val = sprintf(['%0.' int2str(max(0,dig)) 'f'],round(val*mul)/mul);
    
  str_int = '';
  if(numel(uncv)>1)
    % asymetric
    uncv = sort(uncv);
    str_unc{1} = sprintf(['%0.' int2str(max(0,dig)) 'f'],abs(uncv(1)));
    str_unc{2} = sprintf(['%0.' int2str(max(0,dig)) 'f'],uncv(2));
    
    str_unc_a = sprintf(['%0.' int2str(max(0,dig)) 'f'],val+uncv(1));
    str_unc_b = sprintf(['%0.' int2str(max(0,dig)) 'f'],val+uncv(2));
    str_int = ['<' str_unc_a '; ' str_unc_b '>'];
    if(exist('unit','var') && numel(unit))
      str = ['(' str_val ' - ' str_unc{1} ' + ' str_unc{2} ')' unit];
      str_int = [str_int unit];
    else
      str = [str_val ' - ' str_unc{1} ' + ' str_unc{2}];
    end
    
    str_unc{1} = ['-' str_unc{1}];     
        
  else
    str_unc = sprintf(['%0.' int2str(max(0,dig)) 'f'],unc);
    % symetric
    if(exist('unit','var') && numel(unit))
      str = ['(' str_val ' +- ' str_unc ')' unit];
    else
      str = [str_val ' +- ' str_unc];
    end
  end

end
