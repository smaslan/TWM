function [tran,tfer,u_tfer] = correction_transducer_loading(tran,dig)
% TWM: This function calculates loading effect of the transducer and corrects
% its frequency response accordingly. It also propagates the uncertainty
% of the loading impedances to the resulting transfer.
%
% Parameters:
%   tran - transducer correction data with items:
%            type - 'shunt' or 'divider'
%            inp_Y - (Cp+D format)
%            tfer_gain - 2D table of absolute gain values (in/out)
%            tfer_phi - 2D table of phase shifts (rad)
%            Zca - 1D table of output terminals series Z (Rs+Ls format)
%            Yca - 1D table of output terminals shunting Y (Cp+D format)
%            Zcb - 1D table of cable series Z (Rs+Ls format)
%            Ycb - 1D table of cable shunting Y (Cp+D format)
%            Zlo - 1D table of RVD's low side resistor Z (Rp+Cp format)     
%   dig  - digitizer channel correction data with items:
%            inp_Y - channel input shunting admittance (Cp+D format)
%
%
% Returns:
%   tran   - transducer correction with 'tfer_gain' and 'tfer_phi' corrected
%            by the loading 'tfer' correction. Uncertainties in the 'tfer_...'
%            tables are updated as well.
%   tfer   - the loading correction itself
%   u_tfer - absolute uncertainty of 'tfer' 
%
%
%
% The correction applies following equivalent circuit:
%
%  in (RVD)
%  o-------+
%          |
%         +++
%         | | Zhi
%         | |
%         +++ Zca/2      Zca/2      Zcb/2      Zcb/2
%  in      |  +----+     +----+     +----+     +----+        out
%  o-------+--+    +--+--+    +--o--+    +--+--+    +--o--+-----o
%  (shunt) |  +----+  |  +----+     +----+  |  +----+     |
%         +++        +++                   +++           +++
%         | |        | |                   | |           | |
%         | | Zlo    | | Yca (optional)    | | Ycb       | | Yin
%         +++        +++                   +++           +++
%  0V      |          |                     |             |     0V
%  o-------+----------+----------o----------+----------o--+-----o
%
%  ^                             ^                     ^        ^
%  |                             |                     |        |
%  +-------- TRANSDUCER ---------+------ CABLE --------+- ADC --+
%
% The correction consist of 3 components:
%  a) The transducer (RVD or shunt). When shunt. The Zhi nor Zlo are not
%     required as the Zlo can be expressed from tfer_gain and tfer_phi.
%     Part of the tran. is also its output terminal modeled as transmission
%     line Zca/2-Yca-Zca/2.
%  b) Second part is optional cable from Zcb/2-Ycb-Zcb/2.
%  c) Last part is the internal shunting admittance of the digitizer's channel.
%
% The algorithm calculates the correction in 3 steps:
%  1) Unload the transducer from the Zcb-Ycb load.
%  2) Calculate effect of the cable and digitizer to the impedane Zlo.
%  3) Calculate complex transfer from V(Zlo) to V(out).
% All effects combines linearly to complex 'tfer' correction.  
%
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
%

    if ~nargin
        % initiate testing function instead of the algorithm
        correction_transducer_loading_test();
        
        tran = [];
        tfer = [];
        u_tfer = [];
        return    
    end

    % monte carlo cycles:
    mcc = 1000;

    % is it RVD?
    is_rvd = strcmpi(tran.type,'divider');
    
    if is_rvd && ~tran.has_Zlo
        error('Transducer loading correction: Transducer is RVD but low side imepdance ''Zlo'' is not defined!');        
    end
    
    % check cable correction consistency: 
    if tran.has_Zcb + tran.has_Ycb == 1
        error('Transducer loading correction: Cable correction is incomplete! Zcb or Ycb is missing.');
    end

    % make list of involved tables:
    tlist = {tran.tfer_gain,tran.tfer_phi,tran.Zlo,tran.Zca,tran.Yca,tran.Zcb,tran.Ycb,dig.Yin};
    
    % merge axes of the tables:
    [tlist,rms,fx] = correction_expand_tables(tlist);
    
    if ~numel(fx)
        % non of the correction have frequency dependence, so generate some range:
        % ###todo: this should be somehow protected. In real life it won't happen as at least the 
        %          'tfer_gain' and 'tfer_phi' will be dependence but theoretically it may happen
        fx(:,1) = logspace(log10(10),log10(1e6),10);
    end
            
    % interpolate divider's transfer, convert to complex transfer:
    tfer_gain = correction_interp_table(tlist{1},[],fx);
    tfer_phi = correction_interp_table(tlist{2},[],fx);    
    g = nanmean(tfer_gain.gain,2);
    p = nanmean(tfer_phi.phi,2);
    u_g = nanmean(tfer_gain.u_gain,2);
    u_p = nanmean(tfer_phi.u_phi,2);
    [tr, u_tr] = Zphi2Z(g, p, u_g, u_p);
    tr_org = tr;
    tr = mcrand(2, mcc, tr, u_tr);

    % interpolate RVD's low side admittance:
    tmp = correction_interp_table(tlist{3},[],fx);
    [Zlo,u_Zlo] = CpRp2Z(fx, tmp.Cp, tmp.Rp, tmp.u_Cp, tmp.u_Rp);
    Zlo = mcrand(2, mcc, Zlo, u_Zlo);
    
    % interpolate output terminals Z/Y:
    tmp = correction_interp_table(tlist{4},[],fx);
    [Zca,u_Zca] = LsRs2Z(fx, tmp.Ls, tmp.Rs, tmp.u_Ls, tmp.u_Rs);
    Zca = mcrand(2, mcc, Zca, u_Zca);
    
    tmp = correction_interp_table(tlist{5},[],fx);
    [Yca,u_Yca] = CpD2Y(fx, tmp.Cp, tmp.D, tmp.u_Cp, tmp.u_D);
    Yca = mcrand(2, mcc, Yca, u_Yca);
    
    % interpolate cable's terminals Z/Y:
    tmp = correction_interp_table(tlist{6},[],fx);
    [Zcb,u_Zcb] = LsRs2Z(fx, tmp.Ls, tmp.Rs, tmp.u_Ls, tmp.u_Rs);
    Zcb = mcrand(2, mcc, Zcb, u_Zcb);
    
    tmp = correction_interp_table(tlist{7},[],fx);
    [Ycb,u_Ycb] = CpD2Y(fx, tmp.Cp, tmp.D, tmp.u_Cp, tmp.u_D);
    Ycb = mcrand(2, mcc, Ycb, u_Ycb);
    
    % interpolate ADC's input admittance:
    tmp = correction_interp_table(tlist{8},[],fx);
    [Yin,u_Yin] = CpGp2Y(fx, tmp.Cp, tmp.Gp, tmp.u_Cp, tmp.u_Gp);
    Yin = mcrand(2, mcc, Yin, u_Yin);
    
    
    % calculate Zlo for shunt from transfer:
    if ~is_rvd
        [Zlo,u_Zlo] = Z_inv(tr,u_tr);
    end
    
    % --- 1) Assume the transd. was measured including the effect of the Zca-Yca
    %        and no external load. So unload it from the 0.5Zca-Yca load:
    
    % Zlo unloaded by the 0.5Zca-Yca shunting impedance:
    Zlo_ef = 1./(1./Zlo - 1./(0.5*Zca + 1./Yca));
    
    % the complex transfer of the 0.5Zca-Yca divider (out/in):
    k_ca = 2./(Yca.*Zca+2);
    
    % fix the error due to the terminals loading:
    tr = tr.*k_ca;
    
    if is_rvd
        % for RVD:
        
        % high-side impedance:        
        Zhi = Zlo.*(tr - 1);
        
        % relative change of the low-side impedance due to loading:        
        LD = Zlo_ef./Zlo;
                
        % calculate loaded transfer (in/out):
        tr = (Zlo.*LD + Zhi)./(Zlo.*LD);
        
        % continue with the corrected low-side impedance:  
        Zlo = Zlo_ef;
    
    else
        % for Shunt:
        
        % relative effect to the transfer:
        k_zl = Zlo./Zlo_ef;
        
        % calculate actual, unloaded ratio of the transducer (in/out):
        tr = tr.*k_zl;
        
        % recalculate its impedance from the unloaded ratio:
        Zlo = 1./tr;
        
    end
       
    
    % --- 2) Calculate total impedance loading of the Zlo:
      
    % cable-to-digitizer tfer (in/out):
    k_in = (Yin.*Zcb + 2)/2;
    % (ZL+0.5*Zcb)||Ycb (temp value):
    Zx = 1./(Ycb + 1./(1./Yin + 0.5*Zcb));
    % terminal-to-cable tfer (in/out):
    k_cb = (Zcb + Zca + 2*Zx)./(2*Zx);
    % (0.5*Zca+0.5*Zcb+Zx)||Yca (temp value):
    Zx = 1./(Yca + 1./(Zx + 0.5*Zca + 0.5*Zcb));
    % tranfer transducer-terminal (in/out):
    k_te = (2*Zx + Zca)./(2*Zx);
    
    % calculate loaded low-side impedance:
    Zlo_ef = (Zlo.*Zx)./(Zx + Zlo);
    
    
    
    if is_rvd
        % RVD:
        
        % high-side impedance:        
        Zhi = Zlo.*(tr - 1);
        
        % relative change of the low-side impedance due to loading:        
        LD = Zlo_ef./Zlo;
        
        % calculate loaded transfer (in/out):
        tr = (Zlo.*LD + Zhi)./(Zlo.*LD);
        
    else
        % correct the transfer by the load effect (in/out):
        % note: this is not exact solution for RVD but it should be fine...
        tr = tr.*Zlo./Zlo_ef;
    end
      
    
    % --- 3) Apply tfer of the whole terminal-cable-digitizer chain to the trans. tfer:    
    tr = tr.*k_in.*k_cb.*k_te;
    
    
    
    
    % --- evaluate Monte-Carlo data:    
    % note: I don't use mean of the randomized data to avoid noisy result.
    %       Instead I use first item of noisified quantities which is original without noise,
    %       see mcrand().
    % mean relative loading correction factor:
    tfer = tr(:,1)./tr_org;
    % absolute uncertainty of the loading correction:
    u_tfer = complex(std(real(tr(:,2:end)),[],2),std(imag(tr(:,2:end)),[],2));
    
    
    % --- apply the correction to the original tfer.:
    
    % interpolate both gain and phse tfer to the identical axes:
    tfer_gain = correction_interp_table(tlist{1},rms,fx);
    tfer_phi = correction_interp_table(tlist{2},rms,fx);
    
    % convert gain-phase to complex tfer: 
    [tr, u_tr] = Zphi2Z(tfer_gain.gain, tfer_phi.phi, tfer_gain.u_gain, tfer_phi.u_phi);
    
    % apply correction in complex form:
    tr = tr.*tfer;
    % apply uncertainty:
    u_tr = uncc(u_tr,u_tfer);
    
    % convert loaded transd. transfer back to polar form:
    [g,p,u_g,u_p] = Z2Zphi(tr,u_tr);
    
    % overwrite original transducer's transfer:
    % note: preserve original custom data, i.e. the qwtb variable naming setup
    try
        qw = tran.tfer_gain.qwtb;
    end
    tran.tfer_gain = correction_load_table({fx,rms,g,u_g},'rms',{'f','gain','u_gain'});
    try
        tran.tfer_gain.qwtb = qw;
    end
    clear qw;
    try
        qw = tran.tfer_phi.qwtb;
    end
    tran.tfer_phi = correction_load_table({fx,rms,p,u_p},'rms',{'f','phi','u_phi'});
    try
        tran.tfer_phi.qwtb = qw;
    end

