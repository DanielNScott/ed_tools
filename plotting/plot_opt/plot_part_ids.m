function [ ] = plot_part_ids( cfe, hist, ui )
%PLOT_PART_IDS Summary of this function goes here
%   Detailed explanation goes here


labels = cfe.labels(:,1);                                 % Alias the param labels.
nlabs  = numel(labels);
iter   = cfe.iter;
nps    = size(hist.state,2);

q_msk = strcmp(labels,'q');
if any(q_msk) > 0
   q_flds = labels(q_msk);
   q_flds{1} = 'q_co';
   q_flds{2} = 'q_hw';
   labels(q_msk) = q_flds;
end

best_msk  = hist.obj == repmat(min(hist.obj),ui.nps,1);
best_inds = find(best_msk) - ui.nps*[0:cfe.iter-1]';

%init_best_ind   = hist.obj == min(hist.obj(:,1));
%global_best_ind = hist.obj == min(hist.obj(:));
%best_inds       = or(init_best_ind,global_best_ind);
%best_params     = hist.state(:,best_inds);


figname = 'State History';                               % Name a new fig.
gen_new_fig(figname)                                     % And create it
nparams = size(hist.state,1);

subaxis(2,2,1,'S',0.015,'P',0.010,'M',0.03,'PB',0.03)
   plot(1:cfe.iter-1,best_inds,'o')
   title('\bf{Indices of Best Particles}')

nrows = -floor(-numel(labels)/2);                     % How many rows of plots?
for iplt = 1:nlabs

   row_msk  = strcmp(labels(iplt),labels);
   hist_msk = zeros(size(hist.state));
   hist_msk(row_msk,:,1:iter-1) = 1;
   
   best_msk = zeros(size(hist_msk));
   best_msk(iplt,:,:) = hist.obj == repmat(min(hist.obj),ui.nps,1);

subaxis(nrows,2,iplt,'S',0.015,'P',0.010,'M',0.03,'PB',0.03)
      pvals = hist.state(logical(hist_msk));
      pvals = reshape(pvals,nps,iter-1)';
      
      bvals = hist.state(logical(best_msk));
      bvals = reshape(bvals,1,iter)';

end


end

