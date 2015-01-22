function [ ] = plot_opt_figs_DMR( plot_type, opt_mat_name, save)
%PLOT_OPT_FIGS Plots items from output of optimization.
%   plot_type: 'all' graphs everything. See file for more options.
%   opt_mat_name: A string containing the filename of the optimization output.
%   opt_years: The years to plot. Set to [] if all.
%   save: Boolean, save graphs?

close all;                       % Close previously open graphs
load(opt_mat_name)               % Load the data
niter = size(hist_state,2);      % Get the number of iterations completed

if sum(strcmp(plot_type,'all'))
   plot_params  = 1;
   plot_likely  = 1;
   plot_preds   = 1;
else
   if sum(strcmp(plot_type,'params')); plot_params  = 1; else plot_params  = 0; end
   if sum(strcmp(plot_type,'likely')); plot_likely  = 1; else plot_likely  = 0; end
   if sum(strcmp(plot_type,'preds' )); plot_preds   = 1; else plot_preds = 0; end
end

%----------------------------------------------------------------------------------------------%
% Get run info such as start and end indices of simulation
%----------------------------------------------------------------------------------------------%
[start_yr, start_mo, ~,~,~,~] = tokenize_time(out_first.nl.start,'ED','num');
[end_yr  , end_mo  , ~,~,~,~] = tokenize_time(out_first.nl.end  ,'ED','num');
part_yrs  = start_yr:end_yr;
whole_yrs = (start_yr + 1*(start_mo ~= 1)):(end_yr -1 - 1*(end_mo ~= 1));
for i = 1:numel(whole_yrs)
   opt_yr_strs{i} = num2str(whole_yrs(i));
end

ndyr = size(hist_stats.likely.yearly.NEE,1);    % The number of years
ndm  = size(hist_stats.likely.monthly.NEE,1);   % The number of months
%----------------------------------------------------------------------------------------------%


%--------------------------------------------------------------------------%
%% Plot: State History & Star Plots           Updated               
%-------------------------------------------------------------------------%
if plot_params && niter > 1;

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
         yvals = hist_state_prop(hist_msk);
         yvals = reshape(yvals,splt_num,iter-1)';

         names = labels(row_msk);
         if splt_num > 1;
            names{1} = [names{1}, ' Co'];
            names{2} = [names{2}, ' Hw'];
         end

         hold on
         plot(1:(iter-1),yvals)
         plot(repmat(iter_best,2,splt_num), ...
              yvals(iter_best,:),'or');
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
    
    co_param_names = ...
     {'vmfact','q','R_growth fact'}';
    hw_param_names = ...
     {'vmfact','q','stor. turn'}';
    sh_param_names = ...
     {'stom. slope','vm low temp','root turn', 'water cond.',...
      'resp opt H2O','resp Q10','resp w1', 'resp w2'}';
    
    co_params = [hist_state_prop(1:3,1)'    ; hist_state_prop(1:3,iter_best)'    ];
    hw_params = [hist_state_prop(4:6,1)'; hist_state_prop(4:6,iter_best)'];
    sh_params = [hist_state_prop(7:end,1)'; hist_state_prop(7:end,iter_best)'];
    starplot(co_params,co_param_names,'Conifer Parameters' ,save)
    starplot(hw_params,hw_param_names,'Hardwood Parameters',save)
    starplot(sh_params,sh_param_names,'Shared Parameters',save)
end
%--------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
%% Plot: Fit                                  Updated               
%-------------------------------------------------------------------------%
if plot_likely;
   figname = 'Fit';
   gen_new_fig(figname)

   yvals    = cell(1,4);
   yvals{1} = hist_stats.RMSE(1:iter-1);
   yvals{2} = hist_stats.R2(1:iter-1);
   yvals{3} = hist_stats.CoefDeter(1:iter-1);
   yvals{4} = hist_obj_prop(1:iter-1);
   titles   = {'RMSE', 'R^2', 'Coefficient of Determination', 'Objective'};

   for i = 1:4
      subaxis(2,2,i, 'Spacing', 0.015, 'Padding', 0.03, 'Margin', 0.015)
      plot(1:1:(iter-1),yvals{i})
      title(titles{i})
      ylabel('Score')
      xlabel('Iterations')
      set(gca,'XLim',[1,iter]);
   end
   
   if save; export_fig( gcf, figname, '-jpg', '-r150' ); end
