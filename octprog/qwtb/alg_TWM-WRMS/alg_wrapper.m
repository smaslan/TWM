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
    din.u = data.y;
    din.i = data.y;
    if cfg.is_diff
        din.u_lo = data.y_lo;
        din.i_lo = data.y_lo;  
    end
    
    
      
        
    
    
    qwtb('TWM-WRMS',datain,calset);
  


end % function


function [lsb] = adc_get_lsb(din,pfx)
% obtain ADC resolution for channel starting with prefix 'pfx', e.g.:
% adc_get_lsb(datain,'u_lo_') will load LSB value from 'datain.u_lo_adc_lsb'
% if LSB is not found, it tries to calculate the value from bit resolution and nominal range
% 
    if isfield(din,[pfx 'adc_lsb'])
        % direct LSB value: 
        lsb = getfield(din,[pfx 'lsb']); lsb = lsb.v;
    elseif isfield(din,[pfx 'adc_bits']) && isfield(din,[pfx 'adc_nrng'])
        % LSB value from nom. range and bit resolution:
        bits = getfield(din,[pfx 'adc_bits']); bits = bits.v;
        nrng = getfield(din,[pfx 'adc_nrng']); nrng = nrng.v;        
        lsb = nrng*2^-(bits-1);        
    else
        % nope - its not there...
        error('PWDTDI algorithm: Missing ADC LSB value or ADC range and bit resolution!');
    end
end

% convert correction tables 'pfx'_list{:} to list{:}
% i.e. get rid of prefix (usually 'u_' or 'i_')
% list - names of the correction tables
% pfx - prefix without '_' 
function [tout] = conv_vchn_tabs(tin,pfx,list)
    
    tout = struct();
    for t = 1:numel(list)    
        name = [pfx '_' list{t}];
        if isfield(tin,name)
            tout = setfield(tout, list{t}, getfield(tin,name));
        end
    end
    
end

function [unc] = top_bin_unc(unc,bin)
    % 'unc' is uncertainty of DFT bins, 'bin' are indices of the bins
    % the function will get max(unc(bin),unc(bin+1),unc(bin-1)) for
    % each 'bin'. 'unc' must be column vector. 
    N = numel(unc);
    unc = max([unc(bin),unc(min(bin+1,N)),unc(max(bin-1,1))],[],2);
end


function unc = scovint_ofs(x, loc, avg)
% scovint for offsetted histogram
    [slen,sql,sqr] = scovint(x, loc);
    unc = max(abs([sqr sql] - avg));
end
