function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-PSFE.
%
% See also qwtb

    % samples count to synthesize:
    N = 5e3;
    
    % sampling rate [Hz]
    din.fs.v = 100000;
    
    % randomize correction uncertainties:     
    rand_unc = 0;
     
    
    % harmonic amplitudes:
    A =  [1       logrand(1e-6,0.01)  logrand(1e-6,0.01)]';
    % harmonic phases:
    ph = [0.5/pi  2*rand()            2*rand()]'*pi;
    % harmonic freq. [Hz]:
    fx = [1000   (5000+1000*rand())  (10000+2000*rand())]';
    % dc offset:
    dc = 0.1;
    
    % current loop impedance (used for simulation of differential transducer):
    Zx = 0.5;
    
    % non-zero to generate differential input signal:
    is_diff = 0;
               
    % ADC rms noise level:
    adc_std_noise = 10e-6;
        
    
    
    
         
    
    % ADC aperture [s]:
    % note: non-zero value will simulate aperture gain/phase error 
    din.adc_aper.v = 20e-6;
    
    % ADC aperture correction enabled:
    % note: non-zero value will enable correction of the gain/phase error by alg.
    din.adc_aper_corr.v = 1;
    din.lo_adc_aper_corr.v = 1;
    
    
    % generate some time-stamp of the digitizer channel:
    % note: the algorithm must 'unroll' the calculated phase accordingly,
    %       so whatever is put here should have no effect to the estimated phase         
    din.time_stamp.v = rand(1)*0.000; % random time-stamp
    
    % timestamp compensation:
    din.comp_timestamp.v = 1;
        
    % create some corretion table for the digitizer gain: 
    din.adc_gain_f.v = [0;1e3;1e6];
    din.adc_gain_a.v = [];
    din.adc_gain.v = [1.000; 1.100; 1.500];
    din.adc_gain.u = [0.001; 0.002; 0.003]*0.01; 
    % create some corretion table for the digitizer phase: 
    din.adc_phi_f.v = [0;1e3;1e6];
    din.adc_phi_a.v = [];
    din.adc_phi.v = [0.000; 0.100; 0.500]*pi;
    din.adc_phi.u = [0.001; 0.002; 0.005]*pi*0.01;
    % create some low-side corretion table for the digitizer gain: 
    din.lo_adc_gain_f = din.adc_gain_f;
    din.lo_adc_gain_a = din.adc_gain_a;
    din.lo_adc_gain = din.adc_gain;
    din.lo_adc_gain.v = din.lo_adc_gain.v*1.5; 
    % create some low-side corretion table for the digitizer phase: 
    din.lo_adc_phi_f = din.adc_phi_f;
    din.lo_adc_phi_a = din.adc_phi_a;
    din.lo_adc_phi = din.adc_phi;
    din.lo_adc_phi.v = din.lo_adc_phi.v - 0.001*pi;
    % create corretion of the digitizer timebase:
    din.adc_freq.v = 0.000100;
    din.adc_freq.u = 0.000005;
    % create corretion of the digitizer timebase:
    din.adc_offset.v = 0.001;
    din.adc_offset.u = 0.000005;
    din.lo_adc_offset.v = -0.002;
    din.lo_adc_offset.u = 0.000005;
    
    % define some low-side channel timeshift:
    din.time_shift_lo.v = -1.234e-4;
    din.time_shift_lo.u = 1e-6;
    
    
    % transducer type ('rvd' or 'shunt')
    din.tr_type.v = 'rvd';
        
    % create some corretion table for the transducer gain: 
    din.tr_gain_f.v = [0;1e3;1e6];
    din.tr_gain_a.v = [];
    din.tr_gain.v = [1.000; 0.900; 0.800]*5;
    din.tr_gain.u = [0.001; 0.002; 0.005]*0.01; 
    % create some corretion table for the transducer phase: 
    din.tr_phi_f.v = [0;1e3;1e6];
    din.tr_phi_a.v = [];
    din.tr_phi.v = [0.000; -0.0200; -0.0500]*pi;
    din.tr_phi.u = [0.001;  0.0002;  0.0005]*pi*0.1;
        
    % RVD low-side impedance:
    din.tr_Zlo_f.v = [];
    din.tr_Zlo_Rp.v = [200.00];
    din.tr_Zlo_Rp.u = [  0.05];
    din.tr_Zlo_Cp.v = [1e-12];
    din.tr_Zlo_Cp.u = [1e-12];
    
        
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
    
    
    % remember original input quantities:
    datain = din; 
    % Restore orientations of the input vectors to originals (before passing via QWTB)
    din.y.v = ones(10,1); % fake data vector just to make following function work!
    if is_diff, din.y_lo.v = din.y.v; end
    [din,cfg] = qwtb_restore_twm_input_dims(din,1);
    % Rebuild TWM style correction tables (just for more convenient calculations):
    tab = qwtb_restore_correction_tables(din,cfg);
    
    
    % store estimate of the frequency to find:
    datain.f_est.v = fx(1);
    
    
    
    % build virtual harmonic with DC component:
    fx = [fx;1e-12];
    A = [A;dc];
    ph = [ph;pi/2];            
    
    % apply transducer transfer:
    if rand_unc
        rand_str = 'rand';
    else
        rand_str = '';
    end
    A_syn = [];
    ph_syn = [];
    sctab = {};
    tsh = [];
    ap_state = [];
    if is_diff
        % -- differential connection:
        [A_syn(:,1),ph_syn(:,1),A_syn(:,2),ph_syn(:,2)] = correction_transducer_sim(tab,din.tr_type.v,fx, A,ph,0*A,0*ph,rand_str,Zx);
        % subchannel correction tables:
        sctab{1}.adc_gain = tab.adc_gain;
        sctab{1}.adc_phi  = tab.adc_phi;
        sctab{2}.adc_gain = tab.lo_adc_gain;
        sctab{2}.adc_phi  = tab.lo_adc_phi;
        % subchannel timeshift:
        tsh(1) = 0; % high-side channel
        tsh(2) = din.time_shift_lo.v; % low-side channel
        % aperture:
        ap_state(1) = din.adc_aper_corr.v;
        ap_state(2) = din.lo_adc_aper_corr.v;
        % ADC offset:
        adc_ofs(1) = din.adc_offset;
        adc_ofs(2) = din.lo_adc_offset;
    else
        % -- single-ended connection:
        [A_syn(:,1),ph_syn(:,1)] = correction_transducer_sim(tab,din.tr_type.v,fx, A,ph,0*A,0*ph,rand_str);
        % subchannel correction tables:
        sctab{1}.adc_gain = tab.adc_gain;
        sctab{1}.adc_phi  = tab.adc_phi;
        % subchannel timeshift:
        tsh(1) = 0; % none for single-ended mode
        % aperture:
        ap_state(1) = din.adc_aper_corr.v;
        % ADC offset:
        adc_ofs(1) = din.adc_offset;
    end
            
    % get ADC aperture value [s]:
    ta = abs(din.adc_aper.v);

    % calculate aperture gain/phase correction:
    ap_gain = sin(pi*ta*fx)./(pi*ta*fx);
    ap_phi  = -pi*ta*fx;
        
    % for each transducer subchannel:
    for c = 1:numel(sctab)
        
        % interpolate digitizer gain/phase to the measured frequencies and amplitudes:
        k_gain = correction_interp_table(sctab{c}.adc_gain,A_syn(:,c),fx,'f',1);    
        k_phi =  correction_interp_table(sctab{c}.adc_phi, A_syn(:,c),fx,'f',1);
        
        % apply digitizer gain:
        Ac  = A_syn(:,c)./k_gain.gain;
        phc = ph_syn(:,c) - k_phi.phi;
        
        % apply aperture error:
        if ap_state(c) && ta > 1e-12
            Ac = Ac.*ap_gain;
            phc = phc + ap_phi;
        end
        
        % randomize ADC gain:
        if rand_unc
            Ac  = Ac.*(1 + k_gain.u_gain.*randn(size(Ac)));
            phc = phc + k_phi.u_phi.*randn(size(phc));
        end
        
        % DC component to zero freq.:
        fxt = fx;
        fxt(end) = 0;
        
        % generate relative time 2*pi*t:
        % note: include time-shift and timestamp delay and frequency error:        
        tstmp = din.time_stamp.v;       
        t = [];
        t(:,1) = ([0:N-1]/din.fs.v + tsh(c) + tstmp)*(1 + din.adc_freq.v)*2*pi;
        
        % synthesize waveform (crippled for Matlab < 2016b):
        % u = Ac.*sin(t.*fxt + phc);
        u = bsxfun(@times, Ac', sin(bsxfun(@plus, bsxfun(@times, t, fxt'), phc')));
        % sum the harmonic components to a single composite signal:
        u = sum(u,2);
        
        % add some noise:
        u = u + randn(N,1)*adc_std_noise;
        
        % add ADC offset:
        u = u + adc_ofs(c).v + adc_ofs(c).u*randn;
        
        % store to the QWTB input list:
        datain = setfield(datain, cfg.ysub{c}, struct('v',u));
    
    end
    
    % add fake uncertainties to allow uncertainty calculation:
    %  ###todo: to be removed when QWTB supports no uncertainty checking 
    alginf = qwtb('TWM-FPNLSF','info');
    qwtb('TWM-FPNLSF','addpath');    
    datain = qwtb_add_unc(datain,alginf.inputs);
        

    % --- execute the algorithm:
    calcset.unc = 'guf';
    dout = qwtb('TWM-FPNLSF',datain,calcset);
    
    % get reference values:
    f0  = fx(1);
    Ar  = A(1);
    phr = ph(1);    
    
    % get calculated values and uncertainties:
    fx  = dout.f.v;
    Ax  = dout.A.v;
    phx = mod(dout.phi.v+pi,2*pi)-pi; % wrap to +-pi
    ofsx  = dout.ofs.v;
    u_fx  = dout.f.u*2;
    u_Ax  = dout.A.u*2;
    u_phx = dout.phi.u*2;
    u_ofsx = dout.ofs.u*2;
