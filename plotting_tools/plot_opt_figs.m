function [ ] = plot_opt_figs( plot_type, opt_mat_name, save)
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
%    
%    mynames = ...
%     {'Vmfact','stom. slope','root turn.','root resp.'}';
%    
%    co_params = [hist_state_prop(1:end/2,1)'    ; hist_state_prop(1:end/2,iter_best)'];
%    hw_params = [hist_state_prop(end/2+1:end,1)'; hist_state_prop(end/2+1:end,iter_best)'];
%    starplot(co_params,mynames,'Conifer Parameters' ,save)
%    starplot(hw_params,mynames,'Hardwood Parameters',save)
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
gen_new_fig(figname)

flds = fieldnames(hist_stats.likely.yearly);

ylabels = { {'NEE'        ,'-1* Log Likelihood'},{'Nightly NEE'  ,'-1* Log Likelihood' },...
            {'Latent Heat','-1* Log Likelihood'},{'Sensible Heat','-1* Log Likelihood'},...
            {'BAI','-1* Log Likelihood'}  };

yvals = cell(1,4);

yvals{1} = [-1* hist_stats.likely.yearly.NEE(:,1), ...
            -1* hist_stats.likely.yearly.NEE(:,iter_best)];
% yvals{2} = [-1* hist_stats.likely.yearly.NEE_Night(:,1), ...
%             -1* hist_stats.likely.yearly.NEE_Night(:,iter_best)];
% yvals{3} = [-1* hist_stats.likely.yearly.Latent(:,1), ...
%             -1* hist_stats.likely.yearly.Latent(:,iter_best)];
% yvals{4} = [-1* hist_stats.likely.yearly.Sens(:,1), ...
%             -1* hist_stats.likely.yearly.Sens(:,iter_best)];

legends = {'Initial';'Best'};
nplots = 1;
for i = 1:nplots
    subaxis(nplots,1,i, 'Spacing', 0.005, 'Padding', 0.01, 'Margin', 0.050)
    % Bar groups by row, so bar(rand(2,3),'grouped') gives two groups of three
        bar(yvals{i},0.75,'grouped'), colormap(cool)
        legend(legends)
                        
        if i == nplots
           set(gca,'XTickLabel',{num2str(whole_yrs(1)),num2str(whole_yrs(2))})
        else
           set(gca,'XTickLabel','')
        end

        ylabel(ylabels{i})
        if i == 1
            title('\bf{Model Likelihoods by Year}')
        end
        ylimits = ylim;
        if ylimits(1) > 0 && ylimits(2) > 0
            ylim( [0,ylimits(2)] )
        elseif ylimits(1) < 0 && ylimits(2) < 0
            ylim( [ylimits(1), 0])
        end
end
if save; export_fig( gcf, figname, '-jpg', '-r150' ); end
end



%-------------------------------------------------------------------------%
%% Plot: Likelihoods, Monthly                 New                   
%--------------------------------------------------------------------------%
if plot_likely
   figname = 'Likelihoods, Monthly';
   gen_new_fig(figname)

   best = {};
   init = {};
   best{1} = hist_stats.likely.monthly.NEE      (:,iter_best)';
%    best{2} = hist_stats.likely.monthly.NEE_Night(:,iter_best)';
%    best{3} = hist_stats.likely.monthly.Latent   (:,iter_best)';
%    best{4} = hist_stats.likely.monthly.Sens     (:,iter_best)';
%    
    init{1} = hist_stats.likely.monthly.NEE   (:,1)';
%    init{2} = hist_stats.likely.monthly.NEE_Night(:,1)';
%    init{3} = hist_stats.likely.monthly.Latent   (:,1)';
%    init{4} = hist_stats.likely.monthly.Sens  (:,1)';
      
   legends = {'Initial','Best'};
   xlabels = {'NEE','Night Time NEE','Latent Heat','Sensible Heat'};
   npts    = size(best{1},2);
   nplots = 1;
   for i = 1:nplots
      subaxis(4,1,i, 'Spacing', 0.015, 'Padding', 0.03, 'Margin', 0.015)
      plot(1:npts,[-init{i};-best{i}])
      set(gca,'YScale','Log')
      %set(gca,'XTickLabel',names)
      xlabel(xlabels{i})
      ylabel('Normalized Likelihood * -1')
      set(gca,'XLim',[1,npts]);
      legend(legends)
      set_monthly_labels(gca,6)
      if i == 1; title({'\bf{Model Likelihoods By Month}'}); end
   end
   
   if save;
       export_fig( gcf, figname, '-jpg', '-r150' );
   end
end


%--------------------------------------------------------------------------% 
%% Plot: Likelihoods, Analysis                New                   
%--------------------------------------------------------------------------%
if plot_likely
   figname = 'Likelihoods, Analysis';
   figure('Name',figname)
   set(gcf,'Color',[1,1,1])

   diffs     = []; % 'Best - Init' for each dataset
   keptnames = {}; % Fieldnames includes e.g. RMSE. Weed it out below.
   res       = fieldnames(hist_stats.likely);
   nres      = numel(res);
   for i = 1:nres
      fields    = fieldnames(hist_stats.likely.(res{i}));
      nfields   = numel(fields);
      for j = 1:nfields
         best  = hist_stats.likely.(res{i}).(fields{j})(:,iter_best)';
         init  = hist_stats.likely.(res{i}).(fields{j})(:,1        )';
         diffs = [diffs, sum(best - init)];
         keptnames = horzcat(keptnames, [res{i} ' ' fields{j}]);
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
   
   if numel(worse(~bmask)) > 0;
      mwors  = sum(better(~bmask));
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
gen_new_fig(figname)