end

%-------------------------------------------------------------------------%
%% Plot: Likelihoods, Yearly                  Updated               
%--------------------------------------------------------------------------%
if plot_likely
figname = 'Likelihoods, Yearly';
figure('Name',figname)
set(gcf, 'Color', 'white');

ylabels = '-1* Log Likelihood';
yvals   = [-1* hist_stats.likely.yearly.NEE(:,1), ...
           -1* hist_stats.likely.yearly.NEE(:,iter_best)];
legends = {'Initial';'Best'};

% Bar groups by row, so bar(rand(2,3),'grouped') gives two groups of three
bar(yvals,0.75,'grouped'), colormap(cool)
legend(legends)

set(gca,'XTickLabel',{num2str(whole_yrs(1)),num2str(whole_yrs(2))})
%set(gca,'XTickLabel','')
ylabel(ylabels)
xlabel('Model Year')

title('Yearly NEE Likelihoods')
ylimits = ylim;

if ylimits(1) > 0 && ylimits(2) > 0
   ylim( [0,ylimits(2)] )
elseif ylimits(1) < 0 && ylimits(2) < 0
   ylim( [ylimits(1), 0])
end

if save; export_fig( gcf, figname, '-jpg', '-r150' ); end
end



%-------------------------------------------------------------------------%
%% Plot: Likelihoods, Monthly                 New                   
%--------------------------------------------------------------------------%
if plot_likely
   figname = 'Likelihoods, Monthly';
   figure('Name',figname)
   set(gcf, 'Color', 'white');

   best = hist_stats.likely.monthly.NEE(:,iter_best)';  
   init = hist_stats.likely.monthly.NEE(:,1)';

   legends = {'Initial','Best'};
   title('NEE')
   xlabels = 'Month';
   npts    = size(best,2);
   plot(1:npts,[-init;-best])
   set(gca,'YScale','Log')
   xlabel(xlabels)
   ylabel('Normalized Likelihood * -1')
   set(gca,'XLim',[1,npts]);
   legend(legends)
   set_monthly_labels(gca,6)
   if i == 1; title({'\bf{Model Likelihoods By Month}'}); end
   
   if save;
       export_fig( gcf, figname, '-jpg', '-r150' );
   end
end


