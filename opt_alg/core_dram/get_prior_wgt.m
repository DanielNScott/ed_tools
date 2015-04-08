function [ prop_prior_wgt ] = get_prior_wgt( prop_state, p_means, p_sdevs, theta, ... 
                                               ga_k, prior_pdf_type, prior_pdf  )
%GET Summary of this function goes here
%   Detailed explanation goes here

if strcmp(prior_pdf,'uniform')
   % The uniform PDF is the same everywhere, hence all prior evaluations
   % are the same. So this number can be any non-zero const.
   prop_prior_wgt = 1;

elseif strcmp(prior_pdf,'gaussian')
   prop_prior_wgt =  get_prior_wgt_gauss(prop_state, p_means, p_sdevs);

elseif strcmp(prior_pdf,'gamma')
   prop_prior_wgt = get_prior_wgt_gam(theta, ga_k, prop_state, prior_pdf_type);

end

end

function [ prior_weight, vars_conform ] = get_prior_wgt_gam(theta, ga_k, var_list, prior_pdf_type)
%GET_GAM_PRIOR_WEIGHT Summary of this function goes here
%   Detailed explanation goes here
   vars_conform = 0;
   prior_weight = 0;
   nvar         = numel(var_list);
   
   for i = 1:nvar
      if (prior_pdf_type(i) == 2) % Gamma PDF
         if(var_list(i) > 0)
            prior_weight = prior_weight + (ga_k(i)-1)*log(var_list(i)) -   ...
                           var_list(i) / theta(i);
         else
            vars_conform = 0;
            break
         end
       
      elseif (prior_pdf_type(i) == 3) % Beta PDF.
    
         if (var_list(i) > 0 && var_list(i) < 1)
            prior_weight = prior_weight + (theta(i)-1)*log(var_list(i)) +  ...
                           (ga_k(i)-1)*log(1-var_list(i));
         else
            vars_conform = 0;
            break
         end
      end
   end
end

function [ prior_weight ] = get_prior_wgt_gauss( prop_state, p_means, p_sdevs )
%GET_GAUSS_PRIOR_WEIGHT Summary of this function goes here
%   Detailed explanation goes here

prior_weight = sum(-0.5 * ((prop_state - p_means)./p_sdevs).^2);

end

