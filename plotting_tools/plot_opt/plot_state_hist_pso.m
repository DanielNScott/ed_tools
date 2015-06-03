function [ ] = plot_state_hist_pso( ctrl, data, hist, nfo, ui, save )
%PLOT_STATE_HISTORY Summary of this function goes here
%   Detailed explanation goes here

labels = ui.labels(:,1);                                 % Alias the param labels.
nlabs  = numel(labels);
iter   = ctrl.iter;
nps    = size(hist.state,2);

q_msk = strcmp(labels,'q');
if any(q_msk) > 0
   q_flds = labels(q_msk);
   q_flds{1} = 'q_co';
   q_flds{2} = 'q_hw';
   labels(q_msk) = q_flds;
end

figname = 'State History';                               % Name a new fig.
gen_new_fig(figname)                                     % And create it


nrows = -floor(-numel(labels)/2);                     % How many rows of plots?
for iplt = 1:nlabs

   row_msk  = strcmp(labels(iplt),labels);
   hist_msk = zeros(size(hist.state));
   hist_msk(row_msk,:,1:iter-1) = 1;
   
   subaxis(nrows,2,iplt,'S',0.015,'P',0.010,'M',0.03,'PB',0.03)
      pvals = hist.state(logical(hist_msk));
      pvals = reshape(pvals,nps,iter-1)';

      hold on
      plot(1:(iter-1),pvals','o','MarkerSize',4)
      
      set(gca,'XLim',[0,iter]);
%     legend(names,'Interpreter','None','Location','NorthWest')
      if any(iplt == [nlabs-1, nlabs])
          xlabel('Iterations')
      end
      
      if mod(iplt,2) == 1;
         ylabel('Parameter Values')
      end
      raw_title = labels{iplt};
      raw_title(raw_title == '_') = ' ';
      title(['\bf{' raw_title '}' ])
end

if save;
    export_fig( gcf, figname, '-jpg', '-r150' );
end
   
end

