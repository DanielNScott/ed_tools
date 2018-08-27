function [ ] = plot_state_hist_pso( iter, obj, state, state_ref, nps, labels, save, fileID )
%PLOT_STATE_HISTORY Summary of this function goes here
%   Detailed explanation goes here

nlabs  = numel(labels);

% q_msk = strcmp(labels,'q');
% if any(q_msk) > 0
%    q_flds = labels(q_msk);
%    q_flds{1} = 'q_co';
%    q_flds{2} = 'q_hw';
%    labels(q_msk) = q_flds;
% end

figname = 'State history';                               % Name a new fig.
gen_new_fig(figname)                                     % And create it

nparams = size(state,1);
nrows   = -floor(-numel(labels)/2);                     % How many rows of plots?
for iplt = 1:nlabs
   row_ind = find(strcmp(labels(iplt),labels));
   
   if numel(row_ind) == 2
      labels{row_ind(1)} = [labels{row_ind(1)}, '_co'];
      labels{row_ind(2)} = [labels{row_ind(2)}, '_hw'];
      row_ind = row_ind(1);
   end
   
   hist_msk = zeros(size(state));
   hist_msk(row_ind,:,1:iter) = 1;
   
%   best_msk(1,:,:) = obj == repmat(min(obj),ui.nps,1);
%   best_msk = repmat(best_msk,[nparams,1,1]);

   best_msk = zeros(size(hist_msk));
   best_msk(iplt,:,:) = obj == repmat(min(obj),nps,1);

   subaxis(nrows,2,iplt,'S',0.015,'P',0.010,'M',0.03,'PB',0.03)
      pvals = state(logical(hist_msk));
      pvals = reshape(pvals,nps,iter)';
      
      bvals = state(logical(best_msk));
      bvals = reshape(bvals,1,iter)';
      
      rvals = repmat(state_ref(iplt),1,iter);

      hold on
      if nps > 60
         marker = '.';
      else
         marker = 'o';
      end
      plot(1:iter, pvals',marker)%,'MarkerSize',4)
      plot(1:iter, bvals','ro','MarkerSize',8)
      plot(1:iter, rvals','b-')
      
      set(gca,'XLim',[0,iter]);
%     legend(names,'Interpreter','None','Location','NorthWest')
      if any(iplt == [nlabs-1, nlabs])
          xlabel('Iterations')
      end
      
      if mod(iplt,2) == 1
         ylabel('Parameter Values')
      end
      raw_title = labels{iplt};
      raw_title(raw_title == '_') = ' ';
      title(['\bf{' raw_title '}' ])
end

if save; latex_figure(gcf, figname, fileID); end
   
end

