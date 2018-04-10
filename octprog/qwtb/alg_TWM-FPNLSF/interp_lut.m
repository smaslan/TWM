function [val] = interp_lut(lut,ax,res)
% Simple interpolator of multidim. lookup table (LUT) created by make_lut().
%
% Syntax:
%   interp_lut('test')
%     - run function self-test
%   interp_lut('test',lut,res)
%     - run self-test on existing LUT
%
%   unc = interp_lut(lut,ax)
%     - interpolate in LUT
%
% Inputs:
%   lut - lookup table created by the make_lut(), for details see the make_lut() doc.
%         Note the 'lut' may be also path to the MAT file with the store LUT.
%   res - results structure created by VAR lib (the same as used for generatio of LUT).
%   ax - axes values to interpolate, organized as one struct per axis:
%          ax.axis_name_1.val - value of axis 'axis_name_1'
%          ax.axis_name_2.val - value of axis 'axis_name_2'
%          ...
%        The 'axis_name_?' must match to the axes names in the LUT
%        and there must be one axis for each axis in the LUT!
%
% Returns:
%   val - struct of quantities from the LUT:
%           val.quantity_1.val - value of interpolated quantity 'quantity_1'
%           val.quantity_2.val - value of interpolated quantity 'quantity_2'
%           ...
%
% License:
% --------
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT        

    if ischar(lut) && strcmpi(lut,'test')
        % run self-test:
        
        if nargin < 3
            interp_lut_test();
        else
            interp_lut_test(ax,res);
        end
        val = [];        
        return
                
    elseif ischar(lut)    
        % LUT is possibly a file?
        % try to load it:
        if isOctave
            lut = load(lut,'-v7','lut');
        else
            lut = load(lut,'-mat','lut');
        end
        lut = lut.lut;
    end
    
    % get required axes:
    ax_names = fieldnames(lut.ax);
    A = numel(ax_names);
    
    % get existing quantites:
    qu_names = fieldnames(lut.qu);
    Q = numel(qu_names);

    
    % load first quantity record:
    qu = getfield(lut.qu, qu_names{1});    
    % get its axes sizes:
    adims = size(qu.data);
    
    
        
    % --- create interpolation weight-matrix ---
    
    % create interpolation weigth matrix:
    %  note: at this point same w. for all elements
    w = ones(adims);
    
    % for each axis of dependence:
    for a = 1:A
    
        % get axis name:
        a_name = ax_names{a};
    
        % get axis setup:
        cax = getfield(lut.ax,a_name);
        
        % get interpolation value for the axis:
        ai = getfield(ax,a_name);
        ai = ai.val;
        
        % get axis values:
        vax = cax.values(:);
    
        % limit interp. value to valid range:
        if ai < cax.min_ovr*min(vax)
            % required axis value too low:
            if strcmpi(cax.min_lim,'error')
                error(sprintf('Uncertainty estimator: Required interpolation value of axis ''%s'' is too low! Range of estimator data is not sufficient to estimate the uncertainty.',a_name));
            elseif strcmpi(cax.min_lim,'const')
                % limit interpolation value 'ai' to the nearest axis spot:
                ai = min(vax);
            else
                error(sprintf('Uncertainty estimator: Required interpolation value of axis ''%s'' is too low and the corrective action ''%s'' is not recognized! Range of estimator data is not sufficient to estimate the uncertainty.',a_name,cax.min_lim));
            end
        elseif ai > cax.max_ovr*max(vax)
            % required axis value too low:
            if strcmpi(cax.max_lim,'error')
                error(sprintf('Uncertainty estimator: Required interpolation value of axis ''%s'' is too high! Range of estimator data is not sufficient to estimate the uncertainty.',a_name));
            elseif strcmpi(cax.max_lim,'const')
                % limit interpolation value 'ai' to the nearest axis spot:
                ai = max(vax);
            else
                error(sprintf('Uncertainty estimator: Required interpolation value of axis ''%s'' is too high and the corrective action ''%s'' is not recognized! Range of estimator data is not sufficient to estimate the uncertainty.',a_name,cax.max_lim));
            end            
        end
        
        % select mode of interpolation:
        if strcmpi(cax.scale,'log')
            % log-scale interpolation:
            vax = log10(vax);
            ai = log10(ai);
        elseif ~strcmpi(cax.scale,'lin')
            error(sprintf('Uncertainty estimator: Interpolation mode of axis ''%s'' is unknown! Possibly incorrect lookup data.',a_name));
        end
        
        % create axis interpolation mask:
        wa = zeros(size(vax));
        
        % descending axis values?
        is_descend = any(diff(vax) < 0);
                
        if ai <= min(vax)
            % left limit:
            if is_descend
                wa(end) = 1;
            else
                wa(1) = 1;
            end                
        elseif ai >= max(vax)
            % right limit:
            if is_descend
                wa(1) = 1;
            else
                wa(end) = 1;
            end
        else
            % interpolate the axis:
            if is_descend
                % descending axis order:
                id = find(vax > ai,1,'last');               
                ws = (vax(id) - ai)/(vax(id) - vax(id+1));                
                wa(id+0) = 1 - ws;
                wa(id+1) = ws;
            else
                % ascending axis order:
                id = find(ai > vax,1,'last');               
                ws = (ai - vax(id))/(vax(id+1) - vax(id));                
                wa(id+0) = 1 - ws;
                wa(id+1) = ws;
            end                
        end
        
        % expand the axis interpolation mask to all dimensions:
        wdim = ones(size(adims));
        wdim(a) = adims(a);
        wa = reshape(wa,wdim);                                                 
        rdim = adims;
        rdim(a) = 1;
        wa = repmat(wa,rdim);
        
        % combine the mask with previous axes:
        w = bsxfun(@times,w,wa);            
        
    end
    
    % init result struct:
    val = struct();
        
    % --- interpolate the quantities ---
    for k = 1:Q
    
        % quantity name:
        q_name = qu_names{k};
        
        % load quantity record:
        qu = getfield(lut.qu, q_name);
        
        % decode data:
        if strcmpi(qu.data_mode,'log10u16')
            % decode log()+uint16 format:
            data = 10.^(double(qu.data)*qu.data_scale + qu.data_offset);
        elseif strcmpi(qu.data_mode,'real')
            % unscaled data:
            data = double(qu.data);
        else
            error(sprintf('Uncertainty estimator: Precalculated values of quantity ''%s'' stored in unknown format ''%s''! Possibly invalid lookup table content.',q_name,qu.data_mode));
        end        
        
        % convert quantity before interpolation:
        is_log = 0;
        if isfield(qu,'scale') && strcmpi(qu.scale,'log')
            is_log = 1;
            data = log10(data);
        elseif isfield(qu,'scale') && ~strcmpi(qu.scale,'lin')
            error(sprintf('Uncertainty estimator: Precalculated values of quantity ''%s'' cannot be coverted to ''%s'' - unknown operation (only ''lin'' or ''log'')! Possibly invalid lookup table content.',q_name,qu.scale));
        end
        
        % interplate using the weight mask:
        data = data.*w;
        data = sum(data(:))/sum(w(:));
        
        % convert back to state before interp.:
        if is_log
            data = 10^data;
        end
        
        % multiply the data by mult-factor:
        if isfield(qu,'mult')
            data = data*qu.mult;
        end
        
        % store interpolated quantity:
        val = setfield(val, q_name, struct('val',data));        
    
    end