end


% ---------------------------------------------------------------------------------------
% Validation - this section contains functions used to validate the bloody algorithm
 
function [] = correction_transducer_loading_test()
% this is a test function that validates the loading algorithm by
% calculating the same correction using different method - loop-currents
    
    % test Z_inv():
    z =   [1e+6 + j*1e+3; 1     + j*10e-6];
    uz = [1e+2 + j*0.1;   10e-6 + j*10e-6];
    [y,uy] = Z_inv(z,uz);
    [z2,uz2] = Z_inv(y,uy);
    if abs(z./z2-1) > 1e-6 || abs(uz./uz2-1) > 0.01
        error('Z_inv() does not work!');
    end
    
    % test Z-phi to cplx(Z) and cplx(Z) to Z-phi covertor:
    m =  [1     ; 10];
    um = [1e-6  ; 100e-6];
    p =  [0.1   ; 1e-3];
    up = [100e-6; 1e-6];        
    [z,uz] = Zphi2Z(m,p,um,up);
    [m2,p2,um2,up2] = Z2Zphi(z,uz);
    if abs(m./m2-1) > 1e-6 || abs(p./p2-1) > 1e-6 || abs(um./um2-1) > 0.01 || abs(up./up2-1) > 0.01
        error('Z2ZPhi() or Zphi2Z() does not work!');
    end
    
    clear all;
    
    
    % frequency range of the simulation:
    F = 10;
    f(:,1) = logspace(log10(10),log10(1e6),F);
    w = f*2*pi;
    
    % rms range of the transd. transfers:
    rms(1,:) = [1 2 3];
    R = numel(rms);
    
    
    % nominal DC ratio of the transducer (in/out):
    D = 10;
    
    % define low side impedance Cp+Rp:
    Rlo = 200;
    Clo = 50e-12;
    Zlo = 1./(1/Rlo + j*w*Clo);
    
    % RVD high side parallel capacitance:
    Chi = Clo/(D-1);
    
    % RVD calculate high side impedance:
    Zhi = 1./(1/((D - 1)*Rlo) + j*w*Chi);
    
    % define terminals impedances:
    Ls_a = 1000e-9;
    Rs_a = 50e-3;
    Cp_a = 100e-12;
    D_a = 0.01;
    Zca = Rs_a + j*w*Ls_a;
    Yca = w*Cp_a*(j + D_a);
    
    % define cable's impedance:
    len_b = 0.5;
    Ls_b = 250e-9;
    Rs_b = 50e-3;
    Cp_b = 105e-12;
    D_b = 0.02;
    Zcb = (Rs_b + j*w*Ls_b)*len_b;
    Ycb = w*Cp_b*(j + D_b)*len_b;
    
    % define digitizer input impedance Cp-Rp:
    Cp_i = 50e-12;
    Rp_i = 1e6;
    Yin = 1./Rp_i + j*w*Cp_i;
    Zin = 1./Yin;
    
    % calculate effective value of the Zlo when loaded by 0.5*Zca-Yca:
    Zlo_ef = 1./(1./Zlo + 1./(1./Yca + 0.5*Zca));
    
    % Transfer of the terminals 0.5*Zca-Yca (in/out):
    k_te = (Yca.*Zca + 2)./2;
    
    % calculate effective transfer from input to transducer terminals (in/out):
    % note: this is what user will measure when doing calibration
    k_ef = (Zlo_ef + Zhi)./Zlo_ef.*k_te;
      
    
    tran.type = 'divider';
    is_rvd = strcmpi(tran.type,'divider');
            
    
    % simulate transd. transfer and uncertainty (gain):
    g = repmat(abs(k_ef),[1 R]);    
    u_g = g*0;
        
    % simulate transd. transfer and uncertainty (phase):
    p = repmat(arg(k_ef),[1 R]);    
    u_p = p*0;
    
    % remove some elements from the transd. tfer to emulate real correction data:
    g(end,end) = NaN;
    u_g(end,end) = NaN;
    
    % build transd. tfer tables:        
    tran.tfer_gain = correction_load_table({f,rms,g,u_g},'rms',{'f','gain','u_gain'});
    tran.tfer_phi = correction_load_table({f,rms,p,u_p},'rms',{'f','phi','u_phi'});
    
    U = ones(F,1);
    
    % build RVD's low-side impedance table:
    tran.Zlo = correction_load_table({f,1./real(1./Zlo_ef),imag(1./Zlo_ef)./w,0*U,0*U},'',{'f','Rp','Cp','u_Rp','u_Cp'});
    tran.has_Zlo = 1;
    
    % build terminal tables:    
    tran.Zca = correction_load_table({f,real(Zca),imag(Zca)./w,0*U,0*U},'',{'f','Rs','Ls','u_Rs','u_Ls'});
    tran.has_Zca = 1;
    tran.Yca = correction_load_table({f,imag(Yca)./w,real(Yca)./imag(Yca),0*U,0*U},'',{'f','Cp','D','u_Cp','u_D'});
    tran.has_Yca = 1;
    
    % build cable tables:
    tran.Zcb = correction_load_table({f,real(Zcb),imag(Zcb)./w,0*U,0*U},'',{'f','Rs','Ls','u_Rs','u_Ls'});
    tran.has_Zcb = 1;
    tran.Ycb = correction_load_table({f,imag(Ycb)./w,real(Ycb)./imag(Ycb),0*U,0*U},'',{'f','Cp','D','u_Cp','u_D'});
    tran.has_Ycb = 1;

    % digitizer's input impedance:
    dig.Yin = correction_load_table({f,imag(Yin)./w,real(Yin),0*U,0*U},'',{'f','Cp','Gp','u_Cp','u_Gp'});
    
    % calculate using the tested algorithm:
    [tran_n,tfer,u_tfer] = correction_transducer_loading(tran,dig);
    tran_n.tfer_gain.gain
    tran_n.tfer_phi.phi
    %tfer
    %u_tfer
    
    
    
    % --- now the fun part - exact solution ---
    
    % move frequency dependence to the third dim:
    Zhi = reshape(Zhi,[1,1,F]);
    Zlo = reshape(Zlo,[1,1,F]);
    Zin = reshape(Zin,[1,1,F]);
    Zca = reshape(Zca,[1,1,F]);
    Yca = reshape(Yca,[1,1,F]);
    Zcb = reshape(Zcb,[1,1,F]);
    Ycb = reshape(Ycb,[1,1,F]);
    Z = zeros(size(Zhi));

    % loop-currents matrix:
    L = [ Zhi+Zlo  -Zlo                  Z                               Z;
         -Zlo       Zlo+0.5*Zca+1./Yca  -1./Yca                          Z;
          Z        -1./Yca               1./Yca+0.5*Zca+0.5*Zcb+1./Ycb  -1./Ycb;
          Z         Z                   -1./Ycb                          1./Ycb+0.5*Zcb+Zin];

    % define loop voltages:
    U = [1;0;0;0];
    
    % solve for each frequency: 
    I = [];
    for k = 1:F       
        I(:,k) = L(:,:,k)\U;
    end
    
    U_out = I(4,:)(:).*Zin(:);
    
    tfer_ex = 1./U_out;
    
    abs(tfer_ex)
    arg(tfer_ex)
    
    %tfer_ex./k_ef
    
    
    
    
    
    


