function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-THDWFFT.
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
    val.max_count = 100;
    % resutls path:
    val_path = [fileparts(mfilename('fullpath')) filesep 'thdwfft_val_v1.mat'];
    
    
    
    % --- Test function multicore setup:    
    % note: This is execution of the algorithm test, not execution mode if the algorithm itself!
    %       Do not use multicore processing here and for the algorithm uncertainty at once!  
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
        mc_setup.share_fld = 'c:\work\_mc_jobs_'; 
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
        % set supercomputer process affinity:
        mc_setup.run_after_slaves = @coklbind2;
    end
     
    
    
    % calculation setup:
    calcset.verbose = (~is_full_val);
    calcset.unc = 'guf';
    calcset.loc = 0.95;
    % no QWTB input checking:
    calcset.checkinputs = 0;
    calcset.cor.req = 0; calcset.cor.gen = 0; calcset.dof.req = 0; calcset.dof.gen = 0; 



    if is_full_val
        % --- full test mode ---
        % generating multiple combinations of simulation/testing setup
        
        % add variation lib:
        addpath([fileparts(mfilename('fullpath')) filesep 'var']);
    
        % -- test setup combinations:        
        % randomize corrections uncertainty:
        com.rand_unc = [0 1];
        % randomize corrections uncertainty:
        com.scallop_fix = [0 1];
            
        % generate all test setup combinations:
        [vr,com] = var_init(com);
        simcom = var_get_all_fast(com,vr,5000,1);        
    
    else
        % --- single test mode ---       
        simcom = {struct()};
        
        simcom{1}.rand_unc = 1;
        simcom{1}.scallop_fix = 0;        
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

    
            % maximum frequency of component relative to fs:
            nyqlim = 0.4;
            
            % desired sampling rate:
            %  note: no need to randomize in wide range, because all other parameters are relatie to fs and randomized    
            fs = logrand(30e3,70e3);
            
            % nominal input range (input of transducer):
            input_range = logrand(0.1,100);
            
            % total SFDR:
            if simcom{c}.rand_unc
                sfdr = 10^(-linrand(80,140)/20);
            else
                sfdr = 1e-7;
            end
            
            
            % --- correction data ---
        
            % clear corrections:
            din = struct();
        
            % note: gain tfers have intendedly large uncertainty so it is visible in the total budget of the algorithm!
            % create some corretion table for the digitizer gain: 
            [din.adc_gain_f,din.adc_gain] ...
              = gen_adc_tfer(fs/2+1,50, linrand(0.95,1.05),0.000050, linrand(-0.05,+0.05),0.000100 ,linrand(0.5,3) ,0.2*fs,0.03, ...
                             linrand(-0.001,+0.001),0.00008,0.000002,linrand(0.7,3));
            din.adc_gain_a.v = [];    
            % generate some transducer gain transfer:
            [din.tr_gain_f,din.tr_gain] ...
              = gen_adc_tfer(fs/2+1,50, input_range,0.000050, linrand(-0.05,+0.05),0.000100 ,linrand(0.5,3) ,0.2*fs,0.03, ...
                             linrand(-0.001,+0.001),0.00008,0.000002,linrand(0.7,3));
            din.tr_gain_a.v = [];
            
            % note: split SFDR somehow between digitizer and transducer 
            % generate some SFDR values for digitizer:
            sfdr_wg = linrand(0.1,0.9);
            din.adc_sfdr.v =   -log10(sfdr_wg*sfdr)*20;
            din.adc_sfdr_f.v = [];
            din.adc_sfdr_a.v = [];    
            % generate some SFDR values for transducer:
            din.tr_sfdr.v =   -log10((1-sfdr_wg)*sfdr)*20;
            din.tr_sfdr_f.v = [];
            din.tr_sfdr_a.v = [];

            % nominal low-side impedance of RVD:
            din.tr_Zlo_f.v  = [];
            din.tr_Zlo_Rp.v = [200];
            din.tr_Zlo_Cp.v = [1e-12];        
            din.tr_Zlo_Rp.u = [0e-6];
            din.tr_Zlo_Cp.u = [0e-12];
            
            % transducer type:
            trt = {'shunt','rvd'};
            din.tr_type.v = trt(round(linrand(1,2)));
            
            % fake some digitizer parameters:
            din.adc_nrng.v = 1.0; % +/- range
            din.adc_bits.v = logrand(16,28);  % bit resolution
            
            
            % these are used just for convenient use of the correction data:
            %   Restore orientations of the input vectors to originals (before passing via QWTB)
            din.y.v = ones(3,1); % fake data vector just to make following function work!
            [din,scfg] = qwtb_restore_twm_input_dims(din,1);
            %   Rebuild TWM style correction tables (just for more convenient calculations):
            tab = qwtb_restore_correction_tables(din,scfg);
                
            
            % --- algorithm setup ---
            % plot spectrum?
            din.plot.v = 0;
            % harmonics count to analyze:
            din.H.v = linrand(5,10);
            % verbose mode:
            din.verbose.v = (~is_full_val);
            % initial guess of the fundamental frequency (comment if autodetect needed)
            %cfg.f0.v = 1e3;
            % fix scalloping error?
            din.scallop_fix.v = simcom{c}.scallop_fix;
            % maximum bandwidth to analyze (comment if not limited):
            %cfg.band.v = 100e3;
            % fundamental frequency search mode (comment for default):
            din.f0_mode.v = 'psfe';
                
            
            
            % --- THD waveform simulator setup ---
            
            % minimum allowed DFT bins between harmonics:
            min_dft_bins = 30;
            
        
            % samples count:
            N = round(logrand(0.3,5)*fs);
            sim.sample_count = N;
            % rms sampling jitter [s]:
            sim.t_jitter = logrand(1e-9,100e-9);
            % sampling rate [Hz]:
            sim.fs = fs;
            sim.fs_unc = 0; % sampling freq. uncertainty
            % fundamental freq [Hz]:
            f0_max = nyqlim*fs/din.H.v;
            f0_min = fs/N*min_dft_bins;
            if f0_max < f0_min
                error('Sampling setup wrong! Cannot synthesize waveform with at least 30 DFT bins between harmonics.');
            end    
            sim.f0 = logrand(f0_min,f0_max);        
            % repeated measurements (averages) count:
            sim.avg_count = 10;
            % fundamental amplitude [V]:
            sim.A0 = logrand(0.1,0.9)*input_range;
            % --- to generate (select one method):
                % 1) desired THD (fundamental referenced) 
                %sim.k1 = 0.005; %logspace(log10(0.0001),log10(10),50);
                % 2) or fixed harmonics, identical amplitudes [V]
                %sim.A = 0.1; %logspace(log10(1e-7),log10(1e-5),20);
                % 3) or random amplitudes in logspace, range from-to [V]
                sim.A_min = 1e-6;
                sim.A_max = sim.A0*logrand(100e-6,0.1);
            % harmonics count to generate (including fundamental):
            sim.H = din.H.v;
            % ADC rms noise [V]:
            sim.adc_noise_lev = logrand(1e-6,50e-6);
            sim.adc_noise_bw = nyqlim*sim.fs; % noise level related to this bw
            % enable randomization of quantities with uncertainties (to simulate uncertainty):
            %   note: disabling this will also ignore SFDR errors, jitter
            sim.randomize = simcom{c}.rand_unc;
            % copy algorithm input quantities to the simulator's structure:
            sim.corr = din;
            sim.tab = tab;
            
            % store test setup to the list:
            pn = pn + 1;
            par{pn}.din = din;
            par{pn}.calcset = calcset;
            par{pn}.sim = sim;
            par{pn}.simcom = simcom{c};
            par{pn}.val = val;
                
            if ~is_full_val
                fprintf('N = %.0f samples\n',N);
                fprintf('fs = %0.4f Hz\n',fs);
                fprintf('f0 = %0.4f Hz\n',sim.f0);
                fprintf('Harmonic stepping = %0.2f DFT bins\n\n',sim.f0/fs*N);
            end
            
        end
    
    end    
    
    
    
    if is_full_val
        % --- FULL VALIDATION MODE ---
        
        fprintf('Processing test setups...\n');
        
        % -- processing start:
        res = runmulticore(mc_setup.method,@proc_thdwfft_test,par,mc_setup.cores,mc_setup.share_fld,2,mc_setup);
        
        % ### to be removed when qwtb does not destroy paths
        qwtb('TWM-THDWFFT','addpath');
        
        % store results:
        save(val_path,'-v6','res','simcom','vr');
        
        % print results:
        valid_report(res,vr);
        
    else
        % --- SINGLE VALIDATION MODE ---
    
    
        % --- simulate waveforms ---
        [sig,fs_out,k1_out,h_amps] = thd_sim_wave(sim);
        
        % store simulated waveform data:
        din.y.v = sig;
        din.fs.v = fs_out;
        
        
        % --- calculate THD ---
        dout = qwtb('TWM-THDWFFT',din,calcset);
        
        
        % print results:
        fprintf('\nResults:\n');
        fprintf('  THD ref: %0.4f%%, calc: %0.4f%% +- %0.4f%%, dev: %0.4f%%, %%-of-spec: %-3.0f\n', k1_out, dout.thd.v, dout.thd.u, dout.thd.v - k1_out, abs(dout.thd.v - k1_out)/dout.thd.u*100);
        fprintf('\nHarmonics:\n');
        fprintf(    '  ID    REF         CALC                     DIFF         %%-OF-UNC\n');
        for h = 1:dout.H.v
            fprintf('  H%02d:  %0.7f   %0.7f +- %0.7f   %+0.7f   %-3.0f\n', h, h_amps(h), dout.h.v(h), dout.h.u(h), dout.h.v(h) - h_amps(h), abs(dout.h.v(h) - h_amps(h))/dout.h.u(h)*100);
        end   
        
        % check result correctness:
        assert(any(abs(dout.h.v - h_amps) < dout.h.u), 'Calculated harmonic amplitudes out of calculated uncertainty!');
        assert(abs(dout.thd.v - k1_out) < dout.thd.u, 'Calculated THD out of calculated uncertainty!');
    
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
   