function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm TWM-PWRTDI.
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
    
    % AC coupling mode:
    %  exclude DC components of U/I
    is_ac = isfield(datain,'ac_coupling') && datain.ac_coupling.v;         
         
    if cfg.u_is_diff || cfg.i_is_diff
        % Input data 'y' is differential: if it is not allowed, put error message here
        %error('Differential input data ''y'' not allowed!');     
    end
    
    if cfg.is_multi_records
        % Input data 'y' contains more than one record: if it is not allowed, put error message here
        error('Multiple input records in ''y'' not allowed!'); 
    end
    
    if mod(size(datain.u.v,1),2)
        % samples count not multiple of 2!
        if calcset.verbose
            warning('Cropping waveform to size of multiple of two.');
        end
        
        % crop to proper length: 
        datain.u.v = datain.u.v(1:end-1);
        datain.i.v = datain.i.v(1:end-1);
        if cfg.u_is_diff
            datain.u_lo.v = datain.u_lo.v(1:end-1);
        end
        if cfg.i_is_diff
            datain.i_lo.v = datain.i_lo.v(1:end-1);
        end
        
    end
    
    % reference channel for phase calculation:  
    if ~isfield(datain,'ref_channel')
        ref = 'u';
    elseif strcmpi(datain.ref_channel.v,'i')
        ref = 'i';
    elseif strcmpi(datain.ref_channel.v,'u')
        ref = 'u';
    else
        error(sprintf('TWM-PWRFFT parameter ''ref_channel'' value ''%s'' not recognizer! Only ''u'' or ''i'' supported.',datain.ref_channel.v));
    end              
    
    
    
    % Rebuild TWM style correction tables:
    % This is not necessary, but the TWM style tables are more comfortable to use then raw correction matrices
    tab = qwtb_restore_correction_tables(datain,cfg);
    
    
    
    % --------------------------------------------------------------------
    % RMS power calculation using time-domain-integration (TDI) of 
    % windowed (w) u/i signals:
    %
    %  P  = mean(u(k)*i(k)*w(k)^2)/mean(w(k)^2); for k = 1..N
    %  U  = mean(u(k)^2*w(k)^2)^0.5/mean(w(k)^2)^0.5; for k = 1..N
    %  I  = mean(i(k)^2*w(k)^2)^0.5/mean(w(k)^2)^0.5; for k = 1..N
    %  S  = U*I;
    %  Q  = (S^2 - P^2)^0.5;
    %  PF = P/S;
    %
    % The algorithm also incorporates DC component (optional).
    % Note the Q is calculated before DC is added! 
    % PF is calculated including DC components which is maybe not correct.
    %    
    % Frequency dependent corrections of the gain/phase are made using
    % FFT filtering. The filtering method is based on the JV's 
    % sampling wattmeter.
    %
    
    
      
    % --- For easier processing we convert u/i channels to virtual channels array ---
    % so we can process the voltage and current using the same code...

    % list of involved correction tables without 'u_' or 'i_' prefices
    tab_list = {'tr_gain','tr_phi','tr_Zca','tr_Yca','tr_Zcal','tr_Zcam','adc_Yin','lo_adc_Yin','Zcb','Ycb','tr_Zlo','adc_gain','adc_phi','lo_adc_gain','lo_adc_phi','tr_sfdr','adc_sfdr','lo_adc_sfdr','tr_Zbuf'};
    clear vcl; id = 0; % virt. chn. list     
    % -- build virtual channel (U):
    id = id + 1;
    vcl{id}.tran = datain.u_tr_type.v;
    vcl{id}.name = 'u'; 
    vcl{id}.is_diff = cfg.u_is_diff;
    vcl{id}.y = datain.u.v;
    vcl{id}.ap_corr = datain.u_adc_aper_corr.v;
    vcl{id}.adc_ofs = datain.u_adc_offset;
    if cfg.u_is_diff
        vcl{id}.y_lo = datain.u_lo.v;
        vcl{id}.tsh_lo = datain.u_time_shift_lo; % low-high side channel time shift
        vcl{id}.ap_corr_lo = datain.u_lo_adc_aper_corr.v;
        vcl{id}.adc_ofs_lo = datain.u_lo_adc_offset;    
    end        
    vcl{id}.tab = conv_vchn_tabs(tab,'u',tab_list);       
    vcl{id}.tsh = 0; % high-side channel shift (do not change!)    
    % -- build virtual channel (I):
    id = id + 1;
    vcl{id}.tran = datain.i_tr_type.v;
    vcl{id}.name = 'i';
    vcl{id}.is_diff = cfg.i_is_diff;
    vcl{id}.y = datain.i.v;
    vcl{id}.ap_corr = datain.i_adc_aper_corr.v;
    vcl{id}.adc_ofs = datain.i_adc_offset;
    if cfg.i_is_diff
        vcl{id}.y_lo = datain.i_lo.v;
        vcl{id}.tsh_lo = datain.i_time_shift_lo;
        vcl{id}.ap_corr_lo = datain.i_lo_adc_aper_corr.v;
        vcl{id}.adc_ofs_lo = datain.i_lo_adc_offset;
    end            
    vcl{id}.tab = conv_vchn_tabs(tab,'i',tab_list);    
    vcl{id}.tsh = 0; % high-side channel shift (do not change!)
    

    % corrections interpolation mode:
    % ###note: do not change, this works best for frequency characteristics
    i_mode = 'pchip';
    
    % samples count:
    N = size(datain.u.v,1);    

    % size of the FFT filter:
    %  note: is selected automatically based on the source samples count
    fft_size = 2^nextpow2(N/4);
    
    
    
    % --- Pre-processing ---
   
    % window for spectral analysis:
    %  note: this is not the window for the main RMS algorithms itself!
    %        This is just to calculate signal spectrum for purposes of corrections, uncertainty, etc.
    win_type = 'flattop_144D';
         
    
    % --- get channel spectra:    
    % for each virtual (u/i) channel:
    for k = 1:numel(vcl)
        % get channel:
        vc = vcl{k};
        
        % get spectrum:
        din = struct();
        din.fs.v = fs;
        din.window.v = win_type;
        cset.verbose = 0;
        din.y.v = vc.y;                
        dout = qwtb('SP-WFFT',din,cset);
        %qwtb('TWM-PWRTDI','addpath'); % ###todo: fix qwtb so it does not loose the path every time another alg. is called
        fh    = dout.f.v(:); % freq. vector of the DFT bins
        vc.Y  = dout.A.v(:); % amplitude vector of the DFT bins
        vc.ph = dout.ph.v(:); % phase vector of the DFT bins
        w     = dout.w.v; % window coefficients
        
        % estimate DC offset of channel:           
        vc.dc = vc.Y(1);
        vc.dc_adc = vc.dc; 
        % remove DC from time-domain signal:
        vc.y = vc.y - vc.dc;

        
        % store working spectrum for later:
        Y_tmp = vc.Y;
        
        if vc.is_diff
            % -- differential mode (low-side):
            
            % get spectrum:
            din.y.v = vc.y_lo;                
            dout = qwtb('SP-WFFT',din,cset);
            %qwtb('TWM-PWRTDI','addpath'); % ###todo: fix qwtb so it does not loose the path every time another alg. is called
            fh       = dout.f.v(:); % freq. vector of the DFT bins
            vc.Y_lo  = dout.A.v(:); % amplitude vector of the DFT bins
            vc.ph_lo = dout.ph.v(:); % phase vector of the DFT bins
            
            % estimate DC offset of channel:           
            vc.dc_lo = vc.Y_lo(1);
            vc.dc_lo_adc = vc.dc_lo;
            % remove DC from time-domain signal:
            vc.y_lo = vc.y_lo - vc.dc_lo;            
            
        end
        
        vcl{k} = vc;
    end
    fh = fh(:);
        
    %  get window scaling factor:
    w_gain = mean(w);
    %  get window rms:
    w_rms = mean(w.^2).^0.5;    
    % window half-width:
    w_size = 9;
    % window side-lobe:
    w_slob = 10^(-144/20);   
    
    
    
    % --- Process the channels with corrections ---
    % note: this secion just calculates correction values in freq. domain
    %       the actual correction of the time-domain signal follows in next section
        
    % get ADC aperture value [s]:
    ta = abs(datain.adc_aper.v);
    
    % calculate aperture gain/phase correction:
    fap = fh + 1e-12; % needed for DC work
    ap_gain = (pi*ta*fap)./sin(pi*ta*fap);
    ap_phi  =  pi*ta*fh; % phase is not needed - should be identical for all channels?
             
    
    % --- for each virtual (u/i) channel:
    for k = 1:numel(vcl)
        % get channel:
        vc = vcl{k};
        
        % current channel?
        is_current = strcmpi(vc.name,'i');
                
        % correct ADC offset:
        vc.Y(1) = vc.Y(1) - vc.adc_ofs.v; % remove DC offset from working spectrum

        vc.dc = vc.dc - vc.adc_ofs.v; % fix DC estimate by the offset
        vc.u_dc = vc.adc_ofs.u;
                
        % get gain/phase correction for the freq. components (high-side ADC):
        ag = correction_interp_table(vc.tab.adc_gain, abs(vc.Y), fh, 'f',1, i_mode);
        ap = correction_interp_table(vc.tab.adc_phi,  abs(vc.Y), fh, 'f',1, i_mode);
        
        if any(isnan(ag.gain))
            error('High-side ADC gain correction: not sufficient range of correction data!');
        end
        if any(isnan(ap.phi))
            error('High-side ADC phase correction: not sufficient range of correction data!');
        end
        
        % apply aperture corrections (when enabled and some non-zero value entered for the aperture time):
        if vc.ap_corr && ta > 1e-12
            ag.gain = ag.gain.*ap_gain;
        end
        
        if is_current
            % current channel:
                       
            % add (i-u) channel timeshift correction:
            ap.phi   = ap.phi + datain.time_shift.v.*fh*2*pi; 
            ap.u_phi = (ap.u_phi.^2 + (datain.time_shift.u.*fh*2*pi).^2).^0.5;
            
        end
            
         
        % apply high-side adc tfer to the spectrum estimate:        
        vc.Y  = vc.Y.*ag.gain;
        vc.ph = vc.ph + ap.phi;
        vc.Y_hi = vc.Y; % temp. high-side
        
        
        % store high-side ADC tfer:
        vc.adc_gain = ag;
        vc.adc_phi = ap;
        
        % obtain ADC LSB value:
        vc.lsb = adc_get_lsb(datain,[vc.name '_']);
        % apply ADC gain to it:
        vc.lsb = vc.lsb.*ag.gain;
                 
        
        if vc.is_diff
            % -- differential mode:
            
            % correct ADC offset:
            vc.Y_lo(1) = vc.Y_lo(1) - vc.adc_ofs_lo.v;
            vc.dc_lo = vc.dc_lo - vc.adc_ofs_lo.v;
            vc.u_dc_lo = vc.adc_ofs_lo.u;

        
            % get gain/phase correction for the freq. components (low-side ADC):
            agl = correction_interp_table(vc.tab.lo_adc_gain, abs(vc.Y_lo), fh, 'f',1, i_mode);
            apl = correction_interp_table(vc.tab.lo_adc_phi,  abs(vc.Y_lo), fh, 'f',1, i_mode);
            
            if any(isnan(agl.gain))
                error('Low-side ADC gain correction: not sufficient range of correction data!');
            end
            if any(isnan(apl.phi))
                error('Low-side ADC phase correction: not sufficient range of correction data!');
            end              
            
            % apply aperture corrections (when enabled and some non-zero value entered for the aperture time):
            if vc.ap_corr && ta > 1e-12
                agl.gain = agl.gain.*ap_gain;
            end
            
            % apply low-side time shift correction:
            apl.phi   = apl.phi - vc.tsh_lo.v*fh*2*pi;
            apl.u_phi = (apl.u_phi.^2 + (vc.tsh_lo.u*fh*2*pi).^2).^0.5;
            
            if is_current
                % current channel:
                
                % add (i-u) channel timeshift correction:
                apl.phi   = apl.phi + datain.time_shift.v.*fh*2*pi; 
                apl.u_phi = (apl.u_phi.^2 + (datain.time_shift.u.*fh*2*pi).^2).^0.5;            
            end
            
            % apply low-side adc tfer to the spectrum estimate:        
            vc.Y_lo  = vc.Y_lo.*agl.gain;
            vc.ph_lo = vc.ph_lo + apl.phi;
            
            % store low-side ADC tfer:
            vc.adc_gain_lo = agl;
            vc.adc_phi_lo = apl;
            
            % obtain ADC LSB value for low-side:
            vc.lsb_lo = adc_get_lsb(datain,[vc.name '_lo_']);
            % apply ADC gain to it:
            vc.lsb_lo = vc.lsb_lo.*agl.gain;          
                        
            
            % estimate transducer correction tfer from the spectrum estimates:
            % note: The transfer is aproximated from windowed-FFT bins 
            %       despite the sampling was is coherent.
            %       The absolute values of the DFT bin vectors are wrong
            %       due to the window effects, but the ratio of the high/low-side vectors
            %       is unaffected (hopefully), so they can be used to calculate the tfer
            %       which is then normalized to the used difference of high-low side spectra.
            % note: the corrections is relative correction to the difference of digitizer voltages (y - y_lo)
            % note: using window gain so the rms of signal is correct
            % high-side:            
              Y  = vc.Y.*exp(j*vc.ph);
            u_Y  = vc.Y.*(ag.u_gain./ag.gain);
            u_ph = ap.u_phi;
            % low-side:
              Y_lo  = vc.Y_lo.*exp(j*vc.ph_lo);
            u_Y_lo  = vc.Y_lo.*(agl.u_gain./agl.gain);
            u_ph_lo = apl.u_phi;
            % estimate digitizer input rms level:
            dA = abs(Y - Y_lo);
            rms_ref = sum(0.5*dA.^2).^0.5*w_gain/w_rms;            
            % calculate transducer tfer:
            fh_dc = fh; fh_dc(1) = 1e-3; % override DC frequency by non-zero value
            [trg,trp,u_trg,u_trp] = correction_transducer_loading(vc.tab,vc.tran,fh_dc,[], abs(Y),angle(Y),u_Y,u_ph, abs(Y_lo),angle(Y_lo),u_Y_lo,u_ph_lo, 'rms',rms_ref);
            % store relative tfer:
            %vc.tr_gain = trg./abs(Y - Y_lo);
            %vc.tr_phi  = trp - angle(Y - Y_lo);
            %vc.u_tr_gain = u_trg./abs(Y - Y_lo);
            %vc.u_tr_phi = u_trp;
            
            
                        
            % combine ADC and transducer tfers:
            %  note: so we will apply just one filter instead of two
            vc.tr_gain = trg./abs(Y - Y_lo);
            tr_phi = trp - angle(Y - Y_lo);
            vc.adc_gain.gain = vc.adc_gain.gain.*vc.tr_gain;                                                                                  
            vc.adc_phi.phi   = vc.adc_phi.phi + tr_phi;                                 
            vc.adc_gain_lo.gain = vc.adc_gain_lo.gain.*vc.tr_gain;                                                                                  
            vc.adc_phi_lo.phi   = vc.adc_phi_lo.phi + tr_phi;
            
            % calculate effective differential LSB value:            
            vc.lsb = (vc.lsb.^2 + vc.lsb_lo.^2).^0.5.*vc.tr_gain;
                                    
            % store differential signal spectrum estimate after the correction:
            %  i.e. this is now equivalent of single-ended channel spectrum 
            vc.Y = trg;
            vc.Y(1) = vc.Y(1)*(2*(abs(trp(1)) < 0.1) - 1); % restore DC component polarity            
            vc.ph = trp;
            vc.u_Y = u_trg;
            vc.u_ph = u_trp;
            
            %figure
            %semilogx(fh,vc.Y)
            
            

        else
            % -- single-ended mode:
            
            % estimate digitizer input rms level:
            rms_ref = sum(0.5*vc.Y.^2).^0.5*w_gain/w_rms;
            
            % estimate transducer correction tfer from the spectrum estimate:            
            %zz = zeros(size(vc.Y));
            Y = abs(vc.Y); % amplitudes, rectify DC
            u_Y = Y.*(ag.u_gain./ag.gain); % amp. uncertainties
            u_ph = ap.u_phi;
            fh_dc = fh; fh_dc(1) = 1e-3; % override DC frequency by non-zero value
            %vc.tab = rmfield(vc.tab,'tr_Zbuf'); % ###debug
            [trg,trp,u_trg,u_trp] = correction_transducer_loading(vc.tab,vc.tran,fh_dc,[], Y,0*Y,u_Y,u_ph, 'rms',rms_ref);
            Y = max(Y,eps); % to prevent div-by-zero
            trg = trg./Y;
            u_trg = u_trg./Y;
            %Y = Y.*sign(vc.Y); % restore DC polarity
                        
            %semilogx(fh,vc.adc_phi.phi)
            %semilogx(fh,vc.adc_gain.gain)
            %semilogx(fh,trp)
            %semilogx(fh,trg)
            
            % combine ADC and transducer tfers:
            %  note: so we will apply just one filter instead of two            
            vc.adc_gain.gain = vc.adc_gain.gain.*trg;                                                                                  
            vc.adc_phi.phi   = vc.adc_phi.phi + trp;
            %vc.adc_gain.u_gain = vc.adc_gain.gain.*u_trg; % note the uncertainty from the ADC correction is already part of u_trg, so override ADC unc
            %vc.adc_phi.u_phi = u_trp; % note the uncertainty from the ADC correction is already part of u_trp, so override ADC unc
            
            % apply tfer to LSB:
            vc.lsb = vc.lsb.*trg;
            
            % apply transducer tfer to the spectrum estimate: 
            vc.u_Y = abs(vc.Y.*u_trg);
            vc.u_ph = u_trp;
            vc.Y = vc.Y.*trg;
            vc.ph = vc.ph + trp;
            
            % store transducer gain:
            vc.tr_gain = trg;
                        
        end
        
        if any(isnan(trg))
            error('Transducer gain correction: not sufficient range of correction data!');                
        end
        if any(isnan(trp))
            error('Transducer phase correction: not sufficient range of correction data!');
        end
                
        vcl{k} = vc;
    end
    
    
    
    
    % --- Calculate RMS values of the U, I and P ---
    %  this is the main RMS levels and power calculation    
    
    % build calculator setup:
    sig = struct();
    sig.vc = vcl; % list of v.channels
    sig.is_sim = 0; % disable simulator
    sig.i_mode = i_mode;
    sig.fs = fs;
    sig.fh = fh; % reference frequency vector for all correction tables '*adc_*'
    sig.fft_size = fft_size;    
    
    % perform the calculation:  
    result = proc_wrms(sig);
    % the calculation updates some values in the v.channels list, so update it:    
    vcl = result.vc;
         
    
    
    
    
    % --- Calculate uncertainty ---
    
    
    
    % return spectra of the corrected waveforms:   
    Uh = vcl{1}.Y;
    Ih = vcl{2}.Y;
    ph = vcl{2}.ph - vcl{1}.ph; % I-U phase difference
    if ref == 'i'
        ph = -ph; % U-I mode
    end 
    u_Uh = vcl{1}.u_Y;
    u_Ih = vcl{2}.u_Y;
    u_ph = (vcl{1}.u_ph.^2 + vcl{2}.u_ph.^2).^0.5;
    N = numel(Uh);

    % decide fundamental detection channel (default 'u')
    ref_is_u = 1;
    if isfield(datain,'fund_channel') && strcmpi(datain.fund_channel.v,'u')
        ref_is_u = 1;
    elseif isfield(datain,'fund_channel') && strcmpi(datain.fund_channel.v,'i')
        ref_is_u = 0;
    elseif isfield(datain,'fund_channel')
        error('Parameter ''fund_channel'' has invalid value! Only ''u'' or ''i'' are allowed.');
    end
        
    % no peak harmonics defined yet:
    U_max = -1;
    I_max = -1;
    
    % stop harmonics search when lower than ? of dominant:
    h_ratio = max(10e-6,w_slob);
    
    % minimum processed harmonics even if they are small:
    %h_min = 5; 
    
    % max. analyzed harmonics (for noise estimate):
    h_max = 100;
    
    % max. analyzed harmonics (for uncertainty components):
    h_max_proc = min(h_max,10);
    
    % not processed DFT bins:
    msk = [w_size:N-3];
    
    % identify harmonic/interharmonic components:
    is_u = ref_is_u;
    h_list = [];
    for h = 1:h_max
        
        % look for highest harmonic:
        if is_u
            [v,id] = max(Uh(msk));
        else
            [v,id] = max(Ih(msk));
        end        
        hid = msk(id);
        
        % detect if we are done:
        if U_max >= 0 && (Uh(hid) < U_max*h_ratio && Ih(hid) < I_max*h_ratio)
            % we can stop search, no relevant harmonics there
            if ref_is_u == is_u
                is_u = 1 - is_u; % switch search to second channel
            else
                break
            end
        end
        U_max = max(U_max,Uh(hid)); 
        I_max = max(I_max,Ih(hid));
        
        % found harmonics list:
        h_list(h) = hid;
        
        % DFT bins occupied by the harmonic
        h_bins = max((msk(id) - w_size),1):min(msk(id) + w_size,N);
        
        % remove harmonic bins from remaining list:
        msk = setdiff(msk,h_bins);       
    end
    H = numel(h_list);
    H = min(H,h_max_proc);        
    
    % build list of relevant harmonics:
    fx = fh(h_list);
    Ux = Uh(h_list);
    Ix = Ih(h_list);
    Sx = (0.5*Ux.*Ix);
    phx = ph(h_list);
    u_Ux = top_bin_unc(u_Uh,h_list);
    u_Ix = top_bin_unc(u_Ih,h_list);
    u_phx = top_bin_unc(u_ph,h_list);
    Ux_lsb = top_bin_unc(vcl{1}.lsb,h_list);
    Ix_lsb = top_bin_unc(vcl{2}.lsb,h_list);

    
    if isfield(calcset,'dbg_plots') && calcset.dbg_plots
        figure;
        subplot(2,1,1);
        loglog(fh,Uh)
        hold on;
        loglog(fh(msk),Uh(msk),'r')
        loglog(fx,Ux,'ko')       
        hold off;
        title('Spectrum analysis');
        xlabel('f [Hz]');
        ylabel('U [V]');
        legend('full','no harmonics');
        
        subplot(2,1,2);
        loglog(fh,Ih)
        hold on;
        loglog(fh(msk),Ih(msk),'r')
        loglog(fx,Ix,'ko')       
        hold off;
        xlabel('f [Hz]');
        ylabel('I [A]');
        legend('full','no harmonics');
    end
    
    
    % estimate basic parameters from spectrum):
    U_rms = sum(0.5*Uh.^2)^0.5/w_rms*w_gain;
    I_rms = sum(0.5*Ih.^2)^0.5/w_rms*w_gain;
    P = sum((0.5*Ux.*Ix.*cos(phx)));
    S = sum((0.5*Ux.*Ix));
    Q_fft = sum((0.5*Ux.*Ix.*sin(phx)));
    
    % estimate noise levels for the removed harmonics components:
    Uns = interp1(fh(msk),Uh(msk),fh,'nearest','extrap');
    Ins = interp1(fh(msk),Ih(msk),fh,'nearest','extrap');
       
    % estimate RMS noise from windowed spectrum:
    U_noise = sum(0.5*Uns.^2)^0.5/w_rms*w_gain;
    I_noise = sum(0.5*Ins.^2)^0.5/w_rms*w_gain;
    % rms of the identified harmonic components NOT used for uncertainty analysis:
    U_resid = sum(Ux(H+1:end).^2)^0.5;
    I_resid = sum(Ix(H+1:end).^2)^0.5;
    % expand noise by the removed, but unused component:
    U_noise = (U_noise^2 + U_resid^2)^0.5;
    I_noise = (I_noise^2 + I_resid^2)^0.5;
    
    % calculate bits per harmonic pk-pk range:
    Ux_bits = log2(Ux./Ux_lsb)-1;
    Ix_bits = log2(Ix./Ix_lsb)-1;    
    
    % store some of the estimated parameters to v.channel list: 
    vcl{1}.rms = U_rms;
    vcl{2}.rms = I_rms;
    vcl{1}.Y0 = Ux(1);
    vcl{2}.Y0 = Ix(1);
    
    
    % -- estimate SFDR spurs:
    % harmonic spurs of dominant component:
    %  ###todo: maybe it would be more correct to calculate spurs of each harmonic...
    %           but for now lets assume just main harmonic source 
    f_spur(:,1) = (fx(1)*2):fx(1):fs/2;
    
    % spur harmonic bin ids in the original spectrum:
    sid_spur = round(f_spur*N/fs + 1);

        
    for k = 1:numel(vcl)
        % get v.channel
        vc = vcl{k};
        
        % transducer SFDR of dominant component only:
        tr_sfdr = correction_interp_table(vc.tab.tr_sfdr, vc.rms, fx(1), 'f',1, i_mode);
        
        % transducer spur value:
        tr_spur = vc.Y0*10^(-tr_sfdr.sfdr/20);
        
        % high-side ADC amplitude of dominant component: 
        amp_hi = vc.Y_hi(h_list(1));
        
        % high-side ADC SFDR for dominant component only:
        adc_sfdr = correction_interp_table(vc.tab.adc_sfdr, amp_hi, fx(1), 'f',1, i_mode);
        
        if vc.is_diff
            % -- differential mode:
            
            % low-side ADC amplitude of dominant component: 
            amp_lo = vc.Y_lo(h_list(1));
            
            % low-side ADC SFDR for dominant component only:
            adc_sfdr_lo = correction_interp_table(vc.tab.lo_adc_sfdr, amp_lo, fx(1), 'f',1, i_mode);
            
            % absolute spur at ADC level:
            spur = ((amp_hi*10^(-adc_sfdr.sfdr/20))^2 + (amp_lo*10^(-adc_sfdr_lo.sfdr/20))^2)^0.5;
            
            % effective differential SFDR:
            %amp_diff = Ux(1)/vc.tr_gain(h_list(1))
            %adc_sfdr = log10(spur/(amp_diff))*20
            
        else
            % -- single-ended:
            
            % absolute spur at ADC level:
            spur = amp_hi*10^(-adc_sfdr.sfdr/20);
        end
               
        % combine ADC and transducer spurs:
        vcl{k}.spur = ((spur*vc.tr_gain(sid_spur)).^2 + (tr_spur*ones(size(f_spur))).^2).^0.5;
                                
    end
        
    
    
    if strcmpi(calcset.unc,'guf')
        % --- uncertainty estimator:
            
        % -- estimate FFT filter intruduced errors:
        % voltage channel:
        ff = vcl{1}.adc_gain.f;
        fg = vcl{1}.adc_gain.gain;
        fp = vcl{1}.adc_phi.phi;
        [u_fa_U,u_fp_U] = td_fft_filter_unc(fs, numel(datain.u.v), fft_size, ff,fg,fp, i_mode, fx(1:H),Ux(1:H));  
        
        % current channel:
        ff = vcl{2}.adc_gain.f;
        fg = vcl{2}.adc_gain.gain;
        fp = vcl{2}.adc_phi.phi;
        [u_fa_I,u_fp_I] = td_fft_filter_unc(fs, numel(datain.u.v), fft_size, ff,fg,fp, i_mode, fx(1:H),Ix(1:H));
        
        % expand harmonic uncertainties by FFT filter contribution:
        u_Ux(1:H) = (u_Ux(1:H).^2 + u_fa_U.^2).^0.5;
        u_Ix(1:H) = (u_Ix(1:H).^2 + u_fa_I.^2).^0.5;
        u_phx(1:H) = (u_phx(1:H).^2 + u_fp_U.^2 + u_fp_I.^2).^0.5;
              
        
        % -- estimate SFDR uncertainty:
        
        % estimate uncertainty due to the spurs:
        u_U_sfdr = ((sum(0.5*vcl{1}.spur.^2) + U_rms^2)^0.5 - U_rms)/3^0.5;   
        u_I_sfdr = ((sum(0.5*vcl{2}.spur.^2) + I_rms^2)^0.5 - I_rms)/3^0.5;    
        u_P_sfdr = sum(0.5*vcl{1}.spur.*vcl{2}.spur)/3^0.5;
        
        % expand harmonic uncertainties by SFDR (worst case):
        U_sp_x = interp1(f_spur,vcl{1}.spur,fx(2:H),'nearest','extrap');
        I_sp_x = interp1(f_spur,vcl{2}.spur,fx(2:H),'nearest','extrap');        
        u_Ux(2:H) = (u_Ux(2:H).^2 + U_sp_x.^2/3).^0.5;
        u_Ix(2:H) = (u_Ix(2:H).^2 + I_sp_x.^2/3).^0.5;        
        u_phx(2:H) = (u_phx(2:H).^2 + atan2(U_sp_x,Ux(2:H)).^2/3 + atan2(I_sp_x,Ix(2:H)).^2/3).^0.5;
        
        
