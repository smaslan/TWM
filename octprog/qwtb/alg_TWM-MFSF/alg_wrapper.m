function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm TWM-MFSF.
%
% This is part of the QWTB TWM-MFSF wrapper.
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.
%
% See also qwtb
%
% Format input data --------------------------- %<<<1
    
    % Restore orientations of the input vectors to originals (before passing via QWTB)
    % This is critical for the correction data! 
    [datain,cfg] = qwtb_restore_twm_input_dims(datain,1);

    if cfg.y_is_diff
        % Input data 'y' is differential: if it is not allowed, put error message here
        error('Differential input data ''y'' not allowed!');     
    end
    
    if cfg.is_multi
        % Input data 'y' contains more than one record: if it is not allowed, put error message here
        error('Multiple input records in ''y'' not allowed!'); 
    end
    

    % try to obtain sampling period from alternative input quantities [s]
    if isfield(datain, 'fs')
        Ts = 1./datain.fs.v;
    elseif isfield(datain, 'Ts')
        Ts = datain.Ts.v;
    else
        Ts = mean(diff(datain.t.v));
    end
    
    % timestamp phase compensation state:
    tstmp_comp = isfield(datain, 'comp_timestamp') && ((isnumeric(datain.comp_timestamp.v) && datain.comp_timestamp.v) || (ischar(datain.comp_timestamp.v) && strcmpi(datain.comp_timestamp.v,'on')));
    
    % --- get ADC LSB value
    if isfield(datain,'lsb')
        % get LSB value directly
        lsb = datain.lsb.v;
    elseif isfield(datain,'adc_nrng') && isfield(datain,'adc_bits')
        % get LSB value estimate from nominal range and resolution
        lsb = 2*datain.adc_nrng.v*2^(-datain.adc_bits.v);    
    else
        error('MFSF, corrections: Correction data contain no information about ADC resolution+range or LSB value!');
    end
    
    if ~isfield(datain,'fest')
        % default initial guess mode (ipdft):
        datain.fest.v = -1;
    end
    
    if ~isfield(datain,'CFT')
        % default CFT value
        % ###note: overriding the MFSF function default, because the GUF estimator was made for 3.5e-11 only!           
        datain.CFT.v = 3.5e-11;
    end
    
    % frequency components to fit:
    if ~isfield(datain,'ExpComp') && ~isfield(datain,'H')
        % default - three harmonics [1 2 3]:
        datain.ExpComp.v = [1 2 3];
    elseif ~isfield(datain,'ExpComp')
        % explicit list not defined, generate [1:H] list:
        datain.ExpComp.v = [1:datain.H.v];
    end
    
    
    % Rebuild TWM style correction tables:
    % This is not necessary but the TWM style tables are more comfortable to use then raw correction matrices
    tab = qwtb_restore_correction_tables(datain,cfg);
    
    
    % --------------------------------------------------------------------
    % Start of the algorithm
    % --------------------------------------------------------------------
    
    % load input signal (or high-side input channel for diff. mode):
    y = datain.y.v;
    
    
    % call low level PSFE algorithm to obtain estimate of the harmonic:
    %  note: no uncertainty at this time because we don't know all necessary parameters yet! 
    din.Ts = struct('v',Ts, 'u',0*Ts);
    din.y  = struct('v',y,  'u',0*y);
    din.ExpComp.v = datain.ExpComp.v;
    din.fest.v = datain.fest.v;
    din.CFT.v = datain.CFT.v; 
    cset = calcset;
    cset.unc = 'none';
    cset.verbose = 0;
    dout = qwtb('MFSF',din,cset);
    qwtb('TWM-MFSF','addpath'); % ###todo: fix qwtb so it does not loose the path every time another alg. is called    
    f = dout.f.v;
    A = dout.A.v;
    ph = dout.ph.v;
    dc = dout.O.v;    

    % fitted harmonics count:
    H = numel(A);
 
    
    % store original frequency before tb. correction:
    f_org = f;
    % apply timebase frequency correction:    
    % note: it is relative correction of timebase error, so apply inverse correction to measured f.  
    f = f./(1 + datain.adc_freq.v);    
    % calculate correction uncertainty (absolute):
    u_f_tb = f.*datain.adc_freq.u;          
    
    
    
    
    % --- Apply corrections:
    
    % remove ADC DC offset: 
      dc = dc - datain.adc_offset.v;
    u_dc = datain.adc_offset.u;  
    
    
    % create virtual list of frequencies with 'DC' for the corrections purposes (so we can correct DC as well):    
    %  note: The df frequency shift is used for calculation of uncertainty contribution from frequency.
    %        However the uncertainty of 'f' is not known at this point, so lest assume some value
    %        and we just fix the estimate later. 
    df = 10e-6;
    %  f = [dc, f0, f1, ..., f0*(1+df), f1*(1+df), ...]
    f_org   = [0,    f_org,   f_org]';
    f       = [1e-6, f,       f*(1+df)]'; % note: we use non-zero frequency for DC so the AC functions won't get mad... 
    u_f_tb  = [0,    u_f_tb,  u_f_tb]';
    u_A     = [u_dc, 0*A,     0*A]';
    A       = [dc,   A,       A]';    
    ph      = [0,    ph,      ph]';
    
    
    % calculate aperture corrections (when enabled and some non-zero value entered for the aperture time):
    ta = datain.adc_aper.v;
    if datain.adc_aper_corr.v && abs(ta) > 1e-12 

        % calculate gain correction:
        ap_gain = (pi*ta*f)./sin(pi*ta*f);
        ap_gain(1) = 1;
        % calculate phase correction:
        ap_phi = pi*ta*f;
        ap_phi(1) = 0;        
        
        % apply the corrections:
        A  = A.*ap_gain;
        ph = ph + ap_phi; 
    
    end
    
    
    
    
                   
    
    % interpolate the gain/phase tables to the measured frequencies and amplitudes:
    adc_gain = correction_interp_table(tab.adc_gain, abs(A), f, 'f', 1);
    adc_phi  = correction_interp_table(tab.adc_phi,  abs(A), f, 'f', 1);
        
    % check if there are some NaNs in the correction data - that means user correction dataset contains some undefined values:
    if any(isnan(adc_gain.gain)) || any(isnan(adc_phi.phi))
        error('Digitizer gain/phase correction data do not have sufficient frequency range!');
    end
    
    % get ADC SFDR value estimate:
    %  note: assuming first component from MHFE is fundamental component
    adc_sfdr = correction_interp_table(tab.adc_sfdr, A(2), f(2));
            
    % apply the digitizer transfer correction:
    A   = A.*adc_gain.gain;
    u_A = (u_A.^2 + (A.*adc_gain.u_gain).^2).^0.5;
    ph   = ph + adc_phi.phi;      
    u_ph = adc_phi.u_phi;
    
    
    % --- apply transducer gain/phase corrections:
    
    if isempty(datain.tr_type.v)
        % -- transducer type not defined:
        warning('Transducer type not defined! Not applying tran. correction!');
    else
        % -- tran. type defined, apply correction:
        sgn_A = sign(A);
        [A,ph,u_A,u_ph] = correction_transducer_loading(tab,datain.tr_type.v,f,[], abs(A),ph,u_A,u_ph);
        A(1) = A(1)*sgn_A(1); % restore 'DC' polarity                
    end
    
    if any(isnan(A))
        error('Transducer gain/phase correction data or terminal/cable impedances do not have sufficient range!');
    end
    
    % get transducer SFDR value estimate:
    tr_sfdr = correction_interp_table(tab.tr_sfdr, A(2)*2^-0.5, f(2));
    
    % interpolate the gain/phase tfer table to the measured frequencies but NOT rms:        
    tr_gain = correction_interp_table(tab.tr_gain, [], f);
    tr_phi  = correction_interp_table(tab.tr_phi,  [], f);
    
    % calculate estimate of input RMS:
    A_rms = sum(A(1)^2 + 0.5*A(2:end).^2)^0.5;
    
    % interpolate the gain/phase tfer table to the measured frequencies with rms estimate from single A component:        
    tr_gain_rms = correction_interp_table(tab.tr_gain, A_rms, f);
    tr_phi_rms  = correction_interp_table(tab.tr_phi,  A_rms, f);
    
    % get the rms-independent tfer:
    % note: for this alg. it is not possible to evaluate RMS easily, because we may not have all harmonics,
    % so lets assume the correction will be not dependent on rms...
    % the nanmean is used to find mean correction coefficient for all available rms-values ignoring missing NaN-data  
    kgain = nanmean(tr_gain.gain,2);
    kphi  = nanmean(tr_phi.phi,2);
            
    % check if there aren't some NaNs in the correction data - that means user correction dataset contains some undefined values:
    if any(isnan(kgain)) || any(isnan(kphi))
        error('Transducer gain/phase correction data do not have sufficient frequency range!');
    end
    
    % get transducer correction uncertainty contribution:
    % correction may be rms dependent, but we may have not exact RMS value, so lets estimate worst case error from:
    % 1) the worst uncertainty for all rms-values
    % 2) the difference between max and min correction value for all rms-values
    % that should give us decent worst case estimate
    
    % 1) worst uncertainty (normal distr.):
    u_tg = max(tr_gain.u_gain,[],2);
    u_tp = max(tr_phi.u_phi,[],2);
    
    % 2) largest difference of all corr. data from mean corr. data (rectangular distr.):
    d_tg = max(max(tr_gain.gain,[],2) - kgain, kgain - min(tr_gain.gain,[],2));
    d_tp = max(max(tr_phi.phi,[],2)   - kphi,  kphi  - min(tr_phi.phi,[],2));         
    
    % combine:
    if ~isnan(d_tg)
        u_tg = (u_tg.^2 + d_tg.^2/3).^0.5;        
    end
    if ~isnan(d_tp)
        u_tp = (u_tp.^2 + d_tp.^2/3).^0.5;        
    end
    
    % --- evaluate uncertainty of the low level algorithm
    % note: this must be done here, because for the first call of MHFE we had not all required parameters
    if ~strcmpi(calcset.unc,'none')
    
        % get effective ADC + transducer SFDR:
        sfdr_sys = -20*log10(10^(-adc_sfdr.sfdr/20) + 10^(-tr_sfdr.sfdr/20));
                   
        % call low level MHFE algorithm to obtain estimate of the harmonic:
        %  note: this time with uncertainty becasue we know all the required parameters...
        din.jitter.v = datain.adc_jitter.v;
        din.adcres.v = lsb*adc_gain.gain(2)*kgain(2);
        din.sfdr.v = sfdr_sys;
        cset = calcset;
        cset.loc = 0.96; % calculate for k > 2 (nasty safety coefficient)
        cset.verbose = cset.verbose;  
        dout = qwtb('MFSF',din,cset);
        qwtb('TWM-MFSF','addpath'); % ###todo: fix qwtb so it does not loose the path every time another alg. is called
        % express 'standard' uncertainty:
        u_fx  = [0        dout.f.u  dout.f.u]'/2;
          Ax  = [dout.O.v dout.A.v  dout.A.v]';
        u_Ax  = [dout.O.u dout.A.u  dout.A.u]'./Ax.*A/2;
        u_phx = [0        dout.ph.u dout.ph.u]'/2;
        
        % copy spectra if available:
        if isfield(dout,'spec_f') && isfield(dout,'spec_A')
            % ###todo: scale it to actual level by corrections!
            dataout.spec_f = dout.spec_f;
            dataout.spec_A = dout.spec_A;
        end
                
    else
        % no uncertainty:
        u_fx  = [0*f];
        u_Ax  = [0*A];
        u_phx = [0*ph];
    end
    
    
    
       
    
    % absolute uncertainty of the frequency:
    %  timebase + algorithm         
    u_f = (u_f_tb.^2 + u_fx.^2).^0.5;
    
    
    % Now we know uncertainty of frequency, so calculate frequency contribution to the 'A' and 'ph':
    %  note: assume normal distribution 
    % for amplitude:
    u_Af = abs(A(H+2:end) - A(2:H+1))/df.*u_f(2:H+1);
    u_Af = [0;u_Af;u_Af];   
    % for phase:
    u_phf = abs(ph(H+2:end) - ph(2:H+1))/df.*u_f(2:H+1);
    u_phf = [0;u_phf;u_phf];
        
    
    % apply time-stamp phase correction:
    if tstmp_comp
        % note: assume frequency comming from digitizer tb. (f_org), because the timestamp comes also from dig. timebase
        ph = ph - datain.time_stamp.v.*f_org*2*pi;
        % calc. abs uncertainty contribution:
        u_ph_ts = 2*pi*((datain.time_stamp.u.*f_org).^2 + (datain.time_stamp.v.*u_f).^2).^0.5;
    end
       
    
    
    % note: the loading correction function already added uncertainty of tfer to 'A' and 'ph',
    % we need to subtract tfer uncertainty from the combined uncertainty comming from the tran. loading function:
    u_tg_rms = tr_gain_rms.u_gain;
    u_tp_rms = tr_phi_rms.u_phi;
    
    % absolute uncertainty of the amplitude:
    %  (transducer(rms)+adc) + transducer(null) - transducer(rms) + algorithm  
    u_A = (u_A.^2 + (A.*u_tg).^2 - (A.*u_tg_rms).^2 + u_Ax.^2 + u_Af.^2).^0.5;
    
    % absolute uncertainty of the phase:
    %  (transducer(rms)+adc) + transducer(null) - transducer(rms) + algorithm + timestamp
    u_ph = (u_ph.^2 + u_tp.^2 - u_tp_rms.^2 + u_phx.^2 + u_ph_ts.^2 + u_phf.^2).^0.5;
     
    

    
    
    % split virtual DC component and harmonics:
      dc = A(1);
    u_dc = u_A(1);
      f  = f(2:H+1);
    u_f  = u_f(2:H+1);
      A  = A(2:H+1);
    u_A  = u_A(2:H+1);
      ph = ph(2:H+1);
    u_ph = u_ph(2:H+1);
    
    % wrap phase to interval <-pi;+pi>:
    ph = mod(ph + pi,2*pi) - pi;
    
    % total harmonic distortion THD:
    thd = sum(A(2:end).^2)^0.5/A(1);
    
    % uncertainty estimate of THD based on the worst case:
    thd_a = sum((A(2:end) + u_A(2:end)).^2)^0.5/(A(1) - u_A(1));
    thd_b = sum((A(2:end) - u_A(2:end)).^2)^0.5/(A(1) + u_A(1));
    u_thd = max(abs([thd_a thd_b] - thd));
    
    % return calculated quantities:
    dataout.f0.v = f(1);
    dataout.f0.u = u_f(1)*loc2covg(calcset.loc,50);
    dataout.f.v = f;
    dataout.f.u = u_f*loc2covg(calcset.loc,50);           
    dataout.A.v = A;
    dataout.A.u = u_A*loc2covg(calcset.loc,50);
    dataout.phi.v = ph;
    dataout.phi.u = u_ph*loc2covg(calcset.loc,50);    
    dataout.dc.v = dc;
    dataout.dc.u = u_dc*loc2covg(calcset.loc,50);
    dataout.thd.v = 100*thd;
    dataout.thd.u = 100*u_thd*loc2covg(calcset.loc,50);   
        
           
    % --------------------------------------------------------------------
    % End of the demonstration algorithm.
    % --------------------------------------------------------------------


end % function


% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
