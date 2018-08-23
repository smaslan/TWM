function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-Flicker.
%
% See also qwtb

    % calculation setup:
    calcset.verbose = 1;
    calcset.unc = 'guf';
    calcset.loc = 0.95;
        
    %% Generate sample data
    % A time series representing voltage measured on a power supply line will be generated. Modulation
    % amplitude |dVV| in percents, modulation frequency |CPM| in changes per minute, line frequency
    % |f_c|, and line amplitude |A_c| in volts are selected according Table 5 of EN61000-4-15/A1, line
    % 4, collumn 3. Measurement time |siglen| and sampling frequency |f_s| are selected according
    % recommendations of algorithm flicker_sim. Resulted Pst should be very near 1. 
    dVV = 0.894;
    CPM = 39;
    Ac = 230.*sqrt(2);
    din.f_line.v = 50; % this is setup of the alg.
    fc = 50.3; % this is actually generated freq.
    siglen = 720;
    fs = 20000; din.fs.v = fs;
    pst_ref = 1.000; % this is just for comparing result
    % Frequency of the modulation (flicker) signal in hertz:
    fm = CPM/(60*2);
    % samples count:
    N = round(siglen*fs);
                    
    % DC voltage offset:
    dc = 0;
    
    % randomize uncertainties:
    rand_unc = 1;
        
    % digitizer noise level:
    adc_std_noise = 10e-6;
    
    % -- harmonics:
    % max. relative amplitude:
    h_A_max = 0.01;
    % maximum count:
    h_N = 10;
       
    
    
    % ADC aperture [s]:
    % note: non-zero value will simulate aperture gain/phase error 
    din.adc_aper.v = 20e-6;
    
    % ADC aperture correction enabled:
    % note: non-zero value will enable correction of the gain/phase error by alg.
    din.adc_aper_corr.v = 1;
    
    
    % create some corretion table for the digitizer gain: 
    din.adc_gain_f.v = [0;1e3;1e6];
    din.adc_gain_a.v = [];
    din.adc_gain.v = [1.000000; 1.000100; 1.50000]*1.1;
    din.adc_gain.u = [0.000010; 0.000020; 0.00030]*1.1; 
    % create some corretion table for the digitizer phase: 
    din.adc_phi_f.v = [0;1e3;1e6];
    din.adc_phi_a.v = [];
    din.adc_phi.v = [0.000000; 0.000100; 0.005000]*pi;
    din.adc_phi.u = [0.000010; 0.000020; 0.000500]*pi;
    % create corretion of the digitizer timebase:
    din.adc_freq.v = 0.001;
    din.adc_freq.u = 0.000005;
    % create corretion of the digitizer offset:
    din.adc_offset.v = 0.001;
    din.adc_offset.u = 0.000005;
    
    % transducer type ('rvd' or 'shunt')
    din.tr_type.v = 'rvd';
        
    % create some corretion table for the transducer gain: 
    din.tr_gain_f.v = [0;1e3;1e6];
    din.tr_gain_a.v = [];
    din.tr_gain.v = [1.000000; 0.900000; 0.600000]*400;
    din.tr_gain.u = [0.000010; 0.000020; 0.000050]*400; 
    % create some corretion table for the transducer phase: 
    din.tr_phi_f.v = [0;1e3;1e6];
    din.tr_phi_a.v = [];
    din.tr_phi.v = [0.000000; -0.002000; -0.005000]*pi;
    din.tr_phi.u = [0.000010;  0.000020;  0.000500]*pi;
        
    % RVD low-side impedance:
    din.tr_Zlo_f.v = [];
    din.tr_Zlo_Rp.v = [200.00];
    din.tr_Zlo_Rp.u = [  0.05];
    din.tr_Zlo_Cp.v = [1e-12];
    din.tr_Zlo_Cp.u = [1e-12];
    
    if ~rand_unc
        % discard all correction uncertainties if randomization disabled:        
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
    [din,cfg] = qwtb_restore_twm_input_dims(din,1);
    % Rebuild TWM style correction tables (just for more convenient calculations):
    tab = qwtb_restore_correction_tables(din,cfg);
    
    
    % generate list of harmonic components to generate:
    % order: [dc, f_carrier, spurrs...]     
    fx  = [1e-12, fc]';
    Ax  = [dc,    Ac]';
    phx = [pi/2,  rand*2*pi]';
    
    % generate some harmonic spurrs:
    fh(:,1) = (1 + [1:h_N])*fc;
    fh = fh(fh < 0.45*fs);
    Ah = rand(size(fh))*h_A_max*Ac;
    phh = rand(size(fh))*2*pi;
    % add to the list of generated stuff:
    fx = [fx;fh];
    Ax = [Ax;Ah];
    phx = [phx;phh];
        
    
    % apply transducer transfer:
    if rand_unc
        rand_str = 'rand';
    else
        rand_str = '';
    end
    % -- single-ended connection:
    [A_syn,ph_syn] = correction_transducer_sim(tab,din.tr_type.v,fx, Ax,phx,0*Ax,0*phx,rand_str);
    
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
    
    % interpolate digitizer gain/phase to the measured frequencies and amplitudes:
    k_gain = correction_interp_table(tab.adc_gain,A_syn,fx,'f',1);    
    k_phi  = correction_interp_table(tab.adc_phi, A_syn,fx,'f',1);
    
    % apply digitizer gain:
    Ac  = A_syn./k_gain.gain;
    phc = ph_syn - k_phi.phi;
    
    % randomize ADC gain:
    if rand_unc
        Ac  = Ac.*(1 + k_gain.u_gain.*randn(size(Ac)));
        phc = phc + k_phi.u_phi.*randn(size(phc));
    end
    
    % extract DC component:
    dcc = Ac(1);
    
    fprintf('Generating flicker signal...\n');
        
    % generate relative time 2*pi*t:
    % note: include time-shift and timestamp delay and frequency error:              
    t = [];
    t(:,1) = ([0:N-1]/din.fs.v)*(1 + din.adc_freq.v)*2*pi;
    
    % generate main flicker signal: 
    %u = Ac(2)*sin(2*pi*fc*t).*(1 + (dVV/100)/2*sign(sin(2*pi*fm*t - (siglen - 10).*fm.*2.*pi)));
    u = Ac(2)*sin(fc*t).*(1 + (dVV/100)/2*sign(sin(fm*t + rand*2*pi)));

    fprintf('Generating spurrs...\n');        
    % synthesize spurrs:
    for k = 3:numel(fx)
        u = u + Ac(k)*sin(t*fx(k) + phc(k));
    end
    
    fprintf('Generating noise & errors...\n');
    
    % add some noise:
    u = u + randn(N,1)*adc_std_noise;
    
    % add DC offset:
    u = u + dcc;
    
    % add ADC offset:
    u = u + din.adc_offset.v + din.adc_offset.u*randn;
    
    % store to the QWTB input list:
    datain.y.v = u;
    
    
    % add fake uncertainties to allow uncertainty calculation:
    %  ###todo: to be removed when QWTB supports no uncertainty checking 
    alginf = qwtb('TWM-Flicker','info');
    qwtb('TWM-Flicker','addpath');    
    datain = qwtb_add_unc(datain,alginf.inputs);


    % --- execute the algorithm:
    dout = qwtb('TWM-Flicker',datain,calcset);
    
    if strcmpi(calcset.unc,'none')
        % generate fake uncertainty just to have some ditigs limit in the results print
        dout.Pst.u = 0.001;         
    end
       
    
    ref_list =  [pst_ref];    
    dut_list =  [dout.Pst.v];
    unc_list =  [dout.Pst.u];
    name_list = {'PST'};
            
    fprintf('\n------+-------------+----------------------------+-------------+----------+----------+-----------\n');
    fprintf('      |     REF     |        CALC +- UNC         |   ABS DEV   |  DEV [%%] |  UNC [%%] | %%-OF-SPEC\n');
    fprintf('------+-------------+----------------------------+-------------+----------+----------+-----------\n');
    for k = 1:numel(ref_list)
        
        ref = ref_list(k);
        dut = dut_list(k);
        unc = unc_list(k);
        name = name_list{k};
        
        dev = dut - ref;
        
        puc = 100*dev/unc;
        
        [ss,sv,su] = unc2str(dut,unc);
        [ss,dv] = unc2str(dev,unc);
        [ss,rv] = unc2str(ref,unc);
                
        fprintf(' %-4s | %11s | %11s +- %-11s | %11s | %+8.4f | %+8.4f | %+3.0f\n',name,rv,sv,su,dv,100*dev/ref,unc/dut*100,puc);
        
    end
    fprintf('------+-------------+----------------------------+-------------+----------+----------+-----------\n');
    
                                                   
    
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
   