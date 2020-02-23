function [res] = qwtb_exec_cell(par)
% This is function to be run by startmulticoreslave() processes.
% It tries to execute qwtb_exec_algorithm() with 'par' parameters.
% If it fails, it returns error message.
%
% Parameters:
%  par - structure with qwtb_exec_algorithm() parameters
%
% Returns:
%  res.error - empty when success, error string when failed
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2020, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
%  

    try
        
        % parallel processing mode
        par.parallel = 1;
        % try to execute algorithm
        qwtb_exec_algorithm(par.meas_file, par.calc_unc, par.is_last_avg, par.avg_id, par.group_id, par.verbose, par.cfg);
        % no error
        res.error = '';

    catch err
    
        % failed - store error message as result
        res.error = err.message;
  
    end  
        
end

