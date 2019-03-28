function [din, cfg] = qwtb_restore_twm_input_dims(din, opt, varargin)
% TWM: Restores original orientation of the input quantities vectors after passing them via QWTB.
% QWTB by default changes orientation of all vectors to row vectors. This is a problem as the 
% correction data are 2D matrices, because when one dimension is 1, then QWTB may change the
% orientation. So this function will restores their original orientations.
% It also restores orientation of the data 'y', 'u', 'i' if found.
%
% Usage:
% [dout, cfg] = qwtb_restore_twm_input_dims()
%  - to perform self-test
%
% [dout, cfg] = qwtb_restore_twm_input_dims(din)
%  - to restore all default quantities
%
% [dout, cfg] = qwtb_restore_twm_input_dims(din, opt)
%  - to restore restore all default quantities, ignore missing ones
%
% [dout, cfg] = qwtb_restore_twm_input_dims(din, opt, quantities, axes)
%  - to restore one particular quantity
%
% Parameters:
%   din - input quantities received by the QWTB wrapper
%   opt - non-zero value means the function won't throw an error, if some of the default
%         quantities are not found in the 'din'. It is optional parameter, default: 0.
%   quantities - name string or cell array of name strings of the quantities to restore 
%   axes       - cell array of name strings of the independent quantities for the 'quantities' 
%
% Returns:
%   dout - copy if 'din' with original dimensions restored
%   cfg  - structure with identified configuration of the 'din', items:
%            has_y     - nonzero if single input algorithm (has only 'y' input)
%            has_ui    - nonzero if two input algorithm (has 'u' and 'i' inputs)
%            y_is_diff - nonzero if 'y' input has complementary 'y_lo' input
%            u_is_diff - nonzero if 'u' input has complementary 'u_lo' input
%            i_is_diff - nonzero if 'i' input has complementary 'i_lo' input
%            is_multi  - nonzero if there are multiple records in 'y', 'u', 'i'
%            pfx_ch    - list of channel prefixes ('', 'u_' and 'i_' for single-ended,
%                        'lo_', 'lo_u_' and 'lo_i_' for differential complement, ...)
%            pfx_tr    - list of transducer channel prefixes ('', 'u_' and 'i_')
%            ysub      - list of transducer subchannels ('y' or {'y','y_lo'})
%            usub      - list of voltage transducer subchannels ('u' or {'u','u_lo'})
%            isub      - the same for current 'i_'
%
% License:
% --------
% This is part of the TWM - Traceable PQ Wattmeter
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.
%
       
    cfg = struct();
    
    if ~nargin
        % --- run testing ---
        
        din = twm_qwtb_restore_input_dims_test();
        return
        
    elseif nargin == 2+2
        % --- singe correction restoration ---
        
        din = twm_qwtb_restore_input_dim_corr(din, varargin{1}, varargin{2}, opt);
        
    elseif nargin < 3
        % --- restore all predefined correction ---
        
        if nargin == 1
            % by default throw an error if quantity not found
            opt = 0;
        end        
        
        % has 'y' input?
        cfg.has_y = isfield(din,'y');
        
        % has 'u' and 'i' inputs?
        ui = [isfield(din,'u') isfield(din,'i')];
        if xor(ui(1),ui(2))
            error('QWTB input quantities checker: missing one of the main inputs ''u'' or ''i''!');
        end
        cfg.has_ui = ui(1) && ui(2);
        
        % check input data consistency:
        if cfg.has_y && cfg.has_ui
            error('QWTB input quantities checker: input data seem to contain ''u'' and ''i'' but also ''y''!');
        end
        
        % has multiple records per input?
        if cfg.has_y
            cfg.is_multi = sum(size(din.y.v) > 1) > 1;
        elseif cfg.has_ui
            cfg.is_multi = sum(size(din.u.v) > 1) > 1;
        else
            cfg.is_multi = 0;
        end
        
        % check input data compatibility:
