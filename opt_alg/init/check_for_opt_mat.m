function [argout] = check_for_opt_mat(nfo,ui)
%CHECK_FOR_OPT_MAT Checks to see if an opt.mat file exists, loads it, tells the user, and
%manipulates a few variables.

% Move to the run directory
disp(['Run Directory: ', ui.rundir])

% Look for an optimization .mat file.
opt_mat_fname = [ ui.rundir 'opt.mat' ];

if exist(opt_mat_fname,'file')

   load(opt_mat_fname)
   
   if cfe.iter == 1 && cfe.restart
      error('You are attempting to resume a previous optimization at iteration 1...')
   end
  
   disp([opt_mat_fname ' found! This is iter ' num2str(cfe.iter)])
   disp('All initializations skipped, opt.mat loaded instead.')
   
   cfe.restart = 1;

   argout{1} = cfe;
   argout{2} = hist;
   argout{3} = nfo;
   argout{4} = ui;
else
   disp([opt_mat_fname ' not found, initializing a new optimization.'])
   disp('If you are trying to restart an opt. something is wrong.')
   
   cfe.restart = 0;
   argout      = {};
end

end

