function w = flattop(N, T)%<<<1
% original function definition changed because of matlab compatibility:
% function w = flattop(N, T=8)%<<<1
% -- Function File: W = flattop (T,N)
%     Function generates symmetric flat top window coefficients W of
%     length N and type T.  Parameter N sets the length of the window, so
%     it can be different than signal length.  Parameter T selects type
%     of flat top window:
%     '1'
%          The same as in Matlab.
%     '2 up 4'
%          Fast decaying
%     '5 up 7'
%          Minimum sidelobe
%     '8'
%          Lowest sidelobe
%   'G. Heinzel, ‘Spectrum and spectral density estimation by the
%Discrete Fourier transform (DFT), including a comprehensive list of
%window functions and some new flat-top windows’, IEEE, 2003.'
%'https://www.mathworks.com/help/signal/ref/flattopwin.html' 'D'Antona,
%Gabriele, and A. Ferrero. Digital Signal Processing for Measurement
%Systems. New York: Springer Media, 2006, pp. 70–72.'  'Gade, Svend,
%and Henrik Herlufsen. "Use of Weighting Functions in DFT/FFT Analysis
%(Part I)." Windows to FFT Analysis (Part I): Brüel & Kjær Technical
%Review, No. 3, 1987, pp. 1–28.'

% Copyright (C) Věra Nováková Zachovalová
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; If not, see <http://www.gnu.org/licenses/>.

% Contact: Věra Nováková Zachovalová <vnovakovazachovalovaATcmi.cz>
% Created: 2011
% Version: 0.10
% Contains help: yes
% Contains test: no
% Contains demo: no

% XXX T->t, N->n, in equations N and n are used!!!!

% added because of matlab compatibility:
if nargin < 2
        T = 8;
end

switch T
        case 1
        %matlab
                a0 = 0.21557895;
                a1 = -0.41663158;
                a2 = 0.277263158;
                a3 = -0.083578947;
                a4 = 0.006947368;
                a5 = 0;
                a6 = 0;
                a7 = 0;
                a8 = 0;
                a9 = 0;
                a10 = 0;
        case 2
        %SFT3F fast decaying
                a0 = 0.26526;
                a1 = -0.5;
                a2 = 0.23474;
                a3 = 0;
                a4 = 0;
                a5 = 0;
                a6 = 0;
                a7 = 0;
                a8 = 0;
                a9 = 0;
                a10 = 0;
        case 3
        %SFT4F fast decaying
                a0 = 0.21706;
                a1 = -0.42103;
                a2 = 0.28294;
                a3 = -0.07897;
                a4 = 0;
                a5 = 0;
                a6 = 0;
                a7 = 0;
                a8 = 0;
                a9 = 0;
                a10 = 0;
        case 4
        %SFT5F fast decaying
                a0 = 0.1881;
                a1 = -0.36923;
                a2 = 0.28702;
                a3 = -0.13077;
                a4 = 0.02488;
                a5 = 0;
                a6 = 0;
                a7 = 0;
                a8 = 0;
                a9 = 0;
                a10 = 0;
        case 5
        %SFT3M minimum sidelobe
                a0 = 0.28235;
                a1 = -0.52105;
                a2 = 0.19659;
                a3 = 0;
                a4 = 0;
                a5 = 0;
                a6 = 0;
                a7 = 0;
                a8 = 0;
                a9 = 0;
                a10 = 0;
        case 6
        %SFT4M minimum sidelobe
                a0 = 0.241906;
                a1 = -0.460841;
                a2 = 0.255381;
                a3 = -0.041872;
                a4 = 0;
                a5 = 0;
                a6 = 0;
                a7 = 0;
                a8 = 0;
                a9 = 0;
                a10 = 0;
        case 7
        %SFT5M minimum sidelobe
                a0 = 0.209671;
                a1 = -0.407331;
                a2 = 0.281225;
                a3 = -0.092669;
                a4 = 0.0091036;
                a5 = 0;
                a6 = 0;
                a7 = 0;
                a8 = 0;
                a9 = 0;
                a10 = 0;
        case 8
        %HFT248D lowest sidelobe 5.5 bins
                a0 = 1;
                a1 = -1.985844164102;
                a2 = 1.791176438506;
                a3 = -1.282075284005;
                a4 = 0.667777530266;
                a5 = -0.240160796576;
                a6 = 0.056656381764;
                a7 = -0.008134974479;
                a8 = 0.00062454465;
                a9 = -0.000019808998;
                a10 = 0.000000132974;
        otherwise
        %matlab
        % https://www.mathworks.com/help/signal/ref/flattopwin.html
                a0 = 0.21557895;
                a1 = -0.41663158;
                a2 = 0.277263158;
                a3 = -0.083578947;
                a4 = 0.006947368;
                a5 = 0;
                a6 = 0;
                a7 = 0;
                a8 = 0;
                a9 = 0;
                a10 = 0;
end

%for n = 1:1:N
%	w(n) = a0+a1*cos(2*pi*(n-1)/(N-1))+a2*cos(4*pi*(n-1)/(N-1))+a3*cos(6*pi*(n-1)/(N-1))+a4*cos(8*pi*(n-1)/(N-1))+a5*cos(10*pi*(n-1)/(N-1))+a6*cos(12*pi*(n-1)/(N-1))+a7*cos(14*pi*(n-1)/(N-1))+a8*cos(16*pi*(n-1)/(N-1))+a9*cos(18*pi*(n-1)/(N-1))+a10*cos(20*pi*(n-1)/(N-1));
%end

n=[1:1:N];
w = a0+a1*cos(2*pi*(n-1)/(N-1))+a2*cos(4*pi*(n-1)/(N-1))+a3*cos(6*pi*(n-1)/(N-1))+a4*cos(8*pi*(n-1)/(N-1))+a5*cos(10*pi*(n-1)/(N-1))+a6*cos(12*pi*(n-1)/(N-1))+a7*cos(14*pi*(n-1)/(N-1))+a8*cos(16*pi*(n-1)/(N-1))+a9*cos(18*pi*(n-1)/(N-1))+a10*cos(20*pi*(n-1)/(N-1));

end

% vim settings line: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000
