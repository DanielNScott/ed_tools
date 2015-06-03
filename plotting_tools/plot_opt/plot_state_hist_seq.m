function [ ] = plot_state_hist_seq( ctrl, data, hist, nfo, ui )
%PLOT_STATE_HISTORY Summary of this function goes here
%   Detailed explanation goes here

labels = ui.labels;

figname = 'State History';
gen_new_fig(figname)

labels{strcmp(labels(:,1),'vmfact_co')} = 'vmfact';
labels{strcmp(labels(:,1),'vmfact_hw')} = 'vmfact';
var_names = unique(labels(:,1));

nrows = -floor(-numel(var_names)/2);
for iplt = 1:numel(var_names)

   row_msk  = strcmp(var_names(iplt),labels(:,1));
   splt_num = sum(row_msk);
   hist_msk = repmat(row_msk,1,iter-1);

   subaxis(nrows,2,iplt,'Spacing',0.015,'Padding',0.010,'Margin',0.03)
      yvals = hist.state_prop(hist_msk);
      yvals = reshape(yvals,splt_num,iter-1)';

      names = labels(row_msk);
      if splt_num > 1;
         names{1} = [names{1}, ' Co'];
         names{2} = [names{2}, ' Hw'];
      end

      hold on
      plot(1:(iter-1),yvals)
      plot(repmat(hist.iter_best,2,splt_num), ...
           yvals(hist.iter_best,:),'or');
      hold off

      set(gca,'XLim',[1,iter-1]);
      legend(names,'Interpreter','None','Location','NorthWest')
      if iplt == 11 || iplt == 12
          xlabel('Iterations')
      end
      if iplt == 1 || iplt == 2
          title('Parameter Values by Iteration')
      end
      %if mod(iplt,2) == 1;
      %    ylabel('Parameter Values')
      %end
      %title(titles{j},'Interpreter','None')
end

if save;
    export_fig( gcf, figname, '-jpg', '-r150' );
end
   
end

