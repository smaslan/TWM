function [tab] = qwtb_restore_correction_tables(din,cfg)
% TWM: This function will take QWTB input quantities restored by 'qwtb_restore_twm_input_dims()'
% and will build TWM style correction table structures from them. It will try to automatically 
% build all the default correction tables found in the input quantities.
% Point of coversion from raw correction matrices to the TWM correction tables is to ease 
% the use. The TWM style correction tables have few functions to properly handle
% cases when the correction data are independent on one or both axes or contain NaNs, etc.
%
% Note the function does not check presence of the default input quantities. 
% It will load default neutral values if not found, such as unity gain, zero phase shift, etc.
%
% Usage:
%   tab = qwtb_restore_correction_tables(din, cfg)
%
% Parameters:
%   din - input quantities passed from QWTB and processed by 'qwtb_restore_twm_input_dims()'
%   cfg - measurement configuration identified by 'qwtb_restore_twm_input_dims()'
%
% Returns:
%   tab - structure with reconstructed default TWM correction tables:
%           *adc_gain - gain transfer of the digitizer channel (dependent on 'f' and 'a')
%           *adc_phi  - phase transfer of the digitizer channel (dependent on 'f' and 'a')
%           *adc_sfdr - SFDR of the digitizer channel (dependent on 'f' and 'a')
%           *adc_Yin  - input Y of the digitizer channel (dependent on 'f')
%             where * is prefix: '' for single ended, single input 'y'  
%             where * is prefix: '' and 'lo_' for differential, single input 'y'
%             where * is prefix: 'u_' and 'i_' for single-ended, dual inputs 'u' and 'i'
%             where * is prefix: 'u_', 'i_', 'u_lo_' and 'i_lo' for differential, dual inputs 'u' and 'i'
%
%           *tr_gain - gain transfer of the transducer (dependent on 'f' and 'rms')
%           *tr_phi  - phase transfer of the transducer (dependent on 'f' and 'rms')
%           *tr_sfdr - SFDR of the transducer (dependent on 'f' and 'rms')
%           *tr_Zlo  - low-side impedance of RVD transducer (dependent on 'f')
%           *tr_Zca  - output series Z of transducer, (dependent on 'f')
%           *tr_Zcal - output series Z of transducer, low-side (dependent on 'f')
%           *tr_Zcam - mutual indunctance of the transducer terminals (dependent on 'f')
%           *tr_Yca  - output shunting Y of transducer (dependent on 'f')
%           *Zcb     - output series Z of cable to transducer (dependent on 'f')
%           *Ycb     - output shunting Y of cable to transducer (dependent on 'f')
%           *tr_Zbuf - output series Z of buffer (dependent on 'f')
%             where * is prefix: '' for single input 'y'   
%             where * is prefix: 'u_' and 'i_' for dual inputs 'u' and 'i'
%       
%
% License:
% --------
% This is part of the TWM - Traceable PQ Wattmeter
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.
% 

    % init output tables:
    tab = struct();
    
    % list of default channel quantities:
    t_list{1} = {{{'adc_gain'},                {'adc_gain_f';'adc_gain_a'}, {1},               {0},       {[],[]}, {'gain'},    {'f';'a'},   'adc_gain'},
                 {{'adc_phi'},                 {'adc_phi_f';'adc_phi_a'},   {0},               {0},       {[],[]}, {'phi'},     {'f';'a'},   'adc_phi'}, 
                 {{'adc_sfdr'},                {'adc_sfdr_f';'adc_sfdr_a'}, {180},             {},        {[],[]}, {'sfdr'},    {'f';'a'},   'adc_sfdr'},
                 {{'adc_Yin_Cp';'adc_Yin_Gp'}, {'adc_Yin_f'},               {[1e-15],[1e-15]}, {[0],[0]}, {[]},    {'Cp';'Gp'}, {'f'},       'adc_Yin'}};
             
    % list of default transducer quantities:
    t_list{2} = {{{'tr_gain'},                 {'tr_gain_f';'tr_gain_a'},   {1},               {0},       {[],[]}, {'gain'},    {'f';'rms'}, 'tr_gain'},
                 {{'tr_phi'},                  {'tr_phi_f';'tr_phi_a'},     {0},               {0},       {[],[]}, {'phi'},     {'f';'rms'}, 'tr_phi'}, 
                 {{'tr_sfdr'},                 {'tr_sfdr_f';'tr_sfdr_a'},   {180},             {},        {[],[]}, {'sfdr'},    {'f';'rms'}, 'tr_sfdr'},
                 {{'tr_Zlo_Rp';'tr_Zlo_Cp'},   {'tr_Zlo_f'},                {[1e3],[1e-15]},   {[0],[0]}, {[]},    {'Rp';'Cp'}, {'f'},       'tr_Zlo'},
                 {{'tr_Zca_Rs';'tr_Zca_Ls'},   {'tr_Zca_f'},                {[1e-9],[1e-12]},  {[0],[0]}, {[]},    {'Rs';'Ls'}, {'f'},       'tr_Zca'},
                 {{'tr_Yca_Cp';'tr_Yca_D'},    {'tr_Yca_f'},                {[1e-15],[1e-12]}, {[0],[0]}, {[]},    {'Cp';'D'},  {'f'},       'tr_Yca'},
                 {{'tr_Zcal_Rs';'tr_Zcal_Ls'}, {'tr_Zcal_f'},               {[1e-9],[1e-12]},  {[0],[0]}, {[]},    {'Rs';'Ls'}, {'f'},       'tr_Zcal'},
                 {{'tr_Zcam'},                 {'tr_Zcam_f'},               {[1e-12]},         {[0]},     {[]},    {'M'},       {'f'},       'tr_Zcam'},
                 {{'Zcb_Rs';'Zcb_Ls'},         {'Zcb_f'},                   {[1e-9],[1e-12]},  {[0],[0]}, {[]},    {'Rs';'Ls'}, {'f'},       'Zcb'},
                 {{'Ycb_Cp';'Ycb_D'},          {'Ycb_f'},                   {[1e-15],[1e-12]}, {[0],[0]}, {[]},    {'Cp';'D'},  {'f'},       'Ycb'},
                 {{'tr_Zbuf_Rs';'tr_Zbuf_Ls'}, {'tr_Zbuf_f'},               {[0],[0]},         {[0],[0]}, {[]},    {'Rs';'Ls'}, {'f'},       'tr_Zbuf'}};
                 % note: 'tf_Zbuf' must be generated with zero default impedance which disables the buffer option in the correction scheme!
                 %        yeah ... not the best way to do it, but it works... 

    % channel/tranducer quantity prefix lists:
    p_lists = {cfg.pfx_ch,cfg.pfx_tr};
    
    % for each group of tables:
    for t = 1:numel(t_list)
        % quantity channel/transducer prefix list:
        pfx_list = p_lists{t};
                
        % for each table:
        for a = 1:numel(t_list{t})
            % table setup:
            tpar = t_list{t}{a};
            
            % for each channel prefix:
            for p = 1:numel(pfx_list)
                % get channel prefix:
                pfx = pfx_list{p};
                % build input quantities full names (data):
                in_qu = strcat(repmat({pfx},size(tpar{1})),tpar{1});
                % build input quantities full names (axes):
                in_ax = strcat(repmat({pfx},size(tpar{2})),tpar{2});
                                       
                % build table:
                tab = setfield(tab,[pfx tpar{8}],qwtb_build_correction_table(din,in_qu,in_ax,tpar{3},tpar{4},tpar{5},tpar{6},tpar{7}));
            end    
        end
    end
   
end