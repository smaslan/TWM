function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-HCRMS.
%
% See also qwtb

    
    % calculation setup:
    calcset.verbose = 1;
    calcset.unc = 'guf';
    calcset.loc = 0.95;
    calcset.dbg_plots = 0;
    % no QWTB input checking:
    calcset.checkinputs = 0;
    
    
    % total simulation time [s]:
    sim_time = 6; 
    
    % sampling rate [Hz]:
    %  note: at least 100x fundamental component
    din.fs.v = 10000;
    fs = din.fs.v;
    
    % samples count to synthesize:
    N = ceil(sim_time*fs);
    
    % differential mode?
    %  ###note: not implemented (at least not yet)!!! Simulator can generate it, but alg. cannot use it!
    is_diff = 0;
        
    % randomize correction uncertainties:         
    rand_unc = 0;


    % nominal frequency:
    f0 = 50.3;
    % nominal frequency drift [Hz/s]:
    f0_drift = 0;linrand(-0.01,0.01);
    
    % sfdr of harmonics [-]:
    h_sfdr = 0.1;    
    % limit harmonics count:
    h_lim = 10;
    
    % sfdr of inter-harmonics [-]:
    ih_sfdr = 0.001;
    % relative interharm. freq positions, e.g. 2.5 means between 2nd and 3rd harmonic:     
    ih_freqs = [1.8];
     
            
    % rms level to generate:
    nom_rms = 230.0;
    % nominal level for the algorithm:
    %  note: this is not necessarilly the same as nom_rms! 
    din.nom_rms.v = nom_rms;
    
    % nominal frequency:
    %  note: comment to enable auto detect
    %din.nom_f.v = f0;
    
    % calculation mode:
    din.mode.v = 'S';   
            
    % dc offset:
    dc = linrand(-5,5);
               
    % ADC rms noise level:
    adc_std_noise = 10e-6;
    
         
    
    % ADC aperture [s]:
    % note: non-zero value will simulate aperture gain/phase error 
    din.adc_aper.v = 2e-6;
    
    % ADC aperture correction enabled:
    % note: non-zero value will enable correction of the gain/phase error by alg.
    din.adc_aper_corr.v = 1;
    din.lo_adc_aper_corr.v = din.adc_aper_corr.v; % ###note: not used
    
    % timebase frequency correction: 
    din.adc_freq.v = 1e-6;
    din.adc_freq.u = 100e-9;
    
    
    % generate some time-stamp of the digitizer channel:
    % note: the algorithm must 'unroll' the calculated phase accordingly,
    %       so whatever is put here should have no effect to the estimated phase         
    din.time_stamp.v = rand(1)*0.2; % random time-stamp
    
    % timestamp compensation:
    %din.comp_timestamp.v = 1;
        
    % create some corretion table for the digitizer gain: 
    din.adc_gain_f.v = [0;1e3;1e6];
    din.adc_gain_a.v = [];
    din.adc_gain.v = [1.000; 1.100; 1.500];
    din.adc_gain.u = [0.001; 0.002; 0.003]*0.01; 
    % create some corretion table for the digitizer phase: 
    din.adc_phi_f.v = [0;1e3;1e6];
    din.adc_phi_a.v = [];
    din.adc_phi.v = [0.500; 0.100; 0.500]*pi;
    din.adc_phi.u = [0.001; 0.002; 0.005]*pi*0.01;
    % digitizer input admittance:
    din.adc_Yin_f.v = [];         
    din.adc_Yin_Cp.v = logrand(50e-12,500e-12);
    din.adc_Yin_Cp.u = 0;
    din.adc_Yin_Gp.v = logrand(1e-9,1e-6);
    din.adc_Yin_Gp.u = 0;   
    % create some low-side corretion table for the digitizer gain: 
    din.lo_adc_gain_f = din.adc_gain_f; % ###note: not used
    din.lo_adc_gain_a = din.adc_gain_a; % ###note: not used
    din.lo_adc_gain = din.adc_gain; % ###note: not used
    din.lo_adc_gain.v = din.lo_adc_gain.v*1.5; % ###note: not used 
    % create some low-side corretion table for the digitizer phase: 
    din.lo_adc_phi_f = din.adc_phi_f; % ###note: not used
    din.lo_adc_phi_a = din.adc_phi_a; % ###note: not used
    din.lo_adc_phi = din.adc_phi; % ###note: not used
    din.lo_adc_phi.v = din.lo_adc_phi.v - 0.001*pi; % ###note: not used
    % create corretion of the digitizer offset:
    din.adc_offset.v = 0.001;
    din.adc_offset.u = 0.000005;
    din.lo_adc_offset.v = -0.002; % ###note: not used
    din.lo_adc_offset.u = 0.000005; % ###note: not used
    
    % define some low-side channel timeshift:
    din.time_shift_lo.v = -1.234e-4; % ###note: not used
    din.time_shift_lo.u = 1e-6; % ###note: not used
    
    
    % transducer type ('rvd' or 'shunt')
    din.tr_type.v = 'rvd';
        
    % create some corretion table for the transducer gain: 
    din.tr_gain_f.v = [0;1e3;1e6];
    din.tr_gain_a.v = [];
    din.tr_gain.v = [1.000; 0.900; 0.800]*400;
    din.tr_gain.u = [0.001; 0.002; 0.005]*0.01; 
    % create some corretion table for the transducer phase: 
    din.tr_phi_f.v = [0;1e3;1e6];
    din.tr_phi_a.v = [];
    din.tr_phi.v = [0.000; -0.0200; -0.0500]*pi*0;
    din.tr_phi.u = [0.001;  0.0002;  0.0005]*pi*0.1;
        
    % RVD low-side impedance:
    din.tr_Zlo_f.v = [];
    din.tr_Zlo_Rp.v = [200.00];
    din.tr_Zlo_Rp.u = [  0.05];
    din.tr_Zlo_Cp.v = [1e-12];
    din.tr_Zlo_Cp.u = [1e-12];
    
    % transducer buffer output impedance            
    if rand() > 0.5
        din.tr_Zbuf_f.v = [];
        din.tr_Zbuf_Rs.v = 100*logrand(10.0,1000.0);
        din.tr_Zbuf_Rs.u = 1e-9;
        din.tr_Zbuf_Ls.v = logrand(1e-9,1e-6);
        din.tr_Zbuf_Ls.u = 1e-12;
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
        
    
    % remember original input quantities:
    datain = din; 
    % Restore orientations of the input vectors to originals (before passing via QWTB)
    din.y.v = ones(10,1); % fake data vector just to make following function work!
    if is_diff, din.y_lo.v = din.y.v; end
    [din,cfg] = qwtb_restore_twm_input_dims(din,1);
    % Rebuild TWM style correction tables (just for more convenient calculations):
    tab = qwtb_restore_correction_tables(din,cfg);
    
    
    % initial estimate of nominal rms level:
    A0 = nom_rms*2^0.5;
    % fundamental signal phase angle [rad]:
    ph0 = rand*2*pi;
    
    % time vector:
    t  = [];
    t(:,1) = [0:N-1]/fs;    
    
    % relative change of fundamental component in time:
    f0d = polyval([f0_drift f0],t)/f0;
    
    % generate phase increments according to the modulation curve:
    ctw = [0;2*pi/fs*f0d(1:end-1)*f0];
    ctw = cumsum(ctw);
    
    % generate fundamental component:
    A0g = (0.5*A0^2 - dc^2)^0.5*2^0.5;
    u = A0g*sin(ctw + ph0);
        
    % generate higher harmonics:
    f_sp(:,1) = [(2*f0):f0:0.45*fs];
    f_sp = f_sp(1:min(h_lim,numel(f_sp)));
    
    % - generate interharmonics:
    % possible harmonics:
    f_spi(:,1) = ih_freqs(:)*f0;        
        
    % generate spurrs from the harmonics and interharm.:
    A_sp = A0*h_sfdr*rand(size(f_sp));
    ph_sp = rand(size(f_sp))*2*pi;
    A_spi = A0*ih_sfdr;%*rand(size(f_spi)); % generate full amplitude always!
    ph_spi = rand(size(f_spi))*2*pi;
    
    % build full harmonics list:
    fx = [f0;f_sp;f_spi];
    A =  [A0;A_sp;A_spi];
    ph = [ph0;ph_sp;ph_spi];
    
    % add virtual harmonic with DC component:
    %  ###todo: this should maybe be placed before rms level correction but need to decide if DC is part of the sag/swell rms values???
    fx = [fx;1e-12];
    A  = [A;dc];
    ph = [ph;0];
    
    % actual rms of generated signal:
    rms_x = sum(0.5*A(1:end-1).^2)^0.5;
    
    % fix amplitudes so the actual rms level matches nominal one:
    A(1:end-1) = A(1:end-1)*(nom_rms^2 - dc^2)^0.5/rms_x;
        
                    
    
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
        % ###todo: fix DC polarity problem when alg. should be used in the diff mode
        % subchannel correction tables:
        sctab{1}.adc_gain = tab.adc_gain;
        sctab{1}.adc_phi  = tab.adc_phi;
        sctab{2}.adc_gain = tab.lo_adc_gain;
        sctab{2}.adc_phi  = tab.lo_adc_phi;
        % subchannel timeshift:
        tsh(1) = 0; % high-side channel
        tsh(2) = din.time_shift_lo.v; % low-side channel
        % ADC offset:
        adc_ofs(1) = din.adc_offset;
        adc_ofs(2) = din.lo_adc_offset;
    else
        % -- single-ended connection:
        [A_syn(:,1),ph_syn(:,1)] = correction_transducer_sim(tab,din.tr_type.v,fx, abs(A),ph,0*A,0*ph,rand_str);
        A_syn(end) = A_syn(end)*sign(A(end)); % restore DC polarity        
        % subchannel correction tables:
        sctab{1}.adc_gain = tab.adc_gain;
        sctab{1}.adc_phi  = tab.adc_phi;
        % subchannel timeshift:
        tsh(1) = 0; % none for single-ended mode
        % ADC offset:
        adc_ofs(1) = din.adc_offset;
        
    end
            
    % get ADC aperture value [s]:
    ta = abs(din.adc_aper.v);

    % calculate aperture gain/phase correction:
    ap_gain = sin(pi*ta*fx)./(pi*ta*fx);
    ap_phi  = -pi*ta*fx;
    ap_gain(end) = 1; % DC
    
    
    % --- signal parameters fine tuning iteration loop:
  
    % for each transducer subchannel:
    for c = 1:numel(sctab)

        % interpolate digitizer gain/phase to the measured frequencies and amplitudes:
        k_gain = correction_interp_table(sctab{c}.adc_gain,abs(A_syn(:,c)),fx,'f',1);    
        k_phi =  correction_interp_table(sctab{c}.adc_phi, abs(A_syn(:,c)),fx,'f',1);
                
        % apply digitizer gain:
        Ac  = A_syn(:,c)./k_gain.gain;
        phc = ph_syn(:,c) - k_phi.phi;
        
        % apply aperture error:
        if ta > 1e-12
            Ac = Ac.*ap_gain;
            phc = phc + ap_phi;
        end
        
        % randomize ADC tfer:
        if rand_unc
            Ac  = Ac.*(1 + k_gain.u_gain.*randn(size(Ac)));
            phc = phc + k_phi.u_phi.*randn(size(phc));
        end
                
        % extract dc offset:
        dcc = Ac(end);
        
        % extract fundamental:
        f0c = fx(1);
        A0c = Ac(1);
        ph0c = phc(1);
                
        % remove DC component and fundamental from spectrum:
        fxt = fx(2:end-1);
        Ac  = Ac(2:end-1);
        phc = phc(2:end-1);
                
        % generate frequency drift:
        %fdt = [];
        %fdt(:,1) = [0:N-1]/din.fs.v*f0_drift;
        
        % generate relative time 2*pi*t:
        % note: include time-shift and timestamp delay and frequency error:        
        tstmp = din.time_stamp.v;       
        t = [];
        t(:,1) = ([0:N-1]/din.fs.v + tsh(c) + tstmp)*(1 + din.adc_freq.v)*2*pi;
        
        % effective sampling period:
        Tsef = 1/din.fs.v*(1 + din.adc_freq.v);
        
        fprintf('Synthesizing waveform ...\n');
        
        
        % generate phase increments according to the modulation curve:
        ctw = [0;2*pi*Tsef*f0d(1:end-1)*f0c];
        ctw = cumsum(ctw);        
        % generate fundamental component:
        u = A0c*sin(ctw + ph0c);
                       
                
        % synthesize harmonics per blocks (memory saving):
        hblk = 5; % block size (how many harmonics to generate in single cycle)
        a = 1; % initial harmonic
        while true
            % end harmonic of the block:
            b = min(a+hblk-1,numel(fxt));
        
            % synthesize waveform (crippled for Matlab < 2016b):
            % u = sum(Ac.*sin(t.*fxd + phc),2);
            u = u + sum(bsxfun(@times, Ac(a:b)', sin(bsxfun(@plus, bsxfun(@times, t, fxt(a:b)'), phc(a:b)'))),2);
            
            % update initial harmonic:
            a = a + hblk;            
            if a > numel(fxt)
                break;
            end        
        end 
        
        % add some noise:
        u = u + randn(N,1)*adc_std_noise;
        
        % add DC offset:
        u = u + dcc;
        
        % add ADC offset:
        u = u + adc_ofs(c).v + adc_ofs(c).u*randn;
                
        %figure
        %plot(t,u)
        
        % store to the QWTB input list:
        datain = setfield(datain, cfg.ysub{c}, struct('v',u));
    
    end

        
    % add fake uncertainties to allow uncertainty calculation:
    %  ###todo: to be removed when QWTB supports no uncertainty checking 
    alginf = qwtb('TWM-HCRMS','info');
    qwtb('TWM-HCRMS','addpath');    
    datain = qwtb_add_unc(datain,alginf.inputs);
        

    % --- execute the algorithm:    
    dout = qwtb('TWM-HCRMS',datain,calcset);
    
%     figure
%     plot(dout.t.v,dout.rms.v)
%     hold on;
%     plot(dout.t.v,dout.rms.v + dout.rms.u,'r')
%     plot(dout.t.v,dout.rms.v - dout.rms.u,'r')
%     hold off;
       
    
    
    x_t0.v = dout.t.v(1);
    x_t0.u = mean(dout.t.u);
    x_t0.d = NaN;
    x_t0.p = NaN;
    
    x_rms_av.v = mean(dout.rms.v);
    x_rms_av.u = max(dout.rms.u);
    x_rms_av.d = max(abs(dout.rms.v - nom_rms));
    x_rms_av.p = 100*max(abs(dout.rms.v - nom_rms)./dout.rms.u);
    
    x_rms_mx = x_rms_av;
    [x_rms_mx.v,id] = max(dout.rms.v);
    x_rms_mx.u = dout.rms.u(id);
    x_rms_mx.d = abs(dout.rms.v(id) - nom_rms);
    x_rms_mx.p = 100*x_rms_mx.d./dout.rms.u(id);
    
    x_rms_mn = x_rms_av;
    [x_rms_mn.v,id] = min(dout.rms.v);
    x_rms_mn.u = dout.rms.u(id);
    x_rms_mn.d = abs(dout.rms.v(id) - nom_rms);    
    x_rms_mn.p = 100*x_rms_mn.d./dout.rms.u(id);
    
    % generate some min. uncertainty when none calculated just for display:
    if strcmpi(calcset.unc,'none')
        x_t0.u = 1e-6;
        x_rms_av.u = 0.001;
        x_rms_mx.u = 0.001;
        x_rms_mn.u = 0.001;
    end
    
    names  = {'time','mean rms','max rms','min rms'};
        
    dut = [x_t0;x_rms_av;x_rms_mx;x_rms_mn];
               
    ref = [0;nom_rms;nom_rms;nom_rms];
        
    has_unc = ~strcmpi(calcset.unc,'none');
    
    fprintf('\n');
    fprintf('----------+-----------+-------------------------+---------+---------\n');
    fprintf('  EVENT   |   REF     |       DUT +- UNC        |   DEV   | %%-UNC\n');
    fprintf('----------+-----------+-------------------------+---------+---------\n');
    for k = 1:numel(names)

        if ~isnan(ref(k)) && isnan(dut(2).v)
            [ss,rv] = unc2str(ref(k),0.001);
        elseif ~isnan(ref(k))
            [ss,rv] = unc2str(ref(k),dut(k).u);
        else
            rv = 'NaN';
        end            
        
        dev = dut(k).d;
        
        if ~isnan(dut(2).v)
            [ss,dv,du] = unc2str(dut(k).v,dut(k).u);                 
        else
            dv = 'NaN';
            du = 'NaN';
        end
        
        if ~isnan(dev) && has_unc
            [ss,ev] = unc2str(dev,dut(k).u);
            pp = dut(k).p;                
        else
            pp = inf; 
            ev = 'NaN';
        end
                 
        fprintf(' %-8s | %9s | %10s +- %-9s | %7s | %4.0f\n',names{k},rv,dv,du,ev,pp);                
    end        
    fprintf('----------+-----------+-------------------------+---------+---------\n\n');
   
    
end

function [rnd] = linrand(A_min,A_max,N)
    if nargin < 3
        N = [1 1];
    end
    rnd = rand(N)*(A_max - A_min) + A_min;
end

function [rnd] = logrand(A_min,A_max,sz)
    if nargin < 3
        sz = [1 1];
    end
    rnd = 10.^(log10(A_min) + (log10(A_max) - log10(A_min))*rand(sz));
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
   