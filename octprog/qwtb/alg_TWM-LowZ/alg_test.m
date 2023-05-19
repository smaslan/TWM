function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-LowZ.
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2018-2021, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.
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
    N = round(logrand(1e4,1e5));
    
    % sampling rate [Hz]
    din.fs.v = logrand(9000,11000);
    
    % randomize uncertainties:
    %  note: enables randomization of the correction values by their uncertainties
    rand_unc = 0;
    
    % inverted connection to DUT?
    din.invert.v = 0;
    
    % calculation mode (PSFE, FPNLSF, WFFT):
    din.mode.v = 'WFFT';
    % optional window for WFFT (see WFFT algorithm):
    din.window.v = 'hanning';
    
    
    % measurement frequency [Hz]:
    f0 = logrand(100,1000.0);
    % round to coherent:
    f0 = round(N/din.fs.v*f0)/N*din.fs.v;
    din.f_est.v = f0;
        
    % compare curent [A]:
    Iref = 0.1;
    % reference impedance:    
    Zref = 0.6*exp(0.1*j);
    % DUT impedance:    
    Zdut  = 0.6*exp(-0.2*j);
    % DUT ground impedance (differential modes only)
    cfg.ZdutG = 0.001;
    % dut is differential?
    is_dut_diff = 1;
    % 4TP measurement mode {'4TP': regular differential connection of DUT, '2x4T': high-side for lives difference, low-side for neutrals difference}
    %   note: applies for differential only
    din.mode_4TP.v = '2x4T';
    
    
    % RMS noise of the ADC [V]:
    adc_noise = 0e-6;
    
    % digitizer SFDR value [max(Vspur)/Vfund]:
    adc_sfdr = 1e-9;
    
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
    % invert DUT:
    chns{id}.invert = din.invert.v;
    % simulate differential mode?
    if is_dut_diff
        chns{id}.Zx = Zref;
    end 
        
            
    
    % ADC aperture [s]:
    % note: non-zero value will simulate aperture gain/phase error 
    din.adc_aper.v = logrand(1e-6,20e-6);
        
    % create corretion of the digitizer timebase:
    din.adc_freq.v = 0.001;
    din.adc_freq.u = 0.000005;
    % u-to-i channel time shift:
    din.time_shift.v = linrand(-0.001,+0.001);
    
    % generate REF ADC:
    din.i_adc_aper_corr.v = 1;
    din.i_adc_gain_f.v = [];
    din.i_adc_gain_a.v = [];    
    din.i_adc_gain.v   = linrand(0.9,1.1);
    din.i_adc_gain.u   = 0;
    din.i_adc_phi_f.v = [];
    din.i_adc_phi_a.v = [];    
    din.i_adc_phi.v   = linrand(-0.01,+0.01);
    din.i_adc_phi.u   = 0;
    din.i_adc_Yin_f.v = []; 
    din.i_adc_Yin_Cp.v = 100e-12;
    din.i_adc_Yin_Cp.u = 1e-12;
    din.i_adc_Yin_Gp.v = 1e-6;
    din.i_adc_Yin_Gp.u = 1e-9;
    % generate DUT ADC:
    din.u_adc_aper_corr.v = 1;
    din.u_adc_gain_f.v = [];
    din.u_adc_gain_a.v = [];    
    din.u_adc_gain.v   = linrand(0.9,1.1);
    din.u_adc_gain.u   = 0;
    din.u_adc_phi_f.v = [];
    din.u_adc_phi_a.v = [];    
    din.u_adc_phi.v   = linrand(-0.01,+0.01);
    din.u_adc_phi.u   = 0;
    din.u_adc_Yin_f.v = []; 
    din.u_adc_Yin_Cp.v = 100e-12;
    din.u_adc_Yin_Cp.u = 1e-12;
    din.u_adc_Yin_Gp.v = 1e-6;
    din.u_adc_Yin_Gp.u = 1e-9;
    din.u_lo_adc_Yin_f = din.u_adc_Yin_f;
    din.u_lo_adc_Yin_Cp = din.u_adc_Yin_Cp;
    din.u_lo_adc_Yin_Gp = din.u_adc_Yin_Gp;
    din.u_time_shift_lo.v = linrand(-0.001,+0.001);
    din.u_time_shift_lo.u = 0;
    
    
    % generate REF shunt:
    din.i_tr_gain_f.v = [];
    din.i_tr_gain_a.v = [];    
    din.i_tr_gain.v   = abs(1/Zref);
    din.i_tr_gain.u   = 0;
    din.i_tr_phi_f.v = [];
    din.i_tr_phi_a.v = [];
    din.i_tr_phi.v   = angle(1/Zref);
    din.i_tr_phi.u   = 0;
    % transducer buffer output impedance            
    if rand() > 0.5
        din.i_tr_Zbuf_f.v = [];
        din.i_tr_Zbuf_Rs.v = 100*logrand(10.0,1000.0);
        din.i_tr_Zbuf_Rs.u = 1e-9;
        din.i_tr_Zbuf_Ls.v = logrand(1e-9,1e-6);
        din.i_tr_Zbuf_Ls.u = 1e-12;
    end    
    % generate DUT shunt
    if is_dut_diff && isfield(din,'mode_4TP') && strcmpi(din.mode_4TP.v,'2x4T')    
        Zdut_sim = Zdut - cfg.ZdutG; % simulate shield impedance
    else
        Zdut_sim = Zdut;
    end
    din.u_tr_gain_f.v = [];
    din.u_tr_gain_a.v = [];
    din.u_tr_gain.v   = abs(1/Zdut_sim);
    din.u_tr_gain.u   = 0;
    din.u_tr_phi_f.v = [];
    din.u_tr_phi_a.v = [];
    din.u_tr_phi.v   = angle(1/Zdut_sim);
    din.u_tr_phi.u   = 0;
    % transducer buffer output impedance            
    if rand() > 0.5 && ~is_dut_diff
        din.u_tr_Zbuf_f.v = [];
        din.u_tr_Zbuf_Rs.v = 100*logrand(10.0,1000.0);
        din.u_tr_Zbuf_Rs.u = 1e-9;
        din.u_tr_Zbuf_Ls.v = logrand(1e-9,1e-6);
        din.u_tr_Zbuf_Ls.u = 1e-12;
    end
    
    
    % print some header:
    fprintf('samples count = %g\n',N);
    fprintf('sampling rate = %.7g kSa/s\n',0.001*din.fs.v);
    fprintf('fundamental frequency = %.7g Hz\n',f0);
    fprintf('fundamental periods = %.7g\n',N/din.fs.v*f0);
    fprintf('fundamental samples per period = %.7g\n',din.fs.v/f0);
    fprintf('I-transducer buffer (REF) = %.0f\n',isfield(din,'i_tr_Zbuf_f'));
    fprintf('U-transducer buffer (DUT) = %.0f\n',isfield(din,'u_tr_Zbuf_f'));
    fprintf('\n');
    
    
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
    dout = qwtb('TWM-LowZ',datain,calcset);
    
    
    % --- show results:
    
    % get ref. values:
    Zr  = abs(Zdut);
    phr = angle(Zdut);             
    
    % get calculated values and uncertainties:
    fx  = dout.f;
    Zx  = dout.Z_mod;
    phx = dout.Z_phi;
    if strcmpi(calcset.unc,'none')
        fx.u = NaN;
        Zx.u = NaN;
        phx.u = NaN;
    end
    if Zx.u/Zx.v < 1e-6
        Zx.u = Zx.v*1e-6;
    end  
    if abs(phx.u - phx.v) < 1e-6
        phx.u = 1e-6;
    end
     
    % print result:          
    names = {'f','Z','ph'};        
    ref =  [f0, Zr, phr];    
    dut =  [fx, Zx, phx];      
    has_unc = ~strcmpi(calcset.unc,'none');
    
    fprintf('\n');
    fprintf('----------+---------------+----------------------------+-------------+----------+---------\n');
    fprintf('  OUTPUT  |      REF      |         DUT +- UNC         |     DEV     |  UNC [%%] | %%-UNC\n');
    fprintf('----------+---------------+----------------------------+-------------+----------+---------\n');
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
                 
        fprintf(' %-8s | %13s | %11s +- %-11s | %11s | %8.4f |%4.0f\n',names{k},rv,dv,du,ev,runc,pp);                
    end        
    fprintf('----------+---------------+----------------------------+-------------+----------+---------\n\n');
    
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
   