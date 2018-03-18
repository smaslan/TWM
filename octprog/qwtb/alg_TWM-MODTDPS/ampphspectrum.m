function [f, amp, ph] = ampphspectrum(y,fs,new)
% Calcualtes discrete fourier transformation of vector of sampled values |y| with sampling
% frequency |fs|, normalize values and returns frequency vector |f|, amplitudes |amp| and
% phases |ph|.
% 
% Example with signal of frequency 1 Hz, sampled by 50 Hz 
% frequency, two harmonic components at 1 and 8 Hz and one
% interharmonic component at 15.5 Hz with various
% amplitudes and phases:
% 
% fr=1; fs=50;
% x=[0:1/fs:1/fr];
% x = x(1:end-1);
% y=sin(2*pi*fr*x+1)+0.5*sin(2*pi*8*fr*x+2)+0.3*sin(2*pi*15.5*fr*x+3);
% [f,amp,ph]=ampphspectrum(y,fs);
%
% ###NEW:
% Calculates DFT of REAL input vector (or matrix with one series per column).
% It extracts just positive frequencies of the spectrum and normalizes it.
%
% Usage:
%   [f, amp, ph] = ampphspectrum(y, fs)
%     - calculate spectrum
%
%   ampphspectrum()
%     - run self-test
%
% Parameters:
%   y - discrete time domain signal, either vector or matrix with one 
%       signal per column
%   fs - sampling frequency
%
% Returns:
%   f - frequencies of the DFT bins
%   amp, ph - amplitude/phase values of the DFT bins
%           - the spectrum is returned in the same orientation as source 'y'
%
% Version V0.1, Martin Sira:
%  - original release
% Version V0.2, 2018-01-28, Stanislav Maslan: 
%  - simplified, extended for matrix processing, added self-test
%
% Tested: Octave V4.0.0
%         Matlab 2008b

        if ~nargin
            % run self-test/validation
            f = ampphspectrum_test();
            amp = [];
            ph = [];
            
            return            
        end
        
        if nargin > 2 && new
            % --- NEW, SIMPLER, A BIT FASTER FOR LARGE DATA, CAN HANDLE MATRIX INPUT ---
            
            if nargin > 3 || nargin < 2
                print_usage();
            end
            
            if ~isscalar(fs)
                error('fs has to be a scalar!');
            end
            
            if ndims(y) > 2 || isscalar(y)
                error('y has to be vector or matrix!');
            end

            % vector is horizontal?
            was_horz = isvector(y) && size(y,2) > 1;
            
            if was_horz
                % vector to vertical:
                y = y(:);
            end

            % total samples count:
            N = size(y,1);
                       
            % calculate normalized full spectrum:
            Y = fft(y)/N*2;
            % fix DC offset error (this is caused by using just a halve of the DFT spectrum):
            Y(1,:) = Y(1,:)*0.5;
                            
            % throw away negative frequencies of the spectrum:
            Y = Y(1:ceil(N/2+0.5),:);
        
            % fix the angles
            % note: No idea why is this needed, but it has something to do with using just a halve of the DFT spectrum
            %       nevertheless this ensured the DFT bin phases matches test waveform (see test function)
            Y .*= exp(j*pi/2);
            
            % build complementary frequency vector (keep the same orientation as 'y'):
            f(:,1) = [0:size(Y,1)-1]/N*fs;
            
            if was_horz
                % restore original orientation of the data:
                Y = Y.';
                f = f.';
            end
            
            % extract magnitude:
            amp = abs(Y);
            
            % extract phase:
            ph = arg(Y);
        
        else
            % --- ORIGINAL ---
            % ###CTI: nechapu kdes na to prisel, 3x tam tocis ten samej vektor 'Y' tam a zpet a na konci
            % stejne jen vyberes pul puvodniho spektra Y, viz nova implementace, navic v tom mas asi chybu
            % protoze to vraci 2x vyssi offset. To je dany tim, ze vsechny slozky jsou tam 2x, jednou pro
            % pozitivni jednou pro negativni fr (komplexne sdruzene). To oba resime time, ze proste vezmeme
            % jednu pulku, nasobime ji 2x. Jenze offset je tam jen jednou (jeden BIN), takze se zdvojnasobi.         
        
        
            % ---- check input values ----
            if (nargin > 3 || nargin < 2)
                    print_usage();
            end
    
            if ~isvector(y)
                    error('y has to be a vector!');
            end
    
            if ~isscalar(fs)
                    error('fs has to be a scalar!');
            end
    
            % ---- DFT ----
            % (DFT is maybe slightly complicated because the input can contain odd number of samples)
            % number of samples:
            N = length(y);
            % calculate frequency spacing
            df = fs / N;
            % calculate unshifted frequency vector
            f = [0:(N - 1)]*df;
            % move all frequencies that are greater than fs/2 to the negative side of the axis
            f(f >= fs / 2) = f(f >= fs / 2) - fs;
            % fft calculation:
            Y = fft(y);
            % now, Y and f are aligned with one another; if you want frequencies in strictly
            % increasing order, fftshift() them
            Y = fftshift(Y);
            f = fftshift(f);
            % select negative frequencies part of results:
            Y = Y(1:find(f == 0));
            f = f(1:find(f == 0));
            % change sort order and make neg. freq. positive:
            f = abs(f(end:-1:1));
            Y = Y(end:-1:1);
            % power values normalized:
            amp = 2 * abs(Y) / N;
            % calculate phases (and correctly multiply by minuses etc. because we used negative part of
            % spectra):
            ph = -1.*angle(-i.*Y);
        
        end
