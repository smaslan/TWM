function [] = twm_selftest()

    % QWTB info control variable:
    global twm_selftest_info;    
    % QWTB wrapper control variable:
    global twm_selftest_control;
    
    twm_selftest_info = {};
    twm_selftest_control = {};
    
    
    
    % channel configuration:
    mode = 'y';
    %mode = 'ui';
    
    % channel diff modes:
    is_diff = 0;
    %is_diff = [0 0];
    
    % sumup total channels count:
    if strcmpi(mode,'y')
        chn_n = 1;
    elseif strcmpi(mode,'ui')
        chn_n = 2;
    else
        error(sprintf('Channel mode ''%s'' not recognized!',mode));    
    end    
    chn_n = chn_n + sum(~~is_diff);   
        
    
    t2d = gen_tab_list();
    
    
    % virtual measurement root folder:
    meas_root = '..\temp\selftest\';    
    meas_root = fullfile(pwd,meas_root);
    
    [ok,err] = rmdir(meas_root,'s')
    
    % digitizer channel corrections:
    chn_folder = [meas_root 'DIGITIZER\CHN\'];
    
    chn_inf = repmat({''},[chn_n 1]);
        
    % --- for each table:
    for k = 1:numel(t2d)
    
        rec = t2d{k};
        
        if strcmpi(rec.mode,'chn')
            % --- channel mode:
            
            
            if rec.auto_gen
            
                % --- for each channel:
                for c = 1:chn_n
                
                    if isstruct(rec.qu)
                        % --- raw mode:
                        
                        if isfield(rec.qu.v,'range')
                            rec.qu.v.data = rndrng(rec.qu.v.range(:),rec.qu_size);
                        elseif isfield(rec.qu.v,'list')
                            rec.qu.v.data = reshape(rec.qu.v.list(rndrngi(1,numel(rec.qu.v.list),rec.qu_size)),rec.qu_size);
                        else
                            error(sprintf('Unknown raw quantity ''%s'' generation range!',rec.qu_name));
                        end
                        
                        if isfield(rec.qu,'u')
                            if isfield(rec.qu.v,'range')
                                rec.qu.u.data = rndrng(rec.qu.u.range(:),rec.qu_size);
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
                        
                            % generate some data:
                            if q == 1
                                % y-axis (major):                            
                                y_size = rndrngi(5,10);
                                rec.qu{q}.data = randn(y_size,1);                             
                            elseif q == 2 && rec.tab_dim == 2
                                % x-axis (minor):                            
                                x_size = rndrngi(5,10);
                                rec.qu{q}.data = randn(1,x_size);
                            elseif rec.tab_dim == 1
                                % 1D data
                                rec.qu{q}.data = randn([y_size,1]);
                            else
                                % 2D data
                                rec.qu{q}.data = randn([y_size,x_size]);
                            end
                        
                        end
                        
                    end
                                       
                    chn_inf{c} = add_chn_section(chn_inf{c},chn_folder,rec);
                    chn_inf{c} = [chn_inf{c} sprintf('\n\n')];   
                
                end
            
            end
            
        end
    
    end
    
    % --- save channel info files:
    for c = 1:chn_n
        
        file = sprintf('%schannel_%02d.info',chn_folder,c);
        infosave(chn_inf{c},file);
        
    end
    
    
    
    
    
    
    
    %alginf = qwtb('TWM-VALID','info');
    %alginf.inputs(:).name    
    

end


function inf = add_chn_section(inf,folder,rec)

    cor = '';
    
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
        csvpath = [csvfld rec.tab_name '.csv'];     
        
        % write CSV file:
        %  ###todo: find something for Matlab
        cell2csv(csvpath,csv,';');
        
        % generate correction section data:
        cor = infosettextmatrix(cor,'value',{['csv\' rec.tab_name '.csv']});            
        
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

    list = {};
    
    tab = struct();
    tab.tab_name = 'adc_gain';
    tab.tab_dim = 2;
    tab.qu{1} = struct('qu','f', 'name','adc_gain_f', 'sub','v', 'desc','ADC gain - frequency axis');
    tab.qu{2} = struct('qu','a', 'name','adc_gain_a', 'sub','v', 'desc','ADC gain - amplitude axis');
    tab.qu{3} = struct('qu','gain', 'name','adc_gain', 'sub','v', 'desc','ADC gain');
    tab.qu{4} = struct('qu','u_gain', 'name','adc_gain', 'sub','u', 'desc','ADC gain');    
    tab.auto_gen = 1;
    tab.is_csv = 1;
    tab.corr_name = 'gain transfer path';
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
    tab.is_csv = 1;
    tab.corr_name = 'phase transfer path';
    tab.mode = 'chn';
    list{end+1} = tab;
    
    tab = struct();
    tab.tab_name = 'adc_sfdr';
    tab.tab_dim = 2;
    tab.qu{1} = struct('qu','f', 'name','adc_sfdr_f', 'sub','v', 'desc','ADC SFDR - fundamental frequency axis');
    tab.qu{2} = struct('qu','a', 'name','adc_sfdr_a', 'sub','v', 'desc','ADC SFDR - fundamental amplitude axis');
    tab.qu{3} = struct('qu','sfdr', 'name','adc_sfdr', 'sub','v', 'desc','ADC SFDR');   
    tab.auto_gen = 1;
    tab.is_csv = 1;
    tab.corr_name = 'sfdr';
    tab.mode = 'chn';
    list{end+1} = tab;
    
    tab = struct();
    tab.tab_name = 'adc_Yin';
    tab.tab_dim = 1;
    tab.qu{1} = struct('qu','f', 'name','adc_Yin_f', 'sub','v', 'desc','ADC input admittance - frequency axis');
    tab.qu{2} = struct('qu','Cp', 'name','adc_Yin_Cp', 'sub','v', 'desc','ADC input admittance - Cp');
    tab.qu{3} = struct('qu','u_Cp', 'name','adc_Yin_Cp', 'sub','u', 'desc','ADC input admittance - u(Cp)');    
    tab.qu{4} = struct('qu','Gp', 'name','adc_Yin_Gp', 'sub','v', 'desc','ADC input admittance - Gp');
    tab.qu{5} = struct('qu','u_Gp', 'name','adc_Yin_Gp', 'sub','u', 'desc','ADC input admittance - u(Gp)');
    tab.auto_gen = 1;
    tab.is_csv = 1;
    tab.corr_name = 'input admittance';
    tab.mode = 'chn';
    list{end+1} = tab;
    
    tab = struct();
    tab.qu_name = 'adc_aper_corr';
    tab.qu_size = [1 1];
    tab.qu.v.list = [0 1];
    tab.auto_gen = 1;
    tab.is_csv = 0;
    tab.corr_name = 'aperture correction';
    tab.mode = 'chn';
    list{end+1} = tab;
    
    tab = struct();
    tab.qu_size = [1 1];
    tab.auto_gen = 1;
    tab.is_csv = 0;
    tab.qu.v.range = [0.9 1.1]; 
    tab.qu.u.range = [0.01 0.02];     
    tab.corr_name = 'nominal gain';
    tab.mode = 'chn';
    list{end+1} = tab;
    
    
    
    tab = struct();
    tab.auto_gen = 0;
    tab.is_csv = 0;
    tab.corr_name = 'interchannel timeshift';
    tab.mode = 'dig';
    list{end+1} = tab;
    
    tab = struct();
    tab.qu_name = 'adc_freq';
    tab.qu_size = [1 1];
    tab.auto_gen = 1;
    tab.is_csv = 0;
    tab.qu.v.range = [0.000 0.001]; 
    tab.qu.u.range = [0.001 0.002];
    tab.corr_name = 'timebase correction';
    tab.mode = 'dig';
    list{end+1} = tab;

end 