%--------------------------------------------------------------------------% 
%% Plot: Likelihoods, Analysis                New                   
%--------------------------------------------------------------------------%
if 1 %plot_likely
   figname = 'Likelihoods, Analysis';
   figure('Name',figname)
   set(gcf,'Color',[1,1,1])

   diffs     = []; % 'Best - Init' for each dataset
   keptnames = {}; % Fieldnames includes e.g. RMSE. Weed it out below.
   res_list  = fieldnames(hist_stats.likely);
   nres_list = numel(res_list);
   for i = 1:nres_list
      res = res_list{i};
      fields    = fieldnames(hist_stats.likely.(res));
      nfields   = numel(fields);
      for j = 1:nfields
         fld = fields{j};
         best  = hist_stats.likely.(res).(fld)(:,iter_best)';
         init  = hist_stats.likely.(res).(fld)(:,1        )';
         diffs = [diffs, nansum(best - init)];
         keptnames = horzcat(keptnames, [res ' ' fld]);
      end
   end
   [diffs, permutation] = sort(diffs,'descend');
   keptnames = keptnames(permutation);

   % Seperate into better, worse, and unchanged fits
   better = diffs(diffs > 0);
   worse  = diffs(diffs < 0);
   bsum   = sum(better);
   wsum   = sum(worse );
   
   % Remove anything unchanged
   same      = diffs == 0;
   keptnames = keptnames(~same);
   diffs     = diffs(~same);
   
   % Agglomerate everything less than 1%
   bmask = better./bsum > 0.01;
   wmask = worse ./wsum > 0.01;
   
   % Figure out which names to use in legend and finalize 'better' and 'worse' matrices.
   pad = false(size(bmask));
   if numel(better(~bmask)) > 0;
      mbetr  = sum(better(~bmask));
      bnames = [keptnames(bmask), {'Other Improvements'}];
   else
      mbetr  = [];
      bnames = keptnames(bmask);
   end
   
   if numel(worse(~wmask)) > 0;
      mwors  = sum(worse(~wmask));
      wnames = [{'Other Worsenings'}, keptnames([pad wmask])  ];
   else
      mwors  = [];
      wnames = keptnames([pad wmask]);
   end
   better = [better(bmask), mbetr         ];
   worse  = [mwors        , worse(wmask)  ];
   
   % Swap the orders of wnames and worse so we have heirarchy of worsening from 
   % 'most worsened' to 'least worsened' fit.
   nels   = numel(worse);
   worse  = worse (nels:-1:1);
   wnames = wnames(nels:-1:1);
   
   % If there is only one thing in the pie plot, it needs to have a value >= 1.0 or the plot
   % will only draw out a single slice, interpreting the value as a ratio of the whole.
   if numel(better) == 1
      better = 1; 
   end
   if numel(worse) == 1
      worse = -1;
   end
   
   % All log likelihoods are actually negative, and we want to maximize their sum, i.e.
   % to minimize the sum of their opposite. So improvement would be indicated by 'best'
   % likelihoods being less negative than 'initial' likelihoods. Meaning the greater
   % "best - init" is, the more improvement there is.
   subaxis(1,2,1, 'Spacing', 0.015, 'Padding', 0.03, 'Margin', 0.015)
   pie(double(better)); colormap(cool);
   title('\bf{Better}')
   legend(bnames,'Interpreter','None','Location','SouthEast')
   
   subaxis(1,2,2, 'Spacing', 0.015, 'Padding', 0.03, 'Margin', 0.015)
   pie(double(-worse));
   title('\bf{Worse}')
   legend(wnames,'Interpreter','None','Location','SouthEast')
    
   if save; export_fig( gcf, figname, '-jpg', '-r150' ); end
end


%-------------------------------------------------------------------------% 
%% Plot: Predictions, Yearly Fluxes           Updated               
%-------------------------------------------------------------------------%
if plot_preds

figname = 'Predictions, Yearly Fluxes';
figure('Name',figname)
set(gcf,'Color',[1,1,1])
   
ylabels = 'tC/ha';
pntr    = obs.proc.yearly;
yvals   = [out_first.X.YMEAN_NEE', out_best.X.YMEAN_NEE', pntr.NEE];
legends = {'Initial';'Best';'Obs.'};

% Bar groups by row, so bar(rand(2,3),'grouped') gives two groups of three
%bar(yvals,0.75,'grouped'), colormap(cool)
barwitherr([[0;0],[0;0],[2*pntr.NEE_sd]],yvals,0.75,'grouped'), colormap(cool)
legend(legends)

set(gca,'XTickLabel',opt_yr_strs)

ylabel(ylabels)
title('Yearly Mean NEE')
xlabel('Model Year')

ylimits = ylim;
if ylimits(1) > 0 && ylimits(2) > 0
   ylim( [0,ylimits(2)] )
elseif ylimits(1) < 0 && ylimits(2) < 0
   ylim( [ylimits(1), 0])
end

if save; export_fig( gcf, figname, '-jpg', '-r150' ); end

end % Plot Selector
%-------------------------------------------------------------------------%





%-------------------------------------------------------------------------%
%% Plot: Predictions, Yearly BAI and Mort     Updated               
%-------------------------------------------------------------------------%
if plot_preds

figname = 'Predictions, Yearly BAI and Mort';
gen_new_fig(figname)