end

% vim settings line: vim: foldmarker=%{{{,%}}} fdm=marker fen ft=octave





% ---------------------------- %
% Here starts testing routines %
% ---------------------------- %

%!test ampphspectrum()
function result = ampphspectrum_test()

    % samples count (odd, even):
    N_list = 11;[1e6 1e6+1];
    
    % analyses to perform:
    M = 10;
    
    % list of harmonic frequencies to generate:
    F = [1   3    5];
    % list of harmonic amplitudes to generate:
    A = [1   0.5  1];
    % list of harmonic phases to generate:
    P = [0.1 -0.9 0.5]*pi;
    % offset:
    O = 0.1;
    
    
    for n = 1:numel(N_list)                
        
        % samples count to test:
        N = N_list(n);
        
        disp(sprintf('Testing for N = %d samples ...',int32(N)));  
        
        % generate relative time vector <0:2*pi)
        wt = [];
        wt(:,1) = [0:N-1]/N*2*pi;
        
        % generate harmonic components in time domain dims: (samples, harmonics):
        % u = A.*sin(wt.*F + P)
        u = bsxfun(@times, sin(bsxfun(@plus, bsxfun(@times,wt,F), P)), A);    
        % sum the harmonic to single composite signal:
        u = sum(u,2);
        % ass offset:
        u = u + O;
              
        % calculate the spectrum:
        tic
        for k = 1:M
            [f1, a1, p1] = ampphspectrum(u, 1); % old method
        end
        t1 = toc
        
        u = repmat(u,[1 M]); % replicate M waveforms so we can calculate with matrix
        tic    
        [f2, a2, p2] = ampphspectrum(u, 1, 1); % new method
        t2 = toc

        
        % --- check validity of the new implementation:
        % ###note: to be removed
        if any(abs(f2(:) - f1(:)) > 2*eps)
            error('New/old: Frequency vectors do not match.');
        end
        % ###note: skipping DC component check because it is possibly wrong in the old implementation? 
        if any(abs(a2(2:end,1) - a1(2:end)) > 2*eps)
            error('New/old: Amplitude vectors do not match.');
        end    
        if any(abs(p2(2:end,1) - p1(2:end)) > 10*eps)
            error('New/old: Phase vectors do not match.');
        end
                
        
        % --- check the match with synthesized data:
        if any(abs(a2(F+1,1) - A(:)) > 2*eps)
            error('Calculated amplitudes do not match synthesized ones.');
        end
        if any(abs(p2(F+1,1) - P(:)) > 2*eps)
            error('Calculated phases do not match synthesized ones.');
        end    
        if any(abs(a2(1,1) - O) > 2*eps)
            error('Calculated offset does not match synthesized one.');
        end
        
        disp(sprintf(' ... done!\n'));
    
    end 
    
    result = 1;       
    
end
