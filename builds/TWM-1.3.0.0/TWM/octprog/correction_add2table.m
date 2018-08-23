function [tab] = correction_add2table(tab,names,data)
% TWM: This will add quantities to the correction tables loaded by 'correction_load_table'.
% Note all the new quantities must have same dimensions as the existing.  
%
% Parameters:
%  tab   - input correction table
%  names - cell array of new data quantity names to be inserted to the 'tin'
%          note it may be also single string
%  data  - cell array of new data matrices to be inserted to the 'tin'
%          note it may be also single matrix 
%
% Returns:
%  tab - table with the new quantities
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2017, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
%     
    
    if ischar(names)
        names = {names};
    end
    if ~iscell(data)
        data = {data};
    end

    % new quantities count:
    N = numel(names);
    
    if N ~= numel(data)
        error('Correction table: Cannot add new quantities, because their ''names'' and ''data'' have different sizes!');
    end
    
    % obtain expected data size from the table axes:        
    sz = max([tab.size_y tab.size_x],[1 1]);
    
    % create quantity list in the table if it's not there yet:
    if ~numel(tab.quant_names)
        tab.quant_names = {};        
    end
    
    % add new q. names to the table's list:
    tab.quant_names = {tab.quant_names{:} names{:}};
    
    % for each new quantity:
    for k = 1:N        
        if size(data) ~= sz
            error(sprintf('Correction table: Cannot add new quantity ''%s'', because it has different size then existing quantities!',names{k}));
        end
        tab = setfield(tab, names{k}, data{k});            
    end    
      

end