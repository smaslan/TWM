%% Expects cells vector of structures. Combines element from every struct into vectors (for scalar elements) or into arrays (for vector elements).
%% In another words: Cells vector of structs to struct of vectors (or arrays).
%% First index of output struct vector/array elements indicates result id.  

function [res] = vectorize_structs_elements(inp)

  % input cells vector length
  N = length(inp);
          
  % get struct field names
  rnms = fieldnames(inp{1});
  rn = length(rnms);
  
  % initialize result
  res = struct();
  
  % convert vector of structs of elements to cell vector of element cells (much faster processing than getfield()/setfield())
  cinp = cell(N,1);
  for k = 1:N
    cinp{k} = struct2cell(inp{k});
  end
    
  % process output struct fields
  nel = 0;
  for n = 1:rn
    
    % get struct field
    fld = cinp{1}{n};

    % allocate buffers
    if(isscalar(fld) && (isnumeric(fld) || isreal(fld)))
      % is scalar
      par = zeros(N,1);
      par(1) = fld;
    elseif(isvector(fld) && (isnumeric(fld) || isreal(fld)))
      % is vector 
      par = zeros(N,length(fld));
      par(1,:) = fld;
    else
      % skip everything else
      continue;                
    end
    
    % combine input structs elements into single variable
    if(size(fld,1)>1)
      for m = 1:N            
        par(m,:) = cinp{m}{n}';
      end      
    else
      for m = 1:N            
        par(m,:) = cinp{m}{n};
      end
    end
           
    % add element into output structure
    res = setfield(res,rnms{n},par);  
     
  end  
end