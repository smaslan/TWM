function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-WFFT.
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
    %val.fast_mode = 0; % ###note: note implemented
    % maximum number of test repetitions per test setup:
    val.max_count = 500;
    % minimum number of test repetitions per test setup (this has priority over timeout):
    val.min_count = 100;
    % test run total timeout (max allowed time for all 'max_count' iteration) [s]:
    val.timeout = 30*60;
    % print debug lines:
    val.dbg_print = 1;
    % resutls path:
    val_path = [fileparts(mfilename('fullpath')) filesep 'wfft_val_guf1.mat'];
    
    
    % --- test execution setup ---
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
        com.rand_unc = [0];
        %com.rand_unc = [1];
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
            din.adc_aper_corr.v = 1;
            din.lo_adc_aper_corr = din.adc_aper_corr;
            
            % bit resolution limits:
            bits_min = 16;
            bits_max = 28; 
            
            % select processing window:
            din.window.v = 'flattop_144D';
               
            
            % samples count to synthesize:
            %N = 13528;
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
            
            % round to coherent:
            f0 = round(N/din.fs.v*f0)/N*din.fs.v;
            
            % store nominal frequency parameter:
            din.f_nom.v = f0;
                    
            
            % ADC aperture [s]:
            din.adc_aper.v = logrand(1e-9,10e-6);
                
            % ADC jitter [s]:
            din.adc_jitt.v = logrand(1e-9,100e-9);
            din.lo_adc_jitt.v = din.adc_jitt.v;
          
                
            % nominal range:
            A_rng = logrand(0.1,10);
            A_max = 0.7*A_rng; % max aplitude to generate
            
            
            
            % ADC RMS noise [V]:
            adc_noise = logrand(1e-6,10e-6);
            
            % ADC SFDR value unitless [-]:
            adc_sfdr = logrand(1e-6,100e-6);    
            
            % fundamental periods in the record:
            f0_per = f0*N/din.fs.v;
                
            % samples per period of fundamental:
            fs_rat = din.fs.v/f0;
            
            % harmonic components to generate:
            f_harm = [1:round(linrand(2,5))];   
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
            
            
            % generate some timestamp:
            din.time_stamp.v = rand;
                
            
            chns = {}; id = 0;    
               
            % -- signal parameters:
            id = id + 1;
            % channel parameters:
            chns{id}.name = 'y';
            tr_type = {'shunt','rvd'};
            tr_type = tr_type{1 + (rand > 0.5)};
            tr_type = 'shunt';
            chns{id}.type = tr_type;
            % harmonic amplitudes:
            A0 = logrand(0.1,1)*A_max;
            chns{id}.A = A0*[1     logrand(0.01,0.1,[1 n_harm-1]) logrand(0.000001,0.0001)]';
            % harmonic phases:
            chns{id}.ph =   [0     linrand(-0.9,0.9,[1 n_harm-1]) rand*2]'*pi;
            % harmonic component frequencies:
            chns{id}.fx = f0*[f_harm f_iharm]';
            % DC component:
            chns{id}.dc = linrand(-1,1)*0.05*A0;
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
            %chns{id+1} = chns{id}; % fake secondary channel
            
            % put all harmonics to analysed list:
            din.h_num.v = f_harm;
        
                
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
                din.tr_Zlo_f.v  = [];
                din.tr_Zlo_Rp.v = [200];
                din.tr_Zlo_Cp.v = [1e-12];        
                din.tr_Zlo_Rp.u = [0e-6];
                din.tr_Zlo_Cp.u = [0e-12];
                % create some corretion table for the digitizer gain/phase: 
                [din.adc_gain_f,din.adc_gain,din.adc_phi] ...
                  = gen_adc_tfer(din.fs.v/2+1,50, linrand(0.95,1.05),0.000002, linrand(-adc_mgain_acdc,+adc_mgain_acdc),0.00005,linrand(0.5,3), ...
                                 0.2*din.fs.v,logrand(0.005,0.03), ...
                                 linrand(-adc_mphi,+adc_mphi),0.00008,0.000002,linrand(0.7,3));
                din.adc_phi_f = din.adc_gain_f;         
                din.adc_gain_a.v = [];
                din.adc_phi_a.v = [];
                % digitizer SFDR value:
                din.adc_sfdr_a.v = [];
                din.adc_sfdr_f.v = [];
                din.adc_sfdr.v = -log10(chns{1}.sfdr)*20;
                % create identical low-side channel:
                [din.lo_adc_gain_f,din.lo_adc_gain,din.lo_adc_phi] ...
                  = gen_adc_tfer(din.fs.v/2+1,50, linrand(0.95,1.05),0.000002, linrand(-adc_mgain_acdc,+adc_mgain_acdc),0.00005,linrand(0.5,3), ...
                                 0.2*din.fs.v,logrand(0.005,0.03), ...
                                 linrand(-adc_mphi,+adc_mphi),0.00008,0.000002,linrand(0.7,3));
                din.lo_adc_phi_f = din.lo_adc_gain_f;         
                din.lo_adc_gain_a.v = [];
                din.lo_adc_phi_a.v = [];
                % digitizer SFDR value (low-side):
                din.lo_adc_sfdr_a.v = din.adc_sfdr_a.v;
                din.lo_adc_sfdr_f.v = din.adc_sfdr_f.v;
                din.lo_adc_sfdr.v = din.adc_sfdr.v;
                % digitizer resolution:
                din.adc_bits.v = linrand(bits_min,bits_max);
                din.adc_nrng.v = 1;
                din.lo_adc_bits.v = linrand(bits_min,bits_max);
                din.lo_adc_nrng.v = 1;
                % digitizer offset:
                din.adc_offset.v = linrand(-0.005,0.005);
                din.adc_offset.u = 0.0001;
                din.lo_adc_offset.v = linrand(-0.005,0.005);
                din.lo_adc_offset.u = 0.0001;                
                % create some corretion table for the transducer gain/phase: 
                [din.tr_gain_f,din.tr_gain,din.tr_phi] ...
                  = gen_adc_tfer(din.fs.v/2+1,50, A_rng,0.000002*A_rng, linrand(-tr_mgain_acdc,+tr_mgain_acdc),0.000050,linrand(0.5,3), ...
                                 linrand(0.1,0.25)*din.fs.v,0.005, ...
                                 linrand(-tr_mphi,+tr_mphi),0.000080,0.000002,linrand(0.7,3));                                 
                din.tr_phi_f = din.tr_gain_f;
                din.tr_gain_a.v = [];
                din.tr_phi_a.v = [];         
                % transducer SFDR value:
                din.tr_sfdr_a.v = [];
                din.tr_sfdr_f.v = [];
                din.tr_sfdr.v = [180];
                % transducer type:
                din.tr_type.v = chns{1}.type;
                % differential timeshift:
                din.time_shift_lo.v = linrand(-1,1)*max_chn2chn_td;
                din.time_shift_lo.u = logrand(0.1,1)*max_chn2chn_td_u;
            
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
        res = runmulticore(mc_setup.method,@proc_wfft_test,par,mc_setup.cores,mc_setup.share_fld,2,mc_setup);
               
        % store results:
        save(val_path,'-v7','res','simcom','vr');
        
        qwtb('TWM-WFFT','addpath');
        
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
            %calcset = par.calcset;
            rand_unc = par.rand_unc;
            
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
        dout = qwtb('TWM-WFFT',datain,calcset);
        
        
        % --- plot results:
        
        A_ref = chns{1}.A(1:end-1).';
        ph_ref = chns{id}.ph(1:end-1).';
        H = numel(A_ref);
        
        f_names  = cellfun(@sprintf,repmat({'f%d'},[1,H]),num2cell(round(f_harm)),'UniformOutput',false);
        A_names  = cellfun(@sprintf,repmat({'A%d'},[1,H]),num2cell(round(f_harm)),'UniformOutput',false);
        ph_names = cellfun(@sprintf,repmat({'ph%d'},[1,H]),num2cell(round(f_harm)),'UniformOutput',false);
                                    
        % make list of quantities to display:
        ref_list =  [f0*f_harm,  A_ref,      ph_ref,      simout.rms, chns{1}.dc];
        dut_list =  [dout.f.v.', dout.A.v.', dout.ph.v.', dout.rms.v, dout.dc.v];
        unc_list =  [dout.f.u.', dout.A.u.', dout.ph.u.', dout.rms.u, dout.dc.u];
        name_list = [f_names,    A_names,    ph_names,    {'rms',      'dc'}];
            
        % plot table of results:
        fprintf('\n-----+--------------+------------------------------+--------------+----------+----------+-----------\n');
        fprintf('     |      REF     |         CALC +- UNC          |    ABS DEV   |  DEV [%%] |  UNC [%%] | %%-OF-UNC\n');
        fprintf('-----+--------------+------------------------------+--------------+----------+----------+-----------\n');
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
            
            fprintf('%-4s | %12s | %12s +- %-12s | %12s | %+8.4f | %8.4f | %+3.0f\n',name,rv,sv,su,dv,100*dev/ref,abs(unc/dut)*100,puc);
            
        end
        fprintf('-----+--------------+------------------------------+--------------+----------+----------+-----------\n');
    
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
   