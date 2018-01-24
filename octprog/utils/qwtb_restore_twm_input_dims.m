function [din] = qwtb_restore_twm_input_dims(din, varargin)
%
% TWM: Restores original orientation of the input quantities vectors after passing them via QWTB.
% QWTB by default changes orientation of all vectors to row vectors. This is a problem as the 
% correction data are 2D matrices, because when one dimension is 1, then QWTB may change the
% orientation. So this function will restores their original orientations.
% It also restores orientation of the data 'y', 'u', 'i' and 't' if found.
%
% License:
% --------
% This is part of the TWM - Traceable PQ Wattemter
% (c) 2017, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.
%
    
    % ###note: NOT DONE YET!!!!
    
    
    if ~nargin
        % --- run testing ---
        
        din = twm_qwtb_restore_input_dims_test();
        return
        
    elseif nargin == 1+2
        % --- singe correction restoration ---
        
        din = twm_qwtb_restore_input_dim_corr(din, varargin{1}, varargin{2});
                      
    else
        % --- restore all predefined correction ---
        
        
        % has 'y' input?
        has_y = isfield(din,'y');
        
        % has 'u' and 'i' inputs?
        ui = [isfield(din,'u') isfield(din,'i')];
        if xor(ui(1),ui(2))
            error('QWTB input quantities checker: missing one of the main inputs ''u'' or ''i''!');
        end
        has_ui = ui(1) && ui(2);
        
        % has multiple records per input?
        if has_y
            is_multi = sum(size(din.y.v) > 1) > 1;
        elseif has_ui
            is_multi = sum(size(din.u.v) > 1) > 1;
        else
            is_multi = 0;
        end
        
        % y/u/i are differential?
        y_is_diff = has_y && isfield(din,'y_lo');
        u_is_diff = has_ui && isfield(din,'u_lo');
        i_is_diff = has_ui && isfield(din,'i_lo');
        
        % build list of channel prefixes for the parameters:
        pfx_ch = {};
        pfx_tr = {};
        if has_y
            pfx_ch{end+1} = '';
            pfx_tr{end+1} = '';
            if y_is_diff
                pfx_ch{end+1} = 'lo_';
            end
        elseif has_ui
            pfx_ch{end+1} = 'u_';
            pfx_ch{end+1} = 'i_';
            pfx_tr{end+1} = 'u_';
            pfx_tr{end+1} = 'i_';
            if u_is_diff
                pfx_ch{end+1} = 'u_lo_';
            end
            if i_is_diff
                pfx_ch{end+1} = 'i_lo_';
            end
        end

        % restore correction data vector orientations for channel corrections:
        for k = 1:numel(pfx_ch)
            % get quantity prefix:
            p = pfx_ch{k}; 
            % fix the default quantities:
            din = twm_qwtb_restore_input_dim_corr(din, {[p 'adc_gain'];[p 'adc_phi']}, {[p 'adc_gain_f'];[p 'adc_gain_a']});
            din = twm_qwtb_restore_input_dim_corr(din, [p 'adc_sfdr'], {[p 'adc_sfdr_f'];[p 'adc_sfdr_a']});
            din = twm_qwtb_restore_input_dim_corr(din, {[p 'adc_Yin_Cp'];[p 'adc_Yin_Gp']}, {[p 'adc_Yin_f']});           
            %din = twm_qwtb_restore_input_dim_corr(din, {'crosstalk_re';'crosstalk_im'}, {'crosstalk_f'});
        end
        
        % restore correction data vector orientations for transducer corrections:
        for k = 1:numel(pfx_ch)
            % get quantity prefix:
            p = pfx_ch{k}; 
            % fix the default quantities:
            din = twm_qwtb_restore_input_dim_corr(din, {[p 'tr_gain'];[p 'tr_phi']}, {[p 'tr_gain_f'];[p 'tr_gain_a']});
            din = twm_qwtb_restore_input_dim_corr(din, [p 'tr_sfdr'], {[p 'tr_sfdr_f'];[p 'tr_sfdr_a']});            
            din = twm_qwtb_restore_input_dim_corr(din, {[p 'tr_Zlo_Rp'];[p 'tr_Zlo_Cp']}, {[p 'tr_Zlo_f']});
            din = twm_qwtb_restore_input_dim_corr(din, {[p 'tr_Zca_Rs'];[p 'tr_Zca_Ls']}, {[p 'tr_Zca_f']});
            din = twm_qwtb_restore_input_dim_corr(din, {[p 'tr_Yca_Cp'];[p 'tr_Yca_D']}, {[p 'tr_Yca_f']});
            din = twm_qwtb_restore_input_dim_corr(din, {[p 'Zcb_Rs'];[p 'Zcb_Ls']}, {[p 'Zcb_f']});
            din = twm_qwtb_restore_input_dim_corr(din, {[p 'Ycb_Cp'];[p 'Ycb_D']}, {[p 'Ycb_f']});            
        end
       
        
        % fix input data, so the vectors are always vertical
        if has_y && ~is_multi 
            din.y.v = din.y.v(:);
            if y_is_diff
                din.y_lo.v = din.y_lo.v(:);
            end
        end
        if has_ui && ~is_multi
            din.u.v = din.u.v(:);
            din.i.v = din.i.v(:);
            if u_is_diff 
                din.u_lo.v = din.u_lo.v(:);                
            end
            if i_is_diff
                din.i_lo.v = din.i_lo.v(:);
            end
        end
    
    % ###todo: the rest of the corrections, is there are some new...
    end
    
