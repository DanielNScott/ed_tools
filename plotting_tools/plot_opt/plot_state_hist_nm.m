function [ ] = plot_state_hist_nm( cfe, hist, ui, save )
%PLOT_STATE_HISTORY Summary of this function goes here
%   Detailed explanation goes here

labels = cfe.labels(:,1);                                 % Alias the param labels.
nlabs  = numel(labels);
iter   = cfe.iter;

q_msk = strcmp(labels,'q');
if any(q_msk) > 0
   q_flds = labels(q_msk);
   q_flds{1} = 'q_co';
   q_flds{2} = 'q_hw';
   labels(q_msk) = q_flds;
end


cents = [];
bests = [];
for ismp = 1:ui.nsimp
   cents(:,:,:,ismp) = hist.smplx(ismp).state;
   bests(:,:,ismp) = squeeze(hist.smplx(ismp).state(:,1,:));
end
cents = squeeze(mean(cents,2));

nps = ui.nsimp;


figname = 'State History';                               % Name a new fig.
gen_new_fig(figname)                                     % And create it

nrows = -floor(-numel(labels)/2);                     % How many rows of plots?
for iplt = 1:nlabs

   subaxis(nrows,2,iplt,'S',0.015,'P',0.010,'M',0.03,'PB',0.03)
      
      hold on
      if nps > 60;
         marker = '.';
      else
         marker = '--o';
      end
      
      % We want to plot every simplex's centroid's parameters at every iteration and every
      % simplex's best parameter set's value of each parameter at every iteration.
      %hold on
      %plot(1:iter-1,squeeze(bests(iplt,1:iter-1,:))','o')
      plot(1:iter-1,squeeze(cents(iplt,1:iter-1,:))',marker)
      %hold off
      
      set(gca,'XLim',[0,iter]);
%     legend(names,'Interpreter','None','Location','NorthWest')
      if any(iplt == [nlabs-1, nlabs])
          xlabel('Iterations')
      end
      
      if mod(iplt,2) == 1;
         ylabel('Parameter Values')
      end
      raw_title = labels{iplt};
      raw_title(raw_title == '_') = ' ';
      title(['\bf{' raw_title '}' ])
      %legend({'Smplx 1','Smplx 2','Smplx 3','Smplx 4'})
end

if save;
    export_fig( gcf, figname, '-jpg', '-r150' );
end
   
end