%        if cfg.is_multi && ~isfield(din, 'support_multi_inputs')
%            error('QWTB input quantities checker: there are multiple records in  ''y'', ''u'' or ''i'' whereas the ''support_multi_inputs'' is missing!');    
%        end
        
        % y/u/i are differential?
        cfg.y_is_diff = cfg.has_y && isfield(din,'y_lo');
        cfg.u_is_diff = cfg.has_ui && isfield(din,'u_lo');
        cfg.i_is_diff = cfg.has_ui && isfield(din,'i_lo');
        
        % build list of channel prefixes for the parameters:
        pfx_ch = {};
        pfx_tr = {};
        pfx_ysub = {};
        pfx_usub = {};
        pfx_isub = {};
        if cfg.has_y
            pfx_ch{end+1} = '';
            pfx_ysub{end+1} = 'y';
            if cfg.y_is_diff
                pfx_ch{end+1} = 'lo_';
                pfx_ysub{end+1} = 'y_lo';
            end
            pfx_tr{end+1} = '';
        elseif cfg.has_ui
            pfx_ch{end+1} = 'u_';
            pfx_ch{end+1} = 'i_';
            pfx_usub{end+1} = 'u';
            if cfg.u_is_diff
                pfx_ch{end+1} = 'u_lo_';
                pfx_usub{end+1} = 'u_lo';
            end
            pfx_isub{end+1} = 'i';
            if cfg.i_is_diff
                pfx_ch{end+1} = 'i_lo_';
                pfx_isub{end+1} = 'i_lo';
            end
            pfx_tr{end+1} = 'u_';
            pfx_tr{end+1} = 'i_';
        end
        
        % return the prefix lists for future use:
        cfg.pfx_ch = pfx_ch;
        cfg.pfx_tr = pfx_tr;
        cfg.ysub = pfx_ysub;
        cfg.usub = pfx_usub;
        cfg.isub = pfx_isub;
        
        % restore correction data vector orientations for channel corrections:
        for k = 1:numel(pfx_ch)
            % get quantity prefix:
            p = pfx_ch{k}; 
            % fix the default quantities:
            din = twm_qwtb_restore_input_dim_corr(din, [p 'adc_gain'], {[p 'adc_gain_f'];[p 'adc_gain_a']}, opt);
            din = twm_qwtb_restore_input_dim_corr(din, [p 'adc_phi'], {[p 'adc_phi_f'];[p 'adc_phi_a']}, opt);
            din = twm_qwtb_restore_input_dim_corr(din, [p 'adc_sfdr'], {[p 'adc_sfdr_f'];[p 'adc_sfdr_a']}, opt);
            din = twm_qwtb_restore_input_dim_corr(din, {[p 'adc_Yin_Cp'];[p 'adc_Yin_Gp']}, {[p 'adc_Yin_f']}, opt);           
            %din = twm_qwtb_restore_input_dim_corr(din, {'crosstalk_re';'crosstalk_im'}, {'crosstalk_f'}, opt); % to decide how to implement
        end
        
        % restore correction data vector orientations for transducer corrections:
        for k = 1:numel(pfx_tr)
            % get quantity prefix:
            p = pfx_tr{k}; 
            % fix the default quantities:
            din = twm_qwtb_restore_input_dim_corr(din, [p 'tr_gain'], {[p 'tr_gain_f'];[p 'tr_gain_a']}, opt);
            din = twm_qwtb_restore_input_dim_corr(din, [p 'tr_phi'], {[p 'tr_phi_f'];[p 'tr_phi_a']}, opt);
            din = twm_qwtb_restore_input_dim_corr(din, [p 'tr_sfdr'], {[p 'tr_sfdr_f'];[p 'tr_sfdr_a']}, opt);            
            din = twm_qwtb_restore_input_dim_corr(din, {[p 'tr_Zlo_Rp'];[p 'tr_Zlo_Cp']}, {[p 'tr_Zlo_f']}, opt);            
            din = twm_qwtb_restore_input_dim_corr(din, {[p 'tr_Zca_Rs'];[p 'tr_Zca_Ls']}, {[p 'tr_Zca_f']}, opt);
            din = twm_qwtb_restore_input_dim_corr(din, {[p 'tr_Yca_Cp'];[p 'tr_Yca_D']}, {[p 'tr_Yca_f']}, opt);
            din = twm_qwtb_restore_input_dim_corr(din, {[p 'tr_Zcal_Rs'];[p 'tr_Zcal_Ls']}, {[p 'tr_Zcal_f']}, opt);
            din = twm_qwtb_restore_input_dim_corr(din, {[p 'tr_Zcam']}, {[p 'tr_Zcam_f']}, opt);            
            din = twm_qwtb_restore_input_dim_corr(din, {[p 'Zcb_Rs'];[p 'Zcb_Ls']}, {[p 'Zcb_f']}, opt);
            din = twm_qwtb_restore_input_dim_corr(din, {[p 'Ycb_Cp'];[p 'Ycb_D']}, {[p 'Ycb_f']}, opt);
            din = twm_qwtb_restore_input_dim_corr(din, {[p 'tr_Zbuf_Rs'];[p 'tr_Zbuf_Ls']}, {[p 'tr_Zbuf_f']}, opt);
        end
        
        % create default transducer type(s):
        din = qwtb_rtwm_inps_default(din,cfg.has_y,'tr_type','');
        din = qwtb_rtwm_inps_default(din,cfg.has_ui,'u_tr_type','');
        din = qwtb_rtwm_inps_default(din,cfg.has_ui,'i_tr_type','');
        
        % create default digitizer timebase correction:
        din = qwtb_rtwm_inps_default(din,true,'adc_freq',0,0);
        
        % create default digitizer aperture correction (enabled by default!):
        din = qwtb_rtwm_inps_default(din,cfg.has_y,'adc_aper_corr',1);        
        din = qwtb_rtwm_inps_default(din,cfg.y_is_diff,'lo_adc_aper_corr',1);
        din = qwtb_rtwm_inps_default(din,cfg.has_ui,'u_adc_aper_corr',1);
        din = qwtb_rtwm_inps_default(din,cfg.has_ui,'i_adc_aper_corr',1);
        din = qwtb_rtwm_inps_default(din,cfg.u_is_diff,'u_lo_adc_aper_corr',1);
        din = qwtb_rtwm_inps_default(din,cfg.i_is_diff,'i_lo_adc_aper_corr',1);        
        %  - create default aperture:
        din = qwtb_rtwm_inps_default(din,true,'adc_aper',0);
                
        % create default jitter:
        din = qwtb_rtwm_inps_default(din,cfg.has_y,'adc_jitter',0);        
        din = qwtb_rtwm_inps_default(din,cfg.y_is_diff,'lo_adc_jitter',0);
        din = qwtb_rtwm_inps_default(din,cfg.has_ui,'u_adc_jitter',0);
        din = qwtb_rtwm_inps_default(din,cfg.has_ui,'i_adc_jitter',0);
        din = qwtb_rtwm_inps_default(din,cfg.u_is_diff,'u_lo_adc_jitter',0);
        din = qwtb_rtwm_inps_default(din,cfg.i_is_diff,'i_lo_adc_jitter',0);
        
        % create digitizer input offset voltage:
        din = qwtb_rtwm_inps_default(din,cfg.has_y,'adc_offset',0,0);        
        din = qwtb_rtwm_inps_default(din,cfg.y_is_diff,'lo_adc_offset',0,0);
        din = qwtb_rtwm_inps_default(din,cfg.has_ui,'u_adc_offset',0,0);
        din = qwtb_rtwm_inps_default(din,cfg.has_ui,'i_adc_offset',0,0);
        din = qwtb_rtwm_inps_default(din,cfg.u_is_diff,'u_lo_adc_offset',0,0);
        din = qwtb_rtwm_inps_default(din,cfg.i_is_diff,'i_lo_adc_offset',0,0);
        
        % create default time-stamp (y or u channel):
        din = qwtb_rtwm_inps_default(din,true,'time_stamp',0,0);
        
        % create default (i-u) high-side channel time shift:
        din = qwtb_rtwm_inps_default(din,cfg.has_ui,'time_shift',0,0);             
        
        % create default differential channel time shift corrections:
        din = qwtb_rtwm_inps_default(din,cfg.y_is_diff,'time_shift_lo',0,0);
        din = qwtb_rtwm_inps_default(din,cfg.u_is_diff,'u_time_shift_lo',0,0);
        din = qwtb_rtwm_inps_default(din,cfg.i_is_diff,'i_time_shift_lo',0,0);
        
        % create default ADC resolution:
        din = qwtb_rtwm_inps_default(din,true,'adc_bits',40);
        din = qwtb_rtwm_inps_default(din,cfg.y_is_diff,'lo_adc_bits',40);
        din = qwtb_rtwm_inps_default(din,cfg.has_ui,'u_adc_bits',40);
        din = qwtb_rtwm_inps_default(din,cfg.has_ui,'i_adc_bits',40);
        din = qwtb_rtwm_inps_default(din,cfg.u_is_diff,'u_lo_adc_bits',40);
        din = qwtb_rtwm_inps_default(din,cfg.i_is_diff,'i_lo_adc_bits',40);
        % create default ADC range:
        din = qwtb_rtwm_inps_default(din,true,'adc_nrng',1000);
        din = qwtb_rtwm_inps_default(din,cfg.y_is_diff,'lo_adc_nrng',1000);
        din = qwtb_rtwm_inps_default(din,cfg.has_ui,'u_adc_nrng',1000);
        din = qwtb_rtwm_inps_default(din,cfg.has_ui,'i_adc_nrng',1000);
        din = qwtb_rtwm_inps_default(din,cfg.u_is_diff,'u_lo_adc_nrng',1000);
        din = qwtb_rtwm_inps_default(din,cfg.i_is_diff,'i_lo_adc_nrng',1000);

        
        
        % fix input data, so the vectors are always vertical
        if cfg.has_y && ~cfg.is_multi 
            din.y.v = din.y.v(:);
            if cfg.y_is_diff
                din.y_lo.v = din.y_lo.v(:);
            end
        end
        if cfg.has_ui && ~cfg.is_multi
            din.u.v = din.u.v(:);
            din.i.v = din.i.v(:);
            if cfg.u_is_diff 
                din.u_lo.v = din.u_lo.v(:);                
            end
            if cfg.i_is_diff
                din.i_lo.v = din.i_lo.v(:);
            end
        end    
    
    end
    
