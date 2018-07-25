function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-PWRTDI.
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.   
%
% See also qwtb

    
    % calculation setup:
    calcset.verbose = 1;
    calcset.unc = 'guf'; % uncertainty mode
    calcset.loc = 0.95;
    % MonteCarlo (for 'mcm' uncertainty mode) setup:
    calcset.mcm.repeats = 100; % cycles
    calcset.mcm.method = 'multicore'; % parallelization mode
    calcset.mcm.procno = 0; % no. of parallel processes (0 to not start slaves)
    %calcset.mcm.tmpdir = 'c:\work\_mc_jobs_'; % jobs sharing folder for 'multistation' mode
    
    % samples count to synthesize:
    %N = 2000;
    N = round(logrand(5000,20000));    
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
    din.ac_coupling.v = 0;       
    
    % ADC jitter [s]:
    din.u_adc_jitt.v = 1e-9;
    din.u_lo_adc_jitt.v = din.u_adc_jitt.v;
    din.i_adc_jitt.v = din.u_adc_jitt.v;         
    din.i_lo_adc_jitt.v = din.i_adc_jitt.v;
    
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
    rand_unc = 0;
    
    
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
    U0 = logrand(5,50);
    chns{id}.A = U0*[1   logrand(0.01,0.1)  0.001]';
    % harmonic phases:
    %chns{id}.ph = [0   -0.8  0.2]'*pi;
    chns{id}.ph = [0   linrand(-0.8,0.8)  0.2]'*pi;
    % harmonic component frequency {1st, 2rd, ..., floor(0.4*fs/f0)}:
    chns{id}.fx = f0*[1   f_harm             round(0.4*din.fs.v/f0)]';
    % DC component:
    chns{id}.dc = linrand(-0.5,0.5);
    % SFDR simulation:
    chns{id}.sfdr = 1e-6; % sfdr max amplitude
    chns{id}.sfdr_hn = 10; % sfdr max harmonics count
    chns{id}.sfdr_rand = 1; % randomize sfdr amplitudes?    
    chns{id}.sfdr_rand_f = 0; % randomize sfdr frequencies?
    % ADC rms noise [s]:
    chns{id}.adc_std_noise = 1e-6;
    % differential mode: loop impedance:
    %chns{id}.Zx = 100;
     
    
    % -- CURRENT:
    id = id + 1;
    % channel parameters:
    chns{id}.name = 'i';
    chns{id}.type = 'shunt';
    % harmonic amplitudes:
    %chns{id}.A  = 0.3*[1     0.01 0.001]';
    I0 = logrand(0.1,0.9);
    chns{id}.A  = I0*[1  logrand(0.01,0.1)  0.001]';
    % harmonic phases:
    PF = round(linrand(0.1,1.0)*100)/100;
    %chns{id}.ph = [1/3  +0.8  0.2]'*pi;
    chns{id}.ph = [acos(PF)/pi  linrand(-0.8,0.8)  0.2]'*pi;
    % harmonic component frequency {1st, 2rd, ..., floor(0.4*fs/f0)}:
    chns{id}.fx = f0*[1  f_harm  round(0.4*din.fs.v/f0)]';
    % DC component:
    chns{id}.dc = linrand(-0.05,0.05);
    % SFDR simulation:
    chns{id}.sfdr = 1e-6; % sfdr max amplitude
    chns{id}.sfdr_hn = 10; % sfdr max harmonics count
    chns{id}.sfdr_rand = 1; % randomize sfdr amplitudes?    
    chns{id}.sfdr_rand_f = 0; % randomize sfdr frequencies?
    % ADC rms noise [s]:
    chns{id}.adc_std_noise = 1e-6;
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
        [din.u_adc_gain_f,din.u_adc_gain,din.u_adc_phi] ...
          = gen_adc_tfer(din.fs.v/2+1,50, 1.05,0.000002, linrand(-0.05,+0.05),0.00005 ,linrand(0.5,3) ,0.2*din.fs.v,0.03, ...
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
        din.u_adc_sfdr.v = -log10(chns{1}.sfdr)*20;
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
        % digitizer resolution:
        din.u_adc_bits.v = 24;
        din.u_adc_nrng.v = 1;
        din.u_lo_adc_bits.v = 24;
        din.u_lo_adc_nrng.v = 1;
        % digitizer offset:
        din.u_adc_offset.v = 0.01;
        din.u_adc_offset.u = 0.0001;
        din.u_lo_adc_offset.v = -0.01;
        din.u_lo_adc_offset.u = 0.0001;                
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
        din.u_tr_sfdr.v = [180];
        % differential timeshift:
        din.u_time_shift_lo.v = +53e-6;
        din.u_time_shift_lo.u =  0.8e-6;        
        
        
        % -- current channel:
        % create some corretion table for the digitizer gain/phase tfer: 
        [din.i_adc_gain_f,din.i_adc_gain,din.i_adc_phi] ...
          = gen_adc_tfer(din.fs.v/2+1,50, 0.95,0.000002, linrand(-0.05,+0.05),0.00005 ,linrand(0.5,3) ,0.2*din.fs.v,0.03, ...
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
        din.i_adc_sfdr.v = -log10(chns{2}.sfdr)*20;
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
        % digitizer resolution:
        din.i_adc_bits.v = 24;
        din.i_adc_nrng.v = 1;
        din.i_lo_adc_bits.v = 24;
        din.i_lo_adc_nrng.v = 1;
        % digitizer offset:
        din.i_adc_offset.v = 0.01;
        din.i_adc_offset.u = 0.0001;
        din.i_lo_adc_offset.v = -0.01;
        din.i_lo_adc_offset.u = 0.0001;
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
        din.i_tr_sfdr.v = [180];        
        % differential timeshift:
        din.i_time_shift_lo.v = -27e-6;
        din.i_time_shift_lo.u =  0.7e-6;
                
        % interchannel timeshift:
        din.time_shift.v =  33.30e-6;
        din.time_shift.u =   0.03e-6;
    
    end
        
    
    % --- generate the signal:
    cfg.N = N; % samples count
    cfg.chn = chns;    
    [datain,simout] = gen_pwr(din, cfg, rand_unc); % generate
            

    % add fake uncertainties to allow uncertainty calculation:
    %  ###todo: to be removed when QWTB supports no uncertainty checking 
    alginf = qwtb('TWM-PWRTDI','info');
    qwtb('TWM-PWRTDI','addpath');    
    datain = qwtb_add_unc(datain,alginf.inputs);

    % --- execute the algorithm:    
    calcset.mcm.randomize = 0;
    dout = qwtb('TWM-PWRTDI',datain,calcset);
    
    
    % --- plot results:
        
    % make list of quantities to display:
    ref_list =  [simout.U_rms, simout.I_rms, simout.S, simout.P, simout.Q, simout.PF];
    dut_list =  [dout.U.v,     dout.I.v,     dout.S.v, dout.P.v, dout.Q.v, dout.PF.v];
    unc_list =  [dout.U.u,     dout.I.u,     dout.S.u, dout.P.u, dout.Q.u, dout.PF.u];
    name_list = {'U',          'I',          'S',      'P',      'Q',      'PF'};
        
    % plot table of results:
    fprintf('\n---+-------------+----------------------------+-------------+----------+----------+-----------\n');
    fprintf('   |     REF     |        CALC +- UNC         |   ABS DEV   |  DEV [%%] |  UNC [%%] | %%-OF-UNC\n');
    fprintf('---+-------------+----------------------------+-------------+----------+----------+-----------\n');
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
        
        fprintf('%-2s | %11s | %11s +- %-11s | %11s | %+8.4f | %+8.4f | %+3.0f\n',name,rv,sv,su,dv,100*dev/ref,unc/dut*100,puc);
        
    end
    fprintf('---+-------------+----------------------------+-------------+----------+----------+-----------\n');
      
    
    
    
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
   