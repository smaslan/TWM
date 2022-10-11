%% -----------------------------------------------------------------------------
%% QWTB TracePQM: Returns info for selected algorithm.
%% -----------------------------------------------------------------------------
function [alginfo,ptab,input_params_desc,support_multi_records,is_diff,has_ui,unc_guf,unc_mcm,output_params,input_params] = qwtb_load_algorithm(alg_id)
  
  % fetch information struct of the QWTB algorithm
  alginfo = qwtb(alg_id,'info');
  
  % get list of input parameters
  inps = alginfo.inputs(find([alginfo.inputs.parameter] ~= 0));
  
  
  % build parameter's table header
  row{1,1} = 'parameter';
  row{1,2} = 'value';
      
  % --- build parameters table  ---
  for k = 1:numel(inps)
 
    name = inps(k).name;    
    com = '';
    
    % is optional? 
    if inps(k).optional
      com = 'opt.';      
    end
    % has alternative?
    if inps(k).alternative
      if numel(com), com = [com ', ']; end;
      com = [com sprintf('alt. %d',inps(k).alternative)];
    end
    % combine row header
    if numel(com)
      name = [name '  (' com ')'];
    end     
    
    % write variable header to the param. table
    row{end+1,1} = name;
       
  end
  
  % algorithm supports multiple records at once?
  support_multi_records = ~~qwtb_find_parameter(alginfo.inputs,'support_multi_records');
  
  % supports differential tran. mode?
  is_diff = ~~qwtb_find_parameter(alginfo.inputs,'support_diff');
  
  % dual input algorithm?
  has_ui = ~qwtb_find_parameter(alginfo.inputs,'y');
  
  % convert parameters table to csv data
  ptab = catcellcsv(row);
  
  % build list of the possible uncertainty calculation modes 
  unc_guf = alginfo.providesGUF;
  unc_mcm = alginfo.providesMCM;
  
  % return description of the parameters
  input_params_desc = catcellcsv({inps.desc});
  
  % return description of the parameters
  input_params = catcellcsv({inps.name});
  
  % return description matrix of the output parameters
  output_params = catcellcsv(cat(1,{alginfo.outputs.name},{alginfo.outputs.desc}).');
  
end