end




function [din] = qwtb_rtwm_inps_default(din,condition,name,value,unc)
% create default qwtb style input quantity of name 'name' of 'condition' is met and 
% it does not exist in the 'din' QWTB input list. If it exist but has unassigned uncertainty
% it will assing it if the 'unc' parameter is assigned. 
    
    if condition

        has_unc = nargin >= 5;
    
        if ~isfield(din, name)
            item.v = value;
        else
            item = getfield(din, name);
        end
        if has_unc && (~isfield(item,'u') || isempty(item.u))
            item.u = unc;
        end        
        din = setfield(din, name, item);         
    
    end
    
end


function [din] = twm_qwtb_restore_input_dim_corr(din, data, data_axes, opt)
% TWM: restores correction orientation for single correction item
%  din - structure with the correction data (from QWTB)
%  data - name string of the correction data
%         note if there are multiple corrections with shared axes, this must
%         be cell array of all related correction data names
%  data_axes - cell array of string names of correction data independent axes
%            - first item is vertical axis, second is horizontal (optional)
%  opt - non-zero if the quantities are optional (won't generate error if missing) 
%
% It will return an error if correction is incomplete, i.e. if axis is missing or data is missing.
%

    if ischar(data)
        data = {data};
    end
    V = numel(data);
    
    if nargin < 4
        % by default the quantity is not optional 
        opt = 0;
    end
  
    for k = 1:numel(data)
        % --- for each variable in data:
        
        if isfield(din, data{k}) && all(cellfun(@isfield,repmat({din},size(data_axes)),data_axes))
            % correction exists
            
            corr_data = getfield(din,data{k});
            corr_prim = getfield(din,data_axes{1});
            
            if numel(data_axes) == 1
                % --- just one parameter dependence:
                
                if isvector(corr_data.v)
                    % 1D correction data - simply transpose to vertical:
                    corr_data.v = corr_data.v(:);
                    if isfield(corr_data,'u')
                        corr_data.u = corr_data.u(:);
                    end
                    % independent variable also to vertical
                    if k == V
                        corr_prim.v = corr_prim.v(:);
                    end  
                end
            
            elseif numel(data_axes) == 2
                % --- two parameter dependence:
                
                corr_sec = getfield(din,data_axes{2});
                
                if isvector(corr_data.v) && ((size(corr_data.v,1) > 1 && numel(corr_sec.v) > 1) || (size(corr_data.v,2) > 1 && numel(corr_prim.v) > 1))
                    % must be transposed:
                    corr_data.v = corr_data.v.';
                    if isfield(corr_data,'u')
                        corr_data.u = corr_data.u.';  
                    end                        
                end
                % restore original independent variables orientations
                if k == V && size(corr_prim.v,2) > 1
                    corr_prim.v = corr_prim.v.';      
                end
                if k == V && size(corr_sec.v,1) > 1
                    corr_sec.v = corr_sec.v.';      
                end
                
                % store back secondary axis
                din = setfield(din,data_axes{2},corr_sec);
                          
            end
            
            % store back primary axis
            din = setfield(din,data_axes{1},corr_prim);
            
            % store back correction data
            din = setfield(din,data{k},corr_data);
              
        elseif ~opt && any(~[isfield(din, data{k});cellfun(@isfield,repmat({din},size(data_axes)),data_axes)])
            % some of the components of the correction is missing!
            error(sprintf('Correction consitency test failed for correction ''%s''! Some of the components is missing (either corretion data, or dependency axis).',data{k}));  
        end
    end

end









% ====== SELF-TEST SECTION ======

%!assert(qwtb_restore_twm_input_dims())

function ret = twm_qwtb_restore_input_dims_test()
% this is simple test function that should validate the above scripts
    
    % build some fake data structure
    din = struct();
    for k = 1:50
        name = sprintf('long_name_%2d',int32(k));
        val = rand(100,10);
        din = setfield(din,name,struct('v',val,'u',val));   
    end
    
    % try to call the fix function with non-existent data items - just to measure how fast it is:
    tid = tic();
    for k = 1:100   
        try
            dout = qwtb_restore_twm_input_dims(din,0,{'non_existent_item';'non_existent_item_2'},{'data_y';'data_x'});
        end
    end
    disp(sprintf('performance tests %d s\n',toc(tid)));
    
    % do basic test of low level functionality 
    clear din;
    din.data_a.v = [1];
    din.data_y.v = [];    
    dout = qwtb_restore_twm_input_dims(din,0,'data_a',{'data_y'});
    if size(dout.data_a.v) ~= size(din.data_a.v) || size(dout.data_y.v) ~= size(din.data_y.v)
        error('Failed at 1D test with 0D data.');
    end
    
    clear din;
    din.data_a.v = [1 2 3];
    din.data_y.v = [1 2 3];    
    dout = qwtb_restore_twm_input_dims(din,0,'data_a',{'data_y'});
    if size(dout.data_a.v) ~= size(din.data_a.v') || size(dout.data_y.v) ~= size(din.data_y.v')
        error('Failed at 1D test with 1D data.');
    end    
  
    clear din;
    din.data_a.v = [1];
    din.data_x.v = [];
    din.data_y.v = [];
    dout = qwtb_restore_twm_input_dims(din,0,'data_a',{'data_y';'data_x'});
    if size(dout.data_a.v) ~= size(din.data_a.v) || size(dout.data_y.v) ~= size(din.data_y.v) || size(dout.data_x.v) ~= size(din.data_x.v)
        error('Failed at 2D test with 0D data.');
    end
    
    clear din;
    din.data_a.v = [1 2 3];
    din.data_x.v = [];
    din.data_y.v = [1 2 3];
    dout = qwtb_restore_twm_input_dims(din,0,'data_a',{'data_y';'data_x'});
    if size(dout.data_a.v) ~= size(din.data_a.v') || size(dout.data_y.v) ~= size(din.data_y.v') || size(dout.data_x.v) ~= size(din.data_x.v)
        error('Failed at 2D test with y-1D data.');
    end
    
    clear din;
    din.data_a.v = [1 2 3];
    din.data_x.v = [1 2 3];
    din.data_y.v = [];
    dout = qwtb_restore_twm_input_dims(din,0,'data_a',{'data_y';'data_x'});
    if size(dout.data_a.v) ~= size(din.data_a.v) || size(dout.data_y.v) ~= size(din.data_y.v) || size(dout.data_x.v) ~= size(din.data_x.v)
        error('Failed at 2D test with x-1D data.');
    end
    
    clear din;
    din.data_a.v = [1 2 3;4 5 6];
    din.data_x.v = [1 2 3];
    din.data_y.v = [1 2];
    dout = qwtb_restore_twm_input_dims(din,0,'data_a',{'data_y';'data_x'});
    if size(dout.data_a.v) ~= size(din.data_a.v) || size(dout.data_y.v) ~= size(din.data_y.v') || size(dout.data_x.v) ~= size(din.data_x.v)
        error('Failed at 2D test with 2D data.');
    end
    
    clear din;
    din.data_a.v = [1 2 3];
    din.data_b.v = [1 2 3];
    din.data_x.v = [];
    din.data_y.v = [1 2 3];
    dout = qwtb_restore_twm_input_dims(din,0,{'data_a';'data_b'},{'data_y';'data_x'});
    if size(dout.data_a.v) ~= size(din.data_a.v') || size(dout.data_b.v) ~= size(din.data_b.v') || size(dout.data_y.v) ~= size(din.data_y.v') || size(dout.data_x.v) ~= size(din.data_x.v)
        error('Failed at 2D test with multi 2D data.');
    end
    
    clear din;
    din.data_a.v = [1 2 3];
    din.data_a.u = [1 2 3];
    din.data_x.v = [];
    din.data_y.v = [1 2 3];
    dout = qwtb_restore_twm_input_dims(din,0,'data_a',{'data_y';'data_x'});
    if size(dout.data_a.u) ~= size(dout.data_a.v)
        error('Failed at 2D test with 2D data - uncertainty does not match data.');
    end
    
    
    % --- full test:
    
    clear din;
    din.y.v = ones(1,100);
    [dout, cfg] = qwtb_restore_twm_input_dims(din,1);
    if size(dout.y.v) ~= size(din.y.v') || cfg.is_multi || cfg.y_is_diff
        error('Failed at sample data orientation restoration.');
    end
    
    clear din;
    din.support_multi_inputs.v = 1;
    din.y.v = ones(10,100);
    [dout, cfg] = qwtb_restore_twm_input_dims(din,1);
    if size(dout.y.v) ~= size(din.y.v) || ~cfg.is_multi || cfg.y_is_diff
        error('Failed at sample data orientation restoration.');
    end
    
%     clear din;
%     din.y.v = ones(100,10);
%     try
%         dout = qwtb_restore_twm_input_dims(din,1);
%         ok = 0;
%     catch
%         ok = 1;
%     end
%     if ~ok
%         error('Failed at input data records compatibility test.');
%     end
    
    clear din;
    din.y.v = ones(1,100);
    din.y_lo.v = ones(1,100);
    [dout, cfg] = qwtb_restore_twm_input_dims(din,1);
    if size(dout.y_lo.v) ~= size(din.y_lo.v') || ~cfg.y_is_diff
        error('Failed at sample data orientation restoration.');
    end
    
    
    clear din;
    din.u.v = ones(1,100);
    din.i.v = ones(1,100);
    [dout, cfg] = qwtb_restore_twm_input_dims(din,1);
    if size(dout.u.v) ~= size(din.u.v') || size(dout.i.v) ~= size(din.i.v') || cfg.is_multi || cfg.u_is_diff || cfg.i_is_diff 
        error('Failed at sample data orientation restoration.');
    end
    
    clear din;
    din.support_multi_inputs.v = 1;
    din.u.v = ones(100,10);
    din.i.v = ones(100,10);
    [dout, cfg] = qwtb_restore_twm_input_dims(din,1);
    if size(dout.u.v) ~= size(din.u.v) || size(dout.i.v) ~= size(din.i.v) || ~cfg.is_multi || cfg.u_is_diff || cfg.i_is_diff
        error('Failed at sample data orientation restoration.');
    end
    
%     clear din;
%     din.u.v = ones(10,100);
%     din.i.v = ones(10,100);
%     try
%         dout = qwtb_restore_twm_input_dims(din,1);
%         ok = 0;
%     catch
%         ok = 1;
%     end
%     if ~ok
%         error('Failed at input data records compatibility test.');
%     end
    
    clear din;
    din.u.v = ones(1,100);
    din.i.v = ones(1,100);
    din.u_lo.v = ones(1,100);
    din.i_lo.v = ones(1,100);
    [dout, cfg] = qwtb_restore_twm_input_dims(din,1);
    if size(dout.u_lo.v) ~= size(din.u_lo.v') || size(dout.i_lo.v) ~= size(din.i_lo.v') || cfg.is_multi || ~cfg.u_is_diff || ~cfg.i_is_diff 
        error('Failed at sample data orientation restoration.');
    end
    
    
    clear din;
    din.support_multi_inputs.v = 1;
    din.y.v = ones(1,10);
    din.y_lo.v = ones(1,10);    
    din.adc_gain.v = [1 2 3];
    din.adc_gain_f.v = [1 2 3];
    din.adc_gain_a.v = [];    
    din.lo_adc_gain.v = [1 2 3];
    din.lo_adc_gain_f.v = [1 2 3];
    din.lo_adc_gain_a.v = [];
    din.tr_gain.v = [1 2 3];
    din.tr_gain_f.v = [1 2 3];
    din.tr_gain_a.v = [];  
    [dout, cfg] = qwtb_restore_twm_input_dims(din,1);
    if size(dout.adc_gain.v) ~= size(din.adc_gain.v') || size(dout.adc_gain_f.v) ~= size(din.adc_gain_f.v') || size(dout.lo_adc_gain.v) ~= size(din.lo_adc_gain.v') || size(dout.lo_adc_gain_f.v) ~= size(din.lo_adc_gain_f.v') || size(dout.tr_gain.v) ~= size(din.tr_gain.v') || size(dout.tr_gain_f.v) ~= size(din.tr_gain_f.v')
        error('Failed at se/diff channel correction restoration ''y'' input.');
    end
    
    
    clear din;
    din.support_multi_inputs.v = 1;
    din.u.v = ones(1,10);
    din.u_lo.v = ones(1,10);    
    din.i.v = ones(1,10);
    din.i_lo.v = ones(1,10);
    din.u_adc_gain.v = [1 2 3];
    din.u_adc_gain_f.v = [1 2 3];
    din.u_adc_gain_a.v = [];    
    din.i_adc_gain.v = [1 2 3];
    din.i_adc_gain_f.v = [1 2 3];
    din.i_adc_gain_a.v = [];
    din.u_lo_adc_gain.v = [1 2 3];
    din.u_lo_adc_gain_f.v = [1 2 3];
    din.u_lo_adc_gain_a.v = [];
    din.i_lo_adc_gain.v = [1 2 3];
    din.i_lo_adc_gain_f.v = [1 2 3];
    din.i_lo_adc_gain_a.v = [];
    din.u_tr_gain.v = [1 2 3];
    din.u_tr_gain_f.v = [1 2 3];
    din.u_tr_gain_a.v = [];  
    din.i_tr_gain.v = [1 2 3];
    din.i_tr_gain_f.v = [1 2 3];
    din.i_tr_gain_a.v = [];
    [dout, cfg] = qwtb_restore_twm_input_dims(din,1);
    if size(dout.u_adc_gain.v) ~= size(din.u_adc_gain.v') || size(dout.u_adc_gain_f.v) ~= size(din.u_adc_gain_f.v') || size(dout.i_adc_gain.v) ~= size(din.i_adc_gain.v') || size(dout.i_adc_gain_f.v) ~= size(din.i_adc_gain_f.v') || size(dout.u_lo_adc_gain.v) ~= size(din.u_lo_adc_gain.v') || size(dout.u_lo_adc_gain_f.v) ~= size(din.u_lo_adc_gain_f.v') || size(dout.i_lo_adc_gain.v) ~= size(din.i_lo_adc_gain.v') || size(dout.i_lo_adc_gain_f.v) ~= size(din.i_lo_adc_gain_f.v') || size(dout.u_tr_gain.v) ~= size(din.u_tr_gain.v') || size(dout.u_tr_gain_f.v) ~= size(din.u_tr_gain_f.v') || size(dout.i_tr_gain.v) ~= size(din.i_tr_gain.v') || size(dout.i_tr_gain_f.v) ~= size(din.i_tr_gain_f.v')
        error('Failed at se/diff channel correction restoration for ''u''/''i'' inputs.');
    end 
    
    ret = 1;
 
end 