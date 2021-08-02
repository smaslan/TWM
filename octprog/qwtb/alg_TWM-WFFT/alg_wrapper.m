function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm TWM-WFFT.
%
% See also qwtb
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
%
% Format input data --------------------------- %<<<1

    % Restore orientations of the input vectors to originals (before passing via QWTB)
    % This is critical for the correction data! 
    [datain,cfg] = qwtb_restore_twm_input_dims(datain,1);
        
    % try to obtain sampling rate from alternative input quantities [Hz]
    if isfield(datain, 'fs')
        fs = datain.fs.v;
    elseif isfield(datain, 'Ts')
        fs = 1/datain.Ts.v;
    else
        fs = 1/mean(diff(datain.t.v));
    end
             
%     if cfg.y_is_diff
%         % Input data 'y' is differential: if it is not allowed, put error message here
%         error('Differential input data ''y'' not allowed!');     
%     end
%     
%     if cfg.is_multi
%         % Input data 'y' contains more than one record: if it is not allowed, put error message here
%         error('Multiple input records in ''y'' not allowed!'); 
%     end
    
    
    % Rebuild TWM style correction tables:
    % This is not necessary, but the TWM style tables are more comfortable to use then raw correction matrices
    tab = qwtb_restore_correction_tables(datain,cfg);
        
    % ------------------------------------------------------------------------------------------     
    % algorithm start
    % ------------------------------------------------------------------------------------------
    
    dataout = wfft_core(datain, cfg, tab, calcset, fs);

end % function
