% format number to string for uncertainty printing
% format: 'val' +- 'uncv' rounded to 2 valid digits of 'uncv'
% if 'unit' parameter is used output format is: ('val' +- 'uncv') 'unit'
% for asymetric uncertainties the uncv is vector: [left_unc right_unc]
% cfg.min_unc_abs: minimum allowed absolute uncertainty
% cfg.min_unc_rel: minimum allowed relative uncertainty
% cfg.digit_spacing: enable spacing every 3 digits

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
    if ~isfield(cfg,'digit_spacing')
        cfg.digit_spacing = 0;
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
    
    dig = ceil(log10(1/unc)+0.999)+0;
    mul = 10^dig;  
    str_val = sprintf('%0.*f',max(0,dig),round(val*mul)/mul);
    if cfg.digit_spacing
        str_val = unc2str_segment(str_val);
    end     
      
    str_int = '';
    if(numel(uncv)>1)
        % asymetric
        uncv = sort(uncv);
        str_unc{1} = sprintf('%0.*f',max(0,dig),abs(uncv(1)));
        str_unc{2} = sprintf('%0.*f',max(0,dig),uncv(2));
        
        str_unc_a = sprintf('%0.*f',max(0,dig),val+uncv(1));
        str_unc_b = sprintf('%0.*f',max(0,dig),val+uncv(2));
        str_int = ['<' str_unc_a '; ' str_unc_b '>'];
        if(exist('unit','var') && numel(unit))
            str = ['(' str_val ' - ' str_unc{1} ' + ' str_unc{2} ')' unit];
            str_int = [str_int unit];
        else
            str = [str_val ' - ' str_unc{1} ' + ' str_unc{2}];
        end
        
        str_unc{1} = ['-' str_unc{1}];     
          
    else
        str_unc = sprintf('%0.*f',max(0,dig),unc);
        if cfg.digit_spacing
            str_unc = unc2str_segment(str_unc);
        end
        % symetric
        if(exist('unit','var') && numel(unit))
            str = ['(' str_val ' +- ' str_unc ')' unit];
        else
            str = [str_val ' +- ' str_unc];
        end
    end

end

% this mess should insert spacing every three digits
% todo: optimize?
function [str_seg] = unc2str_segment(str)
    N = numel(str);
    fid = find(str == '.');
    if numel(fid)
    
        % indices to insert spaces 
        fid = unique(sort([[1] [fid-3:-3:1] [fid+4:3:N] N+1]));
    
    elseif N > 3
        
        % indices to insert spaces         
        fid = unique(sort([[1] [N-2:-3:1] N+1])); 
    
    end
    
    if numel(fid) 
                
        str_seg = [];
        for f = 1:numel(fid)-1
            str_seg = [str_seg str(fid(f):fid(f+1)-1) ' '];         
        end
        if str_seg(end) == ' '
            str_seg = str_seg(1:end-1);
        end
         
    else
        str_seg = str;
    end
end