%     if ~rand_unc
%         u_fx  = f0*1e-8;
%         u_Ax  = Ar*1e-6;
%         u_phx = 1e-6;
%     end
    
    
    % print results:
    ref_list =  [f0, Ar, phr, dc];    
    dut_list =  [fx, Ax, phx, ofsx];
    unc_list =  [u_fx, u_Ax, u_phx, u_ofsx];
    name_list = {'f','A','ph','dc'};
    
    fprintf('   |     REF     |     DUT     |   ABS DEV   |  %%-DEV   |     UNC     |  %%-UNC \n');
    fprintf('---+-------------+-------------+-------------+----------+-------------+----------\n');
    for k = 1:numel(ref_list)
        
        ref = ref_list(k);
        dut = dut_list(k);
        unc = unc_list(k);
        name = name_list{k};
        
        fprintf('%-2s | %11.6f | %11.6f | %+11.6f | %+8.4f | %+11.6f | %5.0f\n',name,ref,dut,dut - ref,100*(dut - ref)/ref,unc,100*abs(dut - ref)/unc);
        
    end   
    
        
    % check frequency estimate:
    assert(abs(fx - f0) < u_fx, 'Estimated freq. does not match generated one.');
    
    if ~is_diff
    
        % check amplitude match     
        assert(abs(Ax - Ar) < u_Ax, 'Estimated amplitude does not match generated one.');
        
        % check phase match     
        assert(abs(phx - phr) < u_phx, 'Estimated phase does not match generated one.'); 
    end                                                     
    
end


function [rnd] = logrand(A_min,A_max)
    rnd = 10.^(log10(A_min) + (log10(A_max) - log10(A_min))*rand());
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
   