%         mcc = 1000;
%         Usrms = sum(0.5*Ux.^2)^0.5;
%         Isrms = sum(0.5*Ix.^2)^0.5;
%         Usmc = (2^0.5*sum(bsxfun(@times,(2*rand(numel(f_spur),mcc)-1),vcl{1}.spur).^2,1) + Usrms^2).^0.5;
%         Ismc = (2^0.5*sum(bsxfun(@times,(2*rand(numel(f_spur),mcc)-1),vcl{2}.spur).^2,1) + Isrms^2).^0.5;
%         
%         u_U_sfdr = max(abs(Usmc - Usrms))/3^0.5
%         u_I_sfdr = max(abs(Ismc - Isrms))/3^0.5
%         
%         u_U_sfdr/U_rms
%         u_I_sfdr/I_rms
        
                        
        
        % -- estimate rms alg. single-tone uncertainty:
            
        % load single-tone wrms LUT data:
%         mfld = fileparts(mfilename('fullpath'));    
%         lut = load([mfld filesep() 'wrms_single_tone_unc.lut'],'-mat','lut');
%         lut_st = lut.lut;
        if isfield(calcset,'fetch_luts') && calcset.fetch_luts
            global lut_st;
        else
            lut_st = [];
        end           
        if isempty(lut_st)
            mfld = fileparts(mfilename('fullpath'));
            lut = load([mfld filesep() 'wrms_single_tone_unc.lut'],'-mat','lut');
            lut_st = lut.lut;            
        end
            
        
        
        
 
            
        % corrected signal samples count:
        M = numel(vcl{1}.y);
        
        % noise copy:
        %  ###note: it was disabled from the estimation, because it can be calculated directly
        U_noise_st = 0*U_noise;
        I_noise_st = 0*I_noise;
         
                
        % process all harmonics
        u_P_st = [];
        u_I_st = [];
        u_U_st = [];
        for h = 1:H
        
            % ###note: these two values were outside the loop for fundamental, but that is wrong, because the estimator should
            %          operate with each harmonic separately. So I moved them here to reflect sampling parameters for each component.        
            % periods in the record:
            f0_per = fx(h)*M/fs;        
            % samples per period of harmonic:
            fs_rat = fs/fx(h);
        
            % get U single-tone wrms uncertainty components:
            [dPx,dSx,dUx] = wrms_unc_st(lut_st, Ux(h),Ux(h), U_noise_st,U_noise_st, Ux_bits(h),Ux_bits(h), f0_per,fs_rat);
            
            % get P,S,I single-tone wrms uncertainty components:
            [dPx,dSx,dIx] = wrms_unc_st(lut_st, Ux(h),Ix(h), U_noise_st,I_noise_st, Ux_bits(h),Ix_bits(h), f0_per,fs_rat);
            
            % minimum uncertainty:
            %  ###todo: temporary, remove 
            dPx = max(dPx,0.1e-6);
            dIx = max(dIx,0.1e-6);
            dUx = max(dUx,0.1e-6);
            
            % calculate absolute uncertainty of the components:
            u_P_st(h,1) = dPx.*Sx(h)/3^0.5;
            u_I_st(h,1) = dIx.*Ix(h)/3^0.5;
            u_U_st(h,1) = dUx.*Ux(h)/3^0.5;
            
        end
        
        % sum component uncertainties:
        u_P_st = sum(u_P_st.^2).^0.5;
        u_U_st = sum((u_U_st.*Ux(1:H)).^2).^0.5/sum((Ux(1:H).^2))^0.5;
        u_I_st = sum((u_I_st.*Ix(1:H)).^2).^0.5/sum((Ix(1:H).^2))^0.5;
        
