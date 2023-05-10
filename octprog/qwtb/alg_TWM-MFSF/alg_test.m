function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-MFSF.
%
% This is part of the QWTB TWM-MFSF wrapper.
% (c) 2018-2023, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.
%
% See also qwtb

    % --- calculation setup:
    % calculation setup:
    calcset.verbose = 1;
    calcset.dbg_plots = 0;
    % uncertainty mode {'none' - no uncertainty calculation, 'guf' - estimator}
    calcset.unc = 'guf';
    % level of confidence (default 0.68 i.e. k=1):
    calcset.loc = 0.95;
    % MonteCarlo (for 'mcm' uncertainty mode) setup:
    calcset.mcm.repeats = 1000; % cycles
    calcset.mcm.method = 'multistation'; % parallelization mode
    calcset.mcm.procno = 0; % no. of parallel processes (0 to not start slaves)
    %calcset.mcm.user_fun = @coklbind; % user function after servers startup (for CMI's supercomputer)    
    calcset.mcm.tmpdir = 'c:\work\_mc_jobs_'; % jobs sharing folder for 'multistation' mode
    if ~exist(calcset.mcm.tmpdir,'file')
        calcset.mcm.tmpdir = 'f:\work\_mc_jobs_'; % jobs sharing folder for 'multistation' mode
    end
    if ~exist(calcset.mcm.tmpdir,'file')
        calcset.mcm = rmfield(calcset.mcm,'tmpdir');
    end
    % no QWTB input checking:
    calcset.checkinputs = 0;
    
    
    % samples count to synthesize:
    N = 123456;
    %N = round(logrand(1e3,1e4));
    
    % sampling rate [Hz]:
    din.fs.v = 10000;
    
    % number of harmonics to analyze:
    din.H.v = 3; 
    
    % initial guess/method (default not assigned):
    %din.fest.v = 'psfe'; 
    
    % randomize uncertainties:
    %  note: enables randomization of the correction values by their uncertainties
    rand_unc = 0;
    
    % --- these are harmonics to generate:
    % example: [fundamental, 2.harmonic, 3.harmonic, interharmonic]
    % harmonic amplitudes:
    A =  [1       logrand(0.01,0.1)              logrand(0.01,0.1)              0.001]'*logrand(0.1,10);
    % harmonic phases:
    ph = [0.1     rounddig(linrand(-pi,pi),1)    rounddig(linrand(-pi,pi),1)    2*pi*rand]';
    % harmonic periods in the signal (must be: fk < 0.5*N):
    f0_per = logrand(15,0.02*N); % fundamental signal periods count
    fk = [f0_per  2*f0_per                       3*f0_per                       logrand(3.2*f0_per,0.1*N)]';
    
    % dc offset:
    dc = linrand(-0.1,+0.1);
    
    
    
    
        
    % current loop impedance (used for simulation of differential transducer):
    %  note: uncomment to enable differential mode of transducer
    %Zx = 0.1;    
        
    % noise rms level:
    adc_std_noise = 10e-6;
        
    % ADC rms jitter [s]: 
    din.adc_jitter.v = 100e-9;
    
    
    % -- SFDR harmonics generator:
    % max spurr amplitude relative to fundamental [-]:
    sfdr = 100e-6;
    % harmonics count:
    sfdr_hn = 10;
    % randomize amplitude (zero to sfdr-level)?
    sfdr_rand = 1;
            
    
    % ADC aperture [s]:
    % note: non-zero value will simulate aperture gain/phase error 
    din.adc_aper.v = 20e-6;
    
    % ADC aperture correction enabled:
    % note: non-zero value will enable correction of the ADC gain/phase error by alg.
    din.adc_aper_corr.v = 1;
    din.lo_adc_aper_corr.v = 1;    
    
    % generate some time-stamp of the digitizer channel:
    % note: the algorithm must 'unroll' the calculated phase accordingly,
    %       so whatever is put here should have no effect to the estimated phase         
    din.time_stamp.v = rand(1)*0.001; % random time-stamp
    
    % timestamp compensation:
    din.comp_timestamp.v = 1;
        
    % create some corretion table for the digitizer gain: 
    din.adc_gain_f.v = [0;1e3;1e6];
    din.adc_gain_a.v = [];
    din.adc_gain.v = [1.000; 1.100; 1.500];
    din.adc_gain.u = [0.001; 0.002; 0.003]*0.01; 
    % create some corretion table for the digitizer phase: 
    din.adc_phi_f.v = [0;1e3;1e6];
    din.adc_phi_a.v = [];
    din.adc_phi.v = [0.000; 0.100; 0.500]*pi;
    din.adc_phi.u = [0.001; 0.002; 0.005]*pi*0.01;
    % create some low-side corretion table for the digitizer gain: 
%     din.lo_adc_gain_f = din.adc_gain_f;
%     din.lo_adc_gain_a = din.adc_gain_a;
%     din.lo_adc_gain = din.adc_gain;
%     din.lo_adc_gain.v = din.lo_adc_gain.v*1.5; 
    % create some low-side corretion table for the digitizer phase: 
%     din.lo_adc_phi_f = din.adc_phi_f;
%     din.lo_adc_phi_a = din.adc_phi_a;
%     din.lo_adc_phi = din.adc_phi;
%     din.lo_adc_phi.v = din.lo_adc_phi.v - 0.001*pi;
    % digitizer input admittance:
    din.adc_Yin_f.v = [];         
    din.adc_Yin_Cp.v = logrand(50e-12,500e-12);
    din.adc_Yin_Cp.u = 0;
    din.adc_Yin_Gp.v = logrand(1e-9,1e-6);
    din.adc_Yin_Gp.u = 0;   
    % create corretion of the digitizer timebase:
    din.adc_freq.v = linrand(-0.001,0.001);
    din.adc_freq.u = 0.000005;
    % create ADC offset voltages:
    din.adc_offset.v = linrand(-0.001,0.001);
    din.adc_offset.u = 0.000005;
%     din.lo_adc_offset.v = -0.002;
%     din.lo_adc_offset.u = 0.000005;
    % digitizer resolution:
    din.adc_bits.v = 24; % bits
    din.adc_nrng.v = 1; % nominal range [V]
%     din.lo_adc_bits.v = 24; % low-side channel
%     din.lo_adc_nrng.v = 1;
    % digitizer SFDR estimate:
    din.adc_sfdr_a.v = [];
    din.adc_sfdr_f.v = [];
    din.adc_sfdr.v = -log10(sfdr)*20;
%     din.lo_adc_sfdr_a = din.adc_sfdr_a; % low-side channel
%     din.lo_adc_sfdr_f = din.adc_sfdr_f;
%     din.lo_adc_sfdr = din.adc_sfdr;

    
    % define some low-side channel timeshift:
    din.time_shift_lo.v = -1.234e-4;
    din.time_shift_lo.u = 1e-6;
    
    
    % transducer type ('rvd' or 'shunt')
    din.tr_type.v = 'rvd';
        
    % create some corretion table for the transducer gain: 
    din.tr_gain_f.v = [0;1e3;1e6];
    din.tr_gain_a.v = [];
    din.tr_gain.v = [1.000; 0.800; 0.600]*20;
    din.tr_gain.u = [0.001; 0.002; 0.005]*0.01; 
    % create some corretion table for the transducer phase: 
    din.tr_phi_f.v = [0;1e3;1e6];
    din.tr_phi_a.v = [];
    din.tr_phi.v = [0.000; -0.200; -0.500]*pi;
    din.tr_phi.u = [0.001;  0.002;  0.005]*pi*0.01;
        
    % define RVD low-side impedance:
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
    
    
    
    
    % print some header:
    fprintf('samples count = %g\n',N);
    fprintf('sampling rate = %.7g kSa/s\n',0.001*din.fs.v);
    fprintf('fundamental frequency = %.7g Hz\n',f0_per/N*din.fs.v);
    fprintf('fundamental periods = %.7g\n',f0_per);
    fprintf('fundamental samples per period = %.7g\n',N/f0_per);
    fprintf('Transducer type = %s\n',din.tr_type.v);
    fprintf('Transducer buffer = %.0f\n',isfield(din,'tr_Zbuf_f'));
    fprintf('\n');
    
    
    
    % generate the signal:
    cfg.N = N; % samples count
    cfg.fx = fk*din.fs.v/N; % frequency components
    cfg.Ax = A; % amplitudes
    cfg.phx = ph; % phases
    cfg.dc = dc; % dc offset
    cfg.sfdr = sfdr; % sfdr max amplitude
    cfg.sfdr_hn = sfdr_hn; % sfdr max harmonics count
    cfg.sfdr_rand = sfdr_rand; % randomize sfdr amplitudes?
    cfg.adc_std_noise = adc_std_noise; % ADC noise level     
    if exist('Zx','var')
        cfg.Zx = Zx; % differential mode enabled 
    end        
    datain = gen_composite(din, cfg, rand_unc); % generate
   
    

    % add fake uncertainties to allow uncertainty calculation:
    %  ###todo: to be removed when QWTB supports no uncertainty checking 
    alginf = qwtb('TWM-MFSF','info');
    qwtb('TWM-MFSF','addpath');    
    datain = qwtb_add_unc(datain,alginf.inputs);        

    % --- execute the algorithm:
    dout = qwtb('TWM-MFSF',datain,calcset);
    
    % --- show results:
    
    % get reference values:
    dcr = cfg.dc;
    fr  = cfg.fx;
    Ar  = cfg.Ax;
    phr = cfg.phx;    
    thdr = 100*sum(cfg.Ax(2:end).^2)^0.5/cfg.Ax(1);
    
    % get calculated values and uncertainties:
    dcx = dout.dc;
    fx  = dout.f;
    Ax  = dout.A;
    phx = dout.phi;
    thdx = dout.thd;
    if strcmpi(calcset.unc,'none')
        dcx.u = dcx.v*NaN;
        fx.u  = fx.v*NaN;
        Ax.u  = Ax.v*NaN;
        phx.u = phx.v*NaN;
    end
%     dcx.u(abs(dcx.u./dcx.v) < 1e-6) = abs(dcx.v(abs(dcx.u./dcx.v) < 1e-6))*1e-6;
%     Ax.u(abs(Ax.u./Ax.v) < 1e-6) = abs(Ax.v(abs(Ax.u./Ax.v) < 1e-6))*1e-6;
%     phx.u(abs(phx.u./phx.v) < 1e-6) = abs(phx.v(abs(phx.u./phx.v) < 1e-6))*1e-6;
%     thdx.u(thdx.u./thdx.v < 1e-6) = thdx.v(thdx.u./thdx.v < 1e-6)*1e-6;
 
    % print result:          
    h = 0;
%     for k = 1:numel(fx.v)
%         h = h+1;
%         names{h} = sprintf('f[%d]',k-1);
%         dut(h).v = fx.v(k); 
%         dut(h).u = fx.u(k);
%         ref(h) = fr(k);
%     end
    h = h+1;
    names{h} = 'f0';
    dut(h).v = fx.v(1); 
    dut(h).u = fx.u(1);
    ref(h) = fr(1);
    iph(h) = 0;
    for k = 1:numel(Ax.v)
        h = h+1;
        names{h} = sprintf('A[%d]',k-1);
        dut(h).v = Ax.v(k); 
        dut(h).u = Ax.u(k);
        ref(h) = Ar(k);
        iph(h) = 0;
    end
    for k = 1:numel(phx.v)
        h = h+1;
        names{h} = sprintf('ph[%d]',k-1);
        dut(h).v = phx.v(k); 
        dut(h).u = phx.u(k);
        ref(h) = phr(k);
        iph(h) = 1;
    end
    h = h+1;
    names{h} = 'dc';
    dut(h).v = dcx.v(1); 
    dut(h).u = dcx.u(1);
    ref(h) = dcr(1);
    iph(h) = 0;
    h = h+1;
    names{h} = 'THD';
    dut(h).v = thdx.v(1); 
    dut(h).u = thdx.u(1);
    ref(h) = thdr(1);
    iph(h) = 0;
    
    
    has_unc = ~strcmpi(calcset.unc,'none');
    
    fprintf('\n');
    fprintf('----------+--------------+------------------------------+--------------+----------+---------\n');
    fprintf('  OUTPUT  |      REF     |          DUT +- UNC          |      DEV     |  UNC [%%] | %%-UNC\n');
    fprintf('----------+--------------+------------------------------+--------------+----------+---------\n');
    for k = 1:numel(names)

        tref = ref(k);
        if iph(k)
            tref = mod(tref + pi,2*pi) - pi;    
        end
        
        if ~isnan(ref(k)) && isnan(dut(k).u)
            [ss,rv] = unc2str(tref,1e-7*tref);
        elseif ~isnan(ref(k))
            [ss,rv] = unc2str(tref,dut(k).u);
        else
            rv = 'NaN';
        end                
        
        dev = dut(k).v - ref(k);
        if iph(k)
            dev = mod(dev + pi,2*pi) - pi;    
        end         
        
        if isnan(dut(k).u)  
            uu = max(1e-7*dut(k).v,1e-7);
        else
            uu = dut(k).u;
        end
        
        if ~isnan(dut(k).v)             
            [ss,dv,du] = unc2str(dut(k).v,uu);                 
        else
            dv = 'NaN';
            du = 'NaN';
        end
        
        rdev = 100*dev/dut(k).v;
        runc = 100*dut(k).u/dut(k).v;
        [ss,ev] = unc2str(dev,uu);
        
        if ~isnan(dev) && has_unc
            pp = 100*abs(dev/uu);                           
        else
            pp = inf; 
        end
        
        if ~has_unc
            runc = 0;                           
        end
                 
        fprintf(' %-8s | %12s | %12s +- %-12s | %12s | %8.4f |%4.0f\n',names{k},rv,dv,du,ev,runc,pp);                
    end        
    fprintf('----------+--------------+------------------------------+--------------+----------+---------\n');
        
    % check frequency estimate:
    %assert(abs(fx.v - f0) < fx.u, 'Estimated freq. does not match generated one.');
    
end



function [rnd] = logrand(A_min,A_max,sz)
    if nargin < 3
        sz = [1 1];
    end
    if size(sz) < 2
        sz = [sz 1];
    end
    rnd = 10.^(log10(A_min) + (log10(A_max) - log10(A_min))*rand(sz));
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
    digits = ceil(log10(abs(x)));    
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
   