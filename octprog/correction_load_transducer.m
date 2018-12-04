function [tran] = correction_load_transducer(file)
% TWM: Loader of the transducer correction file. 
% It will always return all transducer parameters even if they are not found.
% In that case it will load 'neutral' defaults (unity gain, no phase error, ...).
%
% Inputs:
%   file - absolute file path to the transducers header INFO file.
%          Set '' or not assigned to load default 'blank' correction.
%
% Outputs:
%   tran.type - string defining transducer type 'shunt', 'divider' 
%   tran.name - string with transducer's name
%   tran.sn - string with transducer's serial
%   tran.nominal - transducer's nominal ratio (Ohms or Vin/Vout)
%   tran.u_nominal - transducer's nominal ratio uncertainty (Ohms or Vin/Vout)
%   tran.SFDR - 2D table of SFDR values
%   tran.tfer_gain - 2D table of absolute gain values (nominal gain combined with relative transfer)
%   tran.tfer_phi - 2D table of phase shifts
%   tran.Zca - 1D table of output terminals series Z
%   tran.Yca - 1D table of output terminals shunting Y
%   tran.Zcb - 1D table of cable series Z
%   tran.Ycb - 1D table of cable shunting Y
%   tran.Zlo - 1D table of RVD's low side resistor Z
%   tran.Zbuf - 1D table of buffer output impedance series Z (zero value if no buffer file found)
%
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
%
    
    % load default values only?
    is_default = ~exist('file','var') || isempty(file);
    
    if ~is_default
    
        % root folder of the correction
        root_fld = [fileparts(file) filesep()];
        
        % try to load the correction file
        inf = infoload(file);
        
        % parse info file (speedup):
        inf = infoparse(inf);
          
        % get correction type id
        t_type = infogettext(inf, 'type');
        
        % try to identify correction type
        id = find(strcmpi(t_type,{'shunt','divider'}),1);
        if ~numel(id)
            error(sprintf('Transducer correction loader: Correction type ''%s'' not recognized!'),t_type);
        end
    
    else
        % defaults:
        t_type = 'divider';
    end
    
    % store transducer type
    tran.type = t_type;
    is_shunt = strcmpi(t_type,'shunt');
    
    
    if ~is_default
        % transducer correction name
        tran.name = infogettext(inf,'name');
        
        % transducer serial number
        tran.sn = infogettext(inf,'serial number');
    else
        % defaults:
        tran.name = 'blank divider';
        tran.sn = 'n/a';
    end
    
    % load nominal ratio of the transducer
    if ~is_default            
        tran.nominal = infogetnumber(inf,'nominal ratio');
        tran.u_nominal = infogetnumber(inf,'nominal ratio uncertainty');
    else
        % defaults:
        tran.nominal = 1.0;
        tran.u_nominal = 0.0;        
    end
      
    % load relative frequency/rms dependence (gain):
    try
        fdep_file = [root_fld correction_load_transducer_get_file_key(inf,'amplitude transfer path')];
    catch
        % default (gain, unc.) 
        fdep_file = {[],[],1.0,0.0};         
    end
    tran.tfer_gain = correction_load_table(fdep_file,'rms',{'f','gain','u_gain'});
    tran.tfer_gain.qwtb = qwtb_gen_naming('tr_gain','f','a',{'gain'},{'u_gain'},{''});
    
           
    % load frequency/rms dependence (phase):
    try
        fdep_file = [root_fld correction_load_transducer_get_file_key(inf,'phase transfer path')];
    catch
        % default (phase, unc.) 
        fdep_file = {[],[],0.0,0.0};         
    end
    tran.tfer_phi = correction_load_table(fdep_file,'rms',{'f','phi','u_phi'});
    tran.tfer_phi.qwtb = qwtb_gen_naming('tr_phi','f','a',{'phi'},{'u_phi'},{''});
    
    %tran.tfer_gain.u_gain = (tran.u_nominal^2 + tran.tfer_gain.u_gain.^2).^0.5;    
    tran.tfer_gain.u_gain = ((tran.u_nominal*tran.tfer_gain.gain).^2 + (tran.tfer_gain.u_gain*tran.nominal).^2).^0.5;
    % combine nominal gain and relative gain transfer to the absolute gain tfer.: 
    tran.tfer_gain.gain = tran.nominal*tran.tfer_gain.gain;
        
    if is_shunt
      % inverse ratio for the shunt:
        tran.tfer_gain.gain = 1./tran.tfer_gain.gain;
        tran.tfer_gain.u_gain = tran.tfer_gain.u_gain.*tran.tfer_gain.gain.^2;
    end
      
    
    % --- load loading effect corrections ---
    
    % load output terminals series impedance (optional):
    try
        Zca_file = [root_fld correction_load_transducer_get_file_key(inf,'output terminals series impedance path')];
    catch
        % default value {0 Ohm, 0 H}
        Zca_file = {[], 1e-9, 1e-12, 0.0, 0.0};         
    end
    tran.Zca = correction_load_table(Zca_file,'',{'f','Rs','Ls','u_Rs','u_Ls'});
    tran.Zca.qwtb = qwtb_gen_naming('tr_Zca','f','',{'Rs','Ls'},{'u_Rs','u_Ls'},{'Rs','Ls'});
    % load output terminal shunting admittance (optional):
    try
        Yca_file = [root_fld correction_load_transducer_get_file_key(inf,'output terminals shunting admittance path')];
    catch
        % default value {0 F, 0 D}
        Yca_file = {[], 1e-15, 0.0, 0.0, 0.0};         
    end
    tran.Yca = correction_load_table(Yca_file,'',{'f','Cp','D','u_Cp','u_D'});
    tran.Yca.qwtb = qwtb_gen_naming('tr_Yca','f','',{'Cp','D'},{'u_Cp','u_D'},{'Cp','D'});
    % load output terminals low-side series impedance (optional):
    try
        Zcal_file = [root_fld correction_load_transducer_get_file_key(inf,'output terminals series impedance path (low-side)')];
    catch
        % default value {0 Ohm, 0 H}
        Zcal_file = {[], 1e-9, 1e-12, 0.0, 0.0};         
    end
    tran.Zcal = correction_load_table(Zcal_file,'',{'f','Rs','Ls','u_Rs','u_Ls'});
    tran.Zcal.qwtb = qwtb_gen_naming('tr_Zcal','f','',{'Rs','Ls'},{'u_Rs','u_Ls'},{'Rs','Ls'});
    % load output terminals mutual series impedance (optional):
    try
        Zcam_file = [root_fld correction_load_transducer_get_file_key(inf,'output terminals mutual inductance path')];
    catch
        % default value {0 H}
        Zcam_file = {[], 1e-12, 0.0};         
    end
    tran.Zcam = correction_load_table(Zcam_file,'',{'f','M','u_M'});
    tran.Zcam.qwtb = qwtb_gen_naming('tr_Zcam','f','',{'M'},{'u_M'},{''});
    
    % load cable series impedance (optional):
    try
        Zcb_file = [root_fld correction_load_transducer_get_file_key(inf,'output cable series impedance path')];
        tran.has_Zcb = 1;
    catch
        % default value {0 Ohm, 0 H}
        Zcb_file = {[], 1e-9, 1e-12, 0.0, 0.0};
        tran.has_Zcb = 0;         
    end
    tran.Zcb = correction_load_table(Zcb_file,'',{'f','Rs','Ls','u_Rs','u_Ls'});
    tran.Zcb.qwtb = qwtb_gen_naming('Zcb','f','',{'Rs','Ls'},{'u_Rs','u_Ls'},{'Rs','Ls'});
    % load cable shunting admittance (optional):
    try
        Ycb_file = [root_fld correction_load_transducer_get_file_key(inf,'output cable shunting admittance path')];
    catch
        % default value {0 F, 0 D}
        Ycb_file = {[], 1e-15, 0.0, 0.0, 0.0};         
    end
    tran.Ycb = correction_load_table(Ycb_file,'',{'f','Cp','D','u_Cp','u_D'});
    tran.Ycb.qwtb = qwtb_gen_naming('Ycb','f','',{'Cp','D'},{'u_Cp','u_D'},{'Cp','D'});
    
    % load impedance of the low side of RVD (optional, applies only for RVDs):
    try
        Zlo_file = [root_fld correction_load_transducer_get_file_key(inf,'rvd low side impedance path')];
    catch
        % default value {1 kOhm, 0 F}
        Zlo_file = {[], 1e3, 0, 0.0, 0.0};         
    end
    tran.Zlo = correction_load_table(Zlo_file,'',{'f','Rp','Cp','u_Rp','u_Cp'});
    tran.Zlo.qwtb = qwtb_gen_naming('tr_Zlo','f','',{'Rp','Cp'},{'u_Rp','u_Cp'},{'Rp','Cp'});
    
    % load SFDR (optional):
    try
        sfdr_file = [root_fld correction_load_transducer_get_file_key(inf,'sfdr path')];
    catch
        % default value {180 dB}
        sfdr_file = {[], [], 180};         
    end
    tran.SFDR = correction_load_table(sfdr_file,'rms',{'f','sfdr'});
    tran.SFDR.qwtb = qwtb_gen_naming('tr_sfdr','f','a',{'sfdr'},{''},{''});
    
    % load buffer series output impedance (optional):
    try
        Zbuf_file = [root_fld correction_load_transducer_get_file_key(inf,'buffer output series impedance path')];
    catch
        % default value {0 Ohm, 0 H}
        Zbuf_file = {[], 0.0, 0.0, 0.0, 0.0};       
    end
    tran.Zbuf = correction_load_table(Zbuf_file,'',{'f','Rs','Ls','u_Rs','u_Ls'});
    tran.Zbuf.qwtb = qwtb_gen_naming('tr_Zbuf','f','',{'Rs','Ls'},{'u_Rs','u_Ls'},{'Rs','Ls'});
    
    
    % this is a list of the correction that will be passed to the QWTB algorithm
    % note: any correction added to this list will be passed to the QWTB
    %       but it must contain the 'qwtb' record in the table (see eg. above)  
    tran.qwtb_list = {};
    % autobuild of the list of loaded correction:
    fnm = fieldnames(tran);
    for k = 1:numel(fnm)
        item = getfield(tran,fnm{k});
        if isfield(item,'qwtb')
            tran.qwtb_list{end+1} = fnm{k};
        end
    end
    
