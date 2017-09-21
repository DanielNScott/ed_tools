function [betas, design, labels, design_fn] = fit_quad_to_pso_objs(max_prctile, hst, ui, cfe)

% Get number of parameters being optimized
n_params = size(hst.state,1);

% Create vectors of particle location and corrosponding objectives
flat_locs = reshape(hst.state, [n_params, ui.nps *ui.niter]);
flat_locs = flat_locs';
flat_objs = hst.obj(:);

%reshape(hst.obj        , [ui.nps *ui.niter, 1]);
%big_sol   = repmat( hst.best_state', [ui.nps *ui.niter]);

% Determine particle distance from best fit
sq_diffs = bsxfun(@minus, flat_locs, hst.best_state').^2;
dists    = sqrt(sum(sq_diffs, 2));

% Mask out percentile of data in terms of euclidean distance.
% These particles will be used to construct the response surface.
prctile_msk = dists < prctile(dists, max_prctile);
best_p_locs = flat_locs(prctile_msk,:);

% Create a design matrix for a linear model of objective vals on location
design    = sq_design( best_p_locs(:,1:(n_params-1)) );
design_fn = @(x) sq_design(x);

[betas, stats] = robustfit(design(:,2:end), flat_objs(prctile_msk));

labels = {};
labels{1} = 'intercept';
labels(2:n_params) = ui.params(1:(n_params-1),1);
labels((n_params+1):(2*n_params-1)) = ui.params(1:(n_params-1),1);
for i = 1:length(labels)
   labels{i}(labels{i} == '_') = ' ';
end
for i = (n_params+1):(2*n_params-1)
   labels{i} = [labels{i}, '^2'];
end

figure()
%subplot(2,2,1)
bar(betas)
set(gca,'XTick',1:sum(length(betas)))
%set(gca,'XLim',[0,sum(squares)+1])
set(gca,'XTickLabel',labels)
rotateXLabels(gca,30)
set(gca,'XGrid','on')
title('\bf{Fit Surface Coefficient by Parameter}')

figure()
subplot(2,2,2)
plot(stats.resid)
title('\bf{Residuals}')

subplot(2,2,3)
hist(stats.resid)
title('\bf{Residual Histogram}')

subplot(2,2,4)
%plot_obj_fn(hst,ui,cfe)
title('\bf{Objective Function Evaluations}')

end

% Ordinary regression:
%(X'*X)^(-1)*(X'*flat_objs(msk))

% Ridge regression:
% Unclear what I'm getting out of this... something very warped I think.
%
% C = (X'*X + diag(ones(1,size(X,2))) )^(-1)*(X'*flat_objs(msk));
% plot(C)


function [] = plot_obj_fn(hst,ui,cfe)

last_iter = cfe.iter;
nparams = size(hst.state,1);
nps = ui.nps;
niter = ui.niter;

reshaped = reshape(hst.state,nparams,nps*niter);
coords   = reshaped(1:(nparams-1),1:(nps*last_iter));

objs = reshape(hst.obj,1,nps*niter);
objs = objs(1:(last_iter*nps));

msk = ones(1,700);
msk(max(objs) == objs) = 0;
msk = boolean(msk);

x = coords(1,:);
y = coords(2,:);
z = coords(3,:);

msk = objs < prctile(objs,100);
scatter3(x(msk),y(msk),z(msk),20,log(objs(msk)), 'o');

hold on;
msk = objs < prctile(objs,10);
scatter3(x(msk),y(msk),z(msk),20,log(objs(msk)), 'filled', 'or');

xlabel('vmfact_hw','Interpreter','None')
ylabel('growth_resp','Interpreter','None')
zlabel('storage_resp_hw','Interpreter','None')

end


function[] = old_plot_obj_fn()
   last_iter = cfe.iter;
   nparams = size(hist.state,1);
   nps = ui.nps;
   niter = ui.niter;

   n_samples = nps*last_iter;

   reshaped = reshape(hist.state,nparams,nps*niter);
   coords   = reshaped(1:(nparams-1),1:n_samples);

   objs = reshape(hist.obj,1,nps*niter);
   objs = objs(1:n_samples);

   msk = ones(1,n_samples);
   msk(objs >= prctile(objs,95)) = 0;
   msk = boolean(msk);

   x = coords(1,:);
   y = coords(2,:);
   z = objs;

   x = x(msk);
   y = y(msk);
   z = z(msk);

   xlin = linspace(min(x),max(x),n_samples);
   ylin = linspace(min(y),max(y),n_samples);

   [X,Y] = meshgrid(xlin,ylin);

   f = scatteredInterpolant(x',y',z','linear','none');

   Z = f(X,Y);

   figure
   mesh(X,Y,Z) %interpolated

   axis tight; hold on

   plot3(x,y,z,'.','MarkerSize',15,'Color','r') %nonuniform
end