end









% ---------------------------------------------------------------------------------------
% Other stuff

% randomize complex quantity 'q' by complex uncertainty 'uq' in dimension 'dim' with 'N' elements   
function [qrnd] = mcrand(dim,N,q,uq)
    
    % select dimension to noisify:
    sz = ones(1,dim);
    sz(dim) = N;
    
    % generate normal noise, but keep first sample zero
    % for later calculation of unnoised mean value
    % it should not screw-up the ditribution too much if there is at least N=1000
    rer = randn(sz);
    imr = randn(sz);
    rer(1) = 0;
    imr(1) = 0;
    
    % randomize quantity:
    qrnd = bsxfun(@plus,real(q),bsxfun(@times,real(uq),rer)) + j*bsxfun(@plus,imag(q),bsxfun(@times,imag(uq),imr));
    
end


% ---------------------------------------------------------------------------------------
% Impedance conversion routines

% conversion of complex Z to Y and vice versa
function [Y,uY] = Z_inv(Z,uZ)

  Rs = real(Z);
  Xs = imag(Z);
  uRs = real(uZ);
  uXs = imag(uZ);
  
  uGp = (4*Rs.^2.*Xs.^2.*uXs.^2+(Xs.^4-2*Rs.^2.*Xs.^2+Rs.^4).*uRs.^2).^0.5./(Xs.^8+4*Rs.^2.*Xs.^6+6*Rs.^4.*Xs.^4+4*Rs.^6.*Xs.^2+Rs.^8).^0.5;
  %uGp =  (4*Rs.^2.*Xs.^2.*uXs.^2+(Xs.^4-2*Rs.^2.*Xs.^2+Rs.^4).*uRs.^2).^0.5./(Xs.^8+4*Rs.^2.*Xs.^6+6*Rs.^4.*Xs.^4+4*Rs.^6.*Xs.^2+Rs.^8).^0.5;
  %uGp = ((4*Rs.^2.*Xs.^2.*uXs.^2)./(Xs.^2+Rs.^2).^4+(1./(Xs.^2+Rs.^2)-(2*Rs.^2)./(Xs.^2+Rs.^2).^2).^2.*uRs.^2).^0.5;  
  uBp = ((Xs.^4-2*Rs.^2.*Xs.^2+Rs.^4).*uXs.^2+4*Rs.^2.*Xs.^2.*uRs.^2).^0.5./(Xs.^8+4*Rs.^2.*Xs.^6+6*Rs.^4.*Xs.^4+4*Rs.^6.*Xs.^2+Rs.^8).^0.5;
  
  Y = complex(1./Z);
  uY = complex(uGp,uBp); 
    
