function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm TWM-RATWFFT.
%
% See also qwtb
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2019, Stanislav Maslan, smaslan@cmi.cz
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
    
    % invert one channel?
    if isfield(datain, 'invert') && ((isnumeric(datain.invert.v) && datain.invert.v) || (ischar(datain.invert.v) && strcmpi(datain.invert.v,'on'))) 
        invert = 1;
    else
        invert = 0;
    end
         
%     if cfg.u_is_diff || cfg.i_is_diff
%         % Input data 'y' is differential: if it is not allowed, put error message here
%         error('Differential input data ''y'' not allowed!');     
%     end
%     
%     if cfg.is_multi_records
%         % Input data 'y' contains more than one record: if it is not allowed, put error message here
%         error('Multiple input records in ''y'' not allowed!'); 
%     end
    
    % Rebuild TWM style correction tables:
    % This is not necessary, but the TWM style tables are more comfortable to use then raw correction matrices
    tab = qwtb_restore_correction_tables(datain,cfg);
    
    
    
    % --------------------------------------------------------------------
    % Vector ratio calculation algorithm using WFFT
    %
    % ###todo: add description here
    % Calculates vector from U and I channels using TWM-WFFT, extracts
    % desired harmonics, calculates ration and phase difference of the
    % channels. 
        
    % samples count:
    N = numel(datain.u.v);
          
    % --- For easier processing we convert u/i channels to virtual channels array ---
    % so we can process the voltage and current using the same code...   
        
    % list of involved correction tables without 'u_' or 'i_' prefices
    clear vcl; id = 0; % virt. chn. list     
    % -- build virtual channel (U):
    id = id + 1;
    vcl{id}.tran = 'rvd';
    vcl{id}.name = 'u';     
    vcl{id}.time_stamp.v = datain.time_stamp.v;
    vcl{id}.time_stamp.u = datain.time_stamp.u;    
    vcl{id}.y = datain.u.v;    
    if cfg.u_is_diff
        vcl{id}.y_lo = datain.u_lo.v; 
    end        
    % -- build virtual channel (I):
    id = id + 1;
    vcl{id}.tran = 'shunt';
    vcl{id}.name = 'i';
    vcl{id}.time_stamp.v = datain.time_stamp.v - datain.time_shift.v;
    vcl{id}.time_stamp.u = (datain.time_stamp.u.^2 + datain.time_stamp.u.^2).^0.5; 
    vcl{id}.y = datain.i.v;
    if cfg.u_is_diff
        vcl{id}.y_lo = datain.i_lo.v; 
    end
            
       
    % list of channel specific quantities:
    %  ###todo: check if there is nothing missing
    v_list = {'time_shift_lo','adc_bits','adc_nrng','adc_lsb','adc_jitter','adc_aper_corr','adc_jitter','adc_offset', ... 
              'adc_gain_f','adc_gain_a','adc_gain','adc_phi_f','adc_phi_a','adc_phi','adc_sfdr_f','adc_sfdr_a','adc_sfdr', ... 
              'adc_Yin_f','adc_Yin_Cp','adc_Yin_Gp','tr_gain_f','tr_gain_a','tr_gain','tr_phi_f','tr_phi_a','tr_phi', ...
              'tr_Zlo_f','tr_Zlo_Rp','tr_Zlo_Cp','tr_Zca_f','tr_Zca_Ls','tr_Zca_Rs','tr_Yca_f','tr_Yca_Cp','tr_Yca_D', ...
              'Zcb_f','Zcb_Ls','Zcb_Rs','Ycb_f','Ycb_Cp','Ycb_D','tr_Zbuf_Rs','tr_Zbuf_Ls','tr_Zbuf_f'};
       
    
    if ~isfield(datain,'f_nom')
        % -- we aint got no nominal frequency, so try to search it by PSFE:
        
        % call PSFE:
        din = struct();
        din.fs.v = fs;        
        cset = calcset;
        cset.verbose = 0;
        cset.unc = 'none';
        cset.checkinputs = 0;  
        din.y.v = datain.u.v;                
        dout = qwtb('PSFE',din,cset);
        datain.f_nom.v = dout.f.v;
        
        if calcset.verbose
            fprintf('Searching for nominal frequency by PSFE ... f = %.6g\n', datain.f_nom.v);
        end      
    end
    
    if isfield(datain,'h_num')
        % -- relative harmonic frequencies specified:
        
        if numel(datain.f_nom.v) > 1
            error('TWM-WFFT error: you cannot have vector ''f_nom'' if ''h_num'' is assigned!');
        end
        
        % make vector of frequencies:
        datain.f_nom.v = datain.f_nom.v*datain.h_num.v;        
    end
    
    % no f_nom should contain list of frequencies to analyse:
    f_nom = datain.f_nom.v;
    
    % samples count:
    N = numel(datain.u.v);
    
    % get high-side (or single-ended) spectrum:
    din = struct();
    din.fs.v = fs;
    if isfield(datain,'window')
        din.window = datain.window;
    else
        din.window.v = 'rect';    
    end    
    win_type = din.window.v;        
    
    % --- get channel spectra:    
    % for each virtual (u/i) channel:
    for k = 1:numel(vcl)
        % get channel:
        vc = vcl{k};
        
        % build WFFT parameters:
        cset = struct();
        cset.verbose = 0;
        cset.unc = calcset.unc;
        cset.loc = 0.681;
        cset.checkinputs = 0;
        din = struct();
        din.fs.v = fs;
        din.f_nom.v = f_nom; % DFT frequencies to extract
        din.window.v = win_type;
        din.tr_type.v = vc.tran;
        din.time_stamp = vc.time_stamp;        
        din.adc_aper = datain.adc_aper;
        din.y.v = vc.y;
        if isfield(vc,'y_lo')
            din.y_lo.v = vc.y_lo;        
        end
        % copy channel specific corrections to WFFT data: 
        for v = 1:numel(v_list)            
            % high-side matrices
            if isfield(datain,[vc.name '_' v_list{v}])
                din = setfield(din, v_list{v}, getfield(datain,[vc.name '_' v_list{v}]));
            end
            % low side matrices:
            if isfield(datain,[vc.name '_lo_' v_list{v}])
                din = setfield(din, ['lo_' v_list{v}], getfield(datain,[vc.name '_lo_' v_list{v}]));
            end
        end
        % execute WFFT:
        dout = qwtb('TWM-WFFT',din,cset);        
        % extract DFT bins:
        fh    = dout.f.v(:); % freq. vector of the DFT bins
        vc.Y  = dout.A.v(:); % amplitude vector of the DFT bins
        vc.u_Y  = dout.A.u(:);
        vc.ph = dout.ph.v(:); % phase vector of the DFT bins
        vc.u_ph = dout.ph.u(:);
        vc.dc   = dout.dc.v; % DC component
        vc.u_dc = dout.dc.u;
        spec_f  = dout.spec_f.v; % full spectrum frequency axis
        vc.spec_A = dout.spec_A.v; % full spectrum data
               
        vcl{k} = vc;
    end
    fh = fh(:);
    
    if isfield(calcset,'dbg_plots') && calcset.dbg_plots
        figure;
        loglog(spec_f,vcl{1}.spec_A)
        xlabel('f [Hz]');
        ylabel('U [V]');
        figure;
        loglog(spec_f,vcl{2}.spec_A)
        xlabel('f [Hz]');
        ylabel('I [V]');
    end
    
    % extract DFT bins:
    Uh = vcl{1}.Y; % voltage amplitudes
    Ih = vcl{2}.Y; % current amplitudes
    r   = Uh./Ih; % I/U ratio    
    dph = +vcl{1}.ph - vcl{2}.ph; % I-U phase difference
    if invert
        dph = dph + pi;
    end
    % corresponding uncertainties 
    u_Uh = vcl{1}.u_Y;
    u_Ih = vcl{2}.u_Y;
    u_r   = ((u_Uh./Ih).^2 + (u_Ih.*Uh./Ih.^2).^2).^0.5;
    u_dph = (vcl{1}.u_ph.^2 + vcl{2}.u_ph.^2).^0.5;
    

    % --- return quantities to QWTB:    
    % calc. coverage factor:
    ke = loc2covg(calcset.loc,50);
    
    % returned parameters:
    dataout.f.v = fh;
    dataout.U.v = Uh;
    dataout.U.u = u_Uh*ke;
    dataout.I.v = Ih;
    dataout.I.u = u_Ih*ke;
    dataout.r.v = r;
    dataout.r.u = u_r*ke;
    dataout.dph.v = dph;
    dataout.dph.u = u_dph*ke;
    dataout.dT.v = dph./(2*pi*fh);
    dataout.dT.u = u_dph./(2*pi*fh)*ke;
    dataout.re.v = r.*cos(dph);
    dataout.im.v = r.*sin(dph);
    dataout.Udc.v = vcl{1}.dc;            
    dataout.Udc.u = vcl{1}.u_dc;
    dataout.Idc.v = vcl{2}.dc;            
    dataout.Idc.u = vcl{2}.u_dc;
        
    % return spectra of the corrected waveforms:    
    dataout.spec_U.v = vcl{1}.spec_A(:); % amplitude vector of the DFT bins    
    dataout.spec_I.v = vcl{2}.spec_A(:); % amplitude vector of the DFT bins
    dataout.spec_f.v = spec_f(:);
    
    if isfield(calcset,'dbg_plots') && calcset.dbg_plots
        figure;
        loglog(dataout.spec_f.v(2:end),dataout.spec_U.v(2:end))
        xlabel('f [Hz]');
        ylabel('U [V]');
        figure;
        loglog(dataout.spec_f.v(2:end),dataout.spec_I.v(2:end))
        xlabel('f [Hz]');
        ylabel('I [V]');
    end  


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
