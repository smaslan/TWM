function [] = thd_plot_spectrum(res,gendoc,filenameprefix)

  if ~exist('filenameprefix','var')
      filenameprefix = 'THD_plot';
  end

  %% load stuff to display
  f = res.f;
  sig = res.sig;
  %noise = res.noise;
  f_lst = res.f_lst;
  a_lst = res.a_lst;
  a_lst_a = res.a_lst_a;
  a_lst_b = res.a_lst_b;
  a_noise = res.a_noise;
  a_lst_c = res.a_comp_lst;
  k1 = res.k1_comp; 
  k1_a = res.k1_comp_a;
  k1_b = res.k1_comp_b;
    
  %% limit signal spectrum to harmonics range
  frng = f_lst(end) - f_lst(1); 
  f_start = max(0,f_lst(1) - (f_lst(2) - f_lst(1)));
  f_stop = f_lst(end) + (f_lst(end) - f_lst(end-1));
  idx = find(f<=f_stop & f>=f_start);
  f_disp = f(idx);
  a_disp = sig(idx);
  %n_disp = noise(idx); 
  
  % limit amplitude
  a_stop = max(sig);
  a_stop = 10^ceil(log10(1.1*a_stop));
  
  a_start = min(sig);
  %if(max(noise)>1e-10)
  %  a_start = min(a_start,min(noise));
  %endif
  a_start = 10^floor(log10(0.5*a_start));
  
      
  figure;
  % total spectrum
  semilogy(f_disp,a_disp,'Color',[0.2 0.4 1.0],'LineWidth',1);
  hold on;
  % ADC noise profile
  %plot(f_disp,n_disp,'Color',[0.7 0.7 0.7],'LineWidth',1);
  % hamornics
  plot(f_lst,a_lst,'r.','LineWidth',2,'MarkerSize',10);
  
  % corrected hamornics
  plot(f_lst,a_lst_c,'kx','LineWidth',2,'MarkerSize',4);
  
  % draw mean noise lines
  if(isfield(res,'f_noise'))
    f_noise = res.f_noise; 
    mx = [f_noise(:,1:2);f_noise(:,3:4)];
    my = bsxfun(@times,[a_noise;a_noise],ones(size(mx)));
    plot(mx',my','Color',[0 0.5 0],'LineWidth',4);    
  end
     
  xlim_v = xlim();
  axis([xlim_v(1) f_stop a_start a_stop]);
  
  mx = [f_lst f_lst]';
    
  % error bars
  if(numel(a_lst))
    %my = max(ylim()(1)*1.02,[a_lst_a a_lst_b]');
    %plot(mx,my,'k-+','LineWidth',1);
    ylim_v = ylim();
    my = max(ylim_v(1)*1.02,a_lst_a);
    %h = errorbar(mx(1,1:end),a_lst,(a_lst-my),(a_lst_b-a_lst),'~k.');
    h = errorbar(mx(1,1:end),a_lst,(a_lst-my),(a_lst_b-a_lst),'k.');
    %h = errorbar(mx(1,1:end),a_lst,(a_lst-my),(a_lst_b-a_lst));
    set(h,'Marker','none');  
    set(h,'LineWidth',2);
  end
  
  % hamornics (lines)  
  ylim_v = ylim();
  my = [ones(1,length(a_lst))*ylim_v(1)*1.02;a_lst'];
  %plot(mx,my,'r','LineWidth',2);
   
  %% build title
  % file name
  tit = [str_insert_escapes(conv_title_str(filenameprefix))];
  tit = [tit ', k_1 = ' unc2str(k1,[k1_a-k1 k1_b-k1],'% noise leak. compens.')];
    
  hold off;
  title(tit); %,'interpreter','none'
  xlabel('f [Hz]');
  ylabel('U [V]');
  grid on;
  box on;
  legend('Signal spectrum','Harmonics','Corrected Harmonics','Near noise level');
  %legend('Signal spectrum','ADC noise level','Harmonics','Corrected Harmonics');
  
  % convert xtick labels to SI
  xt = get(gca,'xtick');
  xt_label = num2cell(get(gca,'xticklabel'));
  for k = 1:length(xt)
    if(xt(k) >= 1e6)
      xt_label{k} = [num2str(xt(k)/1e6,'%g') 'M'];
    elseif(xt(k) >= 1e3)
      xt_label{k} = [num2str(xt(k)/1e3,'%g') 'k'];
    else
      xt_label{k} = num2str(xt(k),'%g');
    end
  end
  set(gca,'xticklabel',xt_label);
  
  %% export?
  if(gendoc >= 1)
    ptype = {'','-dpng','-dpdf'};
    suftype = {'','.png','.pdf'};
    fpath = [filenameprefix suftype{gendoc+1}];
    
    %% don't know why, but some on instalations print (or GhostScript) requires escapification of ' ' character,
    %% on some versions it requires adding ['"' path '"']
    %% so both versions are used with try catch to prevent errors
    fpath_ver = {print_esc_path(fpath),['"' fpath '"']};
    for k = 1:length(fpath_ver)
      
      % remove old file
      if(exist(fpath,'file'))
        [err,msg] = unlink(fpath);
        if(err~=0)
          error(['Can''t write spectrum image ''' fpath '''! File is probaly opened by another application.']);
        end
      end
        
      try          
        % try generate new image
        print(fpath_ver{k},'-S720,420','-F:7',ptype{gendoc+1});         
        %print(fpath_ver{k},'-S640,410','-F:7',ptype{gendoc+1});
      catch
        % something fucked up, try another method?
        if(k<length(fpath_ver))
          % yaha
          continue;
        else
          % nope
          error('Can''t generate spectrum image!');
        end             
      end
      
      % was the file actually generated?
      if(exist(fpath,'file'))
        % yaha, job complete
        break;
      end
    end
  end
  
end

function [str] = conv_title_str(str)
  str(find(str=='\')) = '/';
end