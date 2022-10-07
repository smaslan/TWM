function [csv] = catcellcsv(cc,colsep,rowsep)

  % default separators
  if nargin < 3
    rowsep = sprintf('\n');
  end
  if nargin < 2
    colsep = sprintf('\t');
  end

  % input data size
  [R,C] = size(cc);  

  for r = 1:R
    % cat columns    
    row = cat(1,cc(r,:),repmat({colsep},[1 C]));
    row = [row{:}];
    rowss{r,1} = row(1:end-numel(colsep));
  end

  % cat rows
  if R
    csv = cat(2,rowss,repmat({rowsep},[R 1]))';
    csv = [csv{:}];
    csv = csv(1:end-1);
  else
    csv = '';
  end

end