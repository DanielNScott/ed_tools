function [samples] = laprnd(mu, sigma, nsamples)
%LAPRND generate i.i.d. laplacian random numbers drawn from laplacian distribution
%   with mean mu and standard deviation sigma. 
%   mu      : mean or vector of means
%   sigma   : standard deviation or vector of std devs.
%   nsamples: number of samples from each distribution with mean mu and standard dev. sigma.



% Force mu, sigma to be column vectors
mu    = mu(:);
sigma = sigma(:);

% Find the number of elements in each
n_means = numel(mu);
n_sds   = numel(sigma);

% Do some checking to make sure everything will work.
if n_means < 1 || n_sds < 1
   error('Mu and sigma must be non-empty vectors!')
   
elseif n_means > 1 && n_sds > 1 && n_means ~= n_sds
   error('Either numel(mu) must = numel(sigma) or one must be scalar!')
end

n_rows = max(n_means,n_sds);

% Generate Laplacian noise
uni_rnd = rand(n_rows,nsamples) - 0.5;
n_fctr  = sigma / sqrt(2);

samples = bsxfun(@minus,mu,bsxfun(@times,n_fctr,log(1-2*abs(uni_rnd))).* sign(uni_rnd));

end