%         u_P_noise = 0;
%         u_U_noise = 1.5*((U_rms.^2 + U_noise.^2)^0.5 - U_rms)/3^0.5;
%         u_I_noise = 1.5*((I_rms.^2 + I_noise.^2)^0.5 - I_rms)/3^0.5;
        
        % Normalized Equivalent Noise BaNdWidth (Rado's book "Sampling with 3458A", page 196, formula 4.36):
        NENBNW = 2.0044; % # blackmanharris() which is used in the WRMS!
        
        % estimate noise caused uncertainty:
        %   note: from Rado's book "Sampling with 3458A", page 209, section 4.10.2):
        %         Verified by Monte Carlo simulation (by Stanislav Maslan)
        %   note: the factor 1.2 was found empirically from Monte Carlo of WRMS algorithm
        u_U_noise  = (NENBNW)^0.5*U_noise*(2/N)^0.5/1.2;
        u_I_noise  = (NENBNW)^0.5*I_noise*(2/N)^0.5/1.2;      
        u_P_noise = ((u_U_noise*I_rms)^2 + (u_I_noise*U_rms)^2)^0.5;

        
        
        
        
        % -- estimate rms alg. spur uncertainty:
            
        % load single-tone wrms LUT data:
%         mfld = fileparts(mfilename('fullpath'));    
%         lut = load([mfld filesep() 'wrms_spurr_unc.lut'],'-mat','lut');
%         lut_sp = lut.lut;
        if isfield(calcset,'fetch_luts') && calcset.fetch_luts
            global lut_sp;
        else
            lut_sp = [];
        end
        if isempty(lut_sp)
            mfld = fileparts(mfilename('fullpath'));
            lut = load([mfld filesep() 'wrms_spurr_unc.lut'],'-mat','lut');
            lut_sp = lut.lut;            
        end
        
        
        % fundamental periods in the record:
        f0_per = fx(1)*M/fs;        
        
        % samples per period of fundamental:
        fs_rat = fs/fx(1);

        % minimum spur ratio to fundamental to take it into account:
        spur_min_rat = 50e-6;
        
        % DFT bin step [Hz]:
        fft_step = fs/M;

        % process all harmonics
        u_P_sp = [];
        u_U_sp = [];
        u_I_sp = [];
        hid_sp = [];
        for h = 2:H
        
            if Ux(h) > spur_min_rat*Ux(1) || Ix(h) > spur_min_rat*Ix(1)            

                % relative spur position:
                f_spur = abs(fx(h) - fx(1))/fft_step;    
                
                % get U single-tone wrms uncertainty components:
                [dPx,dUx,dIx] = wrms_unc_spur(lut_sp, Ux(1),Ix(1), f_spur,Ux(h),Ix(h), f0_per,fs_rat);
                        
                % calc. absolute uncertainty components:
                u_P_sp(end+1,1) = dPx*Sx(1)/3^0.5;
                u_U_sp(end+1,1) = dUx*Ux(1)/3^0.5;
                u_I_sp(end+1,1) = dIx*Ix(1)/3^0.5;                
                hid_sp(end+1) = h;
                            
            end
                    
        end
        if ~isempty(u_P_sp)
            % sum component uncertainties:
            u_P_sp;
            fx(hid_sp)/fx(1);
            u_P_sp = sum(u_P_sp.^2)^0.5;
            u_U_sp = sum((u_U_sp.*Ux(hid_sp)).^2)^0.5/sum((Ux(hid_sp).^2))^0.5;
            u_I_sp = sum((u_I_sp.*Ix(hid_sp)).^2)^0.5/sum((Ix(hid_sp).^2))^0.5;
        else
            u_P_sp = 0;
            u_U_sp = 0;
            u_I_sp = 0;
        end
        
        
        
        % -- uncertainty of corrections:
        %   Note: we have uncertain detection of harmonic frequencies, so we have to calculate uncertainty
        %         of corrections caused by the frequency uncertainty
        
        % approximate worst case error of frequency (0.5 DFT bins):
        u_fdb = ((fh(2) - fh(1))*0.5);
        
        % expand the harmonic uncertainties for each v. channel:
        for v = 1:numel(vcl)
        
            gain_0 = interp1(fh,vcl{v}.adc_gain.gain, (fx+0),     i_mode,'extrap');
            gain_a = interp1(fh,vcl{v}.adc_gain.gain, (fx+u_fdb), i_mode,'extrap');
            gain_b = interp1(fh,vcl{v}.adc_gain.gain, (fx-u_fdb), i_mode,'extrap');
            phi_0  = interp1(fh,vcl{v}.adc_phi.phi, (fx+0),     i_mode,'extrap');
            phi_a  = interp1(fh,vcl{v}.adc_phi.phi, (fx+u_fdb), i_mode,'extrap');
            phi_b  = interp1(fh,vcl{v}.adc_phi.phi, (fx-u_fdb), i_mode,'extrap');
            
            % estimate of standard uncertainty of gain/phase caused by harmonic frequency uncertainty: 
            u_gain_f = max(abs([gain_a, gain_b] - gain_0),[],2)/3^0.5;
            u_phi_f = max(abs([phi_a, phi_b] - phi_0),[],2)/3^0.5;
            
            %u_gain_f./gain_0
                       
            % expand the uncertainty of harmonics:
            if vcl{v}.name == 'u'
                u_Ux = (u_Ux.^2 + (u_gain_f./gain_0.*Ux).^2).^0.5;
            else
                u_Ix = (u_Ix.^2 + (u_gain_f./gain_0.*Ix).^2).^0.5;
            end
            u_phx = (u_phx.^2 + u_phi_f.^2).^0.5;            
        end
        
        
        
        
        
        % estimate corrections related uncertainty from relevant harmonics (worst case estimates):
        %u_U = sum(0.5*u_Ux.^2).^0.5;
        %u_I = sum(0.5*u_Ix.^2).^0.5;
        u_U = (sum(0.5*(Ux + u_Ux).^2)^0.5 - sum(0.5*Ux.^2)^0.5)*1.15;
        u_I = (sum(0.5*(Ix + u_Ix).^2)^0.5 - sum(0.5*Ix.^2)^0.5)*1.15;
        
        % run small MC for the power cos it's non-linear and the GUF does not work very nice in here:
        %   note: it was crippled for Matlab < 2016b, do not remove bsxfun()!
        mmc = 2000; % iterations        
        H = numel(Ux);
        %v_Ux  = bsxfun(@plus,Ux,bsxfun(@times,u_Ux,randn(H,mmc))); % randomize Ux: v_Ux = Ux + u_Ux.*randn(H,mcc)
        %v_Ix  = bsxfun(@plus,Ix,bsxfun(@times,u_Ix,randn(H,mmc))); % randomize Ix: v_Ix = Ix + u_Ix.*randn(H,mcc)
        %v_phx = bsxfun(@plus,phx,bsxfun(@times,u_phx,randn(H,mmc))); % randomize phx: v_phx = phx + u_phx.*randn(H,mcc)
        %v_P   = 0.5*sum(v_Ux.*v_Ix.*cos(v_phx),1);
        %u_P   = sum((0.5*((Ix.*cos(phx).*u_Ux).^2 + (Ux.*cos(phx).*u_Ix).^2 + (Ux.*Ix.*sin(phx).*u_phx).^2).^0.5).^2).^0.5 % GUF method
        %u_P   = std(v_P,[],2)
        %u_P   = est_scovint(v_P,P)*0.5*1.05 % ###note: schmutzig safety coeficient 1.05 empiricaly found so the estimator fail rate reduces < 1% in selftest        
        k_in = 3^0.5;
        v_Ux  = bsxfun(@plus,Ux,bsxfun(@times,u_Ux*k_in,2*rand(H,mmc)-1)); % randomize Ux: v_Ux = Ux + u_Ux.*randn(H,mcc)
        v_Ix  = bsxfun(@plus,Ix,bsxfun(@times,u_Ix*k_in,2*rand(H,mmc)-1)); % randomize Ix: v_Ix = Ix + u_Ix.*randn(H,mcc)
        v_phx = bsxfun(@plus,phx,bsxfun(@times,u_phx*k_in,2*rand(H,mmc)-1)); % randomize phx: v_phx = phx + u_phx.*randn(H,mcc)
        v_P   = 0.5*sum(v_Ux.*v_Ix.*cos(v_phx),1);
        u_P   = max(abs(v_P - P))/k_in*1.25;
        %hist(v_P,50)
                  
        
        % addup uncertainties from the algorithm itself (worst case estimates):
        u_U = (u_U.^2 + u_U_sfdr^2 + u_U_st.^2 + u_U_sp.^2 + u_U_noise.^2).^0.5;
        u_I = (u_I.^2 + u_I_sfdr^2 + u_I_st.^2 + u_I_sp.^2 + u_I_noise.^2).^0.5;
        u_P = (u_P.^2 + u_P_sfdr^2 + u_P_st.^2 + u_P_sp.^2 + u_P_noise.^2).^0.5;
%         u_U = (u_U + u_U_sfdr + u_U_st + u_U_sp);
%         u_I = (u_I + u_I_sfdr + u_I_st + u_I_sp);        
%         u_P = (u_P + u_P_sfdr + u_P_st + u_P_sp);
                
        
    elseif strcmpi(calcset.unc,'mcm')
        % -- Monte-Carlo mode:
        
        % add spurs to all harmonic ucnertainties because we cannot say true amplitudes: 
        U_sp_x = interp1(f_spur,vcl{1}.spur,fx(2:H),'nearest','extrap')/3^0.5*1.2;
        I_sp_x = interp1(f_spur,vcl{2}.spur,fx(2:H),'nearest','extrap')/3^0.5*1.2;        
        u_Ux(2:H) = (u_Ux(2:H).^2 + U_sp_x.^2).^0.5;
        u_Ix(2:H) = (u_Ix(2:H).^2 + I_sp_x.^2).^0.5;        
        u_phx(2:H) = (u_phx(2:H).^2 + atan2(U_sp_x,Ux(2:H)).^2 + atan2(I_sp_x,Ix(2:H)).^2).^0.5;
            
        % prepare waveform simulation parameters:
        harmonics =   [  Ux(1:H),  Ix(1:H)];
        u_harmonics = [u_Ux(1:H),u_Ix(1:H)];
        noises =      [U_noise,  I_noise];       
        lsbs = [Ux(1)/2^Ux_bits(1), Ix(1)/2^Ix_bits(1)];
        jitters = [datain.u_adc_jitter.v, datain.i_adc_jitter.v];
        % add spurs to all harmonic ucnertainties because we cannot say true amplitudes: 
%         spurs = [max(vcl{1}.spur), max(vcl{2}.spur)];
%         u_spurs = repmat(spurs,[H 1]);
%         u_spurs(1,:) = [0, 0]; % nor spur to fundamental harmonics obviously        
%         u_harmonics = (u_harmonics.^2 + u_spurs.^2).^0.5;
       
       
        % decimate frequency axis (to save memory for paralleling): 
        fh_dec = unique(sort([0;fx;f_spur;logspace(log10(1),log10(max(fh)),100)']));
        
               
                                        
        % -- prepare virtual channels to simulate:
        vcp = vcl;        
        for v = 1:numel(vcl)        
            vc = vcp{v};
                            
            % harmoncis list to synthesize:
            vc.sim.A = harmonics(:,v)./vc.adc_gain.gain(h_list(1:H));
            vc.sim.u_A = u_harmonics(:,v)./vc.adc_gain.gain(h_list(1:H));
            if vc.name == 'u'
                vc.sim.ph = -vc.adc_phi.phi(h_list(1:H));
                vc.sim.u_ph = 0*u_phx(1:H);
            else
                vc.sim.ph = phx(1:H) - vc.adc_phi.phi(h_list(1:H));
                vc.sim.u_ph = u_phx(1:H);
            end
            % aux parameters to synthesize:
            vc.sim.noise = noises(v)./vc.adc_gain.gain(h_list(1));
            %vc.sim.spur = vc.spur./interp1(vc.adc_gain.f,vc.adc_gain.gain,f_spur,i_mode,'extrap');
            vc.sim.spur = [];
            vc.sim.lsb = lsbs(v)/vc.adc_gain.gain(h_list(1));
            vc.sim.jitter = jitters(v);       
            
            % reinterpoalte corrections to decimated freqyency axis:
            vc.adc_gain.gain = interp1(fh,vc.adc_gain.gain,fh_dec,i_mode,'extrap');
            vc.adc_phi.phi = interp1(fh,vc.adc_phi.phi,fh_dec,i_mode,'extrap');
                   
            % remove all useless stuff to save memory for the monte-carlo method:
            %  note: this is quite important as the whole structure will be replicated for each cycle of MC! 
            vc = rmfield(vc,{'y','Y','ph','Y_hi','u_Y','u_ph','spur','lsb','tr_gain'});
            vc.adc_gain = rmfield(vc.adc_gain,{'u_gain','f'});
            vc.adc_phi = rmfield(vc.adc_phi,{'u_phi','f'});
            if vc.is_diff
                vc = rmfield(vc,{'y_lo','Y_lo','ph_lo'});
                vc = rmfield(vc,{'adc_gain_lo','adc_phi_lo'});
            end
            
            vcp{v} = vc;
        end      
        
        % store other calculation parameters 
        sig.vc = vcp; % v.channels    
        sig.i_mode = i_mode;
        sig.fs = fs;
        sig.fft_size = fft_size;
        sig.N = size(datain.u.v,1);
        sig.fh = fh_dec; % reference frequency vector for all correction tables '*adc_*'
        sig.is_sim = 1; % enables waveform simulator as a source
        sig.sim.fx = fx(1:H); % identified harmonic frequencies
        sig.sim.f_spur = []; %f_spur;
        sig.sim.rnd_dc = 0.01; % randomize DC offset [%]
        % save reference RMS values, i.e. this should be returned by the wrms algorithm:        
        sig.ref.P = P;        
        sig.ref.I = I_rms;
        sig.ref.U = U_rms;

        %mean(vcl{1}.spur)/Ux(1)
        %datain.u_adc_bits.v
        
        

        % execute Monte-Carlo:
        res = qwtb_mcm_exec(@proc_wrms,sig,calcset);
        
        % --simulation was done without SFDR (computantionaly expensive), so add SFDR to histograms now:        
        % worst case SFDR effect:
        u_U_sfdr = ((sum(0.5*vcl{1}.spur.^2) + U_rms^2)^0.5 - U_rms)*1.1;    
        u_I_sfdr = ((sum(0.5*vcl{2}.spur.^2) + I_rms^2)^0.5 - I_rms)*1.1;    
        u_P_sfdr = sum(0.5*vcl{1}.spur.*vcl{2}.spur)*1.1;        
        % add SFDR to histograms (assume plus and minus effect, because SFDR is partially in the detected harmonics
        % that are simualted by MC, so the RMS is shifted to plus):
        v_U = (2*rand(calcset.mcm.repeats,1) - 1)*u_U_sfdr + res.dU*U_rms; 
        v_I = (2*rand(calcset.mcm.repeats,1) - 1)*u_I_sfdr + res.dI*I_rms;
        v_P = (2*rand(calcset.mcm.repeats,1) - 1)*u_P_sfdr + res.dP*abs(P);
%         v_U = res.dU*U_rms; 
%         v_I = res.dI*I_rms;
%         v_P = res.dP*abs(P);
                
%         figure;
%         hist(res.dU,50)
%         figure;
%         hist(res.dP,50)
        
        % coverage factor estimate:
        ke = loc2covg(calcset.loc,50);
        
        % calculate uncertainties:
        u_U = scovint_ofs(v_U, calcset.loc, 0)/ke;
        u_I = scovint_ofs(v_I, calcset.loc, 0)/ke;
        u_P = scovint_ofs(v_P, calcset.loc, 0)/ke;
        
        % override DC uncertainty:
        u_Udc = scovint_ofs(res.dUdc, calcset.loc, 0)/ke;
        u_Idc = scovint_ofs(res.dIdc, calcset.loc, 0)/ke;
                
        % this is very crude estimator of uncertainty evaluation error caused by the small MC iterations count:
        %  note: it estimates expansion coeficient based on evaluation of uncertainty from S subsets of the randomized quantities 
        s_U = [];
        s_I = [];
        s_P = [];
        for k = 1:100
            prm = randperm(calcset.mcm.repeats);
            prm = prm(1:round(0.5*calcset.mcm.repeats));
            s_U(k) = scovint_ofs(v_U(prm), calcset.loc, 0)/ke;
            s_I(k) = scovint_ofs(v_I(prm), calcset.loc, 0)/ke;
            s_P(k) = scovint_ofs(v_P(prm), calcset.loc, 0)/ke;
        end      
        k_U = 1 + std(s_U)*2^-0.5/u_U;
        k_I = 1 + std(s_I)*2^-0.5/u_I;
        k_P = 1 + std(s_P)*2^-0.5/u_P;
        
        % expand the original uncertainty estimates:
        u_U = u_U*k_U;
        u_I = u_I*k_I;
        u_P = u_P*k_P;
        vcl{1}.u_dc = u_Udc*k_U;
        vcl{2}.u_dc = u_Idc*k_I;
    
    else
        % -- no uncertainty mode:
        % clear all algorithm-itself uncertainties
        % note: the correction uncertainty stays there because why not?... 
                
        % estimate corrections related uncertainty from relevant harmonics:
        u_U = sum(0.5*u_Ux.^2).^0.5;
        u_I = sum(0.5*u_Ix.^2).^0.5;
        u_P = sum((0.5*((Ix.*cos(phx).*u_Ux).^2 + (Ux.*cos(phx).*u_Ix).^2 + (Ux.*Ix.*sin(phx).*u_phx).^2).^0.5).^2).^0.5;
                
    end
    
    
        
    
    
    
    
    
    
    
    
    
    
    
    
    % --- Results post-processing ---
    % combining some the uncertainties, expressing some additional quantities... 
        
    % obtain main results:
    U = result.U;
    I = result.I;
    P = result.P;
    
    % calculate reactive power:
    % ###todo: decide on actual definition of reactive power!!!
    %          I assume equation S^2 = P^2 + Q^2 applies only wihtout DC component.
    %          That is how the U, I and P paremeters above were calculated.        
    S = U*I;
    u_S = ((u_U*I)^2 + (u_I*U)^2)^0.5;
    Q = (S^2 - P^2)^0.5;    
    u_Q = ((S^2*u_S^2 + P^2*u_P^2)/(S^2 - P^2))^0.5; % ###note: ignoring corelations, may be improved    
    % ###note: very experiMENTAL solution. The sing() of the FFT based Q (according Budenau) is used to estimate polarity.
    %          Correct solution would be to use hilbert transform but that is not done yet.
    %          This solution should work for PF > 0.05 and for not insane THD. In the worst case it will change only polarity. 
    Q = Q.*sign(Q_fft); % apply polarity obtained from FFT    
    
    % obtain DC components:
    dc_u = vcl{1}.dc;
    dc_i = vcl{2}.dc;
    u_dc_u = vcl{1}.u_dc;
    u_dc_i = vcl{2}.u_dc;
    
    % DC power component (empirical):
    P0   = dc_u*dc_i;
    u_P0 = (1.5*(dc_u*u_dc_i)^2 + 1.5*(dc_i*u_dc_u)^2 + u_P^2)^0.5; % ###note: overestimated
    u_dc_u = (u_dc_u^2 + 1.5*u_U^2)^0.5; % ###note: overestimated
    u_dc_i = (u_dc_i^2 + 1.5*u_I^2)^0.5; % ###note: overestimated 
    
    % add DC components (DC coupling mode only):
    if ~is_ac

        % add DC to RMS voltage and current:
        U = (U^2 + dc_u^2)^0.5;
        I = (I^2 + dc_i^2)^0.5;
        % add DC to active power: 
        P = P + P0;
        % reactive power shall be unaffected... 
        
        % add DC uncertainty to the results:
        u_U = (dc_u^2*u_dc_u^2 + U^2*u_U^2)^0.5/(dc_u^2 + U^2)^0.5;
        u_I = (dc_i^2*u_dc_i^2 + I^2*u_I^2)^0.5/(dc_i^2 + I^2)^0.5;
        u_P = (u_P^2 + (dc_u*dc_i*((u_dc_u/dc_u)^2 + (u_dc_i/dc_i)^2)^0.5)^2)^0.5;        
    end     
    
    % calculate apperent power:
    %  ###note: contains DC component of not AC coupled! 
    S = U*I;
    u_S = ((u_U*I)^2 + (u_I*U)^2)^0.5;        
        
    % calculate power factor:
    %  ###note: contains DC component if not AC coupled!
%     PF = P/S;
%     u_PF = ((u_P./P).^2 + (u_S./S).^2).^0.5; % ###note: ignoring corelations, may be improved
    mmc = 2000; % iterations                        
    k_in = 3^0.5;
    v_Px  = bsxfun(@plus,P,bsxfun(@times,u_P*k_in,2*rand(1,mmc)-1));
    v_Sx  = bsxfun(@plus,S,bsxfun(@times,u_S*k_in,2*rand(1,mmc)-1));
    v_PF   = v_Px./v_Sx;
    PF = P/S;
    u_PF  = max(abs(v_PF - PF))/k_in;
    
%     figure
%     hist(v_PF,50)
    
    % find cap/ind
    is_cap = Q < 0;
    if ref == 'u'
        is_cap = ~is_cap;
    end             
    % quadrant string
    if sign(P)
        ie_str = 'IMPORT';
    else 
        ie_str = 'EXPORT';
    end
    if is_cap
        cap_str = 'CAP';
    else
        cap_str = 'IND';
    end
        
        
    
    % --- return quantities to QWTB:
    
    % calc. coverage factor:
    ke = loc2covg(calcset.loc,50);
    
    % power parameters:
    dataout.U.v = U;
    dataout.U.u = u_U*ke;
    dataout.I.v = I;
    dataout.I.u = u_I*ke;
    dataout.P.v = P;
    dataout.P.u = u_P*ke;
    dataout.S.v = S;
    dataout.S.u = u_S*ke;
    dataout.Q.v = Q;
    dataout.Q.u = u_Q*ke;
    dataout.PF.v = PF;
    dataout.PF.u = u_PF*ke;
    dataout.quadrant.v = [ie_str ' ' cap_str];
    dataout.phi_ef.v = atan2(Q,P);
    dataout.phi_ef.u = max(abs([atan2(Q+u_Q,P+u_P) atan2(Q-u_Q,P+u_P) atan2(Q-u_Q,P-u_P) atan2(Q-u_Q,P-u_P)]-atan2(Q,P)))*ke;
    % DC components:
    dataout.Udc.v = dc_u;
    dataout.Udc.u = u_dc_u*ke;
    dataout.Idc.v = dc_i;
    dataout.Idc.u = u_dc_i*ke;
    dataout.Pdc.v = P0;
    dataout.Pdc.u = u_P0*ke;
    
    % return spectra of the corrected waveforms:
    din = struct();
    din.fs.v = fs;
    din.window.v = win_type;
    cset.verbose = 0;
    din.y.v = vcl{1}.y;                
    dout = qwtb('SP-WFFT',din,cset);
    %qwtb('TWM-PWRTDI','addpath'); % ###todo: fix qwtb so it does not loose the path every time another alg. is called
    fh               = dout.f.v(:); % freq. vector of the DFT bins
    dataout.spec_U.v = dout.A.v(:); % amplitude vector of the DFT bins    
    din.y.v = vcl{2}.y;                
    dout = qwtb('SP-WFFT',din,cset);
    %qwtb('TWM-PWRTDI','addpath'); % ###todo: fix qwtb so it does not loose the path every time another alg. is called
    fh               = dout.f.v(:); % freq. vector of the DFT bins
    dataout.spec_I.v = dout.A.v(:); % amplitude vector of the DFT bins
    dataout.spec_S.v = dataout.spec_U.v.*dataout.spec_I.v;
    dataout.spec_f.v = fh(:);
    
%       figure;
%       loglog(fh,dataout.spec_U.v)
%       figure;
%       loglog(fh,dataout.spec_I.v)  


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