ylabels = { {'NEE'        ,'tC/ha' },{'Nightly NEE'  ,'tC/ha' },...
            {'Latent Heat','MJ/m^2'},{'Sensible Heat','MJ/m^2'} };

yvals    = cell(1,4);
yvals{1} = [out_first.X.YMEAN_NEE'           , out_best.X.YMEAN_NEE'           , obs.proc.yearly.NEE      ];
% yvals{2} = [out_first.X.YMEAN_NEE_Night'     , out_best.X.YMEAN_NEE_Night'     , obs.proc.yearly.NEE_Night];
% yvals{3} = [out_first.X.YMEAN_VAPOR_CA_PY'   , out_best.X.YMEAN_VAPOR_CA_PY'   , obs.proc.yearly.Latent   ];
% yvals{4} = [out_first.X.YMEAN_SENSIBLE_CA_PY', out_best.X.YMEAN_SENSIBLE_CA_PY', obs.proc.yearly.Sens     ];

legends = {'Initial';'Best';'Obs.'};

for i = 1:1
    subaxis(4,1,i, 'Spacing', 0.005, 'Padding', 0.01, 'Margin', 0.050)
    % Bar groups by row, so bar(rand(2,3),'grouped') gives two groups of three
     bar(yvals{i},0.75,'grouped'), colormap(cool)
     legend(legends)

     if i == 4
        set(gca,'XTickLabel',opt_yr_strs)
     else
        set(gca,'XTickLabel','')
     end

     ylabel(ylabels{i})
     if i == 1
         title('Yearly Mean Fluxes')
     end
     ylimits = ylim;
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
%% Plot: Predictions, Yearly BAI and Mort     Partially Updated     
%-------------------------------------------------------------------------%
if plot_preds

figname = 'Predictions, Yearly BAI and Mort';
gen_new_fig(figname)

ylabels = { {'Hardwood BA'       ,'m^2/ha'},{'Conifer BA'          ,'m^2/ha'}...
            {'Basal Area Growth' ,'m^2/ha'},{'Basal Area Mortality','m^2/ha'} };

yvals    = cell(1,4);
% yvals{1} = [out_first.X.YMEAN_BA_HW', out_best.X.YMEAN_BA_HW'    , obs.proc.yearly.BA_Hw    ];
% yvals{2} = [out_first.X.YMEAN_BA_CO', out_best.X.YMEAN_BA_CO'    , obs.proc.yearly.BA_Co    ];
yvals{3} = [out_first.T.TOTAL_BASAL_AREA_GROWTH',...
             out_best.T.TOTAL_BASAL_AREA_GROWTH',...
             obs.proc.yearly.BAG(2:end)];
yvals{4} = [out_first.T.TOTAL_BASAL_AREA_MORT',...
             out_best.T.TOTAL_BASAL_AREA_MORT',...
             obs.proc.yearly.BAM(2:end)];
          
legends = {'Initial';'Best';'obs.proc.'};

for i = 3:4
    subaxis(2,2,i, 'Spacing', 0.005, 'Padding', 0.01, 'Margin', 0.050)
    % Bar groups by row, so bar(rand(2,3),'grouped') gives two groups of three
     bar(yvals{i},0.75,'grouped'), colormap(cool)
     legend(legends)

     if i == 1
        set(gca,'XTickLabel',opt_yr_strs)
     else
        set(gca,'XTickLabel','')
     end

     ylabel(ylabels{i})
%     if i == 1
%         title('Yearly Basal Area Increments')
%     end
     ylimits = ylim;
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
gen_new_fig(figname)

yvals    = cell(1,4);
yvals{1} = [out_first.X.MMEAN_NEE           ; out_best.X.MMEAN_NEE           ; obs.proc.monthly.NEE'      ];
% yvals{2} = [out_first.X.MMEAN_NEE_Night     ; out_best.X.MMEAN_NEE_Night     ; obs.proc.monthly.NEE_Night'];
% yvals{3} = [out_first.X.MMEAN_VAPOR_CA_PY   ; out_best.X.MMEAN_VAPOR_CA_PY   ; obs.proc.monthly.Latent'   ];
% yvals{4} = [out_first.X.MMEAN_SENSIBLE_CA_PY; out_best.X.MMEAN_SENSIBLE_CA_PY; obs.proc.monthly.Sens'     ];

titles  = {'NEE', 'Night Time NEE', 'Latent Heat', 'Sensible Heat' };
ylabels = {'tC/ha', 'tC/ha', 'MJ/m^2', 'MJ/m^2'};
legends = {'Initial','Best','obs.proc.'};

for i = 1:1
   subaxis(2,2,i, 'Spacing', 0.015, 'Padding', 0.03, 'Margin', 0.015)
      plot(1:ndm,yvals{i})
      title(titles{i})
      legend(legends,'Interpreter','None','Location','NorthWest')
      ylabel(ylabels{i})
      set(gca,'XLim',[1,ndm])
      set_monthly_labels(gca,6)
end
if save; export_fig( gcf, figname, '-jpg', '-r150' ); end

end % Plot Selector
%----------------------------------------------------------------------%




%-------------------------------------------------------------------------%
%% Plot: Predictions, Daily Fluxes            Updated                   
%-------------------------------------------------------------------------%
if plot_preds

figname = 'Daily Pred - Fluxes';
gen_new_fig(figname)

yvals = {};
yvals{1} = [out_first.X.DMEAN_NEE', out_best.X.DMEAN_NEE', obs.proc.daily.NEE ];
plot(1:numel(out_first.X.DMEAN_NEE),yvals{1})
title('Daily NEE')
legend('Initial','Best','Obs.')

   if save
       export_fig( gcf, figname, '-jpg', '-r150' );
   end
end % Plot Selector
%----------------------------------------------------------------------%




%-------------------------------------------------------------------------%
%%

end

