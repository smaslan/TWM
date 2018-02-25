function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm TWM-PWRTEST.
%
% See also qwtb
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
         
    if cfg.y_is_diff
        % Input data 'y' is differential: if it is not allowed, put error message here
        %error('Differential input data ''y'' not allowed!');     
    end
    
    if cfg.is_multi
        % Input data 'y' contains more than one record: if it is not allowed, put error message here
        error('Multiple input records in ''y'' not allowed!'); 
    end
    
    % Rebuild TWM style correction tables:
    % This is not necessary but the TWM style tables are more comfortable to use then raw correction matrices
    tab = qwtb_restore_correction_tables(datain,cfg);
    
    
    % --------------------------------------------------------------------
    % Now we are ready to do whatever the algorithm should do ...
    % Replace following code by whatever algorithm you like.
    % --------------------------------------------------------------------
    
    % I'm too lazy to implement it, just return something
    dataout.P.v = 48.000;
    dataout.P.u =  0.001;
        
    
    
    % --- NOTE ---
    % This was very basic calculation, the real stuff is not there:
    % No uncertainty contribution from the correction was implemented yet.
    % No correction to the interchannel cross-talk is present.
    % Also no correction to the cable effects was implemented and
    % no correction to the low-side cable leakage current (diff. mode) was implemented.
    % These are the actual tricky parts to be done.
           
    % --------------------------------------------------------------------
    % End of the demonstration algorithm.
    % --------------------------------------------------------------------
       
   
    % --- my job here is done...
          

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