end

% get info text, if found and empty generate error
function [file_name] = correction_load_transducer_get_file_key(inf,key)
    file_name = infogettext(inf,key);
    if isempty(file_name)
        error('File name empty!');
    end  
end

 
function [qw] = qwtb_gen_naming(c_name,ax_prim,ax_sec,v_list,u_list,v_names)
% Correction table structure cannot be directly passed into the QWTB.
% So this will prepare names of the QWTB variables that will be used 
% for passing the table to the QWTB algorithm.
%
% Parameters:
%   c_name  - core name of the correction data
%   ax_prim - name of the primary axis suffix (optional)
%   ax_sec  - name of the secondary axis suffix (optional)
%   v_list  - cell array of the table's quantities to store
%   u_list  - cell array of the table's uncertainties to store
%   v_names - names of the suffixes for each item in the 'v_list'
%
% Example 1:
%   qw = qwtb_gen_naming('adc_gain','f','a',{'gain'},{'u_gain'},{''}):
%   qw.c_name = 'adc_gain'
%   qw.v_names = 'adc_gain'
%   qw.ax_prim = 'adc_gain_f'
%   qw.ax_sec = 'adc_gain_a'
%   qw.v_list = {'gain'}
%   qw.u_list = {'u_gain'}
%   this will be passed to the QWTB list:
%     di.adc_gain.v - the table quantity 'gain' 
%     di.adc_gain.u - the table quantity 'u_gain' (uncertainty)
%     di.adc_gain_f.v - primary axis of the table
%     di.adc_gain_a.v - secondary axis of the table
%
% Example 2:
%   qw = qwtb_gen_naming('Yin','f','',{'Rp','Cp'},{'u_Rp','u_Cp'},{'rp','cp'}):
%   qw.c_name = 'Yin'
%   qw.v_names = {'Yin_Rp','Yin_Cp'}
%   qw.ax_prim = 'Yin_f'
%   qw.ax_sec = ''
%   qw.v_list = {'Rp','Cp'}
%   qw.u_list = {'u_Rp','u_Cp'}
%   this will be passed to the QWTB list:
%     di.Yin_rp.v - the table quantity 'Rp' 
%     di.Yin_rp.u - the table quantity 'u_Rp' (uncertainty)
%     di.Yin_cp.v - the table quantity 'Cp' 
%     di.Yin_cp.u - the table quantity 'u_Cp' (uncertainty)
%     di.adc_gain_f.v - primary axis of the table

    
    V = numel(v_names);
    if V > 1
        % create variable names: 'c_name'_'v_names{:}':
        qw.v_names = {};
        for k = 1:V
            qw.v_names{k} = [c_name '_' v_names{k}];
        end
    else
        % variable name: 'c_name':
        qw.v_names = {c_name}; 
    end
    
    if ~isempty(ax_prim)
        qw.ax_prim = [c_name '_' ax_prim];
    else
        qw.ax_prim = '';         
    end
    if ~isempty(ax_sec)
        qw.ax_sec = [c_name '_' ax_sec];
    else
        qw.ax_sec = '';
    end
    qw.c_name = c_name;
    qw.v_list = v_list;
    qw.u_list = u_list;
    
end