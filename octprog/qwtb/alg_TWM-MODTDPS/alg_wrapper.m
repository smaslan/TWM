function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm TWM-MODTDPS.
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
    
    % PSFE frequency estimate mode:
    if isfield(datain, 'wave_shape') && ischar(datain.wave_shape.v)
        wave_shape = datain.wave_shape.v;
    else
        wave_shape = 'sine';
    end
    
    % timestamp phase compensation state:
    comp_err = isfield(datain, 'comp_err') && ((isnumeric(datain.comp_err.v) && datain.comp_err.v) || (ischar(datain.comp_err.v) && strcmpi(datain.comp_err.v,'on')));
         
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
    % Start of the algorithm
    % --------------------------------------------------------------------
    
    
    % note: following code is residue of multichannel (power) algorithm,
    %       where u/i channels were converted to virtual channels and then process
    %       sequentially by the same code. 
    %       now the algorithm is used just for one channel, so the v.channels may be removed in future
       
        
    % list of involved correction tables without 'u_' or 'i_' prefices
    tab_list = {'tr_gain','tr_phi','tr_Zca','tr_Yca','tr_Zcal','tr_Zcam','adc_Yin','lo_adc_Yin','Zcb','Ycb','tr_Zlo','adc_gain','adc_phi','lo_adc_gain','lo_adc_phi'};
    clear vcl; id = 0; % virt. chn. list     
    % -- build virtual channel (U):
    id = id + 1;
    vcl{id}.tran = datain.tr_type.v;
    vcl{id}.is_diff = cfg.y_is_diff;
    vcl{id}.y = datain.y.v;
    vcl{id}.ap_corr = datain.adc_aper_corr.v;
    if cfg.u_is_diff
        vcl{id}.y_lo = datain.y_lo.v;
        vcl{id}.tsh_lo = datain.time_shift_lo; % low-high side channel time shift
        vcl{id}.ap_corr_lo = datain.lo_adc_aper_corr.v;    
    end        
    vcl{id}.tab = tab;       
    vcl{id}.tsh = 0; % high-side channel shift (do not change!)    
    
    
    
    % --- Find dominant harmonic component --- 
     
    % --- get channel spectra:    
    % for each virtual channel:
    for k = 1:numel(vcl)
        % get channel:
        vc = vcl{k};
        
        % estimate dominant harmonic component:
        [vc.f0, vc.A0] = PSFE(vc.y, 1/fs);
        
        % get spectrum:
        [fh, vc.Y, vc.ph] = ampphspectrum(vc.y, fs, 0, 0, 'flattop_matlab', [], 0);
        
        if vc.is_diff
            % get low-side spectrum:
            [fh, vc.Y_lo, vc.ph_lo] = ampphspectrum(vc.y_lo, fs, 0, 0, 'flattop_matlab', [], 0);
        end
        
        vcl{k} = vc;
    end
    
    % --- estimate carrier component:
    
    % use the estimates dominant harmonic frequency:    
    f0 = vcl{id}.f0;
    
    % get id of the dominant DFT bin coresponding to 'f0':
    [v,fid] = min(abs(f0 - fh));
    
    
    
    
    % --- Process the channels with corrections ---
        
    % get ADC aperture value [s]:
    ta = abs(datain.adc_aper.v);
    
    % calculate aperture gain/phase correction (for f0):
    ap_gain = (pi*ta*f0)./sin(pi*ta*f0);
    ap_phi  =  pi*ta*f0; % phase is not needed - should be identical for all channels
         
    
    % --- for each virtual channel:
    for k = 1:numel(vcl)
        % get channel:
        vc = vcl{k};
        
        % dominant component vector:
        A0  = vc.Y(fid);
        ph0 = vc.ph(fid);
        
        % get gain/phase correction for the dominant component (high-side ADC):
        ag = correction_interp_table(vc.tab.adc_gain, A0, f0);
        ap = correction_interp_table(vc.tab.adc_phi,  A0, f0);
        
        % apply high-side gain:
        vc.y = vc.y.*ag.gain; % to time-domain signal        
        
        % apply aperture corrections (when enabled and some non-zero value entered for the aperture time):
        if vc.ap_corr && ta > 1e-12 
            vc.y = vc.y.*ap_gain;               
        end         
                
        
        if vc.is_diff
            % -- differential mode:
        
            % dominant component vector (low-side):
            A0_lo  = vc.Y_lo(fid);
            ph0_lo = vc.ph_lo(fid);
            
            % get gain/phase correction for the dominant component (low-side ADC):
            ag =  correction_interp_table(vc.tab.lo_adc_gain, A0_lo, f0);
            apl = correction_interp_table(vc.tab.lo_adc_phi,  A0_lo, f0);
            
            % apply high-side gain:
            vc.y_lo = vc.y_lo.*ag.gain; % to time-domain signal
            
            % apply aperture corrections (when enabled and some non-zero value entered for the aperture time):
            if vc.ap_corr_lo && ta > 1e-12 
                vc.y_lo = vc.y_lo.*ap_gain; % to time-domain signal                        
            end
                        
            % phase correction of the low-side channel: 
            lo_ph = apl.phi - ap.phi;
            % phase correction converted to time:
            lo_ph_t = lo_ph/2/pi/f0 + vc.tsh_lo.v;
           
            % generate time vectors for high/low-side channels (with timeshift):
            N = numel(vc.y);
            t_max    = (N-1)/fs;
            thi      = [];
            thi(:,1) = [0:N-1]/fs; % high-side
            tlo      = thi + lo_ph_t; % low-side
            
            % resample (interpolate) the high/low side waveforms to compensate timeshift:    
            imode = 'spline'; % using 'spline' mode as it shows lowest errors on harmonic waveforms
            ida = find(thi >= 0    & tlo >= 0   ,1);
            idb = find(thi < t_max & tlo < t_max,1,'last');    
            vc.y    = interp1(thi,vc.y   , thi(ida:idb), imode,'extrap');
            vc.y_lo = interp1(thi,vc.y_lo, tlo(ida:idb), imode,'extrap');
            N = numel(vc.y);
                     
            % store high-side channel timeshift:
            % note: this is needed to correctly align u/i channels 
            lo_ph_t = -thi(ida);
            vc.tsh = lo_ph_t*(lo_ph_t < 0);
            
            % calculate hi-lo difference:            
            vc.y = vc.y - vc.y_lo; % time-domain
                                    
            % estimate transducer correction tfer for dominant component 'f0':
            % note: The transfer is aproximated from windowed-FFT bins nearest to 
            %       the analyzed freq. despite the sampling was is coherent.
            %       The absolute values of the DFT bin vectors are wrong due to the window effects, 
            %       but the ratio of the high/low-side vectors is unaffected, 
            %       so they can be used to calculate the tfer which is then normalized.
            % note: the corrections is relative correction to the difference of digitizer voltages (y - y_lo)
            % note: corrector estimates rms just from the component 'f0', so it may not be accurate
            if ~isempty(vc.tran)
                Y0    = A0.*exp(j*ph0);
                Y0_lo = A0_lo.*exp(j*ph0_lo);
                [trg,trp,u_trg] = correction_transducer_loading(vc.tab,vc.tran,f0,[], A0,ph0,0,0, A0_lo,ph0_lo,0,0);            
                trg = trg./abs(Y0 - Y0_lo);
                trp = trp - angle(Y0 - Y0_lo);
            else
                trg = 1;
                trp = 0;
            end
            
        else
            % -- single-ended mode:
        
            % estimate transducer correction tfer for dominant component 'f0':
            % note: corrector estimates rms just from the component 'f0', so it may not be accurate
            if ~isempty(vc.tran)
                [trg,trp,u_trg] = correction_transducer_loading(vc.tab,vc.tran,f0,[],A0,0,0,0);
                trg = trg./A0;
            else
                trg = 1;
                trp = 0;
            end
        
        end        
        
        % apply transducer correction:
        vc.y = vc.y.*trg; % to time-domain signal        
                
        % store total v.channel timeshift:
        vc.tsh = vc.tsh + (trp + ap.phi)/2/pi/f0;
        
        if any(isnan(vc.y))
            error('Correction data have insufficient range for the signal!');
        end             
        
        vcl{k} = vc;
    end
    
    
    % --- main algorithm --- 
    
    % get corrected signal:
    u = vcl{1}.y;
    
    % estimate the modulation:
    [me, dc,f0,A0, fm,Am] = mod_tdps(fs,u,wave_shape,comp_err);
    
    
    % --- returning results ---
        
    % return envelope:
    dataout.env.v   = me(:);
    dataout.env_t.v = [0:numel(me)-1]'/fs;
    
    % return carrier:
    dataout.f0.v   = f0;
    dataout.A0.v = A0;
    dataout.dc.v = dc;
    
    % return modulation signal parameters:
    dataout.f_mod.v = fm;
    dataout.A_mod.v = Am;
    dataout.mod.v = 100*Am/A0;
           
    % --------------------------------------------------------------------
    % End of the demonstration algorithm.
    % --------------------------------------------------------------------


end % function


% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
