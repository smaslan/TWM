function [inf] = qwtb_get_result2info(meas_root, alg_id, cfg, var_list)
% This loads the result data and formats it into INFO style packet.
% It is used for transfer of TWM data via TWM server/client.
% ###TODO: better doc

    % return averages:
    res_id = 0;

    % load results:
    [res, avg, unca, res_id, are_scalar, is_avg] = qwtb_load_results(meas_root, res_id, alg_id, cfg, var_list);
    
    % readings count:
    R = numel(res);
    % channels/phases count:       
    C = numel(res{1});
    % quantities count:
    Q = numel(res{1}{1});
    
    
    % result info string:
    inf = '';
    
    % channel names:
    chn_name = {};
    
    % --- For each channel/phase ---
    qu_name = {};
    for c = 1:C
    
        % generate channel name:
        chn_name{c,1} = sprintf('phase/channel %d',c);
    
        % channel section:        
        cinf = '';
        
        % channel/phase tag
        try
            qu = avg{c}{1};
            tag = qu.tag;                                
        catch       
            tag = '';
        end
        cinf = infosettext(cinf,'phase tag',tag);
                
        % --- For each quantity
        qu_name = {};
        for q = 1:Q                      
            
            qu = avg{c}{q};
            ua = unca{c}{q};
            
            % generate quantity name:
            qu_name{q,1} = qu.name;
            
            vinf = '';
            
            % is phase quantity?
            vinf = infosetnumber(vinf,'is phase',qu.is_phase);
            
            % is amplitude quantity?
            vinf = infosetnumber(vinf,'is amplitude',qu.is_amplitude);
            
            % numeric format
            vinf = infosettext(vinf,'numeric format',qu.num_format);
            
            % description text
            vinf = infosettext(vinf,'description',qu.desc);
            
            if ~qu.is_big && ~isempty(qu.val)
                % quantity loaded and numeric                
                uc = (qu.unc.^2 + (2*ua.val).^2).^0.5;                         
                vinf = infosetmatrix(vinf,'value',qu.val);  
                vinf = infosetmatrix(vinf,'uncertainty',uc);
                vinf = infosetmatrix(vinf,'ua',ua.val);
            else
                % unknonw or too long:           
                vinf = infosetmatrix(vinf,'value',NaN);  
                vinf = infosetmatrix(vinf,'uncertainty',NaN);
                vinf = infosetmatrix(vinf,'ua',NaN);            
            end            
            
            % store quantity section:
            cinf = infosetsection(cinf,qu.name,vinf);
    
        end
                
        % store channel section:
        inf = infosetsection(inf,chn_name{end},cinf);
    
    end
    
    % store header:
    inf = infosetnumber(inf,'phases/channels count',numel(chn_name));    
    inf = infosettextmatrix(inf,'list of phases/channels',chn_name);
    inf = infosettextmatrix(inf,'list of quantities',qu_name);
    inf = infosetnumber(inf,'readings',R);
    % append measurement root folder path just in case TWM client wants to dig out some stuff directly
    inf = infosettext(inf,'session folder',meas_root);
    
end