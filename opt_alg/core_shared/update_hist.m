function [ hist ] = update_hist(ui, ctrl, data, hist )
%UPDATE_HIST Summary of this function goes here
%   Detailed explanation goes here


if strcmp(ui.opt_type,'PSO')
   hist.obj       (:,ctrl.iter  ) = ctrl.obj';
   hist.state     (:,:,ctrl.iter) = data.state;
   hist.vels      (:,:,ctrl.iter) = data.vels;
   hist.acc       (ctrl.iter  )   = 1;
else
   hist.acc       (ctrl.iter  ) = ctrl.acc_step;
   hist.state     (:,ctrl.iter) = data.state;
   hist.state_prop(:,ctrl.iter) = data.state_prop;
   hist.obj       (ctrl.iter  ) = ctrl.obj;
   hist.obj_prop  (ctrl.iter  ) = ctrl.obj_prop;
end

hist.acc_rate                = sum(hist.acc(1:ctrl.iter))/ctrl.iter;

if sum(strcmp(ui.model,{'ED2.1','out.mat','read_dir'}))
   if ctrl.iter == 1                                        % Do we need to create 'hist_stats'?
      hist.stats = data.stats;                              % If so, it only has curr. stats.
   else                                                     % Otherwise we just save the ...
      hist.stats = update_struct(data.stats,hist.stats);    % stats from this year to the hist.
   end
end

end

