function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-PWRTEST.
%
% See also qwtb

    %### invalid - residue of other alg.

    % samples count to synthesize:
    N = 1e4;
    
    % sampling rate [Hz]
    din.fs.v = 10000;
    
    % ADC aperture [s]:
    din.aperture.v = 10e-6;
    
    % aperture correction state:
    din.u_adc_aper_corr.v = 1;
    din.u_lo_adc_aper_corr = din.u_adc_aper_corr;
    din.i_adc_aper_corr = din.u_adc_aper_corr;
    din.i_lo_adc_aper_corr = din.u_adc_aper_corr;
      
    
    % fundamental frequency [Hz]:
    f0 = 53;
    
    chns = {}; id = 0;    
    
    % -- VOLTAGE:
    id = id + 1;
    % channel parameters:
    chns{id}.name = 'u';
    % harmonic amplitudes:
    chns{id}.A  = [1    0.5  0.2]';
    % harmonic phases:
    chns{id}.ph = [0   -0.8  0.2]'*pi;
    % harmonic component index {1st, 2rd, ..., floor(N/2)}:
    chns{id}.fk = [1    5    round(0.4*N)]';
    
    % -- CURRENT:
    id = id + 1;
    % channel parameters:
    chns{id}.name = 'i';
    % harmonic amplitudes:
    chns{id}.A  = [0.5   0.5  0.2]';
    % harmonic phases:
    chns{id}.ph = [0.1  -0.8  0.2]'*pi;
    % harmonic component index {1st, 2rd, ..., floor(N/2)}:
    chns{id}.fk = [1     5    round(0.4*N)]';
        
    if true
        % -- voltage channel:
        % create some corretion table for the digitizer gain: 
        din.u_adc_gain_f.v = [0;1e3;1e6];
        din.u_adc_gain_a.v = [];
        din.u_adc_gain.v = [1.000000; 1.010000; 1.100000];
        din.u_adc_gain.u = [0.000005; 0.000020; 0.000300]; 
        % create some corretion table for the digitizer phase: 
        din.u_adc_phi_f.v = [0;1e3;1e6];
        din.u_adc_phi_a.v = [];
        din.u_adc_phi.v = [0.0000; 0.000100; 0.1000];
        din.u_adc_phi.u = [0.0001; 0.000020; 0.0010];
        % create identical low-side channel:
        din.u_lo_adc_gain_f = din.u_adc_gain_f;
        din.u_lo_adc_gain_a = din.u_adc_gain_a;
        din.u_lo_adc_gain = din.u_adc_gain;
        din.u_lo_adc_phi_f = din.u_adc_phi_f;
        din.u_lo_adc_phi_a = din.u_adc_phi_a;
        din.u_lo_adc_phi = din.u_adc_phi;
        
        % create some corretion table for the transducer gain: 
        din.u_tr_gain_f.v = [0;1e3;1e6];
        din.u_tr_gain_a.v = [];
        din.u_tr_gain.v = [70.00000; 70.80000; 70.600];
        din.u_tr_gain.u = [ 0.00010;  0.00020;  0.005]; 
        % create some corretion table for the transducer phase: 
        din.u_tr_phi_f.v = [0;1e3;1e6];
        din.u_tr_phi_a.v = [];
        din.u_tr_phi.v = [0.00000; -0.00300; -0.3000];
        din.u_tr_phi.u = [0.00010;  0.00020;  0.0030];
        
        
        % -- current channel:
        % create some corretion table for the digitizer gain: 
        din.i_adc_gain_f = din.u_adc_gain_f;
        din.i_adc_gain_a = din.u_adc_gain_a;
        din.i_adc_gain = din.u_adc_gain; 
        din.i_adc_phi_f = din.u_adc_phi_f;
        din.i_adc_phi_a = din.u_adc_phi_a;
        din.i_adc_phi = din.u_adc_phi;
        % create some corretion table for the digitizer phase: 
        din.u_adc_phi_f.v = [0;1e3;1e6];
        din.u_adc_phi_a.v = [];
        din.u_adc_phi.v = [0.0000; 0.000100; 0.1000];
        din.u_adc_phi.u = [0.0001; 0.000020; 0.0010];
        din.i_lo_adc_gain_f = din.i_adc_gain_f;
        din.i_lo_adc_gain_a = din.i_adc_gain_a;
        din.i_lo_adc_gain = din.i_adc_gain;
        din.i_lo_adc_phi_f = din.i_adc_phi_f;
        din.i_lo_adc_phi_a = din.i_adc_phi_a;
        din.i_lo_adc_phi = din.i_adc_phi;     
        
        % create some corretion table for the transducer gain: 
        din.i_tr_gain_f.v = [0;1e3;1e6];
        din.i_tr_gain_a.v = [];
        din.i_tr_gain.v = [ 0.500000; 0.510000; 0.60000];
        din.i_tr_gain.u = [ 0.000010; 0.000020; 0.00050]; 
        % create some corretion table for the transducer phase: 
        din.i_tr_phi_f.v = [0;1e3;1e6];
        din.i_tr_phi_a.v = [];
        din.i_tr_phi.v = [0.00000; -0.00300; -0.3000];
        din.i_tr_phi.u = [0.00010;  0.00020;  0.0030];
    
    end
           
    
    % Restore orientations of the input vectors to originals (before passing via QWTB)
    din.u.v = ones(10,1); % fake data vector just to make following function work!
    din.i.v = ones(10,1); % fake data vector just to make following function work!
    [dout,cfg] = qwtb_restore_twm_input_dims(din,1);
    % Rebuild TWM style correction tables:
    tab = qwtb_restore_correction_tables(din,cfg);
    
    
    for c = 1:numel(chns)
    
        % get current channel:
        chn = chns{c};
        
        % channel prefix (eg.: 'u_'):
        cpfx = [chn.name '_'];
        % high-side channel prefix:
        chpfx = [chn.name '_'];
        % low-side channel prefix:
        clpfx = [chn.name '_lo_'];
    
        % calculate actual frequencies of the harmonics:
        fx = chn.fk*f0;
        
        % rms level of the input signal:
        rms = sum(0.5*chn.A.^2)^0.5;        
        chns{c}.rms = rms;
        
        % ###todo: implement differential mode
        
        % interpolate transducer gain/phase to the measured frequencies and rms amplitude:
        k_gain = correction_interp_table(getfield(tab,[cpfx 'tr_gain']),rms,fx);   
        k_phi =  correction_interp_table(getfield(tab,[cpfx 'tr_phi']), rms,fx);
        
        % apply transducer gain:
        A_syn = chn.A./k_gain.gain;
        ph_syn = chn.ph - k_phi.phi;
        
        % interpolate digitizer gain/phase to the measured frequencies and amplitudes:
        k_gain = correction_interp_table(getfield(tab,[chpfx 'adc_gain']),A_syn,fx,'f',1);    
        k_phi =  correction_interp_table(getfield(tab,[chpfx 'adc_phi']), A_syn,fx,'f',1);
        
        % apply digitizer gain:
        A_syn = A_syn./k_gain.gain;
        ph_syn = ph_syn - k_phi.phi;
        
        % generate relative time <0;2*pi):
        t(:,1) = [0:N-1]/din.fs.v*2*pi;
        
        % synthesize waveform (crippled for Matlab < 2016b):
        % u = A_syn.*sin(t.*fk + ph_syn);
        u = bsxfun(@times, A_syn', sin(bsxfun(@plus, bsxfun(@times, t, fx'), ph_syn')));
        % sum the harmonic components to a single composite signal:
        u = sum(u,2);
        
        % store to the QWTB input list:
        din = setfield(din, chn.name, struct('v',u));
    
    end    

    % --- execute the algorithm:
    dout = qwtb('TWM-PWRTEST',din);
    
    U_ref = chns{1}.rms
    I_ref = chns{2}.rms
    
    dout.U
    dout.I
    dout.P
    
    % --- compare calcualted results with desired:
%     if any(abs([dout.amp.v(1+fk)] - A(:))./A(:) > 1e-6)
%         error('TWM-TEST testing: calculated amplitudes do not match!');
%     end
%     if any(abs([dout.phi.v(1+fk)] - ph(:)) > 10e-6)                                    
%         error('TWM-TEST testing: calculated phases do not match!');          
%     end
%     if abs(dout.rms.v - rms)/rms > 1e-7
%         error('TWM-TEST testing: calculated rms value does not match!');
%     end
                                                                         
    
end
   