end



function [din] = twm_qwtb_restore_input_dim_corr(din, data, data_axes)
% TWM: restores correction orientation for single correction item
%  din - structure with the correction data (from QWTB)
%  data - name string of the correction data
%         note if there are multiple corrections with shared axes, this must
%         be cell array of all related correction data names
%  data_axes - cell array of string names of correction data independent axes
%            - first item is vertical axis, second is horizontal (optional)
%
% It will return an error if correction is incomplete, i.e. if axis is missing or data is missing.
%

    if ischar(data)
        data = {data};
    end
    V = numel(data);
  
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
              
        elseif any([isfield(din, data{k});cellfun(@isfield,repmat({din},size(data_axes)),data_axes)])
            % some of the components of the correction is missing!
            error(sprintf('Correction consitency test failed for correction ''%s''! Some of the components is missing (either corretion data, or dependency axis).',data{k}));  
        end
    end

end



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
            dout = qwtb_restore_twm_input_dims(din,{'non_existent_item';'non_existent_item_2'},{'data_y';'data_x'});
        end
    end
    toc(tid)
    
    qwtb_restore_twm_input_dims(din);
    
    clear din;
    din.data_a.v = [1];
    din.data_y.v = [];    
    dout = qwtb_restore_twm_input_dims(din,'data_a',{'data_y'});
    if size(dout.data_a.v) ~= size(din.data_a.v) || size(dout.data_y.v) ~= size(din.data_y.v)
        error('Failed at 1D test with 0D data.');
    end
    
    clear din;
    din.data_a.v = [1 2 3];
    din.data_y.v = [1 2 3];    
    dout = qwtb_restore_twm_input_dims(din,'data_a',{'data_y'});
    if size(dout.data_a.v) ~= size(din.data_a.v') || size(dout.data_y.v) ~= size(din.data_y.v')
        error('Failed at 1D test with 1D data.');
    end    
  
    clear din;
    din.data_a.v = [1];
    din.data_x.v = [];
    din.data_y.v = [];
    dout = qwtb_restore_twm_input_dims(din,'data_a',{'data_y';'data_x'});
    if size(dout.data_a.v) ~= size(din.data_a.v) || size(dout.data_y.v) ~= size(din.data_y.v) || size(dout.data_x.v) ~= size(din.data_x.v)
        error('Failed at 2D test with 0D data.');
    end
    
    clear din;
    din.data_a.v = [1 2 3];
    din.data_x.v = [];
    din.data_y.v = [1 2 3];
    dout = qwtb_restore_twm_input_dims(din,'data_a',{'data_y';'data_x'});
    if size(dout.data_a.v) ~= size(din.data_a.v') || size(dout.data_y.v) ~= size(din.data_y.v') || size(dout.data_x.v) ~= size(din.data_x.v)
        error('Failed at 2D test with y-1D data.');
    end
    
    clear din;
    din.data_a.v = [1 2 3];
    din.data_x.v = [1 2 3];
    din.data_y.v = [];
    dout = qwtb_restore_twm_input_dims(din,'data_a',{'data_y';'data_x'});
    if size(dout.data_a.v) ~= size(din.data_a.v) || size(dout.data_y.v) ~= size(din.data_y.v) || size(dout.data_x.v) ~= size(din.data_x.v)
        error('Failed at 2D test with x-1D data.');
    end
    
    clear din;
    din.data_a.v = [1 2 3;4 5 6];
    din.data_x.v = [1 2 3];
    din.data_y.v = [1 2];
    dout = qwtb_restore_twm_input_dims(din,'data_a',{'data_y';'data_x'});
    if size(dout.data_a.v) ~= size(din.data_a.v) || size(dout.data_y.v) ~= size(din.data_y.v') || size(dout.data_x.v) ~= size(din.data_x.v)
        error('Failed at 2D test with 2D data.');
    end
    
    clear din;
    din.data_a.v = [1 2 3];
    din.data_b.v = [1 2 3];
    din.data_x.v = [];
    din.data_y.v = [1 2 3];
    dout = qwtb_restore_twm_input_dims(din,{'data_a';'data_b'},{'data_y';'data_x'});
    if size(dout.data_a.v) ~= size(din.data_a.v') || size(dout.data_b.v) ~= size(din.data_b.v') || size(dout.data_y.v) ~= size(din.data_y.v') || size(dout.data_x.v) ~= size(din.data_x.v)
        error('Failed at 2D test with multi 2D data.');
    end
    
    clear din;
    din.data_a.v = [1 2 3];
    din.data_a.u = [1 2 3];
    din.data_x.v = [];
    din.data_y.v = [1 2 3];
    dout = qwtb_restore_twm_input_dims(din,'data_a',{'data_y';'data_x'});
    if size(dout.data_a.u) ~= size(dout.data_a.v)
        error('Failed at 2D test with 2D data - uncertainty does not match data.');
    end
    
    ret = 1;
 
end 