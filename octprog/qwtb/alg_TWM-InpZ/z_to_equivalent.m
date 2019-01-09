% Conversion of complex Z to equivalent circuit and vice versa
%  1) with no parameters returns list of available equ. cct
%  2) with 4 parameters converts Z to equ. cct
%  3) with 8 parameters converts equ. cct to complex Z
%
function [res,ecct] = z_to_equivalent(cct,f,Z,uZ,mjr,mnr,umjr,umnr)  
  
  ecct = [];
  
  if(~nargin)
    % --- enumerate options ---
    
    % list of equivalant circuits
    ecct = {
       'Rs','Ohm','Xs','Ohm','%_7p','%_7p';
       'Gp','S','Bp','S','%_7p','%_7p';
       'Z','Ohm','phid','deg','%_7p','%.5f';
       'Z','Ohm','phir','rad','%_7p','%.7f';
       'Y','S','phid','deg','%_7p','%.5f';
       'Y','S','phir','rad','%_7p','%.7f';
       'Cp','F','D','-','%_7p','%.7f';
       'Cp','F','Q','-','%_7p','%_6f';
       'Cp','F','Rp','Ohm','%_7p','%_7p';
       'Cp','F','Gp','S','%_7p','%_7p';
       'Cs','F','D','-','%_7p','%.7f';
       'Cs','F','Q','-','%_7p','%_6f';
       'Cs','F','Rs','Ohm','%_7p','%_7p';
       'Ls','H','Rs','Ohm','%_7p','%_7p';
       'Ls','H','Q','-','%_7p','%_6f',
       'Rs','Ohm','tau','s','%_7p','%_5p'};
    
    % --- no to covnert the list into compact form
    % get string lengths   
    lens = cellfun(@length,ecct,'UniformOutput',true);
         
    % combine into single string
    item = {'mjr','umjr','mnr','umnr','fmjr','fmnr'}; 
    res = struct();
    for k = 1:numel(item)
      res = setfield(res,item{k},ecct(:,k));
      res = setfield(res,[item{k} 'c'],[ecct{:,k}]);
      res = setfield(res,[item{k} 'd'],lens(:,k));      
    end
  
  elseif(nargin == 4)
    % --- convert Zx to desired equivalent circuit ---
    
    Rs = real(Z);
    Xs = imag(Z);
    uRs = real(uZ);
    uXs = imag(uZ);
    w = 2*pi*f;
    
    switch(cct)
      case 0
        % Rs-Xs
        mjr = Rs; 
        mnr = Xs;
        umjr = abs(uRs);
        umnr = abs(uXs);

      case 1
        % Gp-Bp
        mjr = Rs./(Rs.^2 + Xs.^2);
        mnr = -Xs./(Rs.^2 + Xs.^2);     
        umjr = sqrt(4*Rs.^2.*Xs.^2.*uXs.^2+(Xs.^4-2*Rs.^2.*Xs.^2+Rs.^4).*uRs.^2)./(Xs.^4+2*Rs.^2.*Xs.^2+Rs.^4);
        umnr = sqrt((Xs.^4-2*Rs.^2.*Xs.^2+Rs.^4).*uXs.^2+4*Rs.^2.*Xs.^2.*uRs.^2)./(Xs.^4+2*Rs.^2.*Xs.^2+Rs.^4);
                
      case 2
        % Z-phi [deg]
        mjr = (Rs.^2 + Xs.^2).^0.5;
        mnr = atan2(Xs,Rs)*180/pi;
        umjr = (Xs.^2.*uXs.^2+Rs.^2.*uRs.^2).^0.5./(Xs.^2+Rs.^2).^0.5;
        umnr = (Rs.^2.*uXs.^2+Xs.^2.*uRs.^2).^0.5./(Xs.^4+2*Rs.^2.*Xs.^2+Rs.^4).^0.5*180/pi;        
                
      case 3
        % Z-phi [rad]
        mjr = (Rs.^2 + Xs.^2).^0.5;
        mnr = atan2(Xs,Rs);
        umjr = (Xs.^2.*uXs.^2+Rs.^2.*uRs.^2).^0.5./(Xs.^2+Rs.^2).^0.5;
        umnr = (Rs.^2.*uXs.^2+Xs.^2.*uRs.^2).^0.5./(Xs.^4+2*Rs.^2.*Xs.^2+Rs.^4).^0.5;        

      case 4
        % Y-phi [deg]
        mjr = (Rs.^2 + Xs.^2).^-0.5;
        mnr = atan2(-Xs,Rs)*180/pi;
        umjr = (Xs.^2.*uXs.^2+Rs.^2.*uRs.^2).^0.5./(Xs.^6+3*Rs.^2.*Xs.^4+3*Rs.^4.*Xs.^2+Rs.^6).^0.5;
        umnr = (Rs.^2.*uXs.^2+Xs.^2.*uRs.^2).^0.5./(Xs.^4+2*Rs.^2.*Xs.^2+Rs.^4).^0.5*180/pi;
                
      case 5
        % Y-phi [rad]
        mjr = (Rs.^2 + Xs.^2).^-0.5;
        mnr = atan2(-Xs,Rs);
        umjr = (Xs.^2.*uXs.^2+Rs.^2.*uRs.^2).^0.5./(Xs.^6+3*Rs.^2.*Xs.^4+3*Rs.^4.*Xs.^2+Rs.^6).^0.5;
        umnr = (Rs.^2.*uXs.^2+Xs.^2.*uRs.^2).^0.5./(Xs.^4+2*Rs.^2.*Xs.^2+Rs.^4).^0.5;

      case 6
        % Cp-D
        mjr = -Xs./(Rs.^2 + Xs.^2)./w;
        mnr = -Rs./Xs;
        umjr = ((Xs.^4-2*Rs.^2.*Xs.^2+Rs.^4).*uXs.^2+4*Rs.^2.*Xs.^2.*uRs.^2).^0.5./(w.^2.*Xs.^8+4*Rs.^2.*w.^2.*Xs.^6+6*Rs.^4.*w.^2.*Xs.^4+4*Rs.^6.*w.^2.*Xs.^2+Rs.^8.*w.^2).^0.5;
        umnr = (Rs.^2.*uXs.^2+Xs.^2.*uRs.^2).^0.5./abs(Xs).^2.0;
                
      case 7
        % Cp-Q
        mjr = -Xs./(Rs.^2 + Xs.^2)./w;
        mnr = -Xs./Rs;
        umjr = ((Xs.^4-2*Rs.^2.*Xs.^2+Rs.^4).*uXs.^2+4*Rs.^2.*Xs.^2.*uRs.^2).^0.5./(w.^2.*Xs.^8+4*Rs.^2.*w.^2.*Xs.^6+6*Rs.^4.*w.^2.*Xs.^4+4*Rs.^6.*w.^2.*Xs.^2+Rs.^8.*w.^2).^0.5;
        umnr = (Rs.^2.*uXs.^2+Xs.^2.*uRs.^2).^0.5./abs(Rs).^2.0;
        
      case 8
        % Cp-Rp
        mjr = -Xs./(Rs.^2 + Xs.^2)./w;
        mnr = 1./(Rs./(Rs.^2 + Xs.^2));
        umjr = ((Xs.^4-2*Rs.^2.*Xs.^2+Rs.^4).*uXs.^2+4*Rs.^2.*Xs.^2.*uRs.^2).^0.5./(w.^2.*Xs.^8+4*Rs.^2.*w.^2.*Xs.^6+6*Rs.^4.*w.^2.*Xs.^4+4*Rs.^6.*w.^2.*Xs.^2+Rs.^8.*w.^2).^0.5;
        umnr = (4*Rs.^2.*Xs.^2.*uXs.^2+(Xs.^4-2*Rs.^2.*Xs.^2+Rs.^4).*uRs.^2).^0.5./abs(Rs).^2.0; 
        
      case 9
        % Cp-Gp
        mjr = -Xs./(Rs.^2 + Xs.^2)./w;
        mnr = Rs./(Rs.^2 + Xs.^2);
        umjr = ((Xs.^4-2*Rs.^2.*Xs.^2+Rs.^4).*uXs.^2+4*Rs.^2.*Xs.^2.*uRs.^2).^0.5./(w.^2.*Xs.^8+4*Rs.^2.*w.^2.*Xs.^6+6*Rs.^4.*w.^2.*Xs.^4+4*Rs.^6.*w.^2.*Xs.^2+Rs.^8.*w.^2).^0.5;
        umnr = (4*Rs.^2.*Xs.^2.*uXs.^2+(Xs.^4-2*Rs.^2.*Xs.^2+Rs.^4).*uRs.^2).^0.5./(Xs.^8+4*Rs.^2.*Xs.^6+6*Rs.^4.*Xs.^4+4*Rs.^6.*Xs.^2+Rs.^8).^0.5; 
        
      case 10
        % Cs-D
        mjr = -1./Xs./w;
        mnr = -Rs./Xs;
        umjr = abs(uXs)./(abs(w).^1.0.*abs(Xs).^2.0);
        umnr = (Rs.^2.*uXs.^2+Xs.^2.*uRs.^2).^0.5./abs(Xs).^2.0; 
        
      case 11
        % Cs-Q
        mjr = -1./Xs./w;
        mnr = -Xs./Rs;
        umjr = abs(uXs)./(abs(w).^1.0.*abs(Xs).^2.0);
        umnr = (Rs.^2.*uXs.^2+Xs.^2.*uRs.^2).^0.5./abs(Rs).^2.0; 
              
      case 12
        % Cs-Rs
        mjr = -1./Xs./w;
        mnr = Rs;
        umjr = abs(uXs)./(abs(w).^1.0.*abs(Xs).^2.0);
        umnr = abs(uRs); 
        
      case 13
        % Ls-Rs
        mjr = Xs./w;
        mnr = Rs;
        umjr = abs(uXs)./abs(w).^1.0;
        umnr = abs(uRs); 
                
      case 14
        % Ls-Q
        mjr = Xs./w;
        mnr = Xs./Rs;
        umjr = abs(uXs)./abs(w).^1.0;
        umnr = (Rs.^2.*uXs.^2+Xs.^2.*uRs.^2).^0.5./abs(Rs).^2.0;
        
      case 15
        % Rs-tau
        mjr = Rs;
        mnr = Xs./(w.*Rs);
        umjr = abs(uRs);
        umnr = (Rs.^2.*uXs.^2+Xs.^2.*uRs.^2).^0.5./(abs(Rs).^2.0.*abs(w));
        
    end
    
    % fix uncertainty vector lengths to match mean values vector length 
    if(numel(umjr) == 1)
      umjr = repmat(umjr,size(mjr));
    end
    if(numel(umnr) == 1)
      umnr = repmat(umnr,size(mnr));
    end
    
    % return converted equivalent model
    res.mjr = mjr;
    res.mnr = mnr;
    res.umjr = umjr;
    res.umnr = umnr;
  
  
  elseif(nargin == 8)
    % --- convert desired equivalent circuit to Zx ---
       
    w = 2*pi*f;
    
    switch(cct)
      case 0
        % Rs-Xs
        Rs = mjr;
        Xs = mnr;
        uRs = abs(umjr);
        uXs = abs(umnr);

      case 1
        % Gp-Bp
        Rs = mjr./(mjr.^2 + mnr.^2);
        Xs = -mnr./(mjr.^2 + mnr.^2);                
        uRs = sqrt(4*mjr.^2.*mnr.^2.*umnr.^2+(mnr.^4-2*mjr.^2.*mnr.^2+mjr.^4).*umjr.^2)./(mnr.^4+2*mjr.^2.*mnr.^2+mjr.^4);
        uXs = sqrt((mnr.^4-2*mjr.^2.*mnr.^2+mjr.^4).*umnr.^2+4*mjr.^2.*mnr.^2.*umjr.^2)./(mnr.^4+2*mjr.^2.*mnr.^2+mjr.^4);
                
      case 2
        % Z-phi [deg]
        mnr = mnr/180*pi;
        umnr = umnr/180*pi;
        Rs = mjr.*cos(mnr);
        Xs = mjr.*sin(mnr);
        uRs = sqrt(mjr.^2.*sin(mnr).^2.*umnr.^2 + cos(mnr).^2.*umjr.^2);
        uXs = sqrt(mjr.^2.*cos(mnr).^2.*umnr.^2 + sin(mnr).^2.*umjr.^2);        
                
      case 3
        % Z-phi [rad]
        Rs = mjr.*cos(mnr);
        Xs = mjr.*sin(mnr);
        uRs = sqrt(mjr.^2.*sin(mnr).^2.*umnr.^2 + cos(mnr).^2.*umjr.^2);
        uXs = sqrt(mjr.^2.*cos(mnr).^2.*umnr.^2 + sin(mnr).^2.*umjr.^2);        

      case 4
        % Y-phi [deg]
        mnr = mnr/180*pi;
        umnr = umnr/180*pi;
        Rs = 1./mjr.*cos(mnr);
        Xs = 1./mjr.*sin(-mnr);
        uRs = sqrt(mjr.^2.*sin(mnr).^2.*umnr.^2 + cos(mnr).^2.*umjr.^2)./mjr.^2;
        uXs = sqrt(mjr.^2.*cos(mnr).^2.*umnr.^2 + sin(mnr).^2.*umjr.^2)./mjr.^2;
                
      case 5
        % Y-phi [rad]
        Rs = 1./mjr.*cos(mnr);
        Xs = 1./mjr.*sin(-mnr);
        uRs = sqrt(mjr.^2.*sin(mnr).^2.*umnr.^2 + cos(mnr).^2.*umjr.^2)./mjr.^2;
        uXs = sqrt(mjr.^2.*cos(mnr).^2.*umnr.^2 + sin(mnr).^2.*umjr.^2)./mjr.^2;

      case 6
        % Cp-D
        Rs = mnr./((mjr.*mnr.^2+mjr).*w);
        Xs = -1./((mjr.*mnr.^2+mjr).*w);
        uRs = sqrt((mjr.^2.*mnr.^4-2.*mjr.^2.*mnr.^2+mjr.^2).*umnr.^2+(mnr.^6+2.*mnr.^4+mnr.^2).*umjr.^2)./((mjr.^2.*mnr.^4+2.*mjr.^2.*mnr.^2+mjr.^2).*abs(w));
        uXs = sqrt(4.*mjr.^2.*mnr.^2.*umnr.^2+(mnr.^4+2.*mnr.^2+1).*umjr.^2)./((mjr.^2.*mnr.^4+2.*mjr.^2.*mnr.^2+mjr.^2).*abs(w));
                        
      case 7
        % Cp-Q
        Rs = mnr./((mjr.*mnr.^2+mjr).*w);
        Xs = -mnr.^2./((mjr.*mnr.^2+mjr).*w);
        uRs = sqrt((mjr.^2.*mnr.^4-2.*mjr.^2.*mnr.^2+mjr.^2).*umnr.^2+(mnr.^6+2.*mnr.^4+mnr.^2).*umjr.^2)./((mjr.^2.*mnr.^4+2.*mjr.^2.*mnr.^2+mjr.^2).*abs(w));
        uXs = (mnr.*sqrt(4.*mjr.^2.*umnr.^2+(mnr.^6+2.*mnr.^4+mnr.^2).*umjr.^2))./((mjr.^2.*mnr.^4+2.*mjr.^2.*mnr.^2+mjr.^2).*abs(w));
        
      case 8
        % Cp-Rp
        Rs = mnr./(mjr.^2.*mnr.^2.*w.^2+1);
        Xs = -(mjr.*mnr.^2.*w)./(mjr.^2.*mnr.^2.*w.^2+1);
        uRs = sqrt((mjr.^4.*mnr.^4.*umnr.^2+4.*mjr.^2.*mnr.^6.*umjr.^2).*w.^4-2.*mjr.^2.*mnr.^2.*umnr.^2.*w.^2+umnr.^2)./(mjr.^4.*mnr.^4.*w.^4+2.*mjr.^2.*mnr.^2.*w.^2+1);
        uXs = (mnr.*w.*sqrt(mjr.^4.*mnr.^6.*umjr.^2.*w.^4-2.*mjr.^2.*mnr.^4.*umjr.^2.*w.^2+4.*mjr.^2.*umnr.^2+mnr.^2.*umjr.^2))./(mjr.^4.*mnr.^4.*w.^4+2.*mjr.^2.*mnr.^2.*w.^2+1); 
        
      case 9
        % Cp-Gp
        Rs = mnr./(mjr.^2.*w.^2+mnr.^2);
        Xs = -(mjr.*w)./(mjr.^2.*w.^2+mnr.^2);        
        uRs = sqrt((mjr.^4.*umnr.^2+4.*mjr.^2.*mnr.^2.*umjr.^2).*w.^4-2.*mjr.^2.*mnr.^2.*umnr.^2.*w.^2+mnr.^4.*umnr.^2)./(mjr.^4.*w.^4+2.*mjr.^2.*mnr.^2.*w.^2+mnr.^4);
        uXs = (w.*sqrt(mjr.^4.*umjr.^2.*w.^4-2.*mjr.^2.*mnr.^2.*umjr.^2.*w.^2+4.*mjr.^2.*mnr.^2.*umnr.^2+mnr.^4.*umjr.^2))./(mjr.^4.*w.^4+2.*mjr.^2.*mnr^2.*w.^2+mnr.^4);
        
      case 10
        % Cs-D
        Rs = mnr./(mjr.*w);
        Xs = -1./(mjr.*w);
        uRs = sqrt(mjr.^2.*umnr.^2+mnr.^2.*umjr.^2)./(mjr.^2.*abs(w));
        uXs = abs(umjr)./(mjr.^2.*abs(w)); 
        
      case 11
        % Cs-Q
        Rs = 1./(mjr.*mnr.*w);
        Xs = -1./(mjr.*w);
        uRs = sqrt(mjr.^2.*umnr.^2+mnr.^2.*umjr.^2)./(mjr.^2.*abs(w));
        uXs = abs(umjr)./(mjr.^2.*abs(w)); 
              
      case 12
        % Cs-Rs
        Rs = mnr;
        Xs = -1./(mjr.*w);
        uRs = abs(umnr);
        uXs = abs(umjr)./(mjr.^2.*abs(w));
        
      case 13
        % Ls-Rs        
        Rs = mnr;
        Xs = mjr.*w;
        uRs = abs(umnr);
        uXs = abs(umjr).*abs(w);
                
      case 14
        % Ls-Q
        Rs = mjr.*w./mnr;
        Xs = mjr.*w;
        uRs = (sqrt(mjr.^2.*umnr.^2+mnr.^2.*umjr.^2).*abs(w))./mnr.^2;
        uXs = abs(umjr).*abs(w);
        
      case 15
        % Rs-tau
        Rs = mjr;
        Xs = mjr.*mnr.*w;
        uRs = abs(umjr);
        uXs = (mjr.^2.*umnr.^2+mnr.^2.*umjr.^2).^0.5.*abs(w);
        
    end
        
    % combine components
    Z = complex(Rs,Xs);
    uZ = complex(uRs,uXs);
    
    % fix uncertainty vector lengths to match mean values vector length 
    if(numel(Z) == 1)
      Z = repmat(Z,size(mjr));
    end
    if(numel(uZ) == 1)
      uZ = repmat(uZ,size(mjr));
    end
    
    % return converted equivalent model
    res.Z = Z;
    res.uZ = uZ;  
    
  else
    error('Impedance conversion to/from equivalnet circuit failed!');    
  end
end