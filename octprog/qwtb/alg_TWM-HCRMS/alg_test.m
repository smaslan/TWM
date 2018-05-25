function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-HCRMS.
%
% See also qwtb

    % total simulation time [s]:
    sim_time = 6; 
    
    % sampling rate [Hz]:
    %  note: at least 100x fundamental component
    din.fs.v = 10000;
    fs = din.fs.v;
    
    % samples count to synthesize:
    N = ceil(sim_time*fs);
    
    % differential mode?
    %  ###note: not implemented (yet)!!! Simulator can generate it, but alg. cannot use it!
    is_diff = 0;
        
    % randomize correction uncertainties:         
    rand_unc = 0;
    
    
    % event duration [s]:
    ev_time = 0.050;
    % event start time [s]:    
    ev_start = 0.8;
    % event magnitude [%]:
    %  relative to nominal:
    ev_mag = 50;
    % fine-tune event size using sliding window
    %  note: non-zero means the simulator will try to fiddle the event parameters so the
    %        generate event accoridng sliding window method is exactly the set values
    %        otherwise it will just generate 'ev_time' long rectangular amp. modulation 
    ev_tune = 1;

    % nominal frequency:
    f0 = 50.3;
    % nominal frequency drift [Hz/s]:
    f0_drift = 0.0;
    
    % sfdr of harmonics [-]:
    h_sfdr = 0.05;
    % randomize spurr frequencies by +-[f0]:
    h_sfdr_frnd = 0.0;
    % limit harmonics count:
    h_lim = 10;
            
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
    
    % detector hysteresis:
    din.hyst.v = 2;
    
    % plot events?
    din.plot.v = 1;
    
    % event detector setup:
    din.hyst.v = 2;
    din.sag_tres.v = 90;
    din.swell_tres.v = 110;
    din.int_tres.v = 10;

    
    
    
        
            
    % dc offset:
    dc = 0.0;
               
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
    din.adc_freq.u = 10e-9;
    
    
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
    % create corretion of the digitizer timebase:
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
    u = A0*sin(ctw + ph0);
        
        
    % --- parameter finetunnig:
    fprintf('Calculating signal parameters for simulation...\n');    
    
    if ev_tune    
        step = 'm';
    else
        step = 'r'; % no fine tunning
    end
    ev_start_i = ev_start;
    ev_time_i = ev_time;
    ev_mag_i = ev_mag;
    it = 0;
    while true
        
        % event time:
        env = ones(size(t));    
        ev_msk = (t >= ev_start_i) & t <= (ev_start_i + ev_time_i);
        % event magnitude:
        env(ev_msk) = 0.01*ev_mag_i;
        % apply event envelope to signal:
        ux = u.*env;
        
        % desired samples per period:
        SP = 120;
        
        % total samples of resampled signal:
        NX = round(N*SP/(fs/f0));
        
        % get frequency modulation envelope interpolated to new samples count:
        fsx = NX/t(end);
        tx = [];
        tx(:,1) = [0:NX-1]/fsx;
        f0dx = interp1(t,f0d,tx,'linear','extrap');
            
        % generate sampling time increments to compensate frequency modulaion:        
        Tsd = 1./(f0dx*fs*SP/(fs/f0));      
        
        % generete resampling time vector:
        tx = cumsum([0;Tsd(1:end-1)]);
        tx = tx(tx < t(end));
        
        % interpolate to coherent signal:
        ux = interp1(t,ux,tx,'spline','extrap');
        SN = floor(NX/SP)*SP;    
        ux = ux(1:SN);
        
        % debug plot to show all periods are indeed coherent:
    %     ux = reshape(ux,[SP NX/SP]);    
    %     plot(ux(:,1:10:end))        
        
        % windows per period:
        SW = 40;
    
        % duplicate data so we can calculate all sliding windows per period at once:
        %  ux = [u(1) u(2) u(3) ... u(SW)  ]
        %       [u(2) u(3) u(4) ... u(SW+1)]
        %       [...  ...  ...  ... ...    ]
        SS = SP/SW;    
        ux = repmat(ux,[1 SW]);
        ux = ux(:);
        ux = [ux;zeros(SW*SS,1)];    
        ux = reshape(ux,[SN+SS SW]);    
        SN = floor((SN-SP)/SP)*SP;
        ux = ux(1:SN,:);
        % reshape so we have all windows in dim=2 and data for each window in dim=1:
        ux = reshape(ux,[SP SN/SP*SW]);
        % calculate rms for each window:    
        ux = ux.^2;    
        rms = mean(ux,1).^0.5;
        % restore to linear oder:
        rms = reshape(rms,[SN/SP SW])';
        rms = rms(:);
        R = numel(rms);    
        t_rms = tx(SS*[0:R-1]' + SP/2);
        
        %plot(t_rms,rms)
            
        if ev_mag < din.sag_tres.v
            % sag is reference:
            limits = [din.sag_tres.v din.sag_tres.v+din.hyst.v]*0.01*nom_rms;            
        elseif ev_mag > din.swell_tres.v
            % swell is reference:
            limits = [din.swell_tres.v din.swell_tres.v-din.hyst.v]*0.01*nom_rms;
        else
            % no event possible - do not allow fine tunning
            found = 0;
            break;
        end
        
        % detect event:
        [t_start,t_dur,rms_xtr,found] = env_event_detect(t_rms,rms,[],limits,1);        
        resid = 100*rms_xtr/nom_rms;
        
        if step == 'r'
            break;
        end
        if ~found            
            disp(' - failed, restoring initial setting!');
            
            % failed - reset
            ev_start_i = ev_start;
            ev_time_i = ev_time;
            ev_mag_i = ev_mag;            
            step = 'r';
            it = 0;
                                
        else                   
            % update coeficients:
            if step == 'm'        
                ev_mag_i = ev_mag_i + (ev_mag - resid);
                %ev_start_i = ev_start_i + (ev_start - t_start);
            else
                ev_time_i = ev_time_i + (ev_time - t_dur);
            end
        end
        
        it = it + 1;
        if it >= 4
            it = 0;
            if step == 'm'
                step = 'p';
            else
                break;
            end
        end        
    end
    
    if found
        ev_start = ev_start_i;
        ev_time = ev_time_i;
    end
    
    % calculate reference event values:
    ev = {};
    ev{1}.limits = [din.sag_tres.v din.sag_tres.v+din.hyst.v]*0.01*nom_rms;
    ev{1}.name = 'sag';
    ev{2}.limits = [din.swell_tres.v din.swell_tres.v-din.hyst.v]*0.01*nom_rms;
    ev{2}.name = 'swell';
    ev{3}.limits = [din.int_tres.v din.int_tres.v+din.hyst.v]*0.01*nom_rms;
    ev{3}.name = 'int';    
    ref = struct();
    for k = 1:numel(ev)
        [t_start,t_dur,rms_xtr,found] = env_event_detect(t_rms,rms,[],ev{k}.limits,1);
        resid = 100*rms_xtr/nom_rms;        
        ref = setfield(ref, ev{k}.name, struct('found',found, 'start',t_start, 'dur',t_dur, 'res',resid));        
    end
    
    
    
    
    % generate higher harmonics:
    f_sp(:,1) = [(2*f0):f0:0.45*fs];
    f_sp = f_sp(1:min(h_lim,numel(f_sp)));
    % randomize harmonics frequencies:
    f_sp = f_sp + (2*rand(size(f_sp))-1)*h_sfdr_frnd*f0;
    
    % generate spurrs:
    A_sp = A0*h_sfdr*rand(size(f_sp));
    ph_sp = rand(size(f_sp))*2*pi;
    
    % build full harmonics list:
    fx = [f0;f_sp];
    A =  [A0;A_sp];
    ph = [ph0;ph_sp];
    
    % actual rms of generated signal:
    rms_x = sum(0.5*A.^2)^0.5;
    
    % fix amplitudes so the actual rms level matches nominal one:
    A = A*nom_rms/rms_x;
        
    % add virtual harmonic with DC component:
    %  ###todo: this should maybe be placed before rms level correction but need to decide if DC is part of the sag/swell rms values???
    fx = [fx;1e-12];
    A  = [A;dc];
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
        % ADC offset:
        adc_ofs(1) = din.adc_offset;
    end
            
    % get ADC aperture value [s]:
    ta = abs(din.adc_aper.v);

    % calculate aperture gain/phase correction:
    ap_gain = sin(pi*ta*fx)./(pi*ta*fx);
    ap_phi  = -pi*ta*fx;
    
    
    % --- signal parameters fine tuning iteration loop:
  
    % for each transducer subchannel:
    for c = 1:numel(sctab)

        % interpolate digitizer gain/phase to the measured frequencies and amplitudes:
        k_gain = correction_interp_table(sctab{c}.adc_gain,A_syn(:,c),fx,'f',1);    
        k_phi =  correction_interp_table(sctab{c}.adc_phi, A_syn(:,c),fx,'f',1);
        
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
              
        
                
        % relative shift of event due to fundamental component phase shift:
        %  ###todo: check if this is correct, does the modulation shift with phase of carrier or not?
        dpt = (mod(ph0c - ph0 + pi,2*pi) - pi)/2/pi/f0c;
                
        % asign event samples: 
        t = t/2/pi;
        ev_msk = (t >= (ev_start + dpt)) & t <= ((ev_start + dpt) + ev_time);
        
        % generate event envelope:
        env = ones(size(t));
        env(ev_msk) = env(ev_msk)*ev_mag*0.01;
        
        % apply envelope:
        u = u.*env;   
        
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
    calcset = struct();
    calcset.dbg_plots = 0;
    calcset.unc = 'none';
    dout = qwtb('TWM-HCRMS',datain,calcset);
    
    
    
    events = {'Sag','Swell','Interuption'};
    
    names  = {'start','duration','residual'}; 
    
    dut = [dout.sag_start dout.swell_start dout.int_start;
           dout.sag_dur   dout.swell_dur   dout.int_dur;
           dout.sag_res   dout.swell_res   dout.int_res];
               
    ref = [ref.sag.start ref.swell.start ref.int.start;
           ref.sag.dur ref.swell.dur ref.int.dur;
           ref.sag.res ref.swell.res ref.int.res];
    
    
    fprintf('\n');
    for e = 1:numel(events)
    
        fprintf(' %s:\n',events{e});
        fprintf('----------+----------+--------------------+---------+---------\n');
        fprintf('  EVENT   |   REF    |     DUT +- UNC     |   DEV   | %%-UNC\n');
        fprintf('----------+----------+--------------------+---------+---------\n');
        for k = 1:numel(names)
    
            %[ss,sv,su] = unc2str(dut(),unc);
            %[ss,dv] = unc2str(dev,unc);
            
            if ~isnan(ref(k,e)) && isnan(dut(2,e).v)
                [ss,rv] = unc2str(ref(k,e),0.001);
            elseif ~isnan(ref(k,e))
                [ss,rv] = unc2str(ref(k,e),dut(k,e).u);
            else
                rv = 'NaN';
            end            
            
            dev = dut(k,e).v - ref(k,e);
            
            if ~isnan(dut(2,e).v)
                [ss,dv,du] = unc2str(dut(k,e).v,dut(k,e).u);                 
            else
                dv = 'NaN';
                du = 'NaN';
            end
            
            if ~isnan(dev)
                [ss,ev] = unc2str(dev,dut(k,e).u);
                pp = abs(dev/dut(k,e).u)*100;                
            else
                pp = inf; 
                ev = 'NaN';
            end
                     
            fprintf(' %-8s | %8s | %7s +- %-7s | %7s | %+4.0f\n',names{k},rv,dv,du,ev,pp);                
        end        
        fprintf('----------+----------+--------------------+---------+---------\n\n');
        
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
   