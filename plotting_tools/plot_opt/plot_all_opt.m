function [ ] = plot_all_opt( opt_mat_name, save)
%PLOT_OPT_FIGS Plots items from output of optimization.
%   plot_type: 'all' graphs everything. See file for more options.
%   opt_mat_name: A string containing the filename of the optimization output.
%   opt_years: The years to plot. Set to [] if all.
%   save: Boolean, save graphs?

close all;                       % Close previously open graphs
load(opt_mat_name)               % Load the data
niter = size(hist.state,2);      % Get the number of iterations completed
load('obs_proc.mat')

%----------------------------------------------------------------------------------------------%
% Get run info such as start and end indices of simulation
%----------------------------------------------------------------------------------------------%
[start_yr, start_mo, ~,~,~,~] = tokenize_time(hist.out_best.nl.start,'ED','num');
[end_yr  , end_mo  , ~,~,~,~] = tokenize_time(hist.out_best.nl.end  ,'ED','num');
part_yrs  = start_yr:end_yr;
whole_yrs = (start_yr + 1*(start_mo ~= 1)):(end_yr -1 - 1*(end_mo ~= 1));
for i = 1:numel(whole_yrs)
   opt_yr_strs{i} = num2str(whole_yrs(i));
end

%ndyr = size(hist.stats.likely.yearly.NEE,1);    % The number of years
%ndm  = size(hist.stats.likely.monthly.NEE,1);   % The number of months
%----------------------------------------------------------------------------------------------%

if strcmp(ui.opt_type,'PSO')
   plot_state_hist_pso(ctrl,data,hist,nfo,ui,save);
else
   plot_state_hist_seq(ctrl,data,hist,nfo,ui);
end

plot_fit_stats(ctrl,hist,ui,save);

plot_param_stars(hist,ui,save);

plot_likely_analy(ctrl,data,hist,nfo,ui,save);

plot_pred_and_obs(hist,obs,ui,save);




end
