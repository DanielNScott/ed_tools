function [cov, betas, design, labels, design_fn] = fit_quad_to_pso_objs(tmin, tmax, tuse, nevals, locs, objs, params, ref_state, save, fileID)
% 
% Summary: Fit 

set(0,'DefaultAxesXGrid','on')
set(0,'DefaultAxesYGrid','on')

% Other control variables
cut_mort = 1;
censor   = 0;
tstep    = 0.25;

plot_eig = 0;
plot_gof = 0;
plot_cov = 1;

% Get number of parameters being optimized
n_params = length(ref_state);

% Determine particle distance from best fit
sq_diffs = bsxfun(@minus, locs, ref_state).^2;
dists    = sqrt(sum(sq_diffs, 2));

% Remove the (constant) mortality parameter
if cut_mort
    n_params = n_params - 1;
    params   = params(1:(end-1),1)';
end

% Ideally, at least 2 observations on every side of every dimension.
% This won't actually be a good approx to the number req for as dim.
% increases, but we'll say it's good enough for dim ~ 10...
n_betas_estimated = (1 + n_params + (n_params+1)*n_params/2);

% Arrays for storing values at every threshold:
all_stats = [];
all_betas = [];
all_evals = [];
all_evecs = [];
all_covar = [];

all_LD_rho = [];
all_rho_used = [];
all_cond = [];

all_nevals = [];

