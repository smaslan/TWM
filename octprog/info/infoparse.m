function [idata] = infoparse(inf,mode)
% INFO-STRINGS: Parses info-string to sections, matrices and items.
% If will go through the string and recoursively parse the sections.
% Optionally it will also parse the matrices - it will extract the 
% string content of the matrix and stores it unchanged. Eventually
% it can also parse the scalar items (mode 'all').
% Note it only extracts the strings from the sections/matrices/items.
% It will not parse the content. It will just place it into lists.
%
% Inputs:
%  inf  - info-string
%  mode - Mode of parsing:
%          '' - only sections
%          'matrix' - sections and matrices
%          'all' - sections, matrices and items
%
%  Output is recoursive structure with items:
%    all_parsed - true when mode 'all'
%    matrix_parsed - true when mode 'all' or 'matrix'
%    sec_count - number of subsections
%    sec_names - cell array of subsection names
%    sections - cell array of subsections - each cell is the same as this struct
%    scalar_count - number of scalar items in section
%    scalar_names - cell array of scalar item names
%    scalars - cell array of scalar item string contents
%    matrix_count - number of matrices in section
%    matrix_names - cell array of matrix names
%    matrix - cell array of matrix string contents
%    data - unparsed section content, note it is removed vhen mode is 'all'  
%  

    % parse mode selection:
    if ~exist('mode','var')
        mode = 'all';
    end
    if strcmpi(mode,'matrix')
        parse_level = 1;
    elseif strcmpi(mode,'all')
        parse_level = 2;
    else
        parse_level = 0;         
    end

    % temporary line break:
    NL = char([10]);
    
    % add linebreaks around data (for simpler tokenization):
    inf = [NL inf NL];
    
    % get rid of system specific EOLs but do not change string size!:
    % note the result is stored in temporary string! original must be preserved
    % replace windows CRLF by ' LF'
    inflf = strrep(inf,char([13 10]),char([32 NL]));
    % not convert the rest of CR/LF to LF:
    inflf = strrep(inflf,char(13),NL);
       
    % find line breaks:
    nls = find(inflf == NL);
        
    % tokenize sections:
    if parse_level
        keystr = {'#startsection','#endsection','#startmatrix','#endmatrix'};
    else
        keystr = {'#startsection','#endsection'};
    end
    sec_name = {};
    sec_start = [];
    sec_end = [];
    sec_type = [];
    sec_pos = [];
    for s = 1:numel(keystr)    
        % look for token candidates:      
        ss = strfind(inflf,keystr{s});
        keystrlen = length(keystr{s});
        S = numel(ss);
        
        % for each candidate:
        for k = 1:S
            
            % extract one row:
            row_start = nls(find(nls < ss(k),1,'last')) + 1;
            row_end = nls(find(nls > ss(k),1)) - 1;        
            row = strtrim(inf(row_start:row_end));
            
            if strncmp(row,keystr{s},keystrlen)
                % the row starts with key-string, so it may be valid?
            
                % look for separator:
                qci = strfind(row,'::');
                if ~isempty(qci)
                    % separator is there, extract section's name:                
                    name = strtrim(row(qci+2:end));
                    
                    if ~isempty(name)
                        % name present - it is valid token
                        
                        % store section name:
                        sec_name{end+1} = name;
                        % section data (start/end):
                        sec_start(end+1) = row_end + 2;
                        sec_end(end+1) = row_start - 1;                                                        
                        % store section key type (start/end):  
                        sec_type(end+1) = s;
                        % store section key position:
                        sec_pos(end+1) = row_start;                                            
                    end                        
                end
            end
        end
    end
    
    % sort tokens by position in string, append fake #endsection token for parsing the global section:
    [sec_pos,id] = sort(sec_pos);    
    sec_name = {sec_name{id},'_'}; 
    sec_start = [sec_start(id),1];
    sec_end = [sec_end(id),length(inf)];
    sec_type = [sec_type(id),2];       
    
    % recoursive parsing of the sections:
    N = numel(sec_type);
    idata = infoparse_struct(struct(),inf,1,1,N,sec_pos,sec_name,sec_start,sec_end,sec_type,'_',2,parse_level);
    
    % update objects count:
    %idata.sec_count = numel(idata.sections);
    %idata.scalar_count = numel(idata.scalars);
    %idata.matrix_count = numel(idata.matrix);
    
    % and we are outa here...
        
