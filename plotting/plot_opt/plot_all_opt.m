function [ ] = plot_all_opt( opt_mat_name, obs_mat_name, save)
%PLOT_OPT_FIGS Plots items from output of optimization.
%   plot_type: 'all' graphs everything. See file for more options.
%   opt_mat_name: A string containing the filename of the optimization output.
%   opt_years: The years to plot. Set to [] if all.
%   save: Boolean, save graphs?

close all;                       % Close previously open graphs
load(opt_mat_name)               % Load the data
niter = size(hist.state,2);      % Get the number of iterations completed
load(obs_mat_name)

%----------------------------------------------------------------------------------------------%
% Get run info such as start and end indices of simulation
%----------------------------------------------------------------------------------------------%
[start_yr, start_mo, ~,~,~,~] = tokenize_time(hist.pred_best.sim_beg,'ED','num');
[end_yr  , end_mo  , ~,~,~,~] = tokenize_time(hist.pred_best.sim_end,'ED','num');
part_yrs  = start_yr:end_yr;
whole_yrs = (start_yr + 1*(start_mo ~= 1)):(end_yr -1 - 1*(end_mo ~= 1));
for i = 1:numel(whole_yrs)
   opt_yr_strs{i} = num2str(whole_yrs(i));
end

%ndyr = size(hist.stats.likely.yearly.NEE,1);    % The number of years
%ndm  = size(hist.stats.likely.monthly.NEE,1);   % The number of months
%----------------------------------------------------------------------------------------------%

if strcmp(ui.opt_type,'PSO')
   plot_state_hist_pso( cfe.iter, hist.obj, hist.state, ui.state_ref, ui.nps, cfe.labels(:,1), save);
   %plot_part_ids(cfe,data,hist,ui,save);
elseif strcmp(ui.opt_type,'NM')
   plot_state_hist_nm(cfe,hist,ui,save)
else
   plot_state_hist_seq(cfe,data,hist,nfo,ui,save);
end

plot_fit_stats(cfe,hist,ui,save);

plot_param_stars(hist,cfe,ui.opt_type,ui.state_ref,save);

%init_best_ind   = hist.obj == min(hist.obj(:,1));
%global_best_ind = hist.obj == min(hist.obj(:));

if strcmp(ui.opt_type,'NM')
   hist.iter_best = length(hist.stats.ns);
end

if strcmp(ui.opt_type,'PSO')
   init_best_ind   = hist.obj == min(hist.obj(:,1));
   global_best_ind = hist.obj == min(hist.obj(:));
   best_inds       = or(init_best_ind,global_best_ind);
   iter_best       = find(sum(global_best_ind));
else
  iter_best = iter_best;
end

%if init_best_ind ~= global_best_ind && isfield(hist.stats,'ref')
plot_likely_analy(iter_best  , ...
                  ui.opt_type, ...
                  hist.stats , ... 
                  save);
%end

plot_pred_and_obs(hist.obj       , ...
                  iter_best      , ...
                  hist.pred_best , ...
                  hist.stats     , ...
                  hist.pred_ref  , ...
                  obs            , ...
                  ui.opt_type    , ...
                  ui.opt_metadata, ...
                  save);




end
