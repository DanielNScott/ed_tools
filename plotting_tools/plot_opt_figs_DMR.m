function [ ] = plot_opt_figs_DMR( opt_mat_name, save)
%PLOT_OPT_FIGS Plots items from output of optimization.
%   plot_type: 'all' graphs everything. See file for more options.
%   opt_mat_name: A string containing the filename of the optimization output.
%   opt_years: The years to plot. Set to [] if all.
%   save: Boolean, save graphs?

close all;                       % Close previously open graphs
load(opt_mat_name)               % Load the data
niter = size(hist.state,2);      % Get the number of iterations completed

plot_states = 0;                 % Flag to plot parameter chains
plot_fit    = 0;                 % Flag to plot goodness-of-fit metrics

%----------------------------------------------------------------------------------------------%
% Get run info such as start and end indices of simulation
%----------------------------------------------------------------------------------------------%
[start_yr, start_mo, ~,~,~,~] = tokenize_time(hist.out_first.nl.start,'ED','num');
[end_yr  , end_mo  , ~,~,~,~] = tokenize_time(hist.out_first.nl.end  ,'ED','num');
part_yrs  = start_yr:end_yr;
whole_yrs = (start_yr + 1*(start_mo ~= 1)):(end_yr -1 - 1*(end_mo ~= 1));
for i = 1:numel(whole_yrs)
   opt_yr_strs{i} = num2str(whole_yrs(i));
end

ndyr = size(hist.stats.likely.yearly.NEE,1);    % The number of years
ndm  = size(hist.stats.likely.monthly.NEE,1);   % The number of months
%----------------------------------------------------------------------------------------------%


%--------------------------------------------------------------------------%
%% Plot: State History                                              
%-------------------------------------------------------------------------%
if plot_states
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
%--------------------------------------------------------------------------%



%-------------------------------------------------------------------------%
%% Plot: Fit                                                        
%-------------------------------------------------------------------------%
if plot_fit;
   figname = 'Fit';
   gen_new_fig(figname)

   yvals    = cell(1,4);
   yvals{1} = hist.stats.RMSE(1:iter-1);
   yvals{2} = hist.stats.R2(1:iter-1);
   yvals{3} = hist.stats.CoefDeter(1:iter-1);
   yvals{4} = hist.obj_prop(1:iter-1);
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
%% Plot: Stars                                                      
%-------------------------------------------------------------------------%
co_param_names = ...
{'vmfact','q','R_growth fact'}';
hw_param_names = ...
{'vmfact','q','stor. turn'}';
sh_param_names = ...
{'stom. slope','vm low temp','root turn', 'water cond.',...
'resp opt H2O','resp Q10','resp w1', 'resp w2'}';

co_params = [hist.state_prop(1:3,1)'   ; hist.state_prop(1:3,hist.iter_best)'    ];
hw_params = [hist.state_prop(4:6,1)'   ; hist.state_prop(4:6,hist.iter_best)'    ];
sh_params = [hist.state_prop(7:end,1)' ; hist.state_prop(7:end,hist.iter_best)'  ];
starplot(co_params,co_param_names,'Conifer Parameters' ,save)
starplot(hw_params,hw_param_names,'Hardwood Parameters',save)
starplot(sh_params,sh_param_names,'Shared Parameters',save)

%-------------------------------------------------------------------------%
%% Plot: Likelihoods, Analysis                                      
%--------------------------------------------------------------------------%
if hist.iter_best ~= 1
   figname = 'Likelihoods Analysis';
   figure('Name',figname)
   set(gcf,'Color',[1,1,1])

   diffs     = []; % 'Best - Init' for each dataset
   keptnames = {}; % Fieldnames includes e.g. RMSE. Weed it out below.
   res_list  = fieldnames(hist.stats.likely);
   nres_list = numel(res_list);
   for i = 1:nres_list
      res = res_list{i};
      fields    = fieldnames(hist.stats.likely.(res));
      nfields   = numel(fields);
      for j = 1:nfields
         fld = fields{j};
         best  = hist.stats.likely.(res).(fld)(:,hist.iter_best)';
         init  = hist.stats.likely.(res).(fld)(:,1        )';
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
%% Plot: Daily, Monthly, Yearly Pred/Likely                         
%-------------------------------------------------------------------------%
figname = 'Yearly, Monthly, and Daily NEE';
gen_new_fig(figname)

