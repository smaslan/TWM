function [uAmp,uPhi] = td_fft_filter_unc(fs, N, fft_size, f,gain,phi, i_mode, fhr,Yh)
% Simple uncertainty estimator of the td_fft_filter() function (FFT filter).
% It generates N harmonics at frequencies 'fhr' with amplitudes 'Yh' and applies
% filter 'f', 'gain' and 'phi'. It calculates deviation of the harmonics in the 
% FFT filtered signal from the actually generated harmonics. The test is repeated
% 10 times with randomized phases but it should be enough to find worst case errors.

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
        Ur = U(fid,1);
        Uf = U(fid,2);
        
        % phase correction value:
        fphib = interp1(fr,fp,fh(:),'pchip','extrap');
        
        % amplitude correction value:
        fampb = interp1(fr,fg,fh(:),'pchip','extrap');
        
        % window scalloping error correction:
        kWg = Yh(:)./abs(Ur);
        kWp = mod(ph(:) - angle(Ur) + pi,2*pi) - pi;           
        
        % reference harmonics values:
        Ur = Yh(:).*fampb;
        phr = ph(:) + fphib;
        
        % calculate RMS level:
        %W = mean(w.^2)^-0.5;
        %Uf_rms = W*mean((w.*yf).^2).^0.5;
        
        % calculate desired RMS level:
        %Ur_rms = sum(0.5*Ur.^2)^0.5; 
                
        %dR(v) = Ur_rms./Uf_rms - 1;       
        dA(:,v) = kWg.*abs(Uf)./Ur - 1;
        dP(:,v) = mod(angle(Uf) + kWp - phr + pi,2*pi) - pi;

    end
    
    % estimate max error:
    %  note: expanded by empirical coeficient... may be improved
    uAmp = 2*Yh(:).*max(abs(dA),[],2)/3^0.5;
    uPhi = 2*max(abs(dP),[],2)/3^0.5;
    %uRms =max(abs(dR),[],2)/3^0.5;
    
end
