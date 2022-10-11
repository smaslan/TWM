function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm TWM-PWRFFT.
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
    
    % Rebuild TWM style correction tables:
    % This is not necessary, but the TWM style tables are more comfortable to use then raw correction matrices
    tab = qwtb_restore_correction_tables(datain,cfg);
    
    
    
    % --------------------------------------------------------------------
    % Power calculation using FFT
    %
    % ###todo: add description here 
    %
    
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
    
    vcl{id}.time_stamp.v = datain.time_stamp.v + datain.time_shift.v;
    vcl{id}.time_stamp.u = (datain.time_stamp.u^2 + datain.time_stamp.u^2)^0.5;    
    vcl{id}.y = datain.u.v;    
    if cfg.u_is_diff
        vcl{id}.y_lo = datain.u_lo.v; 
    end        
    % -- build virtual channel (I):
    id = id + 1;
    vcl{id}.tran = 'shunt';
    vcl{id}.name = 'i';
    vcl{id}.time_stamp.v = datain.time_stamp.v;
    vcl{id}.time_stamp.u = datain.time_stamp.u; 
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
    
    % --- Pre-processing ---
   
    % window for spectral analysis:
    %  note: this is not the window for the main RMS algorithms itself!
    %        This is just to calculate signal spectrum for purposes of corrections, uncertainty, etc.
    %
    % ###todo: decide if it is good idead to use windowing even for coherent or not:
    %           + it will be more immune to interharmonics in the signal
    %           - it will be more sensitive to inaccurate coherent setup in terms of phase?
    %win_type = 'flattop_144D';
    win_type = 'rect';
         
    
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
        din.f_nom.v = [0:floor(N/2)-1]*fs/N; % DFT frequencies to extract
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
        vc.u_Y  = dout.A.u(:); % amplitude vector of the DFT bins
        vc.ph = dout.ph.v(:); % phase vector of the DFT bins
        vc.u_ph = dout.ph.u(:); % phase vector of the DFT bins
        %w     = dout.w.v; % window coefficients
        
        % estimate DC offset of channel:           
        vc.dc = vc.Y(1);
        vc.u_dc = vc.u_Y(1);
               
        vcl{k} = vc;
    end
    fh = fh(:);
    
    if isfield(calcset,'dbg_plots') && calcset.dbg_plots
        figure;
        loglog(fh,vcl{1}.Y)
        xlabel('f [Hz]');
        ylabel('U [V]');
        figure;
        loglog(fh,vcl{2}.Y)
        xlabel('f [Hz]');
        ylabel('I [A]');
    end
        
    %  get window scaling factor:
    %w_gain = mean(w);
    %  get window rms:
    %w_rms = mean(w.^2).^0.5;    
    % window half-width:
    w_size = 1;
    % window side-lobe:
    %w_slob = 10^(-144/20);   
        
    
    % extract DFT bins:
    Uh = vcl{1}.Y; % voltage amplitudes
    Ih = vcl{2}.Y; % current amplitudes
    ph = vcl{2}.ph - vcl{1}.ph; % I-U phase difference
    % corresponding uncertainties 
    u_Uh = vcl{1}.u_Y;
    u_Ih = vcl{2}.u_Y;
    u_ph = (vcl{1}.u_ph.^2 + vcl{2}.u_ph.^2).^0.5;
    % number of DFT bins
    N = numel(Uh);
    
    % first 'ac' DFT bin - this is used to skip the bins affected by DC component
    nac = 1 + w_size;
    
    % RMS levels
    U   = sum(0.5*Uh(nac:end).^2)^0.5;
    u_U = sum((u_Uh(nac:end).*Uh(nac:end)/(2*U)).^2).^0.5;
    I   = sum(0.5*Ih(nac:end).^2)^0.5;
    u_I = sum((u_Ih(nac:end).*Ih(nac:end)/(2*I)).^2).^0.5;
        
    % active power
    P   = sum(0.5*Uh(nac:end).*Ih(nac:end).*cos(ph(nac:end)));
    u_P = sum((0.5*((Ih(nac:end).*cos(ph(nac:end)).*u_Uh(nac:end)).^2 + (Uh(nac:end).*cos(ph(nac:end)).*u_Ih(nac:end)).^2 + (Uh(nac:end).*Ih(nac:end).*sin(ph(nac:end)).*u_ph(nac:end)).^2).^0.5).^2).^0.5; % GUF method
    
    % reactive power (no DC component)
    Q_bud = sum(0.5*Uh(nac:end).*Ih(nac:end).*sin(ph(nac:end)));
    
    
    % calculate reactive power:
    % ###todo: decide on actual definition of reactive power!!!
    %          I assume equation S^2 = P^2 + Q^2 applies only without DC component.
    %          That is how the U, I and P paremeters above were calculated.        
    S = U*I;
    u_S = ((u_U*I)^2 + (u_I*U)^2)^0.5;
    Q = (S^2 - P^2)^0.5*sign(Q_bud);    
    u_Q = ((S^2*u_S^2 + P^2*u_P^2)/(S^2 - P^2))^0.5; % ###note: ignoring corelations, may be improved         
    
    % obtain DC components:
    dc_u = vcl{1}.dc;
    dc_i = vcl{2}.dc;
    u_dc_u = vcl{1}.u_dc;
    u_dc_i = vcl{2}.u_dc;
    
    % DC power component (empirical uncertainty):
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
    %  ###note: contains DC component if not AC coupled! 
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
    
    
    % --- energy estimation
    
    % total measurement time [s]
    %  ###todo: add adc timebase correction?
    time = 1/fs*numel(datain.u.v);
    
    % active energy [Wh]    
    EP   = P*time/3600;
    u_EP = u_P*EP;    
    % reactive energy [Wh]    
    EQ = Q*time/3600;
    u_EQ = u_Q*EQ;
    
    % extract fundamental phase shift
    [v,f0id] = max(Ih);
    ph1 = ph(f0id);
    u_ph1 = u_ph(f0id);
    ph1_f = fh(f0id);
   
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
    dataout.phi_ef.v = atan2(Q,P);
    dataout.phi_ef.u = max(abs([atan2(Q+u_Q,P+u_P) atan2(Q-u_Q,P+u_P) atan2(Q-u_Q,P-u_P) atan2(Q-u_Q,P-u_P)]-atan2(Q,P)))*ke;
    dataout.phiH1.v = ph1;
    dataout.phiH1.u = u_ph1*ke;
    dataout.phiH1_f.v = ph1_f;
    % DC components:
    dataout.Udc.v = dc_u;
    dataout.Udc.u = u_dc_u*ke;
    dataout.Idc.v = dc_i;
    dataout.Idc.u = u_dc_i*ke;
    dataout.Pdc.v = P0;
    dataout.Pdc.u = u_P0*ke;
    % energies:
    dataout.EP.v = EP;
    dataout.EP.u = u_EP*ke;
    dataout.EQ.v = EQ;
    dataout.EQ.u = u_EQ*ke;
    % return spectra of the corrected waveforms:    
    dataout.spec_U.v = vcl{1}.Y(:); % amplitude vector of the DFT bins    
    dataout.spec_I.v = vcl{2}.Y(:); % amplitude vector of the DFT bins
    dataout.spec_S.v = dataout.spec_U.v.*dataout.spec_I.v;
    dataout.spec_f.v = fh(:);
    
    
    
    
    
    if isfield(calcset,'dbg_plots') && calcset.dbg_plots
        figure;
        loglog(fh(2:end),dataout.spec_U.v(2:end))
        xlabel('f [Hz]');
        ylabel('U [V]');
        figure;
        loglog(fh(2:end),dataout.spec_I.v(2:end))
        xlabel('f [Hz]');
        ylabel('I [A]');
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
