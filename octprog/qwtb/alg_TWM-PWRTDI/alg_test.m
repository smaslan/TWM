function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-PWRTDI.
%
% See also qwtb

    
    % samples count to synthesize:
    %N = 7000;1e4;
    N = round(logrand(5000,20000));
    %N = 8520
    fprintf('N = %.0f samples\n',N);
        
    % sampling rate [Hz]
    din.fs.v = 10000;
    fprintf('fs = %0.4f Hz\n',din.fs.v);
    
    % ADC aperture [s]:
    din.adc_aper.v = 5e-6;
    
    % aperture correction state:
    din.u_adc_aper_corr.v = 1;
    din.u_lo_adc_aper_corr = din.u_adc_aper_corr;
    din.i_adc_aper_corr = din.u_adc_aper_corr;
    din.i_lo_adc_aper_corr = din.u_adc_aper_corr;
    
    % enable AC coupling:
    din.ac_coupling.v = 1;
    
    % ADC rms noise [s]:
    adc_std_noise = 1e-6;     
    
    % fundamental frequency [Hz]:
    %f0 = 61.3460;
    f0 = round(logrand(50.3,403.0)*1000)/1000;    
    fprintf('f0 = %0.4f Hz\n',f0);
    
    
    % fundamental periods in the record:
    f0_per = f0*N/din.fs.v;
    fprintf('f0 periods = %0.2f\n',f0_per);
        
    % samples per period of fundamental:
    fs_rat = din.fs.v/f0;
    fprintf('fs/f0 ratio = %0.2f\n',fs_rat);

    
    % corretions interpolation mode:
    %  note: must be the same as in the alg. itself!
    %        for frequency corrections the best is usually 'pchip'
    i_mode = 'pchip';
    
    % randomize corrections uncertainty:
    rand_unc = 1;
    
    % randomize SFDR:
    rand_sfdr = 1;
    
    
    chns = {}; id = 0;    
    
    % interharmonic ratio:
    %f_harm = 2.5;
    f_harm = logrand(1.3,2.9);
    
    % -- VOLTAGE:
    id = id + 1;
    % channel parameters:
    chns{id}.name = 'u';
    chns{id}.type = 'rvd';
    % harmonic amplitudes:
    %chns{id}.A  = 50*[1   0.01  0.001]';
    chns{id}.A  = logrand(5,50)*[1   logrand(0.01,0.1)  0.001]';
    % harmonic phases:
    %chns{id}.ph =    [0   -0.8  0.2]'*pi;
    chns{id}.ph =    [0   linrand(-0.8,0.8)  0.2]'*pi;
    % harmonic component index {1st, 2rd, ..., floor(0.4*fs/f0)}:
    chns{id}.fk =    [1   f_harm             round(0.4*din.fs.v/f0)]';
    % DC component:
    chns{id}.dc = 0.5;
    % differential mode: loop impedance:
    %chns{id}.Zx = 100;
     
    
    % -- CURRENT:
    id = id + 1;
    % channel parameters:
    chns{id}.name = 'i';
    chns{id}.type = 'shunt';
    % harmonic amplitudes:
    %chns{id}.A  = 0.3*[1     0.01 0.001]';
    chns{id}.A  = logrand(0.1,0.9)*[1    logrand(0.01,0.1)  0.001]';
    % harmonic phases:
    PF = round(linrand(0.1,1.0)*100)/100;
    %chns{id}.ph =     [1/3  +0.8  0.2]'*pi;
    chns{id}.ph =      [acos(PF)/pi  linrand(-0.8,0.8)  0.2]'*pi;
    % harmonic component index {1st, 2rd, ..., floor(0.4*fs/f0)}:
    chns{id}.fk =     [1    f_harm             round(0.4*din.fs.v/f0)]';
    % DC component:
    chns{id}.dc = 0.03;
    % differential mode: loop impedance:
    %chns{id}.Zx = 0.1;
        
    if true
        % -- voltage channel:
        din.u_tr_Zlo_f.v  = [];
        din.u_tr_Zlo_Rp.v = [200];
        din.u_tr_Zlo_Cp.v = [1e-12];        
        din.u_tr_Zlo_Rp.u = [0e-6];
        din.u_tr_Zlo_Cp.u = [0e-12];
        % create some corretion table for the digitizer gain/phase: 
        [din.u_adc_gain_f,din.u_adc_gain,din.u_adc_phi] \
          = gen_adc_tfer(din.fs.v/2+1,50, 1.05,0.000002, linrand(-0.05,+0.05),0.00005 ,linrand(0.5,3) ,0.2*din.fs.v,0.03,
                         linrand(-0.001,+0.001),0.00008,0.000002,linrand(0.7,3));
        din.u_adc_phi_f = din.u_adc_gain_f;         
        din.u_adc_gain_a.v = [];
        din.u_adc_phi_a.v = [];
