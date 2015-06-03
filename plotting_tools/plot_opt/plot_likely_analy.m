function [ ] = plot_likely_analy( ctrl,data,hist,nfo,ui,save )
%PLOT_LIKELY_ANALY Summary of this function goes here
%   Detailed explanation goes here

if strcmp(ui.opt_type,'PSO')
   init_best_ind   = hist.obj == min(hist.obj(:,1));
   global_best_ind = hist.obj == min(hist.obj(:));
   best_inds       = or(init_best_ind,global_best_ind);
   iter_best       = find(sum(global_best_ind));
else
   iter_best = hist.iter_best;
end



if strcmp(ui.opt_type,'PSO') || iter_best ~= 1
   figname = 'Likelihoods Analysis';
   figure('Name',figname)
   %gen_new_fig(figname)
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
         best  = hist.stats.likely.(res).(fld)(:,iter_best)';
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
   
   sworse = sum(-worse);
   if sworse < 1
      worse = worse * 1/sworse;
   end
   sbetter = sum(better);
   if sworse < 1
      better = better * 1/sbetter;
   end
   
   bnames = str_to_space(bnames,'_');
   wnames = str_to_space(wnames,'_');
   
   % All log likelihoods are actually negative, and we want to maximize their sum, i.e.
   % to minimize the sum of their opposite. So improvement would be indicated by 'best'
   % likelihoods being less negative than 'initial' likelihoods. Meaning the greater
   % "best - init" is, the more improvement there is.
   subaxis(2,3,3,'S',0.015,'P',0.03,'Margin',0.015)
   pie(double(better)); colormap(cool);
   title('\bf{Better}')
   legend(bnames,'Interpreter','None','Location','SouthEast')
   
   subaxis(2,3,6,'S',0.015,'P',0.03,'Margin',0.015)
   pie(double(-worse));
   title('\bf{Worse}')
   legend(wnames,'Interpreter','None','Location','SouthEast')
    
  
   
   
   
   rdegs = 15;
   subaxis(1,1.5,1,'S',0.015,'P',0.03,'M',0.03,'MB',0.05)

   row_ind  = 0;
   res_flds = fieldnames(hist.stats.likely);

   init_likely = [];
   init_names = {};
   for res_num = 1:numel(res_flds)
      res = res_flds{res_num};
      obs_flds = fieldnames(hist.stats.likely.(res));

      for obs_num = 1:numel(obs_flds)
         obs = obs_flds{obs_num};

         row_ind = row_ind + 1;
         init_likely(row_ind) = -1*nansum(hist.stats.likely.(res).(obs)(:,1));
         init_names{row_ind} = [res '.' obs];
         end_likely(row_ind) = -1*nansum(hist.stats.likely.(res).(obs)(:,iter_best));
      end
   end

   init_names = str_to_space(init_names,'_');
   init_names = str_to_space(init_names,'.');
   
   bar([init_likely; end_likely]')
   %set(gca,'YScale','log')
   set(gca,'XTickLabel',init_names)
   rotateXLabels(gca,rdegs)
   set(gca,'YGrid','on')
   set(gca,'YMinorGrid','off')
   ylabel('-1 * Log Likelihood')
   legend({'Ref','Best'})
   title('\bf{Data Likelihoods}')
   
   if save; export_fig( gcf, figname, '-jpg', '-r150' ); end
end



end

