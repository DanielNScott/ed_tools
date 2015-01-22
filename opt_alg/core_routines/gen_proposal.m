function [ prop_state ] = gen_proposal(curr_state, dr_factor, p_sdevs, opt_type, prior_pdf )
%GEN_PROPOSAL(curr_state, dr_factor, p_sdevs, opt_type, prior_pdf) Proposes a new parameter set.
% Note: This is what's called the 'Neighborhood Function' in SA parlance.
%   curr_state: Present parameter set
%   dr_factor : Delayed rejection factor
%   p_sdevs   : Parameter standard deviations
%   opt_type  : What type of 'optimization' is this?
%   prior_pdf : The type of PDF the prior has
   
%    nvar         = numel(curr_state);
%    prop_state   = curr_state;
%    innovation   = zeros(1,nvar);
%    
%    rotated_prop = sqrt(dr_factor * proposal_eigenvals) * rnorm();
%
%    for ivar = 1:nvar
%       for jvar = 1:nvar
%          innovation(ivar) = innovation(ivar) + proposal_eigenvecs(jvar,ivar) * rotated_prop(jvar);
%       end      
%       prop_state(ivar) = curr_state(ivar) + innovation(ivar);
%    end
   
if strcmp(prior_pdf,'gaussian')
   % Set proposed state as a normal random number with mean at current state
   prop_state = normrnd(curr_state, p_sdevs);
   
elseif strcmp(prior_pdf,'uniform')
   % Generate a uniform [0,1] random number for each variable
   rands = rand(numel(curr_state),1);
   
   % Shift means from 0.5 to 0;
   rands = rands - 0.5;
   
   % Change range from [-0.5, 0.5] to [-2 Sdevs, 2 Sdevs]
   rands = rands .* (2*p_sdevs);
   
   % Shift means to current state and set proposed state.
   prop_state = rands + curr_state;
end

end

