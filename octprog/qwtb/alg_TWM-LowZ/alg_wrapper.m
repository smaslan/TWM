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
    
    if cfg.i_is_diff
        % Input data 'i' is differential: if it is not allowed, put error message here
        error('Differential input data for reference channel ''i'' not allowed!');     
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
    
    if ~strcmpi(mode,'WFFT') && cfg.is_multi_records
        % Input data 'y' contains more than one record: if it is not allowed, put error message here
        error('Multiple input records in ''y'' not allowed for other than WFFT mode!'); 
    end
    
    % decide 4TP wiring mode:    
    if isfield(datain, 'mode_4TP') && strcmpi(datain.mode_4TP.v, '2x4T')
        is_2x4T = 1;
    elseif isfield(datain, 'mode_4TP') && strcmpi(datain.mode_4TP.v, '4TP')
        is_2x4T = 0;
    elseif isfield(datain, 'mode_4TP')
        error(sprintf('4TP wiring mode ''%s'' is unknown!',datain.mode_4TP.v));
    else
        is_2x4T = 0; % default
    end
    if ~cfg.u_is_diff
        is_2x4T = 0;
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
    % -- build reference virtual channel (I):
    id = id + 1;
    vcl{id}.tran = 'shunt';
    vcl{id}.name = 'i';
    vcl{id}.y = datain.i.v;
    %vcl{id}.tab = conv_vchn_tabs(tab,'i',tab_list);    
    vcl{id}.time_stamp.v = datain.time_stamp.v - datain.time_shift.v;
    vcl{id}.time_stamp.u = (datain.time_stamp.u.^2 + datain.time_shift.u.^2).^0.5; 
    vcl{id}.tsh = 0; % high-side channel shift (do not change!)
    vcl{id}.is_diff = cfg.i_is_diff; % note: should be always false
    % -- build DUT virtual channel (U):
    id = id + 1;        
    vcl{id}.tran = 'shunt';
    vcl{id}.name = 'u'; 
    vcl{id}.y = datain.u.v;
    %vcl{id}.tab = conv_vchn_tabs(tab,'u',tab_list);       
    vcl{id}.time_stamp.v = datain.time_stamp.v;
    vcl{id}.time_stamp.u = datain.time_stamp.u;
    vcl{id}.tsh = 0; % high-side channel shift (do not change!)
    vcl{id}.is_diff = cfg.u_is_diff;
    if cfg.u_is_diff
        vcl{id}.y_lo = datain.u_lo.v;
    end
    
    %datain.time_stamp.v
    %datain.time_shift.v
    
    k_unc = loc2covg(calcset.loc,50);        
    
    % list of channel specific correction quantities:
    % ###todo: check there is nothing missing?
    v_list = {'adc_bits','adc_nrng','adc_lsb','adc_jitter','adc_aper_corr','adc_jitter','adc_offset','adc_gain_f','adc_gain_a','adc_gain','adc_phi_f','adc_phi_a','adc_phi','adc_sfdr_f','adc_sfdr_a','adc_sfdr','adc_Yin_f','adc_Yin_Cp','adc_Yin_Gp','tr_gain_f','tr_gain_a','tr_gain','tr_phi_f','tr_phi_a','tr_phi','tr_Zlo_f','tr_Zlo_Rp','tr_Zlo_Cp','tr_Zca_f','tr_Zca_Ls','tr_Zca_Rs','tr_Yca_f','tr_Yca_Cp','tr_Yca_D','Zcb_f','Zcb_Ls','Zcb_Rs','Ycb_f','Ycb_Cp','Ycb_D','time_shift_lo','tr_Zbuf_f','tr_Zbuf_Rs','tr_Zbuf_Ls'};        
        
    % corrections interpolation mode:
    % ###note: do not change, this works best for frequency characteristics
    %i_mode = 'pchip';   
                
    % for each virtual channel:
    %  1. REF (i) channel
    %  2. DUT (u) channel
    for k = 1:numel(vcl)
        % get channel:
        vc = vcl{k};
        
        % Dual execution when 2x4T mode emulation of 4TP measurement is selected
        % otherwise single execution.
        for d4t = 1:min((is_2x4T+1),k)
        
            % Dual execution for DUT (u):
            %   1. pass: get approximate value of dut Z
            %   2. pass: get accurate value including proper loading corrections
            % Single execution for REF (i):
            for m = 1:k
            
                % build harmonic estimator parameters:
                cset = struct();
                cset.verbose = 0;
                cset.loc = 0.681;
                if vc.name == 'i' || (m == 2)
                    % uncertainty calculation allowed:
                    cset.unc = calcset.unc;
                else
                    % no uncertainty needed - disable:
                    cset.unc = 'none';                    
                end            
                cset.checkinputs = 0;
                din = struct();
                din.fs.v = fs; % sampling rate
                din.f_est.v = f_est; % fundamental frequency           
                if ~isnan(f_est)
                    din.f_nom.v = f_est; % fundamental frequency for WFFT mode only
                end
                din.adc_aper = datain.adc_aper; 
                din.tr_type.v = 'shunt'; % reference impedance type - always shunt type
                % copy correction values        
                if is_2x4T
                    % 2x4T mode (first execution: high side correction, second execution: low-side correction):
                    for v = 1:numel(v_list)         
                        if d4t == 1 && isfield(datain,[vc.name '_' v_list{v}])
                            din = setfield(din, v_list{v}, getfield(datain,[vc.name '_' v_list{v}]));
                        elseif isfield(datain,[vc.name '_lo_' v_list{v}])
                            din = setfield(din, v_list{v}, getfield(datain,[vc.name '_lo_' v_list{v}]));
                        end
                    end
                else
                    % 4T mode (single ended corrections) or 4TP mode (high-side and low-side corrections):
                    for v = 1:numel(v_list)         
                        if isfield(datain,[vc.name '_' v_list{v}])
                            din = setfield(din, v_list{v}, getfield(datain,[vc.name '_' v_list{v}]));
                        end
                        if vc.is_diff && isfield(datain,[vc.name '_lo_' v_list{v}])
                            din = setfield(din, ['lo_' v_list{v}], getfield(datain,[vc.name '_lo_' v_list{v}]));
                        end
                    end
                end
                % timeshift correction
                din.time_stamp = vc.time_stamp;
                
                % copy waveform(s) data
                if is_2x4T && d4t == 1
                    din.y.v = vc.y;                                    
                elseif vc.is_diff && is_2x4T && d4t == 2
                    din.y.v = vc.y_lo;
                else
                    din.y.v = vc.y;
                    if vc.is_diff
                        din.y_lo.v = vc.y_lo;
                    end
                end
                
                if vc.name == 'u'
                    % processing DUT channel:
                    
                    % start generating fake DUT tfer:
                    din.tr_gain_f.v = [];
                    din.tr_gain_a.v = [];
                    din.tr_phi_f.v = [];
                    din.tr_phi_a.v = [];
                    
                    if m == 1
                        % -- 1. pass: setup unity DUT tfer so we get approximate unscalled DUT amplitude:
                        
                        din.tr_type.v = ''; % simplified correction
                        din.tr_gain.v = [1]; 
                        din.tr_gain.u = [0];                    
                        din.tr_phi.v = [0]; 
                        din.tr_phi.u = [0];                                        
                        
                    else
                        % -- 2. pass: generate fake tfer based on 1. pass impedance estimate:
                        
                        % 1. pass DUT impedance estimate:
                        %  note: only rough estimate without loading corrections
                        Zx1 = dout.A.v/vcl{1}.A.v;
                        px1 = dout.phi.v - vcl{1}.phi.v;
                        
                        % generate fake DUT tfer:
                        %  note: it is needed so the estimator will apply correct loading correction, 
                        %        but the non-zero transducer tfer itself will be discarded later!
                        din.tr_gain.v = [1./Zx1]; 
                        din.tr_gain.u = [0];                    
                        din.tr_phi.v = [-px1]; 
                        din.tr_phi.u = [0];
                        
                    end
                end
                
                % estimate harmonic                            
                if strcmpi(mode,'PSFE')
                    din.comp_timestamp.v = 1;
                    dout = qwtb('TWM-PSFE',din,cset);
                    dout.dc.v = 0;
                    dout.dc.u = 0;
                elseif strcmpi(mode,'FPNLSF')
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
                
                if vc.name == 'u' && (m == 1)
                    % return DC voltage offset on DUT
                    dataout.Udc = dout.dc;
                    if vc.is_diff && strcmpi(mode,'WFFT') && ~is_2x4T
                        % 4TP mode
                        dataout.Udc_hi = dout.dc_hi;
                        dataout.Udc_lo = dout.dc_lo;
                    elseif vc.is_diff && strcmpi(mode,'WFFT') && is_2x4T && d4t == 1
                        % 2x4T mode - high side
                        dataout.Udc_hi = dout.dc;
                    elseif vc.is_diff && strcmpi(mode,'WFFT') && is_2x4T && d4t == 2
                        % 2x4T mode - low side
                        dataout.Udc_lo = dout.dc;                                        
                    end
                elseif vc.name == 'i' && (m == 1)
                    % return DC current bias
                    
                    % get approximate transducer DC gain
                    ag = correction_interp_table(tab.i_tr_gain, abs(dout.dc.v), 0, 'f',1, 'nearest');                                                           
                    
                    % return DC current bias
                    dataout.Idc = dout.dc;
                    % return approximate DC voltage offset on reference impedance
                    dataout.Udc_ref.v = dout.dc.v/ag.gain;
                    dataout.Udc_ref.u = dout.dc.u/ag.gain;                                        
                end      
                            
                if vc.name == 'u' && m == 1
                    % -- DUT spectrum storage
                    if d4t == 1
                        % try to store DUT voltage spectrum (first 4T part of 2x4T mode)
                        if isfield(dout,'spec_A')
                            spec_U = dout.spec_A.v;
                        end                    
                    elseif d4t == 2
                        % try to combine two 4T measurements spectra for 2x4T mode
                        if isfield(dout,'spec_A')
                            spec_U = spec_U - dout.spec_A.v;
                        end                        
                    end                    
                    
                elseif vc.name == 'u' && (m > 1)
                    % -- DUT channel, 2. pass:
                    
                    % invert DUT connection mode? (0 or 180 deg)
                    inv_phi = is_invert*pi;
                                    
                    % phase shift arg(Zdut/Zref):
                    px2   = dout.phi.v - vcl{1}.phi.v;
                    Zx2   = dout.A.v/vcl{1}.A.v;
                    u_px2 = (dout.phi.u^2 + vcl{1}.phi.u^2)^0.5;
                    u_Zx2 = Zx2*((dout.A.u/dout.A.v)^2 + (vcl{1}.A.u/vcl{1}.A.v)^2)^0.5;
    
                    % fundamental frequency:
                    if strcmpi(mode,'WFFT')
                        % override frequency by initial estimate (WFFT only)
                        %  ###note: we need this because WFFT cannot measure exact frequency in non-coherent mode
                        %           so we assume user knows exact value and used it as f_est
                        f0   = f_est;
                        u_f0 = 0.0;
                    else
                        f0   = vcl{1}.f0.v;
                        u_f0 = vcl{1}.f0.u;
                    end
                                        
                    % U-I channel time shift - phase shift correction for f0:
                    %   note: averaging for multirecord WFFT mode                  
                    %  phts = 2*pi*mean(datain.time_shift.v)*f0;
                    %u_phts = 2*pi*((mean(datain.time_shift.u)*f0)^2 + (u_f0*mean(datain.time_shift.v))^2)^0.5;
                      phts = 0;
                    u_phts = 0;
                    
                    % monte carlo cycles
                    mcc = 10000;
                    
                    % 2. pass DUT impedance estimate:
                    %  ###note: here we discard the first pass Zx1-px1 values
                      Zx = Zx2*Zx1;
                    u_Zx = u_Zx2*Zx1;                                              
                      px = mod((px2 + px1 - phts + inv_phi) + pi, 2*pi) - pi;
                    u_px = (u_px2^2 + u_phts^2)^0.5;                
                      Zdut = Zx*exp(j*px);
                    u_Zdut = (Zx + u_Zx*randn(mcc,1)).*exp(j*(px + u_px*randn(mcc,1)));
                                        
                    if d4t == 1
                        % perform always for 4TP or 4T mode or in first pass of 2x4T mode (live terminals 4T part):                        
                        dataout.f.v = f0;
                        dataout.f.u = k_unc*u_f0;
                        dataout.Iref.v = vcl{1}.A.v*2^-0.5;
                        dataout.Udut.v = dataout.Iref.v*abs(Zdut);
                        dataout.Pdut.v = dataout.Iref.v.^2*real(Zdut);
                        
                        % store 4T impednace for live conductors for next execution pass (2x4T mode only)
                          Zdut_live = Zdut;
                        u_Zdut_live = u_Zdut;
                        
                    end
                    if d4t == 2
                        % 2x4T mode: combine two 4T measurements:
                        
                        %error('time_shift_lo is not correctly implemented yet for 2x4T mode!');
                        
                        % apply time shift between high and low-side ADC
                          phts = 2*pi*datain.u_time_shift_lo.v*f0;
                        u_phts = 2*pi*((datain.u_time_shift_lo.u*f0)^2 + (u_f0*datain.u_time_shift_lo.v)^2)^0.5;
                          Zdut = Zdut*exp(-j*phts);
                        u_Zdut = u_Zdut.*exp(-j*(phts + u_phts*randn(mcc,1)));
                        
                        % return shield impedance                        
                        dataout.Z_mod_sh.v = abs(Zdut);
                        dataout.Z_phi_sh.v = angle(Zdut);
                        [u_mag,u_arg] = cunc_mc_magarg(u_Zdut);
                        dataout.Z_mod_sh.u = k_unc*u_mag;
                        dataout.Z_phi_sh.u = k_unc*u_arg;
                        % convert to desired equivalent circuit:
                        ec = z_to_equivalent(ecid-1,f0,Zdut,k_unc*cunc_mc_reim(u_Zdut));
                        dataout.mjr_sh.v = ec.mjr;
                        dataout.mjr_sh.u = ec.umjr;
                        dataout.mnr_sh.v = ec.mnr;
                        dataout.mnr_sh.u = ec.umnr;
                         
                        % combine two 4T measurements into equivalent 4TP mode
                        %  assuming we measure lives and shields in same polarity, i.e. both lows-of-ADCs at Lpot side of DUT
                          Zdut = Zdut_live - Zdut;
                        u_Zdut = u_Zdut_live - u_Zdut;
                        
                    end                    
                    if d4t == 2 || ~is_2x4T
                        % performed always (4T, 4TP and in second pass of 2x4T):
                        
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
                        
                    end
                                                    
                elseif vc.name == 'i' && isfield(dout,'spec_A')
                    % try to store ref current spectrum
                    spec_f = dout.spec_f.v;
                    spec_I = dout.spec_A.v;                    
                end

            end
        
        end
        
        % store estimated harmonic to the virtual channel record for next pass:
        vc.f0  = dout.f;
        vc.A   = dout.A;
        vc.phi = dout.phi;                        
        vcl{k} = vc;
    end
    
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
