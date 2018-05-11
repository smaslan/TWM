%% Copyright (C) 2012 Martin Å Ã­r
%%
%% This program is free software; you can redistribute it and/or modify
%% it under the terms of the GNU General Public License as published by
%% the Free Software Foundation; either version 2 of the License, or
%% (at your option) any later version.
%%
%% This program is distributed in the hope that it will be useful,
%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%% GNU General Public License for more details.
%%
%% You should have received a copy of the GNU General Public License
%% along with this program; If not, see <http://www.gnu.org/licenses/>.

%% -*- texinfo -*-
%% @deftypefn {Function File} {[@var{sloci}, @var{sqL}, @var{sqR}] =} scovint (@var{data}, @var{cp}, [ @var{verbose} ] )
%% Calculates shortest coverage interval for given coverage 
%% probability cp from vector of samples of distribution. 
%% The interval can be asymmetric. Thus the output is uncertainty
%% according to Evaluation of measurement data - Supplement 1 
%% to the "Guide to the expression of uncertainty in measurement"
%% - Propagation of distributions using a Monte Carlo method, JCGM, 
%% 2008. In the case of multiple shortest coverage intervals, the one 
%% symmetric to expectation (mean) is selected.
%%
%% Input variables:
%% @table @samp
%% @item @var{data} - vector of numbers
%% @item @var{cp} - coverage interval probability
%% @item @var{expe} - user override for expected value (optional)
%% @item @var{verbose} - displays output and figures (optional)
%% @end table
%%
%% Output variables:
%% @table @samp
%% @item @var{sloci} - shortest coverage interval
%% @item @var{sqL} - value of output quantity at the left side of shortest coverage interval
%% @item @var{sqR} - value of output quantity at the right side of shortest coverage interval
%% @end table
%%
%% Example:
%% generate random numbers according to normal distribution and calculate 
%% uncertainty of the result (compare it with standard deviation times two):
%% @example
%% a=randn(1,1e5);
%% [sloci, sqL, sqR] = scovint(a, 0.6827, 1)
%% 2.*std(a)
%% @end example
%% @end deftypefn

%% Author: Martin Å Ã <msiraATcmi.cz>
%% Created: July 2012
%% Version: 1.11
%% Keywords: coverage interval GUM

% modified: 1.12.2017, Stanislav Maslan
%  - improved performance
%  - added user input for expected value
%  - made Matlab compatible


