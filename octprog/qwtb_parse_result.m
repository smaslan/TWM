%% -----------------------------------------------------------------------------
%% TracePQM: Parses single QWTB result. Returns one or more variables of the
%% result including their setup from the result header. It returns the variable(s)
%% for each available phase/channel in the result file.
%%
%%   Inputs:
%%     result_path - result full path without extension
%%     cfg - confiuration structure (all elements are optional):
%%           cfg.max_dim - maximum dimension of variable, otherwise it will ignore
%%                          0: only scalars
%%                          1: scalars, vectors
%%                          2: scalars, vectors, matrices
%%           cfg.max_array - maximum array elements to be returned
%%                           if exeeded, function will ignore the variable
%%     var_list - cell array of variable names to return
%%                note: if empty, returns all
%%
%%   Outputs:
%%     chn_list - always contain cell array of channels/phases,
%%                each channel/phase contain cell array of quantities,
%%                each quantity contain:
%%                  name - quantity's name
%%                  desc - quantity's description from QWTB
%%                  tag - tag of the channel or phase to which it belongs (u1, i1, L2, ...)
%%                  is_big - is non-zero when quantity exeeded limits given by 'cfg'
%%                  size - quantity's size()
%%                  dims - quantity's dimensions count (0: scalar, 1: vector, 2:matrix)
%%                  val - quantity's value
%%                  unc - quantity's uncertainty (empty array [] if not available)
%%                  is_phase - quantity is phase angle
%%                  is_graph - quantity is graph
%%                  graph_x - independent quantity name if 'is_graph'
%%                  num_format - prefered number format for displaying
%%                                 'f' - float number (no exponent)
%%                                 'si' - float number with SI sufix
%%                  min_unc_abs - minimum allowed abs. uncertainty of the var.
%%                                for displaying (default 1e-9) 
%%                  min_unc_rel - minimum allowed rel. uncertainty of the var.
%%                                for displaying (default 1e-6)
%% ----------------------------------------------------------------------------- 
function [chn_list,list] = qwtb_parse_result(result_path, cfg, var_list)

  list = {};
  
  if ~exist('var_list','var')
    % no variable list specified - load all
    var_list = {};
  end
  
  % load result info
  inf = infoload(result_path);  
  % parse the info file (faster usage): 
  inf = infoparse(inf);
  
  % complementary MAT file
  result_mat = [result_path '.mat'];
  
  % read QWTB algorithm setup
  try 
    alg_cfg = infogetsection(inf, 'algorithm configuration', {'QWTB processing setup'});
  catch
    alg_cfg = '';
  end

  % get list of excluded variables
  try 
    excludes = infogettextmatrix(alg_cfg, 'exclude outputs');
  catch
    excludes = {};
  end
  
  % get list of graph variables
  try 
    graphs = infogettextmatrix(alg_cfg, 'graphs');
  catch
    graphs = {};
  end
  
  % get list of phase variables
  try 
    phases = infogettextmatrix(alg_cfg, 'is phase');
  catch
    phases = {};
  end
  
  % try to get number formats of the quantities {name, format, min abs unc., min rel unc}
  try
    fmt = infogettextmatrix(alg_cfg, 'number formats');
  catch
    fmt = {};
  end
  if size(fmt,1) && size(fmt,2) ~= 4
    error('QWTB result parsed: Invalid setup ''number formats'' found!');
  end  
  
  % scan through the list of desired variables, check if they are in the list of graph variables
  % if so, add the independent variable to the list of loaded variables as well
  if size(graphs,1)
    for v = 1:numel(var_list)
      vid = find(strcmp(graphs(:,2),var_list{v}));
      for k = 1:numel(vid)
        var_list{end+1} = graphs{vid(k),1};
      end
    end
  end
  % get rid of duplicates in the list
  var_list = unique(var_list); 
  
  % get channels/phases list
  list = infogettextmatrix(inf, 'list');
  L = numel(list);
  
  % decide MAT file format (Octave sometimes needs explicit definition)
  if isOctave
    mat_fmt = '-v4';
  else
    mat_fmt = '-mat';
  end
  
  % --- for each phase/channel:
  for k = 1:L
    % get section
    sinf = infogetsection(inf, list{k});
    
    % get variable names
    var_names_all = infogettextmatrix(sinf, 'variable names');
    
    % filter variables:
    vars = {};
    for v = 1:numel(var_names_all)
    
      % create empty variable record
      myvar = struct();
      
      % this variable
      myvar.name = var_names_all{v};
      
      % try to find variable in the list of formats specifiers
      if size(fmt,2)
        fid = find(strcmp(fmt(:,1), myvar.name),1);
      else
        fid = [];
      end
      if numel(fid)
        % found - parse format and store to variables setup
        if ~any(strcmpi(fmt{fid,2},{'f','si'}))
          error(sprintf('QWTB result parsed: Invalid format specifier ''%s'' found for the variable ''%s''!',fmt{fid,2},myvar.name));
        end
        myvar.num_format = fmt{fid,2};
        myvar.min_unc_abs = str2num(fmt{fid,3});
        myvar.min_unc_rel = str2num(fmt{fid,4});
      else
        % use default format if not specified
        myvar.num_format = 'f';
        myvar.min_unc_abs = 1e-9;
        myvar.min_unc_rel = 1e-6;
      end
      
      % check if the variable is phase
      if numel(phases)
        pid = find(strcmp(phases(:), myvar.name),1);
      else
        pid = [];
      end
      myvar.is_phase = numel(pid) > 0;
      
      
      % store variable's phase/channel tag
      myvar.tag = list{k};      
      
      % filter out nonlisted variables unless there is no list
      if ~isempty(var_list) && ~any(strcmp(var_list, myvar.name))
        continue;
      end
            
      % filter out excluded variables
      if isempty(var_list) && any(strcmp(myvar.name,excludes))
        continue;
      end
      
      % this variable's section
      vinf = infogetsection(sinf, myvar.name);
      
      % get variable's size
      myvar.size = infogetmatrix(vinf, 'dimensions');
      
      % variable's dimensions count
      myvar.dims = sum(myvar.size > 1);
            
      % filter out variables that are larger than max allowed dims
      if myvar.dims > cfg.max_dim
        continue;
      end
      
      % is graph variable?
      if size(graphs,1)
        gid = find(strcmp(graphs(:,2),myvar.name),1);
      else
        gid = [];
      end
      myvar.is_graph = numel(gid) > 0;
      % store independent variable name of the graph
      if myvar.is_graph        
        myvar.graph_x = graphs{gid,1};
      end
           
            
      % set array too big flag?
      myvar.is_big = prod(myvar.size) > cfg.max_array;
      
      % load variable description
      myvar.desc = infogettext(vinf, 'description');
      
      % try to load the variable's data
      if ~myvar.is_big
        
        try 
          value = infogetmatrix(vinf, 'value');
        catch
          % value not stored in header, possibly it is in the complementary MAT file
          
          try
            % is it string?
            value = infogettext(vinf, 'value');
          catch 
            % get variable name in the MAT file
            value_var = infogettext(vinf, 'MAT file variable - value');
            
            % try to load the variable from MAT file
            value = load(result_mat, mat_fmt, value_var);
            if isstruct(value)
              value = struct2cell(value);
              value = value{:};
            end
          end
          
          
        end
        
        % always transform vectors to row
        if cfg.vec_horiz && myvar.dims == 1 && size(value,2) == 1
          myvar.val = value.';
          myvar.size = fliplr(myvar.size);
        else
          myvar.val = value;
        end
        
        try 
          unc = infogetmatrix(vinf, 'uncertainty');
        catch
          % value not stored in header, possibly it is in the complementary MAT file
                    
          % get variable name in the MAT file
          try
            unc_var = infogettext(vinf, 'MAT file variable - uncertainty');
            
            % try to load the variable from MAT file
            unc = load(result_mat, mat_fmt, unc_var);
            if isstruct(unc)
              unc = struct2cell(unc);
              unc = unc{:};
            end
                        
          catch
            unc = [];
          end
          
        end
        
        % always transform vectors to row
        if cfg.vec_horiz && myvar.dims == 1 && size(unc,2) == 1
          myvar.unc = unc.';          
        else
          myvar.unc = unc;
        end
      
      else
        % load inhibited - return empty value+unc
        myvar.val = [];  
        myvar.unc = [];
      end
      
      % store loaded variable to the list
      vars{end+1} = myvar;       
      
    end
    
    % store loaded channel/phase to the list
    chn_list{k} = vars;
  
  end

end