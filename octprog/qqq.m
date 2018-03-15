clc;
clear all;

warning('off');

mfld = fileparts(mfilename('fullpath'));
cd(mfld); 

addpath([mfld filesep() 'info']);
addpath([mfld filesep() 'qwtb']);

qwtb('TWM-THDWFFT','test')
%qwtb('TWM-PWRTEST','test')
%qwtb('TWM-TEST','test')
%qwtb('TWM-PSFE','test')

return






algi = qwtb('TWM-TEST','info');

N = 11;
din.Ts.v = 1/10000;

% harmonic amplitudes:
A =  [1 0.5];
% harmonic phase:
ph = [0.1 -0.8]*pi
% harmonic frequency relative to 1/(N*Ts):
fk = [1 5  ];

% time vector:
t(:,1) = [0:N-1]*din.Ts.v;

% synthesize waveform:
din.y.v = sum(A.*sin(t*2*pi.*fk/N/din.Ts.v + ph),2);

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


tic
qwtb('TWM-TEST',din);
toc





%meas_root = [mfld '\..\temp\stst'];
%file = [mfld '\..\temp\sim\session_doc.info'];

%meas = tpq_load_record(file,-1,1);
%qwtb_exec_algorithm(file,0,1,1);

return;

% process all repetition cycles
%for m = 1:meas.repetitions_count
%    qwtb_exec_algorithm(file,0,1,m);
%end

cfg.max_dim = 1;
cfg.max_array = 50;
cfg.unc_mode = 1;
cfg.group_mode = 0;
cfg.phi_mode = 0;

csv = qwtb_get_results(meas_root,0,'',cfg);

plot_cfg.xlog = 1;                             
plot_cfg.ylog = 1;
plot_cfg.box = 1;
plot_cfg.grid = 1;
plot_cfg.legend = '';

qwtb_plot_result(meas_root, 0, '', 0, cfg, 'A', plot_cfg)