end


% conversion of Z-phi [Ohm-rad] scheme to complex Y scheme with uncertainty
% note: it has been crippled by the bsxfun() for Matlab < 2016b - do not remove!
function [Z,u_Z] = Zphi2Z(Z,phi,u_Z,u_phi)
    
    % re: sqrt(Z^2*sin(phi)^2*u_phi^2+cos(phi)^2*u_Z^2):
    % im: sqrt(g^2*cos(p)^2*u_p^2+sin(p)^2*u_g^2):
    %u_Z = sqrt(Z.^2.*sin(phi).^2.*u_phi.^2 + cos(phi).^2.*u_Z.^2) + j*sqrt(Z.^2.*cos(phi).^2.*u_phi.^2 + sin(phi).^2.*u_Z.^2);
    u_Z = (Z.^2.*sin(phi).^2.*u_phi.^2 + cos(phi).^2.*u_Z.^2).^0.5 + j*(Z.^2.*cos(phi).^2.*u_phi.^2 + sin(phi).^2.*u_Z.^2).^0.5;
       
    % Z = Z*e(j*phi) [Ohm + jOhm]:
    Z = Z.*exp(j*phi); 

end


% conversion of complex Z to Z-phi [Ohm-rad] scheme
% note: it has been crippled by the bsxfun() for Matlab < 2016b - do not remove!
function [Z,phi,u_Z,u_phi] = Z2Zphi(Z,u_Z)
 
    % extract real and imag parts:
    re = real(Z);
    im = imag(Z);
    u_re = real(u_Z);
    u_im = imag(u_Z);
        
    % sqrt(re^2*u_re^2+im^2*u_im^2)/sqrt(re^2+im^2)):
    %u_Z = sqrt(re.^2.*u_re.^2 + im.^2.*u_im.^2)./sqrt(re.^2 + im.^2);
    u_Z = (re.^2.*u_re.^2 + im.^2.*u_im.^2).^0.5./(re.^2 + im.^2).^0.5;
    
    % sqrt(im^2*u_re^2+re^2*u_im^2)/(re^2+im^2):
    %u_phi = sqrt(im.^2.*u_re.^2 + re.^2.*u_im.^2)./(re.^2 + im.^2);
    u_phi = (im.^2.*u_re.^2 + re.^2.*u_im.^2).^0.5./(re.^4 + 2*im.^2.*re.^2 + im.^4).^0.5;
    
    % convert to polar:
    phi = arg(Z);
    Z = abs(Z); 