titles = {'Basal Area Growth', 'Basal Area Mortality', ...
          'Hardwood BAG'     , 'Hardwood BAM'        , ...
          'Conifer BAG'      , 'Conifer BAM'         };

ylabs  = 'm^2/ha';
pntr   = obs.proc.yearly;

yvals    = cell(1,6);
yvals{1} = [out_first.T.TOTAL_BASAL_AREA_GROWTH',...
            out_best.T.TOTAL_BASAL_AREA_GROWTH',...
            pntr.BAG(2:end)];
yvals{2} = [out_first.T.TOTAL_BASAL_AREA_MORT',...
            out_best.T.TOTAL_BASAL_AREA_MORT',...
            pntr.BAM(2:end)];
yvals{3} = [out_first.H.BASAL_AREA_GROWTH',...
            out_best.H.BASAL_AREA_GROWTH',...
            pntr.BAG_Hw(2:end)];
yvals{4} = [out_first.H.BASAL_AREA_MORT',...
            out_best.H.BASAL_AREA_MORT',...
            pntr.BAM_Hw(2:end)];
yvals{5} = [out_first.C.BASAL_AREA_GROWTH',...
            out_best.C.BASAL_AREA_GROWTH',...
            pntr.BAG_Co(2:end)];
yvals{6} = [out_first.C.BASAL_AREA_MORT',...
            out_best.C.BASAL_AREA_MORT',...
            pntr.BAM_Co(2:end)];
         
err{1} = pntr.BAG_sd(2:end);
err{2} = pntr.BAM_sd(2:end);
err{3} = pntr.BAG_Hw_sd(2:end);
err{4} = pntr.BAM_Hw_sd(2:end);
err{5} = pntr.BAG_Co_sd(2:end);
err{6} = pntr.BAM_Co_sd(2:end);
         
legends = {'Initial';'Best';'Obs.'};

for i = 1:6
   subaxis(3,2,i, 'Spacing', 0.015, 'Padding', 0.015, 'Margin', 0.050)
   % Bar groups by row, so bar(rand(2,3),'grouped') gives two groups of three
   %bar(yvals{i},0.75,'grouped'), colormap(cool)
   barwitherr([[0;0],[0;0],2*err{i}],yvals{i},0.75,'grouped'), colormap(cool)
   legend(legends)

   set(gca,'XTickLabel',opt_yr_strs)
   if i == 5 || i == 6
      xlabel('Model Year')
   end

   if mod(i,2) == 1
      ylabel(ylabs);
   end
%     if i == 1
%         title('Yearly Basal Area Increments')
%     end
   ylimits = ylim;
   title(titles{i})
   if ylimits(1) > 0 && ylimits(2) > 0
       ylim( [0,ylimits(2)] )
   elseif ylimits(1) < 0 && ylimits(2) < 0
       ylim( [ylimits(1), 0])
   end
end
if save; export_fig( gcf, figname, '-jpg', '-r150' ); end

end % Plot Selector
%-------------------------------------------------------------------------%




%-------------------------------------------------------------------------%
%% Plot: Predictions, Monthly Fluxes          Updated               
%-------------------------------------------------------------------------%
if plot_preds

figname = 'Predictions, Monthly Fluxes';
figure('Name',figname)
set(gcf,'Color',[1,1,1])

pntr  = obs.proc.monthly;
yvals = [out_first.X.MMEAN_NEE; out_best.X.MMEAN_NEE];
envel = {pntr.NEE + 2*pntr.NEE_sd, pntr.NEE - 2*pntr.NEE_sd};

titles  = {'NEE'};
ylabels = {'tC/ha'};
legends = {'Obs','Initial','Best'};

hold on
ciplot(envel{1},envel{2},1:ndm,'r');
plot(1:ndm,yvals)
hold off

title(titles)
legend(legends,'Interpreter','None','Location','NorthWest')
ylabel(ylabels)
set(gca,'XLim',[1,ndm])
set_monthly_labels(gca,6)

