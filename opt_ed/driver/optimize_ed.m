function [] = optimize_ed(settings_fname)
% Please see the bottom of this file for general notes.

[ui,cfe,obs,hist] = init_alg(settings_fname);

while keep_iterating(cfe,ui.niter,ui.opt_type)
   
   vdisp('------------------------------------------',0,ui.verbose)
   vdisp(['Beginning iteration ' num2str(cfe.iter+1)],0,ui.verbose)
   vdisp('------------------------------------------',0,ui.verbose)
   
   [cfe,hist]        = update_alg (cfe,hist,ui);
   [hist,state_prop] = prop_state (cfe,hist,ui);
  
   if ui.resub_override
      cfe.restart = 0;
   end

   if cfe.run_xtrnl
      % We save a version of opt.mat with no 'hist' variable, because this variable takes up
      % a huge amount of space.
      save pso.mat -REGEXP ^((?!hist).)*$
      set_jobs(cfe.iter,cfe.njobs,cfe.fmt,cfe.restart,state_prop,cfe.labels,ui);
      
      hist = get_jobs(cfe.fmt,cfe.iter,cfe.njobs,hist,ui.sim_location,ui.verbose);
      
      %if ~isempty(pred_best)
         %hist.pred_best = pred_best;
         %hist.stats = update_struct(stats,hist.stats);
      %end
      
   elseif cfe.run_local
      [hist.obj(:,cfe.iter)] = run_jobs_locally(cfe,obs,hist,state_prop,ui);
   end
   
   hist = proc_jobs  (cfe,hist,ui);
   
   %hist       = update_hist (cfe,hist,ui);
   %hist       = gen_state   (cfe,hist,nfo,ui);
   %print_progress(cfe.iter, ui.niter, hist.acc)
   
   % If this had been a restart, we need to turn cfe.restart off so it doesn't resubmit jobs
   % every iteration.
   cfe.restart = 0;
   
   vdisp('Saving current program state to opt.mat...',0,ui.verbose);
   vdisp(' '                                         ,0,ui.verbose);
   save('opt.mat')
end
cd(cfe.init_dir)

end
%==========================================================================================%
%==========================================================================================%








%=============================================================================================%
% DRAM, Simulated Annealing, and PSO                                                          %
%=============================================================================================%
% Here you will find some notes on the structures, implementations, and shared code between 
% the Delayed Rejection Adaptive Metropolis Hastings algorithm, the Simulated Annealing 
% algorithm, and the Particle Swarm Optimization algorithm.
%
%--------------------------------------------------------------------------------------------%
% The basic SA Algorithm in pseudocode                                                       %
%--------------------------------------------------------------------------------------------%
% iteration = 1;
% while iter < max_iters and (energy > max_acceptable_energy)
%     set Temperature  = Temperature_Function(iter,max_iters)
%     set new_State    = neighbor_generating_function(state)
%     set new_Energy   = Energy_Function(new_state)
%
%     if Acceptance_Probability_Function(Energy,new_Energy,Temperature) > Uniform_Rand
%        set state  = new_State
%        set energy = new_Energy
%     end
%
%     if new_Energy < best_Energy
%        set best_Energy = new_Energy
%        set best_State  = new_State
%     end
%
%     add state to list of visited states
%     add energy to list of visited energies
%
%     set iteration = iteration + 1
% end while
%
%
%--------------------------------------------------------------------------------------------%
% The DRAM (Delayed Rejection Adaptive Metropolis Hastings) Algorithm in pseudocode          %
%--------------------------------------------------------------------------------------------%
%
%
%
%----------------------------------------------------------------------------------------------%
% Canonical PSO in pseudocode                                                                  %
%----------------------------------------------------------------------------------------------%
%
%
%
%==============================================================================================%



%=============================================================================================%
% Some notes on the structure of this program.                                                %
%=============================================================================================%
% The program 'optimize_ed' implements both SA and DRAM. Right now, the delayed rejection and
% adaptive components of DRAM are still under development, but the basic Metropolis-Hastings
% algorithm is functional.
%
% (More to be added)
%=============================================================================================%