end


function [idata,n,pos] = infoparse_struct(idata,inf,pos,n,N,sec_pos,sec_name,sec_start,sec_end,sec_type,name,stype,parse_level)
        
    % this section's data
    idata.data = '';
    
    % default output when subsection:
    if stype == 2
        idata.sec_names = {};
        idata.sections = {};
        idata.scalar_names = {};
        idata.scalars = {};
        idata.matrix_names = {};
        idata.matrix = {};
    end
    
    while n <= N
        
        % collect this section's data (without sub-section's data):
        idata.data = [idata.data,inf(pos:sec_end(n))];
        % update parse position:
        pos = sec_start(n); 
    
        if sec_type(n) == 2
            % #endsection        
            if ~strcmp(name,sec_name{n})
                error(sprintf('info-bourator: inconsitent data in info-string! ''#endsection %s'' does not match ''#startsection %s''.',sec_name{n},name));    
            end
            % valid #endsection - return
            
            % --- parse rest of this's section stuff (optional): ---            
            if parse_level > 1
                % line break
                NL = char(10);
                % add linebreaks around data (for simpler tokenization) 
                str = [NL idata.data NL];
                % find line breaks
                nls = find(str == char(13) | str == char(10));
     
                % search separators: 
                ss = strfind(str,'::');
                % for each separator:
                for k = 1:numel(ss)
                    % extract active part of the row:
                    row_start = nls(find(nls < ss(k),1,'last')) + 1;
                    row_end = nls(find(nls > ss(k),1)) - 1;    
                    
                    % store item
                    idata.scalar_names{end+1} = strtrim(str(row_start:ss(k)-1));
                    idata.scalars{end+1} = strtrim(str(ss(k)+2:row_end));                                     
                end
                
                % get rid of raw data because we parsed everything
                idata = rmfield(idata,'data');
              
                % set parse mode flags
                idata.all_parsed = 1;
                idata.matrix_parsed = 1;              
            else
                % set parse mode flags
                idata.all_parsed = 0;
                idata.matrix_parsed = ~~parse_level;
            end
            
            % update objects count
            idata.sec_count = numel(idata.sections);
            idata.scalar_count = numel(idata.scalars);
            idata.matrix_count = numel(idata.matrix);
            % format magic-id - used to identify the structure is generate by this function:
            idata.this_is_infostring = 1;
                  
            return;
            
        elseif sec_type(n) == 4
            % #endmatrix        
            if ~strcmp(name,sec_name{n})
                error(sprintf('info-bourator: inconsitent data in info-string! ''#endmatrix %s'' does not match ''#startmatrix %s''.',sec_name{n},name));    
            end
            % valid #endmatrix - return
            
            % return just content when matrix
            idata = idata.data;
            
            return;
            
        elseif sec_type(n) == 1
            % next #startsection
            
            % new section's name:
            new_name = sec_name{n};
            
            % go recursion:
            [sec_data,n,pos] = infoparse_struct(struct(),inf,pos,n+1,N,sec_pos,sec_name,sec_start,sec_end,sec_type,new_name,2,parse_level);
                     
            % collect subsection data
            idata.sec_names{end+1} = new_name;
            idata.sections{end+1} = sec_data;        
        
        elseif sec_type(n) == 3
            % next #startmatrix
            if stype == 4
                error(sprintf('info-bourator: inconsitent data in info-string! ''#startmatrix %s'' inside matrix ''%s''.',sec_name{n},name));
            end
            
            % new matrix name:
            new_name = sec_name{n};
            
            % go recursion:
            [item_data,n,pos] = infoparse_struct(struct(),inf,pos,n+1,N,sec_pos,sec_name,sec_start,sec_end,sec_type,new_name,4,parse_level);
                     
            % collect item data
            idata.matrix_names{end+1} = new_name;
            idata.matrix{end+1} = item_data;              
            
        end
        
        % move to the next token:
        n = n + 1;
      
    end
     
    error(sprintf('info-bourator: inconsitent data in info-string! Missing ''#endsection %s''.',name));     
    
end