function [] = pokus(record,id);

  disp(['processing record ''' record '''']);

  
  inf = infoload(record);

  recz = infogetmatrixstr(inf,'record sample data files');

  record_binary = [fileparts(record) filesep() recz{id}];

  load('-mat4-binary',record_binary);
  y = y.';

  [N C] = size(y);

  plot(y);

  rms = sum(y.^2,1).^0.5/N

end