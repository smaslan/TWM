% format number to string for uncertainty printing
% format: 'val' +- 'unc' rounded to 2 valid digits of 'unc'
% if 'unit' parameter is used output format is: ('val' +- 'unc') 'unit'
% for asymetric uncertainties the uncv is vector: [left_unc right_unc]
% automatic generation of SI prefix

function [str,str_val,str_unc,str_int,si] = unc2str_si(val,unc,unit,cfg)

  if ~exist('unit','var')
    unit= '';
  end
  
  if ~exist('cfg','var')
    cfg = struct();
  end
  
  units = {'y','z','a','f','p','n','u','m','','k','M','G','T','P','E','Z','Y'};
  lim = 1e-24*(1000.^((1:length(units))-1));
  id = find(lim<=val,1,'last');
  if(isempty(id))
    id = 9;
  end
  si = units{id};
  mul = lim(id);
  
  spc = '';
  if(numel(unit) && unit(1) == ' ')
    spc = unit(1);
  end
  if(numel(unit)>1 && unit(1) == ' ')
    unit = unit(2:end);
  else
    unit = unit;
  end
  
  if isfield(cfg,'min_unc_abs')
    cfg.min_unc_abs = cfg.min_unc_abs/mul;
  end
    
  [str,str_val,str_unc,str_int] = unc2str(val/mul,unc/mul,'',cfg);  
  str = ['(' str ')' spc si unit];
  str_int = [str_int spc si unit];   

end
