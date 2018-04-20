function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-MODTDPS.
%
% See also qwtb

    % samples to synthesize:
    N = 30000;
    
    % sampling rate:
    fs = 10000;
    
    % carrier:
    f0 = 50.3;
    A0 = 50;
    
    % modulating signal:    
    fm = 2.321;
    Am = A0*0.333333;    
    phm = rand(1)*2*pi; % random phase
    wshape = 'sine';
    
    % digitizer std noise:    
    adc_std_noise = 1e-6;
    
    % digitizer jitter:
    jitter = 100e-9;
    
    % enable algorithm self-compensation?
    din.comp_err.v = 1;
    
    % enable differential sensor connection?
    is_diff = 0;
    
    % randomize uncertainties?
    rand_unc = 0;
    
    
    % store some input quantities:
    din.fs.v = fs;    
    din.wave_shape.v = wshape;
        
    % store correction data:
    if true
        % create some corretion table for the digitizer gain: 
        din.adc_gain_f.v = [0;1e3;1e6];
        din.adc_gain_a.v = [];
        din.adc_gain.v = [1.0000; 1.1000; 1.5000];
        din.adc_gain.u = [0.0001; 0.0002; 0.0003]; 
        % create some corretion table for the digitizer phase: 
        din.adc_phi_f.v = [0;1e3;1e6];
        din.adc_phi_a.v = [];
        din.adc_phi.v = [0.00000; 0.00010; 0.0010];
        din.adc_phi.u = [0.00010; 0.00020; 0.0020];
        % create some corretion table for the digitizer gain: 
        din.lo_adc_gain_f = din.adc_gain_f;
        din.lo_adc_gain_a = din.adc_gain_a;
        din.lo_adc_gain = din.adc_gain; 
        % create some corretion table for the digitizer phase: 
        din.lo_adc_phi_f = din.adc_phi_f;
        din.lo_adc_phi_a = din.adc_phi_a;
        din.lo_adc_phi = din.adc_phi;
        
        % define some low-side channel timeshift:
        din.time_shift_lo.v = 1.234e-4;
        din.time_shift_lo.u = 10e-6;
        
        % ADC aperture correction:
        din.adc_aper_corr.v = 1; % state
        din.adc_aper.v = 1e-5; % aperture value
        
        
        % transducer type:
        din.tr_type.v = 'rvd';        
        % create some corretion table for the transducer gain: 
        din.tr_gain_f.v = [0;1e3;1e6];
        din.tr_gain_a.v = [];
        din.tr_gain.v = [1.0000; 0.9500; 0.9000]*70;
        din.tr_gain.u = [0.0001; 0.0002; 0.0005]*70; 
        % create some corretion table for the transducer phase: 
        din.tr_phi_f.v = [0;1e3;1e6];
        din.tr_phi_a.v = [];
        din.tr_phi.v = [0.0000; -0.0010; -0.0020];
        din.tr_phi.u = [0.0001;  0.0002;  0.0010];
        % RVD transducer low-side impedance:
        din.tr_Zlo_f.v  = [];
        din.tr_Zlo_Rp.v = [200];
        din.tr_Zlo_Cp.v = [1e-12];        
        din.tr_Zlo_Rp.u = [1e-6];
        din.tr_Zlo_Cp.u = [1e-12];    
    
    end
    
    if ~rand_unc
        % discard all correction uncertainties:        
        corrz = fieldnames(din);        
        for k = 1:numel(corrz)
            c_data = getfield(din,corrz{k});
            if isfield(c_data,'u')
                c_data.u = 0*c_data.u;
                din = setfield(din,corrz{k},c_data);
            end            
        end
    end
    
    
    % enable differential transducer simulation?
    %  note: current loop low-impedance
    if is_diff
        Zx = 0.5;
    end
    
    
  
    % Restore orientations of the input vectors to originals (before passing via QWTB)
    % note: this is used just for more convenient programming of the test function...
    din.y.v = ones(10,1); % fake data vector just to make following function work!
    if exist('Zx','var'), din.y_lo.v = din.y.v; end
    din_org = din;
    [din,cfg] = qwtb_restore_twm_input_dims(din,1);
    % Rebuild TWM style correction tables:
    tab = qwtb_restore_correction_tables(din,cfg);
    
    
    
    if strcmpi(wshape,'sine')
        % SINE mode (synthesizing in freq. domain):
                
        % modulated signal frequency components:
        f =  [f0; f0-fm;    f0+fm];
        A =  [A0; 0.5*Am;   0.5*Am];
        ph = [0;  pi/2-phm; -pi/2+phm];
        
    elseif strcmpi(wshape,'rect')
        % SQUARE mode (synthesize in time domain - square would be too complex):
        
        f = f0;
        A = A0;
        ph = phm;        
        
    else
        error('Unsupported waveshape!');        
    end
    
    
        
    
    % apply transducer transfer:
    A_syn = [];
    ph_syn = [];
    sctab = {};
    tsh = [];
    if cfg.y_is_diff
        % -- differential connection:
        [A_syn(:,1),ph_syn(:,1),A_syn(:,2),ph_syn(:,2)] = correction_transducer_sim(tab,din.tr_type.v,f, A,ph,0*A,0*ph,'',Zx);
        % subchannel correction tables:
        sctab{1}.adc_gain = tab.adc_gain;
        sctab{1}.adc_phi  = tab.adc_phi;
        sctab{2}.adc_gain = tab.lo_adc_gain;
        sctab{2}.adc_phi  = tab.lo_adc_phi;
        % subchannel timeshift:
        tsh(1) = 0; % high-side channel
        tsh(2) = din.time_shift_lo.v; % low-side channel
    else
        % -- single-ended connection:
        [A_syn(:,1),ph_syn(:,1)] = correction_transducer_sim(tab,din.tr_type.v,f, A,ph,0*A,0*ph,'');
        % subchannel correction tables:
        sctab{1}.adc_gain = tab.adc_gain;
        sctab{1}.adc_phi  = tab.adc_phi;
        % subchannel timeshift:
        tsh(1) = 0; % none for single-ended mode
    end
    
    
    % apply ADC aperture error:
    if din.adc_aper_corr.v && din.adc_aper.v > 1e-12
        % get ADC aperture value [s]:
        ta = abs(din.adc_aper.v);
    
        % calculate aperture gain/phase correction:
        ap_gain = sin(pi*ta*f)./(pi*ta*f);
        ap_phi  = -pi*ta*f;        
        % apply it to subchannels:
        A_syn  = bsxfun(@times,ap_gain,A_syn);
        ph_syn = bsxfun(@plus, ap_phi, ph_syn);
    end
    
    % for each transducer subchannel:
    for c = 1:numel(sctab)
    
        % interpolate digitizer gain/phase to the measured frequencies and amplitudes:
        k_gain = correction_interp_table(sctab{c}.adc_gain,A_syn(:,c),f,'f',1);    
        k_phi =  correction_interp_table(sctab{c}.adc_phi, A_syn(:,c),f,'f',1);
        
        % apply digitizer gain:
        Ac  = A_syn(:,c)./k_gain.gain;
        phc = ph_syn(:,c) - k_phi.phi;
        
        % generate relative time 2*pi*t:
        % note: include time-shift and jitter:
        t = [];
        t(:,1) = ([0:N-1]/din.fs.v + tsh(c) + jitter*rand(1,N))*2*pi;
        
        if strcmpi(wshape,'sine')        
            % SINE modulation:
            
            % synthesize waveform (crippled for Matlab < 2016b):
            % u = Ac.*sin(t.*fx + phc);
            u = bsxfun(@times, Ac', sin(bsxfun(@plus, bsxfun(@times, t, f'), phc')));
            % sum the harmonic components to a single composite signal:
            u = sum(u,2);
        
        elseif strcmpi(wshape,'rect')
            % SQUARE modulation:
            
            u = sin(t*f + phc).*(Ac + 2*Ac*Am/A0*(0.5 - (mod(t*fm + phm,2*pi) > pi)));
        
        end
        
        % add some noise:
        u = u + randn(N,1)*adc_std_noise;
        
        % store to the QWTB input list:
        din_org = setfield(din_org, cfg.ysub{c}, struct('v',u));
    
    end
    
    % workaround for QWTB uncertainty checking
    %  ###todo: to be removed when QWTB fixed
    alginf = qwtb('TWM-MODTDPS','info');
    qwtb('TWM-MODTDPS','addpath');
    din_org = qwtb_add_unc(din_org,alginf.inputs);
    
    % --- execute the algorithm:
    calcset.unc = 'guf';
    dout = qwtb('TWM-MODTDPS',din_org,calcset);
    
    
    % get calculated values:
    A0x   = dout.A0.v;   
    u_A0x = dout.A0.u*2;    
    Amx   = dout.A_mod.v;   
    u_Amx = dout.A_mod.u*2;    
    modx   = dout.mod.v;   
    u_modx = dout.mod.u*2;    
    f0x   = dout.f0.v;
    u_f0x = dout.f0.u;    
    fmx   = dout.f_mod.v;
    u_fmx = dout.f_mod.u;
    
    % prepare reference values:
    modr = 100*Am/A0;
    
    % prepare list of quantities to print:
    r_list = [A0    Am    modr   f0    fm];
    x_list = [A0x   Amx   modx   f0x   fmx];
    u_list = [u_A0x u_Amx u_modx u_f0x u_fmx];
    n_list = {'A0','Am','mod','f0','fm'};
    
    % print results table:
    fprintf('\n------+------------+------------+-----------+----------+---------\n');
    fprintf(' NAME |    REF     |    CALC    |    DEV    |    UNC   | %%-UNC\n');
    fprintf('------+------------+------------+-----------+----------+---------\n');
    for k = 1:numel(n_list)
    
        fprintf('%5s | %10.6f | %10.6f | %10.6f| %8.6f | %+3.0f\n',n_list{k},r_list(k),x_list(k),x_list(k)-r_list(k),u_list(k),(x_list(k)-r_list(k))/u_list(k)*100);
            
    end
    fprintf('------+------------+------------+-----------+----------+---------\n\n');
       
    
end


function [din] = qwtb_add_unc(din,pin)
% this will create fake uncertainty for each non-parameter quantity
% ###TODO: to be removed, when QWTB will support no-unc checking
% It is just a temporary workaround.

    names = fieldnames(din);
    N = numel(names);

    p_names = {pin(~~[pin.parameter]).name};
    
    for k = 1:N
        if ~any(strcmpi(p_names,names{k}))
            v_data = getfield(din,names{k});
            if ~isfield(v_data,'u')
                v_data.u = 0*v_data.v;
                din = setfield(din,names{k},v_data);
            end
        end        
    end    
end
   