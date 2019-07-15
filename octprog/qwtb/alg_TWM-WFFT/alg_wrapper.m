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
    
    % multiple records data?
    is_multi = sum(size(datain.y.v)>1) > 1;
    
    if ~isfield(datain,'f_nom')
        % -- we aint got no nominal frequency, so try to search it by PSFE:
        
        % call PSFE:
        din = struct();
        din.fs.v = fs;        
        cset = calcset;
        cset.verbose = 0;
        cset.unc = 'none';
        cset.checkinputs = 0;  
        if is_multi
            % select one of the input records only:
            din.y.v = datain.y.v(:,1);
        else
            din.y.v = datain.y.v;
        end                
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
    N = numel(datain.y.v);
    
    % get high-side (or single-ended) spectrum:
    din = struct();
    din.fs.v = fs;
    if isfield(datain,'window')
        din.window = datain.window;
    else
        din.window.v = 'rect';    
    end
    cset.verbose = 0;
    din.y.v = datain.y.v;                
    dout = qwtb('SP-WFFT',din,cset);
    fh    = dout.f.v(:); % freq. vector of the DFT bins
    A     = dout.A.v; % amplitude vector of the DFT bins
    ph    = dout.ph.v; % phase vector of the DFT bins
    if ~is_multi   
        A     = A(:); % amplitude vector of the DFT bins
        ph    = ph(:); % phase vector of the DFT bins
    end
    w     = dout.w.v; % window coefficients
    
    % Normalized Equivalent Noise BaNdWidth (Rado's book "Sampling with 3458A", page 196, formula 4.36):
    NENBNW = numel(w)*sum(w.^2)/sum(w)^2;
    
    
    %  get window scaling factor:
    w_gain = mean(w);
    %  get window rms:
    w_rms = mean(w.^2).^0.5;    
   
    % get ADC aperture value [s]:
    ta = abs(datain.adc_aper.v);
    
    % calculate aperture gain/phase correction:
    fap = fh + 1e-12; % needed for DC work
    ap_gain = (pi*ta*fap)./sin(pi*ta*fap);
    ap_phi  =  pi*ta*fh;
    clear fap;
        
    % corrections interpolation mode:
    % ###note: do not change, this works best for frequency characteristics
    i_mode = 'pchip';
    
    % compensate phase by timestamp:
    ph   = ph - fh*datain.time_stamp.v*2*pi; % ph   = ph - fh.*datain.time_stamp.v*2*pi;
    u_ph = fh.*mean(datain.time_stamp.u)*2*pi;
    
    % average records:
    U = mean(A.*exp(j*ph),2);
    A = abs(U);
    ph = angle(U);
    %A  = mean(A,2);
    %ph = mean(ph,2);
        
    % fix ADC offset:
    A(1)   = A(1) - datain.adc_offset.v; % remove DC offset from spectrum
    u_A    = 0*A;
    u_A(1) = datain.adc_offset.u;
            
    % get gain/phase correction for the freq. components (high-side ADC):
    ag = correction_interp_table(tab.adc_gain, abs(A), fh, 'f',1, i_mode);
    ap = correction_interp_table(tab.adc_phi,  abs(A), fh, 'f',1, i_mode);
        
    if any(isnan(ag.gain))
        error('High-side ADC gain correction: not sufficient range of correction data!');
    end
    if any(isnan(ap.phi))
        error('High-side ADC phase correction: not sufficient range of correction data!');
    end
       
    % apply aperture corrections (when enabled and some non-zero aperture entered):
    if datain.adc_aper_corr.v && ta > 1e-12
        ag.gain = ag.gain.*ap_gain;
        ap.phi = ap.phi + ap_phi;        
        ag.u_gain = (ag.u_gain.*ap_gain); % ###todo: add uncertainty of apperture?                  
    end      
     
    % apply high-side adc tfer to the spectrum estimate:        
    A   = A.*ag.gain;
    u_A = (u_A.^2 + (A.*ag.u_gain).^2).^0.5;
    ph   = ph + ap.phi;
    u_ph = ap.u_phi;
        
    
    % store temporary high-side:
    A_hi = A;
    
    % add quantisation noise estimate:
    %   note: from Rado's book "Sampling with 3458A", page 208, formula 4.68):
    %         Verified by Monte Carlo simulation (by Stanislav Maslan).
    lsb = ag.gain*adc_get_lsb(datain,'');
    q_noise = lsb/12^0.5;
    A_qu = (NENBNW)^0.5*q_noise*(2/N)^0.5;
    p_qu = (NENBNW)^0.5*q_noise./A*(2/N)^0.5;
    u_A = (u_A.^2 + A_qu.^2).^0.5;
    u_ph = (u_ph.^2 + p_qu.^2).^0.5;
        
    
    if cfg.y_is_diff
        % --- differential mode ---:
        
        % get low-side spectrum
        din.y.v = datain.y_lo.v;                
        dout = qwtb('SP-WFFT',din,cset);
        A_lo  = dout.A.v; % amplitude vector of the DFT bins
        ph_lo = dout.ph.v; % phase vector of the DFT bin
        if ~is_multi   
            A_lo  = A_lo(:); % amplitude vector of the DFT bins
            ph_lo = ph_lo(:); % phase vector of the DFT bins
        end
        
        % compensate phase by timestamp:
        ph_lo = ph_lo - fh*(datain.time_stamp.v + datain.time_shift_lo.v)*2*pi;        
        u_ph_lo = ((fh.*mean(datain.time_stamp.u)*2*pi).^2 + (fh.*mean(datain.time_shift_lo.u)*2*pi).^2).^0.5;
        
        % average records:
        U = mean(A_lo.*exp(j*ph_lo),2);
        A_lo = abs(U);
        ph_lo = angle(U);        
        %A_lo  = mean(A_lo,2);
        %ph_lo = mean(ph_lo,2);
    
        % fix ADC offset:
        A_lo(1)   = A_lo(1) - datain.lo_adc_offset.v; % remove DC offset from working spectrum
        u_A_lo    = 0*A_lo;
        u_A_lo(1) = datain.lo_adc_offset.u;
            
        % get gain/phase correction for the freq. components (low-side ADC):
        ag = correction_interp_table(tab.lo_adc_gain, abs(A_lo), fh, 'f',1, i_mode);
        ap = correction_interp_table(tab.lo_adc_phi,  abs(A_lo), fh, 'f',1, i_mode);
        
        if any(isnan(ag.gain))
            error('Low-side ADC gain correction: not sufficient range of correction data!');
        end
        if any(isnan(ap.phi))
            error('Low-side ADC phase correction: not sufficient range of correction data!');
        end
           
        % apply aperture corrections (when enabled and some non-zero aperture entered):
        if datain.lo_adc_aper_corr.v && ta > 1e-12
            ag.gain = ag.gain.*ap_gain;
            ap.phi = ap.phi + ap_phi;
            ag.u_gain = (ag.u_gain.*ap_gain); % ###todo: add uncertainty of apperture?
        end      
         
        % apply low-side adc tfer to the spectrum estimate:        
        A_lo   = A_lo.*ag.gain;
        u_A_lo = (u_A_lo.^2 + (A_lo.*ag.u_gain).^2).^0.5;
        ph_lo   = ph_lo + ap.phi;
        u_ph_lo = ap.u_phi;                
        
        % add quantisation noise estimate:
        %   note: from Rado's book "Sampling with 3458A", page 208, formula 4.68):
        %         Verified by Monte Carlo simulation (by Stanislav Maslan).
        lsb = ag.gain*adc_get_lsb(datain,'lo_');
        q_noise = lsb/12^0.5;
        A_qu = (NENBNW)^0.5*q_noise*(2/N)^0.5;
        p_qu = (NENBNW)^0.5*q_noise./A_lo*(2/N)^0.5;
        u_A_lo = (u_A_lo.^2 + A_qu.^2).^0.5;
        u_ph_lo = (u_ph_lo.^2 + p_qu.^2).^0.5;
        
        
%         figure
%         loglog(fh,A)
%         hold on;
%         loglog(fh,A_lo,'r')
%         hold off;

        %[f0,fid] = min(abs(datain.f_nom.v(1) - fh));
        %u_adc_phx = (u_ph(fid)^2 + u_ph_lo(fid)^2)^0.5;     
%         datain.f_nom.v(1)*datain.time_shift_lo.u*2*pi
%         datain.f_nom.v(1)*datain.time_stamp.u*2*pi
        
        
        % high-side:            
          Y  = A.*exp(j*ph);
        u_Y  = u_A;
        u_ph = u_ph;
        % low-side:
          Y_lo  = A_lo.*exp(j*ph_lo);
        u_Y_lo  = u_A_lo;
        u_ph_lo = u_ph_lo;
        % estimate digitizer input rms level:
        dA = abs(Y - Y_lo);
        rms_ref = sum(0.5*dA.^2).^0.5*w_gain/w_rms;            
        % calculate transducer tfer:
        fh_dc = fh; fh_dc(1) = 1e-3; % override DC frequency by non-zero value
        [trg,trp,u_trg,u_trp] = correction_transducer_loading(tab,datain.tr_type.v,fh_dc,[], abs(Y),angle(Y),u_Y,u_ph, abs(Y_lo),angle(Y_lo),u_Y_lo,u_ph_lo, 'rms',rms_ref);
        trg(1)= trg(1)*(1 - 2*(abs(trp(1)) > 0.1*pi)); % restore sign
        A   = trg;
        u_A = u_trg;
        ph   = trp;
        u_ph = u_trp;
        ph(1) = 0;
        
        %u_ph(fid)
        
        
        %ap = correction_interp_table(tab.tr_phi, rms_ref, fh, 'f',1, i_mode);
        %(u_adc_phx^2 + ap.u_phi(fid)^2)^0.5
        
        
        
%          figure
%          loglog(fh,A)
        
    
    else
        % --- single ended mode ---
        
        % apply transducer correction:
        rms_ref = sum(0.5*A.^2).^0.5*w_gain/w_rms;
        Y = abs(A); % amplitudes, rectify DC
        fh_dc = fh; fh_dc(1) = 1e-3; % override DC frequency by non-zero value
        [trg,trp,u_trg,u_trp] = correction_transducer_loading(tab,datain.tr_type.v,fh_dc,[], Y,ph,u_A,u_ph, 'rms',rms_ref);
        trg(1) = trg(1)*sign(A(1)); % restore sign
        A   = trg;
        u_A = u_trg;
        ph   = trp;
        u_ph = u_trp;
        ph(1) = 0;
        
    end
    
    % wrap phase to +-180deg:
    %  note: this is critical to avoid insane phase due to time_stamp correction!
    ph = mod(ph + pi, 2*pi) - pi;
        
        

    % --- now a little spectrum analysis:
    
    % search dominant component:
    [Amax,mid] = max(A);     
    
    % local copy of spectrum:
    w_size = 11; % widest window half-width
    Ax = zeros(size(A));
    Ax(w_size:end) = A(w_size:end);
    
    % max harmonics to search:
    H_max = 100;
    
    % min ratio to fundamental to take component into account:
    h_min_ratio = 10e-6;
    
    % spectrum size:
    M = numel(A);
        
    h_list = [];            
    for h = 1:H_max
                
        % look for highest harmonic:            
        [v,id] = max(Ax);                     
        
        % leave if harmonics too low:
        if v < Amax*h_min_ratio || isempty(id)
            break;
        end
    
        % add to found harmonics list:
        h_list(end+1) = id;
        
        % DFT bins occupied by the harmonic:
        h_bins = max((id - w_size),1):min(id + w_size,M);
        % remove harmonic bins from remaining list:
        Ax(h_bins) = 0;
        
    end
    
    
    % estimate RMS of the signal from identified components:
    %  note: we cannot use all DFT bins, because in non-rect window the sidebands are altered differently by correction
    %        so as a result the energy of whole signal does not match!
    %        Thus we use only DC and peak harmonics (and inter-harmonics).
    rms = (A(1)^2 + sum(0.5*A(h_list).^2))^0.5;
      
    % expand noise to full bw:
    if numel(fh(Ax ~= 0)) > 1
        Ax_noise = interp1(fh(Ax ~= 0),Ax(Ax ~= 0),fh,'nearest','extrap');
    else
        Ax_noise = 0;
    end
    
    % RMS noise estimate:
    %  ###note: some safety multiplier added...
    rms_noise = sum(0.5*Ax_noise.^2)^0.5/w_rms*w_gain*1.3;
    
    if cfg.y_is_diff
        % -- differential mode:
        %  note: in diff. mode we will estimate high-to-low side ratio
        %        and calculate effective jitter, SFDR from high and low-sides.
        %        Then we proceed as for single-ended mode.
        
        % high-low weight:
        %whl = A_hi(mid)/(A_hi(mid) - A_lo(mid));
        
        % get ADC SFDR ratios for dominant component:
        adc_sfdr    = correction_interp_table(tab.adc_sfdr, abs(A_hi(mid)), fh(mid), 'f',1, i_mode);
        lo_adc_sfdr = correction_interp_table(tab.lo_adc_sfdr, abs(A_lo(mid)), fh(mid), 'f',1, i_mode);
        
        % calculate effective ADC SFDR ratio (unit-less): 
        adc_sfdr    = A_hi(mid)*10^(-adc_sfdr.sfdr/20);
        lo_adc_sfdr = A_lo(mid)*10^(-lo_adc_sfdr.sfdr/20);
        adc_sfdr = (adc_sfdr + lo_adc_sfdr)/(A_hi(mid) - A_lo(mid));
        
        % get transducer SFDR ratio for dominant component:
        tr_sfdr = correction_interp_table(tab.tr_sfdr, rms, fh(mid), 'f',1, i_mode);
        tr_sfdr = 10^(-tr_sfdr.sfdr/20);
        
        % combined SFDR ratio:
        sfdr = adc_sfdr + tr_sfdr;  
        
        % effective jitter:
        jitter = (datain.adc_jitter.v^2 + datain.lo_adc_jitter.v^2)^0.5;
        
    else
        % -- single-ended mode:
        
        % calculate effective SFDR ratio (unit-less):
        adc_sfdr = correction_interp_table(tab.adc_sfdr, abs(A_hi(mid)), fh(mid), 'f',1, i_mode);
        adc_sfdr = 10^(-adc_sfdr.sfdr/20);
        
        % get transducer SFDR ratio for dominant component:
        tr_sfdr = correction_interp_table(tab.tr_sfdr, rms, fh(mid), 'f',1, i_mode);
        tr_sfdr = 10^(-tr_sfdr.sfdr/20);
        
        % combined SFDR ratio:
        sfdr = adc_sfdr + tr_sfdr;
        
        % rms jitter value:
        jitter = datain.adc_jitter.v;        
        
    end
       
    
    % estimated spurs level: 
    A_spur = A(mid)*sfdr*ones(size(A));
    A_spur(mid) = 0; % no spurr addition to fundamental harmonic I guess...
       
    % add SFDR spurs to harmonics uncertainties:
    u_A = (u_A.^2 + A_spur.^2/3).^0.5;    
    u_ph = (u_ph.^2 + atan2(abs(A_spur),abs(A)).^2/3).^0.5;
    
    
    % estimate and add jitter uncertainty:
    %   note: from Rado's book "Sampling with 3458A", page 209, section 4.10.5):
    %         Verified by Monte Carlo simulation (by Stanislav Maslan), but there seems
    %         to be some typo in formula 4.72?
    sig = A*0.5;%*2^-0.5; % this was changed from Arms to 0.5*Amplitude, which matches Monte Carlo simulation! 
    noise_jt = 2*pi*fh*jitter.*sig;
    u_A_jitter = (NENBNW)^0.5*noise_jt*(2/N)^0.5;
    u_p_jitter = (NENBNW)^0.5*2*noise_jt./A*(2/N)^0.5;
    u_A = (u_A.^2 + u_A_jitter.^2).^0.5;
    u_ph = (u_ph.^2 + u_p_jitter.^2).^0.5;
            
    % estimate noise caused uncertainty:
    %   note: from Rado's book "Sampling with 3458A", page 209, section 4.10.2):
    %         Verified by Monte Carlo simulation (by Stanislav Maslan)
    u_A_noise  = (NENBNW)^0.5*rms_noise*(2/N)^0.5;
    u_p_noise  = (NENBNW)^0.5*rms_noise./A*(2/N)^0.5;
    u_A = (u_A.^2 + u_A_noise.^2).^0.5;
    u_ph = (u_ph.^2 + u_p_noise.^2).^0.5;
        
%     figure
%     loglog(fh,Ax)
%     hold on;
%     loglog(fh,Ax_noise,'r')
%     hold off;
    
                   
    % get nearest frequency DFT bin(s) from spectrum: 
    fx = datain.f_nom.v;
    % note: slow version - replaced by interp1()
    %fid = [];
    %for h = 1:numel(datain.f_nom.v)    
    %    [f0,fid(h)] = min(abs(datain.f_nom.v(h) - fh));
    %end
    fid = interp1(fh,[1:numel(fh)]',fx,'nearest');        
        
        
    % get rms estimate from identified significant components:
    rms = (A(1)^2 + sum(0.5*A(h_list).^2))^0.5;
    % estimate of rms uncertainty as a worst case:
    u_rms = ((A(1)+u_A(1))^2 + sum(0.5*(A(h_list) + u_A(h_list)).^2))^0.5 - rms; 
    
    
    % return extracted DFT bin(s):
    k_unc = loc2covg(calcset.loc,50);
    dataout.f.v = fh(fid);
    dataout.A.v = A(fid);
    dataout.ph.v = ph(fid);
    dataout.rms.v = rms;
    dataout.dc.v = A(1);              
    dataout.f.u = 0*dataout.f.v;
    dataout.A.u = u_A(fid)*k_unc;
    dataout.ph.u = u_ph(fid)*k_unc;
    dataout.rms.u = u_rms*k_unc;
    dataout.dc.u = u_A(1)*k_unc;
    
    % return spectrum:
    dataout.spec_f.v = fh;
    dataout.spec_A.v = A;   

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