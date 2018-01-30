function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-TEST.
%
% See also qwtb

    % samples count to synthesize:
    N = 1e5;
    
    % sampling rate [Hz]
    din.fs.v = 10000;
    
    % harmonic amplitudes:
    A =  [1    0.5  0.2]';
    % harmonic phases:
    ph = [0.1 -0.8  0.2]'*pi;
    % harmonic component index {1st, 2rd, ..., floor(N/2)}:
    fk = [1    5    round(0.4*N)]';
    
    
    % create some corretion table for the digitizer gain: 
    din.adc_gain_f.v = [0;1e3;1e6];
    din.adc_gain_a.v = [];
    din.adc_gain.v = [1.00; 1.10; 1.50];
    din.adc_gain.u = [0.01; 0.02; 0.03]; 
    % create some corretion table for the digitizer phase: 
    din.adc_phi_f.v = [0;1e3;1e6];
    din.adc_phi_a.v = [];
    din.adc_phi.v = [0.00; 0.10; 10.0];
    din.adc_phi.u = [0.01; 0.02;  2.0];
    
    % create some corretion table for the transducer gain: 
    din.tr_gain_f.v = [0;1e3;1e6];
    din.tr_gain_a.v = [];
    din.tr_gain.v = [1.00; 0.80; 0.60];
    din.tr_gain.u = [0.01; 0.02; 0.05]; 
    % create some corretion table for the transducer phase: 
    din.tr_phi_f.v = [0;1e3;1e6];
    din.tr_phi_a.v = [];
    din.tr_phi.v = [0.00; -0.30; -5.0];
    din.tr_phi.u = [0.01;  0.02;  2.0];
    
    
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
    
    % synthesize waveform (crippled for Matlab < 2016b):
    % u = A_syn.*sin(t.*fk + ph_syn);
    u = bsxfun(@times, A_syn', sin(bsxfun(@plus, bsxfun(@times, t, fk'), ph_syn')));
    % sum the harmonic components to a single composite signal:
    u = sum(u,2);
    
    % store to the QWTB input list:
    din.y.v = u;

    % --- execute the algorithm:
    dout = qwtb('TWM-TEST',din);
    
    % --- compare calcualted results with desired:
    if any(abs([dout.amp.v(1+fk)] - A(:))./A(:) > 1e-6)
        error('TWM-TEST testing: calculated amplitudes do not match!');
    end
    if any(abs([dout.phi.v(1+fk)] - ph(:)) > 10e-6)                                    
        error('TWM-TEST testing: calculated phases do not match!');          
    end
    if abs(dout.rms.v - rms)/rms > 1e-7
        error('TWM-TEST testing: calculated rms value does not match!');
    end
                                                                         
    
end
   