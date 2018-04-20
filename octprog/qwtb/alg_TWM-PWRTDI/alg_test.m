function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-PWRTDI.
%
% See also qwtb

    % samples count to synthesize:
    N = 1e5;
    
    % sampling rate [Hz]
    din.fs.v = 100000;
    
    % ADC aperture [s]:
    din.adc_aper.v = 10e-6;
    
    % aperture correction state:
    din.u_adc_aper_corr.v = 1;
    din.u_lo_adc_aper_corr = din.u_adc_aper_corr;
    din.i_adc_aper_corr = din.u_adc_aper_corr;
    din.i_lo_adc_aper_corr = din.u_adc_aper_corr;
    
    % ADC rms noise [s]:
    adc_std_noise = 1e-6;     
    
    % fundamental frequency [Hz]:
    f0 = 50.3;
    
    % corretions interpolation mode:
    %  note: must be the same as in the alg. itself!
    %        for frequency corrections the best is usually 'pchip'
    i_mode = 'pchip';
    
    % randomize corrections uncertainty:
    rand_unc = 0;
    
    
    chns = {}; id = 0;    
    
    % -- VOLTAGE:
    id = id + 1;
    % channel parameters:
    chns{id}.name = 'u';
    chns{id}.type = 'rvd';
    % harmonic amplitudes:
    chns{id}.A  = 50*[1   0.01  0.001]';
    % harmonic phases:
    chns{id}.ph =    [0   -0.8  0.2]'*pi;
    % harmonic component index {1st, 2rd, ..., floor(0.4*fs/f0)}:
    chns{id}.fk =    [1    5    round(0.4*din.fs.v/f0)]';
    % differential mode: loop impedance:
    %chns{id}.Zx = 100;
    
    % -- CURRENT:
    id = id + 1;
    % channel parameters:
    chns{id}.name = 'i';
    chns{id}.type = 'shunt';
    % harmonic amplitudes:
    chns{id}.A  = 0.3*[1     0.01  0.001]';
    % harmonic phases:
    chns{id}.ph =     [1/3  +0.8  0.2]'*pi;
    % harmonic component index {1st, 2rd, ..., floor(0.4*fs/f0)}:
    chns{id}.fk =     [1     5    round(0.4*din.fs.v/f0)]';
    % differential mode: loop impedance:
    %chns{id}.Zx = 0.1;
        
    if true
        % -- voltage channel:
        din.u_tr_Zlo_f.v  = [];
        din.u_tr_Zlo_Rp.v = [200];
        din.u_tr_Zlo_Cp.v = [1e-12];        
        din.u_tr_Zlo_Rp.u = [1e-6];
        din.u_tr_Zlo_Cp.u = [1e-12];
        % create some corretion table for the digitizer gain: 
        din.u_adc_gain_f.v = [0;1e3;1e6];
        din.u_adc_gain_a.v = [];
        din.u_adc_gain.v = [1.000000; 1.010000; 1.100000];
        din.u_adc_gain.u = [0.000005; 0.000020; 0.000300]; 
        % create some corretion table for the digitizer phase: 
        din.u_adc_phi_f.v = [0;1e3;1e6];
        din.u_adc_phi_a.v = [];
        din.u_adc_phi.v = [0.0000; 0.000100; 0.1000];
        din.u_adc_phi.u = [0.0001; 0.000020; 0.0010];
        % create identical low-side channel:
        din.u_lo_adc_gain_f = din.u_adc_gain_f;
        din.u_lo_adc_gain_a = din.u_adc_gain_a;
        din.u_lo_adc_gain = din.u_adc_gain;
        din.u_lo_adc_phi_f = din.u_adc_phi_f;
        din.u_lo_adc_phi_a = din.u_adc_phi_a;
        din.u_lo_adc_phi = din.u_adc_phi;
        din.u_lo_adc_phi.v(2:end) = din.u_lo_adc_phi.v(2:end) + 0.005; % change dig. tfer so u/i are not idnetical
        
        % create some corretion table for the transducer gain: 
        din.u_tr_gain_f.v = [0;1e3;1e6];
        din.u_tr_gain_a.v = [];
        din.u_tr_gain.v = [70.00000; 70.80000; 70.600];
        din.u_tr_gain.u = [ 0.00010;  0.00020;  0.005]; 
        % create some corretion table for the transducer phase: 
        din.u_tr_phi_f.v = [0;1e3;1e6];
        din.u_tr_phi_a.v = [];
        din.u_tr_phi.v = [0.00000; -0.00300; -0.3000];
        din.u_tr_phi.u = [0.00010;  0.00020;  0.0030];
        % differential timeshift:
        din.u_time_shift_lo.v = -1.133e-3;
        din.u_time_shift_lo.u = 1e-5;
        
        
        % -- current channel:
        % create some corretion table for the digitizer gain: 
        din.i_adc_gain_f = din.u_adc_gain_f;
        din.i_adc_gain_a = din.u_adc_gain_a;
        din.i_adc_gain = din.u_adc_gain;
        din.i_adc_gain.v = din.i_adc_gain.v*1.1; % change dig. tfer so u/i are not idnetical 
        din.i_adc_phi_f = din.u_adc_phi_f;
        din.i_adc_phi_a = din.u_adc_phi_a;
        din.i_adc_phi = din.u_adc_phi;
        din.i_adc_phi.v = din.i_adc_phi.v;
        din.i_adc_phi.v(2:end) = din.i_adc_phi.v(2:end) + 0.005; % change dig. tfer so u/i are not idnetical
        % create some corretion table for the digitizer phase: 
        din.i_lo_adc_gain_f = din.i_adc_gain_f;
        din.i_lo_adc_gain_a = din.i_adc_gain_a;
        din.i_lo_adc_gain = din.i_adc_gain;
        din.i_lo_adc_phi_f = din.i_adc_phi_f;
        din.i_lo_adc_phi_a = din.i_adc_phi_a;
        din.i_lo_adc_phi = din.i_adc_phi;             
        % create some corretion table for the transducer gain: 
        din.i_tr_gain_f.v = [0;1e3;1e6];
        din.i_tr_gain_a.v = [];
        din.i_tr_gain.v = [ 0.500000; 0.510000; 0.60000];
        din.i_tr_gain.u = [ 0.000010; 0.000020; 0.00050]; 
        % create some corretion table for the transducer phase: 
        din.i_tr_phi_f.v = [0;1e3;1e6];
        din.i_tr_phi_a.v = [];
        din.i_tr_phi.v = [0.00000; -0.00300; -0.3000] + 0.0;
        din.i_tr_phi.u = [0.00010;  0.00020;  0.0030];        
        % differential timeshift:
        din.i_time_shift_lo.v = -2.133e-3;
        din.i_time_shift_lo.u = 1e-5;
                
        % interchannel timeshift:
        din.time_shift.v = 1.133e-4;
        din.time_shift.u = 1e-5;
    
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
        tab_list = {'tr_gain','tr_phi','tr_Zca','tr_Yca','tr_Zcal','tr_Zcam','adc_Yin','lo_adc_Yin','Zcb','Ycb','tr_Zlo','adc_gain','adc_phi','lo_adc_gain','lo_adc_phi'};
        chtab = conv_vchn_tabs(tab,chn.name,tab_list);
    
        % calculate actual frequencies of the harmonics:
        fx = chn.fk*f0;
        
        % rms level of the input signal:
        rms = sum(0.5*chn.A.^2)^0.5;        
        chns{c}.rms = rms;
        
        
                
        
        % --- apply transducer transfer:
        if rand_unc, rand_unc_str = 'rand'; else rand_unc_str = ''; end % randomize uncertainty option:
        A_syn = [];
        ph_syn = [];
        tsh_lo = [];
        sctab = {};
        sub_chn = {};        
        if is_diff
            % -- differential connection (create two subchannels: high and low-side):            
            [A_syn(:,1),ph_syn(:,1),A_syn(:,2),ph_syn(:,2)] = correction_transducer_sim(chtab,chn.type,fx,chn.A,chn.ph,0,0,rand_unc_str,chn.Zx);
            % prepare digitizer sunchannel correction tables:
            sctab{1}.adc_gain = chtab.adc_gain; % high-side
            sctab{1}.adc_phi  = chtab.adc_phi;
            sctab{2}.adc_gain = chtab.lo_adc_gain; % low-side
            sctab{2}.adc_phi  = chtab.lo_adc_phi;
            % prepare subchannel timeshifts:
            tsh_lo(1) = 0; % high-side
            tslo = getfield(din,[cpfx 'time_shift_lo']); 
            tsh_lo(2) = -tslo.v + randn(1)*tslo.u.*rand_unc; % low-side
            
            % subchannel waveform names:
            sub_chn{1} = chn.name; % high-side
            sub_chn{2} = [chn.name '_lo']; % low-side
        else
            % -- single-ended connection (create single channel):
            [A_syn,ph_syn] = correction_transducer_sim(chtab,chn.type,fx,chn.A,chn.ph,0,0,rand_unc_str);
            % prepare digitizer sunchannel correction tables:
            sctab{1}.adc_gain = chtab.adc_gain;
            sctab{1}.adc_phi  = chtab.adc_phi;
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
                         
            % generate time vector 2*pi*t:
            % note: including time shift!
            t = [];
            t(:,1) = ([0:N-1]/din.fs.v + tsh + tsh_lo(k))*2*pi;
            
            % synthesize waveform (crippled for Matlab < 2016b):
            % u = Av.*sin(t.*fx + phc);
            u = bsxfun(@times, Ac', sin(bsxfun(@plus, bsxfun(@times, t, fx'), phc')));
            % sum the harmonic components to a single composite signal:
            u = sum(u,2);
            
            % add some noise:
            u = u + randn(size(u))*adc_std_noise; 
            
            % store to the QWTB input list:
            din_alg = setfield(din_alg, sub_chn{k}, struct('v',u));

        end
    
    end    

    % --- execute the algorithm:
    dout = qwtb('TWM-PWRTDI',din_alg);
    
    % calculate reference values:
    U_ref  = chns{1}.rms;
    I_ref  = chns{2}.rms;
    S_ref  = chns{1}.rms.*chns{2}.rms;
    P_ref  = 0.5*sum(chns{1}.A.*chns{2}.A.*cos(chns{2}.ph - chns{1}.ph));    
    Q_ref  = (S_ref^2 - P_ref.^2)^0.5;
    PF_ref = P_ref/S_ref;
    
    % get calculated values:
    Ux  = dout.U.v;
    Ix  = dout.I.v;
    Sx  = dout.S.v;
    Px  = dout.P.v;
    Qx  = dout.Q.v;
    PFx = dout.PF.v;
    
    ref_list =  [U_ref,I_ref,S_ref,P_ref,Q_ref,PF_ref];    
    dut_list =  [Ux,   Ix,   Sx,   Px,   Qx,   PFx];
    name_list = {'U','I','S','P','Q','PF'};
    
    fprintf('   |     REF     |     DUT     |   ABS DEV   |  %%-DEV\n');
    fprintf('---+-------------+-------------+-------------+----------\n');
    for k = 1:numel(ref_list)
        
        ref = ref_list(k);
        dut = dut_list(k);
        name = name_list{k};
        
        fprintf('%-2s | %11.6f | %11.6f | %+11.6f | %+8.4f\n',name,ref,dut,dut - ref,100*(dut - ref)/ref);
        
    end
      
    
    
    
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
   