function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm TWM-InpZ.
%
% See also qwtb
%
% Format input data --------------------------- %<<<1
    
    % Restore orientations of the input vectors to originals (before passing via QWTB)
    % This is critical for the correction data! 
    [datain,cfg] = qwtb_restore_twm_input_dims(datain,1);

    if cfg.y_is_diff
        % Input data 'y' is differential: if it is not allowed, put error message here
        error('Differential input data ''y'' not allowed!');     
    end
    
    if cfg.is_multi
        % Input data 'y' contains more than one record: if it is not allowed, put error message here
        error('Multiple input records in ''y'' not allowed!'); 
    end
    
    % try to obtain sampling rate from alternative input quantities [Hz]
    if isfield(datain, 'fs')
        fs = datain.fs.v;
    elseif isfield(datain, 'Ts')
        fs = 1/datain.Ts.v;
    else
        fs = 1/mean(diff(datain.t.v));
    end
    
    % decide harmonic estimation mode:
    if isfield(datain, 'mode') && strcmpi(datain.mode.v, 'PSFE')
        mode = 'PSFE';
    elseif isfield(datain, 'mode') && strcmpi(datain.mode.v, 'FPNLSF')
        mode = 'FPNLSF';
    elseif isfield(datain, 'mode') && strcmpi(datain.mode.v, 'WFFT')
        mode = 'WFFT';
    elseif isfield(datain, 'mode')
        error(sprintf('Harmonic estimation mode ''%s'' is unknown!'),datain.mode.v);
    else
        mode = 'PSFE'; % default
    end
    
    % initial frequency estimate mode:
    if isfield(datain, 'f_est') && isnumeric(datain.f_est.v) && ~isempty(datain.f_est.v)
        f_est = datain.f_est.v;
    elseif strcmpi(mode,'FPNLSF')
        error('Initial frequency estimte is required for FPNLSF mode!');
    else
        % default (for PSFE):
        f_est = NaN;
    end
           
    % default window:
    if ~isfield(datain,'window') || isempty(datain.window.v)
        datain.window.v = 'rect';        
    end
        
    % get equivalent circuit:
    [r,eclist] = z_to_equivalent();
    for k = 1:size(eclist,1)
        ecstr{k} = [eclist{k,[1,3]}];
    end
    if isfield(datain, 'equ')
        equ = datain.equ.v;
    else
        equ = 'CpRp';
    end
    ecid = find(strcmpi(ecstr,equ),1);
    if isempty(ecid)
        error(sprintf('Equivalent circuit ''%s'' not supported! Supported: %s.',equ,catcellcsv(ecstr,', ',';')));
    end
    
    
    % Rebuild TWM style correction tables:
    % This is not necessary but the TWM style tables are more comfortable to use then raw correction matrices
    tab = qwtb_restore_correction_tables(datain,cfg);
    
    
    % --------------------------------------------------------------------
    % Start of the algorithm
    % --------------------------------------------------------------------
    
    % apply timebase frequency correction:    
    % note: it is relative correction of timebase error, so apply inverse correction to measured f.  
    %fs = fs.*(1 + datain.adc_freq.v); 


    clear vcl; id = 0; % virt. chn. list     
    % -- build virtual channel (U):
    id = id + 1;
    vcl{id}.tran = 'shunt';
    vcl{id}.name = 'i';
    vcl{id}.y = datain.i.v;
    % -- build virtual channel (I):
    id = id + 1;        
    vcl{id}.tran = 'shunt';
    vcl{id}.name = 'u'; 
    vcl{id}.y = datain.u.v;
    
    % list of channel specific quantities:
    v_list = {'adc_bits','adc_nrng','adc_lsb','adc_jitter','adc_aper_corr','adc_jitter','adc_offset','adc_gain_f','adc_gain_a','adc_gain','adc_phi_f','adc_phi_a','adc_phi','adc_sfdr_f','adc_sfdr_a','adc_sfdr','adc_Yin_f','adc_Yin_Cp','adc_Yin_Gp','tr_gain_f','tr_gain_a','tr_gain','tr_phi_f','tr_phi_a','tr_phi','tr_Zlo_f','tr_Zlo_Rp','tr_Zlo_Cp','tr_Zca_f','tr_Zca_Ls','tr_Zca_Rs','tr_Yca_f','tr_Yca_Cp','tr_Yca_D','Zcb_f','Zcb_Ls','Zcb_Rs','Ycb_f','Ycb_Cp','Ycb_D'};        
        
    % corrections interpolation mode:
    % ###note: do not change, this works best for frequency characteristics
    i_mode = 'pchip';   
                
    % for each virtual channel:
    for k = 1:numel(vcl)
        % get channel:
        vc = vcl{k};   
     
        % build harmonic estimator parameters:
        cset = struct();
        cset.verbose = 0;
        cset.unc = 'none';
        cset.loc = 0.681;
        cset.checkinputs = 0;
        din = struct();
        din.fs.v = fs;
        din.f_est.v = f_est;
        if ~isnan(f_est)
            din.f_nom.v = f_est; % for WFFT mode only            
        end
        din.window = datain.window;
        din.adc_aper = datain.adc_aper;
        din.tr_type.v = 'shunt';        
        for v = 1:numel(v_list)            
            if isfield(datain,[vc.name '_' v_list{v}])
                din = setfield(din, v_list{v}, getfield(datain,[vc.name '_' v_list{v}]));
            end
        end
        din.y.v = vc.y;
        if strcmpi(mode,'PSFE')
            dout = qwtb('TWM-PSFE',din,cset);
        elseif strcmpi(mode,'FPNLSF')
            dout = qwtb('TWM-FPNLSF',din,cset);
        elseif strcmpi(mode,'WFFT')
            dout = qwtb('TWM-WFFT',din,cset);
            dout.phi = dout.ph; %###todo: remove when WFFT phase renamed to phi
        end
        if vc.name == 'u'
            
            % fundamental frequency:
            f0 = dout.f.v;
            w0 = 2*pi*f0;
            
            % fix I-U time shift:
            dout.phi.v = dout.phi.v - datain.time_shift.v*w0;
            
            % calculate complex ratio of analysed channel to reference channel:
            kA = vcl{1}.A.v/dout.A.v;
            kP = vcl{1}.phi.v - dout.phi.v;
            r = kA.*exp(j*kP);
            
            % reference impedance from user parameters:
            if isfield(datain,'Rp')
                Zr = 1/(1/datain.Rp.v + j*2*pi*f0*datain.Cp.v);
            elseif isfield(datain,'D')
                Zr = 1/(2*pi*f0*datain.Cp.v*(j + datain.D.v));
            else
                error('Missing reference impedance minor component Rp or D!');
            end
            
            % input impedance:
            Zi = Zr*r/(1 - r);
            
            % convert Zi to equivalent circuit:
            ec = z_to_equivalent(ecid-1,f0,Zi,Zi*0);
            
            % return stuff:
            dataout.f.v = f0;
            dataout.Uref.v = dout.A.v*(2^-0.5);
            
            dataout.Cp.v = imag(1./Zi)/w0;
            dataout.Gp.v = real(1./Zi);
            dataout.Rp.v = 1/dataout.Gp.v;
            
            dataout.mjr.v = ec.mjr;
            dataout.mjr.u = ec.umjr;
            dataout.mnr.v = ec.mnr;
            dataout.mnr.u = ec.umnr;
            
            dataout.mjr_name.v = char([eclist{ecid,1} ' [' eclist{ecid,2} ']']); 
            dataout.mnr_name.v = char([eclist{ecid,3} ' [' eclist{ecid,4} ']']);
            
            if isfield(dout, 'spec_f')
                dataout.spec_U.v = dout.spec_A.v;
            end         
                            
        elseif vc.name == 'i'
            % current channel (DUT)
            
            % return current as voltage assuming shunt has unity transfer
            dataout.Udut.v = dout.A.v*(2^-0.5);
            
            % return spectrum if available
            if isfield(dout, 'spec_f')
                dataout.spec_f.v = dout.spec_f.v;
                dataout.spec_I.v = dout.spec_A.v;
            end      
            
        end                            
        
       
        % store estimated harmonic:
        vc.f0  = dout.f;
        vc.A   = dout.A;
        vc.phi = dout.phi;
        
                
        vcl{k} = vc;
    end
    
     
    
    
    
    
    
    
    
          
        
           
    % --------------------------------------------------------------------
    % End of the demonstration algorithm.
    % --------------------------------------------------------------------


end % function

% convert correction tables 'pfx'_list{:} to list{:}
% i.e. get rid of prefix (usually 'u_' or 'i_')
% list - names of the correction tables
% pfx - prefix without '_' 
function [tout] = conv_vchn_tabs(tin,pfx,list)
    
    tout = struct();
    for t = 1:numel(list)    
        name = [pfx '_' list{t}];
        if isfield(tin,name)
            tout = setfield(tout, list{t}, getfield(tin,name));
        end
    end
    
end


% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