%         din.u_adc_gain_f.v = [0;1e3;1e6];
%         din.u_adc_gain_a.v = [];        
%         din.u_adc_gain.v = [1.000000; 1.010000; 1.100000];
%         din.u_adc_gain.u = [0.000002; 0.000010; 0.000050]; 
%         din.u_adc_phi_f.v = [0;1e3;1e6];        
%         din.u_adc_phi_a.v = [];
%         din.u_adc_phi.v = [0.000000; 0.000100; 0.001000];
%         din.u_adc_phi.u = [0.000002; 0.000007; 0.000080];
        % digitizer SFDR value:
        din.u_adc_sfdr_a.v = [];
        din.u_adc_sfdr_f.v = [];
        din.u_adc_sfdr.v = [110];
        % create identical low-side channel:
        din.u_lo_adc_gain_f = din.u_adc_gain_f;
        din.u_lo_adc_gain_a = din.u_adc_gain_a;
        din.u_lo_adc_gain = din.u_adc_gain;
        din.u_lo_adc_gain.v = din.u_adc_gain.v*0.95;
        din.u_lo_adc_phi_f = din.u_adc_phi_f;
        din.u_lo_adc_phi_a = din.u_adc_phi_a;
        din.u_lo_adc_phi = din.u_adc_phi;
        din.u_lo_adc_phi.v(2:end) = din.u_lo_adc_phi.v(2:end) + 0.002; % change dig. tfer so u/i are not idnetical
        % digitizer SFDR value (low-side):
        din.u_lo_adc_sfdr_a.v = din.u_adc_sfdr_a.v;
        din.u_lo_adc_sfdr_f.v = din.u_adc_sfdr_f.v;
        din.u_lo_adc_sfdr.v = din.u_adc_sfdr.v;
        % create some corretion table for the transducer gain: 
        din.u_tr_gain_f.v = [0;1e3;1e6];
        din.u_tr_gain_a.v = [];
        din.u_tr_gain.v = [70.00000; 70.80000; 70.60000];
        din.u_tr_gain.u = [0.000005; 0.000007; 0.000050].*din.u_tr_gain.v; 
        % create some corretion table for the transducer phase: 
        din.u_tr_phi_f.v = [0;1e3;1e6];
        din.u_tr_phi_a.v = [];
        din.u_tr_phi.v = [0.000000; -0.000300; -0.003000];
        din.u_tr_phi.u = [0.000003;  0.000007;  0.000250];
        % transducer SFDR value:
        din.u_tr_sfdr_a.v = [];
        din.u_tr_sfdr_f.v = [];
        din.u_tr_sfdr.v = [100];
        % differential timeshift:
        din.u_time_shift_lo.v = +53e-6;
        din.u_time_shift_lo.u =  0.8e-6;
        
        
        % -- current channel:
        % create some corretion table for the digitizer gain/phase tfer: 
        [din.i_adc_gain_f,din.i_adc_gain,din.i_adc_phi] = gen_adc_tfer(din.fs.v/2+1,50, 0.95,0.000002, linrand(-0.05,+0.05),0.00005 ,linrand(0.5,3) ,0.2*din.fs.v,0.03,
                                                                       linrand(-0.001,+0.001),0.00008,0.000002,linrand(0.7,3));
        din.i_adc_phi_f = din.i_adc_gain_f;         
        din.i_adc_gain_a.v = [];
        din.i_adc_phi_a.v = [];        
