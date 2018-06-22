function dout = gen_composite(din,cfg,rand_unc)
% This is simple signal generator for the single input TWM algorithms.
% It can apply all the standard currections (errors) defined in the TWM.
% For meaning of the correction matrices in the 'din' see doc. of the 
% TWM tool in 'doc' folder of the TWM git. 
% It can generate multiharmonic signal + several interference signals.
%
% Usage:
%   dout = gen_composite(din, cfg, rand_unc)
%
% Parameters:
%   din - all the QWTB style corrections data defined by the TWM.        
%         If not assigned, it will generate default values internally.
%          Content:
%           din.fs.v - sampling rate [Hz], required
%          all others are optional:
%           din.*adc_gain... - ADC gain correction matrices
%           din.*adc_phi... - ADC phase shift correction matrices
%           din.*adc_offset - ADC DC offset [V]
%           din.*adc_bits - ADC bits count
%           din.*adc_nrng - ADC nominal range
%           din.*adc_jitter - ADC jitter value [s]
%           din.*adc_Yin - ADC input admittance matrices
%           din.*adc_aper_corr - enable ADC aperture correction
%           din.adc_aper - ADC aperture
%           din.adc_freq - ADC timebase correction
%           din.time_stamp - first sample time-stamp
%           din.timeshift_lo - low side channel time shift value [s]
%           din.tr_type - transducer type string ('rvd' or 'shunt')
%           din.tr_gain... - transducer gain correction matrices
%           din.tr_phi... - transducer phase correction matrices
%           din.tr_Zlo... - transducer low-side Z matrices (for RVD only)
%           din.tr_Zca... - transducer high-side terminals Z matrices
%           din.tr_Zcal... - transducer low-side terminals Z matrices
%           din.tr_Zcam... - transducer terminals mutual inductance matrices
%           din.tr_Yca... - transducer terminals shunting Y matrices
%           din.tr_Zcb... - transducer cable(s) series Z matrices
%           din.tr_Ycb... - transducer cable(s) shunting Y matrices
%           * - prefix of subchannel ('' - high-side channel or SE, or 'lo_' - low-side channel)
%         
%   cfg - configuration of the simulator:
%     cfg.N - samples count to generate
%     cfg.fx - frequencies to synthesize
%     cfg.Ax - amplitudes to synthesize
%     cfg.dc - DC offset of the signal
%     cfg.phx - phases to synthesize [rad]
%     cfg.sfdr - max. SFDR of harmonic spurrs (relative to Ax(1))
%     cfg.sfdr_hn - maximum count of harmonic spurrs
%     cfg.sfdr_rand - non-zero enable randomization of spurr amplitudes
%                     from 0 to cfg.sfdr
%     cfg.adc_std_noise - rms noise at the ADC input [V] 
%     cfg.Zx  - loop impedance for the differential transducer mode.
%               when found in the structure, the diff. mode is enabled.
%   rand_unc - non-zero means all the corrections in 'din' will be randomized
%              according their uncertainties. Zero value discard all uncertainties
%              even in the returned quantities 'dout'.
%
% Returns:
%   dout - copy of 'din' with added signals 'y' (and 'y_lo')
%
% License:
% --------
% This is part of the TWM tool (https://github.com/smaslan/TWM).
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT   


    if ~rand_unc
        % discard all correction uncertainties when randomization not allowed:        
        corrz = fieldnames(din);        
        for k = 1:numel(corrz)
            c_data = getfield(din,corrz{k});
            if isfield(c_data,'u')
                c_data.u = 0*c_data.u;
                din = setfield(din,corrz{k},c_data);
            end            
        end
    end
    
    % differential mode?
    is_diff = isfield(cfg,'Zx');

    % remember original input quantities:
    %  note: so the sample data are written to these instead of the ones modified during the following code 
    dout = din;
       
    
    % Restore orientations of the input vectors to originals (before passing via QWTB)
    %  note: also generates default (neutral) correction values, so not all TWM correction must be generated
    din.y.v = ones(10,1); % fake data vector just to make following function work!
    if is_diff, din.y_lo.v = din.y.v; end
    [din,t_cfg] = qwtb_restore_twm_input_dims(din,1);
    
    % Rebuild TWM style correction tables (just for more convenient calculations):
    tab = qwtb_restore_correction_tables(din,t_cfg);
    
    
    
    
    % -- generate harmonics list to synthesize --   
    % get composite signal components to generate:
    fx  = cfg.fx;
    Ax  = cfg.Ax;
    phx = cfg.phx;
    
    % add fake DC component:
    fx = [1e-12;fx]; 
    Ax = [cfg.dc;Ax];
    phx = [pi/2;phx];
    
    % add SFDR harmonic spurrs to the composite signal:
    fh = fx(1)*[2:cfg.sfdr_hn+1]'; % odd and even harmonics
    fh = fh(fh < 0.45*din.fs.v); % limit by nyquist
    if cfg.sfdr_rand
        Ah = rand(size(fh))*cfg.sfdr*cfg.Ax(1); % random amplitudes
    else
        Ah = ones(size(fh))*cfg.sfdr*cfg.Ax(1); % maximum amplitudes
    end
    phh = rand(size(fh))*2*pi; % random amplitudes     
    % add SFDR spurrs to the list
    fx  = [fx;fh];
    Ax  = [Ax;Ah];
    phx = [phx;phh];
     
    
    % apply transducer transfer:
    if rand_unc, rand_str = 'rand'; else rand_str = ''; end
    A_syn = [];
    ph_syn = [];
    sctab = {};
    tsh = [];
    if is_diff
        % -- differential connection:
        [A_syn(:,1),ph_syn(:,1),A_syn(:,2),ph_syn(:,2)] = correction_transducer_sim(tab,din.tr_type.v,fx, Ax,phx,0*Ax,0*phx,rand_str,cfg.Zx);
        % subchannel correction tables:
        sctab{1}.adc_gain = tab.adc_gain;
        sctab{1}.adc_phi  = tab.adc_phi;
        sctab{2}.adc_gain = tab.lo_adc_gain;
        sctab{2}.adc_phi  = tab.lo_adc_phi;
        % subchannel timeshift:
        tsh(1) = 0; % high-side channel
        tsh(2) = din.time_shift_lo.v; % low-side channel
        % ADC resolution:
        res(1).adc_bits = din.adc_bits;
        res(1).adc_nrng = din.adc_nrng;
        res(2).adc_bits = din.lo_adc_bits;
        res(2).adc_nrng = din.lo_adc_nrng;
        % ADC offset:
        ofs(1) = din.adc_offset;
        ofs(2) = din.lo_adc_offset;
    else
        % -- single-ended connection:
        [A_syn(:,1),ph_syn(:,1)] = correction_transducer_sim(tab,din.tr_type.v,fx, Ax,phx,0*Ax,0*phx,rand_str);
        % subchannel correction tables:
        sctab{1}.adc_gain = tab.adc_gain;
        sctab{1}.adc_phi  = tab.adc_phi;
        % subchannel timeshift:
        tsh(1) = 0; % none for single-ended mode
        % ADC resolution:
        res(1).adc_bits = din.adc_bits;
        res(1).adc_nrng = din.adc_nrng;
        % ADC offset:
        ofs(1) = din.adc_offset;
    end
    
    % restore DC polarity:
    A_syn = bsxfun(@times,A_syn,sign(Ax));
    

    % apply ADC aperture error:
    if din.adc_aper_corr.v && din.adc_aper.v > 1e-12
        % get ADC aperture value [s]:
        ta = abs(din.adc_aper.v);
    
        % calculate aperture gain/phase correction:
        ap_gain = sin(pi*ta*fx)./(pi*ta*fx);
        ap_phi  = -pi*ta*fx;        
        % apply it to subchannels:
        A_syn  = bsxfun(@times,ap_gain,A_syn);
        ph_syn = bsxfun(@plus, ap_phi, ph_syn);
        
    end
    
    % generate random frequency error (common for both differential inputs):
    rng_adc_freq = din.adc_freq.v + din.adc_freq.u*rand;    
    
    % for each transducer subchannel (differential mode has two sub-channels):
    for c = 1:numel(sctab)
    
        % interpolate digitizer gain/phase to the measured frequencies and amplitudes:
        k_gain = correction_interp_table(sctab{c}.adc_gain, A_syn(:,c), fx, 'f',1);    
        k_phi  = correction_interp_table(sctab{c}.adc_phi,  A_syn(:,c), fx, 'f',1);
        
        % apply digitizer gain (with uncertainty randomization):
        Ac  = A_syn(:,c)./(k_gain.gain + k_gain.u_gain.*randn(size(k_gain.u_gain)));
        phc = ph_syn(:,c) - k_phi.phi + k_phi.u_phi.*randn(size(k_phi.u_phi));
        
        % extract fake DC component from the harmonic list:
        dcc = Ac(1);
        fxc = fx(2:end);
        Ac = Ac(2:end);
        phc = phc(2:end);
                
        % generate relative time 2*pi*t:
        %  note: include time-shift
        %        timestamp delay
        %        frequency error
        %        jitter        
        jitter = din.adc_jitter.v*randn(1,cfg.N); % assume gassian
        tstmp = din.time_stamp.v;       
        t = [];
        t(:,1) = ([0:cfg.N-1]/din.fs.v + tsh(c) + tstmp + jitter)*(1 + rng_adc_freq)*2*pi;
        clear jitter;
                
        % synthesize waveforms (rather one by one harmonic to prevent insane sized matrix):
        u = repmat(dcc,size(t)); % DC component
        for k = 1:numel(fxc)
            u = u + Ac(k)*sin(t*fxc(k) + phc(k));  
        end
        
        % add ADC DC offset:
        u = u + ofs(c).v + randn*ofs(c).u;
                
        % add ADC noise:
        u = u + randn(cfg.N,1)*cfg.adc_std_noise;
        
        % qunatize:    
        adc_res = res(c).adc_nrng.v*2^-(res(c).adc_bits.v - 1);
        u = round(u./adc_res).*adc_res;

        % store to the QWTB input list:
        dout = setfield(dout, t_cfg.ysub{c}, struct('v',u));
        
    end    

end
