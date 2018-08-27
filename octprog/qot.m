clc;
clear all;

warning('off');

mfld = fileparts(mfilename('fullpath'));
cd(mfld); 

addpath([mfld filesep() 'info']);
addpath([mfld filesep() 'qwtb']);


%correction_transducer_loading()
%return


%meas = [mfld '\..\temp\sim\DIGITIZER\HP3458_demo'];
%meas = [mfld '\..\temp\sim\session_doc'];
%meas = [mfld '\..\temp\test_3chn\session'];
%meas = [mfld '\..\temp\test_3chn\ss_dual'];
%meas = [mfld '\..\temp\pokus\session'];

meas = [mfld '\..\temp\sertest'];

cfg.max_dim = 1;

[inf] = qwtb_get_result2info(meas, '', cfg, {})




return


unc = 'none';

tic
%data = tpq_load_record(meas);
qwtb_exec_algorithm(meas,unc);
toc




return


inf = infoload(meas);



tic();
idata = infoparse(inf,'all');
toc()

tran = correction_load_transducer()


%meas = [mfld '\..\temp\sim\session_doc'];
%data = tpq_load_record(meas);



return


%meas_file = [mfld filesep() '..' filesep() 'data' filesep() 'session.info'];


%tr_path = [mfld() '\..\data\corrections\transducers\shunt_100mA\shunt_100mA_313'];
%tab_path = [mfld() '\..\data\corrections\transducers\shunt_100mA\fdep.csv'];
%tab_path = [mfld() '\..\data\corrections\transducers\shunt_100mA\fdep_2D_no_f.csv'];
%tab_path = [mfld() '\..\data\corrections\transducers\shunt_100mA\fdep_2D_no_a.csv'];
%tab_path = [mfld() '\..\data\corrections\transducers\shunt_100mA\fdep_2D_no_fa.csv'];
%tab_path = [mfld() '\..\data\corrections\transducers\shunt_100mA\fdep_1D.csv'];
%tab_path = [mfld() '\..\data\corrections\transducers\shunt_100mA\fdep_1D_no_f.csv'];
%tbl = correction_load_table(tab_path,'',{'f';'gain';'U_gain'})

%correction_load_transducer(tr_path)



ta.rms = [1 2 3];
ta.axis_x = 'rms';
ta.has_x = 1;
ta.f = [1;2;3];
ta.axis_y = 'f';
ta.has_y = 1;
ta.Z = [1 1 1;2 2 2;3 3 3];
ta.quant_names = {'Z'};

tb.rms = [1 2];
tb.axis_x = 'rms';
tb.has_x = 0;
tb.f = [1;2];
tb.axis_y = 'f';
tb.has_y = 0;
tb.Z = [1];
tb.quant_names = {'Z'};

tlst = correction_expand_tables({ta,tb});
tlst{1}
tlst{2}





