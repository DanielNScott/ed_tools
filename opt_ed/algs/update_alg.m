function [ cfe, hist, new_state] = update_alg( cfe, hist, ui )
%UPDATE_ALG Updates the iterative optimization algorithm being used.
%   At one point multiple algorithms were supported. In practice these were not necessary, but this
%   file remains in case any additional algorithms should be implemented in the future.

cfe.iter = cfe.iter + 1;

switch ui.opt_type
case('PSO')
   % PSO is deterministic
   if cfe.iter ~= 1
      [new_state, vels] = update_pso_state(hist.state(:,:,cfe.iter-1) ...
                                           ,hist.vels (:,:,cfe.iter-1) ...
                                           ,cfe.vel_max                ...
                                           ,cfe.chi                    ...
                                           ,ui.phi_1                   ...
                                           ,ui.phi_2                   ...
                                           ,hist.pbs                   ...
                                           ,hist.pbo                   ...
                                           ,cfe.nbrhd                  ...
                                           ,size(hist.state,1)         ...
                                           ,cfe.bounds);
      hist.state(:,:,cfe.iter) = new_state;
      hist.vels (:,:,cfe.iter) = vels;
   else
       new_state = hist.state(:,:,cfe.iter);    
   end
   
otherwise
    error('Only PSO is supported. Old algorithms have been thrown out. Halting.')

end


end

