clc;
%clear all;

warning('off');

mfld = fileparts(mfilename('fullpath'));
cd(mfld); 

addpath([mfld filesep() 'info']);
addpath([mfld filesep() 'qwtb']);


meas = [mfld '\..\temp\test_sim\session.info'];

job_folder = fullfile(mfld, 'mc_rubbish');

cfg.parallel_cfg.mc_tmpdir = job_folder;
cfg.parallel_cfg.time.year = 2020;
cfg.parallel_cfg.time.month = 2;
cfg.parallel_cfg.time.day = 2;
cfg.parallel_cfg.time.hour = 12;
cfg.parallel_cfg.time.minute = 30;
cfg.parallel_cfg.time.second = 55;


job_list = qwtb_exec_clearjobs(cfg.parallel_cfg.mc_tmpdir);

total = 10;
for k = 1:total
    job_file = qwtb_exec_makejob(meas,'',1,k,1,1,cfg);
    job_list{end+1,1} = job_file;
end
 
while true 
    [job_list, done] = qwtb_exec_checkjobs(job_list);
    done
    total = total - done;
    if total == 0
        break
    else         
        pause(0.1);
    end    
end

%qwtb_exec_algorithm(meas,'',1,1,1);



return

%correction_transducer_loading()
%return


%meas = [mfld '\..\temp\sim\DIGITIZER\HP3458_demo'];
%meas = [mfld '\..\temp\sim\session_doc'];
%meas = [mfld '\..\temp\test_3chn\session'];
%meas = [mfld '\..\temp\test_3chn\ss_dual'];
%meas = [mfld '\..\temp\pokus\session'];

%meas = [mfld '\..\temp\stab_3458A'];

%meas = [mfld '\..\temp\wbtest\session.info'];

unc = 'none';

%meas = [mfld '\test\session.info'];
meas = 'f:\prace\cvi\test1';

%qwtb_exec_algorithm(meas,unc,0,1,1);
%res_id, alg_id, cfg, var_list
qwtb_get_results(meas, -1, '')

return


cfg.max_dim = 1;

%[inf] = qwtb_get_result2info(meas, '', cfg, {})

cfg.max_array = 10000;
cfg.phi_ref_chn = 1;
res = qwtb_load_results(meas,0,'',cfg,{'A','phi'});

R = numel(res);
for k = 1:R
    gain(k,1) = res{k}{2}{1}.val/res{k}{1}{1}.val;
    phi(k,1) = res{k}{2}{2}.val; 
end


din.y.v = gain;
din.Ts.v = 70;
dout = qwtb('OADEV',din);
figure; hold on;
loglog(dout.tau.v, dout.oadev.v, '-b')
loglog(dout.tau.v, dout.oadev.v + dout.oadev.u, '-k')
loglog(dout.tau.v, dout.oadev.v - dout.oadev.u, '-k')
hold off;

din.y.v = phi;
din.Ts.v = 70;
dout = qwtb('OADEV',din);
figure; hold on;
loglog(dout.tau.v, dout.oadev.v, '-b')
loglog(dout.tau.v, dout.oadev.v + dout.oadev.u, '-k')
loglog(dout.tau.v, dout.oadev.v - dout.oadev.u, '-k')
hold off;



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





