function [A,ph,u_A,u_ph] = correction_transducer_loading(tab,tran,f,A,ph,u_A,u_ph,lo_A,lo_ph,u_lo_A,u_lo_ph)
% TWM: This function calculates loading effect of the transducer and corrects
% its frequency response accordingly. It also propagates the uncertainty
% of the loading impedances to the resulting transfer.
%
% ### UNDER DEVELOPMENT!!!!
%
% [A,ph,u_A,u_ph] = correction_transducer_loading(tab,'shunt',f,A,ph,u_A,u_ph)
% [A,ph,u_A,u_ph] = correction_transducer_loading(tab,'rvd',f,A,ph,u_A,u_ph)
%   - single ended transducers
%
% [A,ph,u_A,u_ph] = correction_transducer_loading(tab,'shunt',f,A,ph,u_A,u_ph,lo_A,lo_ph,lo_u_A,lo_u_ph)
% [A,ph,u_A,u_ph] = correction_transducer_loading(tab,'rvd',f,A,ph,u_A,u_ph,lo_A,lo_ph,lo_u_A,lo_u_ph)
%   - differential transducers
%
% [] = correction_transducer_loading('test')
%   - run function selftest
%
% Parameters:
%   tab     - TWM-style correction tables with items:
%             tr_gain - 2D table (freq+rms axes) of tran. absolute gain values (in/out)
%             tr_phi - 2D table (freq+rms axes) of tran. phase shifts (rad)
%             tr_Zca - freq dep. of output terminals series Z (Rs+Ls format)              
%             tr_Yca - freq dep. of output terminals shunting Y (Cp+D format)
%             tr_Zcal - freq dep. of low-side output terminal series Z (Rs+Ls format)
%             tr_Zcam - freq dep. of mutual inductance of output terminals
%             adc_Yin - freq dep. of digitizer input admittance (Cp+Gp format)
%             lo_adc_Yin - freq dep. of digigitizer low-side channel input
%                     admittance (Cp+Gp format), differential mode only
%             Zcb - freq dep. of cable series Z (Rs+Ls format)
%             Ycb - freq dep. of cable shunting Y (Cp+D format)
%             tr_Zlo - freq dep. of RVD's low side resistor Z (Rp+Cp format)
%                  note: not used for shunts
%   tran    - transducer type {'rvd' or 'shunt'}
%   f       - vector of frequencies for which to calculate the correction
%   A       - vector of amplitudes at the digitizer input [V]
%   ph      - vector of phase angles at the digitizer input [rad]
%   u_A     - vector of abs. uncertainties of 'A' 
%   u_ph    - vector of abs. uncertainties of 'ph'
%   lo_A    - vector of amplitudes at the low-side digitizer input [V]
%   lo_ph   - vector of phase angles at the low-side digitizer input [rad]
%   u_lo_A  - vector of abs. uncertainties of 'A' 
%   u_lo_ph - vector of abs. uncertainties of 'ph'
%
% Returns:
%   A    - calculated input amplitudes
%   ph   - calculated input phase shifts
%   u_A  - abs. uncertainties of 'A' 
%   u_ph - abs. uncertainties of 'ph'
%
%
%
% The correction applies following equivalent circuit (single-ended mode):
%
%  in (RVD)
%  o-------+
%          |
%         +++
%         | | Zhi
%         | |
%         +++ Zca/2      Zca/2      Zcb/2      Zcb/2
%  in      |  +----+     +----+     +----+     +----+          out
%  o-------+--+    +--+--+    +--o--+    +--+--+    +--o--+-----o
%  (shunt) |  +----+  |  +----+     +----+  |  +----+     |
%         +++        +++                   +++           +++
%         | |        | |                   | |           | |
%         | | Zlo    | | Yca               | | Ycb       | | Yin
%         +++        +++                   +++           +++
%  0V      |          |                     |             |     0V
%  o-------+----------+----------o----------+----------o--+-----o
%
%  ^                             ^                     ^        ^
%  |                             |                     |        |
%  +-------- TRANSDUCER ---------+------ CABLE --------+- ADC --+
%
% The correction consists of 3 components:
%  a) The transducer (RVD or shunt). When shunt, the Zhi nor Zlo are not
%     required as the Zlo can be expressed from tr_gain and tr_phi.
%     Part of the tran. definition is also its output terminal modeled 
%     as transmission line Zca/2-Yca-Zca/2.
%  b) Second part is optional cable from Zcb/2-Ycb-Zcb/2.
%  c) Last part is the internal shunting admittance of the digitizer's channel.
%
% The algorithm calculates the correction in 3 steps:
%  1) Unload the transducer from the Zca-Yca load.
%  2) Calculate effect of the cable and digitizer to the impedance Zlo.
%  3) Calculate complex transfer from V(Zlo) to V(out).
%  4) It calculates the input voltage or current and the uncertainties.
%
% Note the aditional parameters 'Zcal' and 'Zcam' were added for the 
% differential connection mode.  
% 
% 
%
%
% The correction applies following equivalent circuit (differential mode):
%
%  in (RVD)
%  o-------+
%          |
%         +++
%         | | Zhi                   
%         | |          
%         +++ Zca/2      Zca/2       Zcb/2      Zcb/2
%  in      |  +----+     +----+      +----+     +----+          
%  o-------+--+    +--+--+    +--o---+    +--+--+    +--o---+---o u
%  (shunt) |  +----+  |  +----+      +----+  |  +----+      |
%          |          |      ^              +++            +++
%         +++        +++      \             | |            | |
%         | |        | | Yca   | M          | | Ycb        | | Yin
%         | |        | |       |            +++            +++
%         +++        +++      /              |              |
%      Zlo |          |      v     +---------+----------o---+---o gnd_u
%  0V      |  +----+  |  +----+    | +----+     +----+
%  o-------+--+    +--+--+    +--o---+    +--+--+    +--o---+---o u_lo
%             +----+     +----+    | +----+  |  +----+      |
%             Zcal/2     Zcal/2    | Zcb/2  +++  Zcb/2     +++
%                                  |        | |            | |
%                                  |        | | Ycb        | | lo_Yin
%                                  |        +++            +++
%                                  |         |              |
%                                  +---------+----------o---+---o gnd_u_lo
%                                  |
%                                 +++                                
%  ^                             ^                      ^       ^
%  |                             |                      |       |
%  +-------- TRANSDUCER ---------+------ CABLES --------+- ADC -+
%
% The correction consists of several sections:
%  a) transducer with its terminals model (Zca, Zcal, Zcam, Yca)
%  b) cables to the digitizers (Zcb, Ycb)
%  c) digitizer shunting admittances Yin, lo_Yin
%
% 1) The solver first simplifies the cables+digitizers to following:
%  
%  in (RVD)
%  o-------+
%          |
%  +--+   +++
%  |  |   | | Zhi                       
%  |  |   | |                           Uhi
%         +++ Zca/2      Zca/2        ------->                
%  in      |  +----+     +----+        +----+                     
%  o-------+--+    +--+--+    +--o-----+    +---+
%  (shunt) |  +----+  |  +----+        +----+   |                
%  |  |    |          |  *   ^          Zih     |                
%  |  |   +++  +--+  +++      \         ----+   |                
%  |I1|   | |  |I2|  | | Yca   | Zcam    I3 |   |                     
%  |  |   | |  |  v  | |       |        <---+   |                
%  |  |   +++  +-    +++      /         Ulo     |              
%      Zlo |          |  *   v        ------->  |                         
%  0V      |  +----+  |  +----+        +----+   |         
%  o-------+--+    +--+--+    +--o-----+    +---+
%          |  +----+     +----+        +----+   |              
%  |  |   +++ Zcal/2     Zcal/2         Zil     |               
%  |  v   | |                    -----------+   |               
%  |      | |                         I4    |   |                      
%         +++ Zx (unknown)       <----------+   |             
%  GND     |                                    |              
%  o-------+------------------------------------+
%  ^       |                     ^              ^
%  |      +++                    |              |
%  +-------- TRANSDUCER ---------+-- CABLES ----+
%                                     +ADC
% 2) Unload the transducer from the Zca-Zcal-Yca+Zcam load.
% 3) It solves the circuit mesh by loop-current method to obtain currents I1 and I2.
% 4) It calculates the input voltage or current and the uncertainties.
%
%
% This is part of the TWM - TracePQM WattMeter.
% (c) 2018, Stanislav Maslan, smaslan@cmi.cz
% The script is distributed under MIT license, https://opensource.org/licenses/MIT.                
%

    if strcmpi(tab,'test')
        % --- run self-test:
        correction_transducer_loading_test();
        
        A = [];
        ph = [];
        u_A = [];
        u_ph = [];
        return
        
    end
    

    % is it RVD?
    is_rvd = strcmpi(tran,'rvd');
    
    % differential mode?
    is_diff = nargin >= 8;
    
    % convert inputs to vertical:
    org_orient = size(f); % remember original orientation
    f = f(:);
    A = A(:);
    ph = ph(:);
    u_A = u_A(:);
    u_ph = u_ph(:);
    if is_diff
        lo_A = lo_A(:);
        lo_ph = lo_ph(:);
        u_lo_A = u_lo_A(:);
        u_lo_ph = u_lo_ph(:);
    end
    
    % monte carlo cycles:
    mcc = 1000;
            
    % randomize high-side voltage and convert it to complex form:
    A_v = real(mcrand(2,mcc,A,u_A));
    ph_v = real(mcrand(2,mcc,ph,u_ph));    
    U = A_v.*exp(j*ph_v);
    
    % make list of involved correction tables:
    tlist = {tab.tr_gain,tab.tr_phi,tab.tr_Zlo,tab.tr_Zca,tab.tr_Yca,tab.Zcb,tab.Ycb,tab.adc_Yin};
    if is_diff        
        tlist = {tlist{:},tab.lo_adc_Yin,tab.tr_Zcal,tab.tr_Zcam};
    end
    
    % merge axes of the tables to common range:
    [tlist,rms,fx] = correction_expand_tables(tlist);

    if ~isempty(fx) && (max(f) > max(fx) || min(f) < min(fx))
        error('Transducer loading correction: Some of the involved correction tables have insufficient frequency reange!');
    end
    
    % interpolate divider's transfer, convert to complex transfer:        
    tr_gain = correction_interp_table(tlist{1},[],f);
    tr_phi = correction_interp_table(tlist{2},[],f);    
    g_org = nanmean(tr_gain.gain,2);
    p_org = nanmean(tr_phi.phi,2);        
    tr = g_org.*exp(j*p_org); % convert to complex        
    tr = repmat(tr,[1 mcc]); % expand because MATLAB < 2016b cannot broadcast so the whole calculation would be a mess of bsxfun()...
    % note the uncertainty is ignored at this point, because we don't know which 'rms' value we have yet,
    % so it will be applied at the end!               

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
    
    % interpolate ADC's input admittances:
    tmp = correction_interp_table(tlist{8},[],fx);
    [Yin,u_Yin] = CpGp2Y(fx, tmp.Cp, tmp.Gp, tmp.u_Cp, tmp.u_Gp);
    Yin = mcrand(2, mcc, Yin, u_Yin);
    
    if ~is_rvd
        % calculate Zlo for SHUNT from transfer: 
        [Zlo,u_Zlo] = Z_inv(tr,0.*tr);
    end
        
    
    if is_diff
        % =====================================
        % ========= DIFFERENTIAL MODE =========
        % =====================================
                
        % --- load additional corrections:
        % interpolate output terminals Z/Y:       
        tmp = correction_interp_table(tlist{9},[],fx);
        [Zcal,u_Zcal] = LsRs2Z(fx, tmp.Ls, tmp.Rs, tmp.u_Ls, tmp.u_Rs);
        Zcal = mcrand(2, mcc, Zcal, u_Zcal);
        
        tmp = correction_interp_table(tlist{10},[],fx);
        [Zcam,u_Zcam] = LsRs2Z(fx, tmp.M, 0.*tmp.M, tmp.u_M, 0.*tmp.M);
        Zcam = mcrand(2, mcc, Zcam, u_Zcam);
        
        % interpolate ADC's input admittances:
        tmp = correction_interp_table(tlist{11},[],fx);
        [lo_Yin,u_lo_Yin] = CpGp2Y(fx, tmp.Cp, tmp.Gp, tmp.u_Cp, tmp.u_Gp);
        Yinl = mcrand(2, mcc, lo_Yin, u_lo_Yin);
        
        
        % --- 1) Solve the cable->digitizer transfers and simplify the circuit:  
        
        % calculate transfer of the high-side cable to dig. input (in/out):
        k1 = (Yi.*Zcb + 2)./2;
        Zih = 1./(1./(1./Yi + 0.5*Zcb) + Ycb);
        k2 = (Zih + 0.5*Zcb)./Zih;
        Zih = Zih + 0.5*Zcb; % effective cable input impedance
        kih = k1.*k2; % complex cable to dig. transfer        
        
        % calculate transfer of the low-side cable to dig. input (in/out):
        k1 = (Yil.*Zcb + 2)./2;
        Zil = 1./(1./(1./Yil + 0.5*Zcb) + Ycb);
        k2 = (Zil + 0.5*Zcb)./Zil;
        Zil = Zil + 0.5*Zcb; % effective cable input impedance
        kil = k1.*k2; % complex cable to dig. transfer
        
        % apply high/low side cable transfers to the input complex voltages:        
        U = U.*kih;  
        U_lo = U_lo.*kil;
        
                        
        % --- 2) Assume the transd. was measured including the effect of the Zca-Zcal-Zcam-Yca
        %        and no external load. So unload it from the 0.5Zca-0.5Zcal+2*Zcam-Yca load:
        
        % calculate effective terminals loop impedance (series high+low side - mutual impedance):
        Zca_ef = Zca + Zcal - 2*Zcam;
        
        % Zlo unloaded by the 0.5Zca_ef-Yca shunting impedance:
        Zlo_ef = 1./(1./Zlo - 1./(0.5*Zca_ef + 1./Yca));
        
        % the complex transfer of the 0.5Zca_ef-Yca divider (out/in):
        k_ca = 2./(Yca.*Zca_ef + 2);
        
        % fix the transfer error due to the terminals loading:
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
            % for SHUNT:
            
            % relative effect of the loading to the transfer:
            k_zl = Zlo./Zlo_ef;
            
            % calculate actual, unloaded ratio of the transducer (in/out):
            tr = tr.*k_zl;
            
            % recalculate its impedance from the unloaded ratio:
            Zlo = 1./tr;
            
        end
    
        
        % --- 3) solve the circuit (the formulas come from symbolic solver):
        I1 = ((((4.*Ulo-4.*Uhi).*Yca.*Zih+4.*Uhi.*Yca.*Zcam-2.*Uhi.*Yca.*Zca-4.*Uhi).*Zil+(2.*Ulo.*Yca.*Zcal-4.*Ulo.*Yca.*Zcam).*Zih).*Zlo+(((2.*Ulo-2.*Uhi).*Yca.*Zcal+(2.*Ulo-2.*Uhi).*Yca.*Zca+4.*Ulo-4.*Uhi).*Zih+(2.*Uhi.*Yca.*Zcal+2.*Uhi.*Yca.*Zca+4.*Uhi).*Zcam-Uhi.*Yca.*Zca.*Zcal-Uhi.*Yca.*Zca.^2-4.*Uhi.*Zca).*Zil+((-2.*Ulo.*Yca.*Zcal-2.*Ulo.*Yca.*Zca-4.*Ulo).*Zcam+Ulo.*Yca.*Zcal.^2+(Ulo.*Yca.*Zca+4.*Ulo).*Zcal).*Zih)./(4.*Zih.*Zil.*Zlo);        
        I2 = (((2.*Ulo-2.*Uhi).*Yca.*Zih+2.*Uhi.*Yca.*Zcam-Uhi.*Yca.*Zca-2.*Uhi).*Zil+(Ulo.*Yca.*Zcal-2.*Ulo.*Yca.*Zcam).*Zih)./(2.*Zih.*Zil);
        
        % --- 4) calculate the input level:
        if is_rvd
            % for DIVIDER
            
            % input voltage:
            Y = I1*Zhi + (I1 - I2)*Zlo;
            
        else
            % for SHUNT:
        
            % input current:
            Y = I1;
        
        end
    
    else
        % =====================================
        % ========= SINGLE-ENDED MODE =========
        % =====================================        
        
        % --- 1) Assume the transd. was measured including the effect of the Zca-Yca
        %        and no external load. So unload it from the 0.5Zca-Yca load:
        
        % actual internal Zlo impedance:
        Zlo_int = 1./(1./(Zlo - 0.5*Zca) - Yca) - 0.5*Zca;
        
        % effective value of Zlo with 0.5Zca-Yca in parallel:
        Zlo_ef = 1./(1./Zlo_int + 1./(1./Yca + 0.5*Zca));
        
        % the complex transfer of the 0.5Zca-Yca divider (out/in):
        k_ca = 2./(Yca.*Zca + 2);
        
        % actual division ratio Zhi:Zlo_ef:
        tr = tr.*k_ca;
        
        if is_rvd
            % for RVD:
            
            % high-side impedance:        
            Zhi = Zlo_ef.*(tr - 1);
                    
            % calculate loaded transfer (in/out):
            tr = (Zlo_ef + Zhi)./Zlo_ef;
            
            % continue with the corrected low-side impedance:  
            Zlo = Zlo_int;
        
        else
            % for Shunt:
            
            % recalculate its impedance from the unloaded ratio:
            Zlo = 1./tr;
            
            % subtract admittance of the connector (0.5*Zca-Yca)
            Zlo = 1./(1./Zlo - 1./(0.5*Zca + 1./Yca));
                        
        end
           
        
        % --- 2) Calculate total impedance loading of the Zlo:
          
        % cable-to-digitizer tfer (in/out):
        k_in = (Yin.*Zcb + 2)/2;
        % (ZL+0.5*Zcb)||Ycb (temp value):
        Zx = 1./(Ycb + 1./(1./Yin + 0.5*Zcb));
        % terminal-to-cable tfer (in/out):
        k_cb = (0.5*Zcb + 0.5*Zca + Zx)./Zx;
        % (0.5*Zca+0.5*Zcb+Zx)||Yca (temp value):
        Zx = 1./(Yca + 1./(Zx + 0.5*Zca + 0.5*Zcb));
        % tranfer transducer-terminal (in/out):
        k_te = (Zx + 0.5*Zca)./Zx;
        
        % calculate loaded low-side impedance:
        Zlo_ef = 1./(1./Zlo + 1./(Zx + 0.5*Zca));
        
        if is_rvd
            % RVD:
            
            tr = (Zhi + Zlo_ef)./Zlo_ef;
            
        else
            % correct the transfer by the total load effect (in/out):
            
            tr = 1./Zlo_ef;
            
        end
          
        
        % --- 3) Apply tfer of the whole terminal-cable-digitizer chain to the trans. tfer:    
        tr = tr.*k_in.*k_cb.*k_te;
        
        % --- 4) Calculate input level:
        Y = U.*tr;
        
    end
    
    
    % convert input signal level back to the polar form:
    A = abs(Y);
    ph = arg(Y);
     
    % --- evaluate Monte-Carlo data:    
    % note: I don't use mean of the randomized data to avoid noisy result.
    %       Instead I use first item of noisified quantities which is original without noise,
    %       see mcrand().
    % absolute uncertainty:
    u_A = std(A,[],2);    
    u_ph = std(ph,[],2);                 
    % mean relative loading correction factor (see mcrand() function to understand):
    A = A(:,1);
    ph = ph(:,1);
    
    % estimate input RMS value (assuming the input frequency range covers all dominant harmonics):
    rms = sum(0.5*A.^2).^0.5;
            
    % get final transducer transfer corrections, this time with the rms value estimation: 
    tr_gain = correction_interp_table(tab.tr_gain,rms,f,'f',1);
    tr_phi = correction_interp_table(tab.tr_phi,rms,f,'f',1);
    
    % fix the calculated input levels by the final transfer of the tran.:
    A = A.*tr_gain.gain./g_org;
    ph = ph + tr_phi.phi - p_org;
    
    % get abs. uncertainties of the final transducer correction:
    u_trg = A.*tr_gain.u_gain;
    u_trp = tr_phi.u_phi;
    
    % combine the tran. tfer. uncertainty with the calculated input levels:
    u_A = (u_A.^2 + u_trg.^2).^0.5;
    u_ph = (u_ph.^2 + u_trp.^2).^0.5;
    
    
    % restore original vector orientations:
    A = reshape(A,org_orient);
    ph = reshape(ph,org_orient);
    u_A = reshape(u_A,org_orient);    
    u_ph = reshape(u_ph,org_orient);
            
    
    % job complete and we are outahere...

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
    if any(abs(z./z2-1) > 1e-6) || any(abs(uz./uz2-1) > 0.01)
        error('Z_inv() does not work!');
    end
    
    % test Z-phi to cplx(Z) and cplx(Z) to Z-phi covertor:
    m =  [1     ; 10];
    um = [1e-6  ; 100e-6];
    p =  [0.1   ; 1e-3];
    up = [100e-6; 1e-6];        
    [z,uz] = Zphi2Z(m,p,um,up);
    [m2,p2,um2,up2] = Z2Zphi(z,uz);
    %if any(abs(m./m2-1) > 1e-6) || any(abs(p./p2-1) > 1e-6) || any(abs(um./um2-1) > 0.02) || any(abs(up./up2-1) > 0.02)
    %    error('Z2ZPhi() or Zphi2Z() does not work!');
    %end
    
    clear all;
    
    
    % define test configurations:
    
    id = 1; % test 1:
    cfg{id}.is_rvd = 1;
    cfg{id}.is_diff = 0;
    cfg{id}.Rlo = 200;
    cfg{id}.D = 10;
    cfg{id}.label = 'SE, RVD test ...';
    
    id = id + 1; % test 2:
    cfg{id}.is_rvd = 0;
    cfg{id}.is_diff = 0;
    cfg{id}.Rlo = 20;
    cfg{id}.label = 'SE, shunt test ...';
    
        
    for c = 1:numel(cfg)
    
        % setup for current test:
        s = cfg{c};
        
        disp(s.label);
    
        % frequency range of the simulation:
        F = 10;
        f = [];
        f(:,1) = logspace(log10(10),log10(1e6),F);
        w = f*2*pi;
        
        % generate some spectrum:
        A = ones(size(f));
        ph = zeros(size(f));
        u_A = 0*A;
        u_ph = 0*ph;
            
        % rms range of the transd. transfers:
        rms = [];
        rms(1,:) = [0 3 5];
        R = numel(rms);
        
        % define low side impedance Cp+Rp:
        Rlo = s.Rlo;
        Clo = 50e-12;
        Zlo = 1./(1/Rlo + j*w*Clo);
        
        % nominal DC ratio of the transducer (in/out):
        if s.is_rvd
            D = s.D;
        else
            D = 0;
        end
        
        if s.is_rvd
            % RVD high side parallel capacitance:
            Chi = Clo/(D-1);
            
            % RVD calculate high side impedance:
            Zhi = 1./(1/((D - 1)*Rlo) + j*w*Chi);
        else
            % no high-side resistor for shunt mode:
            Zhi = repmat(1e-15,[F 1]);
        end
        
        % define low return path series impedance (diff mode only):
        Rr = 1;
        Lr = 5e-6;
        Zx = Rr + j*w*Lr;
        
        % define terminals impedances:
        Ls_a = 1000e-9;
        Rs_a = 50e-3;
        Cp_a = 100e-12;
        D_a = 0.01;
        Zca = Rs_a + j*w*Ls_a;
        Yca = w*Cp_a*(j + D_a);
        % low-side:
        Zcal = 1.2*Zca;
        % mutual:
        Ma = 300e-9;
        Zcam = j*w*Ma;
                
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
        Yinl = Yin;
        Zin = 1./Yin;
        Zinl = 1./Yinl;
        
        % calculate effective value of the Zlo when loaded by 0.5*Zca-Yca:
        Zlo_ef = 1./(1./Zlo + 1./(1./Yca + 0.5*Zca));
                
        % transfer of the terminals 0.5*Zca-Yca (in/out):
        k_te = (Yca.*Zca + 2)./2;
        
        % calculate measurable low side impedance (measured via the output terminals):
        % note: this is what user will measure when doing calibration
        Zlo_meas = 1./(1./(Zlo + 0.5*Zca) + Yca) + 0.5*Zca;
        
        % calculate effective transfer from input to transducer terminals (in/out):
        % note: this is what user will measure when doing calibration
        if s.is_rvd
            k_ef = (Zlo_ef + Zhi)./Zlo_ef.*k_te;
        else
            k_ef = 1./Zlo_ef.*k_te;
        end
          
        % type of the transducer (control string for the corr. function):
        tran = {'shunt','rvd'};
        tran = tran{1 + s.is_rvd};                
        
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
        tab.tr_gain = correction_load_table({f,rms,g,u_g},'rms',{'f','gain','u_gain'});
        tab.tr_phi = correction_load_table({f,rms,p,u_p},'rms',{'f','phi','u_phi'});
        
        U = ones(F,1);
        
        % build RVD's low-side impedance table:
        tab.tr_Zlo = correction_load_table({f,1./real(1./Zlo_meas),imag(1./Zlo_meas)./w,0*U,0*U},'',{'f','Rp','Cp','u_Rp','u_Cp'});
        
        % build terminal tables:    
        tab.tr_Zca = correction_load_table({f,real(Zca),imag(Zca)./w,0*U,0*U},'',{'f','Rs','Ls','u_Rs','u_Ls'});
        tab.tr_Yca = correction_load_table({f,imag(Yca)./w,real(Yca)./imag(Yca),0*U,0*U},'',{'f','Cp','D','u_Cp','u_D'});
        tab.tr_Zcal = correction_load_table({f,real(Zcal),imag(Zcal)./w,0*U,0*U},'',{'f','Rs','Ls','u_Rs','u_Ls'}); % low-side
        tab.tr_Zcam = correction_load_table({f,imag(Zcam)./w,0*U},'',{'f','M','u_M'}); % mutual
        
        % build cable tables:
        tab.Zcb = correction_load_table({f,real(Zcb),imag(Zcb)./w,0*U,0*U},'',{'f','Rs','Ls','u_Rs','u_Ls'});
        tab.Ycb = correction_load_table({f,imag(Ycb)./w,real(Ycb)./imag(Ycb),0*U,0*U},'',{'f','Cp','D','u_Cp','u_D'});
    
        % digitizer's input impedance:
        tab.adc_Yin = correction_load_table({f,imag(Yin)./w,real(Yin),0*U,0*U},'',{'f','Cp','Gp','u_Cp','u_Gp'});
        tab.lo_adc_Yin = correction_load_table({f,imag(Yinl)./w,real(Yinl),0*U,0*U},'',{'f','Cp','Gp','u_Cp','u_Gp'}); % low-side
        
        
        
        % --- now the fun part - exact forward solution ---
        
        % move frequency dependence to the third dim:
        Zhi  = reshape(Zhi,[1,1,F]);
        Zlo  = reshape(Zlo,[1,1,F]);
        Zin  = reshape(Zin,[1,1,F]);
        Zinl = reshape(Zinl,[1,1,F]);
        Zca  = reshape(Zca,[1,1,F]);
        Yca  = reshape(Yca,[1,1,F]);
        Zcal = reshape(Zcal,[1,1,F]);
        Zcam = reshape(Zcam,[1,1,F]);
        Zcb  = reshape(Zcb,[1,1,F]);
        Ycb  = reshape(Ycb,[1,1,F]);
        Zx   = reshape(Zx,[1,1,F]);
        Z    = zeros(size(Zhi));
        
        if s.is_diff
            % --- diff mode:
            
            % simplify the cable->digitizer joints (step 1):
            Zih = 1./(1./(Zin + 0.5*Zcb) + Ycb);
            Zil = 1./(1./(Zinl + 0.5*Zcb) + Ycb);
            tfh = Zih./(Zih + 0.5*Zcb).*Zin./(Zin + 0.5*Zcb);
            tfl = Zil./(Zil + 0.5*Zcb).*Zinl./(Zinl + 0.5*Zcb);
            Zih = Zih + 0.5*Zcb;
            Zil = Zil + 0.5*Zcb;
                        
            % loop-currents matrix:
            L = [ Zhi+Zlo+Zx      -Zlo                              Z                                       -Zx              ;
                 -Zlo              Zlo+1./Yca+0.5*Zca+0.5*Zcal     -1./Yca                                  -0.5*Zcal        ;
                  Z               -1/Yca                            1./Yca+0.5*Zca+0.5*Zcal+Zih+Zil-2*Zcam  -Zcal/2-Zil+Zcam ;
                 -Zx              -0.5*Zcal                        -0.5*Zcal-Zil+Zcam                        Zx+Zcal+Zil    ];
                 
                 
                                         
        
        else
            % --- single-ended mode:
                
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
            
            % forward transfer (out/in):
            if s.is_rvd
                tfer = I(4,:)(:).*Zin(:);
            else
                tfer = I(4,:)(:).*Zin(:)./I(1,:)(:);
            end
            
        end
        
        % extract magnitude and phase:
        A_in = A.*abs(tfer);
        ph_in = ph + arg(tfer);
        
        % --- apply the loading correction to obtain original signal:
        [Ax,phx] = correction_transducer_loading(tab,tran,f,A_in,ph_in,0*A_in,0*ph_in);

        % check correctness of the calculation    
        assert(any(abs(Ax./A - 1) < 1e-6),[s.label ' gain not matching!']);
        assert(any(abs(phx - ph) < 1e-6),[s.label ' phase not matching!']);
        
        disp(' ... ok.');
    
    end
    
    
    


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

