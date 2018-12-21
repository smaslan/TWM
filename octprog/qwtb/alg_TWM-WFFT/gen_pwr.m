function [dout,simout] = gen_pwr(din,cfg,rand_unc)
% This is signal generator for simulation of voltage and current waveforms
% with known power parameters. It supports simulation of a single ended 
% and/or differential input sensors.
% 
%
% Usage:  
%   dout = gen_pwr(din, cfg, rand_unc)
%
% Parameters:
%   din - all the QWTB style corrections data defined by the TWM.        
%         If not assigned, it will generate default values internally.
%          Content:
%           din.fs.v - sampling rate [Hz], required
%          all others are optional:
%           din.*adc_gain... - ADC gain correction matrices
%           din.*adc_phi... - ADC phase shift correction matrices
%           din.*adc_offset - ADC DC offset [V]
%           din.*adc_bits - ADC bits count (not implemented yet)
%           din.*adc_nrng - ADC nominal range (not implemented yet)
%           din.*adc_jitter - ADC jitter value [s]
%           din.*adc_Yin... - ADC input admittance matrices
%           din.adc_aper - ADC aperture
%           din.adc_freq - ADC timebase correction
%           din.time_stamp - first sample time-stamp
%           din.ac_coupling - non-zero to calculate ref. power values wihtout DC component
%                           - note it does not affect the generator, it always generates DC 
%           din.**timeshift_lo - low side channel time shift value [s]
%           din.**tr_type - transducer type string ('rvd' or 'shunt')
%           din.**tr_gain... - transducer gain correction matrices
%           din.**tr_phi... - transducer phase correction matrices
%           din.**tr_Zlo... - transducer low-side Z matrices (for RVD only)
%           din.**tr_Zca... - transducer high-side terminals Z matrices
%           din.**tr_Zcal... - transducer low-side terminals Z matrices
%           din.**tr_Zcam... - transducer terminals mutual inductance matrices
%           din.**tr_Yca... - transducer terminals shunting Y matrices
%           din.**tr_Zcb... - transducer cable(s) series Z matrices
%           din.**tr_Ycb... - transducer cable(s) shunting Y matrices
%           *  - prefix of subchannel ('u_' or 'i_' - high-side channel or SE
%                                      or 'lo_u_', 'lo_i_' - low-side channel for diff. mode)
%           ** - prefix of channel ('u_' or 'i_' - channel prefix)
% 
%   cfg - configuration of the simulator:
%     cfg.N - samples count to generate
%     cfg.chn{} - cell array of channels {1} - U-channel, {2} - I-channel:
%       cfg.chn{}.fx - harmonic component frequencies [Hz]
%       cfg.chn{}.A  - harmonic component amplitudes
%       cfg.chn{}.ph - armonic component phases [rad]
%       cfg.chn{}.dc - DC offset of the signal
%       cfg.chn{}.sfdr - max. SFDR of harmonic spurrs (relative to Ax(1))
%       cfg.chn{}.sfdr_hn - maximum count of harmonic spurrs
%       cfg.chn{}.sfdr_rand - non-zero enable randomization of spurr amplitudes
%                             from 0 to cfg.sfdr
%       cfg.chn{}.sfdr_rand_f - how much to randomize spurrs from exact harmonics
%                               e.g.: 0.1 = 10% of f0
%       cfg.chn{}.adc_std_noise - rms noise at the ADC input [V] 
%       cfg.chn{}.Zx - loop impedance for the differential transducer mode.
%                      when found in the structure, the diff. mode is enabled.
%   rand_unc - non-zero means all the corrections in 'din' will be randomized
%              according their uncertainties. Zero value discard all uncertainties
%              even in the returned quantities 'dout'.
%
% Returns:
%   dout - copy of 'din' with added signals 'u', 'i' (and 'u_lo', 'i_lo')
%   simout - simulated power parameters:
%     simout.U_rms - rms voltage level [V] 
%     simout.I_rms - rms current level [A]
%     simout.P     - rms power [W]
%     simout.S     - apparent power [VA]
%     simout.Q     - reactive power [VAr]
%     simout.PF    - power factor [-]
%     
%
% License:
% --------
% This is part of the TWM tool (https://github.com/smaslan/TWM).
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT


    % corretions interpolation mode:
    %  note: must be the same as in the alg. itself!
    %        for frequency corrections the best is usually 'pchip'
    i_mode = 'pchip';
    

    if ~rand_unc
        % discard all correction uncertainties when randomization not allowed:        
        corrz = fieldnames(din);        
        for k = 1:numel(corrz)
            c_data = getfield(din,corrz{k});
            if isfield(c_data,'u')
                c_data.u = 0*c_data.u;
                din = setfield(din,corrz{k},c_data);
            end            
        end
    end

    % remember original input quantities:
    %  note: so the sample data are written to these instead of the ones modified during the following code 
    dout = din;
    
    % power generation?
    %  note: zero for single channel RMS generatio
    is_pwr = numel(cfg.chn) > 1;
    
    
    % Restore orientations of the input vectors to originals (before passing via QWTB)
    % Note the function also generates default values of all corrections so the generator
    %       may be used even without any correction data.
    if is_pwr
        din.u.v = ones(10,1); % fake data vector just to make following function work!
        din.i.v = ones(10,1); % fake data vector just to make following function work!
        if isfield(cfg.chn{1},'Zx'), din.u_lo.v = din.u.v; end
        if isfield(cfg.chn{2},'Zx'), din.i_lo.v = din.i.v; end
    else
        din.y.v = ones(10,1); % fake data vector just to make following function work!
        if isfield(cfg.chn{1},'Zx'), din.y_lo.v = din.y.v; end
    end    
    [din,t_cfg] = qwtb_restore_twm_input_dims(din,1);
        
    % Rebuild TWM style correction tables (just for more convenient calculations):
    tab = qwtb_restore_correction_tables(din,t_cfg);
    
    
        

    
    % --- For each virtual channel (U,I): ---
    for c = 1:(is_pwr+1)
    
        % get current channel:
        chn = cfg.chn{c};
        
        % differential mode?
        is_diff = isfield(chn,'Zx');
                
        % i-channel timeshift:
        if is_pwr && chn.name == 'i'
            tsh = -din.time_shift.v + randn(1)*din.time_shift.u*rand_unc; % ###todo: decide if this has correct polarity!!!!!!!!!!!!!!!           
        else
            tsh = 0;
        end
        
        if isfield(din,'time_stamp')
            tsh = tsh + din.time_stamp.v;
        end            
        
        % channel prefix (eg.: 'u_'):
        if is_pwr
            cpfx = [chn.name '_'];
        else
            cpfx = '';
        end
                                        
        % load channel corrections for given v.channel:
        % note: this removes 'u_' or 'i_' prefix so the rest of code can be run in loop for both U and I v.channels
        tab_list = {'tr_gain','tr_phi','tr_Zca','tr_Yca','tr_Zcal','tr_Zcam','adc_Yin','lo_adc_Yin','Zcb','Ycb','tr_Zlo','adc_gain','adc_phi','lo_adc_gain','lo_adc_phi','tr_sfdr','adc_sfdr','lo_adc_sfdr'};
        if is_pwr
            chtab = conv_vchn_tabs(tab,chn.name,tab_list);
        else
            chtab = tab;
        end
            
        % insert fake DC component to the harmonic list:
        chn.fxg = [1e-12;  chn.fx];
        chn.Ag  = [chn.dc; chn.A];
        chn.phg = [0;      chn.ph];
                
        % rms level of the input signal:
        rms = sum(0.5*chn.A.^2)^0.5;
        
        % include DC?
        cfg.chn{c}.rms_ac = rms;
        if ~isfield(din,'ac_coupling') || ~din.ac_coupling.v
            rms = (rms^2 + chn.dc^2)^0.5;       
        end                
        cfg.chn{c}.rms = rms;
        
                
        
        % ###todo: this should probably somehow be scaled by the transducer transfer??
        % add SFDR harmonic spurrs to the composite signal:
        fh = chn.fx(1)*[2:chn.sfdr_hn+1]'; % odd and even harmonics
        fh = fh + (2-2*rand(size(fh)))*chn.sfdr_rand_f*chn.fx(1); % randomize frequencies (optional)
        fh = fh(fh < 0.45*din.fs.v); % limit by nyquist
        if chn.sfdr_rand
            Ah = rand(size(fh))*chn.sfdr*chn.A(1); % random amplitudes
        else
            Ah = ones(size(fh))*chn.sfdr*chn.A(1); % maximum amplitudes
        end
        phh = rand(size(fh))*2*pi; % random phase angles     
        % add SFDR spurrs to the harmonics list:
        chn.fxg = [chn.fxg; fh];
        chn.Ag  = [chn.Ag;  Ah];
        chn.phg = [chn.phg; phh];
        
                               
        % --- apply transducer transfer:
        if rand_unc, rand_unc_str = 'rand'; else rand_unc_str = ''; end % randomize uncertainty option:
        A_syn = [];
        ph_syn = [];
        tsh_lo = [];
        sctab = {};
        sub_chn = {};        
        if is_diff
            % -- differential connection (create two subchannels: high and low-side):            
            [A_syn(:,1),ph_syn(:,1),A_syn(:,2),ph_syn(:,2)] = correction_transducer_sim(chtab,chn.type,chn.fxg,chn.Ag,chn.phg,0,0,rand_unc_str,chn.Zx);
            is_neg = 2*(abs(angle(A_syn(1,:).*exp(j*ph_syn(1,:)))) < 0.1) - 1; % sub-channel DC polarities
            A_syn(1,:) = A_syn(1,:).*is_neg;
            
            % prepare digitizer sunchannel correction tables:
            sctab{1}.adc_gain = chtab.adc_gain; % high-side
            sctab{1}.adc_phi  = chtab.adc_phi;
            sctab{1}.adc_sfdr  = chtab.adc_sfdr;
            sctab{2}.adc_gain = chtab.lo_adc_gain; % low-side
            sctab{2}.adc_phi  = chtab.lo_adc_phi;
            sctab{2}.adc_sfdr  = chtab.lo_adc_sfdr;
            
            % prepare subchannel timeshifts:
            tsh_lo(1) = 0; % high-side
            tslo = getfield(din,[cpfx 'time_shift_lo']); 
            tsh_lo(2) = tslo.v + randn(1)*tslo.u.*rand_unc; % low-side ###todo: decide if the polarity is ok!!!!
            
            % subchannel waveform names:
            sub_chn{1} = chn.name; % high-side
            sub_chn{2} = [chn.name '_lo']; % low-side
            
            % ADC offset:
            adc_ofs(1) = getfield(din,[cpfx 'adc_offset']);
            adc_ofs(2) = getfield(din,[cpfx 'lo_adc_offset']);
            
            % ADC jitter:
            adc_jitt(1) = getfield(din,[cpfx 'adc_jitter']);
            adc_jitt(2) = getfield(din,[cpfx 'lo_adc_jitter']);
            
        else
            % -- single-ended connection (create single channel):
            [A_syn,ph_syn] = correction_transducer_sim(chtab,chn.type,chn.fxg,chn.Ag,chn.phg,0,0,rand_unc_str);
            A_syn = bsxfun(@times,A_syn,sign(chn.Ag)); % restore DC polarity
            % prepare digitizer sunchannel correction tables:
            sctab{1}.adc_gain = chtab.adc_gain;
            sctab{1}.adc_phi  = chtab.adc_phi;
            sctab{1}.adc_sfdr  = chtab.adc_sfdr;
            % prepare subchannel timeshifts:
            tsh_lo(1) = 0;
            % subchannel waveform names:
            sub_chn{1} = chn.name;
            % ADC offset:
            if is_pwr
                chn_pfx_str = [chn.name '_'];
            else
                chn_pfx_str = '';
            end
            adc_ofs(1) = getfield(din,[chn_pfx_str 'adc_offset']);
            % ADC jitter:
            adc_jitt(1) = getfield(din,[chn_pfx_str 'adc_jitter']);            
        end
        
        % apply aperture error:
        ta = din.adc_aper.v;
        if abs(ta) > 1e-12
            ap_gain = sin(pi*ta*chn.fxg)./(pi*ta*chn.fxg);
            ap_phi  = -pi*ta*chn.fxg;
            ap_gain(1) = 1;            
            ap_phi(1) = 0;
            A_syn  = bsxfun(@times, A_syn, ap_gain);
            ph_syn = bsxfun(@plus, ph_syn, ap_phi);
        end
        
        % --- for each sub channel (low/high-side): 
        for k = 1:size(A_syn,2)
        
            % interpolate digitizer gain/phase to the measured frequencies and amplitudes:
            k_gain = correction_interp_table(sctab{k}.adc_gain, abs(A_syn(:,k)), chn.fxg,'f',1, i_mode);   
            k_phi =  correction_interp_table(sctab{k}.adc_phi,  abs(A_syn(:,k)), chn.fxg,'f',1, i_mode);
                        
            % apply digitizer gain:
            Ac  = A_syn(:,k)./(k_gain.gain + randn(size(A_syn(:,k))).*k_gain.u_gain*rand_unc);
            phc = ph_syn(:,k) - k_phi.phi + randn(size(ph_syn(:,k))).*k_phi.u_phi*rand_unc;            
                                                 
            % generate time vector 2*pi*t:
            % note: including time shifts, jitterm etc.!
            t = [];
            t(:,1) = ([0:cfg.N-1]/din.fs.v + tsh + tsh_lo(k) + adc_jitt(k).v*randn(1,cfg.N))*2*pi;
            
            % generate DC component:
            u = repmat(Ac(1),size(t));
            
            % synthesize rest of the harmonics (one by one harmonic to prevent insane sized matrix):        
            for m = 2:numel(chn.fxg)
                u = u + Ac(m)*sin(t*chn.fxg(m) + phc(m));  
            end
            
            % add some ADC noise:
            u = u + randn(size(u))*chn.adc_std_noise;
            
            % add ADC offset:
            u = u + adc_ofs(k).v + adc_ofs(k).u*randn;
            
            % store to the QWTB input list:
            dout = setfield(dout, sub_chn{k}, struct('v',u));
            
%             figure;
%             plot(u)

        end
    
    end
    
    % calculate reference values:
    if is_pwr
        simout.U_rms = cfg.chn{1}.rms;
        simout.I_rms = cfg.chn{2}.rms;
        simout.S = cfg.chn{1}.rms_ac.*cfg.chn{2}.rms_ac;
        simout.P = 0.5*sum(cfg.chn{1}.A.*cfg.chn{2}.A.*cos(cfg.chn{2}.ph - cfg.chn{1}.ph));
        Q_tmp = 0.5*sum((cfg.chn{1}.A.*cfg.chn{2}.A.*sin(cfg.chn{2}.ph - cfg.chn{1}.ph)));
        simout.Q = (simout.S^2 - simout.P^2)^0.5*sign(Q_tmp); % ###note: the sign() thingy estimates actual polarity of Q.
                                                              %          It won't work properly for highly distorted waveforms and for PF near 0.
        if ~isfield(din,'ac_coupling') || ~din.ac_coupling.v
            simout.P = simout.P + (cfg.chn{1}.dc*cfg.chn{2}.dc);
            simout.S = cfg.chn{1}.rms.*cfg.chn{2}.rms;
        end        
        %simout.Q  = (simout.S^2 - simout.P^2)^0.5;
        simout.PF = simout.P/simout.S;
        simout.phi_ef = atan2(simout.Q,simout.P);
        % DC components:
        simout.Udc = cfg.chn{1}.dc;
        simout.Idc = cfg.chn{2}.dc;
        simout.Pdc = cfg.chn{1}.dc*cfg.chn{2}.dc;
    
    else
        simout.rms = cfg.chn{1}.rms;
        simout.dc = cfg.chn{1}.dc;
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
