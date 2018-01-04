function [] = correction_load_digitizer(minf, meas_root, rep_id, group_id)
% TWM: Loader of the digitizer corrections.
%
% Parameters:
%   minf - loaded measurement header file (info-strings)
%   meas_root - root folder of the measurement
%   rep_id              - measurement repetition id
%   group_id            - measurement group id
%
% Returns:
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2017, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
% 

    % get relative path to the digitizer corrections:
    cor_name = infogettext(minf, 'digitizer path', {'corrections'});
    
    % build absolute path to the corrections:
    cor_path = [meas_root filesep() cor_name];
    
    % load corrections info file:
    dinf = infoload(cor_path);
    
    % check correction file validity:
    ctype = infogettext(dinf, 'type');
    if ~strcmpi(ctype,'digitizer')
        error(sprintf('Digitizer correction loader: Invalid correction type ''%s''!',ctype));
    end
    
    % load list of the digitizer's channel names from the correction file:
    chn_names = infogetmatrixstr(dinf, 'channel identifiers');
    % load the same list from the measurement header
    meas_chn_names = infogetmatrixstr(minf, 'channel descriptors');
    
    % check if the correction file matches to the measurement header instruments:
    if ~all(strcmpi(chn_names,meas_chn_names))
        error('Digitizer correction loader: Instrument''s channel names in the correction file and measurement header do not match! This correction file cannot be used for this measurement.');
    end
        
    % load channel correction paths:
    chn_paths = infogetmatrixstr(dinf, 'channel correction paths');
    % check consistency:
    if numel(chn_paths) ~= numel(chn_names)
        error('Digitizer correction loader: Number of digitizer''s channels does not match.');
    end
    
    % try to load interchannel timeshifts
    table_cfg.primary_ax = '';
    table_cfg.second_ax = 'chn';
    table_cfg.quant_names = {'its','u_its'};       
    tbl = correction_parse_section(meas_root, dinf, minf, 'interchannel timeshift', table_cfg, 1, rep_id, group_id);
    
    
          

end