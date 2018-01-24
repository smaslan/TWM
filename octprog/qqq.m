clc;
clear all;

warning('off');

mfld = fileparts(mfilename('fullpath'));
cd(mfld); 

addpath([mfld filesep() 'info']);
addpath([mfld filesep() 'qwtb']);


algi = qwtb('TWM-TEST','info');

din.Ts.v = 1;
din.y.v = rand(100,1);

din.adc_gain_f.v = [1 2 3];
din.adc_gain_a.v = [];
din.adc_gain.v = [1 2 3];
din.adc_gain.u = [0.1 0.2 0.3]; 

qwtb('TWM-TEST',din);





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







