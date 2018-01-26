function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-TEST.
%
% See also qwtb

    % samples count to synthesize:
    N = 21;
    
    % sampling rate [Hz]
    din.fs.v = 10000;
    
    % harmonic amplitudes:
    A =  [1 0.5];
    % harmonic phases:
    ph = [0.1 -0.8]*pi
    % harmonic component index {1st, 2rd, ..., floor(N/2)}:
    fk = [1 5 round(0.4*N)];
    
    
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
    
    % interpolate digitizer gain/phase to the measured frequencies and amplitudes:
    k_gain = correction_interp_table(tab.adc_gain,A,fx,'f',1);    
    k_phi = correction_interp_table(tab.adc_phi,A,fx,'f',1);
    
    
    
    
    % generate relative time <2;2*pi):
    t(:,1) = [0:N-1]/N*2*pi;
    
    % synthesize waveform (crippled for Matlab < 2016b):
    % u = A.*sin(t.*fk + ph);
    u = bsxfun(@times, A, sin(bsxfun(@plus, bsxfun(@times, t, fk), ph)));
    % sum the harmonic components to a single composite signal:
    u = sum(u,2);
    




end
