clc;
clear all;

warning('off');

mfld = fileparts(mfilename('fullpath'));
cd(mfld); 

addpath([mfld filesep() 'info']);
addpath([mfld filesep() 'qwtb']);


meas_file = [mfld filesep() '..' filesep() 'data' filesep() 'session.info'];


%qwtb_exec_algorithm(meas_file);

meas_root = fileparts(meas_file);

qwtb_get_results(meas_root, 0)




%data = tpq_load_record(meas_file);




%inf = qwtb('ADEV','info');
%N = 10000;
%di.y.v = randn(N,1);
%di.Ts.v = 1;
%dout = qwtb('ADEV',di);








%qwtb_list_file = 'qwtb_list.info';

%qwtb_test(qwtb_list_file);

%[ids, names] = qwtb_load_algorithms(qwtb_list_file);

%qwtb_load_algorithm('iDFT2p');

%file = 'f:\data\LVprog\TracePQM\temp\sim\session.info';

%meas = tpq_load_record(file);

%correction_parse_section()


