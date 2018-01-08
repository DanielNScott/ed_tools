function [ hist, state_prop ] = prop_state( cfe,hist,ui )
%PROP_STATE Summary of this function goes here
%   Detailed explanation goes here


switch ui.opt_type
case('PSO')
   % This iteration's state was generated in update_alg.m
   % It's deterministic, and thefefore not actually a proposal.
   state_prop = hist.state(:,:,cfe.iter);
   
otherwise
    error('Only PSO is supported. Old algorithms have been thrown out. Halting.')

end



end

