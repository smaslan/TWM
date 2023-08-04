function dataout = alg_wrapper(datain, calcset)
% Part of QWTB. Wrapper script for algorithm TWM-CLKSKIP.
%
% See also qwtb
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2023, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
%
% Format input data --------------------------- %<<<1

    is_wfft_local = 1;
    
    % Restore orientations of the input vectors to originals (before passing via QWTB)
    % This is critical for the correction data! 
    [datain,cfg] = qwtb_restore_twm_input_dims(datain,1);

    if cfg.u_is_diff || cfg.i_is_diff
        error('Differential transducer input not supported!');     
    end
    if cfg.is_multi_records
        error('Multiple input records in not supported!'); 
    end
    
    % try to obtain sampling rate from alternative input quantities [Hz]
    if isfield(datain, 'fs')
        fs = datain.fs.v;
    elseif isfield(datain, 'Ts')
        fs = 1/datain.Ts.v;
    else
        fs = 1/mean(diff(datain.t.v));
    end    
        
    % initial frequency estimate mode
    if isfield(datain, 'f0') && isnumeric(datain.f0.v) && ~isempty(datain.f0.v)
        f0 = datain.f0.v;
    else
        % default (for PSFE):
        f0 = NaN;
    end
    
    % default time skip value
    if ~isfield(datain,'ref_delta_t') || isempty(datain.ref_delta_t.v)
        datain.ref_delta_t.v = 100e-9;        
    end
    ref_delta_t = datain.ref_delta_t.v;
    
    % default time skip value tolerance
    if ~isfield(datain,'tol_delta_t') || isempty(datain.tol_delta_t.v)
        datain.tol_delta_t.v = 10e-9;        
    end
    tol_delta_t = datain.tol_delta_t.v;
    
    % default plot mode
    if ~isfield(datain,'plot') || isempty(datain.plot.v)
        datain.plot.v = 0;        
    end
       
    
    % --------------------------------------------------------------------
    % Start of the algorithm
    % --------------------------------------------------------------------
    
    
    % expected maximum event width [s]
    Tev = 0.1;
    
    N = numel(datain.y.v);
    
    % look for f0 frequency
    if isnan(f0)
        M = 50;
        Nw = min(floor(N/M),100e3);
        f_list = [];
        for k = 1:M
            w_ofs = (k-1)*Nw + 1;
            yw = datain.y.v(w_ofs:w_ofs+Nw-1);
            [fa A ph] = PSFE(yw,1/fs);
            f_list(end+1,1) = fa;
        end
        f0 = median(f_list);
    end
    w0 = 2*pi*f0; 
    
    % samples per period (coherent)
    Np = 1*round(fs/f0);
    
    % split per periods
    N = floor(N/Np)*Np;
    M = N/Np;
    yp = reshape(datain.y.v(1:N),[Np M]);
    
    % do FFT per periods
    fid0 = round(f0/(fs/Np)+1);
    %Up(:,1) = fft(yp)(fid0,:)/Np*2;
    Up = fft(yp);
    Up = Up(fid0,:).'/Np*2;
    
    % get phase and unwrap [rad]
    phi_p = unwrap(angle(Up));
    tp(:,1) = [0:M-1]*Np/fs;
    
    % show phase development
    % figure;
    % plot(tp, phi_p)
    % xlabel('time [s]')
    % ylabel('phi [rad]')
    
    % get rid of mean phase drift
    pp = polyfit(tp,phi_p,4);
    phi_p_fit = polyval(pp, tp);
    phi_p_rel = phi_p - phi_p_fit;
    
    % hold on;
    % plot(tp, phi_p_fit, 'r');
    % hold off;
    
    if datain.plot.v
        figure;
        plot(tp, phi_p_rel*1e6)
        xlabel('time [s]')
        ylabel('phi [urad]')
        title('Phase development with suppressed drift');
        grid on;
        box on;
    end
    
    % filter phase jumps 
    phi_p_diff = diff(phi_p);
    phi_p_M = numel(phi_p_diff);
    Nev = round(Tev/(Np/fs));
    Nev_step = max(round(0.05*Nev),1);
    ev_list = [];
    ev_list_t = [];
    for ev_ofs = 1:Nev_step:phi_p_M-Nev     
        ev_list(end+1,1) = sum(phi_p_diff(ev_ofs:ev_ofs+Nev-1));   
        ev_list_t(end+1,1) = tp(ev_ofs);
    end
    ev_list_t = ev_list_t + 0.5*Nev*Np/fs;
    
    % figure;
    % plot(0.5*(tp(1:end-1) + tp(2:end)), diff(phi_p))
    % xlabel('time [s]')
    % ylabel('phi [rad]')
    
    if datain.plot.v
        figure;
        plot(ev_list_t, (ev_list - median(ev_list))*1e6);
        xlabel('time [s]')
        ylabel('\Delta{}phi [urad]')
        title('Phase jumps (unfiltered)');
        grid on;
        box on;
    end
    
    % look for most likely skip position
    [v,id] = max(ev_list);
    skip_ids = max(id-Nev*2,1):min(id+Nev*2,numel(ev_list));
    skip_data = ev_list(skip_ids);
    skip_time = ev_list_t(skip_ids);
    
    % check amplitude of the skip
    ev_tresh = 0.5*(max(skip_data) + min(skip_data));
    ev_peak = median(skip_data(skip_data >= ev_tresh));
    ev_base = median(skip_data(skip_data < ev_tresh));
    delta_phi = ev_peak - ev_base;
    delta_t = delta_phi/w0;
    skip_data = skip_data - ev_base;
    
    % skip detected?
    is_skip = abs(delta_t - ref_delta_t) < tol_delta_t; 
    
    % crude filter to find center of event
    N_filt = round(0.05/(diff(skip_time(1:2)))/2)*2+1;
    skip_data_filt = conv(skip_data,repmat(1/N_filt,[N_filt 1]),'valid');
    skip_time_filt = skip_time((N_filt-1)/2+1:end-(N_filt-1)/2);
    [v,ev_id] = max(skip_data_filt);
    ev_time = skip_time_filt(ev_id);
    ev_mag = ev_peak - ev_base; 
    
    % show detected skip
    if datain.plot.v
        figure;
        plot(skip_time,skip_data/w0*1e9)
        hold on;
        plot(skip_time_filt,skip_data_filt/w0*1e9,'r')
        plot(skip_time([1,end]),(repmat((ref_delta_t + tol_delta_t),[2 1]))*1e9,'k--');
        plot(skip_time([1,end]),(repmat((ref_delta_t - tol_delta_t),[2 1]))*1e9,'k--');
        if is_skip
            plot(ev_time,ev_mag/w0*1e9,'ro')
        end
        hold off;
        xlabel('time [s]')
        ylabel('\Delta{}t [ns]')
        legend('Raw time skips','Filtered time skips','Expected skip limit+','Expected skip limit-','Time skip event');
        title('Detected and extracted time skip (if any)');
        grid on;
        box on;
    end
    
    % return result
    dataout.f0.v = f0;
    if is_skip
        dataout.t_skip.v = ev_time;
        dataout.delta_t.v = delta_t;
        dataout.delta_phi.v = delta_phi;        
        dataout.result.v = sprintf('Time skip found in t = %.2fs, dT = %.3fns (dPhi = %.1furad @ f = %.3fkHz)', ev_time, 1e9*delta_t, 1e6*delta_phi, 0.001*f0);
    else
        dataout.t_skip.v = NaN;
        dataout.delta_t.v = NaN;
        dataout.delta_phi.v = NaN;
        dataout.result.v = sprintf('No clear sign of time skip detected');
    end
        
           
    % --------------------------------------------------------------------
    % End of the algorithm.
    % --------------------------------------------------------------------


end % function


% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
