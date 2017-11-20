%% -----------------------------------------------------------------------------
%% QWTB TracePQM:
%% -----------------------------------------------------------------------------
function [alginfo,ptab,unc_list,input_params] = qwtb_load_algorithm(alg_id)

  % fetch information struct of the QWTB algorithm
  alginfo = qwtb(alg_id,'info');
  
  % get list of input parameters
  inps = alginfo.inputs(find([alginfo.inputs.parameter] ~= 0));
  
  % some constants for table building
  tab = sprintf('\t');
  eol = sprintf('\n');
  fmt = {tab,eol};
  
  % build parameter's table header
  ptab = '';
  row{1,1} = 'parameter';
  row{1,2} = 'value';
  
  % merge table row(s) to single string
  ptab = [ptab [cellfun('strcat',row(:),{fmt{1+[1:size(row,2) == size(row,2)]}}.','UniformOutput',false){:}]]; 
      
  % --- build parameters table  ---
  for k = 1:numel(inps)
    
    % clear current table row
    row = {};
    
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
    row{1,1} = name;

    % merge table row(s) to single string
    ptab = [ptab [cellfun('strcat',row(:),{fmt{1+[1:size(row,2) == size(row,2)]}}.','UniformOutput',false){:}]];
            
  end
  
  % build list of the possible uncertainty calculation modes 
  unc{1} = 'No uncertainty calculation';
  if alginfo.providesGUF
    unc{end+1} = 'Calculate by GUF';
  elseif alginfo.providesMCM
    unc{end+1} = 'Calculate by Monte Carlo';
  endif
  unc_list = [cellfun('strcat',unc(:),{tab},'UniformOutput',false){:}];
  
  % return description of the parameters
  input_params = [cellfun('strcat',{inps.desc},{tab},'UniformOutput',false){:}];
  
end