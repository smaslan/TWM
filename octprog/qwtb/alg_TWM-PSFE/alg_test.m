function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-PSFE.
%
% See also qwtb

    % --- calculation setup:
    % verbose level
    calcset.verbose = 1;
    % uncertainty mode {'none' - no uncertainty calculation, 'guf' - estimator}
    calcset.unc = 'guf';
    % level of confidence (default 0.68 i.e. k=1):
    calcset.loc = 0.95;
    
    
    % samples count to synthesize:
    %N = 1e5;
    N = round(logrand(1e3,1e5));
    
    % sampling rate [Hz]
    din.fs.v = 10000;
    
    % randomize uncertainties:
    %  note: enables randomization of the correction values by their uncertainties
    rand_unc = 0;
    
    % --- these are harmonics to generate:
    % harmonic amplitudes:
    A =  [1       0.005]'*10;
    % harmonic phases:
    ph = [0.1/pi  2*rand]'*pi;
    % harmonic periods in the signal (must be: fk < 0.5*N):
    f0_per = logrand(10,0.1*N); % fundamental signal periods count
    fk = [f0_per  logrand(f0_per,0.45*N)]';
    
    % dc offset:
    dc = 0.1;
    
    % print some header:
    fprintf('samples count = %g\n',N);
    fprintf('sampling rate = %.7g kSa/s\n',0.001*din.fs.v);
    fprintf('fundamental frequency = %.7g Hz\n',f0_per/N*din.fs.v);
    fprintf('fundamental periods = %.7g\n',f0_per);
    fprintf('fundamental samples per period = %.7g\n',N/f0_per);
    fprintf('\n');
    
        
    % current loop impedance (used for simulation of differential transducer):
    %  note: uncomment to enable differential mode of transducer
    %Zx = 0.1;    
        
    % noise rms level:
    adc_std_noise = 1e-6;
        
    % ADC rms jitter [s]: 
    din.adc_jitter.v = 100e-9;
    
    
    % -- SFDR harmonics generator:
    % max spurr amplitude relative to fundamental [-]:
    sfdr = 10e-6;
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
    din.lo_adc_gain_f = din.adc_gain_f;
    din.lo_adc_gain_a = din.adc_gain_a;
    din.lo_adc_gain = din.adc_gain;
    din.lo_adc_gain.v = din.lo_adc_gain.v*1.5; 
    % create some low-side corretion table for the digitizer phase: 
    din.lo_adc_phi_f = din.adc_phi_f;
    din.lo_adc_phi_a = din.adc_phi_a;
    din.lo_adc_phi = din.adc_phi;
    din.lo_adc_phi.v = din.lo_adc_phi.v - 0.001*pi;
    % create corretion of the digitizer timebase:
    din.adc_freq.v = 0.001;
    din.adc_freq.u = 0.000005;
    % create ADC offset voltages:
    din.adc_offset.v = 0.001;
    din.adc_offset.u = 0.000005;
    din.lo_adc_offset.v = -0.002;
    din.lo_adc_offset.u = 0.000005;
    % digitizer resolution:
    din.adc_bits.v = 24; % bits
    din.adc_nrng.v = 1; % nominal range [V]
    din.lo_adc_bits.v = 24; % low-side channel
    din.lo_adc_nrng.v = 1;
    % digitizer SFDR estimate:
    din.adc_sfdr_a.v = [];
    din.adc_sfdr_f.v = [];
    din.adc_sfdr.v = -log10(sfdr)*20;
    din.lo_adc_sfdr_a = din.adc_sfdr_a; % low-side channel
    din.lo_adc_sfdr_f = din.adc_sfdr_f;
    din.lo_adc_sfdr = din.adc_sfdr;
    
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
    alginf = qwtb('TWM-PSFE','info');
    qwtb('TWM-PSFE','addpath');    
    datain = qwtb_add_unc(datain,alginf.inputs);        

    % --- execute the algorithm:
    dout = qwtb('TWM-PSFE',datain,calcset);
    
    
    % --- show results:
    
    % get reference values:
    f0  = cfg.fx(1);
    Ar  = A(1);
    phr = ph(1);    
    
    % get calculated values and uncertainties:
    fx   = dout.f;
    Ax  = dout.A;
    phx = dout.phi;
    if strcmpi(calcset.unc,'none')
        fx.u = NaN;
        Ax.u = NaN;
        phx.u = NaN;
    end
    if Ax.u/Ax.v < 1e-6
        Ax.u = Ax.v*1e-6;
    end  
    if phx.u/phx.v < 1e-6
        phx.u = phx.v*1e-6;
    end

 
    % print result:          
    names = {'f','A','ph'};        
    ref =  [f0, Ar, phr];    
    dut =  [fx, Ax, phx];      
    has_unc = ~strcmpi(calcset.unc,'none');
    
    fprintf('\n');
    fprintf('----------+-------------+----------------------------+-------------+----------+---------\n');
    fprintf('  OUTPUT  |     REF     |         DUT +- UNC         |     DEV     |  UNC [%%] | %%-UNC\n');
    fprintf('----------+-------------+----------------------------+-------------+----------+---------\n');
    for k = 1:numel(names)

        if ~isnan(ref(k)) && isnan(dut(k).u)
            [ss,rv] = unc2str(ref(k),1e-7*ref(k));
        elseif ~isnan(ref(k))
            [ss,rv] = unc2str(ref(k),dut(k).u);
        else
            rv = 'NaN';
        end            
        
        dev = dut(k).v - ref(k);
        
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
                 
        fprintf(' %-8s | %11s | %11s +- %-11s | %11s | %8.4f |%4.0f\n',names{k},rv,dv,du,ev,runc,pp);                
    end        
    fprintf('----------+-------------+----------------------------+-------------+----------+---------\n\n');
        
    % check frequency estimate:
    assert(abs(fx.v - f0) < fx.u, 'Estimated freq. does not match generated one.');
    
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
   