function [mode] = par_mode_qwtb2mc(mode)
% converts QWTB style parallel execution mode to runmulticore() naming    
    if strcmpi(mode,'singlecore')        
        mode = 'cellfun';
    elseif strcmpi(mode,'multicore')
        mode = 'parcellfun';
    elseif strcmpi(mode,'multistation')
        mode = 'multicore';
    else
        error(sprintf('Unknown parallelization mode ''%s''!',mode)); 
    end
end   
   