function [betas, design, labels, design_fn] = fit_quad_to_pso_objs(tmin, tmax, tuse, locs, objs, params, ref_state)

% Other control variables
cut_mort = 1;
sqs_only = 1;
censor   = 0;
tstep    = 0.25;

plot_eig = 1;
plot_gof = 1;
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

thresholds = tmin:tstep:tmax;
use_index  = find(tmin:tstep:tmax == tuse);
for prc = thresholds
    disp(['Processing threshold: ', num2str(prc)])
    
    % Mask out percentile of data in terms of euclidean distance.
    % These particles will be used to construct the response surface.
    prctile_msk = dists < prctile(dists, prc);
    best_p_locs = locs(prctile_msk,:);

    % Create a design matrix for a linear model of objective vals on location
    [design, labels] = sq_design( best_p_locs(:, 1:n_params), params );
    design_fn = @(x) sq_design(x);

    [betas, stats] = robustfit(design(:,2:end), objs(prctile_msk));
    
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
    inv_covar = 2*vec2sym(betas(n_params+2:end));

    % Inverse of FIM gives covariance matrix, eigenvalues / vecs give
    % hierarchy of directional uncertainty.
    covar = inv(inv_covar);
    [eigenvecs, eigenvals] = eig(covar);
    
    eigenvals = diag(eigenvals);
    evratios  = abs(eigenvals ./ min(eigenvals));
    
    % Unpack inverted FIM into covariance matrix terms
    covar_terms = sym2vec(covar);

    all_stats = [all_stats, stats.se./betas];
    all_betas = [all_betas, betas          ];
    all_evals = [all_evals, eigenvals      ];
    all_evecs = [all_evecs, eigenvecs(:)   ]; % (:) stacks cols.
    all_covar = [all_covar, covar_terms    ];
    
    if prc == tuse
        save_stats  = stats;
        save_betas  = betas;
        save_design = design;
        save_best_p = best_p_locs;
        save_covar  = covar_terms;
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



figure()
abbrev_labels = {'vmf_c_o', 'q_c_o', 'grf_c_o', 'vmf_h_w', 'q_h_w', 'grf_h_w', 'str', 'rtr', 'rrf'};

subplot(2,2,1)
plot(thresholds, all_betas(sq_selector,:)');
title('Regression Weights')
xlabel('Inclusion Threshold [percentile]')
ylabel('Loading []')
%legend(labels(sq_selector))
%line([use_prctile, use_prctile],get(gca,'YLim'))

subplot(2,2,2)
plot(thresholds, abs(all_covar'));
title('Covariance Matrix Elements')
xlabel('Inclusion Threshold [percentile]')
ylabel('Element Value []')
%legend(labels(sq_selector))
%line([use_prctile, use_prctile],get(gca,'YLim'))

subplot(2,2,3)
plot(thresholds, coefficients_of_variation);
title('Weight Coefficients of Variation')
xlabel('Inclusion Threshold [percentile]')
ylabel('S.E. as % of Mean [%]')
%legend(labels(sq_selector))
%line([use_prctile, use_prctile],get(gca,'YLim'))

ax = subplot(2,2,4);
set(gca,'NextPlot','replacechildren', 'ColorOrder', linspecer(9));
semilogy(thresholds, all_evals');
colormap(ax, parula);
[~, hObj] = legend(abbrev_labels);
hL = findobj(hObj,'type','line');  % get the lines, not text
set(hL,'linewidth',2)              % set their width property

title('Eigenvalues')
xlabel('Inclusion Threshold [percentile]')

if plot_cov
    cov = vec2sym(save_covar);
    figure()
    suptitle('95% CRs By Parameter Pair')
    for i = 1:n_params
        for j = i:n_params
            subplot(n_params, n_params, (i-1)*n_params + j)

            try
                error_ellipse([cov(i,i), cov(i,j); cov(j,i), cov(j,j)])
                if i == 1; title(abbrev_labels{j}); end
                lims = [min([xlim, ylim]), max([xlim, ylim])];
                set(gca, 'XLim', lims);
                set(gca, 'YLim', lims);
            catch exception
                disp(exception)
            end
        end
    end
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


function [sigma] = regularize(S)

    % OAS shrinkage applied to FIM
    % This is justified because regularizing the eigenvalues of a matrix's
    % inverse towards one results in regularization of original matrix's
    % eigenvalues as well.
    [n,p] = size(S);

    % structured estimator, formula (3) in the article [1]
    mu = trace(S)/p;
    F = mu*eye(p);

    % rho = (1-(2/p)*trace(S^2)+trace(S)^2)/((n+1-2/p)*(trace(S^2)-1/p*trace(S)^2));
    c1 = 1-2/p;
    c2 = n+1-2/p;
    c3 = 1-n/p;
    rho = (c1*trace(S^2) + trace(S)^2) / (c2*trace(S^2) + c3*trace(S)^2);

    % regularization, formula (4) in the paper [1]
    sigma = (1-rho)*S + rho*F;

end


function [] = plots(all_betas)

end