thresholds = tmin:tstep:tmax;
use_index  = find(tmin:tstep:tmax == tuse);
for prc = thresholds
    disp(' ')
    disp(['Processing threshold: ', num2str(prc)])
    
    % Mask out percentile of data in terms of euclidean distance.
    % These particles will be used to construct the response surface.
    prctile_msk = dists < prctile(dists, prc);
    best_p_locs = locs(prctile_msk,:);

    % Create a design matrix for a linear model of objective vals on location
    [design, labels] = sq_design( best_p_locs(:, 1:n_params), params );
    design_fn = @(x) sq_design(x);

    % Use robust fit to get weightings
    [betas, stats] = robustfit(design(:,2:end), objs(prctile_msk));
    wgts = stats.w'*eye(length(stats.w));
    
    % Can verify this is correct by entering "wgted_des\wgted_obj"
    % to get same betas
    wgted_des = sqrt(wgts)*design;
    wgted_obj = sqrt(wgts)*objs(prctile_msk);
    
    %
    %[ridge(wgted_obj, wgted_des(:,2:end), 0, 0), wgted_des\wgted_obj, robustfit(design(:,2:end), objs(prctile_msk))]

    %----------------------------------------------------------------------%
    %           Betas, the FIM, and the inverse covariance matrix          %
    %----------------------------------------------------------------------%
    % Taking the likelihood to be approximately gaussian: 
    %
    %         p = a*exp( (1/2) * x' * sigma^-1 * x)
    %   -log(p) = (1/2) * x' * sigma^-1 * x - log(a)
    %
    % hence:
    % -log(p)'' = sigma^-1            for diagonal terms
    % -log(p)'' = (1/2) * sigma^-1    for off diagonal terms
    %
    % while:
    %    beta = (1/2) * sigma^-1      for each term.
    %
    % So we take the betas and construct the inverse of the covariance.
    %----------------------------------------------------------------------%
    inv_covar = vec2sym(betas(n_params+2:end));
    
    for i = 1:n_params
        inv_covar(i,i) = 2*inv_covar(i,i);
    end

    % Inverse of FIM gives covariance matrix, eigenvalues / vecs give
    % hierarchy of directional uncertainty.
    covar = inv(inv_covar);
    %covar = nearestSPD(covar);
    disp(['cond: ', num2str(cond(inv_covar))])
    [eigenvecs, eigenvals] = eig(covar);
    eigenvals = diag(eigenvals);

    %[U,S] = svd(covar);
    %M = U * S * S' * U';
    %new_eigenvals = eig(M);

    % Check if any eigenvalues are less than 0
    reg = 1;
    [~, LD_rho] = regularize(inv_covar, 0);
    
    rho = -0.05; % So rho starts at 0.
    while reg && rho < 1
        rho = min(rho + 0.05,1);

        [inv_covar_reg, rho] = regularize(inv_covar, rho);
        cond_num = cond(inv_covar_reg);
        covar = inv(inv_covar_reg);
        [eigenvecs, eigenvals] = eig(covar);
        eigenvals = diag(eigenvals);
        
        reg = sum(eigenvals > 0)/length(eigenvals) < 1;
    end
    if reg
        disp('Failure to recover positive eigenvalues.')
    else
        disp(['accepted rho: ', num2str(rho)])
        %diff = sym2vec(abs((covar - inv(inv_covar))./inv(inv_covar)))';
        %disp(diff)
    end
    
    % Unpack inverted FIM into covariance matrix terms
    covar_terms = sym2vec(covar);

    all_stats = [all_stats, stats.se./betas];
    all_betas = [all_betas, betas          ];
    all_evals = [all_evals, eigenvals      ];
    all_evecs = [all_evecs, eigenvecs(:)   ]; % (:) stacks cols.
    all_covar = [all_covar, covar_terms    ];
    all_LD_rho = [all_LD_rho, LD_rho    ];
    all_rho_used = [all_rho_used, rho  ];
    all_cond = [all_cond, cond_num  ];
    
    if prc == tuse
        save_stats  = stats;
        save_betas  = betas;
        save_design = design;
        save_evecs  = eigenvecs;
        save_evals  = eigenvals;
        save_best_p = best_p_locs;
        save_covar  = covar_terms;
        save_diag   = diag(covar);
        use_prctile_msk = prctile_msk;
    end
end
%best_p_locs = save_best_p;
%
sq_selector = (n_betas_estimated - (n_params + 1)*n_params/2+1):length(betas);
coefficients_of_variation = abs(all_stats(sq_selector,:)'./all_betas(sq_selector,:)'*100);

if censor
    delete = logical(sum(coefficients_of_variation > 50,2));
    all_stats(:,delete) = NaN;
    all_betas(:,delete) = NaN;
    all_evals(:,delete) = NaN;
    all_evecs(:,delete) = NaN;
    all_covar(:,delete) = NaN;
    coefficients_of_variation(delete,:) = NaN;
end

% Get short, unique param names
params = short_pnames(params);

figname = 'Fit parameters';
figure('Name', figname)
% Fit surface weights
subplot(2,3,1)
%npts = floor((tmin:tstep:tmax)*size(locs,1)/100);
plot(thresholds, all_betas(sq_selector,:)');
xlim([min(thresholds), max(thresholds)])
%line([size(locs,1)*tuse/100, size(locs,1)*tuse/100], ylim, 'LineStyle','--', 'Color', 'r')
line([tuse, tuse], ylim, 'LineStyle','--', 'Color', 'r')
title('Surface parameters')
xlabel('Inclusion Threshold [percentile]')
%xlabel('Inclusion threshold [points]')
ylabel('Regression weight')

% Weight coefficients of variation
subplot(2,3,2)
plot(thresholds, coefficients_of_variation);
title('Weight Estimate CVs')
xlabel('Inclusion Threshold [percentile]')
ylabel('S.E. as % of Mean [%]')

% Covariance matrix elements
subplot(2,3,3)
semilogy(thresholds, abs(all_covar'));
title('Covariance Matrix Elements')
xlabel('Inclusion Threshold [percentile]')
ylabel('Element Value')

% Covariance matrix eigenvalues
ax = subplot(2,3,4);
set(gca,'NextPlot','replacechildren', 'ColorOrder', linspecer(9));
semilogy(thresholds, all_evals');
colormap(ax, parula);
%[~, hObj] = legend(abbrev_labels);
%hL = findobj(hObj,'type','line');  % get the lines, not text
%set(hL,'linewidth',2)              % set their width property

title('Eigenvalues of \Sigma')
xlabel('Inclusion Threshold [percentile]')

% Goodness of Fit Stuff
subplot(2,3,5)
distances = dist(ref_state, save_best_p');
plot(distances, save_stats.resid, 'o')
xlim([0, max(distances)]);
line(xlim, [0, 0], 'LineStyle', '--', 'Color', 'b')
title('Residuals by Dist')
xlabel('Distance')
ylabel('Residual')

% Coverage in each dimension
%subplot(2,4,6)
%boxplot(save_best_p(:,1:n_params), 'positions', 1:n_params, 'labels', params)
%title('Parameter Coverage')
%xlabel('Parameters')
%ylabel('Parameter Values')

subplot(2,3,6)
ax = plotyy(thresholds, [all_LD_rho; all_rho_used], thresholds, all_cond);
title('Regularization')
xlabel('Threshold [prctile]')
ylabel(ax(1), 'Identity mixing fraction')
ylabel(ax(2), 'Condition number')

set(gcf, 'Position', [100, 108, 1672, 840])

if save; latex_figure(gcf, figname, fileID); end

figname = 'Uncertainty covariance';
figure('Name',figname)
% Covariance matrix as heat map
%subplot(1,2,1)
heatmap(params, params, corrcov(vec2sym(save_covar)), 'Colormap', parula);
caxis([-1,1])
title('Uncertainty covariance')
if save; latex_figure(gcf, figname, fileID); end

figname = 'Unit eigenvectors';
figure('Name', figname)
subplot(2,1,1)
b = bar(save_evals(end:-1:(end-nevals+1)), 'FaceColor','flat');
set(gca,'yscale','log')
title('Eigenvalues')
xlabel('Eigenvector num.')
ylabel('Eigenvalue')

subplot(2,1,2)
bar(save_evecs(:,end:-1:(end-nevals+1)))
title('Unit eigenvectors')
xlabel('Parameters')
ylabel('Loadings')
xticklabels(params)
set(gcf, 'Position', [95, 420, 1148, 542])
axis tight
if save; latex_figure(gcf, figname, fileID); end


if plot_cov     
    cov = vec2sym(save_covar);
    lb = [];
    ub = [];
    figname = 'Pairwise uncertainties';
    figure('Name', figname)
    for i = 1:n_params
        for j = i:n_params
            subplot(n_params, n_params, (i-1)*n_params + j)
            try
                if i ==j
                    histogram(save_best_p(:,i))

                    ylimit = get(gca,'YLim');
                    lb(i) = ref_state(i) - sqrt(save_diag(i));
                    ub(i) = ref_state(i) + sqrt(save_diag(i));
                    line([lb(i),lb(i)], [0,ylimit(2)], 'LineStyle', '--', 'Color', 'r')
                    line([ub(i),ub(i)], [0,ylimit(2)], 'LineStyle', '--', 'Color', 'r')
                    
                    %legend({'marginal', '95% CI'})
                    title(params{i})
                else
                    error_ellipse([cov(i,i), cov(i,j); cov(j,i), cov(j,j)], ref_state)
                    axis('equal')
                    
                    xbnd = sqrt(save_diag(i));
                    ybnd = sqrt(save_diag(j));
                    
                    hold on
                    errorbar(ref_state(1), ref_state(2), ybnd, ybnd, xbnd, xbnd, 'o')
                    hold off
                    
                    title([params{i}, '*', params{j}])
                    %legend({'95% CR', '95% CIs'})
                end 
            catch exception
                disp(exception)
            end
        end
    end
    if save; latex_figure(gcf, figname, fileID); end
end


if plot_eig
    % Plot the eigenvalues and eigenvectors
    figure()
    small_eig = all_evecs(1:2,:)';
    large_eig = all_evecs(3:4,:)';
    zero_vec  = zeros(length(small_eig),1);

    n_eig = size(small_eig,1);
    small_eig_colors = parula(n_eig);
    large_eig_colors = parula(n_eig);

    subplot(1,2,1)
    hold on
    for row = 1:n_eig
        quiver(0,0, small_eig(row,1), small_eig(row,2), 'color', small_eig_colors(row,:));
    end
    title('Unit-Eigenvectors (Small)')
    %xlabel('Inclusion Threshold [percentile]')
    xlim([-1,1])
    ylim([-1,1])

    subplot(1,2,2)
    hold on
    for row = 1:n_eig
        quiver(0,0, large_eig(row,1), large_eig(row,2), 'color', large_eig_colors(row,:));
    end
    title('Unit-Eigenvectors (Large)')
    %xlabel('Inclusion Threshold [percentile]')
    xlim([-1,1])
    ylim([-1,1])
end

if plot_gof
    % Goodness of Fit Stuff
    figure()
    subplot(1,2,1)
    plot(save_stats.resid)
    title('\bf{Residuals}')

    subplot(1,2,2)
    hist(save_stats.resid)
    title('\bf{Residual Histogram}')
end


end

% Approximate parameter 95% CI's and CR:
%
% The 'local' gaussian being approximated here by assuming a quadratic
% log-likelihood has form N(sol, 1/sqrt(FIM)).
%
% Hence, the 95% confidence elipse is given by:
%
%   n * (sol - x)' * S^-1 * (sol - x) <= (n-1)*p*F(p,n-p,alpha)/(n-p)
%
% where S^-1 is the inverse of the sample covariance matrix, i.e. the FIM.
% (or, more technically, the observed information matrix in our approx.)
%
% Here p is the dimension of the gaussian, n is number of subjects.


function [sigma, rho] = regularize(S, rho)

    % OAS shrinkage applied to FIM
    % This is justified because regularizing the eigenvalues of a matrix's
    % inverse towards one results in regularization of original matrix's
    % eigenvalues as well.
    [n,p] = size(S);

    % structured estimator, formula (3) in the article [1]
    mu = trace(S)/p;
    F = mu*eye(p);
    
    if rho == 0
        % rho = (1-(2/p)*trace(S^2)+trace(S)^2)/((n+1-2/p)*(trace(S^2)-1/p*trace(S)^2));
        c1 = 1-2/p;
        c2 = n+1-2/p;
        c3 = 1-n/p;
        rho = (c1*trace(S^2) + trace(S)^2) / (c2*trace(S^2) + c3*trace(S)^2);
        
        disp(['      LD rho: ', num2str(rho)])
    end

    % regularization, formula (4) in the paper [1]
    sigma = (1-rho)*S + rho*F;

end
