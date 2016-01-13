function [ ] = plot_likely_analy( iter_best, opt_type, stats, save )
%PLOT_LIKELY_ANALY Summary of this function goes here
%   Detailed explanation goes here

% hist: obj iter_best stats
% ctrl: iter
% ui  : opt_type


% if strcmp(opt_type,'PSO')
%    init_best_ind   = obj == min(obj(:,1));
%    global_best_ind = obj == min(obj(:));
%    best_inds       = or(init_best_ind,global_best_ind);
%    iter_best       = find(sum(global_best_ind));
% else
%   iter_best = iter_best;
%end



if 1%strcmp(opt_type,'PSO') || iter_best ~= 1
   figname = 'Likelihoods Analysis';
   figure('Name',figname)
   set(gcf,'Color',[1,1,1])
   %gen_new_fig(figname)

   if 1%iter > 1;
      diffs     = []; % 'Best - Init' for each dataset
      keptnames = {}; % Fieldnames includes e.g. RMSE. Weed it out below.
      res_list  = fieldnames(stats.likely);
      nres_list = numel(res_list);
      for i = 1:nres_list
         res = res_list{i};
         fields    = fieldnames(stats.likely.(res));
         nfields   = numel(fields);
         for j = 1:nfields
            fld = fields{j};
            best  = stats.likely.(res).(fld)(:,iter_best)';

            if isfield(stats,'ref')
               init  = stats.ref.likely.(res).(fld)(:,1        )';
            else
               init  = stats.likely.(res).(fld)(:,1        )';
            end

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

      bnames = char_sub(bnames,'_',' ');
      wnames = char_sub(wnames,'_',' ');

      if isempty(worse)
         worse = -1;
         wnames = {'None!'};
      end

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
   end
  
   rdegs = 15;
   subaxis(2,1.5,1,'S',0.015,'P',0.03,'M',0.03,'MB',0.05)

   row_ind  = 0;
   res_flds = fieldnames(stats.likely);

   init_likely = [];
   init_names = {};
   for res_num = 1:numel(res_flds)
      res = res_flds{res_num};
      obs_flds = fieldnames(stats.likely.(res));

      for obs_num = 1:numel(obs_flds)
         obs = obs_flds{obs_num};

         row_ind = row_ind + 1;
         init_likely(row_ind) = -1*nansum(stats.likely.(res).(obs)(:,1));
         init_names{row_ind} = [res '.' obs];
         end_likely(row_ind) = -1*nansum(stats.likely.(res).(obs)(:,iter_best));
         
         if isfield(stats,'ref')
            ref_likely(row_ind) = -1*nansum(stats.ref.likely.(res).(obs));
         end         
      end
   end

   init_names = char_sub(init_names,'_',' ');
   init_names = char_sub(init_names,'.',' ');
   
   n_names = numel(init_names);
   if isfield(stats,'ref')
      bar([ref_likely; init_likely; end_likely]')      
      legend({'Ref','Init','Best'})
   else
      bar([init_likely; end_likely]')
      legend({'Init','Best'})
   end
   
   %set(gca,'YScale','log')
   set(gca,'xtick',1:n_names)
   set(gca,'xlim',[0,n_names+1])
   set(gca,'XTickLabel',init_names)
   rotateXLabels(gca,rdegs)
   set(gca,'XGrid','on')
   set(gca,'YGrid','on')
   set(gca,'YMinorGrid','off')
   ylabel('-1 * Log Likelihood')
   title('\bf{Data Likelihoods}')
   
   subaxis(2,1.5,2.5,'S',0.015,'P',0.03,'M',0.03,'MB',0.05)
      ref_diffs = end_likely - ref_likely ;
      bar(ref_diffs')      

      %set(gca,'YScale','log')
      set(gca,'xtick',1:n_names)
      set(gca,'xlim',[0,n_names+1])
      set(gca,'XTickLabel',init_names)
      rotateXLabels(gca,rdegs)
      set(gca,'XGrid','on')
      set(gca,'YGrid','on')
      set(gca,'YMinorGrid','off')
      ylabel('-1 * Log Likelihood')
      title('\bf{\Delta_{objective} (Obj_{best} - Obj_{ref})}')
   
   set(gcf,'Position',[1 1 1280 1024]);
   set(gcf, 'Color', 'white');
   if save; export_fig( gcf, figname, '-jpg', '-r150' ); end
end



end

