function [y] = tpqa_loader(fpath)
% A simple loader for TXT sample record from TPQA tool.
% It decides number of channels from the column headers CH1, CH2, CH...
% Returns matrix with one column per channel.
%
% This is part of the TWM - TracePQM WattMeter (http://tracepqm.cmi.cz/). 
% (c) 2019, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
%     
    
    % open record
    fr = fopen(fpath,'r');
    
    % extract samples count
    [t,t,t,t,str] = regexp(fgets(fr), '.*Record Length:\s*([\d]+)');    
    N = str2num(str{1}{1});
       
    % extract column headers
    str = fgets(fr);
    
    % columns count
    cols = sum(str == sprintf('\t'));
    
    % count channels
    C = 0;
    for c = 1:cols
        C = C + ~isempty(strfind(str,sprintf('CH%d',c)));
    end
    
    % close file
    fclose(fr);
    
    % read sample data
    y = dlmread(fpath, '\t', [3 1 N+2 C]);
       
end