%         din.i_adc_gain_f = din.u_adc_gain_f;
%         din.i_adc_gain_a = din.u_adc_gain_a;
%         din.i_adc_gain = din.u_adc_gain;
%         din.i_adc_gain.v = din.i_adc_gain.v*1.1; % change dig. tfer so u/i are not idnetical 
%         din.i_adc_phi_f = din.u_adc_phi_f;
%         din.i_adc_phi_a = din.u_adc_phi_a;
%         din.i_adc_phi = din.u_adc_phi;
%         din.i_adc_phi.v = din.i_adc_phi.v;
%         din.i_adc_phi.v(2:end) = din.i_adc_phi.v(2:end) + 0.005; % change dig. tfer so u/i are not idnetical
        % digitizer SFDR value:
        din.i_adc_sfdr_a.v = [];
        din.i_adc_sfdr_f.v = [];
        din.i_adc_sfdr.v = [110];
        % create some corretion table for the digitizer phase: 
        din.i_lo_adc_gain_f = din.i_adc_gain_f;
        din.i_lo_adc_gain_a = din.i_adc_gain_a;
        din.i_lo_adc_gain = din.i_adc_gain;
        din.i_lo_adc_gain.v = din.i_adc_gain.v*1.05;
        din.i_lo_adc_phi_f = din.i_adc_phi_f;
        din.i_lo_adc_phi_a = din.i_adc_phi_a;
        din.i_lo_adc_phi = din.i_adc_phi;
        din.i_lo_adc_phi.v(2:end) = din.i_lo_adc_phi.v(2:end) + 0.002; % change dig. tfer so u/i are not idnetical
        % digitizer SFDR value (low-side):
        din.i_lo_adc_sfdr_a.v = din.i_adc_sfdr_a.v;
        din.i_lo_adc_sfdr_f.v = din.i_adc_sfdr_f.v;
        din.i_lo_adc_sfdr.v = din.i_adc_sfdr.v;             
        
        % create some corretion table for the transducer gain: 
        din.i_tr_gain_f.v = [0;1e3;1e6];
        din.i_tr_gain_a.v = [];
        din.i_tr_gain.v = [0.500000; 0.510000; 0.520000];
        din.i_tr_gain.u = [0.000005; 0.000007; 0.000050].*din.i_tr_gain.v; 
        % create some corretion table for the transducer phase: 
        din.i_tr_phi_f.v = [0;1e3;1e6];
        din.i_tr_phi_a.v = [];
        din.i_tr_phi.v = [0.000000; -0.000400; -0.002000] + 0.0;
        din.i_tr_phi.u = [0.000003;  0.000006;  0.000200];
        % transducer SFDR value:
        din.i_tr_sfdr_a.v = [];
        din.i_tr_sfdr_f.v = [];
        din.i_tr_sfdr.v = [100];        
        % differential timeshift:
        din.i_time_shift_lo.v = -27e-6;
        din.i_time_shift_lo.u =  0.7e-6;
                
        % interchannel timeshift:
        din.time_shift.v =  33.30e-6;
        din.time_shift.u =   0.01e-6;
    
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
    
    
           
    
    % Restore orientations of the input vectors to originals (before passing via QWTB)
    din.u.v = ones(10,1); % fake data vector just to make following function work!
    din.i.v = ones(10,1); % fake data vector just to make following function work!
    if isfield(chns{1},'Zx')
        din.u_lo.v = din.u.v;   
    end
    if isfield(chns{2},'Zx')
        din.i_lo.v = din.i.v;   
    end
    din_alg = din; % backup input quantities to be send to the alg. itself
    [din,cfg] = qwtb_restore_twm_input_dims(din,1);    
    % Rebuild TWM style correction tables:
    tab = qwtb_restore_correction_tables(din,cfg);

    
    for c = 1:numel(chns)
    
        % get current channel:
        chn = chns{c};
        
        % differential mode?
        is_diff = isfield(chn,'Zx');
                
        % i-channel timeshift:
        if chn.name == 'i'
            tsh = din.time_shift.v + randn(1)*din.time_shift.u*rand_unc;           
        else
            tsh = 0;
        end              
        
        % channel prefix (eg.: 'u_'):
        cpfx = [chn.name '_'];
                                        
        % channel corrections:
        tab_list = {'tr_gain','tr_phi','tr_Zca','tr_Yca','tr_Zcal','tr_Zcam','adc_Yin','lo_adc_Yin','Zcb','Ycb','tr_Zlo','adc_gain','adc_phi','lo_adc_gain','lo_adc_phi','tr_sfdr','adc_sfdr','lo_adc_sfdr'};
        chtab = conv_vchn_tabs(tab,chn.name,tab_list);
    
        % calculate actual frequencies of the harmonics:
        fx = chn.fk*f0;
        
        % insert DC component
        fx = [eps;fx];
        chn.A = [chn.dc;chn.A];
        chn.ph = [pi/2;chn.ph];
                
        % rms level of the input signal:
        rms = sum(0.5*chn.A(2:end).^2)^0.5;
        
        % include DC:
        if ~din.ac_coupling.v
            rms = (rms^2 + chn.A(1)^2)^0.5;
        end                
        chns{c}.rms = rms;
        
        
        % spurr frequencies:
        f_sp = [];
        f_sp(:,1) = 2*fx(2):fx(2):floor(0.45*din.fs.v);
        
        % generate TR spurrs:
        tr_sfdr = correction_interp_table(chtab.tr_sfdr, rms, fx(2),'f',1, i_mode);
        A_spurr = chn.A(2)*10^(-tr_sfdr.sfdr/20)*rand(size(f_sp));
        
        % add the spurrs to the signal to generate:
        if rand_sfdr
            fx = [fx;f_sp];
            chn.Ag = [chn.A;A_spurr];
            chn.phg = [chn.ph;rand(size(f_sp))*2*pi];
        else
            chn.Ag = chn.A;
            chn.phg = chn.ph;
        end
                
        
        % --- apply transducer transfer:
        if rand_unc, rand_unc_str = 'rand'; else rand_unc_str = ''; end % randomize uncertainty option:
        A_syn = [];
        ph_syn = [];
        tsh_lo = [];
        sctab = {};
        sub_chn = {};        
        if is_diff
            % -- differential connection (create two subchannels: high and low-side):            
            [A_syn(:,1),ph_syn(:,1),A_syn(:,2),ph_syn(:,2)] = correction_transducer_sim(chtab,chn.type,fx,chn.Ag,chn.phg,0,0,rand_unc_str,chn.Zx);
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
            tsh_lo(2) = -tslo.v + randn(1)*tslo.u.*rand_unc; % low-side
            
            % subchannel waveform names:
            sub_chn{1} = chn.name; % high-side
            sub_chn{2} = [chn.name '_lo']; % low-side
        else
            % -- single-ended connection (create single channel):
            [A_syn,ph_syn] = correction_transducer_sim(chtab,chn.type,fx,chn.Ag,chn.phg,0,0,rand_unc_str);
            % prepare digitizer sunchannel correction tables:
            sctab{1}.adc_gain = chtab.adc_gain;
            sctab{1}.adc_phi  = chtab.adc_phi;
            sctab{1}.adc_sfdr  = chtab.adc_sfdr;
            % prepare subchannel timeshifts:
            tsh_lo(1) = 0;
            % subchannel waveform names:
            sub_chn{1} = chn.name;
        end
        
        % apply aperture error:
        ta = din.adc_aper.v;
        if abs(ta) > 1e-12
            ap_gain = sin(pi*ta*fx)./(pi*ta*fx);
            ap_phi  = -pi*ta*fx;            
            A_syn  = A_syn.*ap_gain;
            ph_syn = ph_syn + ap_phi;
        end
        
        
        % --- for each sub channel (low/high-side): 
        for k = 1:size(A_syn,2)
        
            % interpolate digitizer gain/phase to the measured frequencies and amplitudes:
            k_gain = correction_interp_table(sctab{k}.adc_gain, A_syn(:,k), fx,'f',1, i_mode);   
            k_phi =  correction_interp_table(sctab{k}.adc_phi,  A_syn(:,k), fx,'f',1, i_mode);
            
            % apply digitizer gain:
            Ac  = A_syn(:,k)./(k_gain.gain + randn(size(A_syn(:,k))).*k_gain.u_gain*rand_unc);
            phc = ph_syn(:,k) - k_phi.phi + randn(size(ph_syn(:,k))).*k_phi.u_phi*rand_unc;
            
            % get ADC sfdr value:
            sfdr = correction_interp_table(sctab{k}.adc_sfdr, A_syn(1,k), fx(1),'f',1, i_mode);
            
            if rand_sfdr
                % ADC spurrs:
                adc_spurr = A_syn(2,k)*10^(-sfdr.sfdr/20)*rand(size(f_sp));
                
                % add spurrs to the signal to generate:
                Ac((numel(chn.A)+1):end) = Ac((numel(chn.A)+1):end) + adc_spurr;
                
            end
            
            
            % frquency with zeroed DC component frequency:
            fx_temp = fx;
            fx_temp(1) = 0;                                               
                         
            % generate time vector 2*pi*t:
            % note: including time shift!
            t = [];
            t(:,1) = ([0:N-1]/din.fs.v + tsh + tsh_lo(k))*2*pi;
            
            % synthesize waveform (crippled for Matlab < 2016b):
            % u = Av.*sin(t.*fx_temp + phc);
            u = bsxfun(@times, Ac', sin(bsxfun(@plus, bsxfun(@times, t, fx_temp'), phc')));
            % sum the harmonic components to a single composite signal:
            u = sum(u,2);
            
            % add some noise:
            u = u + randn(size(u))*adc_std_noise;
            
            %figure;
            %plot(u)
            
            % store to the QWTB input list:
            din_alg = setfield(din_alg, sub_chn{k}, struct('v',u));

        end
    
    end    

    % add fake uncertainties to allow uncertainty calculation:
    %  ###todo: to be removed when QWTB supports no uncertainty checking 
    alginf = qwtb('TWM-PWRTDI','info');
    qwtb('TWM-PWRTDI','addpath');    
    din_alg = qwtb_add_unc(din_alg,alginf.inputs);

    % --- execute the algorithm:
    calcset.unc = 'none';
    dout = qwtb('TWM-PWRTDI',din_alg,calcset);
    
    % calculate reference values:
    U_ref  = chns{1}.rms;
    I_ref  = chns{2}.rms;
    S_ref  = chns{1}.rms.*chns{2}.rms;
    P_ref  = 0.5*sum(chns{1}.A.*chns{2}.A.*cos(chns{2}.ph - chns{1}.ph));
    if ~din.ac_coupling.v
        P_ref  = P_ref + (chns{1}.dc*chns{2}.dc);
    end    
    Q_ref  = (S_ref^2 - P_ref.^2)^0.5;
    PF_ref = P_ref/S_ref;
        
    
    ref_list =  [U_ref,    I_ref,    S_ref,    P_ref,    Q_ref,    PF_ref];    
    dut_list =  [dout.U.v, dout.I.v, dout.S.v, dout.P.v, dout.Q.v, dout.PF.v];
    unc_list =  [dout.U.u, dout.I.u, dout.S.u, dout.P.u, dout.Q.u, dout.PF.u]*2;
    name_list = {'U','I','S','P','Q','PF'};
        
    
    fprintf('\n---+-------------+----------------------------+-------------+----------+----------+----------\n');
    fprintf('   |     REF     |        CALC +- UNC         |   ABS DEV   |  %%-DEV   |  %%-UNC   |  %%-UNC\n');
    fprintf('---+-------------+----------------------------+-------------+----------+----------+----------\n');
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
        %sn = ['[' un_list{k} ']'];
        
        fprintf('%-2s | %11s | %11s +- %-11s | %11s | %+8.4f | %+8.4f | %+3.0f\n',name,rv,sv,su,dv,100*dev/ref,unc/dut*100,puc);
        
    end
    fprintf('---+-------------+----------------------------+-------------+----------+----------+----------\n');
      
    
    
    
    % --- compare calcualted results with desired:
%     if any(abs([dout.amp.v(1+fk)] - A(:))./A(:) > 1e-6)
%         error('TWM-TEST testing: calculated amplitudes do not match!');
%     end
%     if any(abs([dout.phi.v(1+fk)] - ph(:)) > 10e-6)                                    
%         error('TWM-TEST testing: calculated phases do not match!');          
%     end
%     if abs(dout.rms.v - rms)/rms > 1e-7
%         error('TWM-TEST testing: calculated rms value does not match!');
%     end
                                                                         
    
end

function [rnd] = logrand(A_min,A_max,N)
    if nargin < 3
        N = [1 1];
    end
    rnd = 10.^(log10(A_min) + (log10(A_max) - log10(A_min))*rand(N));
end

function [rnd] = linrand(A_min,A_max,N)
    if nargin < 3
        N = [1 1];
    end
    rnd = rand(N)*(A_max - A_min) + A_min;
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
   