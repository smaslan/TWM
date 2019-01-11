function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-PSFE.
%
% See also qwtb

    % --- calculation setup:
    % verbose level
    calcset.verbose = 1;
    % uncertainty mode {'none' - no uncertainty calculation, 'guf' - estimator}
    calcset.unc = 'none';
    % level of confidence (default 0.68 i.e. k=1):
    calcset.loc = 0.95;
    % no QWTB input checking:
    calcset.checkinputs = 0;
    
    
    % samples count to synthesize:
    %N = 1e5;
    N = round(logrand(1e3,1e5));
    
    % sampling rate [Hz]
    din.fs.v = 10000;
    
    % randomize uncertainties:
    %  note: enables randomization of the correction values by their uncertainties
    rand_unc = 0;
    
    
    % measurement frequency [Hz]:
    f0 = 1000.0;
    % compare curent [A]:
    Iref = 0.1;
    % reference impedance:    
    Zref = 0.6;
    % dut impedance:    
    Zdut = 2.0;
    
    % RMS noise of the ADC [V]:
    adc_noise = 1e-6;
    
    % digitizer SFDR value [max(Vspur)/Vfund]:
    adc_sfdr = 1e-7;
    
    chns = {}; id = 0;    
    
    % -- REF channel:
    id = id + 1;
    % channel parameters:
    chns{id}.name = 'i';
    chns{id}.type = 'shunt';
    % harmonic amplitudes:
    chns{id}.A = 2^0.5*[Iref];
    % harmonic phases:
    chns{id}.ph = [0];
    % harmonic component frequencies:
    chns{id}.fx = [f0]';
    % DC component:
    chns{id}.dc = 0;
    % SFDR simulation:
    chns{id}.sfdr = adc_sfdr; % sfdr max amplitude
    chns{id}.sfdr_hn = 10; % sfdr max harmonics count
    chns{id}.sfdr_rand = 1; % randomize sfdr amplitudes?    
    chns{id}.sfdr_rand_f = 0; % randomize sfdr frequencies?
    % ADC rms noise [s]:
    chns{id}.adc_std_noise = adc_noise;
    
    % -- DUT channel:
    id = id + 1;
    % channel parameters:
    chns{id}.name = 'u';
    chns{id}.type = 'shunt';
    % harmonic amplitudes:
    chns{id}.A = 2^0.5*[Iref];
    % harmonic phases:
    chns{id}.ph = [0];
    % harmonic component frequencies:
    chns{id}.fx = [f0]';
    % DC component:
    chns{id}.dc = 0;
    % SFDR simulation:
    chns{id}.sfdr = adc_sfdr; % sfdr max amplitude
    chns{id}.sfdr_hn = 10; % sfdr max harmonics count
    chns{id}.sfdr_rand = 1; % randomize sfdr amplitudes?    
    chns{id}.sfdr_rand_f = 0; % randomize sfdr frequencies?
    % ADC rms noise [s]:
    chns{id}.adc_std_noise = adc_noise;
            
    
    % print some header:
    fprintf('samples count = %g\n',N);
    fprintf('sampling rate = %.7g kSa/s\n',0.001*din.fs.v);
    fprintf('fundamental frequency = %.7g Hz\n',f0);
    fprintf('fundamental periods = %.7g\n',N/din.fs.v*f0);
    fprintf('fundamental samples per period = %.7g\n',din.fs.v/f0);
    fprintf('\n');
            
    
    % ADC aperture [s]:
    % note: non-zero value will simulate aperture gain/phase error 
    din.adc_aper.v = 20e-6;
    
    % ADC aperture correction enabled:
    % note: non-zero value will enable correction of the ADC gain/phase error by alg.
    din.adc_aper_corr.v = 1;  
               
    
    % create corretion of the digitizer timebase:
    din.adc_freq.v = 0.001;
    din.adc_freq.u = 0.000005;
    % u-to-i channel time shift:
    din.time_shift.v = 0;
    
    % generate REF shunt:
    din.i_tr_gain_f.v = [];
    din.i_tr_gain_a.v = [];
    din.i_tr_gain.v   = 1/Zref;
    din.i_tr_gain.u   = 0;
    % generate DUT shunt (unity, it is just formal, it is overriden inside):
    din.u_tr_gain_f.v = [];
    din.u_tr_gain_a.v = [];
    din.u_tr_gain.v   = 1/Zdut;
    din.u_tr_gain.u   = 0;
    
    
    % create generator setup
    cfg.N = N; % samples count
    cfg.chn = chns;
    datain = gen_ratio(din, cfg, rand_unc); % generate
   
%     figure
%     plot(datain.u.v)
%     hold on;
%     plot(datain.i.v,'r')
%     hold off;
   

    % add fake uncertainties to allow uncertainty calculation:
    %  ###todo: to be removed when QWTB supports no uncertainty checking 
    %alginf = qwtb('TWM-PSFE','info');
    %qwtb('TWM-PSFE','addpath');    
    %datain = qwtb_add_unc(datain,alginf.inputs);        

    % --- execute the algorithm:
    dout = qwtb('TWM-VecRat',datain,calcset);
    
    
    
    
    return
    
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
   