end


% conversion of Cp-D scheme to complex Y scheme with uncertainty
% note: it has been crippled by the bsxfun() for Matlab < 2016b - do not remove!
function [Y,u_Y] = CpD2Y(f,Cp,D,u_Cp,u_D)
 
    % nagular freq [rad/s]:
    w = 2*pi*f;
    
    % Y = w.*Cp.*(j + D) [S + jS]:
    Y = bsxfun(@times,w,Cp).*(j + D);
    
    % re: sqrt(Cp^2*u_D^2+D^2*u_Cp^2)*abs(w):
    % im: abs(u_Cp)*abs(w):
    u_Y = bsxfun(@times,sqrt(Cp.^2.*u_D.^2 + D.^2.*u_Cp.^2),w) + j*bsxfun(@times,u_Cp,w);

end


% conversion of Cp-Gp scheme to complex Y scheme with uncertainty
% note: it has been crippled by the bsxfun() for Matlab < 2016b - do not remove!
function [Y,u_Y] = CpGp2Y(f,Cp,Gp,u_Cp,u_Gp)
 
    % angular freq [rad/s]:
    w = 2*pi*f;
    
    % admittance [S + jS]:
    Y = Gp + j*bsxfun(@times,w,Cp);
    
    % uncerainty [S + jS]:
    u_Y = u_Gp + j*bsxfun(@times,w,u_Cp);

