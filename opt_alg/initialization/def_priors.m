function [ theta, ga_k, prior_pdf_type ] = def_priors( nvar, p_means, p_sdevs, prior_pdf )
%DEFINE_PRIORS THIS FUNCTION IS NOT PRESENTLY USED
%   Detailed explanation goes here

theta = NaN;
ga_k  = NaN;
prior_pdf_type = NaN;

if strcmp(prior_pdf,'uniform')
   % Nothing to do, p_means and p_sdevs contain all dist. info.

elseif strcmp(prior_pdf,'gaussian')
   % Nothing to do, p_means and p_sdevs contain all dist. info.

elseif strcmp(prior_pdf,'gamma')
   [theta, ga_k, prior_pdf_type] = define_gamma_priors(nvar, p_means, p_sdevs);

else
   disp(['Bad prior scheme: ', prior_pdf])
   disp('Please use "uniform", "gaussian", or "gamma".')
   return
end


end

function [ theta, ga_k, pr_pdf_type ] = define_gamma_priors(nvar, p_means, p_sdevs)
%DEFINE_GAMMA_PRIORS Summary of this function goes here
%   Detailed explanation goes here

   theta       = zeros(nvar,1);
   ga_k        = zeros(nvar,1);
   pr_pdf_type = zeros(nvar,1);

   %------------------------------------------------------------------------------------------%
   %  Two formulas are implemented below, one for general use and another for specific vars.
   %
   %  Formula 1) ... for specific vars (some growth respirations) is ...
   %     theta = ( mean^2 * (1-mean) )/sd^2 - mean
   %     k     = theta *(1-mean) / mean
   %
   %  Formula 2) ... for general vars is...
   %     theta = 0.5 * ( -mean + sqrt(mean^2 + 4*sd^2))
   %     k     = sd / theta^2
   %------------------------------------------------------------------------------------------%   
   for i = 1:nvar
      %---- Implement formula 1 for some vars ---------------------------------------------%
      % These indices, 11, 43, 44, 55, should corrospond to grr_hw, grr_c3, grr_c4, and    %
      % wopt. Please check that they for by referencing the ed_mcmc.f90 module namespace.   %
      %------------------------------------------------------------------------------------%
      if (i == 11 || i == 37 || i == 50 || i == 55)
         theta(i) = ( p_means(i)^2  *(1.0 - p_means(i)) - p_means(i) * p_sdevs(i)^2) ...
                       / p_sdevs(i)^2;

         ga_k(i)  = theta(i)*(1.0 - p_means(i)) ...
                       /p_means(i);

         pr_pdf_type(i) = 3;

      %---- Implement formula 2 for the rest ----------------------------------------------%
      else
         theta(i) = 0.5 * ( -p_means(i) + sqrt(p_means(i)^2 + 4.0*p_sdevs(i)^2 ) );
         ga_k(i)  = ( p_sdevs(i) / theta(i) )^2;

         pr_pdf_type(i) = 2;
      end
   end
   %------------------------------------------------------------------------------------------%   

end
