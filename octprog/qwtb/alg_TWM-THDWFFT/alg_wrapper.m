function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm THDWFFT.
%
% See also qwtb

% Format input data --------------------------- %<<<1
    
    
    % Restore orientations of the input vectors to originals (before passing via QWTB)
    % This is critical for the correction data! 
    [datain,cfg] = qwtb_restore_twm_input_dims(datain,1);
    
    
        
    % obtain sampling rate [Hz]
    if isfield(datain, 'fs')
        fs = datain.fs.v;
    elseif isfield(datain, 'Ts')
        fs = 1/datain.Ts.v;
        if calcset.verbose
            disp('QWTB: TWM-THDWFFT wrapper: sampling frequency was calculated from sampling time')
        end
    else
        fs = 1/mean(diff(datain.t.v));
        if calcset.verbose
            disp('QWTB: TWM-THDWFFT wrapper: sampling frequency was calculated from time series')
        end
    end


    if cfg.y_is_diff
        % Input data 'y' is differential: if it is not allowed, put error message here
        error('Differential input data ''y'' not allowed!');     
    end
    
    % Rebuild TWM style correction tables:
    % note: for comfortable work on correction matrices
    c_tabs = qwtb_restore_correction_tables(datain,cfg);  


    % obtain wave data
    y = datain.y.v;
    
    % --- default setup of the algorithm ---
    % verbose level
    s.verbose = calcset.verbose*2;
    % fundamental frequency setup [Hz], set 0 for autodetection
    s.f_fund = 0;
    % fundamental frequency autodetection, 0 - zero-cross (fast, usable for high signal periods count), 1 - fitting (slow, accurate), 2 - PSFE
    s.f_fund_fit = 2;
    % limit sample count for f0 fitting (0: none)
    s.f_fund_fit_limit = 0;
    % moving average filter for zero-cross method (usually 20), ZC is used also for initial guess for a fitting algorithm! 
    s.f_fund_zc_filter = 20;
    % maximum harmonics count to analyze [-]
    s.h_num = 10;
    % maximum harmonic frequnecy [Hz]
    s.h_f_max = inf;
    % maximum harmonic freq. deviation from ideal position [bin] 
    s.f_dev_max = 2;
    % Monte Carlo uncertainty evaluation: cycles count
    s.mc_cycles = 10000;
    % Monte Carlo uncertainty evaluation: coverage interval
    s.mc_cover = calcset.loc;
    % return spectrum?
    s.save_spec = 1;
    
    % obtain initial fundamental frequency guess [Hz]
    if isfield(datain, 'f0')
        s.f_fund = datain.f0.v;
    end    
    
    % obtain initial fundamental frequency guess method
    if isfield(datain, 'f0_mode')
      
        if any(strcmpi(datain.f0_mode.v,{'zc';'zerocross'}))
            s.f_fund_fit = 0;
        elseif strcmpi(datain.f0_mode.v,'fit')
            s.f_fund_fit = 1;
        elseif strcmpi(datain.f0_mode.v,'psfe')
            s.f_fund_fit = 2;
        else
            error(sprintf('QWTB: TWM-THDWFFT wrapper: initial guess mode ''%s'' of the fundamental frequency is not recognized! Only ''zerocross'', ''fit'' or ''PSFE'' are recognized.',datain.f0_mode.v));
        end
    end
    
    % limit sample count for f0 fitting?        
    if isfield(datain, 'fit_limit')
        s.f_fund_fit_limit = datain.fit_limit.v;
    end
    
    % obtain harmonics count to analyze
    if isfield(datain, 'H')
        s.h_num = datain.H.v;
    end
    
    % obtain bandwidth to analyze
    if isfield(datain, 'band')
        s.h_f_max = datain.band.v;
    end
    
    % enable scalloping error correction?
    if isfield(datain, 'scallop_fix') && datain.scallop_fix.v
        % yaha
        s.f_dev_max = -1;
    end
    
    % prepare corrections data structure (copy of input parameters without data vector - is too large)
    cin = rmfield(datain,'y');
        
        
    % --- evaluate THD ---
    r = thd_wfft(y,fs,s,cin,c_tabs,cfg);
        
    % optional result plot:
    if isfield(datain, 'plot') && ((isnumeric(datain.plot.v) && datain.plot.v) || (ischar(datain.plot.v) && any(strcmpi(datain.plot.v,{'on';'true';'enabled'}))))
        thd_plot_spectrum(r,0);
    end

    
    % --- return outputs ---
    
    % analyzed harmonics count:
    dataout.H.v = r.H;
    
    % calculated THD (fundamental referenced):
    dataout.thd.v = r.k1_comp;
    % uncertainty is maximum from left and right tolerance (asymmetric not supported by QWTB)
    dataout.thd.u = max(abs([r.k1_comp_a, r.k1_comp_b] - r.k1_comp));
    
    % calculated THD (rms referenced):
    dataout.thd2.v = r.k2_comp;
    % uncertainty is maximum from left and right tolerance (asymmetric not supported by QWTB)
    dataout.thd2.u = max(abs([r.k2_comp_a, r.k2_comp_b] - r.k2_comp));
    
    % calculated THD+N (fundamental referenced):
    dataout.thdn.v = r.k3_comp;
    % uncertainty is maximum from left and right tolerance (asymmetric not supported by QWTB)
    dataout.thdn.u = 0;%max(r.k3_comp - r.k3_comp_a, r.k3_comp_b - r.k3_comp);
    
    % calculated THD+N (rms referenced):
    dataout.thdn2.v = r.k4_comp;
    % uncertainty is maximum from left and right tolerance (asymmetric not supported by QWTB)
    dataout.thdn2.u = 0;%max(r.k4_comp - r.k4_comp_a, r.k4_comp_b - r.k4_comp);
    
    % return rms noise estimate:
    dataout.noise.v = r.noise;
    dataout.noise.u = 0;
    
    % return rms noise bandwidth:
    dataout.noise_bw.v = r.noise_bw;
    dataout.noise_bw.u = 0;
    
    
    % harmonic frequencies:
    dataout.f.v = r.f_lst;
    
    % harmonic amplitudes:
    dataout.h.v = r.a_comp_lst;
    % uncertainty is maximum from left and right tolerance (asymmetric not supported by QWTB)
    dataout.h.u = max(r.a_comp_lst - r.a_comp_lst_a, r.a_comp_lst_b - r.a_comp_lst);
    
    % return fundamental
    if ~isempty(r.f_lst)
        dataout.f0.v = r.f_lst(1);
        dataout.f0.u = 0;
        dataout.h0.v = dataout.h.v(1);
        dataout.h0.u = dataout.h.u(1);
        dataout.hrms.v = sum(0.5*dataout.h.v.^2)^0.5;
        dataout.hrms.u = 0;
    endif
    
    % return full spectrum:
    if s.save_spec
        dataout.spec_f.v = r.f(:);
        dataout.spec_A.v = r.sig(:);
    else
        dataout.spec_f.v = [];
        dataout.spec_A.v = [];
    end
        
    % uncorrected calculated THD (fundamental referenced):
    dataout.thd_raw.v = r.k1;
    % uncertainty is maximum from left and right tolerance (asymmetric not supported by QWTB)
    dataout.thd_raw.u = max(r.k1 - r.k1_a, r.k1_b - r.k1);
    
    % uncorrected calculated THD (rms referenced):
    dataout.thd2_raw.v = r.k2;
    % uncertainty is maximum from left and right tolerance (asymmetric not supported by QWTB)
    dataout.thd2_raw.u = max(r.k2 - r.k2_a, r.k2_b - r.k2);
    
    % uncorrected harmonic amplitudes:
    dataout.h_raw.v = r.a_lst;
    % uncertainty is maximum from left and right tolerance (asymmetric not supported by QWTB)
    dataout.h_raw.u = max(r.a_lst - r.a_lst_a, r.a_lst_b - r.a_lst);
    
    % SFDR estimate
    dataout.SFDR.v = r.sfdr;
    dataout.SFDR.u = 0*r.sfdr;

    
    if strcmpi(calcset.unc,'none')
        % none uncertainty - clear uncertainties:
        names = fieldnames(dataout);
        for k = 1:numel(names)
            qu = getfield(dataout,names{k});
            if isfield(qu,'u')
                qu.u = 0*qu.v;
                dataout = setfield(dataout,names{k},qu);
            end
        end
    end

end % function

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
