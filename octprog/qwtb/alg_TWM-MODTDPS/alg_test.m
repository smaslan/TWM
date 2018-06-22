function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-MODTDPS.
%
% See also qwtb

    % calculation setup:
    calcset.verbose = 1;
    calcset.unc = 'guf';
    calcset.loc = 0.95;
    
    % samples to synthesize:
    %N = 30000;
    N = logrand(3000,100000,1);
    
    % sampling rate:
    fs = 10000;
    
    % carrier:
    f0 = rounddig(logrand(50,fs/10,1),4);
    A0 = rounddig(logrand(1,50,1),3);
        
    % modulating signal:    
    fm = rounddig(logrand(3/(N/fs),0.3*f0,1),4);
    Am = A0*rounddig(logrand(0.02,0.98,1),3);    
    phm = rand(1)*2*pi; % random phase
    wshape = 'sine';
    
    % DC component:
    dc = 0.1;
    
    %f0 = 882.6;
    %A0 = 14.6;
    %Am = 3*4.4384;
    %fm = 45.79;
    
    
    % print some header:
    fprintf('samples count = %g\n', N);
    fprintf('sampling rate = %.7g kSa/s\n', 0.001*fs);
    fprintf('fundamental frequency = %.7g Hz\n', f0);
    fprintf('modulating periods = %.7g\n', (N/fs)*fm);
    fprintf('fundamental samples per period = %.7g\n', fs/f0);
    fprintf('modulation to carrier frequency ratio = %.5g\n', fm/f0);
    fprintf('\n');
    
        
    
    % digitizer std noise:    
    adc_std_noise = 100e-6;
    
    % digitizer jitter:
    jitter = 100e-9;
    
    % enable algorithm self-compensation?
    din.comp_err.v = 1;
    
    % uncomment to enable differential sensor connection?
    %  note: this is an additional loop impedance of the differential sensor
    %Zx = 10;
    
    % randomize uncertainties?
    rand_unc = 0;
    
    
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
        % create some corretion table for the digitizer gain: 
        din.adc_gain_f.v = [0;1e3;1e6];
        din.adc_gain_a.v = [];
        din.adc_gain.v = [1.0000; 1.1000; 1.5000];
        din.adc_gain.u = [0.0001; 0.0002; 0.0003]; 
        % create some corretion table for the digitizer phase: 
        din.adc_phi_f.v = [0;1e3;1e6];
        din.adc_phi_a.v = [];
        din.adc_phi.v = [0.00000; 0.00010; 0.0010];
        din.adc_phi.u = [0.00010; 0.00020; 0.0020];
        % create some corretion table for the digitizer gain: 
        din.lo_adc_gain_f = din.adc_gain_f;
        din.lo_adc_gain_a = din.adc_gain_a;
        din.lo_adc_gain = din.adc_gain; 
        % create some corretion table for the digitizer phase: 
        din.lo_adc_phi_f = din.adc_phi_f;
        din.lo_adc_phi_a = din.adc_phi_a;
        din.lo_adc_phi = din.adc_phi;
        % generate some ADC sfdr:
        din.adc_sfdr_a.v = [];
        din.adc_sfdr_f.v = [];
        din.adc_sfdr.v = -log10(sfdr)*20;
        din.lo_adc_sfdr_a = din.adc_sfdr_a;
        din.lo_adc_sfdr_f = din.adc_sfdr_f;
        din.lo_adc_sfdr = din.adc_sfdr;
        % create corretion of the digitizer timebase:
        din.adc_freq.v = 0.000100;
        din.adc_freq.u = 0.000005;
        % create ADC offset voltages:
        din.adc_offset.v = 0.001;
        din.adc_offset.u = 0.000005;
        din.lo_adc_offset.v = -0.002;
        din.lo_adc_offset.u = 0.000005;
        
        % define some low-side channel timeshift:
        din.time_shift_lo.v = 1.234e-4;
        din.time_shift_lo.u = 10e-6;
        
        % ADC aperture correction:
        din.adc_aper_corr.v = 1; % state
        din.adc_aper.v = 10e-6; % aperture value
        
        
        % transducer type:
        din.tr_type.v = 'rvd';        
        % create some corretion table for the transducer gain: 
        din.tr_gain_f.v = [0;1e3;1e6];
        din.tr_gain_a.v = [];
        din.tr_gain.v = [1.0000; 0.9500; 0.9000]*70;
        din.tr_gain.u = [0.0001; 0.0002; 0.0005]*70; 
        % create some corretion table for the transducer phase: 
        din.tr_phi_f.v = [0;1e3;1e6];
        din.tr_phi_a.v = [];
        din.tr_phi.v = [0.0000; -0.0010; -0.0020];
        din.tr_phi.u = [0.0001;  0.0002;  0.0010];     
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
    datain = gen_mod(din, cfg, rand_unc);
    
    
    % workaround for QWTB uncertainty checking
    %  ###todo: to be removed when QWTB fixed
    alginf = qwtb('TWM-MODTDPS','info');
    qwtb('TWM-MODTDPS','addpath');
    datain = qwtb_add_unc(datain,alginf.inputs);
    
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
    modr = 100*Am/A0;
    
    % prepare list of quantities to print:
    r_list = [A0    Am    modr   f0    fm];
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
   