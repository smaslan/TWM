function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-PWRFFT.
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.   
%
% See also qwtb


    % --- PWRFFT test function ---
    %  This is test function for the PWRFFT algorithm.
    %  It can operate in several modes. When is_full_val = 0 it will generate random signal
    %  and corrections, synthesize the signal of known power and calculates the power by
    %  tested algorithm and finally compares the calculated vs. generated power.
    %
    %  Next mode is validation when is_full_val > 0. In that case the function
    %  will test 'is_full_val' random signals, and for each it performs 'val.max_count'
    %  repeated tests to get average pass rate mean(|error(i)| < uncertainty(i),i = 1..val.max_count).
    %  Note the validation mode will work only in Octave without further modifications.   

    
    % testing mode {0: single test, N >= 1: N repeated tests}:
    is_full_val = 5000;
    
    
    % --- setup for validation only:
    % minimum number of repetitions per test setup:
    %  note: if the value is 1 and all quantities passed, the test is done successfully
    %val.fast_mode = 0; % ###note: note implemented
    % maximum number of test repetitions per test setup:
    val.max_count = 700;
    % print debug lines:
    val.dbg_print = 1;
    % resutls path:
    val_path = [fileparts(mfilename('fullpath')) filesep 'pwrfft_val_guf2.mat'];
    
    
    % --- validation test execution setup ---
    % paralellize at which level:
    %  'testsetup' - run test setups parallel (good for 'guf' validation)
    %  'testrun' - run test runs within the test setup parallel (good for 'mcm' validation)
    %  'mcm' - run Monte Carlo iterations in parallel (good only for small cores count) 
    %par_level = {'testrun','testsetup'};
    par_level = 'testsetup';
    if is_full_val <= 0
        par_level = 'mcm'; % override for single test    
    end
    
    % parallel instances (use 0 to not start servers, user must run them manually):
    par_cores = 0;
    
    % parallel execution mode (QWTB naming convence) {'singlecore', 'multicore', 'multistation'}:
    par_mode = 'multistation';
    
    % 'multistation' mode jobs sharing folder:
    if ispc
        % windoze:
        par_mc_folder = 'f:\work\_mc_jobs_';
        if ~exist(par_mc_folder,'file')
            par_mc_folder = 'c:\work\_mc_jobs_';
        end        
    else
        % linux:
        par_mc_folder = 'mc_rubbish';        
    end
    
        
    
    
    
    % --- Test function multicore setup:    
    % note: This is execution of the algorithm test, not execution mode if the algorithm itself!
    %       Do not use multicore processing here and for the algorithm at once!  
    % multicore cores count (0 to not start any, user must start servers manually):
    if ispc    
        mc_setup.cores = 0; % never start servers in windoze (started manually)
    else
        mc_setup.cores = par_cores; % for supercomputer        
    end            
    % multicore behaviour:
    mc_setup.min_chunk_size = 1;
    % multicore jobs directory:
    mc_setup.share_fld = par_mc_folder;
    % paths required for the calculation:
    %  note: multicore slaves need to know where to find the algorithm functions 
    mc_setup.user_paths = {fileparts(mfilename('fullpath')), fileparts(which('qwtb'))}; 
    % run only master if cores count set to 0 (assuming slave servers are already running on background)
    mc_setup.run_master_only = (mc_setup.cores == 0);
    if ispc
        % windoze - most likely small CPU:
        % use only small count of job files, coz windoze may get mad...    
        mc_setup.max_chunk_count = 200;
        % lest master work as well, it won't do any harm:
        mc_setup.master_is_worker = (mc_setup.cores <= 4);         
    else
        % Unix: possibly supercomputer - assume large CPU:
        % set large number of job files, coz Linux or supercomputer should be able to handle it well:    
        mc_setup.max_chunk_count = 10000;
        % lest master will not work, because there is fuckload of servers to do the stuff:
        mc_setup.master_is_worker = 0;
        if par_cores
            try
                mc_setup.run_after_slaves = @coklbind2;
            catch
                fprintf('User function ''@coklbind2'' not found!\n');
            end
        end
    end    
    % multicore method {'cellfun','parcellfun','multicore'}:        
    mc_setup.method = 'for'; % by defaul no parallel
    if any(strcmpi(par_level,'testsetup'))
        mc_setup.method = par_mode_qwtb2mc(par_mode);
    end
      
    % --- Test runs within the test setup execution mode: 
    % use the same setup as for test runs:
    mc_setup_runs = mc_setup;
    % decide parallel mode:
    mc_setup_runs.method = 'for'; % by defaul no parallel
    if any(strcmpi(par_level,'testrun'))
        mc_setup_runs.method = par_mode_qwtb2mc(par_mode);
    end
       
    
    
    % --- Algorithm calculation setup ---:     
    calcset.verbose = (is_full_val <= 0);
    calcset.unc = 'guf'; % uncertainty mode
    calcset.loc = 0.95;
    calcset.dbg_plots = 0;
    % MonteCarlo (for 'mcm' uncertainty mode) setup:
    calcset.mcm.repeats = 1000; % Monte Carlo cycles
    %calcset.mcm.max_jobs = 200; % limit jobs count
    calcset.mcm.method = 'singlecore'; % default execution on single core 
    if strcmpi(par_level,'mcm')
        calcset.mcm.method = par_mode; % parallelization allowed
    end
    calcset.mcm.procno = par_cores; % no. of parallel processes (0 to not start slaves)
    if ~ispc && par_cores
        try
            calcset.mcm.user_fun = @coklbind2; % user function after servers startup (for CMI's supercomputer)
        catch
            fprintf('User function ''@coklbind2'' not found!\n');
        end    
    end
    if strcmpi(calcset.unc,'mcm')
        calcset.mcm.tmpdir = par_mc_folder; % jobs sharing folder for 'multistation' mode
    end
    % no QWTB input checking:
    calcset.cor.req = 0; calcset.cor.gen = 0; calcset.dof.req = 0; calcset.dof.gen = 0;
    calcset.checkinputs = 0;        
    % faster mode - uncertainty LUTs are stored in globals to prevent repeated file access (for validation on supercomp. only):
    calcset.fetch_luts = (is_full_val > 0);
    
    if is_full_val > 0
        % --- full validation mode ---
    
        % -- test setup combinations:      
        % randomize corrections uncertainty:
        %com.rand_unc = [0];
        com.rand_unc = [0 1];
        % differential sensors:
        com.is_diff = [0 1];
        %com.is_diff = [0];
    
        % generate all test setup combinations:
        [vr,com] = var_init(com);
        simcom = var_get_all_fast(com,vr,5000,1);        
    else        
        % --- single test mode ---
        simcom = {struct()};
        
        simcom{1}.rand_unc = 0;
        simcom{1}.is_diff = 0;
    end
        
    

    
    if is_full_val > 0
        fprintf('Generating test setups...\n');
    end    
        
    % list of test setups:
    par = {};
    pn = 0;
    
    % --- FOR EACH TEST SETUP GROUP: ---
    simcom_num = numel(simcom);
    for c = 1:simcom_num
    
        % --- FOR EACH VALIDATION TEST: ---
        val_num = max(1,is_full_val);
        for v = 1:val_num
        
            % |||                                                               |||
            % VVV - HERE starts the definition of test signal and corrections - VVV
        
            % clear alg. inputs:
            din = struct();        
        
            % corretions interpolation mode:
            %  note: must be the same as in the alg. itself!
            %        for frequency corrections the best is usually 'pchip'
            i_mode = 'pchip';
            
            % corrections uncertainty randomization enable/disabled:
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
            
            % random bit resolution range:
            bits_min = 16;
            bits_max = 28; 
               
            
            % samples count to synthesize:
            N = round(logrand(5000,20000));
                
            % sampling rate [Hz]
            din.fs.v = rounddig(linrand(9000,11000),3);        
            
            % min max allowed fundamental frequency:
            %  note: given by uncertainty estimator range
            f0_max = din.fs.v/10;
            f0_min = 20/(N/din.fs.v);
                
            % fundamental frequency [Hz]:
            %f0 = 124;
            f0 = rounddig(logrand(f0_min,f0_max),3);
            
            
            % force coherent sampling by rounding fundamental frequency:
            %  note: this is needed for the window-less FFT mode                                     
            f0 = round(N/din.fs.v*f0)*din.fs.v/N;
            
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
            % max amplitude:
            i_harm_amp = 0; % disabled for coherent FFT
            % min allowed relative distance from any harmonic:
            i_harm_min_dist = 0.2;
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
            chns{id}.A = U0*[1     logrand(0.01,0.1,[1 n_harm-1]) i_harm_amp]';
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
            chns{id}.A  = I0*[1      logrand(0.01,0.1,[1 n_harm-1])  i_harm_amp]';
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
                max_chn2chn_phi   = 0.1;
                %max_chn2chn_phi_u = 0.02; % uncertainty
                max_chn2chn_td   = max_chn2chn_phi/(2*pi*0.5*din.fs.v); % expressed as delay
                %max_chn2chn_td_u = max_chn2chn_phi_u/(2*pi*0.5*din.fs.v) % expressed as delay
                max_chn2chn_td_u = 20e-9;
                
                % maximum change of gain of digitizer from DC to AC at fs/2 [-]:
                adc_mgain_acdc = 0.01; 
                % maximum phase error of digitizer [rad]:
                adc_mphi = 0.001;
                % maximum change of gain of transducer from DC to AC at fs/2 [-]:
                tr_mgain_acdc = 0.02;
                % maximum phase error of transducer [rad]:
                tr_mphi = 0.001;
                
            
                % -- voltage channel:
                din.u_tr_Zlo_f.v  = [];
                din.u_tr_Zlo_Rp.v = [200];
                din.u_tr_Zlo_Cp.v = [1e-12];        
                din.u_tr_Zlo_Rp.u = [0e-6];
                din.u_tr_Zlo_Cp.u = [0e-12];
                % create some corretion table for the digitizer gain/phase: 
                [din.u_adc_gain_f,din.u_adc_gain,din.u_adc_phi] ...
                  = gen_adc_tfer(din.fs.v/2+1,50, linrand(0.95,1.05),0.000002, linrand(-adc_mgain_acdc,+adc_mgain_acdc),0.00005,linrand(0.5,3), ...
                                 0.2*din.fs.v,logrand(0.005,0.03), ...
                                 linrand(-adc_mphi,+adc_mphi),0.00008,0.000002,linrand(0.7,3));
                din.u_adc_phi_f = din.u_adc_gain_f;         
                din.u_adc_gain_a.v = [];
                din.u_adc_phi_a.v = [];
                % digitizer SFDR value:
                din.u_adc_sfdr_a.v = [];
                din.u_adc_sfdr_f.v = [];
                din.u_adc_sfdr.v = -log10(chns{1}.sfdr)*20;
                % create identical low-side channel:
                [din.u_lo_adc_gain_f,din.u_lo_adc_gain,din.u_lo_adc_phi] ...
                  = gen_adc_tfer(din.fs.v/2+1,50, linrand(0.95,1.05),0.000002, linrand(-adc_mgain_acdc,+adc_mgain_acdc),0.00005,linrand(0.5,3), ...
                                 0.2*din.fs.v,logrand(0.005,0.03), ...
                                 linrand(-adc_mphi,+adc_mphi),0.00008,0.000002,linrand(0.7,3));
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
                din.u_adc_offset.v = linrand(-0.005,0.005);
                din.u_adc_offset.u = 0.0001;
                din.u_lo_adc_offset.v = linrand(-0.005,0.005);
                din.u_lo_adc_offset.u = 0.0001;                
                % create some corretion table for the transducer gain/phase: 
                [din.u_tr_gain_f,din.u_tr_gain,din.u_tr_phi] ...
                  = gen_adc_tfer(din.fs.v/2+1,50, U_rng,0.000002*U_rng, linrand(-tr_mgain_acdc,+tr_mgain_acdc),0.000050,linrand(0.5,3), ...
                                 linrand(0.1,0.25)*din.fs.v,0.005, ...
                                 linrand(-tr_mphi,+tr_mphi),0.000080,0.000002,linrand(0.7,3));
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
                  = gen_adc_tfer(din.fs.v/2+1,50, linrand(0.95,1.05),0.000002, linrand(-adc_mgain_acdc,+adc_mgain_acdc),0.00005,linrand(0.5,3), ...
                                 0.2*din.fs.v,logrand(0.005,0.03), ...
                                 linrand(-adc_mphi,+adc_mphi),0.00008,0.000002,linrand(0.7,3));
                din.i_adc_phi_f = din.i_adc_gain_f;         
                din.i_adc_gain_a.v = [];
                din.i_adc_phi_a.v = [];
                % digitizer SFDR value:
                din.i_adc_sfdr_a.v = [];
                din.i_adc_sfdr_f.v = [];
                din.i_adc_sfdr.v = -log10(chns{2}.sfdr)*20;
                % create some corretion table for the digitizer phase: 
                [din.i_lo_adc_gain_f,din.i_lo_adc_gain,din.i_lo_adc_phi] ...
                  = gen_adc_tfer(din.fs.v/2+1,50, linrand(0.95,1.05),0.000002, linrand(-adc_mgain_acdc,+adc_mgain_acdc),0.00005,linrand(0.5,3), ...
                                 0.2*din.fs.v,logrand(0.005,0.03), ...
                                 linrand(-adc_mphi,+adc_mphi),0.00008,0.000002,linrand(0.7,3));
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
                din.i_adc_offset.v = linrand(-0.005,0.005);
                din.i_adc_offset.u = 0.0001;
                din.i_lo_adc_offset.v = linrand(-0.005,0.005);
                din.i_lo_adc_offset.u = 0.0001;
                % create some corretion table for the transducer gain/phase: 
                [din.i_tr_gain_f,din.i_tr_gain,din.i_tr_phi] ...
                  = gen_adc_tfer(din.fs.v/2+1,50, I_rng,0.000002*I_rng, linrand(-tr_mgain_acdc,+tr_mgain_acdc),0.000050,linrand(0.5,3), ...
                                 linrand(0.1,0.25)*din.fs.v,0.005, ...
                                 linrand(-tr_mphi,+tr_mphi),0.000080,0.000002,linrand(0.7,3));
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
            par{pn}.mc_setup_runs = mc_setup_runs;
                           
        end
    
    end
        
    if is_full_val > 0
        % --- FULL VALIDATION MODE ---
        
        fprintf('Processing test setups...\n');

        % -- processing start:
        res = runmulticore(mc_setup.method,@proc_pwrfft_test,par,mc_setup.cores,mc_setup.share_fld,2,mc_setup);
               
        % store results:
        save(val_path,'-v7','res','simcom','vr');
        
        qwtb('TWM-PWRFFT','addpath');
        
        % print results:
        valid_report(res,vr);
        
    else
        % --- SINGLE VALIDATION MODE ---
        
        if is_full_val < 0
            % load setup from previous validation report:
            
            
            % try to reload last result from temp:
            tmp_res_path = [fileparts(mfilename('fullpath')) filesep 'lastres_temp.mat'];
            try
                tmp = load(tmp_res_path,'tmp','val_path','is_full_val');                
                res = tmp.tmp{1};
                if ~strcmp(tmp.val_path,val_path) || tmp.is_full_val ~= is_full_val
                    error('not the same results set!');
                end
                fprintf('Loading result #%d from temp...\n',-is_full_val);
            catch
                % failed, we will reload it from full set (slow):
                fprintf('Loading result #%d from full results set (wait)...\n',-is_full_val);                
                res = load(val_path,'res');
                res = res.res{-is_full_val};                 
            end
            par = res.par;
            
            % save the selected result to temp to speedup future reloading:
            tmp = {res};
            save(tmp_res_path,'tmp','val_path','is_full_val');
            
            
            din = par.din;
            cfg = par.cfg;
            %calcset = par.calcset;
            rand_unc = par.rand_unc;           
            calcset.dbg_plots = 1;
            
        end
        
        if is_full_val <= 0
            f0 = cfg.chn{1}.fx(1);
            fprintf('N = %.0f samples\n',cfg.N);
            fprintf('fs = %0.4f Hz\n',din.fs.v);
            fprintf('f0 = %0.4f Hz\n',f0);
            fprintf('f0 periods = %0.2f\n',(cfg.N/din.fs.v)*f0);
            fprintf('fs/f0 ratio = %0.2f\n',din.fs.v/f0);
            fprintf('Harmonics = %s\n',sprintf('%.3g ',sort([cfg.chn{1}.fx/f0])));
            fprintf('AC coupling = %.0f\n',din.ac_coupling.v);
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
        dout = qwtb('TWM-PWRFFT',datain,calcset);
        
        
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
   