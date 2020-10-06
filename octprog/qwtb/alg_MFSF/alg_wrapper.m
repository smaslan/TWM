function dataout = alg_wrapper(datain, calcset) %<<<1
% Part of QWTB. Wrapper script for algorithm MFSF.
%
% See also qwtb

% Format input data --------------------------- %<<<1
% MFSF definition is:
% function [f0, A, phase, THD] = MFSF(Record, Ts, Har,ig,RelErr)
% INPUT ARGUMENTS
%   Record  : sampled input signal
%   Ts      : sampling time (in s)
%   Har     : index signal harmonics to be estimated
%   ig      : 0 - FFT max bin, >0 initial frequency estimate
%   RelErr  : cost function treshold

    if isfield(datain, 'Ts')
        Ts = datain.Ts.v;
    elseif isfield(datain, 'fs')
        Ts = 1/datain.fs.v;
        if calcset.verbose
            disp('QWTB: MFSF wrapper: sampling time was calculated from sampling frequency')
        end
    else
        Ts = mean(diff(datain.t.v));
        if calcset.verbose
            disp('QWTB: MFSF wrapper: sampling time was calculated from time series')
        end
    end

    % create default parameters for uncertainty calculator if some of them is missing:
    if ~isfield(datain,'sfdr')
        datain.sfdr.v = 180;
    end
    if ~isfield(datain,'jitter')
        datain.jitter.v = 0;
    end
    if ~isfield(datain,'adcres')
        datain.adcres.v = 1e-16;
    end

    if isfield(datain,'fest') && ((isnumeric(datain.fest.v) && datain.fest.v < 0) || ischar(datain.fest.v) && strcmpi(datain.fest.v,'ipdft'))
        datain.fest.v = -1;
        % Get initial estimate by the ipdft_spect() method
        %  ###note: This is added from older version of MFSF algorithm, because the fast uncertainty estimator
        %           was made for this method of initial guess only so it won't be consistent without this option. 
        
        % get initial estimate by ipdft_spect():
        fest = ipdft_spect(fft(datain.y.v),1/Ts);
    elseif isfield(datain,'fest') && ischar(datain.fest.v) && strcmpi(datain.fest.v,'psfe')
        datain.fest.v = -1;
        % Get initial estimate by the PSFE method
        %  ###note: This was added because PSFE can sometimes detect fundamental better even for heavily distorted signals
        
        % get initial estimate by external call of QWTB PSFE:
        din.y.v = datain.y.v;
        din.Ts.v = Ts;
        cset = calcset;
        cset.unc = 'none';
        cset.verbose = 0;
        dout = qwtb('PSFE',din,cset);
        fest = dout.f.v;        
    elseif isfield(datain,'fest') && ischar(datain.fest.v)
        error(sprintf('QWTB: MFSF wrapper: initial estimate mode ''%s'' not recognised!',datain.fest.v));        
    else
        % standard mode (user estimate or default auto method of MFSF (peak FFT bin)):
        fest = datain.fest.v;
    end
    
    if ~isfield(datain,'CFT')
        % ###note: this is default value from MFSF. It is assigned here so it can
        %          be used later in the wrapper even if user did not assigned it 
        datain.CFT.v = 3.5e-11;
    end

    % Call algorithm ---------------------------  %<<<1
    % function [f0, A, phase, THD] = MFSF(Record, Ts, Har,ig,RelErr)
    [f0, A, phase, O, THD] = MFSF(datain.y.v, Ts, datain.ExpComp.v, fest, datain.CFT.v);
        
    
    % frequencies of fitted components:
    f_har = f0*datain.ExpComp.v;
    
        
    
    
    % --------------------------------------------------------------------------------------------
    % HERE STARTS THE UNCERTAINTY FUN PART
    % -------------------------------------------------------------------------------------------- 
    % Note: Following code is not part of the original MFSF algorithm. 
    %       It was developed in scope of TracePQM EMPIR: http://tracepqm.cmi.cz/     
    % --------------------------------------------------------------------------------------------
    if ~strcmpi(calcset.unc,'none')
        % --- Some uncertainty mode enabled ---
        
        % -- perform spectrum analysis:
        % note: we need this in order to find out harmonics/inter-harmonics in the signal
        % do windowed FFT:
        din.Ts.v = Ts;
        din.y.v = datain.y.v;
        din.window.v = 'flattop_116D'; % narrow, but flat window
        cset.verbose = 0; % stfu        
        dout = qwtb('SP-WFFT',din,cset);
        qwtb('MFSF','addpath'); % ###todo: fix qwtb so it does not loose the path every time another alg. is called
        fh  = dout.f.v; % freq. vector of the DFT bins
        amp = dout.A.v; % amplitude vector of the DFT bins
        M = numel(fh); % DFT bins count
        % get window parameters (needed later):
        w_gain = mean(dout.w.v);        
        w_rms = mean(dout.w.v.^2).^0.5;
        
        
        % returning of spectrum:
        dataout.spec_f.v = fh;
        dataout.spec_A.v = amp;
        
               
        
        % DFT bin step [Hz]:
        fft_step = fh(2) - fh(1);
                        
        % window half-width in DFT bins (pessimistic value):
        w_size = 8;
        
        
        % get fundamental component's DFT bin:
        [v,f0id] = min(abs(f0 - fh));
        
        % fundamental amplitude:
        sig_amp = amp(f0id);
        
        % mask DC components and Nuqyist in the spectrum:
        dc_msk = [max(w_size,floor(0.1*f0id)):numel(fh)-1];
                
        
        % -- 1) remove fitted components:
        
        % mask all fitted components in the spectrum:
        msk = dc_msk;        
        c_list = [];
        for k = 1:numel(f_har)
            [v,fid] = min(abs(f_har(k) - fh));
            if isempty(fid)
                continue;
            end
            % add component to the list:
            c_list(end+1) = fid;            
            % remove harmonic bins from remaining list:
            h_bins = [(fid - w_size):(fid + w_size)];
            msk = setdiff(msk,h_bins);                        
        end
        % at this point the spectrum should not contain the fitted components...
        
        
        
        % -- 2) identify and remove all higher harmonics of f0:
        
        % min. amplitude of harmonic relative to fundamental: 
        h_tresh = 2e-5;
        
        % all possible harmonics of f0:    
        fhx = [f0:f0:(fh(end)-1.5*fft_step)];
        
        % remove possible harmonics that matches the fitted components: 
        for f = 1:numel(f_har)
            fid = find(abs(f_har(f) - fhx) <= 0.5*fft_step);            
            fhx = setdiff(fhx,fhx(fid));            
        end            
        
        % mask all harmonics in the spectrum:             
        h_list = [];
        h_msk = msk;
        for k = 1:numel(fhx)
            [v,fid] = min(abs(fhx(k) - fh));
            if isempty(fid)
                continue;
            end
            if (amp(fid)/sig_amp) > h_tresh 
                h_list(end+1) = fid; % add the found harmonic to buffer
                % remove harmonic's bins from remaining list:
                h_bins = [(fid - w_size):(fid + w_size)];                
                h_msk = setdiff(h_msk,h_bins);
            end            
        end
        % at this point, the spectrum contains no fitted components and no harmonics of f0...          
        
        
        % -- 3) identify and remove remaining (interharmonic) components:        
         
        % min relative level to fundamental
        ih_tresh = 2e-5;
        
        % max. analyzed components:
        ih_max = 100;
        
        % identify harmonic/interharmonic components:
        ih_list = [];
        ih_msk = h_msk;
        for k = 1:ih_max
            
            % look for highest harmonic:
            [v,fid] = max(amp(ih_msk));        
            if ~fid
                % no more components
                break;                
            end
            
            % found component DFT bin id:
            hid = ih_msk(fid);    
            
            if (amp(hid)/sig_amp) > ih_tresh            
                % add to found inter-harmonics list:
                ih_list(end+1) = hid;
                
                % list of DFT bins occupied by the component:
                h_bins = [(hid - w_size):(hid + w_size)];
                
                % remove harmonic bins from remaining list:
                ih_msk = setdiff(ih_msk,h_bins);                
            end        
        end        
        % at this point spectrum should contain only noise...
        
        
                
                
        % -- 4) estimate the residual RMS noise:
        
        % rms estimate of a whole signal excluding DC and fitted components:
        noise_rms = interp1(fh(msk),amp(msk),fh,'nearest','extrap'); % reconstruct spectrum in full bw
        noise_rms = sum(0.5*noise_rms.^2)^0.5/w_rms*w_gain; % calculte RMS
        % rms of extracted components:        
        h_rms  = sum(0.5*mean_spect_amp(amp,h_list).^2)^0.5; % harmonics
        ih_rms = sum(0.5*mean_spect_amp(amp,ih_list).^2)^0.5; % interharmonics
        % total rms of noise noise:
        noise_rms = (noise_rms^2 - h_rms^2 - ih_rms^2)^0.5;
        if ~isreal(noise_rms)
            if calcset.verbose
                disp('QWTB: MFSF wrapper: estimate of signal noise for uncertainty calculation is too low, truncating it to zero.');
            end
            % the noise is too low for some reason...
            noise_rms = 0;
        end           
        
        
        % optional debug plots:
        if isfield(calcset,'dbg_plots') && calcset.dbg_plots    
            figure
            loglog(fh,amp)        
            hold on;
            loglog(fh(msk),amp(msk),'r');                
            loglog(fh(h_msk),amp(h_msk),'m');
            loglog(fh(ih_msk),amp(ih_msk),'k');
            hold off;
            xlabel('f [Hz]');
            ylabel('Amplitude');
            title('Spectrum analysis')
            legend('full','no fitted','no harmonics','noise');            
        end
                        
        
        
        if strcmpi(calcset.unc,'mcm')
            % --- Monte Carlo mode enabled ---
            
            % store some basic simulation parameters: 
            sim.fs = 1/Ts;
            sim.N = numel(datain.y.v);
            sim.ih_f_unc = fft_step;
            % relative uncertainty of amplitude estimation from spectrum:            
            sim.h_amp_unc = 0.01;
            % estimate of relative uncertainty of f0:
            %  note: this is very crude estimate and the randomization is used to prevent
            %        accidental lock-up in some local mininum of uncertainty
            sim.f0_unc = 0.001;
            % correction data SFDR (unitless):
            sim.sfdr = 10^(-datain.sfdr.v/20);
            % ADC resolution:
            sim.lsb = datain.adcres.v;
            % rms jitter [s]:
            sim.jitter = datain.jitter.v;            
            
            % calculation options of MFSF:
            sim.mfsf_ig = datain.fest.v;
            sim.mfsf_cft = datain.CFT.v;
            
            
            % simulated fitted components:
            sim.f0 = f0;
            sim.A = A;
            sim.ph = phase;
            sim.har = f_har/f0; % relative frequencies
            % DC offset: 
            sim.ofs = amp(1); % ###todo: add actual DC estimate?
            sim.ofs_unc = 0.1*max(A); % some estimate of the DC offset uncertainty
            

            % -- prepare list of simulated harmonics:
            
            % maximum additional harmonics count to simulate:
            h_max = 10;                      
            
            % find dominant harmonics left:
            [v,id] = sort(amp(h_list),'descend');
            if ~isempty(id)
                % select limited count:
                tmp_list = h_list(id(1:min(end,h_max)));
                
                % store the harmonics to the simulator list:                
                sim.h_id = round(fh(tmp_list)/f0);
                sim.h_amp = amp(tmp_list);
                                                
                % remove used harmonics from the working list:
                h_list = setdiff(h_list,tmp_list);
            else
                % no harmonics found:
                sim.h_id = [];
                sim.h_amp = [];                
            end
            
            
            % -- prepare list of simulated residual components:
            
            % merge harmonincs and interharmonics:
            c_list = [h_list(:);ih_list(:)]';
            
            % max components count:
            c_max = 10;
            
            % find dominant harmonics left:
            [v,id] = sort(amp(c_list),'descend');
            if ~isempty(id)
                % select limited count:
                tmp_list = c_list(id(1:min(end,c_max)));
                
                % store the harmonics to the simulator list:                
                sim.ih_f = fh(tmp_list);
                sim.ih_amp = amp(tmp_list);
                
                % remove used components from the merged list:
                c_list = setdiff(c_list,tmp_list);                                                
            else
                % no more component found:
                sim.ih_f = [];
                sim.ih_amp = [];                
            end
            
            % residual RMS of the components not selected for the simulation:
            rms_res = sum(0.5*mean_spect_amp(amp,c_list).^2)^0.5;

            % add the residual RMS to the noise:
            sim.noise_rms = (noise_rms^2 + rms_res^2)^0.5;
            
            %sim
                            
            % execute Monte-Carlo using calcset options:
            res = qwtb_mcm_exec(@proc_MFSF,sim,calcset);
            
            % optional debug plots:
            if isfield(calcset,'dbg_plots') && calcset.dbg_plots 
                figure;
                hist(res.f0_dev,30,1);
                title('Monte Carlo of ''f0''');
                xlabel('\delta{}f');
                ylabel('probab [-]');
            end
            
            % estimate uncertainties of algorithm from randomized outputs:
            u_f0 = scovint(res.f0_dev,calcset.loc); % relative
            u_dc = scovint(res.ofs_dev,calcset.loc); % absolute            
            u_A = [];
            u_ph = [];
            for k = 1:size(res.A_dev,2)
                u_A(k)  = scovint(res.A_dev(:,k),calcset.loc); % absolute
                u_ph(k) = scovint(res.ph_dev(:,k),calcset.loc); % absolute
            end
            
        
        elseif strcmpi(calcset.unc,'guf')
            % --- Fast estimator ---
        
            % ###todo: to do estimator
                        
            if abs(datain.CFT.v - 3.5e-11) > 1e-13
                % not allowed value of CFC!
                error('QWTB: MFSF wrapper: ''CFT'' value for uncertainty mode ''guf'' must be 3.5e-11 only!');                
            end
            
            if datain.fest.v >= 0
                % not allowed mode of initial guess!
                error('QWTB: MFSF wrapper: ''fest'' option must be ''-1'' for uncertainty mode ''guf''!');                
            end
                        
            if any(abs(diff(sort(datain.ExpComp.v)) - 1) > 10*eps)
                % fitted components must be harmonics and from [1:?] with no gaps!
                error('QWTB: MFSF wrapper: ''ExpComp'' components list must be linear order [1,2,3..N] without gaps. No interhamonics allowed.');
            end            
            
            % calculate RMS of everything but the fitted components:
            rms_spur = (noise_rms^2 + h_rms^2 + ih_rms^2)^0.5;
            
            % SNR estimate (fundamental/rms(noise)):
            SNR = A(1)/rms_spur;
            
            %###todo: SIQ - add limits of estimation???
                                    
            % estimate the uncertainty (k = 2):            
            [u_f1, u_A1, u_Ah] = MFSF_unc(f0, A(1), 1/Ts, numel(datain.y.v), datain.adcres.v, SNR, datain.jitter.v);
            
            % express the uncertainties for desired level of confidence:
            u_f0 = u_f1/f0*loc2covg(calcset.loc,50)/2;
            u_A = [u_A1 repmat(u_Ah,[1 numel(datain.ExpComp.v)-1])]*loc2covg(calcset.loc,50)/2;
            u_ph = zeros(size(u_A));
            u_dc = 0;                        
                        
        end
        
        % calcualte worst case estimate for THD uncertainty:
        thd_a = sum((A(2:end) + u_A(2:end)).^2)^0.5/(A(1) - u_A(1));
        thd_b = sum((A(2:end) - u_A(2:end)).^2)^0.5/(A(1) + u_A(1));
        u_thd = max(abs([thd_a thd_b] - THD));
    
    else
        % --- no uncertainty mode ---
        
        u_f0 = 0;
        u_dc = 0;
        u_A = 0*A;
        u_ph = 0*phase;
        u_thd = 0;
                                       
    end
    
    
    

    % Format output data:  --------------------------- %<<<1
    % MFSF definition is:
    % function [f0, A, phase, THD] = MFSF(Record, Ts, Har,ig,RelErr)
    % OUTPUT ARGUMENTS
    %   f0      : estimated fundamental frequency
    %   A       : estimated signal's amplitude (record for more harmonics)
    %   phase   : estimated signal's phase (record for more harmonics)
    %   THD     : Total harmonic distortion for specified number of harmonics
    
    dataout.f.v = f_har(:)';
    dataout.f.u = u_f0.*f_har(:)';    
    dataout.A.v = A;
    dataout.A.u = u_A;
    dataout.ph.v = phase;
    dataout.ph.u = u_ph;
    dataout.O.v = O;
    dataout.O.u = u_dc;
    dataout.THD.v = THD; % fundamental referenced 
    dataout.THD.u = u_thd; % fundamental referenced

end % function




function A = mean_spect_amp(amp,bid)
% Calculates peak amplitudes of DFT spectrum 'amp' components 
% defined by bins indices 'bid'.
% It peforms following calcualtion for each bin:
% A(k) = (0.5*amp(bid(k)-1) + amp(bid(k)) + 0.5*amp(bid(k)+1))/2
% The weighing cofficients are empiric.          
    is_hor = size(bid,2);            
    A = amp(bsxfun(@plus,bid(:),[-1 0 +1]))*[0.5;1;0.5]/2;
    if is_hor
        A = A';
    end     
end

% vim settings modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=80 tabstop=4 shiftwidth=4
