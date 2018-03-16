function alg_test(calcset) %<<<1
% Part of QWTB. Test script for algorithm TWM-THDWFFT.
%
% See also qwtb




    % --- correction data ---
    % generate some digitizer gain transfer:
    din.adc_gain.v =   [1.0; 0.5; 0.2];
    din.adc_gain.u =   [0.0; 0.0; 0.0];
    din.adc_gain_f.v = [0;   1e4; 1e6];
    din.adc_gain_a.v = [];
    
    % generate some transducer gain transfer:
    din.tr_gain.v =   [2.000; 2.001; 2.002; 2.005; 2.10];
    din.tr_gain.u =   [0.000; 0.000; 0.000; 0.000; 0.00];
    din.tr_gain_f.v = [0;     1e2;   1e3;   1e4;   1e6];
    din.tr_gain_a.v = [];
    
    % generate some SFDR values for digitizer:
    din.adc_sfdr.v =   [180];
    din.adc_sfdr_f.v = [];
    din.adc_sfdr_a.v = [];
    
    % generate some SFDR values for transducer:
    din.tr_sfdr.v =   [180];
    din.tr_sfdr_f.v = [];
    din.tr_sfdr_a.v = [];
    
    % transducer type:
    din.tr_type.v = 'shunt';
    
    % fake some digitizer parameters:
    din.adc_nrng.v = 1.0; % +/- range
    din.adc_bits.v = 24;  % bit resolution
    
    
    % these are used just for convenient use of the correction data:
    %   Restore orientations of the input vectors to originals (before passing via QWTB)
    din.y.v = ones(10,1); % fake data vector just to make following function work!
    [din,scfg] = qwtb_restore_twm_input_dims(din,1);
    %   Rebuild TWM style correction tables (just for more convenient calculations):
    tab = qwtb_restore_correction_tables(din,scfg);
        
    
    % --- algorithm setup ---
    % plot spectrum?
    din.plot.v = 0;
    % harmonics count to analyze:
    din.H.v = 10;
    % verbose mode:
    din.verbose.v = 1;
    % initial guess of the fundamental frequency (comment if autodetect needed)
    %cfg.f0.v = 1e3;
    % fix scalloping error?
    din.scallop_fix.v = 0;
    % maximum bandwidth to analyze (comment if not limited):
    %cfg.band.v = 100e3;
    % fundamental frequency search mode (comment for default):
    din.f0_mode.v = 'psfe';
        
    
    
    % --- THD waveform simulator setup ---    
    % rms sampling jitter [s]:
    sim.t_jitter = 0;
    % sampling rate [Hz]:
    sim.fs = 50e3;
    sim.fs_unc = 0; % sampling freq. uncertainty
    % fundamental freq [Hz]:
    sim.f0 = 1001.2345;        
    % samples count:
    sim.sample_count = round(sim.fs/sim.f0*200);            
    % repeated measurements (averages) count:
    sim.avg_count = 10;
    % fundamental amplitude [V]:
    sim.A0 = 0.9;
    % --- to generate (select one method):
        % 1) desired THD (fundamental referenced) 
        %sim.k1 = 0.005; %logspace(log10(0.0001),log10(10),50);
        % 2) or fixed harmonics, identical amplitudes [V]
        %sim.A = 0.1; %logspace(log10(1e-7),log10(1e-5),20);
        % 3) or random amplitudes in logspace, range from-to [V]
        sim.A_min = 1e-6;
        sim.A_max = 1000e-6;
    % harmonics count to generate (including fundamental):
    sim.H = din.H.v;
    % ADC noise level in DFT spectrum [V]:
    sim.adc_noise_lev = 1e-6;
    % enable randomization of quantities with uncertainties (to simulate uncertainty):
    %   note: disabling this will also ignore SFDR errors, jitter
    sim.randomize = 0;
    % copy algorithm input quantities to the simulator's structure:
    sim.corr = din;
    sim.tab = tab;
    
    % --- simulate waveforms ---
    [sig,fs_out,k1_out,h_amps] = thd_sim_wave(sim);
    
    % store simulated waveform data:
    din.y.v = sig;
    din.fs.v = fs_out;
    
    % --- calculate THD ---
    dout = qwtb('TWM-THDWFFT',din);
    
    % print results:
    fprintf('\nResults:\n');
    fprintf('  THD ref: %0.4f%%, calc: %0.4f%% +- %0.4f%%, dev: %0.4f%%, %%-of-spec: %-3.0f\n', k1_out, dout.thd.v, dout.thd.u, dout.thd.v - k1_out, abs(dout.thd.v - k1_out)/dout.thd.u*100);
    fprintf('\nHarmonics:\n');
    fprintf(    '  ID    REF         CALC                     DIFF         %%-OF-UNC\n');
    for h = 1:dout.H.v
        fprintf('  H%02d:  %0.7f   %0.7f +- %0.7f   %+0.7f   %-3.0f\n', h, h_amps(h), dout.h.v(h), dout.h.u(h), dout.h.v(h) - h_amps(h), abs(dout.h.v(h) - h_amps(h))/dout.h.u(h)*100);
    end   
    
    % check result correctness:
    assert(any(abs(dout.h.v - h_amps) < dout.h.u), 'Calculated harmonic amplitudes out of calculated uncertainty!');
    assert(abs(dout.thd.v - k1_out) < dout.thd.u, 'Calculated THD out of calculated uncertainty!');
                                                         
    
end
   