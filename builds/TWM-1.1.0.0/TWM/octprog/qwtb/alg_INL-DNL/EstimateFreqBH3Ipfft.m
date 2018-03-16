function f = EstimateFreqBH3Ipfft(x,varargin)
% @fn EstimateFreqBH3Ipfft
% @brief Estimates the frequency of the input signal using different windowa in time domnain, and paraboloc interpolation in
%       frequency domain
% @param x The vector of the sampled (and quantized) signal
% @param varargin 
%        NFFT: length of DFT can be specified optionally
%              deafult value is 1E6
%        source_of_initial_fr: specifies the window to be used
%            possible values:
%               'FFT'
%               'ipFFT (without windowing)'
%               'ipFFT (Hann window)'
%               'ipFFT (Blackman window)'
% @return f The estimated frequency normalized to the sampling frequency (f/fs)
% @author Tamás Virosztek, Budapest University of Technology and Economics,
%         Department of Measurement and Information Systems,
%         Virosztek.Tamas@mit.bme.hu

% f = EstimateFreqBH3Ipfft(x,NFFT,source_of_initial_fr)

if (nargin >= 2)
    NFFT = varargin{1};
else
    NFFT = 1e6;
end

if (nargin >= 3)
    source_of_initial_fr = varargin{2};
else
    source_of_initial_fr = 'ipFFT (Blackman window)'; %If no method specified, ipFFT with Blackman window is used
end

x = x(:);
%Discarding DC component:
x = x - mean(x);

if (strcmpi(source_of_initial_fr,'FFT') || strcmpi(source_of_initial_fr,'ipFFT (without windowing)'))
    windowed_data = x;
elseif (strcmpi(source_of_initial_fr,'ipFFT (Hann window)'))
    windowed_data = x.*hann(length(x));
elseif (strcmpi(source_of_initial_fr,'ipFFT (Blackman window)'))
    windowed_data = x.*blackman(length(x));
else
    windowed_data = x;
end
    
W = fft(windowed_data,NFFT);
Wa = abs(W);

[val,ind] = max(Wa(1:floor(NFFT/2)+1));

%Fitting parabola to the two neighbours of the peak:
D = [(ind-1)^2,     ind-1,  1;...
     (ind)^2,       ind,    1;...
     (ind+1)^2,     ind+1,  1];
if (rcond(D) < 1e-6)
    %If the matrix D is close to singular, parabola fitting is cancelled.
    %Frequency is estimated simply using the peak of the FFT
    f = (ind-1)/NFFT;
else
    y = [Wa(ind-1); Wa(ind); Wa(ind+1)];
    p = inv(D)*y;
    peak = -p(2)/(2*p(1));
    f = (peak - 1)/NFFT;
end

end