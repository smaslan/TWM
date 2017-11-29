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

end