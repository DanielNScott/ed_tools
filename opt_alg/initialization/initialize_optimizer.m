% Save current directory:
init_dir = pwd;

% opt_years is the set of years with optimization data. extract it from settings info.
%opt_years = cell2mat(opt_metadata(:,1));

%----------------------------------------------------------------------------------------------%
% Determine if this is a test, look for opt.mat, infer init status, determine opt_years.
%----------------------------------------------------------------------------------------------%
testing = ~sum(strcmp(model,{'ED2.1','out.mat'}));
if ~testing
   % Move to the run directory:
   disp(['Run Directory: ', rundir])
   cd(rundir)
   
   % Look for an optimization .mat file.
   opt_mat_fp = [rundir 'opt.mat'];
   if exist(opt_mat_fp,'file')
      load(opt_mat_fp)
      if iter == 1 && restart
         error('Iter should not be set to 1 while opt_mat exists restart == 1!')
      end
      disp([opt_mat_fp ' found! This is iter ' num2str(iter)])
      disp('All initializations skipped, opt.mat loaded instead.')
      restart = 1;
   else
      disp([opt_mat_fp ' not found, considering this as a new optimization.'])
      disp('If you are trying to restart an opt. something is wrong.')
      disp('If you are not, this should be correct.')
      restart = 0;
   end
   disp(' ')
   disp(['Restart? (Boolean): ', num2str(restart)])
else
   % No 'restarting' of tests allowed; Just let them complete.
   restart = 0;
end
%----------------------------------------------------------------------------------------------%
% Throughout this optimization program p_means is used as the set of parameter means, p_sdevs as
% their standard deviations, and labels is used to identify these vars by name and to determine
% which pfts each 'version' of the parameter should be applied to. See settings_ed_opt for more
% information.
%----------------------------------------------------------------------------------------------%
if (~restart && ~testing) || (~restart && strcmp(model,'read_dir'))
   % Adjust the parameter matrix according to 'multiplier'
   for i = 1:size(params,1)
      params{i,4} = params{i,4} * multiplier;
      params{i,5} = params{i,5} * multiplier;
   end
   
   % Extract some information from the parameter matrix.
   p_means    = cell2mat(params(cell2mat(params(:,6)) == 1,4));
   p_sdevs    = cell2mat(params(cell2mat(params(:,6)) == 1,5));
   labels     = params(cell2mat(params(:,6)) == 1,1:3);
   
   simres = get_simres(opt_metadata);

   % Tell the user what's up
   disp('ED Parameter matrix loaded: ')
   disp(params(cell2mat(params(:,end)) == 1,1:end-1));
end
%-----------------------------------------------------------------------------------------%
% Allocate the arrays used in the optimization process.                                   %
% These will be used in SA as they are in DRAM: state_prop will get loaded into           %
% 'loaded_vars' and  copied into 'state_curr' if they are used in an accepted step.       %
% If they are not used in an accepted step they are put in rejected_var. Param_chain is,  %
% in both algorithms, the 'state' of the system.                                          %
%-----------------------------------------------------------------------------------------%
if ~restart
   nvar            = numel(p_means)   ;    % Number of variables being optimized
   state_prop      = p_means          ;    % Set first proposed state to the initial state
   state_curr      = zeros(nvar,1    );    % Current state
   hist_state_prop = zeros(nvar,niter);    % List of proposed states
   hist_state      = zeros(nvar,niter);    % List of accepted states
   hist_accept     = nan  (1   ,niter);    % List of acceptance/rejections
   hist_obj        = nan  (1   ,niter);    % List of objective function values.

   % Get observations against which to compare the model.
   disp('Retrieving observational data...')
   obs = get_obs(opt_data_dir, model, data_fnames, simres);
end
%-----------------------------------------------------------------------------------------%
% Set up priors depending on which type is indicated in the namelist, and set up delayed  %
% rejection factors for if we're doing DRAM.                                              %
%-----------------------------------------------------------------------------------------%
if ~restart
   [theta, ga_k, prior_pdf_type] = def_priors(nvar, p_means, p_sdevs, prior_pdf);

   dr_factor(1) = 1;
   for idr = 2:ndr
      dr_factor(idr) = dr_factor(idr - 1) * 0.1;
   end
end
%-----------------------------------------------------------------------------------------%
% Eigenvalues and covariances... better to not touch them until we need them...           %
%-----------------------------------------------------------------------------------------%
%call init_prop_cov_mat(maxvar, nvar, include_var)
%call eigen_prop_cov_mat(nvar)
%-----------------------------------------------------------------------------------------%


%-----------------------------------------------------------------------------------------%
% Initialize some more things, then let the looping begin!                                %
%                                                                                         %
% For the MH algorithm ee want to just cycle through iterations, i.e. we have a do-loop   %
% which we're setting up as a special case (when opt_type = 'DRAM') of the while loop.    %
%                                                                                         %
% For the SA, we actually want a while loop attuned to the annealing schedule and and our %
% minimum acceptable value of the objective function.                                     %
%-----------------------------------------------------------------------------------------%
if ~restart
   iter           = 1;              % Cycle over this var. in both algs. 
   tenths         = 1;              % Current tenth of iteration we're working in.
   alpha          = zeros(ndr,1);   % Acceptance probability for both delayed reject, and SA.   
   energy         = inf;            % If we're running the the SA alg this gets modified in loop.
   energy_max     = 0;              % For stopping SA if our energy gets good enough.
   temp_max       = 1000;           % Gets used to determine SA inst. step rejection rate
   obj_curr       = 0;              % Current value of the objective function
   curr_prior_wgt = 0;              % Current value of the prior function, not normalized.
end
%-----------------------------------------------------------------------------------------%