pntr  = {};
yvals = {};
envel = {};
lgnds = {};
ylabs = {};
xlabs = {};
titles = {};

pntr{1}  = data.obs.proc.yearly;
pntr{2}  = data.obs.proc.monthly;
pntr{3}  = data.obs.proc.daily;

yvals{1} = [hist.out_first.Y.YMEAN_NEE', hist.out_best.Y.YMEAN_NEE', pntr{1}.NEE];
yvals{2} = [hist.out_first.Y.MMEAN_NEE;  hist.out_best.Y.MMEAN_NEE];
yvals{3} = [hist.out_first.Y.DMEAN_NEE', hist.out_best.Y.DMEAN_NEE'];
yvals{4} = [-1* hist.stats.likely.yearly.NEE(:,1), ...
            -1* hist.stats.likely.yearly.NEE(:,hist.iter_best)];
yvals{5} = [-1* hist.stats.likely.monthly.NEE(:,1)'; ...
            -1* hist.stats.likely.monthly.NEE(:,hist.iter_best)'];
yvals{6} = [-1* hist.stats.likely.daily.NEE(:,1)';...
            -1* hist.stats.likely.daily.NEE(:,hist.iter_best)'];
         
zero_pad = zeros(ndyr,1);
envel{1} = [zero_pad,zero_pad,2*pntr{1}.NEE_sd];
envel{2} = {pntr{2}.NEE + 2*pntr{2}.NEE_sd, pntr{2}.NEE - 2*pntr{2}.NEE_sd};
envel{3} = {pntr{3}.NEE - 2*pntr{3}.NEE_sd, pntr{3}.NEE + 2*pntr{3}.NEE_sd};

lgnds{1} = {'Initial','Best','Obs.'};
lgnds{2} = {'Obs.','Initial','Best'};
lgnds{3} = {'Obs.','Initial','Best'};
lgnds{4} = {'Initial','Best'};
lgnds{5} = {'Initial','Best'};
lgnds{6} = {'Initial','Best'};

titles  = {'Yearly Mean NEE'   , 'Monthly Mean NEE'   , 'Daily Mean NEE',...
           'Yearly Likelihoods', 'Monthly Likelihoods', 'Daily Likelihoods'};
xlabs   = {'Years' , 'Months', 'Days since Jan 1, 1994' , ...
           'Years' , 'Months', 'Days since Jan 1, 1994'};
ylabs   = {'tC/ha', 'tC/ha', 'tC/ha', ...
           '-1* Log Likelihood', '-1* Log Likelihood', '-1* Log Likelihood'};

for i = 1:6
   subaxis(2,3,i, 'Spacing', 0.015, 'Padding', 0.02, 'Margin', 0.05)
   
   if i == 1;
      barwitherr(envel{1},yvals{1},0.75,'grouped')
%      freezeColors();
      %colormap(cool)
   elseif i == 2;
      hold on
      ciplot(envel{2}{1},envel{2}{2},1:ndm,'r');
      plot(1:ndm,yvals{2})
      hold off
%      freezeColors();
   elseif i == 3;
      npts = numel(hist.out_first.X.DMEAN_NEE);
      hold on
      ciplot(envel{3}{1},envel{3}{2},1:npts,'r')
      plot(1:npts,yvals{3})
      hold off
%      freezeColors();
   elseif i == 4;
      bar(yvals{4},0.75,'grouped')
%      colormap(cool)
   elseif i == 5;
      plot(1:ndm,yvals{5})
   elseif i == 6;
      plot(1:npts,yvals{6})
   end
   
   title(['\bf' titles{i}])
   legend(lgnds{i})

   ylimits = ylim;
   if ylimits(1) > 0 && ylimits(2) > 0
      ylim( [0,ylimits(2)] )
   elseif ylimits(1) < 0 && ylimits(2) < 0
      ylim( [ylimits(1), 0])
   end

   if i == 1 || i == 4
      ylabel(ylabs{i})
      set(gca,'XTickLabel',opt_yr_strs)
   end
   if i > 3
      xlabel(xlabs{i})
   end
   
   if any(i == [2,5])
      set(gca,'XLim',[1,ndm])
      set_monthly_labels(gca,6)
   end

end
if save; export_fig( gcf, figname, '-jpg', '-r150' ); end

%-------------------------------------------------------------------------%
%% Plot: BAI and Mort                                               
%-------------------------------------------------------------------------%
figname = 'BAI and Mort.';
gen_new_fig(figname)

titles = {'Basal Area Growth'   , 'Hw Basal Area Growth'   , 'Co Basal Area Growth'   , ...
          'Growth Likelihoods'  , 'Hw Growth Likelihoods'  , 'Co Growth Likelihoods'  , ...
          'Basal Area Mortality', 'Hw Basal Area Mortality', 'Co Basal Area Mortality', ...
          'Mort. Likelihoods'   , 'Hw Mort. Likelihoods'   , 'Co Mort. Likelihoods'   , ...
          };

ylabs{1}  = 'm^2/ha';
ylabs{2}  = '-1* Log Likelihood';
pntr   = data.obs.proc.yearly;

yvals    = cell(1,6);
yvals{1} = [hist.out_first.T.TOTAL_BASAL_AREA_GROWTH',...
            hist.out_best.T.TOTAL_BASAL_AREA_GROWTH',...
            pntr.BAG(2:end)];
yvals{2} = [hist.out_first.H.BASAL_AREA_GROWTH',...
            hist.out_best.H.BASAL_AREA_GROWTH',...
            pntr.BAG_Hw(2:end)];
yvals{3} = [hist.out_first.C.BASAL_AREA_GROWTH',...
            hist.out_best.C.BASAL_AREA_GROWTH',...
            pntr.BAG_Co(2:end)];
yvals{4}  = [-1* hist.stats.likely.yearly.BAG(:,1),...
             -1* hist.stats.likely.yearly.BAG(:,hist.iter_best)];
yvals{5}  = [-1* hist.stats.likely.yearly.BAG_Hw(:,1),...
             -1* hist.stats.likely.yearly.BAG_Hw(:,hist.iter_best)];
yvals{6}  = [-1* hist.stats.likely.yearly.BAG_Co(:,1),...
             -1* hist.stats.likely.yearly.BAG_Co(:,hist.iter_best)];
          
yvals{7} = [hist.out_first.T.TOTAL_BASAL_AREA_MORT',...
            hist.out_best.T.TOTAL_BASAL_AREA_MORT',...
            pntr.BAM(2:end)];
yvals{8} = [hist.out_first.H.BASAL_AREA_MORT',...
            hist.out_best.H.BASAL_AREA_MORT',...
            pntr.BAM_Hw(2:end)];
yvals{9} = [hist.out_first.C.BASAL_AREA_MORT',...
            hist.out_best.C.BASAL_AREA_MORT',...
            pntr.BAM_Co(2:end)];
yvals{10} = [-1* hist.stats.likely.yearly.BAM(:,1),...
             -1* hist.stats.likely.yearly.BAM(:,hist.iter_best)];
yvals{11} = [-1* hist.stats.likely.yearly.BAM_Hw(:,1),...
             -1* hist.stats.likely.yearly.BAM_Hw(:,hist.iter_best)];
yvals{12} = [-1* hist.stats.likely.yearly.BAM_Co(:,1),...
             -1* hist.stats.likely.yearly.BAM_Co(:,hist.iter_best)];
            
         
err{1} = pntr.BAG_sd(2:end);
err{2} = pntr.BAM_sd(2:end);
err{3} = pntr.BAG_Hw_sd(2:end);
err{4} = [];
err{5} = [];
err{6} = [];
err{7} = pntr.BAM_Hw_sd(2:end);
err{8} = pntr.BAG_Co_sd(2:end);
err{9} = pntr.BAM_Co_sd(2:end);
         
lgnds{1} = {'Initial';'Best';'Obs.'};
lgnds{2} = {'Initial','Best'};

barcolors = [0,1,1; 0.5,0.5,1; 1,0,1];

for i = 1:12
   subaxis(4,3,i, 'Spacing', 0.015, 'Padding', 0.02, 'Margin', 0.05)
   % Bar groups by row, so bar(rand(2,3),'grouped') gives two groups of three
   %bar(yvals{i},0.75,'grouped'), colormap(cool)
   if any(i == [1,2,3,7,8,9])
      barwitherr([zero_pad,zero_pad,2*err{i}],yvals{i},0.75,'grouped');
      colormap(cool)
      legend(lgnds{1})
   else
      bar(yvals{i},0.75,'grouped');
      legend(lgnds{2})
   end

   set(gca,'XTickLabel',opt_yr_strs)
   %if i > 9
   %   xlabel('Model Year')
   %end

   if any(i == [1,7])
      ylabel(ylabs{1});
   elseif any(i == [4,10])
      ylabel(ylabs{2})
   end
%     if i == 1
%         title('Yearly Basal Area Increments')
%     end
   ylimits = ylim;
   title(['\bf' titles{i}])
   if ylimits(1) > 0 && ylimits(2) > 0
       ylim( [0,ylimits(2)] )
   elseif ylimits(1) < 0 && ylimits(2) < 0
       ylim( [ylimits(1), 0])
   end
end
if save; export_fig( gcf, figname, '-jpg', '-r150' ); end

%-------------------------------------------------------------------------%
%% Plot: Hourly Fluxes                                              
%-------------------------------------------------------------------------%
figname = 'Hourly Fluxes';
gen_new_fig(figname)

pntr  = data.obs.proc.hourly;
yvals = cell(1:4);
yvals{1} = [hist.out_first.Y.FMEAN_NEE'        , hist.out_best.Y.FMEAN_NEE'        , pntr.NEE];
yvals{2} = [hist.out_first.X.FMEAN_NEE_Day'    , hist.out_best.X.FMEAN_NEE_Day'    , pntr.NEE_Day];
yvals{3} = [hist.out_first.X.FMEAN_NEE_Night'  , hist.out_best.X.FMEAN_NEE_Night'  , pntr.NEE_Night];
yvals{4} = [hist.out_first.Y.FMEAN_VAPOR_CA_PY', hist.out_best.Y.FMEAN_VAPOR_CA_PY', pntr.Latent];

%envel = {[pntr.NEE       - pntr.NEE_sd      , pntr.NEE       + pntr.NEE_sd       ];...
%         [pntr.NEE_Day   - pntr.NEE_Day_sd  , pntr.NEE_Day   + pntr.NEE_Day_sd   ];...
%         [pntr.NEE_Night - pntr.NEE_Night_sd, pntr.NEE_Night + pntr.NEE_Night_sd ];...
%         [pntr.Latent    - pntr.Latent_sd   , pntr.Latent    + pntr.Latent_sd    ]   };


titles  = {'Hourly NEE', 'Hourly Daytime NEE', 'Hourly Night Time NEE', 'Hourly Latent Heat Flux'};
ylabels = {'tC/ha', 'tC/ha', 'tC/ha', 'W/m^2'};

npts = numel(hist.out_first.X.FMEAN_NEE);
for i = 1:4
   subaxis(4,1,i, 'Spacing', 0.015, 'Padding', 0.015, 'Margin', 0.050)
      hold on
      plot(1:npts,yvals{i})
      hold off
      title(['\bf' titles{i}])
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

if save; export_fig( gcf, figname, '-jpg', '-r150' ); end

%-------------------------------------------------------------------------%
%%





end