end


% conversion of Cp-Rp scheme to complex Z scheme with uncertainty
% note: it has been crippled by the bsxfun() for Matlab < 2016b - do not remove!
function [Z,u_Z] = CpRp2Z(f,Cp,Rp,u_Cp,u_Rp)
 
    % nagular freq [rad/s]:
    w = 2*pi*f;
    
    % complex Z [Ohm + jOhm]:
    Z = 1./(j*bsxfun(@times,Cp,w) + 1./Rp);
        
    % uncertainty [Ohm + jOhm]:
    re = sqrt(bsxfun(@times,Cp.^4.*Rp.^4.*u_Rp.^2 + 4*Cp.^2.*Rp.^6.*u_Cp.^2,w.^4) - 2*Cp.^2.*Rp.^2.*u_Rp.^2.*w.^2 + u_Rp.^2)./(bsxfun(@times,Cp.^4.*Rp.^4,w.^4) + bsxfun(@times,2*Cp.^2.*Rp.^2,w.^2) + 1);
    im = (bsxfun(@times,Cp.^2.*Rp.^4.*u_Cp,w.^3) - bsxfun(@times,Rp.^2.*u_Cp,w))./(bsxfun(@times,Cp.^4.*Rp.^4,w.^4) + bsxfun(@times,2*Cp.^2.*Rp.^2,w.^2) + 1);
    u_Z = re + j*im;    

end


% conversion of Ls-Rs scheme to complex Z scheme with uncertainty
% note: it has been crippled by the bsxfun() for Matlab < 2016b - do not remove!
function [Z,u_Z] = LsRs2Z(f,Ls,Rs,u_Ls,u_Rs)
 
    % nagular freq [rad/s]:
    w = 2*pi*f;
    
    % Z = j*w*Ls + Rs [Ohm + jOhm]:
    Z = j*bsxfun(@times,w,Ls) + Rs;
    
    % re: abs(u_Rs)
    % im: abs(u_Ls)*abs(w)
    u_Z = u_Rs + j*bsxfun(@times,u_Ls,w);

end

