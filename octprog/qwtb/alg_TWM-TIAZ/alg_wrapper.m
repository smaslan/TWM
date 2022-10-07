function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm TWM-LowZ (top level of the algorithm).
%
% See also qwtb
% This is part of the TWM - TracePQM WattMeter.
% (c) 2018-2021, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.
% Format input data --------------------------- %<<<1
    
    
    is_wfft_local = 1;
    
    
    % Restore orientations of the input vectors to originals (before passing via QWTB)
    % This is critical for the correction data! 
    [datain,cfg] = qwtb_restore_twm_input_dims(datain,1);
    
    if cfg.i_is_diff || cfg.u_is_diff
        error('Differential input data not allowed!');     
    end
    
    % try to obtain sampling rate from alternative input quantities [Hz]
    if isfield(datain, 'fs')
        fs = datain.fs.v;
    elseif isfield(datain, 'Ts')
        fs = 1/datain.Ts.v;
    else
        fs = 1/mean(diff(datain.t.v));
    end
    
    % decide harmonic estimation mode:
    if isfield(datain, 'mode') && strcmpi(datain.mode.v, 'PSFE')
        mode = 'PSFE';
    elseif isfield(datain, 'mode') && strcmpi(datain.mode.v, 'FPNLSF')
        mode = 'FPNLSF';
    elseif isfield(datain, 'mode') && strcmpi(datain.mode.v, 'WFFT')
        mode = 'WFFT';
    elseif isfield(datain, 'mode')
        error(sprintf('Harmonic estimation mode ''%s'' is unknown!',datain.mode.v));
    else
        mode = 'WFFT'; % default
    end
    
    if ~strcmpi(mode,'WFFT') && cfg.is_multi
        % Input data 'y' contains more than one record: if it is not allowed, put error message here
        error('Multiple input records in ''y'' not allowed for other than WFFT mode!'); 
    end  
    
    % initial frequency estimate mode:
    if isfield(datain, 'f_est') && isnumeric(datain.f_est.v) && ~isempty(datain.f_est.v)
        f_est = datain.f_est.v;
    elseif strcmpi(mode,'FPNLSF')
        error('Initial frequency estimte is required for FPNLSF mode!');
    else
        % default (for PSFE):
        f_est = NaN;
    end
    
    % default window:
    if ~isfield(datain,'window') || isempty(datain.window.v)
        datain.window.v = 'rect';        
    end
    
    % invert phase mode:
    is_invert = isfield(datain,'invert') && datain.invert.v;
    
    % get equivalent circuit:
    [r,eclist] = z_to_equivalent();
    for k = 1:size(eclist,1)
        ecstr{k} = [eclist{k,[1,3]}];
    end
    if isfield(datain, 'equ')
        equ = datain.equ.v;
    else
        equ = 'RsTau';
    end
    ecid = find(strcmpi(ecstr,equ),1);
    if isempty(ecid)
        error(sprintf('Equivalent circuit ''%s'' not supported! Supported: %s.',equ,catcellcsv(ecstr,', ',';')));
    end
    
    
    % Rebuild TWM style correction tables:
    % This is not necessary but the TWM style tables are more comfortable to use then raw correction matrices
    tab = qwtb_restore_correction_tables(datain,cfg);
    
    
    
    % --------------------------------------------------------------------
    % Start of the algorithm
    % --------------------------------------------------------------------
    
    % apply timebase frequency correction:    
    % note: it is relative correction of timebase error, so apply inverse correction to measured f.  
    %fs = fs.*(1 + datain.adc_freq.v); 


    % list of involved correction tables without 'u_' or 'i_' prefices
    %tab_list = {'tr_gain','tr_phi','tr_Zca','tr_Yca','tr_Zcal','tr_Zcam','adc_Yin','lo_adc_Yin','Zcb','Ycb','tr_Zlo','adc_gain','adc_phi','lo_adc_gain','lo_adc_phi','tr_sfdr','adc_sfdr','lo_adc_sfdr'};
    clear vcl; id = 0; % virt. chn. list         
    % -- build TIA virtual channel (I) - TIA output:
    id = id + 1;
    vcl{id}.tran = 'shunt';
    vcl{id}.name = 'i';
    vcl{id}.y = datain.i.v;
    %vcl{id}.tab = conv_vchn_tabs(tab,'i',tab_list);    
    vcl{id}.time_stamp.v = datain.time_stamp.v - datain.time_shift.v;
    vcl{id}.time_stamp.u = (datain.time_stamp.u.^2 + datain.time_shift.u.^2).^0.5; 
    vcl{id}.tsh = 0; % high-side channel shift (do not change!)
    vcl{id}.is_diff = cfg.i_is_diff; % note: should be always false
    % -- build reference virtual channel (U) - impedance high-side voltage:
    id = id + 1;        
    vcl{id}.tran = 'rvd';
    vcl{id}.name = 'u'; 
    vcl{id}.y = datain.u.v;
    %vcl{id}.tab = conv_vchn_tabs(tab,'u',tab_list);       
    vcl{id}.time_stamp.v = datain.time_stamp.v;
    vcl{id}.time_stamp.u = datain.time_stamp.u;
    vcl{id}.tsh = 0; % high-side channel shift (do not change!)
    vcl{id}.is_diff = cfg.u_is_diff;
   
       
    k_unc = loc2covg(calcset.loc,50);        
    
    % list of channel specific correction quantities:
    % ###todo: check there is nothing missing?
    v_list = {'adc_bits','adc_nrng','adc_lsb','adc_jitter','adc_aper_corr','adc_jitter','adc_offset','adc_gain_f','adc_gain_a','adc_gain','adc_phi_f','adc_phi_a','adc_phi','adc_sfdr_f','adc_sfdr_a','adc_sfdr','adc_Yin_f','adc_Yin_Cp','adc_Yin_Gp','tr_gain_f','tr_gain_a','tr_gain','tr_phi_f','tr_phi_a','tr_phi','tr_Zlo_f','tr_Zlo_Rp','tr_Zlo_Cp','tr_Zca_f','tr_Zca_Ls','tr_Zca_Rs','tr_Yca_f','tr_Yca_Cp','tr_Yca_D','Zcb_f','Zcb_Ls','Zcb_Rs','Ycb_f','Ycb_Cp','Ycb_D','tr_Zbuf_f','tr_Zbuf_Ls','tr_Zbuf_Rs'};        
        
    % corrections interpolation mode:
    % ###note: do not change, this works best for frequency characteristics
    %i_mode = 'pchip';   
                
    % for each virtual channel:
    %  1. TIA (i) channel
    %  2. REF (u) channel
    for k = 1:numel(vcl)
        % get channel:
        vc = vcl{k};
                
        % build harmonic estimator parameters:
        cset = struct();
        cset.verbose = 0;
        cset.loc = 0.681;
        cset.unc = calcset.unc;
        cset.checkinputs = 0;
        din = struct();
        din.fs.v = fs; % sampling rate
        din.f_est.v = f_est; % fundamental frequency           
        if ~isnan(f_est)
            din.f_nom.v = f_est; % fundamental frequency for WFFT mode only
        end
        din.adc_aper = datain.adc_aper; 
        din.tr_type.v = vc.tran;
        % copy correction values        
        for v = 1:numel(v_list)         
            if isfield(datain,[vc.name '_' v_list{v}])
                din = setfield(din, v_list{v}, getfield(datain,[vc.name '_' v_list{v}]));
            end
        end    
        % timeshift correction
        din.time_stamp = vc.time_stamp;        
        % copy waveform(s) data
        din.y.v = vc.y;                                    
        
        % estimate harmonic                            
        if strcmpi(mode,'PSFE')
            din.comp_timestamp.v = 1;
            dout = qwtb('TWM-PSFE',din,cset);
            dout.dc.v = 0;
            dout.dc.u = 0;
        elseif strcmpi(mode,'FPNLSF')
            din.comp_timestamp.v = 1;
            dout = qwtb('TWM-FPNLSF',din,cset);
        elseif strcmpi(mode,'WFFT')
            din.window.v = datain.window.v;
            if is_wfft_local
                % -- run WFFT directly using local functions:                        
                [din_wfft,cfg_wfft] = qwtb_restore_twm_input_dims(din,1);
                tab_wfft = qwtb_restore_correction_tables(din_wfft,cfg_wfft);
                dout = wfft_core(din_wfft, cfg_wfft, tab_wfft, cset, fs);
                
            else
                % -- run WFFT via QWTB (slower):
                dout = qwtb('TWM-WFFT',din,cset);
                
            end
            dout.phi = dout.ph; %###todo: remove when WFFT phase renamed to phi
        end
        
            
        if vc.name == 'u'
            % -- ref DUT voltage channel:
            
            % invert DUT connection mode? (0 or 180 deg)
            inv_phi = is_invert*pi;

            % fundamental frequency:
            if strcmpi(mode,'WFFT')
                % override frequency by initial estimate (WFFT only)
                %  ###note: we need this because WFFT cannot measure exact frequency in non-coherent mode
                %           so we assume user knows exact value and used it as f_est
                f0   = f_est;
                u_f0 = 0.0;
            else
                f0   = dout.f.v;
                u_f0 = dout.f.u;
            end                  
                                
            % monte carlo cycles
            mcc = 10000;
                        
            % TIA current
              I_tia = vcl{1}.A.v;
            u_I_tia = vcl{1}.A.u; 
              p_tia = vcl{1}.phi.v;
            u_p_tia = vcl{1}.phi.u;
            % DUT voltage
              U_dut = dout.A.v;
            u_U_dut = dout.A.u;
              p_dut = dout.phi.v;                      
            u_p_dut = dout.phi.u;
            
              Zx = U_dut/I_tia;
            u_Zx = Zx*((u_I_tia/I_tia)^2 + (u_U_dut/U_dut)^2)^0.5;                                              
              px = mod((p_dut - p_tia + inv_phi) + pi, 2*pi) - pi;
            u_px = (u_p_dut^2 + u_p_tia^2)^0.5;                
              Zdut = Zx*exp(j*px);
            u_Zdut = (Zx + u_Zx*randn(mcc,1)).*exp(j*(px + u_px*randn(mcc,1)));
                                        
            dataout.f.v = f0;
            dataout.f.u = k_unc*u_f0;
            dataout.Itia.v = I_tia*2^-0.5;
            dataout.Udut.v = U_dut*2^-0.5;
            dataout.Idc.v = vcl{1}.dc.v;
            dataout.Udc.v = dout.dc.v;
                                                 
                
            % return complex Z
            dataout.Z_mod.v = abs(Zdut);
            dataout.Z_phi.v = angle(Zdut);
            [u_mag,u_arg] = cunc_mc_magarg(u_Zdut);
            dataout.Z_mod.u = k_unc*u_mag;
            dataout.Z_phi.u = k_unc*u_arg;
        
            % convert to desired equivalent circuit:
            ec = z_to_equivalent(ecid-1,f0,Zdut,k_unc*cunc_mc_reim(u_Zdut));
            
            % return in equivalent circuit
            dataout.mjr.v = ec.mjr;
            dataout.mjr.u = ec.umjr;
            dataout.mnr.v = ec.mnr;
            dataout.mnr.u = ec.umnr;                
            dataout.mjr_name.v = char([eclist{ecid,1} ' [' eclist{ecid,2} ']']); 
            dataout.mnr_name.v = char([eclist{ecid,3} ' [' eclist{ecid,4} ']']);
            
            if isfield(dout,'spec_A')
                spec_U = dout.spec_A.v;
            endif
                                            
        elseif vc.name == 'i' && isfield(dout,'spec_A')
            % try to store ref current spectrum
            spec_f = dout.spec_f.v;
            spec_I = dout.spec_A.v;                    
        end
        
        % store estimated harmonic to the virtual channel record for next pass:        
        vc.f0  = dout.f;
        vc.A   = dout.A;
        vc.phi = dout.phi;
        vc.dc  = dout.dc;                        
        vcl{k} = vc;
        
    end % each channel
    
    % try to return spectra
    if exist('spec_f','var') && exist('spec_U','var') && exist('spec_I','var')
        dataout.spec_f.v = spec_f;
        dataout.spec_U.v = spec_U;
        dataout.spec_I.v = spec_I;
    end

end % function

% complex uncertainty monte-carlo
function [unc,val] = cunc_mc_reim(values)
    unc = complex(std(real(values)),std(imag(values)));
    val = complex(mean(real(values)),mean(imag(values)));
end
function [umag,uarg] = cunc_mc_magarg(values)
    umag = std(abs(values));
    % try to prevent phase wrapping
    uarg = std(angle(values-mean(angle(values))));
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


% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
