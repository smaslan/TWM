clc;
clear all;

mfld = fileparts(mfilename('fullpath'));
cd(mfld); 

addpath([mfld filesep() 'info']);
addpath([mfld filesep() 'qwtb']);


%qwtb_list_file = 'qwtb_list.info';

%qwtb_test(qwtb_list_file);

%[ids, names] = qwtb_load_algorithms(qwtb_list_file);

%qwtb_load_algorithm('iDFT2p');

file = 'f:\data\LVprog\TracePQM\temp\sim\session.info';

meas = tpq_load_record(file);

%correction_parse_section()


