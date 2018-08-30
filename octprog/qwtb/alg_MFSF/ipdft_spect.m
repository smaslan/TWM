function f = ipdft_spect(fft_array,fs)
% IPDFT_SPECT  2-point IpDFT algorithm
%
%    f = ipdft_spect(fft_array,fs)
%       f         - frequency estimate (in Hz)
%       fft_array - FFT spectrum of the signal whose frequency is being estimated
%       fs        - sampling frequency (in Hz)

N=length(fft_array);
df=fs/N;

fft_array=fft_array/N;
abs_fft_array=abs(fft_array);
abs_fft_array(1)=0;
[val,i]=max(abs_fft_array);
if abs_fft_array(i-1) > abs_fft_array(i+1)
    i1=i-1;
    i2=i;
else
    i1=i;
    i2=i+1;
end

n=2*pi/N;
UL=real(fft_array(i1));
UL1=real(fft_array(i2));
VL=imag(fft_array(i1));
VL1=imag(fft_array(i2));
kopt=(((sin(n*i1))*(VL1-VL))+((cos(n*i1))*(UL1-UL)))/(UL1-UL);
Z1=VL*((kopt-cos(n*i1))/(sin(n*i1)))+UL;
Z2=VL1*((kopt-cos(n*i2))/(sin(n*i2)))+UL1;
lambda=(acos((Z2*cos(n*i2)-Z1*cos(n*i1))/(Z2-Z1)))/n;
f=df*(lambda-1);