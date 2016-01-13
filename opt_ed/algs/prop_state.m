function [ hist, state_prop ] = prop_state( cfe,hist,ui )
%PROP_STATE Summary of this function goes here
%   Detailed explanation goes here


switch ui.opt_type
case('DRAM')
   state_prop = prop_dram(cfe,hist,ui);
case('SA')
   state_prop = prop_sa(cfe,hist,ui);
case('NM')
   [hist, state_prop] = prop_nm(cfe,hist,ui);
case('PSO')
   % This iteration's state was generated in update_alg.m
   % It's deterministic, and thefefore not actually a proposal.
   state_prop = hist.state(:,:,cfe.iter);
end



end