function [selsloci, selsqL, selsqR] = scovint(data, cp, expe, verbose)

        % --------------------------- check input parameters %<<<1
        % check No of arguments
        if ( nargin<2 )
                print_usage();
        end
        % check if input data is vector 
        if ( isvector(data)~=1 )
                error ('scovint: DATA must be vector');
        end
        % check cp
        if ( ~isscalar(cp) )
                if ( ~isnumeric(cp) )
                        error ('scovint: CP must be a scalar number');
                end
        end
        % check correct cp
        if ( cp<=0 || cp>=1 )
                error ('scovint: CP must be greater than 0 and smaller than 1');
        end
        % check estimate value
        if ~exist('expe','var') || ~numel(expe)
                % expectation (normally it is mean, but user may need other exact value)
                expe = mean(data);
        end
        % check correct verbose
        if ~exist('verbose','var')
                verbose = 0;
        end
        if ( ~isscalar(verbose) )
                error ('scovint: verbose must be scalar');
        end

        % --------------------------- inner constants %<<<1
        % output quantity resolution (defines resolution of result):
        % XXX POSSIBLY CHANGE THIS VALUES IN THE CASE OF IMPROPER RESULTS:
        % XXX BUT THE CALCULATION WILL TAKE LONGER TIME
        cdfxlength = 500;
        probvalraster = 0.0001;

        % --------------------------- preliminary values %<<<1
        % data length
        N = length(data);
        
        % reshape data to vertical
        data = reshape(data,N,1);

        % --------------------------- cumulative distribution function: %<<<1
        % see figure 1 of 1st GUM supplement

        % output quantity vector (x axis of the cdf plot):
        cdfx(:,1) = linspace(min(data),max(data),cdfxlength);          
        
        %%%% calculate cdf for all output quantities, normalize %%%%        
        %% Original version
        %cdfy = [];              
        %for x = cdfx'
        %  cdfy = [cdfy;sum(data<=x)];
        %endfor
        %cdfy = cdfy./N;         
        
        %% Cleaner version
        %cdfy(:,1) = sum(bsxfun(@lt,data,cdfx'))./N;        
        
        %% Zimlich gut version 
        %[cdfy,s] = hist(data,cdfxlength);
        %cdfy = cumsum(cdfy)'/N;                      
                
        %% Da best version mit eine kleine Besserungsvorschlag                            
        %cdfy = interp1q(sort(data)',[0:N-1]',cdfx(1:end))/(N-1);
        % %%#note: may need extrapolation to make it safe
        cdfy = interp1(sort(data)',[0:N-1]',cdfx(1:end))/(N-1);
        
              
        
                
       
        sver = 0;
        
        if(sver==0)
          %%%%%%%%%%% NEW VERSION %%%%%%%%%%%
          
          % expectation:
          %expe = mean(data);
                    
          % expected mean probability
          %expe_p = interp1q(cdfx,cdfy,expe);
          % %%#note: may need extrapolation to make it safe
          expe_p = interp1(cdfx,cdfy,expe,'extrap');
          
          % --------------------------- coverage interval length: %<<<1
          % possible left probabs, valid interval <0;expe_p>                
          lim_a_p = 0:probvalraster:expe_p;          
          
          % generate right probabs for every left probab
          lim_b_p = cp + lim_a_p;
          % limit to interval <expe_p;0>
          id = lim_b_p>expe_p & lim_b_p<1;          
          lim_b_p = lim_b_p(id);
          lim_a_p = lim_a_p(id);
          
          % get qunatities for every left probab
          %lim_a_q = interp1q(cdfy,cdfx,lim_a_p);
          % %%#note: may need extrapolation to make it safe
          lim_a_q = interp1(cdfy,cdfx,lim_a_p);
          
          % get qunatities for every right probab
          %lim_b_q = interp1q(cdfy,cdfx,lim_b_p);
          % %%#note: may need extrapolation to make it safe
          lim_b_q = interp1(cdfy,cdfx,lim_b_p);
          
          % calculate vector of interval lengths 
          int_v_q = lim_b_q - lim_a_q;                   
                  
          % --------------------------- selection of the apropriate shortest coverage interval in the case of multiple results: %<<<1
          % find minimum in the interval lengths vector
          [v_min,id_min] = min(int_v_q);
          
          %% find additional minima in desired range
          % range of minima search (relative to interval length span)
          min_span = 1e-5;                    
          % maximum length of interval
          v_max = max(int_v_q);
          % search indexes of intervals within the span
          %id = [([1:length(int_v_q)](int_v_q <= (v_min + (v_max-v_min)*min_span + 10*eps*mean(int_v_q)))) id_min];         
          id = [1:length(int_v_q)];
          id = [(id(int_v_q <= (v_min + (v_max-v_min)*min_span + 10*eps*mean(int_v_q)))) id_min];
          % store the minima into the list
          sloci = int_v_q(id);                               
          
          % possible left and right bounds for the shortest intervals
          selsqL = lim_a_q(id);
          selsqR = lim_b_q(id);
          % %%#note: may need extrapolation to make it safe
          %selspL = interp1q(cdfx,cdfy,selsqL);
          %selspR = interp1q(cdfx,cdfy,selsqR);
          selspL = interp1(cdfx,cdfy,selsqL);
          selspR = interp1(cdfx,cdfy,selsqR);
          
          % possible shortest interval lengths
          selsloci = selsqR - selsqL;
          
          %% generate some rubbish for displaying compatible with old version                              
          % all interval lengths 
          pL = lim_a_p;
          loci = int_v_q;
          % possible shortest intervals
          spL = selspL;          
         
          
          % in the case of multiple coverage interval, find most symetric results:
          tmp = abs(abs(selsqL - expe) - abs(selsqR - expe));
          symr = min(tmp);
          symrind = find(tmp == symr);
          % if more symetric results, use middle one:
          if(numel(symrind) > 1)
            resind = symrind(round(length(symrind)/2));
          else
            resind = symrind;
          end
          
          % get final values
          selsqL = selsqL(resind);
          selsqR = selsqR(resind);
          selspL = selspL(resind);
          selspR = selspR(resind);
          selsloci = selsloci(resind);          
          
                               
        
        else
          %%%%%%%%%%% OLD VERSION %%%%%%%%%%%
          % --------------------------- coverage interval length: %<<<1
          % plot of the length of the 95 % coverage interval, as a function of the probability at its left-hand endpoint
          % (figure 7 of 1st GUM supplement)
  
          % left hand probability vector (x axis of the plot):
          pL=[];
          % length of coverage interval vector (y axis of the plot):
          loci=[];
          % shortest length of coverage interval (starting value):
          sloci=inf;
          % left hand probability of the shortest coverage interval
          spL = [];
          % curpL (current left hand probability) goes through left hand probability values:
          % OPTIMIZATION IS NEEDED!
          % through left hand probability:
          for curpL=[0:probvalraster:1]
                  % right hand probability of coverage interval:
                  curpR = curpL + cp;
                  % if right hand probability is > 1 no reason to calculate further:
                  if ( curpR > 1 )
                          break
                  end
                  % index of the value from probability vector nearest to the left hand probability:
                  [tmp, curpLind]=min(abs(cdfy-curpL));
                  % building data for the plot of length of coverage interval:
                  pL=[pL cdfy(curpLind)];
                  % output quantity corresponing to the left hand probability:
                  qL = cdfx(curpLind);
                  % index of the value from probability vector nearest to the right hand probability:
                  [tmp, curpRind]=min(abs(cdfy - curpR));
                  % output quantity corresponing to the right hand probability:
                  qR = cdfx(curpRind);
                  % length of coverage interval:
                  curloci = qR - qL;
                  % building data for the plot of length of coverage interval:
                  loci = [loci curloci];
                  % shortest length of coverage interval values:
                  if curloci < sloci(1)
                          sloci = curloci;
                          % throw away values other than for shortest coverage interval lengths:
                          sqL = qL;
                          sqR = qR;
                          spL = cdfy(curpLind);
                  elseif curloci == sloci
                          % cumulate values in the case of multiple shortest coverage interval lengths:
                          sloci = [sloci curloci];
                          sqL = [sqL qL];
                          sqR = [sqR qR];
                          % left hand probability of coverage interval:
                          spL = [spL cdfy(curpLind)];
                  end
  
          end
                          %%%%%%%%sqL 
                          %%%%%%%%sqR 
                          %%%%%%%%spL 
  
          % --------------------------- selection of the apropriate shortest coverage interval in the case of multiple results: %<<<1
          % expectation:
          %expe = mean(data);
          % select only those shortest intervals which cover expectation:
          selsqL = [];
          selsqR = [];
          selsloci = [];
          selspL = [];
          for i=1:length(sloci)
                  if ( sqL(i) <= expe ) && ( sqR(i) >= expe )
                          selsqL = [selsqL sqL(i)];
                          selsqR = [selsqR sqR(i)];
                          selsloci = [selsloci sloci(i)];
                          selspL = [selspL spL(i)];
                  end
          end
          % in the case of no appropriate coverage interval:
          if ( sum(size(sloci)) == 0 )
                  error('no shortest coverage interval covering expectation found')
          end
          % in the case of multiple coverage interval, find most symetric results:
          tmp = abs( abs(selsqL - expe) - abs(selsqR - expe) );
          symr = min(tmp);
          symrind = find(tmp == symr);
          % if more symetric results, use middle one:
          if ( length(symrind) > 1 )
                  resind = symrind( round( length(symrind)/2 ) );
          else
                  resind = symrind;
          end
          % get final values
          selsqL = selsqL(resind);
          selsqR = selsqR(resind);
          selsloci = selsloci(resind);
          selspL = selspL(resind);
        
        end
        
                
        

        % --------------------------- plotting: %<<<1

        % plot of the cumulative distribution function:
        if verbose
                figure
                % cdf:
                plot(cdfx,cdfy,'-x')
                hold on
                xl=xlim;
                yl=ylim;
                % show expectation:
                plot([expe expe], [yl(1) yl(2)], '-g');
                % lines to show selected shortest coverage interval:
                plot([xl(1) selsqL], [selspL selspL], '-r')
                plot([selsqL selsqL], [yl(1) selspL], '-r');
                plot([selsqR xl(1)], [selspL+cp selspL+cp], '-r');
                plot([selsqR selsqR], [yl(1) selspL+cp], '-r');
                legend('cdf','expectation','shortest cov. int.');
                xlabel('output quantity')
                ylabel('probability')
                title('cumulative distribution function');
                hold off
        end

        % plot of the length of coverage interval
        if verbose
                figure
                hold on
                plot(pL,loci,'o-')
                plot(spL, ones(size(spL)).*sloci, 'xg', 'linewidth',4,'markersize',10)
                plot(selspL, selsloci, 'xr', 'linewidth',4, 'markersize',10)
                legend('length of coverage interval', 'shortest l. of c. i.', 'selected s. l. of c. i.','',''); 
                title(['length of ' num2str(cp) ' coverage interval'])
                xlabel('left hand probability')
                ylabel('length of coverage interval')
                hold off
        end

end

% --------------------------- tests: %<<<1

%!shared a, b, c, sloci, sqL, sqR
%! a=[-10:0.1:10];
%! b=stdnormal_pdf(a);
%! c=[];
%! for i=1:length(b)
%!         c=[c ones(1,  round(b(i).*1000)  ).*a(i)];
%! endfor
%! [sloci, sqL, sqR] = scovint(c, 0.6827,0);
%!assert(sloci, std(c).*2, 0.005);
%!assert(sqL<0);
%!assert(sqR>0);
%!assert(sloci, sqR-sqL, 2*eps);
%! a=[0:0.01:10];
%! b=gampdf(a,1,2);
%! c=[];
%! for i=1:length(b)
%!         c=[c ones(1,  round(b(i).*1000)  ).*a(i)];
%! endfor
%! [sloci, sqL, sqR] = scovint(c, 0.6827,0);
%!assert(sloci, 2.26226452905812, 0.00000000000002);
%!assert(sqL,0.01);
%!assert(sqR, sloci+sqL, 0.00000000000002);


% --------------------------- demo: %<<<1
%!demo
%! % chosen coverage interval probability:
%! cp=0.6827;
%! % generate points at which distribution will be evaluated:
%! a=[0:0.01:10];
%! % generate probability density function of gamma distribution:
%! b=gampdf(a,2,2);
%! % prepare variable:
%! c=[];
%! % generate samples of the gamma distribution:
%! for i=1:length(b)
%! % for every point of pdf b(i) generate appropriate number of values:
%!         c=[c ones(1,  round(b(i).*1000)  ).*a(i)];
%! endfor
%! % calculate shortest coverage interval:
%! [sloci, sqL, sqR] = scovint(c, cp, 1);
%! % calculate twice the standard deviation:
%! stddouble=std(c).*2;
%! % plot histogram figure:
%! figure
%! hist(c,100);
%! hold on
%! % get figure y axis limits:
%! yl=ylim;
%! % calculate expectation (mean):
%! expe=mean(c);
%! % calculate standard deviation:
%! stdev=std(c);
%! % plot the rest:
%! plot([expe expe], [yl(1) yl(2)], 'g--', 'linewidth',3);
%! plot([expe-stdev expe-stdev], [yl(1) yl(2)], '-y', 'linewidth',3);
%! plot([sqL sqL], [yl(1) yl(2)], '-r', 'linewidth',3);
%! plot([sqR sqR], [yl(1) yl(2)], '-r', 'linewidth',3);
%! plot([expe+stdev expe+stdev], [yl(1) yl(2)], '-y', 'linewidth',3);
%! legend('histogram','mean','standard deviation','shortest cov. interv.');
%! xlabel('output quantity');
%! ylabel('count');
%! title('gamma probability density function, A=2, B=2');
%! hold off
%! % 
%! % RESULT: see on probability density function figure - yellow standard
%! % deviation interval is symmetric around expectation (mean), but red
%! % shortest coverage interval is assymetrical and shorter!
%! % RESULT: compare shortest length of coverage interval (sloci)
%! % with twice the standard deviation (stddouble):
%! sloci
%! stddouble

% vim modeline: vim: foldmarker=%<<<,%>>> fdm=marker fen ft=octave textwidth=1000