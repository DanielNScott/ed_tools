function [ ] = adapt_covar(ctrl, ui)
%ADAPT_COVAR Summary of this function goes here
%   Detailed explanation goes here
   if(ctrl.iter > floor(ctrl.burn_in*ctr.niter) && ...
      mod(ctrl.iter,adapt_freq) == 0            && ...
      sum(hist.acc) < 10)
      %call adapt_prop_covar(ctrl.niter, nvar, iter-1, param_chain)
      %call eigen_prop_cov_mat(nvar)
      %covar     = adapt_prop_covar()
      %eigenvals = eigen_prop_cov_mat()
   end
end

