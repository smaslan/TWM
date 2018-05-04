function [] = td_fft_filter_unc(fs, N, fft_size, f,gain,phi, i_mode, fhr,Yh)

    fhr = fhr(:)';
    Yh = Yh(:)'; 
        
    % generate time vector:
    t(:,1) = [0:N-1]/fs*2*pi;
    
    % DFT bin step [Hz]:
    bin_step = 0.5*fs/N;
    
    dA = [];
    dP = [];
    for v = 1:10
        
        % random phases:
        ph = rand(size(fhr))*2*pi;
        
        % randomize harmonics positions: 
        fh = fhr + (2*rand(size(fhr)) - 1)*bin_step;
        
        % generate signal:
        y = sum(bsxfun(@times,Yh,sin(bsxfun(@plus,bsxfun(@times,t,fh),ph))),2);
        
        % get used window parameters:
        %  get window:
        w = reshape(window_coeff('flattop_248D',N),[N 1]);
        %  get window scaling factor:
        w_gain = mean(w);
        %  get window rms:
        w_rms = mean(w.^2).^0.5;
        
        % estiamte DC level:
        dc = mean(y.*w)/w_gain;
        
        % remove DC offset:
        y = y - dc;
        
        % apply filter:
        [yf, first, last, fr,fg,fp] = td_fft_filter(y, fs, fft_size, f,gain,phi, i_mode);
        y = y(first:last);
        
        % samples count:
        M = numel(yf);
                
        % get used window parameters:
        %  get window:
        w = reshape(window_coeff('flattop_248D',M),[M 1]);
        %  get window scaling factor:
        w_gain = mean(w);
        %  get window rms:
        w_rms = mean(w.^2).^0.5;
                

        % apply window to both signals:
        y = [y yf].*w;
        
        % do FFT:
        U = fft(y)(1:round(M/2),:)/M*2/w_gain;
        fx = [0:size(U,1)-1]'/M*fs;
                        
        % component DFT bins:
        fid = round(fh/fs*M + 1);
        
        % extract harmonics from the spectra:
        Ur = U(:,1);
        Uf = U(:,2);
        
        % phase correction value:
        fphib = interp1(fr,fp,fx,'pchip','extrap');
        
        % amplitude correction value:
        fampb = interp1(fr,fg,fx,'pchip','extrap');
        
        % apply filter correction to the reference signal:
        Ur = Ur.*fampb.*exp(j*fphib);
        
        w_size = 10;
        
        % calcualte RMSs:
        Ur_rms = sum(0.5*abs(Uf(w_size:end)).^2)^0.5/w_rms*w_gain;
        Uf_rms = sum(0.5*abs(Ur(w_size:end)).^2)^0.5/w_rms*w_gain;
        
        % store deviations:
        dR(v) = Ur_rms./Uf_rms - 1;
        dA(:,v) = abs(Ur(fid))./abs(Uf(fid)) - 1;
        dP(:,v) = mod(angle(Ur(fid)) - angle(Uf(fid)) + pi,2*pi) - pi;
    end
    
    max(abs(dA),[],2)(1:3)
    max(abs(dP),[],2)(1:3)
    max(abs(dR),[],2)

end
