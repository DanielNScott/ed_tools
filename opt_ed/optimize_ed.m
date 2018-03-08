function [] = optimize_ed(settings_fname)

% Read in settings file and initialize data structures
[ui, cfe, obs, hist] = setup_optim(settings_fname);

% Outer program loop for iterative optimization algorithms
while cfe.iter < ui.niter
   
   disp('------------------------------------------')
   disp(['Beginning iteration ' num2str(cfe.iter+1)])
   disp('------------------------------------------')
   
   % Every iteration, we need a new set of states to run on the basis of the optimization algorithm.
   [cfe, hist, state] = update_alg(cfe, hist, ui);
  
   if ui.resub_override
      cfe.restart = 0;
   end

   % On clusters, generally we use multiple nodes.
   if cfe.multi_node

      % We save a version of opt.mat with no 'hist' variable, because this variable takes up
      % a huge amount of space.
      save pso.mat -REGEXP ^((?!hist).)*$
      
      % Sets up job folders for other nodes' use, submits them, etc.
      setup_jobs(cfe.iter, cfe.njobs, cfe.fmt, cfe.restart, state, cfe.labels, ui);
      
      % Retrieves completed job data.
      hist = get_jobs(cfe.fmt, cfe.iter, cfe.njobs, hist, ui.sim_location, ui.verbose);

   elseif cfe.single_node

      hist.obj(:,cfe.iter) = run_jobs_locally(cfe,obs,hist,state,ui);

   end
   
   hist = proc_jobs  (cfe,hist,ui);
   
   %hist       = update_hist (cfe,hist,ui);
   %hist       = gen_state   (cfe,hist,nfo,ui);
   %print_progress(cfe.iter, ui.niter, hist.acc)
   
   % If this had been a restart, we need to turn cfe.restart off so it doesn't resubmit jobs every iteration.
   cfe.restart = 0;
   
   disp('Saving current program state to opt.mat...');
   disp(' '                                         );
   save('opt.mat')
end
cd(cfe.init_dir)

end
%==========================================================================================%
%==========================================================================================%
