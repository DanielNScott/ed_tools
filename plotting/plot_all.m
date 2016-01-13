function [] = plot_all(opt_mat_name)

plot_opt_figs_DMR('all',opt_mat_name,1)

load(opt_mat_name)

data.best_iter  = out_best;
data.first_iter = out_first;

plot_cb_analy(data.best_iter);
export_fig(gcf, 'Carbon Use - Best Iter', '-jpg', '-r150' );

plot_cb_analy(data.first_iter);
export_fig(gcf, 'Carbon Use - First Iter', '-jpg', '-r150' );

%plot_resps_analy(data.best_iter);
%export_fig(gcf, 'Resps Breakdown - Best Iter', '-jpg', '-r150' );

%plot_resps_analy(data.first_iter);
%export_fig(gcf, 'Resps Breakdown - First Iter', '-jpg', '-r150' );

plot_ed_output(data,0,[],1);
close all

end