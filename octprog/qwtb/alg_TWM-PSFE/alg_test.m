function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-TEST.
%
% See also qwtb

    % samples count to synthesize:
    N = 1e5;
    
    % sampling rate [Hz]
    din.fs.v = 10000;
    
    % harmonic amplitudes:
    A =  [1       0.1  0.02]';
    % harmonic phases:
    ph = [0.1/pi -0.8  0.2]'*pi;
    % harmonic component index {1st, 2rd, ..., floor(N/2)}:
    fk = [1000   5000  round(0.4*N)]';
    
    
    % generate some time-stamp of the digitizer channel:
    % note: the algorithm must 'unroll' the calculated phase accordingly,
    %       so whatever is put here should have no effect to the estimated phase         
    din.time_stamp.v = 0.12345;
        
    % create some corretion table for the digitizer gain: 
    din.adc_gain_f.v = [0;1e3;1e6];
    din.adc_gain_a.v = [];
    din.adc_gain.v = [1.00; 1.10; 1.50];
    din.adc_gain.u = [0.01; 0.02; 0.03]; 
    % create some corretion table for the digitizer phase: 
    din.adc_phi_f.v = [0;1e3;1e6];
    din.adc_phi_a.v = [];
    din.adc_phi.v = [0.00; 0.10; 0.50]*pi;
    din.adc_phi.u = [0.01; 0.02; 0.05]*pi;
    % create corretion of the digitizer timebase:
    din.adc_freq.v = 0.001;
    din.adc_freq.u = 0.000005;
    
    
    % create some corretion table for the transducer gain: 
    din.tr_gain_f.v = [0;1e3;1e6];
    din.tr_gain_a.v = [];
    din.tr_gain.v = [1.00; 0.80; 0.60];
    din.tr_gain.u = [0.01; 0.02; 0.05]; 
    % create some corretion table for the transducer phase: 
    din.tr_phi_f.v = [0;1e3;1e6];
    din.tr_phi_a.v = [];
    din.tr_phi.v = [0.00; -0.20; -0.50]*pi;
    din.tr_phi.u = [0.01;  0.02;  0.05]*pi;
    
    
    % Restore orientations of the input vectors to originals (before passing via QWTB)
    din.y.v = ones(10,1); % fake data vector just to make following function work!
    [dout,cfg] = qwtb_restore_twm_input_dims(din,1);
    % Rebuild TWM style correction tables:
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
    u = sum(u,2);
    
    % store to the QWTB input list:
    din.y.v = u;

    % --- execute the algorithm:
    dout = qwtb('TWM-PSFE',din)
    
    
    % check frequency estimate:
    assert(abs(dout.f.v - fx(1))./fx(1) < 1e-8, 'Estimated freq. does not match generated one.');                                                     
    
end
   