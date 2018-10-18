function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm TWM-WRMS.
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
    
    if cfg.is_multi
        % Input data 'y' contains more than one record: if it is not allowed, put error message here
        error('Multiple input records in ''y'' not allowed!'); 
    end
    
    
    % Rebuild TWM style correction tables:
    % This is not necessary, but the TWM style tables are more comfortable to use then raw correction matrices
    tab = qwtb_restore_correction_tables(datain,cfg);
    
    
    % ------------------------------------------------------------------------------------------
    % Note: Following algorithm is just a wrapper for TWM-PWRTDI power algorithm!
    %       It takes copies the single waveform 'y' and 'y_lo' to both U and I channels
    %       of TWM-PWRTDI and just one of the RMS 'channels' of TWM-PWRTDI will be used. 
    % ------------------------------------------------------------------------------------------
    
    % put copies of waveform to both U/I channels:
    din.u = datain.y;
    din.i = datain.y;
    if cfg.y_is_diff
        din.u_lo = data.y_lo;
        din.i_lo = data.y_lo;  
    end
    
    din.fs.v = fs; 
    din.adc_freq = datain.adc_freq;
    din.adc_aper = datain.adc_aper;
    din.u_tr_type = 'rvd';
    din.i_tr_type = 'shunt';
    din.time_shift.v = 0; din.time_shift.u = 0;
        
    list = {'adc_gain','adc_phi','adc_offset','adc_jitter','adc_bits','adc_nrng','adc_lsb','adc_aper_corr','adc_Yin_f','adc_Yin_Cp','adc_Yin_Gp','time_shift','tr_gain','tr_phi','adc_sfdr','tr_sfdr','tr_Zlo','tr_Zlo_f','tr_Zlo_Rp','tr_Zlo_Cp','tr_Zca_f','tr_Zca_Ls','tr_Zca_Rs', 'tr_Yca_f','tr_Yca_Cp','tr_Yca_D', 'tr_Zcal_f','tr_Zcal_Ls','tr_Zcal_Rs', 'tr_Zcam_f','tr_Zcam', 'Zcb_f','Zcb_Ls','Zcb_Rs', 'Ycb_f','Ycb_Cp','Ycb_D'};
    din = close_ui_tabs(din,datain,'u',list);
    din = close_ui_tabs(din,datain,'i',list);
    
    %fieldnames(din)

    % execute TWM-PWRTDI
    qwtb('TWM-PWRTDI',din,calcset);
  


end % function

 
% copies TWM tables named in 'list' from 'tin' to 'tout' adding preffix 'pfx':
%  pfx = 'u'; list = {'adc_gain',...}; tin.adc_gain => tout.u_adc_gain; ...
function [tout] = close_ui_tabs(tout,tin,pfx,list)
    for t = 1:numel(list)    
        name = [pfx '_' list{t}];
        sname = list{t};
        if isfield(tin,sname)
            tout = setfield(tout, name, getfield(tin,sname));
        end
        name = [pfx '_' list{t} '_a'];        
        sname = [list{t} '_a'];
        if isfield(tin,sname)
            tout = setfield(tout, name, getfield(tin,sname));
        end
        name = [pfx '_' list{t} '_f'];
        sname = [list{t} '_f'];
        if isfield(tin,sname)
            tout = setfield(tout, name, getfield(tin,sname));
        end
        
        name = [pfx '_lo_' list{t}];
        sname = ['lo_' list{t}];
        if isfield(tin,sname)
            tout = setfield(tout, name, getfield(tin,sname));
        end        
        name = [pfx '_lo_' list{t} '_a'];
        sname = ['lo_' list{t} '_a'];
        if isfield(tin,sname)
            tout = setfield(tout, name, getfield(tin,sname));
        end
        name = [pfx '_lo_' list{t} '_f'];
        sname = ['lo_' list{t} '_f'];
        if isfield(tin,sname)
            tout = setfield(tout, name, getfield(tin,sname));
        end
    end    
end

