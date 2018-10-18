function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-MODTDPS.
%
% See also qwtb

    % testing mode {0: single test, ? >= 1: N repeated tests, ? < 0: repeat particular test from previous test setups}:
    is_full_val = 5000;
    
    % maximum number of test repetitions per test setup (includes retries when alg. returns error):
    val.max_count = 300;
    % minimum number of test repetitions per test setup:
    val.min_count = 200;
    % print debug lines:
    val.dbg_print = 1;
    % resutls path:
    val_path = [fileparts(mfilename('fullpath')) filesep 'modtdps_val_sgl3.mat'];
    
    
    % --- test execution setup ---
    % parallel instances (use 0 to not start servers, user must run them manually):
    par_cores = 0;
    
    % parallel execution mode (QWTB naming convence) {'singlecore', 'multicore', 'multistation'}:
    par_mode = 'multistation';
    
    % 'multistation' mode jobs sharing folder:
    if ispc
        % windoze:
        par_mc_folder = 'g:\work\_mc_jobs_';
        if ~exist(par_mc_folder,'file')
            par_mc_folder = 'f:\work\_mc_jobs_';
        end        
    else
        % linux:
        par_mc_folder = 'mc_rubbish_m';        
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
        mc_setup.max_chunk_count = 500;
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
    mc_setup.method = par_mode_qwtb2mc(par_mode);

      

    % --- calculation setup:
    calcset.verbose = (is_full_val <= 0);
    calcset.unc = 'guf';
    calcset.loc = 0.95;
    % no QWTB input checking:
    calcset.checkinputs = 0;
    % faster mode - uncertainty LUTs are stored in globals to prevent repeated file access (for validation on supercomp. only):
    calcset.fetch_luts = (is_full_val > 0);
    
    % calculation modes:
    a_modes =  {struct('wshape','sine', 'corr',1),
                struct('wshape','sine', 'corr',0),
                struct('wshape','rect', 'corr',0)};
    
    if is_full_val > 0
        % --- full validation mode ---
    
        % -- test setup combinations:      
        % randomize corrections uncertainty:
        com.rand_unc = [0];
        %com.rand_unc = [0];
        % calculation mode (see above):
        com.mode = [1 2 3];
        %com.mode = [1];
    
        % generate all test setup combinations:
        [vr,com] = var_init(com);
        simcom = var_get_all_fast(com,vr,5000,1);        
    else        
        % --- single test mode ---
        simcom = {struct()};
        
        % randomize corrections uncertainty:
        simcom{1}.rand_unc = 1;
        % calculation mode (see above): 
        simcom{1}.mode = 1; 
    end
    
    
    % --- single axis variation:    
    sens.par.fs = 10000;
    sens.par.N = 2*12345;
    sens.par.f0 = 53;
    sens.par.modd = 0.5;
    sens.par.fmod = 0.1;
    sens.qu = 'modd';
    sens.lbl = 'Am/A0';
    sens.ax = logspace(log10(0.05),log10(0.95),20);
    %sens.ax = logspace(log10(sens.par.fs/sens.par.N*3.01/sens.par.f0),log10(0.32),15);
    sens.ax_scale = 'log';    
    sens.enab = 0;
    %sens.ax
        

    % --- FOR EACH TEST SETUP GROUP: ---
    if sens.enab
        % override test setups count if single axis variation enabled: 
        is_full_val = numel(sens.ax);
    end
    if is_full_val
        fprintf('Generating test setups...\n');
    end
    par = {};
    pn = 0;
    simcom_num = numel(simcom);
    for c = 1:simcom_num
    
        % --- FOR EACH VALIDATION TEST: ---
        val_num = max(1,is_full_val);
        for v = 1:val_num
            
            din = struct();
            
            % calculation mode struct:
            mode = a_modes{simcom{c}.mode};       
            
            % samples to synthesize:
            if sens.enab && isfield(sens.par,'N')
                N = sens.par.N;
            else
                N = round(logrand(3000,100000));
            end
            
            % sampling rate:
            %  note: randomize in small range, no need for full range testing, because all other parameters are relative to this
            if sens.enab && isfield(sens.par,'fs')
                fs = sens.par.fs;
            else
                fs = logrand(9000,11000);
            end
            
            % input voltage range:
            U_rng = logrand(5,70);
            
            % carrier:
            if sens.enab && isfield(sens.par,'f0')
                f0 = sens.par.f0;
            else
                f0 = rounddig(logrand(50,fs/10),4);
            end
            % carrier amplitude:
            A0 = rounddig(logrand(0.1,1)*U_rng,3);
            
            % maximum modulating/carrier freq. ratio:
            if strcmpi(mode.wshape,'sine')
                fmf0_rat_max = 0.32; % for sine
            else
                fmf0_rat_max = 0.24; % for rect
            end                               
                
            % modulating signal frequency:    
            if sens.enab && strcmpi(sens.qu,'fmod')
                fm = sens.ax(v)*f0;
            elseif sens.enab && isfield(sens.par,'fmod')
                fm = f0*sens.par.fmod;
            else
                fm = rounddig(logrand(3/(N/fs),fmf0_rat_max*f0),4);
            end
            % modulating signal amplitude:            
            if sens.enab && strcmpi(sens.qu,'modd')
                modd = sens.ax(v);
            elseif sens.enab && isfield(sens.par,'modd')
                modd = sens.par.modd;                
            else
                modd = rounddig(logrand(0.02,0.98),3);
            end
            Am = A0*modd;    
            % modulating signal phase [rad]: 
            phm = rand(1)*2*pi; % random phase
            % modulating signal shape: 
            wshape = mode.wshape;
            
            % DC component:
            dc = linrand(-0.02,0.02)*A0;
            
            % digitizer std noise:    
            adc_std_noise = logrand(1e-6,50e-6);
            
            % digitizer jitter:
            jitter = logrand(1e-9,100e-9);
            
            % enable algorithm self-compensation?
            din.comp_err.v = mode.corr;
            
            % randomize correctio uncertainties?
            rand_unc = simcom{c}.rand_unc;
            
            % uncomment to enable differential sensor connection?
            %  note: this is an additional loop impedance of the differential sensor
            %Zx = 10;
            
            
            % -- SFDR harmonics/interharmonics generator:
            % max spurr amplitude relative to fundamental [-]:
            sfdr = logrand(10e-6,0.001);
            % harmonics count:
            sfdr_hn = 10;
            % randomize amplitude (zero to sfdr-level)?
            sfdr_rand = 1;
            % randomize frequency (relative to f0)?
            sfdr_rand_f = 0.1;
            
        
            % store some input quantities:
            din.fs.v = fs;    
            din.wave_shape.v = wshape;
                
            % store correction data:
            if true

                % maximum digitizer interchannel time shift expressed as phase shift at nyquist frequency [rad]: 
                max_chn2chn_phi   = 0.1;
                max_chn2chn_td   = max_chn2chn_phi/(2*pi*0.5*din.fs.v); % expressed as delay
                max_chn2chn_td_u = 20e-9;
                
                % maximum change of gain of digitizer from DC to AC at fs/2 [-]:
                adc_mgain_acdc = 0.01; 
                % maximum phase error of digitizer [rad]:
                adc_mphi = 0.001;
                % maximum change of gain of transducer from DC to AC at fs/2 [-]:
                tr_mgain_acdc = 0.02;
                % maximum phase error of transducer [rad]:
                tr_mphi = 0.001;
                
                % create some corretion table for the digitizer gain:                 
                gain_unc = logrand(5e-6,50e-6);
                [din.adc_gain_f,din.adc_gain,din.adc_phi] ...
                  = gen_adc_tfer(din.fs.v/2+1,linrand(30,50), linrand(0.95,1.05),gain_unc, ... % f_max, n_steps, nom_gain, nom_gain_unc
                                 linrand(-adc_mgain_acdc,+adc_mgain_acdc),gain_unc*logrand(1,5),linrand(0.5,3), ... % ac-dc [-], max_unc [-], shape (power)
                                 0.2*din.fs.v,logrand(0.005,0.03), ... % ripple period [Hz], ripple amplitude [dB] 
                                 linrand(-adc_mphi,+adc_mphi),0.00008,0.000002,linrand(0.7,3)); % phi_at_fs/2, max_phi_unc, min_phi_unc, shape (power)
                din.adc_phi_f = din.adc_gain_f;         
                din.adc_gain_a.v = [];
                din.adc_phi_a.v = [];               
                % create some corretion table for the digitizer gain: 
                din.lo_adc_gain_f = din.adc_gain_f;
                din.lo_adc_gain_a = din.adc_gain_a;
                din.lo_adc_gain = din.adc_gain; 
                % create some corretion table for the digitizer phase: 
                din.lo_adc_phi_f = din.adc_phi_f;
                din.lo_adc_phi_a = din.adc_phi_a;
                din.lo_adc_phi = din.adc_phi;
                % generate some ADC sfdr:
                w_sfdr = linrand(0.1,0.9);
                din.adc_sfdr_a.v = [];
                din.adc_sfdr_f.v = [];
                din.adc_sfdr.v = -log10(sfdr*w_sfdr)*20;
                din.lo_adc_sfdr_a = din.adc_sfdr_a;
                din.lo_adc_sfdr_f = din.adc_sfdr_f;
                din.lo_adc_sfdr = din.adc_sfdr;
                % create corretion of the digitizer timebase:
                din.adc_freq.v = linrand(-0.000100,0.000100);
                din.adc_freq.u = 0.000005;
                % create ADC offset voltages:
                din.adc_offset.v = linrand(-0.002,0.002);
                din.adc_offset.u = 0.0001;
                din.lo_adc_offset.v = linrand(-0.002,0.002);
                din.lo_adc_offset.u = 0.0001;  
                % define some low-side channel timeshift:
                din.time_shift_lo.v = linrand(-1,1)*max_chn2chn_td;
                din.time_shift_lo.u = logrand(0.1,1)*max_chn2chn_td_u;
                % digitizer resolution:
                din.adc_bits.v = linrand(16,28);
                din.adc_nrng.v = 1; % nominal range +-1V                
                % ADC aperture correction:
                din.adc_aper_corr.v = 1; % state always on
                din.adc_aper.v = logrand(1e-6,100e-6); % aperture value
                
                
                % transducer type:
                ttypz = {'rvd','shunt'};
                din.tr_type.v = ttypz{(rand > 0.5) + 1};        
                % create some corretion table for the transducer gain: 
                gain_unc = logrand(5e-6,50e-6);
                [din.tr_gain_f,din.tr_gain,din.tr_phi] ...
                  = gen_adc_tfer(din.fs.v/2+1,linrand(30,50), U_rng,gain_unc*U_rng, ... % f_max, n_steps, nom_gain, nom_gain_unc
                                 linrand(-tr_mgain_acdc,+tr_mgain_acdc),gain_unc*logrand(1,5),linrand(0.5,3), ... % ac-dc [-], max_unc [-], shape (power)
                                 linrand(0.1,0.25)*din.fs.v,0.005, ... % ripple period [Hz], ripple amplitude [dB]
                                 linrand(-tr_mphi,+tr_mphi),0.000080,0.000002,linrand(0.7,3)); % phi_at_fs/2, max_phi_unc, min_phi_unc, shape (power)
                din.tr_phi_f = din.tr_gain_f;
                din.tr_gain_a.v = [];
                din.tr_phi_a.v = [];
                % transducer SFDR:
                din.tr_sfdr.v = -log10(sfdr*(1-w_sfdr))*20;
                din.tr_sfdr_f.v = [];
                din.tr_sfdr_a.v = [];                
                % RVD transducer low-side impedance:
                din.tr_Zlo_f.v  = [];
                din.tr_Zlo_Rp.v = [200];
                din.tr_Zlo_Cp.v = [1e-12];        
                din.tr_Zlo_Rp.u = [1e-6];
                din.tr_Zlo_Cp.u = [1e-12];    
            
            end                  
        
            % generate the signal:
            cfg.N = N; % samples count
            cfg.f0 = f0; % carrier frequency
            cfg.A0 = A0; % carrier amplitude
            cfg.fm = fm; % modulating frequency
            cfg.Am = Am; % modulating amplitude    
            cfg.phm = phm; % modulating phase
            cfg.wshape = wshape; 
            cfg.dc = dc; % dc offset
            cfg.sfdr = sfdr; % sfdr max amplitude
            cfg.sfdr_hn = sfdr_hn; % sfdr max harmonics count
            cfg.sfdr_rand = sfdr_rand; % randomize sfdr amplitudes?
            cfg.sfdr_rand_f = sfdr_rand_f; % randomize sfdr frequency?
            cfg.adc_std_noise = adc_std_noise; % ADC noise level  
            if exist('Zx','var')
                cfg.Zx = Zx; % differential mode enabled 
            end
                        
            if sens.enab && (v > 1)
                % - single axis variation:
                
                % temp config:
                cfg_t = cfg;
                
                % restore first set:                 
                din = par{pn_first}.din;
                cfg = par{pn_first}.cfg;
                % override the single axis, so everything but the axis stays constant:
                if strcmpi(sens.qu,'fmod')
                    cfg.fm = cfg_t.fm;    
                elseif strcmpi(sens.qu,'modd')
                    cfg.Am = cfg_t.Am;
                end
            end
            
            % store test setup:
            pn = pn + 1;
            par{pn}.rand_unc = rand_unc;
            par{pn}.cfg = cfg;
            par{pn}.din = din;
            par{pn}.val = val;
            par{pn}.simcom = simcom{c};
            par{pn}.calcset = calcset;
            if v == 1
                pn_first = pn; % store first test setup ID    
            end
            
        end % test setups loop
        
    end % combinations loop           
            
    
    
    if is_full_val > 0
        % --- FULL VALIDATION MODE ---
        
        fprintf('Processing test setups...\n');

        % -- processing start:
        res = runmulticore(mc_setup.method, @proc_modtdps_test, par, mc_setup.cores, mc_setup.share_fld, 2, mc_setup);
               
        % store results:
        save(val_path,'-v7','res','simcom','vr','sens');
        
        % restore path (###todo: should be removed when QWTB works correctly)
        qwtb('TWM-MODTDPS','addpath');
        
        % print results:
        if sens.enab
            % - single axis validation:
            valid_report(val_path);
        else
            % - random validation:   
            valid_report(res,vr);
        end
        
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
                disp(' - loading from temp result');
            catch
                % failed, we will reload it from full set (slow):
                disp(' - loading from full results set (wait)');                
                res = load(val_path,'res');
                res = res.res{-is_full_val};                 
            end
            par = res.par;
            
            % save the selected result to temp to speedup future reloading:
            tmp = {res};
            save(tmp_res_path,'tmp','val_path','is_full_val');
            
            rand_unc = par.rand_unc;
            din = par.din;
            cfg = par.cfg;
            
            %cfg.fm += 1;
            %cfg.f0 += 1;
            %cfg.N /= 2;
            %din.fs.v /= 2;
            
%             din.tr_gain.v = din.tr_gain.v(1);
%             din.tr_gain.u = din.tr_gain.u(1);
%             din.tr_gain_a.v = [];
%             din.tr_gain_f.v = [];            
%             din.adc_gain.v = din.adc_gain.v(1);
%             din.adc_gain.u = din.adc_gain.u(1);
%             din.adc_gain_a.v = [];
%             din.adc_gain_f.v = [];
%             din.tr_phi.v = 0;
%             din.tr_phi.u = 0;
%             din.tr_phi_a.v = [];
%             din.tr_phi_f.v = [];
%             din.adc_phi.v = 0;
%             din.adc_phi.u = 0;
%             din.adc_phi_a.v = [];
%             din.adc_phi_f.v = [];
            %din.adc_aper.v = 1e-3;

            
            tset = calcset;
            calcset = par.calcset;
            calcset.verbose = tset.verbose;            
                        
        end
        
        % print some header with test setup info:
        if is_full_val <= 0            
            fprintf('samples count = %g\n', cfg.N);
            fprintf('sampling rate = %.7g kSa/s\n', 0.001*din.fs.v);
            fprintf('fundamental frequency = %.7g Hz\n', cfg.f0);
            fprintf('modulating periods = %.7g\n', (cfg.N/din.fs.v)*cfg.fm);
            fprintf('fundamental samples per period = %.7g\n', din.fs.v/cfg.f0);
            fprintf('modulation to carrier frequency ratio = %.5g\n', cfg.fm/cfg.f0);
            fprintf('\n');
        end
        
        % --- synthesize the signal:    
        datain = gen_mod(din, cfg, rand_unc);
        
        % --- execute the algorithm:
        dout = qwtb('TWM-MODTDPS',datain,calcset);
        
        
        % get calculated values:
        A0x   = dout.A0.v;   
        u_A0x = dout.A0.u;    
        Amx   = dout.A_mod.v;   
        u_Amx = dout.A_mod.u;    
        modx   = dout.mod.v;   
        u_modx = dout.mod.u;    
        f0x   = dout.f0.v;
        u_f0x = dout.f0.u;    
        fmx   = dout.f_mod.v;
        u_fmx = dout.f_mod.u;
        %ofsx   = dout.dc.v;
        %u_ofsx = inf;
        
        % prepare reference values:
        modr = 100*cfg.Am/cfg.A0;
        
        % prepare list of quantities to print:
        r_list = [cfg.A0 cfg.Am modr cfg.f0 cfg.fm];
        x_list = [A0x   Amx   modx   f0x   fmx];
        u_list = [u_A0x u_Amx u_modx u_f0x u_fmx];
        un_list = {'V','V','%','Hz','Hz'};
        fmt_list = {'si','si','f','si','si'};
        n_list = {'A0','Am','mod','f0','fm'};
            
        
        % print results table:
        fprintf('\n------------+-------------+----------------------------+-------------+---------\n');
        fprintf('    NAME    |     REF     |     CALC +- UNCERTAINTY    |     DEV     | %%-UNC\n');
        fprintf('------------+-------------+----------------------------+-------------+---------\n');
        for k = 1:numel(n_list)
        
    %         if strcmpi(fmt_list{k},'si')
    %             [ss,sv,su,sn] = unc2str_si(x_list(k),u_list(k),un_list{k});
    %             [ss,dv,ss,sn] = unc2str_si(x_list(k)-r_list(k),u_list(k),un_list{k});
    %             [ss,rv,ss,sn] = unc2str_si(r_list(k),u_list(k),un_list{k});
    %             sn = ['[' sn ']'];
    %         else
                [ss,sv,su] = unc2str(x_list(k),u_list(k));
                [ss,dv] = unc2str(x_list(k)-r_list(k),u_list(k));
                [ss,rv] = unc2str(r_list(k),u_list(k));
                sn = ['[' un_list{k} ']'];
    %        end
            fprintf('%5s %-5s | %11s | %11s +- %-11s | %11s | %+3.0f\n',n_list{k},sn,rv,sv,su,dv,(x_list(k)-r_list(k))/u_list(k)*100);
                
        end
        fprintf('------------+-------------+----------------------------+-------------+---------\n\n');
    
    end
       
    
end

function [rnd] = logrand(A_min,A_max)
    rnd = 10.^(log10(A_min) + (log10(A_max) - log10(A_min))*rand());
end

function [rnd] = linrand(A_min,A_max,N)
    if nargin < 3
        N = [1 1];
    end
    if size(N) < 2
        sz = [N 1];
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
   
   