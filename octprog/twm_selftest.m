function [] = twm_selftest(tmp_path)
% This extremely messy function is designed to validate the TWM functions.
% It generates fake measurement folder with all possible corrections
% and some fake records and then it executes fake algorithm TWM-VALID
% which should return copy of the inputs, which are saved to the measurement
% folder and loaded again and compared to originally generates ones.
% So the function should validate entire chain of data loading->processing->
% storing->results loading. In particular it validates the functions:
%   tpq_load_data()
%   correction_load_digitizer()
%   correction_load_transducer()
%   qwtb_exec_algorithm()
%   qwtb_get_results()
%   qwtb_load_results()
%   qwtb_parse_result()
%   qwtb_average_results()
%   qwtb_store_results()
%   * also their subfunctions obviously ...
%
% [] = twm_selftest()
% [] = twm_selftest(tmp_path)
%
% Parameters:
%   tmp_path - optional path to the folder, where the selftest measurement
%              data are generated. If not available, the data are generated
%              in algorithm's folder

    % current path
    mpath = [fileparts(mfilename('fullpath')) filesep];
    
    if ~exist('tmp_path','var')
        tmp_path = [mpath '_tmp_data'];
    end
    
    % add some component paths:
    addpath([mpath 'info']);
    addpath([mpath 'qwtb']);
    
    % test configurations:
    runid = 0;
    runid = runid + 1; runz{runid} = struct('mode','y', 'is_diff',0);
    runid = runid + 1; runz{runid} = struct('mode','y', 'is_diff',1);
    runid = runid + 1; runz{runid} = struct('mode','ui', 'is_diff',[0 0]);
    runid = runid + 1; runz{runid} = struct('mode','ui', 'is_diff',[0 1]);
    runid = runid + 1; runz{runid} = struct('mode','ui', 'is_diff',[1 0]);
    runid = runid + 1; runz{runid} = struct('mode','ui', 'is_diff',[1 1]);
    
    % verbose level (0: stfu, 1: small talk, 2: all):
    verbose = 2;    
    
    try 
        % --- for each test combination --- 
        for runid = 1:numel(runz)
        
            % QWTB wrapper control variable:
            global twm_selftest_control;    
            twm_selftest_control = {};
            
            % channel configuration:
            %mode = 'y';
            %mode = 'ui';
            mode = runz{runid}.mode;
            
            % channel diff modes:
            %is_diff = 0;
            %is_diff = [0 1];
            is_diff = runz{runid}.is_diff;
            
            % print test setup:
            if verbose
                fprintf('=== mode: %s, is_diff: %s ===\n\n',mode,sprintf('%.0f ',is_diff));
            end
            
            % sumup total channels count:
            if strcmpi(mode,'y')
                chn_n = 1;
                tr_types = {'divider'};
                tr_pfx = {''};
                chn_name = {'y'};
            elseif strcmpi(mode,'ui')
                chn_n = 2;
                tr_types = {'divider';'shunt'};
                tr_pfx = {'u_','i_'};
                chn_name = {'u','i'};
            else
                error(sprintf('Channel mode ''%s'' not recognized!',mode));    
            end
            tr_phases = ones([chn_n 1]);
            tr_n = chn_n; % transducers count    
            chn_n = chn_n + sum(~~is_diff);
            
            chn_pfx = {};
            data_pfx = {};
            for k = 1:tr_n
                chn_pfx{end+1} = tr_pfx{k};
                data_pfx{end+1} = chn_name{k};
                if is_diff(k)
                    chn_pfx{end+1} = [tr_pfx{k} 'lo_'];
                    data_pfx{end+1} = [chn_name{k} '_lo'];
                end         
            end
            delete chn_name;
                
            
            t2d = gen_tab_list();
            
            
            % virtual measurement root folder:
            %meas_root = '..\temp\selftest\';    
            %meas_root = fullfile(pwd,meas_root);
            meas_root = [tmp_path filesep];
            
            %[ok,err] = rmdir(meas_root,'s')
            %delete([meas_root '*'])
            
            % digitizer channel corrections:
            dig_folder = [meas_root 'DIGITIZER\']; 
            
            % digitizer channel corrections:
            chn_folder = [meas_root 'DIGITIZER\CHN\'];
            
            % digitizer channel corrections:
            tr_folder = [meas_root 'TRANSDUCER\'];
            
            % channel info files:
            chn_inf = repmat({''},[chn_n 1]);
            
            % digitizer info file:
            dig_inf = '';
            
            % user parameters info file:
            par_inf = '';
            
            % transducer info files:
            tr_inf = repmat({''},[tr_n 1]);
            
                    
            % --- for each correction quantity:
            for k = 1:numel(t2d)
            
                % get qu. record:
                rec = t2d{k};
                
                if rec.auto_gen
                
                    % --- for each channel:
                    C = chn_n;
                    if strcmpi(rec.mode,'chn')
                        C = chn_n; % channel correction - for each channel
                    elseif strcmpi(rec.mode,'dig')
                        C = 1; % digitizer correction - once
                    elseif strcmpi(rec.mode,'tr')
                        C = tr_n;
                    else
                        C = 1;
                    end
                    
                    % for each channel/transducer/digitizer:
                    for c = 1:C
                    
                        if isstruct(rec.qu)
                            % --- raw mode:
                            
                            if isfield(rec.qu.v,'tr_type') && rec.qu.v.tr_type
                                % transducer type string:
                                if strcmpi(tr_types{c},'divider')
                                    rec.qu.v.data = 'rvd';
                                else
                                    rec.qu.v.data = 'shunt';                                
                                end                             
                            elseif isfield(rec.qu.v,'string')
                                rec.qu.v.data = char(rndrngi('a','z',[1 rndrngi(1,prod(rec.qu_size))]));
                            elseif isfield(rec.qu.v,'range')
                                rec.qu.v.data = rndrng(rec.qu.v.range(1),rec.qu.v.range(2),rec.qu_size);
                            elseif isfield(rec.qu.v,'list')
                                rec.qu.v.data = reshape(rec.qu.v.list(rndrngi(1,numel(rec.qu.v.list),rec.qu_size)),rec.qu_size);
                            else
                                error(sprintf('Unknown raw quantity ''%s'' generation range!',rec.qu_name));
                            end
                            
                            if isfield(rec.qu,'u')
                                if isfield(rec.qu.v,'range')
                                    rec.qu.u.data = rndrng(rec.qu.u.range(1),rec.qu.u.range(2),rec.qu_size);
                                elseif isfield(rec.qu.v,'list')
                                    rec.qu.u.data = reshape(rec.qu.u.list(rndrngi(1,numel(rec.qu.u.list),rec.qu_size)),rec.qu_size);
                                else
                                    error(sprintf('Unknown raw quantity ''%s'' generation range!',rec.qu_name));
                                end
                            end
                            
                        else
                            % --- TWM table mode:
                            
                            % for each table quantity:
                            for q = 1:numel(rec.qu)
                            
                                if isfield(rec.qu{q},'range')
                                    rrng = rec.qu{q}.range;
                                else
                                    rrng = [-1 1];
                                end
                            
                                % generate some data:
                                if q == 1
                                    % y-axis (major):                            
                                    y_size = rndrngi(5,10);
                                    rec.qu{q}.data = sort(randn(y_size,1));                             
                                elseif q == 2 && rec.tab_dim == 2
                                    % x-axis (minor):                            
                                    x_size = rndrngi(5,10);
                                    rec.qu{q}.data = sort(randn(1,x_size));
                                elseif rec.tab_dim == 1
                                    % 1D data
                                    rec.qu{q}.data = rndrng(rrng(1),rrng(2),[y_size,1]);
                                else
                                    % 2D data
                                    rec.qu{q}.data = rndrng(rrng(1),rrng(2),[y_size,x_size]);
                                end
                            
                            end
                            
                        end                                   
                        
                        if strcmpi(rec.mode,'chn')
                        
                            chn_inf{c} = add_chn_section(chn_inf{c},chn_folder,rec,c);
                            
                            % store QWTB quantity record for each channel:
                            qwrec = struct();
                            qwrec.auto_pass = rec.auto_pass;
                            if iscell(rec.qu)
                                % TWM table:                        
                                qwrec.tab_name = [chn_pfx{c} rec.tab_name];
                                qwrec.pfx = chn_pfx{c}; 
                                qwrec.qu = rec.qu;
                                for r = 1:numel(rec.qu)                            
                                    qwrec.qu{r}.name = [chn_pfx{c} rec.qu{r}.name];                            
                                end
                                twm_selftest_control.t2d{end+1} = qwrec;
                                
                            else
                                % raw QWTB quantity:
                                if isfield(rec,'qu_name')
                                    qwrec.name = [chn_pfx{c} rec.qu_name];
                                end
                                qwrec.is_par = 0;
                                qwrec.pfx = chn_pfx{c};
                                qwrec.desc = rec.corr_name;                        
                                qwrec.data.v = rec.qu.v.data;
                                if isfield(rec.qu,'u')
                                    qwrec.data.u = rec.qu.u.data;
                                end                        
                                twm_selftest_control.raw{end+1} = qwrec;
                                
                            end
                            
                        elseif strcmpi(rec.mode,'dig')
                            dig_inf = add_chn_section(dig_inf,dig_folder,rec);
                                            
                            % store QWTB quantity record:
                            qwrec = struct();
                            qwrec.auto_pass = rec.auto_pass;
                            if iscell(rec.qu)
                                % TWM table:
                                
                                qwrec.tab_name = [rec.tab_name];
                                qwrec.qu = rec.qu;
                                for r = 1:numel(rec.qu)                            
                                    qwrec.qu{r}.name = [rec.qu{r}.name];                            
                                end
                                twm_selftest_control.t2d{end+1} = qwrec;
                                
                            else
                                % raw QWTB quantity:                    
                                qwrec.name = [rec.qu_name];
                                qwrec.desc = rec.corr_name;  
                                qwrec.data.v = rec.qu.v.data;
                                qwrec.is_par = 0;
                                if isfield(rec.qu,'u')
                                    qwrec.data.u = rec.qu.u.data;
                                end                        
                                twm_selftest_control.raw{end+1} = qwrec;
                                
                            end
                            
                        elseif strcmpi(rec.mode,'tr')
        
                            tr_inf{c} = add_tr_corr(tr_inf{c},tr_folder,rec,c);
                            
                            % store QWTB quantity record for each transducer:
                            qwrec = struct();
                            qwrec.auto_pass = rec.auto_pass;
                            if iscell(rec.qu)
                                % TWM table:
                                
                                qwrec.tab_name = [tr_pfx{c} rec.tab_name];
                                qwrec.pfx = tr_pfx{c};
                                qwrec.qu = rec.qu;
                                for r = 1:numel(rec.qu)                            
                                    qwrec.qu{r}.name = [tr_pfx{c} rec.qu{r}.name];                            
                                end
                                twm_selftest_control.t2d{end+1} = qwrec;
                                
                            else
                                % raw QWTB quantity:
                                if isfield(rec,'qu_name')
                                    qwrec.name = [tr_pfx{c} rec.qu_name];
                                end
                                qwrec.is_par = 0;
                                qwrec.pfx = tr_pfx{c};                        
                                qwrec.desc = rec.corr_name;  
                                qwrec.data.v = rec.qu.v.data;
                                if isfield(rec.qu,'u')
                                    qwrec.data.u = rec.qu.u.data;
                                end                        
                                twm_selftest_control.raw{end+1} = qwrec;
                                
                            end
         
         
                        elseif strcmpi(rec.mode,'par')
        
                            if ischar(rec.qu.v.data)
                                par_inf = infosettextmatrix(par_inf,rec.qu_name,{rec.qu.v.data});
                            elseif isnumeric(rec.qu.v.data)
                                par_inf = infosetmatrix(par_inf,rec.qu_name,rec.qu.v.data);
                            end                    
                            
                            % store QWTB quantity record for each transducer:
                            qwrec = struct();
                            qwrec.auto_pass = rec.auto_pass;
                            qwrec.is_par = 1; 
        
                            % raw QWTB quantity:
                            if isfield(rec,'qu_name')
                                qwrec.name = [rec.qu_name];
                            end                      
                            qwrec.desc = rec.corr_name;  
                            qwrec.data.v = rec.qu.v.data;
                            twm_selftest_control.raw{end+1} = qwrec;
                         
                        end 
                    
                    end
                
                end
            
            end
            
            %[twm_selftest_control.raw{:}].name
            %[twm_selftest_control.t2d{:}].tab_name
            
            
            % --- save channel info files:
            chn_files = {};
            chn_names = {};
            chn_rel_names = {};
            for c = 1:chn_n
                
                
                % generate channel path:
                file = sprintf('%schannel_%02d.info',chn_folder,c);
                
                chn_files{c,1} = file;
                chn_names{c,1} = sprintf('channel %02d',c);
                chn_rel_names{c,1} = sprintf('CHN%schannel_%02d.info',filesep(),c);;
                
                % generate some more correction stuff:
                chn_inf{c} = [infosettext('channel identifier',chn_names{c}) sprintf('\n\n') chn_inf{c}];
                chn_inf{c} = [infosettext('name',chn_names{c}) sprintf('\n\n') chn_inf{c}];        
                chn_inf{c} = [infosettext('type','channel') sprintf('\n\n') chn_inf{c}];
                
                delete(file);
                infosave(chn_inf{c},file);
                        
            end
            
            
            % --- save digitizer info file:
            
            % store channel correction paths: 
            dig_inf = [infosettextmatrix('channel correction paths',chn_rel_names) sprintf('\n\n') dig_inf];
            
            % store channel names: 
            dig_inf = [infosettextmatrix('channel identifiers',chn_names) sprintf('\n\n') dig_inf];
            
            % store digitizer name: 
            dig_inf = [infosettext('name','Simulated digitizer') sprintf('\n\n') dig_inf];
            
            % store digitizer control flag: 
            dig_inf = [infosettext('type','digitizer') sprintf('\n\n') dig_inf];
            
            % generate timeshifts matrix:
            time_shifts = randn([1 chn_n])*1e-3;
            time_shifts_u = randn([1 chn_n])*1e-6;
            time_shifts(1) = 0;
            time_shifts_u(1) = 0;    
            tsinf = infosetmatrix('value',time_shifts);
            tsinf = infosetmatrix(tsinf,'uncertainty',time_shifts_u);
            dig_inf = infosetsection(dig_inf,'interchannel timeshift',tsinf);   
            
            % save
            dig_file = fullfile(dig_folder,'digitizer.info');
            dig_rel_name = fullfile('DIGITIZER','digitizer.info');
            delete(dig_file);
            infosave(dig_inf,dig_file);
            
            
            % --- save transducer info files:
            tr_files = {};
            tr_rel_names = {};
            for c = 1:tr_n
                
                % generate channel path:
                tr_rel_names{c,1} = sprintf('TRANSDUCER%sT%02d%stransducer.info',filesep(),c,filesep());        
                file = sprintf('%sT%02d%stransducer.info',tr_folder,c,filesep());
                
                
                tr_files{c,1} = file;
                        
                % generate some more correction stuff:
                tr_inf{c} = [infosettext('serial number',sprintf('transducer %d',c)) sprintf('\n\n') tr_inf{c}];
                tr_inf{c} = [infosettext('name','Simulated transducer') sprintf('\n\n') tr_inf{c}];        
                tr_inf{c} = [infosettext('type',tr_types{c}) sprintf('\n\n') tr_inf{c}];
                
                delete(file);
                infosave(tr_inf{c},file);
                        
            end
            
            
            % --- Generate measurement session ---
            
            minf = '';
            
            % list of used digitizer channels:
            minf = infosettextmatrix(minf,'channel descriptors',chn_names);
            
            % aux. HW descriptors:
            minf = infosettextmatrix(minf,'auxiliary HW descriptors',{});
            
            % dig. channels count:
            minf = infosetnumber(minf,'channels count',numel(chn_names));
            
            % sample data format:
            minf = infosettext(minf,'sample data format','mat-v4');    
            minf = infosettext(minf,'sample data variable name','y');
            
            % meas. groups count:
            %  ###todo: not implemented
            minf = infosetnumber(minf,'groups count',1);
            
            % temperature cfg.:
            minf = infosetnumber(minf,'temperature available',0);
            minf = infosetnumber(minf,'temperature log available',0);
            
            % repetitions count
            rep_n = 5;
            inf = infosetnumber('repetitions count',rep_n);
            
            % desired samples count:
            smpl_n = rndrngi(10,20);
            inf = infosetnumber(inf,'samples count',smpl_n);
            
            % bit resolution:
            bits_n = rndrngi(16,32);
            inf = infosetnumber(inf,'bit resolution',bits_n);
            
            % voltage ranges:
            ranges = rndrngi(1,10,[1 chn_n]);
            inf = infosetmatrix(inf,'voltage ranges [V]',ranges);
            
            % aperture time:
            apertures = rndrng(1e-6,1e-3,[rep_n 1]);
            inf = infosetmatrix(inf,'aperture [s]',apertures);
                
            % trigger mode:
            inf = infosettext(inf,'trigger mode','Immediate');
            
            % actual samples counts:
            inf = infosetmatrix(inf,'record samples counts',repmat(smpl_n,[rep_n 1]));
            
            % sampling time increments:
            fs = rndrng(1e3,1e6);
            inf = infosetmatrix(inf,'record time increments [s]',repmat(1/fs,[rep_n 1]));
            
            % sample data gains:
            gains = rndrng(0.1,10.0,[rep_n chn_n]);
            inf = infosetmatrix(inf,'record sample data gains [V]',gains);
            
            % sample data offsets:
            offsets = rndrng(-0.01,+0.01,[rep_n chn_n]);
            inf = infosetmatrix(inf,'record sample data offsets [V]',offsets);
        
            % relative timestamps:
            timestamps = repmat(rndrng(0,0.1,[rep_n 1]),[1 chn_n]);
            inf = infosetmatrix(inf,'record relative timestamps [s]',timestamps);
            
            % absolute timestamps:
            inf = infosettimematrix(inf,'record relative timestamps [s]',timestamps);
            
            % record paths:    
            rec_folder = [meas_root 'RAW' filesep()];
            mkdir(rec_folder);
            
            % generate and save records:
            records = {};
            rec_rel_names = {};
            for r = 1:rep_n    
                records{r} = randn([smpl_n chn_n]);        
                rec_rel_names{r,1} = sprintf('RAW%srec_%03d.mat',filesep(),r);
                rec_paths{r,1} = sprintf('%srec_%03d.mat',rec_folder,r);        
                y = records{r}'; % stores in transposed way
                save(rec_paths{r},'-v4','y');            
            end    
            inf = infosettextmatrix(inf,'record sample data files',rec_rel_names);
            
            % insert records section:
            minf = infosetsection(minf,'measurement group 1',inf);
            
            
            
            % digitizer correction file:         
            inf = infosettext('digitizer corrections path',dig_rel_name);
            
            % transducer correction paths: 
            inf = infosettextmatrix(inf,'transducer paths',tr_rel_names);
                
            % phase index:
            inf = infosetmatrix(inf,'channel phase indexes',tr_phases);
            
            % create channel mapping:
            C = numel(chn_files);
            rpt = randperm(C);
            rpt = 1:C; % ###todo: implement channel mapping
            c = 1;
            
            map = {};
            for t = 1:numel(tr_files)            
                chn_map{t,1} = rpt(c);
                map{t,1} = int2str(rpt(c));
                c = c + 1;            
                if is_diff(t)
                    chn_map{t,1} = [chn_map{t,1} rpt(c)];
                    map{t,2} = int2str(rpt(c));
                    c = c + 1;
                end    
            end
            
            % channel mapping:
            inf = infosettextmatrix(inf,'transducer to digitizer channels mapping',map);
            
            % insert setup configuration section:
            minf = infosetsection(minf,'measurement setup configuration',inf);
            
            % save measurement session:
            session_file = [meas_root 'session.info'];    
            delete(session_file);
            infosave(minf,session_file);
            
            
            % --- generate QWTB calculation record ---
            
            % validation algorithm:
            inf = infosettext('algorithm id', 'TWM-VALID');
            
            % records processing mode:
            inf = infosetnumber(inf, 'calculate whole average at once', 0);
            
            % no uncertainty:
            inf = infosettext(inf, 'uncertainty mode', 'none');
            inf = infosetnumber(inf, 'coverage interval [%]', 95);
            
            % list of user parameters:
            inf = infosettextmatrix(inf, 'list of parameter names', {'scalar';'vector';'matrix';'string'});
            
            % write user parameters:
            %p_scalar = randn;
            %p_vector = randn(rndrngi(1,10),1);
            %p_matrix = randn(rndrngi(1,10),rndrngi(1,10));
            %p_string = char(rndrngi('a','z',[1 rndrngi(1,50)]));    
            %inf = infosetmatrix(inf, 'scalar', p_scalar);
            %inf = infosetmatrix(inf, 'vector', p_vector);
            %inf = infosetmatrix(inf, 'matrix', p_matrix);
            %inf = infosettextmatrix(inf, 'string', {p_string});
            inf = [inf sprintf('\n') par_inf];
              
            % save measurement session:
            inf = infosetsection('', 'QWTB processing setup', inf);
            qwtb_file = [meas_root 'qwtb.info'];    
            delete(qwtb_file);
            infosave(inf,qwtb_file);
            
            
            
            % --- manualy generated qwtb quantities:        
            % generate sample data vectors:
            for k = 1:numel(data_pfx)        
                rec = struct();
                rec.auto_pass = 1;
                rec.name = data_pfx{k};
                rec.desc = ['Sample data for channel ' data_pfx{k}];
                rec.data.v = records{end}(:,k);
                rec.opt = 'waveform';
                rec.pfx = chn_pfx{k};
                rec.is_par = 0;                
                twm_selftest_control.raw{end+1} = rec;        
            end
            
            
            % -- generate timeshifts:
            
            tsref = timestamps(end,1);
            % aperture time:
            rec = struct();
            rec.auto_pass = 1;
            rec.name = 'time_stamp';
            rec.desc = 'Ref channel timestamp';
            rec.data.v = tsref;
            rec.is_par = 0;
            twm_selftest_control.raw{end+1} = rec;
            
            time_shifts = timestamps(end,:) - tsref + time_shifts;    
            % for each transducer:
            for k = 1:tr_n        
                
                tr_map = chn_map{k};
                
                if is_diff(k)
                
                    rec = struct();
                    rec.auto_pass = 1;
                    rec.name = [tr_pfx{k} 'time_shift_lo'];
                    rec.desc = 'Low channel timeshift';
                    rec.data.v = time_shifts(tr_map(2)) - time_shifts(tr_map(1));
                    rec.data.u = (time_shifts_u(tr_map(2))^2 + time_shifts_u(tr_map(1))^2)^0.5;
                    rec.pfx = tr_pfx{k};
                    rec.is_par = 0;                
                    twm_selftest_control.raw{end+1} = rec;    
                 
                end
                
                if strcmpi(mode,'ui') && k == 2
                  % second channel (i):
                  
                  rec = struct();
                  rec.auto_pass = 1;
                  rec.name = ['time_shift'];
                  rec.desc = 'Current channel timeshift';
                  rec.data.v = time_shifts(chn_map{k-1}(1)) - time_shifts(tr_map(1)); % ###todo: decide if it is inverted?
                  rec.data.u = (time_shifts_u(tr_map(1))^2 + time_shifts_u(chn_map{k-1}(1))^2)^0.5;
                  rec.pfx = tr_pfx{k};
                  rec.is_par = 0;                
                  twm_selftest_control.raw{end+1} = rec;
                  
                end
                        
            end
            
            % aperture time:
            rec = struct();
            rec.auto_pass = 1;
            rec.name = 'adc_aper';
            rec.desc = 'ADC aperture time';
            rec.data.v = apertures(end);
            rec.is_par = 0;
            twm_selftest_control.raw{end+1} = rec;
               
                
            
            % --- execute validation algorithm on the simulated measurement:
            qwtb_exec_algorithm(session_file, 'guf', 1, -1, -1, 0);
            
            
            
            % --- compare generated/returned quantities:
            cfg.vec_horiz = 0;
            [res] = qwtb_load_results(meas_root,-1,'',cfg);
            res = res{1}{1};
            
            
            % obtain result names:
            rnames = {[res{:}].name};
                
            % --- for each correction quantity:
            for k = 1:numel(twm_selftest_control.t2d)
            
                % get qu. record:
                rec = twm_selftest_control.t2d{k};
                
                for q = 1:numel(rec.qu)
                    
                    if verbose > 1
                        fprintf('Comparing quantity ''%s'' ...\n',rec.qu{q}.name);
                    end        
                    
                    % find quantity in results:
                    fid = find(strcmpi(rec.qu{q}.name,rnames),1,'first');
                    if isempty(fid)
                        rec.qu{q}
                        error(sprintf('Compare: quantity ''%s'' not found in the results!',rec.qu{q}.name)); 
                    end
                    
                    % get results record:
                    dut = res{fid};
                    
                    % check size match:
                    if any(dut.size ~= size(rec.qu{q}.data))
                        rec.qu{q}
                        dut
                        error(sprintf('Compare: quantity ''%s'' size does not match!',rec.qu{q}.name));
                    end
                    
                    if isfield(rec.qu{q},'opt')
                        % optional actions:
                        if strcmpi(rec.qu{q}.opt,'nom_gain_fix')
                            % apply adc_gain*nominal gain before compare:
                            
                            % find nominal gain matching the channel:
                            nom_gain.v = NaN;
                            for r = 1:numel(twm_selftest_control.raw)
                                if strcmpi(twm_selftest_control.raw{r}.desc,'nominal gain') && strcmpi(twm_selftest_control.raw{r}.pfx,rec.pfx)
                                    nom_gain = twm_selftest_control.raw{r}.data;    
                                end                    
                            end
                            if isnan(nom_gain.v)
                                error(sprintf('Compare: quantity ''%s'' cannot be compared, missing nominal gain! This should not happen.',rec.qu{q}.name));
                            end                    
                            
                            % store gain tfer before nominal gain application:
                            % ###note: needed for .opt == 'nom_gain_fix_u' 
                            gain_tfer_temp = rec.qu{q}.data; 
                            
                            % apply nominal gain:                    
                            rec.qu{q}.data = rec.qu{q}.data*nom_gain.v;
                        
                        elseif strcmpi(rec.qu{q}.opt,'nom_gain_fix_u')
                            % apply adc_gain*nominal gain uncertainty before compare:
                            % ###note: this piece of code expects hardcoded position of gain quantity, complementary to the gain uncertainty quantity.
                            %          It expects the value at index (q-1)! Eventually it may fail when structure of quantities in the gain records is changed!
                            
                            % find nominal gain matching the channel:
                            nom_gain.u = NaN;
                            for r = 1:numel(twm_selftest_control.raw)
                                if strcmpi(twm_selftest_control.raw{r}.desc,'nominal gain') && strcmpi(twm_selftest_control.raw{r}.pfx,rec.pfx)
                                    nom_gain = twm_selftest_control.raw{r}.data;    
                                end                    
                            end
                            if isnan(nom_gain.u)
                                error(sprintf('Compare: quantity ''%s'' cannot be compared, missing nominal gain! This should not happen.',rec.qu{q}.name));
                            end                    
                            % apply nominal gain uncertainty:                    
                            rec.qu{q}.data = ((nom_gain.v.*rec.qu{q}.data).^2 + (gain_tfer_temp.*nom_gain.u).^2).^0.5;
                                        
                        elseif strcmpi(rec.qu{q}.opt,'nom_rat_fix')
                            % apply tr_gain*nominal gain before compare:
                            
                            % find nominal gain matching the channel:
                            nom_gain.v = NaN;
                            for r = 1:numel(twm_selftest_control.raw)
                                if strcmpi(twm_selftest_control.raw{r}.desc,'nominal ratio') && strcmpi(twm_selftest_control.raw{r}.pfx,rec.pfx)
                                    nom_gain = twm_selftest_control.raw{r}.data;    
                                end                    
                            end
                            if isnan(nom_gain.v)
                                error(sprintf('Compare: quantity ''%s'' cannot be compared, missing nominal gain! This should not happen.',rec.qu{q}.name));
                            end                    
                            
                            % store gain tfer before nominal gain application:
                            % ###note: needed for .opt == 'nom_rat_fix_u' 
                            gain_tfer_temp = rec.qu{q}.data;
                            
                            % apply nominal gain:                    
                            rec.qu{q}.data = rec.qu{q}.data*nom_gain.v;
                                 
        
                            rid = find(strcmpi(rnames,[rec.pfx 'tr_type']),1);
                            if strcmpi(res{rid}.val,'shunt')
                                % inverse ratio for a shunt:
                                rec.qu{q}.data = 1./rec.qu{q}.data;    
                            end 
                        
                        elseif strcmpi(rec.qu{q}.opt,'nom_rat_fix_u')
                            % apply tr_gain*nominal gain uncertainty before compare:
                            % ###note: this piece of code expects hardcoded position of gain quantity, complementary to the gain uncertainty quantity.
                            %          It expects the value at index (q-1)! Eventually it may fail when structure of quantities in the gain records is changed! 
                                                                    
                            % find nominal gain matching the channel:
                            nom_gain.u = NaN;
                            for r = 1:numel(twm_selftest_control.raw)
                                if strcmpi(twm_selftest_control.raw{r}.desc,'nominal ratio') && strcmpi(twm_selftest_control.raw{r}.pfx,rec.pfx)
                                    nom_gain = twm_selftest_control.raw{r}.data;    
                                end                    
                            end
                            if isnan(nom_gain.u)
                                error(sprintf('Compare: quantity ''%s'' cannot be compared, missing nominal gain! This should not happen.',rec.qu{q}.name));
                            end                    
                            
                            % apply nominal gain uncertainty:
                            rec.qu{q}.data = ((rec.qu{q}.data*nom_gain.v).^2 + (nom_gain.u*gain_tfer_temp).^2).^0.5./(gain_tfer_temp.*nom_gain.v).*rec.qu{q-1}.data;                    
                            %rec.qu{q}.data = ((rec.qu{q}.data).^2 + (nom_gain.u).^2).^0.5;
                            
        %                     rid = find(strcmpi(rnames,[rec.pfx 'tr_type']),1);
        %                     if strcmpi(res{rid}.val,'shunt')
        %                         % inverse ratio for a shunt:
        %                         rec.qu{q}.data = rec.qu{q}.data.*rec.qu{q-1}.data;     
        %                     end
                        end
                    end
                    
                    % check content match
                    if strcmpi(rec.qu{q}.sub,'u')
                        ref = dut.unc; % comparing uncertainty
                        comp_tol = 1e-2;
                    else
                        ref = dut.val; % comparing value of quantity
                        comp_tol = 1e-9;
                    end
                    
                
                    
                    if ~matchtol(ref,rec.qu{q}.data,comp_tol)
                        disp('----- Calculated:')
                        rec.qu{q}.data
                        disp('----- Reference:')
                        ref
                        
                        dev = rec.qu{q}.data./ref-1
                        error(sprintf('Compare: quantity ''%s.%s'' content does not match!',rec.qu{q}.name,rec.qu{q}.sub));
                    end
                                
                end         
                
            end
            % --- for each correction quantity (raw):
            for k = 1:numel(twm_selftest_control.raw)
                
                % get qu. record:
                rec = twm_selftest_control.raw{k};
                
                if rec.auto_pass
                
                    if verbose > 1
                        fprintf('Comparing quantity ''%s'' ...\n',rec.name);
                    end
                     
                    % find quantity in results:
                    fid = find(strcmpi(rec.name,rnames),1,'first');
                    if isempty(fid)
                        rec
                        error(sprintf('Compare: quantity ''%s'' not found in the results!',rec.name)); 
                    end
                    dut = res{fid};
                    
                    if isfield(rec,'opt') && strcmpi(rec.opt,'waveform')
                        % waveform - select waveform before compare:
                        
                        % identify channel prefix that is being tested:
                        cid = find(strcmpi(rec.pfx,chn_pfx));
                        
                        % apply offsets:
                        rec.data.v = rec.data.v*gains(end,cid) + offsets(end,cid);                
                                                        
                    end
                    
                    % compare contents:
                    if ~matchtol(dut.val,rec.data.v)
                        rec
                        dut
                        error(sprintf('Compare: quantity ''%s.v'' content does not match!',rec.name));
                    end
                    if isfield(rec.data,'u') && ~matchtol(dut.unc,rec.data.u)
                        rec
                        dut
                        error(sprintf('Compare: quantity ''%s.u'' content does not match!',rec.name));
                    end            
                    
                end
                
            end
            
            % remove the global from global workspace: 
            clear global twm_selftest_control;
        
        end
    
    catch
        % --- something failed - cleanup first, then generate error:
                
        % remove the global from global workspace: 
        clear global twm_selftest_control;
        
        rethrow(lasterror);
    
    end
    
    if verbose
        disp('All done successfully.');
    end

end

function res = matchtol(a,b,trel)
    if nargin < 3
        trel = 1e-9;
    end
    devs = abs((a - b)./a) > trel;
    devs = devs(:);
    if any(isnan(devs)) || any(isinf(devs))
        res = all(a == b);        
    end
    res = ~any(devs);
end


function inf = add_tr_corr(inf,folder,rec,chn)

    mkdir(folder);
    
    tr_folder = sprintf('T%02d',chn);
    
    folder = [fullfile(folder,tr_folder) filesep()];
    
    mkdir(folder);
       
    
    if rec.is_csv
        % --- CSV table mode:
        
        % CSV files folder:
        csvfld = [folder 'csv' filesep()];
        
        % make CSV folder:
        mkdir(csvfld);
        
        if rec.tab_dim == 1
            % -- 1D table:
            
            y_axis = rec.qu{1}.data;
            y_size = numel(y_axis);
            
            csv = {rec.tab_name};
            csv{2,1} = rec.qu{1}.qu;
            
            % write y-axis:
            if y_size > 1
                for k = 1:y_size
                    csv{2+k,1} = rec.qu{1}.data(k);
                end
            end
            
            % write quantities:
            for q = 2:numel(rec.qu)
                csv{2,q} = rec.qu{q}.qu;
                for k = 1:y_size
                    csv{2+k,q} = rec.qu{q}.data(k);
                end                
            end
           
        else
        
            y_axis = rec.qu{1}.data;
            y_size = numel(y_axis);
            x_axis = rec.qu{2}.data;
            x_size = numel(x_axis);
            
            csv = {rec.tab_name};
            csv{3,1} = [rec.qu{1}.qu '\' rec.qu{2}.qu];
            
            % write y-axis:
            if y_size > 1
                for k = 1:y_size
                    csv{3+k,1} = rec.qu{1}.data(k);
                end
            end
            
            % write x-axis:
            if y_size > 1
                for q = 0:numel(rec.qu)-3
                    for k = 1:x_size
                        csv{3,1+k+q*x_size} = rec.qu{2}.data(k);
                    end
                end
            end
            
            % write quantities:
            for q = 3:numel(rec.qu)                
                for m = 1:x_size
                    csv{2,(q-3)*x_size+m+1} = rec.qu{q}.qu;
                    for k = 1:y_size
                        csv{3+k,m+(q-3)*x_size+1} = rec.qu{q}.data(k,m);
                    end
                end                
            end
                
        end
        
        % create CSV path:
        csvname = sprintf('%s.csv',rec.tab_name);        
        csvpath = fullfile(csvfld,csvname);     
        
        % write CSV file:
        %  ###todo: find something for Matlab
        cell2csv(csvpath,csv,';');
        
        % generate correction section data:
        inf = infosettext(inf,rec.corr_name,['csv' filesep() csvname]);
        
    else
        % --- direct data mode:
        
        if ~ischar(rec.qu.v.data)
            inf = infosetnumber(inf,rec.corr_name,rec.qu.v.data);
        end        
        if isfield(rec.qu,'u')
            inf = infosetnumber(inf,[rec.corr_name ' uncertainty'],rec.qu.u.data);
        end
        
    end    

end


function inf = add_chn_section(inf,folder,rec,chn)

    cor = '';
    
    is_chn = nargin >= 4;
    
    if rec.is_csv
        % --- CSV table mode:
        
        % CSV files folder:
        csvfld = [folder 'csv\'];
        
        % make CSV folder:
        mkdir(csvfld);
        
        if rec.tab_dim == 1
            % -- 1D table:
            
            y_axis = rec.qu{1}.data;
            y_size = numel(y_axis);
            
            csv = {rec.tab_name};
            csv{2,1} = rec.qu{1}.qu;
            
            % write y-axis:
            if y_size > 1
                for k = 1:y_size
                    csv{2+k,1} = rec.qu{1}.data(k);
                end
            end
            
            % write quantities:
            for q = 2:numel(rec.qu)
                csv{2,q} = rec.qu{q}.qu;
                for k = 1:y_size
                    csv{2+k,q} = rec.qu{q}.data(k);
                end                
            end
           
        else
        
            y_axis = rec.qu{1}.data;
            y_size = numel(y_axis);
            x_axis = rec.qu{2}.data;
            x_size = numel(x_axis);
            
            csv = {rec.tab_name};
            csv{3,1} = [rec.qu{1}.qu '\' rec.qu{2}.qu];
            
            % write y-axis:
            if y_size > 1
                for k = 1:y_size
                    csv{3+k,1} = rec.qu{1}.data(k);
                end
            end
            
            % write x-axis:
            if y_size > 1
                for q = 0:numel(rec.qu)-3
                    for k = 1:x_size
                        csv{3,1+k+q*x_size} = rec.qu{2}.data(k);
                    end
                end
            end
            
            % write quantities:
            for q = 3:numel(rec.qu)                
                for m = 1:x_size
                    csv{2,(q-3)*x_size+m+1} = rec.qu{q}.qu;
                    for k = 1:y_size
                        csv{3+k,m+(q-3)*x_size+1} = rec.qu{q}.data(k,m);
                    end
                end                
            end
                
        end
        
        % create CSV path:
        if is_chn
            csvname = sprintf('%s_%02d.csv',rec.tab_name,chn);
        else
            csvname = sprintf('%s.csv',rec.tab_name);        
        end
        csvpath = fullfile(csvfld,csvname);     
        
        % write CSV file:
        %  ###todo: find something for Matlab
        cell2csv(csvpath,csv,';');
        
        % generate correction section data:
        cor = infosettextmatrix(cor,'value',{['csv\' csvname]});            
        
    else
        % --- direct data mode:
        
        if isstruct(rec.qu)
            % -- raw QWTB quantity mode:
            
            cor = infosetmatrix(cor,'value',rec.qu.v.data);
            if isfield(rec.qu,'u')
                cor = infosetmatrix(cor,'uncertainty',rec.qu.u.data);
            end
        
        else
            % -- TWM style table mode:
        
            for q = (1+rec.tab_dim):numel(rec.qu)            
                
                if rec.qu{q}.sub == 'v'
                    % value:
                    cor = infosetmatrix(cor,'value',rec.qu{q}.data);
                elseif rec.qu{q}.sub == 'u'
                    % uncertainty:
                    cor = infosetmatrix(cor,'uncertainty',rec.qu{q}.data);                
                end
                
            end
        end        
        
    end
    
    % insert correction section to the data:
    inf = infosetsection(inf,rec.corr_name,cor); 

end


function rnd = rndrngi(rmin,rmax,sz)
% generate random integer from-to
    if nargin < 3
        sz = [1 1];
    elseif size(sz) < 2
        sz = [sz 1];
    end
    rnd = round(rand(sz)*(rmax - rmin) + rmin);
end

function rnd = rndrng(rmin,rmax,sz)
% generate random integer from-to
    if nargin < 3
        sz = [1 1];
    elseif size(sz) < 2
        sz = [sz 1];
    end
    rnd = rand(sz)*(rmax - rmin) + rmin;
end




function [list] = gen_tab_list()
% List of TWM tables and raw quantities

    list = {};
    
    tab = struct();
    tab.tab_name = 'adc_gain';
    tab.tab_dim = 2;
    tab.qu{1} = struct('qu','f', 'name','adc_gain_f', 'sub','v', 'desc','ADC gain - frequency axis');
    tab.qu{2} = struct('qu','a', 'name','adc_gain_a', 'sub','v', 'desc','ADC gain - amplitude axis');
    tab.qu{3} = struct('qu','gain', 'name','adc_gain', 'sub','v', 'desc','ADC gain', 'opt', 'nom_gain_fix');
    tab.qu{4} = struct('qu','u_gain', 'name','adc_gain', 'sub','u', 'desc','ADC gain', 'opt', 'nom_gain_fix_u');    
    tab.auto_gen = 1;
    tab.auto_pass = 1;
    tab.is_csv = 1;
    tab.corr_name = 'gain transfer';
    tab.mode = 'chn';
    list{end+1} = tab;
    
    tab = struct();
    tab.tab_name = 'adc_phi';
    tab.tab_dim = 2;
    tab.qu{1} = struct('qu','f', 'name','adc_phi_f', 'sub','v', 'desc','ADC phase - frequency axis');
    tab.qu{2} = struct('qu','a', 'name','adc_phi_a', 'sub','v', 'desc','ADC phase - amplitude axis');
    tab.qu{3} = struct('qu','phi', 'name','adc_phi', 'sub','v', 'desc','ADC phase');
    tab.qu{4} = struct('qu','u_phi', 'name','adc_phi', 'sub','u', 'desc','ADC phase');    
    tab.auto_gen = 1;
    tab.auto_pass = 1;
    tab.is_csv = 1;
    tab.corr_name = 'phase transfer';
    tab.mode = 'chn';
    list{end+1} = tab;
    
    tab = struct();
    tab.tab_name = 'adc_sfdr';
    tab.tab_dim = 2;
    tab.qu{1} = struct('qu','f', 'name','adc_sfdr_f', 'sub','v', 'desc','ADC SFDR - fundamental frequency axis');
    tab.qu{2} = struct('qu','a', 'name','adc_sfdr_a', 'sub','v', 'desc','ADC SFDR - fundamental amplitude axis');
    tab.qu{3} = struct('qu','sfdr', 'name','adc_sfdr', 'sub','v', 'desc','ADC SFDR');   
    tab.auto_gen = 1;
    tab.auto_pass = 1;
    tab.is_csv = 1;
    tab.corr_name = 'sfdr';
    tab.mode = 'chn';
    list{end+1} = tab;
    
    tab = struct();
    tab.tab_name = 'adc_Yin';
    tab.tab_dim = 1;
    tab.qu{1} = struct('qu','f', 'name','adc_Yin_f', 'sub','v', 'desc','ADC input admittance - frequency axis');
    tab.qu{2} = struct('qu','Cp', 'name','adc_Yin_Cp', 'sub','v', 'desc','ADC input admittance - Cp');
    tab.qu{3} = struct('qu','Gp', 'name','adc_Yin_Gp', 'sub','v', 'desc','ADC input admittance - Gp');
    tab.qu{4} = struct('qu','u_Cp', 'name','adc_Yin_Cp', 'sub','u', 'desc','ADC input admittance - u(Cp)');     
    tab.qu{5} = struct('qu','u_Gp', 'name','adc_Yin_Gp', 'sub','u', 'desc','ADC input admittance - u(Gp)');
    tab.auto_gen = 1;
    tab.auto_pass = 1;
    tab.is_csv = 1;
    tab.corr_name = 'input admittance';
    tab.mode = 'chn';
    list{end+1} = tab;
    
    tab = struct();
    tab.qu_name = 'adc_aper_corr';
    tab.qu_size = [1 1];
    tab.qu.v.list = [0 1];
    tab.auto_gen = 1;
    tab.auto_pass = 1;
    tab.is_csv = 0;
    tab.corr_name = 'aperture correction';
    tab.mode = 'chn';
    list{end+1} = tab;
    
    tab = struct();
    tab.qu_name = 'adc_offset';
    tab.qu_size = [1 1];
    tab.qu.v.range = [-0.01 +0.01];
    tab.qu.u.range = [0.0001 0.001];
    tab.auto_gen = 1;
    tab.auto_pass = 1;
    tab.is_csv = 0;
    tab.corr_name = 'dc offset';
    tab.mode = 'chn';
    list{end+1} = tab;
    
    tab = struct();
    tab.qu_name = 'adc_jitter';
    tab.qu_size = [1 1];
    tab.qu.v.range = [0.00001 0.01];
    tab.auto_gen = 1;
    tab.auto_pass = 1;
    tab.is_csv = 0;
    tab.corr_name = 'rms jitter';
    tab.mode = 'chn';
    list{end+1} = tab;
    
    tab = struct();
    tab.qu_size = [1 1];
    tab.auto_gen = 1;
    tab.auto_pass = 0;
    tab.is_csv = 0;
    tab.qu.v.range = [0.9 1.1]; 
    tab.qu.u.range = [0.01 0.02];     
    tab.corr_name = 'nominal gain';
    tab.mode = 'chn';
    list{end+1} = tab;
    
    
 
    tab = struct();
    tab.qu_name = 'adc_freq';
    tab.qu_size = [1 1];
    tab.auto_gen = 1;
    tab.auto_pass = 1;
    tab.is_csv = 0;
    tab.qu.v.range = [0.000 0.001]; 
    tab.qu.u.range = [0.001 0.002];
    tab.corr_name = 'timebase correction';
    tab.mode = 'dig';
    list{end+1} = tab;   
    
    tab = struct();
    tab.qu_name = 'tr_type';
    tab.qu_size = [];
    tab.qu.v.tr_type = 1;
    tab.auto_gen = 1;
    tab.auto_pass = 1;
    tab.is_csv = 0;
    tab.corr_name = 'transducer type';
    tab.mode = 'tr';
    list{end+1} = tab;
    
    tab = struct();
    tab.tab_name = 'tr_gain';
    tab.tab_dim = 2;
    tab.qu{1} = struct('qu','f', 'name','tr_gain_f', 'sub','v', 'desc','Transducer gain - frequency axis');
    tab.qu{2} = struct('qu','rms', 'name','tr_gain_a', 'sub','v', 'desc','Transducer gain - amplitude axis');
    tab.qu{3} = struct('qu','gain', 'name','tr_gain', 'sub','v', 'desc','Transducer gain', 'opt','nom_rat_fix', 'range',[0.5 1.5]);
    tab.qu{4} = struct('qu','u_gain', 'name','tr_gain', 'sub','u', 'desc','Transducer gain', 'opt','nom_rat_fix_u', 'range',[1e-6 1e-3]);    
    tab.auto_gen = 1;
    tab.auto_pass = 1;
    tab.is_csv = 1;
    tab.corr_name = 'amplitude transfer path';
    tab.mode = 'tr';
    list{end+1} = tab;
    
    tab = struct();
    tab.tab_name = 'tr_phi';
    tab.tab_dim = 2;
    tab.qu{1} = struct('qu','f', 'name','tr_phi_f', 'sub','v', 'desc','Transducer phase - frequency axis');
    tab.qu{2} = struct('qu','rms', 'name','tr_phi_a', 'sub','v', 'desc','Transducer phase - amplitude axis');
    tab.qu{3} = struct('qu','phi', 'name','tr_phi', 'sub','v', 'desc','Transducer phase');
    tab.qu{4} = struct('qu','u_phi', 'name','tr_phi', 'sub','u', 'desc','Transducer phase');    
    tab.auto_gen = 1;
    tab.auto_pass = 1;
    tab.is_csv = 1;
    tab.corr_name = 'phase transfer path';
    tab.mode = 'tr';
    list{end+1} = tab;
    
    tab = struct();
    tab.qu_size = [1 1];
    tab.auto_gen = 1;
    tab.auto_pass = 0;
    tab.is_csv = 0;
    tab.qu.v.range = [0.1 10.0];
    tab.qu.u.range = [0.001 0.002];
    tab.corr_name = 'nominal ratio';
    tab.mode = 'tr';
    list{end+1} = tab;
    
    
    tab = struct();
    tab.tab_name = 'tr_sfdr';
    tab.tab_dim = 2;
    tab.qu{1} = struct('qu','f', 'name','tr_sfdr_f', 'sub','v', 'desc','Transducer SFDR - fundamental frequency axis');
    tab.qu{2} = struct('qu','rms', 'name','tr_sfdr_a', 'sub','v', 'desc','Transducer SFDR - fundamental frequency amplitude axis');
    tab.qu{3} = struct('qu','sfdr', 'name','tr_sfdr', 'sub','v', 'desc','Transducer SFDR');   
    tab.auto_gen = 1;
    tab.auto_pass = 1;
    tab.is_csv = 1;
    tab.corr_name = 'sfdr path';
    tab.mode = 'tr';
    list{end+1} = tab;
    
    tab = struct();
    tab.tab_name = 'tr_Zca';
    tab.tab_dim = 1;
    tab.qu{1} = struct('qu','f', 'name','tr_Zca_f', 'sub','v', 'desc','Transducer output terminal series impedance - frequency axis');
    tab.qu{2} = struct('qu','Rs', 'name','tr_Zca_Rs', 'sub','v', 'desc','Transducer output terminal series impedance - Rs');
    tab.qu{3} = struct('qu','Ls', 'name','tr_Zca_Ls', 'sub','v', 'desc','Transducer output terminal series impedance - Ls');
    tab.qu{4} = struct('qu','u_Rs', 'name','tr_Zca_Rs', 'sub','u', 'desc','Transducer output terminal series impedance - u(Rs)');
    tab.qu{5} = struct('qu','u_Ls', 'name','tr_Zca_Ls', 'sub','u', 'desc','Transducer output terminal series impedance - u(Ls)');
    tab.auto_gen = 1;
    tab.auto_pass = 1;
    tab.is_csv = 1;
    tab.corr_name = 'output terminals series impedance path';
    tab.mode = 'tr';
    list{end+1} = tab;
    
    tab = struct();
    tab.tab_name = 'tr_Zcal';
    tab.tab_dim = 1;
    tab.qu{1} = struct('qu','f', 'name','tr_Zcal_f', 'sub','v', 'desc','Transducer output terminal series impedance - frequency axis');
    tab.qu{2} = struct('qu','Rs', 'name','tr_Zcal_Rs', 'sub','v', 'desc','Transducer output terminal series impedance - Rs');        
    tab.qu{3} = struct('qu','Ls', 'name','tr_Zcal_Ls', 'sub','v', 'desc','Transducer output terminal series impedance - Ls');
    tab.qu{4} = struct('qu','u_Rs', 'name','tr_Zcal_Rs', 'sub','u', 'desc','Transducer output terminal series impedance - u(Rs)');
    tab.qu{5} = struct('qu','u_Ls', 'name','tr_Zcal_Ls', 'sub','u', 'desc','Transducer output terminal series impedance - u(Ls)');
    tab.auto_gen = 1;
    tab.auto_pass = 1;
    tab.is_csv = 1;
    tab.corr_name = 'output terminals series impedance path (low-side)';
    tab.mode = 'tr';
    list{end+1} = tab;
    
    tab = struct();
    tab.tab_name = 'tr_Zcam';
    tab.tab_dim = 1;
    tab.qu{1} = struct('qu','f', 'name','tr_Zcam_f', 'sub','v', 'desc','Transducer output terminal mutual inductance - frequency axis');
    tab.qu{2} = struct('qu','M', 'name','tr_Zcam', 'sub','v', 'desc','Transducer output terminal mutual inductance - M');
    tab.qu{3} = struct('qu','u_M', 'name','tr_Zcam', 'sub','u', 'desc','Transducer output terminal mutual inductance - u(M)');    
    tab.auto_gen = 1;
    tab.auto_pass = 1;
    tab.is_csv = 1;
    tab.corr_name = 'output terminals mutual inductance path';
    tab.mode = 'tr';
    list{end+1} = tab;
    
    tab = struct();
    tab.tab_name = 'tr_Yca';
    tab.tab_dim = 1;
    tab.qu{1} = struct('qu','f', 'name','tr_Yca_f', 'sub','v', 'desc','Transducer output terminal shunting admittance - frequency axis');
    tab.qu{2} = struct('qu','Cp', 'name','tr_Yca_Cp', 'sub','v', 'desc','Transducer output terminal shunting admittance - Cp');        
    tab.qu{3} = struct('qu','D', 'name','tr_Yca_D', 'sub','v', 'desc','Transducer output terminal shunting admittance - D');
    tab.qu{4} = struct('qu','u_Cp', 'name','tr_Yca_Cp', 'sub','u', 'desc','Transducer output terminal shunting admittance - u(Cp)');
    tab.qu{5} = struct('qu','u_D', 'name','tr_Yca_D', 'sub','u', 'desc','Transducer output terminal shunting admittance - u(D)');
    tab.auto_gen = 1;
    tab.auto_pass = 1;
    tab.is_csv = 1;
    tab.corr_name = 'output terminals shunting admittance path';
    tab.mode = 'tr';
    list{end+1} = tab;
    
    tab = struct();
    tab.tab_name = 'Zcb';
    tab.tab_dim = 1;
    tab.qu{1} = struct('qu','f', 'name','Zcb_f', 'sub','v', 'desc','Cable series impedance - frequency axis');
    tab.qu{2} = struct('qu','Rs', 'name','Zcb_Rs', 'sub','v', 'desc','Cable series impedance - Rs');
    tab.qu{3} = struct('qu','Ls', 'name','Zcb_Ls', 'sub','v', 'desc','Cable series impedance - Ls');
    tab.qu{4} = struct('qu','u_Rs', 'name','Zcb_Rs', 'sub','u', 'desc','Cable series impedance - u(Rs)');        
    tab.qu{5} = struct('qu','u_Ls', 'name','Zcb_Ls', 'sub','u', 'desc','Cable series impedance - u(Ls)');
    tab.auto_gen = 1;
    tab.auto_pass = 1;
    tab.is_csv = 1;
    tab.corr_name = 'output cable series impedance path';
    tab.mode = 'tr';
    list{end+1} = tab;
    
    tab = struct();
    tab.tab_name = 'Ycb';
    tab.tab_dim = 1;
    tab.qu{1} = struct('qu','f', 'name','Ycb_f', 'sub','v', 'desc','Cable shunting admittance - frequency axis');
    tab.qu{2} = struct('qu','Cp', 'name','Ycb_Cp', 'sub','v', 'desc','Cable shunting admittance - Cp');    
    tab.qu{3} = struct('qu','D', 'name','Ycb_D', 'sub','v', 'desc','Cable shunting admittance - D');
    tab.qu{4} = struct('qu','u_Cp', 'name','Ycb_Cp', 'sub','u', 'desc','Cable shunting admittance - u(Cp)');
    tab.qu{5} = struct('qu','u_D', 'name','Ycb_D', 'sub','u', 'desc','Cable shunting admittance - u(D)');
    tab.auto_gen = 1;
    tab.auto_pass = 1;
    tab.is_csv = 1;
    tab.corr_name = 'output cable shunting admittance path';
    tab.mode = 'tr';
    list{end+1} = tab;
    
    tab = struct();
    tab.tab_name = 'tr_Zlo';
    tab.tab_dim = 1;
    tab.qu{1} = struct('qu','f', 'name','tr_Zlo_f', 'sub','v', 'desc','RVD low-side impedance - frequency axis');
    tab.qu{2} = struct('qu','Rp', 'name','tr_Zlo_Rp', 'sub','v', 'desc','RVD low-side impedance - Rp');        
    tab.qu{3} = struct('qu','Cp', 'name','tr_Zlo_Cp', 'sub','v', 'desc','RVD low-side impedance - Cp');
    tab.qu{4} = struct('qu','u_Rp', 'name','tr_Zlo_Rp', 'sub','u', 'desc','RVD low-side impedance - u(Rp)');
    tab.qu{5} = struct('qu','u_Cp', 'name','tr_Zlo_Cp', 'sub','u', 'desc','RVD low-side impedance - u(Cp)');
    tab.auto_gen = 1;
    tab.auto_pass = 1;
    tab.is_csv = 1;
    tab.corr_name = 'rvd low side impedance path';
    tab.mode = 'tr';
    list{end+1} = tab;
    
    tab = struct();
    tab.tab_name = 'tr_Zbuf';
    tab.tab_dim = 1;
    tab.qu{1} = struct('qu','f', 'name','tr_Zbuf_f', 'sub','v', 'desc','Transducer output buffer ouput series impedance - frequency axis');
    tab.qu{2} = struct('qu','Rs', 'name','tr_Zbuf_Rs', 'sub','v', 'desc','Transducer output buffer ouput series impedance - Rs');
    tab.qu{3} = struct('qu','Ls', 'name','tr_Zbuf_Ls', 'sub','v', 'desc','Transducer output buffer ouput series impedance - Ls');
    tab.qu{4} = struct('qu','u_Rs', 'name','tr_Zbuf_Rs', 'sub','u', 'desc','Transducer output buffer ouput series impedance - u(Rs)');
    tab.qu{5} = struct('qu','u_Ls', 'name','tr_Zbuf_Ls', 'sub','u', 'desc','Transducer output buffer ouput series impedance - u(Ls)');
    tab.auto_gen = 1;
    tab.auto_pass = 1;
    tab.is_csv = 1;
    tab.corr_name = 'buffer output series impedance path';
    tab.mode = 'tr';
    list{end+1} = tab;
    
    
    
    
    tab = struct();
    tab.qu_name = 'scalar';
    tab.qu_size = [1 1];
    tab.auto_gen = 1;
    tab.auto_pass = 1;
    tab.is_csv = 0;
    tab.qu.v.range = [-1 +1]; 
    tab.corr_name = 'scalar parameter';
    tab.mode = 'par';
    list{end+1} = tab;
    
    tab = struct();
    tab.qu_name = 'vector';
    tab.qu_size = [1 rndrngi(1,10)];
    tab.auto_gen = 1;
    tab.auto_pass = 1;
    tab.is_csv = 0;
    tab.qu.v.range = [-1 +1]; 
    tab.corr_name = 'vector parameter';
    tab.mode = 'par';
    list{end+1} = tab;
    
    tab = struct();
    tab.qu_name = 'matrix';
    tab.qu_size = [rndrngi(1,10) rndrngi(1,10)];
    tab.auto_gen = 1;
    tab.auto_pass = 1;
    tab.is_csv = 0;
    tab.qu.v.range = [-1 +1]; 
    tab.corr_name = 'matrix parameter';
    tab.mode = 'par';
    list{end+1} = tab;
    
    tab = struct();
    tab.qu_name = 'string';
    tab.qu_size = [1 rndrngi(1,10)];
    tab.auto_gen = 1;
    tab.auto_pass = 1;
    tab.is_csv = 0;
    tab.qu.v.string = 1; 
    tab.corr_name = 'string parameter';
    tab.mode = 'par';
    list{end+1} = tab;
    

end 
