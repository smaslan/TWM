%% -----------------------------------------------------------------------------
%% TracePQM: Performes averaging of all quantities of each channel.
%%
%% inputs:
%%   res - cell array of results loaded by 'qwtb_parse_result()',
%%         where each cell contains cell array of channels/phases,
%%         where each cell contains quantities
%%         So the order of indexes is:
%%           res{avg_cycle}{phase/channel}{quantity}
%%
%% outputs:
%%   avg - vector of channels with averages quantities
%%   unca - type A uncertainty of averaged quantities
%%          note the 'unc' item of 'unca' is invalid  
%% -----------------------------------------------------------------------------
function [avg, unca] = qwtb_average_results(res)

  R = numel(res);
  P = numel(res{1});
  V = numel(res{1}{1});
    
  % create default results
  avg = res{1};
  unca = res{1};
  
  % --- for each phase/channel
  for p = 1:P
    
    % --- for each variable
    for v = 1:V
    
      % variable size
      sz = res{1}{p}{v}.size;
      
      % allocate averaging matrices
      dims = [sz R];
      val = zeros(dims);
      unc = zeros(dims);
    
      % build averageing matrices 
      skip = 0;
      for r = 1:R
        if res{r}{p}{v}.is_big
          skip = 1;
          break;
        end
        
        if res{r}{p}{v}.size ~= sz
          error(sprintf('QWTB results averager: Averaging variable ''%s'' failes because dimensions are not equal!',res{r}{v}.name));
        end

        % merge average data
        val(:,:,r) = res{r}{p}{v}.val;     
        if numel(res{r}{p}{v}.unc)
          unc(:,:,r) = res{r}{p}{v}.unc;
        end
      
      end
      
      if ~skip
        if R == 1
          avg{p}{v}.val = val;
          avg{p}{v}.unc = unc;
          unca{p}{v}.val = zeros(size(val)); % type A uncertainty estimate
          unca{p}{v}.unc = zeros(size(val)); % type A uncertainty estimate
        else
          % average variable and uncertainty
          avg{p}{v}.val = mean(val,3);
          avg{p}{v}.unc = mean(unc,3);
          unca{p}{v}.val = std(val,[],3)/R^0.5; % type A uncertainty estimate
          unca{p}{v}.unc = avg{p}{v}.unc;
        end
      else
        % leave if variable is big
        break;
      end
    
    end
  end 

end