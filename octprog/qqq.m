clc;
clear all;

mfld = fileparts(mfilename('fullpath'));
cd(mfld); 

addpath([mfld filesep() 'info']);
addpath([mfld filesep() 'qwtb']);

qwtb_list_file = 'qwtb_list.info';

%qwtb_test(qwtb_list_file);

[ids, names] = qwtb_load_algorithms(qwtb_list_file);

[alginfo,ptab,unc_list,input_params] = qwtb_load_algorithm('SP-WFFT');

return


meas_root = [mfld '\..\temp\stst'];
file = [mfld '\..\temp\stst\session.info'];

meas = tpq_load_record(file);

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






