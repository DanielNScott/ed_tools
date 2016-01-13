function [ ] = adapt_covar(cfe, ui)
%ADAPT_COVAR Summary of this function goes here
%   Detailed explanation goes here
   if(cfe.iter > floor(ui.burn_in*cfe.niter) && ...
      mod(cfe.iter,adapt_freq) == 0            && ...
      sum(hist.acc) < 10)
      %call adapt_prop_covar(cfe.niter, nvar, iter-1, param_chain)
      %call eigen_prop_cov_mat(nvar)
      %covar     = adapt_prop_covar()
      %eigenvals = eigen_prop_cov_mat()
   end
end

