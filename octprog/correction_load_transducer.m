%% -----------------------------------------------------------------------------
%% TracePQM: Loader of the tranducer correction file.
%%
%% Inputs:
%%   file - absolute file path to the transducers header INFO file.
%%
%% Outputs:
%%   tran.type - string defining transducer type 'shunt', 'divider' 
%%   tran.name - string with transducer's name
%%   tran.sn - string with transducer's serial
%%   tran.nominal - transducer's nominal ratio (Ohms or Vin/Vout)
%% -----------------------------------------------------------------------------

function [tran] = correction_load_transducer(file)

  % root folder of the correction
  root_fld = [fileparts(file) filesep()];
  
  % try to load the correction file
  inf = infoload(file);
    
  % get correction type id
  t_type = infogettext(inf, 'type');
  
  % try to identify correction type
  id = find(strcmpi(t_type,{'shunt','divider'}),1);
  if ~numel(id)
    error(sprintf('Transducer correction loader: Correction type ''%s'' not recognized!'),t_type);
  end
  
  % store transducer type
  tran.type = t_type;
  
  % transducer correction name
  tran.name = infogettext(inf,'name');
  
  % transducer serial number
  tran.sn = infogettext(inf,'serial number');
  
  % load nominal ratio of the transducer
  tran.nominal = infogetnumber(inf,'nominal ratio');
  tran.u_nominal = infogetnumber(inf,'nominal ratio uncertainty');
    
  % load relative frequency/rms dependence (gain):
  try
    fdep_file = [root_fld infogettext(inf,'amplitude transfer path')];
  catch
    % default (gain, unc.) 
    fdep_file = {1.0,0.0};         
  end
  tfer_gain = correction_load_table(fdep_file,'rms',{'f','gain','u_gain'});
  
  % load frequency/rms dependence (phase):
  try
    fdep_file = [root_fld infogettext(inf,'phase transfer path')];
  catch
    % default (phase, unc.) 
    fdep_file = {0.0,0.0};         
  end
  tran.tfer_phi = correction_load_table(fdep_file,'rms',{'f','phi','u_phi'});
    
  
  % combine nominal gain and relative gain transfer to the absolute gain tfer.: 
  tran.tfer_gain = tran.nominal*tfer_gain.gain;
  tran.tfer_u_gain = (tran.u_nominal^2 + tfer_gain.u_gain.^2).^0.5;
    
  
  % --- load loading effect corrections ---
  
  % load output terminals series impedance (optional):
  try
    Zca_file = [root_fld correction_load_transducer_get_file_key(inf,'output terminals series impedance path')];
  catch
    % default value {0 Ohm, 0 H}
    Zca_file = {0.0, 0.0, 0.0, 0.0};         
  end
  tran.Zca = correction_load_table(Zca_file,'',{'f','Rs','Ls','u_Rs','u_Ls'});
  % load output terminal shunting admittance (optional):
  try
    Yca_file = [root_fld correction_load_transducer_get_file_key(inf,'output terminals shunting admittance path')];
  catch
    % default value {0 S, 0 D}
    Yca_file = {0.0, 0.0, 0.0, 0.0};         
  end
  tran.Yca = correction_load_table(Yca_file,'',{'f','Cp','D','u_Cp','u_D'});
  
  % load cable series impedance (optional):
  try
    Zcb_file = [root_fld correction_load_transducer_get_file_key(inf,'output cable series impedance path')];
  catch
    % default value {0 Ohm, 0 H}
    Zcb_file = {0.0, 0.0, 0.0, 0.0};         
  end
  tran.Zcb = correction_load_table(Zcb_file,'',{'f','Rs','Ls','u_Rs','u_Ls'});
  % load cable shunting admittance (optional):
  try
    Ycb_file = [root_fld correction_load_transducer_get_file_key(inf,'output terminals shunting admittance path')];
  catch
    % default value {0 S, 0 D}
    Ycb_file = {0.0, 0.0, 0.0, 0.0};         
  end
  tran.Ycb = correction_load_table(Ycb_file,'',{'f','Cp','D','u_Cp','u_D'});
  
  % load impedance of the low side of RVD (optional, applies only for RVDs):
  try
    Zlo_file = [root_fld correction_load_transducer_get_file_key(inf,'rvd low side impedance path')];
  catch
    % default value {0 Ohm, 0 Ohm}
    Zlo_file = {0.0, 0.0, 0.0, 0.0};         
  end
  tran.Zlo = correction_load_table(Zlo_file,'',{'f','Rs','Xs','u_Rs','u_Xs'});
  

end

% get info text, if found and empty generate error
function [file_name] = correction_load_transducer_get_file_key(inf,key)
  file_name = infogettext(inf,'output terminals series impedance path');
  if isempty(file_name)
    error('File name empty!');
  end  
end