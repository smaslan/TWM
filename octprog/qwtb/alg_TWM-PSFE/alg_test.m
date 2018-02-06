function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-TEST.
%
% See also qwtb

    % samples count to synthesize:
    N = 1e5;
    
    % sampling rate [Hz]
    din.fs.v = 10000;
    
    % harmonic amplitudes:
    A =    [1       0.1  0.02]';
    % harmonic phases:
    ph =   [0.1/pi -0.8  0.2]'*pi;
    % harmonic component index {1st, 2rd, ..., floor(N/2)}:
    fk =   [1000   5000  round(0.4*N)]';
    
    % non-zero to generate differential input signal:
    is_diff = 0;
    % for differential only: amplitude of the low-side terminal: 
    A_lo = A*0.1;
        
    
    % ADC aperture [s]:
    % note: non-zero value will simulate aperture gain/phase error 
    din.adc_aper.v = 20e-6;
    
    % ADC aperture correction enabled:
    % note: non-zero value will enable correction of the gain/phase error by alg.
    din.adc_aper_corr.v = 1;
    
    
    % generate some time-stamp of the digitizer channel:
    % note: the algorithm must 'unroll' the calculated phase accordingly,
    %       so whatever is put here should have no effect to the estimated phase         
    din.time_stamp.v = 0.12345;
        
    % create some corretion table for the digitizer gain: 
    din.adc_gain_f.v = [0;1e3;1e6];
    din.adc_gain_a.v = [];
    din.adc_gain.v = [1.000; 1.100; 1.500];
    din.adc_gain.u = [0.001; 0.002; 0.003]; 
    % create some corretion table for the digitizer phase: 
    din.adc_phi_f.v = [0;1e3;1e6];
    din.adc_phi_a.v = [];
    din.adc_phi.v = [0.000; 0.100; 0.500]*pi;
    din.adc_phi.u = [0.001; 0.002; 0.005]*pi;
    % create corretion of the digitizer timebase:
    din.adc_freq.v = 0.001;
    din.adc_freq.u = 0.000005;
    
    
    % create some corretion table for the transducer gain: 
    din.tr_gain_f.v = [0;1e3;1e6];
    din.tr_gain_a.v = [];
    din.tr_gain.v = [1.000; 0.800; 0.600];
    din.tr_gain.u = [0.001; 0.002; 0.005]; 
    % create some corretion table for the transducer phase: 
    din.tr_phi_f.v = [0;1e3;1e6];
    din.tr_phi_a.v = [];
    din.tr_phi.v = [0.000; -0.200; -0.500]*pi;
    din.tr_phi.u = [0.001;  0.002;  0.005]*pi;
    
    
    % Restore orientations of the input vectors to originals (before passing via QWTB)
    din.y.v = ones(10,1); % fake data vector just to make following function work!
    [dout,cfg] = qwtb_restore_twm_input_dims(din,1);
    % Rebuild TWM style correction tables (just for more convenient calculations):
    tab = qwtb_restore_correction_tables(din,cfg);
    
    
    % calculate actual frequencies of the harmonics:
    fx = fk/N*din.fs.v;
    
    % rms level of the input signal:
    rms = sum(0.5*A.^2)^0.5;
    
    % interpolate transducer gain/phase to the measured frequencies and rms amplitude:
    k_gain = correction_interp_table(tab.tr_gain,rms,fx);    
    k_phi = correction_interp_table(tab.tr_phi,rms,fx);
    
    % apply transducer gain:
    A_syn = A./k_gain.gain;
    ph_syn = ph - k_phi.phi;
    
    % interpolate digitizer gain/phase to the measured frequencies and amplitudes:
    k_gain = correction_interp_table(tab.adc_gain,A,fx,'f',1);    
    k_phi = correction_interp_table(tab.adc_phi,A,fx,'f',1);
    
    % apply digitizer gain:
    A_syn = A_syn./k_gain.gain;
    ph_syn = ph_syn - k_phi.phi;
    
    
    % calculate aperture effect:
    ta = din.adc_aper.v;    
    % apply gain error:
    A_ap = sin(pi*ta*fx)./(pi*ta*fx);
    % apply phase error:
    ph_ap = -(pi*ta*fx);
        
    % apply aperture effect (if aperture value exists only):
    if abs(din.adc_aper.v) > 1e-12
        A_syn = A_syn.*A_ap;
        ph_syn = ph_syn + ph_ap;
    end
    
    % calculate low-side of the differential voltage pair (just for diff. mode):
    % note: assuming zero phase shift of the low-side
    A_syn_lo = A_syn.*A_lo./A;
     
    
    
    % generate relative time <2;2*pi):
    t(:,1) = [0:N-1]/N*2*pi;
    
    % apply timebase error (inverse of relative correction, not negation of the correction!):
    % positivice tb correction - longer sampling intervals
    t = t.*(1 + din.adc_freq.v);
       
    % apply time-stamp to the phase of the synthesized signals:
    % note: operate in local timebase, not actual time, because ts. are derived from local dig. timebase 
    ph_syn = ph_syn + din.time_stamp.v*fk/(N/din.fs.v)*(1 + din.adc_freq.v)*2*pi;
           
    % synthesize waveform (crippled for Matlab < 2016b):
    % u = A_syn.*sin(t.*fk + ph_syn);
    u = bsxfun(@times, A_syn', sin(bsxfun(@plus, bsxfun(@times, t, fk'), ph_syn')));
    % sum the harmonic components to a single composite signal:
    din.y.v = sum(u,2);
    
    if is_diff

        % synthesize waveform (crippled for Matlab < 2016b):
        % u = A_syn_lo.*sin(t.*fk + ph_syn);
        u = bsxfun(@times, A_syn_lo', sin(bsxfun(@plus, bsxfun(@times, t, fk'), ph_syn')));
        % sum the harmonic components to a single composite signal:
        din.y_lo.v = sum(u,2);
        
    end
        

    % --- execute the algorithm:
    dout = qwtb('TWM-PSFE',din)
    
    
    % check frequency estimate:
    assert(abs(dout.f.v - fx(1))./fx(1) < 1e-8, 'Estimated freq. does not match generated one.');
    
    if ~is_diff
    
        % calc. reference amp/phase:
        if din.adc_aper_corr.v
            A_ref = A;
            ph_ref = ph;
        else
            A_ref = A.*A_ap;
            ph_ref = ph + ph_ap;
        end
    
        % check amplitude match     
        assert(abs(dout.A.v - A_ref(1))./A_ref(1) < 1e-6, 'Estimated amplitude does not match generated one.');
        
        % check phase match     
        assert(abs(dout.phi.v - ph_ref(1)) < 1e-6, 'Estimated phase does not match generated one.'); 
    end                                                     
    
end
   