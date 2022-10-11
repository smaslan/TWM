function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm TWM-VALID.
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
    
    if cfg.u_is_diff || cfg.i_is_diff
        % Input data 'y' is differential: if it is not allowed, put error message here
        %error('Differential input data ''y'' not allowed!');     
    end
    
    if cfg.is_multi_records
        % Input data 'y' contains more than one record: if it is not allowed, put error message here
        %error('Multiple input records in ''y'' not allowed!'); 
    end
    
    % Rebuild TWM style correction tables:
    % This is not necessary, but the TWM style tables are more comfortable to use then raw correction matrices
    tab = qwtb_restore_correction_tables(datain,cfg);
    
    
    % copy sampling rate:
    dataout.fs.v = fs;    
    
    % TWM control structure containing quantity assignement rules:
    global twm_selftest_control;
    
    if ~isempty(twm_selftest_control)
    
        % raw quantities:
        %   note: these will be passed directly datain -> dataout 
        raw = twm_selftest_control.raw;
        
        % table-to-dataout quantities:
        %   note: these will be passed from 'tab' tables to -> dataout 
        t2d = twm_selftest_control.t2d;
        
        % --- process raw quantities:
        for k = 1:numel(raw)
            
            if raw{k}.auto_pass
                
                % get input quantity:
                src = getfield(datain,raw{k}.name);
                
                if isfield(raw{k}.data,'u')
                    src = struct('v',src.v, 'u',src.u);
                else
                    src = struct('v',src.v);
                end            
                
                % return output quantity:
                dataout = setfield(dataout,raw{k}.name,src);
            end    
        
        end
        
        %fieldnames(dataout)
        
        % --- process table-to-dataout quantities:
        for k = 1:numel(t2d)
        
            % get quantity record:
            qur = t2d{k};
            
            % get input table:
            tbl = getfield(tab,qur.tab_name);
            
            % copy all table's content to dataout:
            for q = 1:numel(qur.qu)
                % get table's data:
                qu = getfield(tbl,qur.qu{q}.qu);
                % copy table's data to dataout:
                if isfield(dataout,qur.qu{q}.name)
                    doq = getfield(dataout,qur.qu{q}.name);
                else
                    doq = struct();
                end            
                doq = setfield(doq,qur.qu{q}.sub,qu);
                dataout = setfield(dataout,qur.qu{q}.name,doq);
            end    
        end
    
    end
    
end % function
