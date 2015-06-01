function [ ctrl, data, hist, nfo, ui ] = check_for_opt_mat(ctrl, data, hist, nfo, ui )
%CHECK_FOR_OPT_MAT Checks to see if an opt.mat file exists, loads it, tells the user, and
%manipulates a few variables.

% Move to the run directory
disp(['Run Directory: ', ui.rundir])
cd(ui.rundir)                                      

% Look for an optimization .mat file.
opt_mat_fname = [ ui.rundir 'opt.mat' ];

if exist(opt_mat_fname,'file')

   load(opt_mat_fname)
   
   if ctrl.iter == 1 && nfo.restart
      error('You are attempting to resume a previous optimization at iteration 1...')
   end
  
   disp([opt_mat_fname ' found! This is iter ' num2str(ctrl.iter)])
   disp('All initializations skipped, opt.mat loaded instead.')
   
   nfo.restart = 1;
else
   disp([opt_mat_fname ' not found, initializing a new optimization.'])
   disp('If you are trying to restart an opt. something is wrong.')
   
   nfo.restart = 0;
end

disp(' ')
disp(['Restart? (Boolean): ', num2str(nfo.restart)])
   
end

