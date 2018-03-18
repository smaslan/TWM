clear all

%% switch plot output to GNUplot - works a little better under Windoze
if(sum((version-'3.4.3').*10.^(length(version):-1:1))>=0)
  graphics_toolkit('gnuplot');
end

%% set cwd to script folder (since version 3.6.4 the Octave won't find data at '--path')
mfld = mfilename('fullpath'); mfld = mfld(1:strchr(mfld,filesep(),1,'last'));
cd(mfld);




N = 10000;

fs = 10000;

f0 = 50.3;

fm = 4.321;

A0 = 0.5;
Am = 0.5;

dc = 0.1;

u = mod_synth(fs,N, dc, f0,A0,0, fm,Am,0.1);

%[fU,U,ph] = ampphspectrum(u,fs);
%semilogx(fU,U)
%return


plot(u)

[dcx,f0x,A0x, fmx,Amx,phmx] = mod_fit_sin(fs,u);


dci = dcx;
f0i = f0x;
A0i = A0x;
fmi = fmx;
Ami = Amx;
phmi = phmx;

for k = 1:3
    
    % synth form model:
    ux = mod_synth(fs,N, dci, f0i,A0i,0, fmi,Ami,phmi);
    
    % calculate parameters of model:
    [dcx2,f0x2,A0x2, fmx2,Amx2,phmx2] = mod_fit_sin(fs,ux);
    
    dci = dci + (dci - dcx2);
    f0i = f0i*f0x/f0x2;
    A0i = A0i*A0x/A0x2;
        
    fmi = fmi*fmx/fmx2;
    Ami = Ami*Amx/Amx2;
    phmi = phmi + mod((phmx - phmx2) + pi,2*pi) - pi;
    
end

tic
M = 100;
Amx2 = [];
A0x2 = [];
for k = 1:M
    ux = mod_synth(fs,N, dci, f0i,A0i,(k-1)/M*2*pi, fmi,Ami,phmi);
    [dcx2,f0x2,A0x2(k), fmx2,Amx2(k),phmx2] = mod_fit_sin(fs,ux);    
end
toc


%hold on;
%plot(ux,'r')
%hold off;


f0i
A0i
fmi
Ami


return



f = 50;
T = 1/f;
a = 10e-6;

p = linspace(0,2*pi,100);
%g = (1/(a/T*2*pi))*(cos(p)-cos((T.*p+2.*pi.*a)./T));
%h = (cos(p)-cos(p+2*pi*a*f))./(2*pi*a*f);
%plot(p,sin(p))
%hold on
%plot(p,h,'r')
%hold off;

f = [];
f(:,1) = logspace(log10(50),log10(5000),100);
T = 1./f;

%h = -(T.*exp((j*pi*a)./T).^2-T)./(4*pi*a)*2;
%h = conj(h);
%h .*= exp(j*pi/2);


%ha = 2*sqrt(T.^2.*sin((2.*pi.*a)./T).^2+(T.*cos((2.*pi.*a)./T)-T).^2)./(4.*pi.*abs(a));
%hp = -atan2(sin(pi/2),cos(pi/2))-atan2(T.*sin((2*pi*a)./T),T.*cos((2*pi*a)./T)-T)+atan2(0,a./sqrt(a.^2))+pi;

ha = sqrt(sin(2*pi*a*f).^2+(cos(2*pi*a*f)-1).^2)./(2*pi*abs(a)*abs(f));
hp = atan2(sin(2*pi*a*f),cos(2*pi*a*f)-1) - pi/2;

hae = (ha - 1)*1e6; 
hpe = 180/pi*hp;

figure(1)
loglog(f,hae);
xlabel('f [Hz]');
ylabel('\delta(U) [\muV/V]');
grid on;
box on;
print('ampl.png','-S480,300','-F:7','-dpng');

figure(2)
loglog(f,hpe);
xlabel('f [Hz]');
ylabel('\Delta(\Phi) [deg]');
grid on;
box on;
print('phase.png','-S480,300','-F:7','-dpng');






return




