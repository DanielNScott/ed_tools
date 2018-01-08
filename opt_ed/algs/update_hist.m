function [ hist ] = update_hist(cfe, hist, ui )
%UPDATE_HIST Summary of this function goes here
%   Detailed explanation goes here


if any(strcmp(ui.opt_type,{'PSO','NM'}))
   hist.obj       (:,cfe.iter  ) = hist.obj';
   hist.state     (:,:,cfe.iter) = hist.state;
   hist.acc       (cfe.iter  )   = 1;
   if strcmp(ui.opt_type,'PSO')
      hist.vels      (:,:,cfe.iter) = data.vels;
   end
end

if sum(strcmp(ui.model,{'ED2.1','out.mat','read_dir'}))
   if cfe.iter == 1                                        % Do we need to create 'hist_stats'?
      hist.stats = data.stats;                              % If so, it only has curr. stats.
   else                                                     % Otherwise we just save the ...
      hist.stats = update_struct(data.stats,hist.stats);    % stats from this year to the hist.
   end
end

end