if save; export_fig( gcf, figname, '-jpg', '-r150' ); end

end % Plot Selector
%----------------------------------------------------------------------%




%-------------------------------------------------------------------------%
%% Plot: Predictions, Daily Fluxes            Updated               
%-------------------------------------------------------------------------%
if plot_preds

figname = 'Predictions, Daily Fluxes';
figure('Name',figname)
set(gcf,'Color',[1,1,1])

pntr  = obs.proc.daily;
yvals = [out_first.X.DMEAN_NEE', out_best.X.DMEAN_NEE'];
envel = {pntr.NEE - 2*pntr.NEE_sd, pntr.NEE + 2*pntr.NEE_sd};

npts = numel(out_first.X.DMEAN_NEE);
hold on
ciplot(envel{1},envel{2},1:npts,'r')
plot(1:npts,yvals)
hold off

title('Daily NEE')
legend('Obs.','Initial','Best')
ylabs = 'tC/ha';
xlabs = 'Days since Jan 1, 1994';
xlabel(xlabs)
ylabel(ylabs)

   if save
       export_fig( gcf, figname, '-jpg', '-r150' );
   end
end % Plot Selector
%----------------------------------------------------------------------%




%-------------------------------------------------------------------------%
%% Plot: Predictions, Hourly Fluxes           Updated               
%-------------------------------------------------------------------------%
if plot_preds

figname = 'Predictions, Hourly Fluxes';
gen_new_fig(figname)

pntr  = obs.proc.hourly;
yvals = cell(1:4);
yvals{1} = [out_first.X.FMEAN_NEE'        , out_best.X.FMEAN_NEE'        , pntr.NEE];
yvals{2} = [out_first.X.FMEAN_NEE_Day'    , out_best.X.FMEAN_NEE_Day'    , pntr.NEE_Day];
yvals{3} = [out_first.X.FMEAN_NEE_Night'  , out_best.X.FMEAN_NEE_Night'  , pntr.NEE_Night];
yvals{4} = [out_first.X.FMEAN_VAPOR_CA_PY', out_best.X.FMEAN_VAPOR_CA_PY', pntr.Latent];

%envel = {[pntr.NEE       - pntr.NEE_sd      , pntr.NEE       + pntr.NEE_sd       ];...
%         [pntr.NEE_Day   - pntr.NEE_Day_sd  , pntr.NEE_Day   + pntr.NEE_Day_sd   ];...
%         [pntr.NEE_Night - pntr.NEE_Night_sd, pntr.NEE_Night + pntr.NEE_Night_sd ];...
%         [pntr.Latent    - pntr.Latent_sd   , pntr.Latent    + pntr.Latent_sd    ]   };


titles  = {'Hourly NEE', 'Hourly Daytime NEE', 'Hourly Night Time NEE', 'Hourly Latent Heat Flux'};
ylabels = {'tC/ha', 'tC/ha', 'tC/ha', 'W/m^2'};

npts = numel(out_first.X.FMEAN_NEE);
for i = 1:4
   subaxis(4,1,i, 'Spacing', 0.015, 'Padding', 0.015, 'Margin', 0.050)
      hold on
      plot(1:npts,yvals{i})
      hold off
      title(titles{i})
      legend('Initial','Best','Obs.')

      if i ~= 4
        set(gca,'XTickLabel','')
      end
      if i == 4
         xlabel('Hours since 00:00, Jan 1 1994')
      end

      ylabel(ylabels{i})
end
% if i == 1
%    title('Yearly Mean Fluxes')
% end

ylimits = ylim;
if ylimits(1) > 0 && ylimits(2) > 0
   ylim( [0,ylimits(2)] )
elseif ylimits(1) < 0 && ylimits(2) < 0
   ylim( [ylimits(1), 0])
end


if save
    export_fig( gcf, figname, '-jpg', '-r150' );
end

end % Plot Selector
%----------------------------------------------------------------------%




%-------------------------------------------------------------------------%
%%

end
