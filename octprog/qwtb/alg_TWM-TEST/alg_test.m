function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-TEST.
%
% See also qwtb

    % samples count to synthesize:
    N = 1e5;
    
    % sampling rate [Hz]
    din.fs.v = 10000;
    
    % harmonic amplitudes:
    A =  [1    0.5  0.2]';
    % harmonic phases:
    ph = [0.1 -0.8  0.2]'*pi;
    % harmonic component index {1st, 2rd, ..., floor(N/2)}:
    fk = [1    5    round(0.4*N)]';
    
    adc_std_noise = 0.1e-6;
    
    if true
        % create some corretion table for the digitizer gain: 
        din.adc_gain_f.v = [0;1e3;1e6];
        din.adc_gain_a.v = [];
        din.adc_gain.v = [1.00; 1.10; 1.50];
        din.adc_gain.u = [0.01; 0.02; 0.03]; 
        % create some corretion table for the digitizer phase: 
        din.adc_phi_f.v = [0;1e3;1e6];
        din.adc_phi_a.v = [];
        din.adc_phi.v = [0.00; 0.010; 0.1];
        din.adc_phi.u = [0.01; 0.02;  0.2];
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
        
        % define some timestamp (high-side channel):
        din.time_stamp.v = rand(1)*0.01; % random time-stamp
                
        
        % ADC aperture correction:
        din.adc_aper_corr.v = 1; % state
        din.adc_aper.v = 1e-5; % aperture value
        
        
        % transducer type:
        din.tr_type.v = 'rvd';        
        % create some corretion table for the transducer gain: 
        din.tr_gain_f.v = [0;1e3;1e6];
        din.tr_gain_a.v = [];
        din.tr_gain.v = [1.00; 0.80; 0.60]*70;
        din.tr_gain.u = [0.01; 0.02; 0.05]; 
        % create some corretion table for the transducer phase: 
        din.tr_phi_f.v = [0;1e3;1e6];
        din.tr_phi_a.v = [];
        din.tr_phi.v = [0.00; -0.10; -0.5];
        din.tr_phi.u = [0.01;  0.02;  0.1];
        % RVD transducer low-side impedance:
        din.tr_Zlo_f.v  = [];
        din.tr_Zlo_Rp.v = [200];
        din.tr_Zlo_Cp.v = [1e-12];        
        din.tr_Zlo_Rp.u = [1e-6];
        din.tr_Zlo_Cp.u = [1e-12];    
    end
    
    % uncomment to enable differential transducer simulation:
    %  note: current loop low-impedance
    Zx = 0.5;
    
    
    % Restore orientations of the input vectors to originals (before passing via QWTB)
    % note: this is used just for more convenient programming of the test function...
    din.y.v = ones(10,1); % fake data vector just to make following function work!
    if exist('Zx','var'), din.y_lo.v = din.y.v; end
    [din,cfg] = qwtb_restore_twm_input_dims(din,1);
    % Rebuild TWM style correction tables:
    tab = qwtb_restore_correction_tables(din,cfg);
         
    % calculate actual frequencies of the harmonics:
    fx = fk/N*din.fs.v;
    
    % apply transducer transfer:
    A_syn = [];
    ph_syn = [];
    sctab = {};
    tsh = [];
    if cfg.y_is_diff
        % -- differential connection:
        [A_syn(:,1),ph_syn(:,1),A_syn(:,2),ph_syn(:,2)] = correction_transducer_sim(tab,din.tr_type.v,fx, A,ph,0*A,0*ph,'',Zx);
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
        [A_syn(:,1),ph_syn(:,1)] = correction_transducer_sim(tab,din.tr_type.v,fx, A,ph,0*A,0*ph,'');
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
        ap_gain = sin(pi*ta*fx)./(pi*ta*fx);
        ap_phi  = -pi*ta*fx;        
        % apply it to subchannels:
        A_syn  = bsxfun(@times,ap_gain,A_syn);
        ph_syn = bsxfun(@plus, ap_phi, ph_syn);
    end
    
    % for each transducer subchannel:
    for c = 1:numel(sctab)
    
        % interpolate digitizer gain/phase to the measured frequencies and amplitudes:
        k_gain = correction_interp_table(sctab{c}.adc_gain,A_syn(:,c),fx,'f',1);    
        k_phi =  correction_interp_table(sctab{c}.adc_phi, A_syn(:,c),fx,'f',1);
        
        % apply digitizer gain:
        Ac  = A_syn(:,c)./k_gain.gain;
        phc = ph_syn(:,c) - k_phi.phi;
        
        % generate relative time 2*pi*t:
        % note: include time-shift and timestamp delay:
        t = [];
        t(:,1) = ([0:N-1]/din.fs.v + tsh(c) + din.time_stamp.v)*2*pi;
        
        % synthesize waveform (crippled for Matlab < 2016b):
        % u = Ac.*sin(t.*fx + phc);
        u = bsxfun(@times, Ac', sin(bsxfun(@plus, bsxfun(@times, t, fx'), phc')));
        % sum the harmonic components to a single composite signal:
        u = sum(u,2);
        
        u = u + randn(N,1)*adc_std_noise;

        % store to the QWTB input list:
        din = setfield(din, cfg.ysub{c}, struct('v',u));
    
    end
        

    % --- execute the algorithm:
    dout = qwtb('TWM-TEST',din);
    
    % reference values:
    rms_ref = sum(0.5*A.^2).^0.5;
    
    
    
       
    % maximum harmonics to print:
    H_max = 10;
    
    % identify H_max dominant harmonics:
    Ax = dout.amp.v; 
    [v,id] = sort(Ax);
    % reorder them to original freq. order: 
    id = sort(id(max(end-H_max+1,1):end));    
    H = numel(id);
    
    % --- print summary of the results:
    fprintf('--------+-------------+-------------+-------------+----------\n');
    fprintf('    H   |    REF(A)   |    DUT(A)   |   ABS DEV   |  %%-DEV   \n');
    fprintf('--------+-------------+-------------+-------------+----------\n');
    for h = 1:H
        
        fid = find(id(h)-1 == fk,1);
        if ~isempty(fid)
            a_ref = A(fid);
        else
            a_ref = 0;
        end            
        a_dut = dout.amp.v(id(h));
        
        fprintf(' %-6d | %11.6f | %11.6f | %+11.6f | %+8.4f \n',id(h)-1,a_ref,a_dut,a_dut - a_ref,100*(a_dut - a_ref)/a_ref);
        
    end
    fprintf('--------+-------------+-------------+-------------+----------\n\n');
    
    
    fprintf('--------+-----------+-----------+-----------\n');
    fprintf('    H   |  REF(ph)  |  DUT(ph)  |  ABS DEV   \n');
    fprintf('--------+-----------+-----------+-----------\n');
    for h = 1:H
        
        fid = find(id(h)-1 == fk,1);
        if ~isempty(fid)
            p_ref = ph(fid);
        else
            p_ref = 0;
        end            
        p_dut = dout.phi.v(id(h));
        if isempty(fid)
            p_dut = 0;
        end
        
        fprintf(' %-6d | %9.6f | %9.6f | %+8.6f \n',id(h)-1,p_ref,p_dut,p_dut-p_ref);
        
    end
    fprintf('--------+-----------+-----------+-----------\n\n');
    
    fprintf('--------------+--------------+--------------+----------\n');
    fprintf('   REF(rms)   |    DUT(rms)  |    ABS DEV   | ppm-DEV  \n');
    fprintf('--------------+--------------+--------------+----------\n');
    fprintf(' %12.7f | %12.7f | %+12.7f | %+8.3f \n',rms_ref,dout.rms.v,dout.rms.v - rms_ref,1e6*(dout.rms.v - rms_ref)/rms_ref);
    fprintf('--------------+--------------+--------------+----------\n');
        
 
    % --- compare calcualted results with desired:
    assert(any(abs([dout.amp.v(1+fk)] - A(:))./A(:) < 1e-6),'TWM-TEST testing: calculated amplitudes do not match!')
    assert(abs([dout.phi.v(1+fk)] - ph(:)) < 5e-6,'TWM-TEST testing: calculated phases do not match!');          
    assert(abs(dout.rms.v - rms_ref)/rms_ref < 1e-6,'TWM-TEST testing: calculated rms value does not match!');
    
end
   