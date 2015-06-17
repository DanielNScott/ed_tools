function [ ] = plot_fit_stats( ctrl,hist,ui,save )
%PLOT_FIT_STATS Summary of this function goes here
%   Detailed explanation goes here

iter = ctrl.iter;

figname = 'Fit';
gen_new_fig(figname)

yvals    = cell(1,4);
yvals{1} = hist.stats.RMSE(1:iter-1);
yvals{2} = hist.stats.R2(1:iter-1);
yvals{3} = hist.stats.CoefDeter(1:iter-1);

if strcmp(ui.opt_type,'PSO')
   best_objs = min(hist.obj);
   yvals{4}  = best_objs(1:iter-1);
   
   if isfield(hist.stats,'ref')
      yvals{1} = [yvals{1}; repmat(hist.stats.ref.RMSE,1,iter-1);];
      yvals{2} = [yvals{2}; repmat(hist.stats.ref.R2,1,iter-1);];
      yvals{3} = [yvals{3}; repmat(hist.stats.ref.CoefDeter,1,iter-1);];
      yvals{4} = [yvals{4}; repmat(hist.stats.ref.total_likely*-1,1,iter-1);];
   end
   
else
   yvals{4} = hist.obj_prop(1:iter-1);
end
titles   = {'RMSE', 'R^2', 'Coefficient of Determination', 'Objective'};

for i = 1:4
   subaxis(2,2,i, 'Spacing', 0.015, 'Padding', 0.03, 'Margin', 0.015)
   plot(1:1:(iter-1),yvals{i})
   title(['\bf{' titles{i} '}'])
   ylabel('Score')
   xlabel('Iterations')
   set(gca,'XLim',[1,iter]);

   if isfield(hist.stats,'ref')
      legend('Ensemble Bests','Reference')
   end
end

if save; export_fig( gcf, figname, '-jpg', '-r150' ); end

end