end


%%
%% Return: true if the environment is Octave.
%%
function retval = isOctave()
  persistent cacheval;  % speeds up repeated calls

  if isempty (cacheval)
    cacheval = (exist ('OCTAVE_VERSION', 'builtin') > 0);
  end

  retval = cacheval;
end


%-------------------------------------------------------------------------------
% HERE STARTS SELF-TEST
%-------------------------------------------------------------------------------
function [] = interp_lut_test(lut,res)

    if nargin >= 2
        % --- TEST ON USER LUT ---
        
        % results count:
        R = numel(res);
        
        % get quantity names:
        qu_names = fieldnames(lut.qu);
        Q = numel(qu_names);       
        
        % get axes names:   
        ax_names = fieldnames(lut.ax);
        A = numel(ax_names);
        
        % generate VAR lib control struct:       
        vr.names = ax_names;
        for k = 1:A
            axrec = getfield(lut.ax,ax_names{k});
            vr.par_n(k) = numel(axrec.values);
        end    
    
    else
        % --- TEST ON GENERATED LUT ---
    
        % generate some axes:
        p.aa = [1 2 3 4];
        p.bb = [1 2 3];
        p.cc = [0.1 0.2];
        p.dd = [0.5 0.7 0.9];
        p.ee = [1 2 3 4 5];
        
        % generate VAR lib control struct:       
        vr.names = fieldnames(p);
        vr.par_n = cellfun(@numel,struct2cell(p));
        
        % generate some data:
        for k = 1:prod(vr.par_n)
            q1 = rand(1)*1e-3 + 1e-9;
            q2 = rand(1)*1e-3 + 1e-9;
            res{k}.q1 = q1;
            res{k}.q2 = q2;        
        end
        R = numel(res);
        
        % generate some axis configurations:
        ax = struct();
        ax.aa.min_lim = 'error';
        ax.aa.max_lim = 'const';
        ax.aa.min_ovr = 0.99;
        ax.aa.max_ovr = 1.05;
        ax.aa.scale = 'log';    
        ax.bb.min_lim = 'error';
        ax.bb.max_lim = 'const';
        ax.bb.min_ovr = 0.99;
        ax.bb.max_ovr = 1.05;
        ax.bb.scale = 'lin';    
        ax.cc.min_lim = 'error';
        ax.cc.max_lim = 'const';
        ax.cc.min_ovr = 0.99;
        ax.cc.max_ovr = 1.05;
        ax.cc.scale = 'log';    
        ax.dd.min_lim = 'error';
        ax.dd.max_lim = 'const';
        ax.dd.min_ovr = 0.99;
        ax.dd.max_ovr = 1.05;
        ax.dd.scale = 'lin';
        ax.ee.min_lim = 'error';
        ax.ee.max_lim = 'const';
        ax.ee.min_ovr = 0.99;
        ax.ee.max_ovr = 1.05;
        ax.ee.scale = 'lin';
        
        % generate quantity configurations:
        qu = struct();    
        qu.q1.scale = 'log';
        qu.q2.scale = 'lin';
        qu.q1.mult = 1.0;
        qu.q2.mult = 1.0;
        qu_names = fieldnames(qu);
        Q = numel(qu_names);
        
        % build LUT:
        lut = make_lut(res,p,vr,ax,qu);
    
    end
    
    % number of tests:
    T = 1000;
    
    % maximum relative deviation of quantity:
    max_eps = 0.001;
    
    
    % -- random spot testing loop:
    tid = tic();
    devs = zeros(size(qu_names));
    for t = 1:T
        
        % select random spot from results-data vector:
        rid = round(rand(1)*(R-1));
        rid_tmp = rid;
        % decompose the random selection to axes and build interpolator values 'ax':
        ax = struct();
        for a = numel(vr.par_n):-1:1
            sz = prod(vr.par_n(1:a-1));
            axi = floor(rid_tmp/sz);
            rid_tmp = rem(rid_tmp,sz);            
            axv = getfield(lut.ax,vr.names{a});
            ax = setfield(ax,vr.names{a},struct('val',axv.values(axi+1)));
        end
        
        % interpolate LUT:
        val = interp_lut(lut,ax);
        
        % check deviation of the intrepolated data from originals:
        for k = 1:Q
            int = getfield(val,qu_names{k});            
            ref = getfield(res{rid+1},qu_names{k});
            devs(k) = max(devs(k),abs((int.val/ref-1)));        
        end
        
        if toc(tid) > 1
            tid = tic();        
            fprintf(' testing %6d of %6d          \r',t,T);
        end
                                    
    end
    fprintf(' testing %6d of %6d          \n',t,T);
    
    % print found deviations:
    for k = 1:Q
        fprintf(' max. dev of %s = %.3g\n',qu_names{k},devs(k));
    end
    
    % check the limits:
    assert(max(devs) < max_eps, 'LUT interpolator failed!');    
        
end