function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-PWRTDI.
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.   
%
% See also qwtb

    
    % testing mode {0: single test, N >= 1: N repeated tests}:
    is_full_val = 0;
    
    % minimum number of repetitions per test setup:
    %  note: if the value is 1 and all quantities passed, the test is done successfully
    val.fast_mode = 0;
    % maximum number of test repetitions per test setups:
    val.max_count = 300;
    % resutls path:
    val_path = [fileparts(mfilename('fullpath')) filesep 'pwrtdi_val_mcm.mat']; 
    
    
    
    % --- Test function multicore setup:    
    % note: This is execution of the algorithm test, not execution mode if the algorithm itself!
    %       Do not use multicore processing here and for the algorithm at once!  
    % multicore cores count (0 to not start any, user must start servers manually):
    if ~ispc    
        mc_setup.cores = 400; % for supercomputer
    else
        mc_setup.cores = 0; % do not start servers in windoze (started manually)
    end        
    % multicore method {'cellfun','parcellfun','multicore'}:
    mc_setup.method = 'multicore';
    % multicore options: jobs grouping for 'parcellfun': 
    mc_setup.ChunksPerProc = 0;    
    % multicore behaviour:
    mc_setup.min_chunk_size = 1;
    % paths required for the calculation:
    %  note: multicore slaves need to know where to find the algorithm functions 
    mc_setup.user_paths = {fileparts(mfilename('fullpath')),[fileparts(mfilename('fullpath')) filesep '..']}; 
    if ispc
        % windoze - most likely small CPU:
        % use only small count of job files, coz windoze may get mad...    
        mc_setup.max_chunk_count = 200;
        % run only master if cores count set to 0 (assuming slave servers are already running on background)
        mc_setup.run_master_only = (mc_setup.cores == 0);
        % lest master work as well, it won't do any harm:
        mc_setup.master_is_worker = (mc_setup.cores <= 4);
        % multicore jobs directory:
        mc_setup.share_fld = 'f:\work\_mc_jobs_'; 
    else
        % Unix: possibly supercomputer - assume large CPU:
        % set large number of job files, coz Linux or supercomputer should be able to handle it well:    
        mc_setup.max_chunk_count = 10000;
        % run only master if cores count set to 0 (assuming slave servers are already running on background)
        mc_setup.run_master_only = (mc_setup.cores == 0);
        % do not let master work, assuming there is fuckload of slave servers to do stuff:
        mc_setup.master_is_worker = (mc_setup.cores <= 4);
        % multicore jobs directory:
        mc_setup.share_fld = 'mc_rubbish';
        %try
        mc_setup.run_after_slaves = @coklbind2;
        %end
    end
    
    
    
    
    % --- Algorithm calculation setup ---:    
    calcset.verbose = ~is_full_val;
    calcset.unc = 'guf'; % uncertainty mode
    calcset.loc = 0.95;
    calcset.dbg_plots = 0;
    % MonteCarlo (for 'mcm' uncertainty mode) setup:
    calcset.mcm.repeats = 1000; % cycles
    if ~is_full_val
        calcset.mcm.method = 'multistation'; % parallelization mode
    else
        calcset.mcm.method = 'singlecore'; % do not change (for full validation test only)
    end
    calcset.mcm.procno = 0; % no. of parallel processes (0 to not start slaves)
    %calcset.mcm.user_fun = @coklbind2; % user function after servers startup (for CMI's supercomputer)
    %calcset.mcm.tmpdir = 'c:\work\_mc_jobs_'; % jobs sharing folder for 'multistation' mode
    % no QWTB input checking:
    calcset.cor.req = 0; calcset.cor.gen = 0; calcset.dof.req = 0; calcset.dof.gen = 0;
    calcset.checkinputs = 0;
        
    % faster mode - uncertainty LUTs are stored in globals to prevent repeated file access (for validation on supercomp. only):
    calcset.fetch_luts = (is_full_val > 0);
    
    
    if is_full_val
        % --- full validation mode ---
        
        % add variation lib:
        addpath([fileparts(mfilename('fullpath')) filesep 'var']);
    
        % -- test setup combinations:
        
        % randomize corrections uncertainty:
        %com.rand_unc = [0 1];
        com.rand_unc = [1];
        % differential sensors:
        %com.is_diff = [0 1];
        com.is_diff = [0];
    
        % generate all test setup combinations:
        [vr,com] = var_init(com);
        simcom = var_get_all_fast(com,vr,5000,1);        
    else        
        % --- single test mode ---
        simcom = {struct()};
        
        simcom{1}.rand_unc = 1;
        simcom{1}.is_diff = 0;
    end
        
    

    fprintf('Generating test setups...\n');    
        
    % list of test setups:
    par = {};
    pn = 0;
    
    % --- FOR EACH TEST SETUP GROUP: ---
    simcom_num = numel(simcom);
    for c = 1:simcom_num
    
        % --- FOR EACH VALIDATION TEST: ---
        val_num = max(1,is_full_val);
        for v = 1:val_num
        
            % clear alg. inputs:
            din = struct();        
        
            % corretions interpolation mode:
            %  note: must be the same as in the alg. itself!
            %        for frequency corrections the best is usually 'pchip'
            i_mode = 'pchip';
            
            % randomize corrections uncertainty:
            rand_unc = simcom{c}.rand_unc;
            
            % nyquist limit [-]:
            %  note: maximum allowed f_component/fs ratio
            nylim = 0.4;
            
            % enable AC coupling:
            din.ac_coupling.v = (rand > 0.5);
            
            % aperture correction state:
            din.u_adc_aper_corr.v = 1;
            din.u_lo_adc_aper_corr = din.u_adc_aper_corr;
            din.i_adc_aper_corr = din.u_adc_aper_corr;
            din.i_lo_adc_aper_corr = din.u_adc_aper_corr;
            
            % bit resolution limits:
            bits_min = 16;
            bits_max = 28; 
               
            
            % samples count to synthesize:
            %N = 13528;
            N = round(logrand(5000,20000));
                
            % sampling rate [Hz]
            din.fs.v = 10000;        
            
            % min max allowed fundamental frequency:
            %  note: given by uncertainty estimator range
            f0_max = din.fs.v/10;
            f0_min = 20/(N/din.fs.v);
                
            % fundamental frequency [Hz]:
            %f0 = 124;
            f0 = rounddig(logrand(f0_min,f0_max),3);        
            
            % ADC aperture [s]:
            din.adc_aper.v = logrand(1e-9,10e-6);
                
            % ADC jitter [s]:
            din.u_adc_jitt.v = logrand(1e-9,100e-9);
            din.u_lo_adc_jitt.v = din.u_adc_jitt.v;
            din.i_adc_jitt.v = din.u_adc_jitt.v;         
            din.i_lo_adc_jitt.v = din.i_adc_jitt.v;
                
            % nominal voltage range:
            U_rng = logrand(10,70);
            U_max = 5/7*U_rng; % max aplitude to generate
            
            % nominal current range:
            I_rng = logrand(0.5,5);
            I_max = 5/7*I_rng; % max aplitude to generate
            
            % ADC RMS noise [V]:
            adc_noise = logrand(1e-6,10e-6);
            
            % ADC SFDR value unitless [-]:
            adc_sfdr = logrand(1e-6,100e-6);    
            
            % fundamental periods in the record:
            f0_per = f0*N/din.fs.v;
                
            % samples per period of fundamental:
            fs_rat = din.fs.v/f0;
            
            % harmonic components to generate:
            f_harm = [1:round(linrand(1,5))];   
            f_harm = f_harm(f0*f_harm < nylim*din.fs.v); % lim by nyquist
            n_harm = numel(f_harm);    
                
            % -- generate some interharmonic:
            i_harm_min_dist = 0.2;  % min allowed relative distance from any harmonic
            % DFT frequency step:
            fft_step = din.fs.v/N;
            % analyser window width (HFT144D: 9bins):
            w_fw = 9*fft_step;        
            % retry until found:
            min_fih = 1;
            for k = 1:100
                f_iharm = linrand(min_fih, min(nylim*din.fs.v/f0,3));        
                if all(abs(f_iharm - f_harm) > i_harm_min_dist & f0*abs(f_iharm - f_harm) > w_fw)
                    break;
                end
                if k == 50
                    min_fih = max(f_harm);
                end                
            end
            if k >= 100
                error('No suitable place for inter-harmonic found!');        
            end
            
                
            
            chns = {}; id = 0;    
               
            % -- VOLTAGE:
            id = id + 1;
            % channel parameters:
            chns{id}.name = 'u';
            chns{id}.type = 'rvd';
            % harmonic amplitudes:
            U0 = logrand(0.1,1)*U_max;
            chns{id}.A = U0*[1     logrand(0.01,0.1,[1 n_harm-1]) logrand(0.001,0.01)]';
            % harmonic phases:
            chns{id}.ph =   [0     linrand(-0.9,0.9,[1 n_harm-1]) rand*2]'*pi;
            % harmonic component frequencies:
            chns{id}.fx = f0*[f_harm f_iharm]';
            % DC component:
            chns{id}.dc = linrand(-1,1)*0.05*U0;
            % SFDR simulation:
            chns{id}.sfdr = adc_sfdr; % sfdr max amplitude
            chns{id}.sfdr_hn = 10; % sfdr max harmonics count
            chns{id}.sfdr_rand = 1; % randomize sfdr amplitudes?    
            chns{id}.sfdr_rand_f = 0; % randomize sfdr frequencies?
            % ADC rms noise [s]:
            chns{id}.adc_std_noise = adc_noise;
            % differential mode: loop impedance:
            if simcom{c}.is_diff
                chns{id}.Zx = 10;
            end
             
            
            % -- CURRENT:
            id = id + 1;
            % channel parameters:
            chns{id}.name = 'i';
            chns{id}.type = 'shunt';
            % harmonic amplitudes:
            I0 = logrand(0.1,1)*I_max;
            chns{id}.A  = I0*[1      logrand(0.01,0.1,[1 n_harm-1])  logrand(0.001,0.01)]';
            % harmonic phases:        
            phi_ef = linrand(-0.45*pi,+0.45*pi)*sign(randn);
            chns{id}.ph =    [phi_ef linrand(-0.9,0.9,[1 n_harm-1])  rand*2]'*pi;
            % harmonic component frequencies:
            chns{id}.fx = chns{id-1}.fx;
            % DC component:
            chns{id}.dc = linrand(-1,1)*0.05*I0;
            % SFDR simulation:
            chns{id}.sfdr = adc_sfdr; % sfdr max amplitude
            chns{id}.sfdr_hn = 10; % sfdr max harmonics count
            chns{id}.sfdr_rand = 1; % randomize sfdr amplitudes?    
            chns{id}.sfdr_rand_f = 0; % randomize sfdr frequencies?
            % ADC rms noise [s]:
            chns{id}.adc_std_noise = adc_noise;
            % differential mode: loop impedance:
            if simcom{c}.is_diff
                chns{id}.Zx = 0.1;
            end
            
                
            if true
            
                % maximum digitizer interchannel time shift expressed as phase shift at nyquist frequency [rad]: 
                max_chn2chn_phi   = 1.0;
                max_chn2chn_phi_u = 0.05; % uncertainty
                max_chn2chn_td   = max_chn2chn_phi/(2*pi*0.5*din.fs.v); % expressed as delay
                max_chn2chn_td_u = max_chn2chn_phi_u/(2*pi*0.5*din.fs.v); % expressed as delay
            
                % -- voltage channel:
                din.u_tr_Zlo_f.v  = [];
                din.u_tr_Zlo_Rp.v = [200];
                din.u_tr_Zlo_Cp.v = [1e-12];        
                din.u_tr_Zlo_Rp.u = [0e-6];
                din.u_tr_Zlo_Cp.u = [0e-12];
                % create some corretion table for the digitizer gain/phase: 
                [din.u_adc_gain_f,din.u_adc_gain,din.u_adc_phi] ...
                  = gen_adc_tfer(din.fs.v/2+1,50, linrand(0.95,1.05),0.000002, linrand(-0.05,+0.05),0.00005 ,linrand(0.5,3) ,0.2*din.fs.v,0.03, ...
                                 linrand(-0.001,+0.001),0.00008,0.000002,linrand(0.7,3));
                din.u_adc_phi_f = din.u_adc_gain_f;         
                din.u_adc_gain_a.v = [];
                din.u_adc_phi_a.v = [];
                % digitizer SFDR value:
                din.u_adc_sfdr_a.v = [];
                din.u_adc_sfdr_f.v = [];
                din.u_adc_sfdr.v = -log10(chns{1}.sfdr)*20;
                % create identical low-side channel:
                [din.u_lo_adc_gain_f,din.u_lo_adc_gain,din.u_lo_adc_phi] ...
                  = gen_adc_tfer(din.fs.v/2+1,50, linrand(0.95,1.05),0.000002, linrand(-0.05,+0.05),0.00005 ,linrand(0.5,3) ,0.2*din.fs.v,0.03, ...
                                 linrand(-0.001,+0.001),0.00008,0.000002,linrand(0.7,3));
                din.u_lo_adc_phi_f = din.u_lo_adc_gain_f;         
                din.u_lo_adc_gain_a.v = [];
                din.u_lo_adc_phi_a.v = [];
                % digitizer SFDR value (low-side):
                din.u_lo_adc_sfdr_a.v = din.u_adc_sfdr_a.v;
                din.u_lo_adc_sfdr_f.v = din.u_adc_sfdr_f.v;
                din.u_lo_adc_sfdr.v = din.u_adc_sfdr.v;
                % digitizer resolution:
                din.u_adc_bits.v = linrand(bits_min,bits_max);
                din.u_adc_nrng.v = 1;
                din.u_lo_adc_bits.v = linrand(bits_min,bits_max);
                din.u_lo_adc_nrng.v = 1;
                % digitizer offset:
                din.u_adc_offset.v = linrand(-0.01,0.01);
                din.u_adc_offset.u = 0.0001;
                din.u_lo_adc_offset.v = linrand(-0.01,0.01);
                din.u_lo_adc_offset.u = 0.0001;                
                % create some corretion table for the transducer gain/phase: 
                [din.u_tr_gain_f,din.u_tr_gain,din.u_tr_phi] ...
                  = gen_adc_tfer(din.fs.v/2+1,50, U_rng,0.000002*U_rng, linrand(-0.05,+0.05),0.000050 ,linrand(0.5,3) ,linrand(0.1,0.25)*din.fs.v,0.03, ...
                                 linrand(-0.001,+0.001),0.000080,0.000002,linrand(0.7,3));
                din.u_tr_phi_f = din.u_tr_gain_f;
                din.u_tr_gain_a.v = [];
                din.u_tr_phi_a.v = [];         
                % transducer SFDR value:
                din.u_tr_sfdr_a.v = [];
                din.u_tr_sfdr_f.v = [];
                din.u_tr_sfdr.v = [180];
                % differential timeshift:
                din.u_time_shift_lo.v = linrand(-1,1)*max_chn2chn_td;
                din.u_time_shift_lo.u = logrand(0.1,1)*max_chn2chn_td_u;
                
                
                % -- current channel:
                % create some corretion table for the digitizer gain/phase tfer: 
                [din.i_adc_gain_f,din.i_adc_gain,din.i_adc_phi] ...
                  = gen_adc_tfer(din.fs.v/2+1,50, linrand(0.95,1.05),0.000002, linrand(-0.05,+0.05),0.00005 ,linrand(0.5,3) ,0.2*din.fs.v,0.03, ...
                                 linrand(-0.001,+0.001),0.00008,0.000002,linrand(0.7,3));
                din.i_adc_phi_f = din.i_adc_gain_f;         
                din.i_adc_gain_a.v = [];
                din.i_adc_phi_a.v = [];
                % digitizer SFDR value:
                din.i_adc_sfdr_a.v = [];
                din.i_adc_sfdr_f.v = [];
                din.i_adc_sfdr.v = -log10(chns{2}.sfdr)*20;
                % create some corretion table for the digitizer phase: 
                [din.i_lo_adc_gain_f,din.i_lo_adc_gain,din.i_lo_adc_phi] ...
                  = gen_adc_tfer(din.fs.v/2+1,50, linrand(0.95,1.05),0.000002, linrand(-0.05,+0.05),0.00005 ,linrand(0.5,3) ,0.2*din.fs.v,0.03, ...
                                 linrand(-0.001,+0.001),0.00008,0.000002,linrand(0.7,3));
                din.i_lo_adc_phi_f = din.i_lo_adc_gain_f;         
                din.i_lo_adc_gain_a.v = [];
                din.i_lo_adc_phi_a.v = [];
                % digitizer SFDR value (low-side):
                din.i_lo_adc_sfdr_a.v = din.i_adc_sfdr_a.v;
                din.i_lo_adc_sfdr_f.v = din.i_adc_sfdr_f.v;
                din.i_lo_adc_sfdr.v = din.i_adc_sfdr.v;
                % digitizer resolution:
                din.i_adc_bits.v = linrand(bits_min,bits_max);
                din.i_adc_nrng.v = 1;
                din.i_lo_adc_bits.v = linrand(bits_min,bits_max);
                din.i_lo_adc_nrng.v = 1;
                % digitizer offset:
                din.i_adc_offset.v = linrand(-0.01,0.01);
                din.i_adc_offset.u = 0.0001;
                din.i_lo_adc_offset.v = linrand(-0.01,0.01);
                din.i_lo_adc_offset.u = 0.0001;
                % create some corretion table for the transducer gain/phase: 
                [din.i_tr_gain_f,din.i_tr_gain,din.i_tr_phi] ...
                  = gen_adc_tfer(din.fs.v/2+1,50, I_rng,0.000002*I_rng, linrand(-0.05,+0.05),0.000050 ,linrand(0.5,3) ,linrand(0.1,0.25)*din.fs.v,0.03, ...
                                 linrand(-0.001,+0.001),0.000080,0.000002,linrand(0.7,3));
                din.i_tr_phi_f = din.i_tr_gain_f;
                din.i_tr_gain_a.v = [];
                din.i_tr_phi_a.v = [];
                % transducer SFDR value:
                din.i_tr_sfdr_a.v = [];
                din.i_tr_sfdr_f.v = [];
                din.i_tr_sfdr.v = [180];        
                % differential timeshift:
                din.i_time_shift_lo.v = linrand(-1,1)*max_chn2chn_td;
                din.i_time_shift_lo.u =  logrand(0.1,1)*max_chn2chn_td_u;
                        
                % U-I interchannel timeshift:
                din.time_shift.v =  linrand(-1,1)*max_chn2chn_td;
                din.time_shift.u =  logrand(0.1,1)*max_chn2chn_td_u*0.1;
            
            end
            
            % create generator setup
            cfg.N = N; % samples count
            cfg.chn = chns;
            
            % store test setup to the list:
            pn = pn + 1;
            par{pn}.din = din;
            par{pn}.calcset = calcset;
            par{pn}.cfg = cfg;
            par{pn}.simcom = simcom{c};
            par{pn}.val = val;
            par{pn}.rand_unc = rand_unc;        
            
            if ~is_full_val
                fprintf('N = %.0f samples\n',N);
                fprintf('fs = %0.4f Hz\n',din.fs.v);
                fprintf('f0 = %0.4f Hz\n',f0);
                fprintf('f0 periods = %0.2f\n',f0_per);
                fprintf('fs/f0 ratio = %0.2f\n',fs_rat);
                fprintf('Harmonics = %s\n',sprintf('%.3g ',sort([f_harm f_iharm])));
            end
        
        end
    
    end
        
    if is_full_val > 0
        % --- FULL VALIDATION MODE ---
        
        fprintf('Processing test setups...\n');

        % -- processing start:
        res = runmulticore(mc_setup.method,@proc_pwrtdi_test,par,mc_setup.cores,mc_setup.share_fld,2,mc_setup);
               
        % store results:
        save(val_path,'-v7','res','simcom','vr');
        
        qwtb('TWM-PWRTDI','addpath');
        
        % print results:
        valid_report(res,vr);
        
    else
        % --- SINGLE VALIDATION MODE ---
        
        if is_full_val < 0
            % load setup from previous validation report:
            
            res = load(val_path,'res');
            par = res.res{-is_full_val}.par;
            din = par.din;
            cfg = par.cfg;
            calcset = par.calcset;
            rand_unc = par.rand_unc;
          
        end
    
        % --- generate the signal:        
        [datain,simout] = gen_pwr(din, cfg, rand_unc); % generate
        
        % add fake uncertainties to allow uncertainty calculation:
        %  ###todo: to be removed when QWTB supports no uncertainty checking 
        %alginf = qwtb('TWM-PWRTDI','info');
        %qwtb('TWM-PWRTDI','addpath');    
        %datain = qwtb_add_unc(datain,alginf.inputs);
    
        % --- execute the algorithm:    
        calcset.mcm.randomize = 0;
        dout = qwtb('TWM-PWRTDI',datain,calcset);
        
        
        % --- plot results:
            
        % make list of quantities to display:
        ref_list =  [simout.U_rms, simout.I_rms, simout.S, simout.P, simout.Q, simout.PF, simout.phi_ef*180/pi, simout.Udc, simout.Idc, simout.Pdc];
        dut_list =  [dout.U.v,     dout.I.v,     dout.S.v, dout.P.v, dout.Q.v, dout.PF.v, dout.phi_ef.v*180/pi, dout.Udc.v, dout.Idc.v, dout.Pdc.v];
        unc_list =  [dout.U.u,     dout.I.u,     dout.S.u, dout.P.u, dout.Q.u, dout.PF.u, dout.phi_ef.u*180/pi, dout.Udc.u, dout.Idc.u, dout.Pdc.u];
        name_list = {'U',          'I',          'S',      'P',      'Q',      'PF',      'phi',                'Udc',      'Idc',      'Pdc'};
            
        % plot table of results:
        fprintf('\n----+-------------+----------------------------+-------------+----------+----------+-----------\n');
        fprintf('    |     REF     |        CALC +- UNC         |   ABS DEV   |  DEV [%%] |  UNC [%%] | %%-OF-UNC\n');
        fprintf('----+-------------+----------------------------+-------------+----------+----------+-----------\n');
        for k = 1:numel(ref_list)
            
            ref = ref_list(k);
            dut = dut_list(k);
            unc = unc_list(k);
            name = name_list{k};
            
            nounc = isnan(unc);
            if nounc
                unc = 1e-6;
            end
            
            dev = dut - ref;
            
            puc = 100*dev/unc;
            
            [ss,sv,su] = unc2str(dut,unc);
            [ss,dv] = unc2str(dev,unc);
            [ss,rv] = unc2str(ref,unc);
            
            if nounc
                puc = NaN;
            end
            
            fprintf('%-3s | %11s | %11s +- %-11s | %11s | %+8.4f | %8.4f | %+3.0f\n',name,rv,sv,su,dv,100*dev/ref,abs(unc/dut)*100,puc);
            
        end
        fprintf('----+-------------+----------------------------+-------------+----------+----------+-----------\n');
    
    end
      
    
                                                          
    
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

function y = rounddig(x,d)
    digits = ceil(log10(x));    
    round_base = 10.^-(digits - d);    
    y = round(x.*round_base)./round_base;
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
   