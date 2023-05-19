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
    
    
    % sub-records count (default: 1)
    subrec = 1;  
    
    % signal processing mode {WFFT, PSFE or FPNLSF}
    din.mode.v = 'WFFT';
    % optional window for WFFT only
    din.window.v = 'rect';
    % output equivalent circuit {CpD, CpRp, etc.}
    din.equ.v = 'CpD';
    % process sub-records as readings and return results vector?
    din.vector.v = 1;
    
    % skip transducer corrections (faster calculation)
    din.fast.v = 1;
    
    
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
    % round f0 to coherent?
    to_coherent = 1;
    
        
    % test voltage [V]
    Uref = 0.5;    
    
    % reference impedance (Rp-Cp or Cp-D)    
    Zref.Rp = 1e6;
    Zref.Cp = 1e-12;
    %Zref.D = 0.001;
    % place Zref to transducer correction instead of parameters?
    Zref_in_tran = 1;
    
    % input impedance (Rp-Cp)    
    Zinp.Rp = 100e3;
    Zinp.Cp = 100e-12;
    
    % dut impedance (Rp-Cp)    
    Zdut.Rp = 1000e3;
    Zdut.Cp = 50e-12;
    
    % use open correction by adc_Yin?
    din.open.v = 1;
    
    
    % RMS noise of the ADC [V]:
    adc_noise = 1e-6;
    
    % digitizer SFDR value [max(Vspur)/Vfund]:
    adc_sfdr = 1e-7;
    
    
    
    % round f0 to coherent?
    if to_coherent
        f0 = round(N/din.fs.v*f0)*din.fs.v/N;
    end
    if strcmpi(din.mode.v,'WFFT')
        din.f_est.v = f0;
    end
    w0 = 2*pi*f0;
    
    % make ref impedance
    if isfield(Zref,'Rp') && isfield(Zref,'Cp')
        Zref.Z = 1/(1/Zref.Rp + j*w0*Zref.Cp);
        if ~Zref_in_tran
            din.Rp.v = Zref.Rp;
            din.Cp.v = Zref.Cp;
        else
            Zref.fx = [0;logspace(log10(1),log10(din.fs.v),1000)'];
            wx = 2*pi*Zref.fx;            
            Zref.Zx = 1./(1/Zref.Rp + j*wx*Zref.Cp);            
        end
    elseif isfield(Zref,'Cp') && isfield(Zref,'D')
        Zref.Z = 1/(w0*Zref.Cp*(j + Zref.D));
        if ~Zref_in_tran        
            din.Cp.v = Zref.Cp;
            din.D.v = Zref.D;
        else
            Zref.fx = [0;logspace(log10(1),log10(din.fs.v),1000)'];
            wx = 2*pi*Zref.fx;            
            Zref.Zx = 1./(wx*Zref.Cp*(j + Zref.D));
        end
    else
        error('Zref impedance must be either Rp-Cp or Cp-D!');
    end
    
    % make dut impedance
    if isfield(Zinp,'Rp') && isfield(Zinp,'Cp')
        Zinp.Z = 1/(1/Zinp.Rp + j*w0*Zinp.Cp);
    else
        error('Zinp impedance must be Rp-Cp!');
    end
    
    % make dut impedance
    if isfield(Zdut,'Rp') && isfield(Zdut,'Cp')
        Zdut.Z = 1/(1/Zdut.Rp + j*w0*Zdut.Cp);
    else
        error('Zdut impedance must be Rp-Cp!');
    end
    
    % prepare open correction
    if din.open.v
        Zmeas = Zdut;
    else
        Zmeas.Cp = Zdut.Cp + Zinp.Cp;
        Zmeas.Rp = 1/(1/Zdut.Rp + 1/Zinp.Rp);
        Zmeas.Z = 1/(1/Zdut.Z + 1/Zinp.Z);
    end
    Zsim.Cp = Zdut.Cp + Zinp.Cp;
    Zsim.Rp = 1/(1/Zdut.Rp + 1/Zinp.Rp);
    Zsim.Z = 1/(1/Zdut.Z + 1/Zinp.Z);
    
    % DUT channel voltage
    Udut = Uref*Zsim.Z/(Zsim.Z + Zref.Z);
    
        
    chns = {}; id = 0;
    
    tran_type = 'shunt';    
    
    % -- DUT channel:
    id = id + 1;
    % channel parameters:
    chns{id}.name = 'u';
    chns{id}.type = tran_type;
    % harmonic amplitude-phase:
    chns{id}.A = 2^0.5*abs(Uref);
    chns{id}.ph = angle(Uref);
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
    
    % -- REF channel:
    id = id + 1;
    % channel parameters:
    chns{id}.name = 'i';
    chns{id}.type = tran_type;
    % harmonic amplitude-phase:
    chns{id}.A = 2^0.5*abs(Udut);    
    chns{id}.ph = angle(Udut);
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
    
    
            
               
    
    % ADC aperture [s]:
    % note: non-zero value will simulate aperture gain/phase error 
    din.adc_aper.v = 20e-6;
    
    % ADC aperture correction enabled:
    % note: non-zero value will enable correction of the ADC gain/phase error by alg.
    din.adc_aper_corr.v = 1;                 
    
    % generate DUT ADC:
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
    din.i_adc_Yin_Cp.v = Zinp.Cp;
    din.i_adc_Yin_Cp.u = 1e-12;
    din.i_adc_Yin_Gp.v = 1/Zinp.Rp;
    din.i_adc_Yin_Gp.u = 1e-9;
    
    % generate REF ADC:
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
    % create corretion of the digitizer timebase:
    din.adc_freq.v = 0*0.001;
    din.adc_freq.u = 0*0.000005;
    % u-to-i channel time shift:
    din.time_shift.v = linrand(-10e-6,+10e-6);
    din.time_shift.u = 1e-9;
    
    % generate DUT transducer:
    din.i_tr_gain_f.v = [];
    din.i_tr_gain_a.v = [];
    din.i_tr_gain.v   = 1.0;
    din.i_tr_gain.u   = 0;
    % transducer buffer output impedance            
    if false && rand() > 0.5
        din.i_tr_Zbuf_f.v = [];
        din.i_tr_Zbuf_Rs.v = 100*logrand(10.0,1000.0);
        din.i_tr_Zbuf_Rs.u = 1e-9;
        din.i_tr_Zbuf_Ls.v = logrand(1e-9,1e-6);
        din.i_tr_Zbuf_Ls.u = 1e-12;
    else
        din.i_tr_Zbuf_f.v = [];
        din.i_tr_Zbuf_Rs.v = 1e-8;
        din.i_tr_Zbuf_Rs.u = 1e-9;
        din.i_tr_Zbuf_Ls.v = 1e-11;
        din.i_tr_Zbuf_Ls.u = 1e-12;
    end    
    % generate REF transducer
    din.u_tr_gain_f.v = [];
    din.u_tr_gain_a.v = [];
    din.u_tr_gain.v   = 1.0;
    din.u_tr_gain.u   = 0;
    % transducer buffer output impedance            
    if false && rand() > 0.5
        din.u_tr_Zbuf_f.v = [];
        din.u_tr_Zbuf_Rs.v = 100*logrand(10.0,1000.0);
        din.u_tr_Zbuf_Rs.u = 1e-9;
        din.u_tr_Zbuf_Ls.v = logrand(1e-9,1e-6);
        din.u_tr_Zbuf_Ls.u = 1e-12;
    else
        din.u_tr_Zbuf_f.v = [];
        din.u_tr_Zbuf_Rs.v = 1e-8;
        din.u_tr_Zbuf_Rs.u = 1e-9;
        din.u_tr_Zbuf_Ls.v = 1e-11;
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
    
    
    % generate waveform(s)
    cfg.N = N; % samples count    
    cfg.chn = chns;    
    v_u = [];
    v_i = [];
    for k = 1:subrec
        datain = gen_ratio(din, cfg, rand_unc); % generate
        v_u(:,k) = [datain.u.v];
        v_i(:,k) = [datain.i.v];
    end
    datain.u.v = v_u;
    datain.i.v = v_i;
    
    if Zref_in_tran
        % now override DUT tranducer transfer by reference impedance data
        % (cannot be done before gen_ratio()!)    
        datain.i_tr_gain_f.v = Zref.fx;
        datain.i_tr_gain_a.v = [];
        datain.i_tr_gain.v   = abs(1./Zref.Zx);
        datain.i_tr_gain.u   = 0;
        datain.i_tr_phi_f.v = Zref.fx;
        datain.i_tr_phi_a.v = [];
        datain.i_tr_phi.v   = -angle(Zref.Zx);
        datain.i_tr_phi.u   = 0;
    end
    
    
   
%     figure
%     plot(datain.u.v)
%     hold on;
%     plot(datain.i.v,'r')
%     hold off;
   
    % --- execute the algorithm:
    dout = qwtb('TWM-InpZ',datain,calcset);
    
    
    
    % --- show results:
    
    % get ref. values:
    Cpr = Zmeas.Cp;
    Rpr = Zmeas.Rp;             
    
    % get calculated values and uncertainties:
    fx  = dout.f;
    Cpx.v = mean(dout.Cp.v);
    Cpx.u = mean(dout.Cp.u);
    Rpx.v = mean(dout.Rp.v);
    Rpx.u = mean(dout.Rp.u);
    if strcmpi(calcset.unc,'none')
        fx.u = NaN;
        Cpx.u = NaN;
        Rpx.u = NaN;
    end
    if Rpx.u/Rpx.v < 1e-6
        Rpx.u = Rpx.v*1e-6;
    end  
    if Cpx.u/Cpx.v < 1e-6
        Cpx.u = Cpx.v*1e-6;
    end
     
    % print result:          
    names = {'f','Rp','Cp'};        
    ref =  [f0, Rpr, Cpr];    
    dut =  [fx, Rpx, Cpx];      
    mul =  [1, 1, 1e12];
    has_unc = ~strcmpi(calcset.unc,'none');
    
    fprintf('\n');
    fprintf('----------+---------------+----------------------------+-------------+----------+---------\n');
    fprintf('  OUTPUT  |      REF      |         DUT +- UNC         |     DEV     |  UNC [%%] | %%-UNC\n');
    fprintf('----------+---------------+----------------------------+-------------+----------+---------\n');
    for k = 1:numel(names)
    
        if ~isnan(ref(k)) && isnan(dut(k).u)
            [ss,rv] = unc2str(ref(k)*mul(k),1e-7*ref(k)*mul(k));
        elseif ~isnan(ref(k))
            [ss,rv] = unc2str(ref(k)*mul(k),dut(k).u*mul(k));
        else
            rv = 'NaN';
        end            
        
        dev = (dut(k).v - ref(k))*mul(k);
        
        if isnan(dut(k).u)  
            uu = max(1e-7*dut(k).v*mul(k),1e-7);
        else
            uu = dut(k).u*mul(k);
        end
                
        if ~isnan(dut(k).v)             
            [ss,dv,du] = unc2str(dut(k).v*mul(k),uu);                 
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
   