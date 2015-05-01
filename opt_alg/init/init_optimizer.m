function [ ui, ctrl, data, nfo, hist] = init_optimizer( settings_fname )
%READ_SETTINGS Summary of this function goes here
%   Detailed explanation goes here

%-----------------------------------------------------------------------------------------------
% Load the contents of the settings.m file into this function's namespace.
%-----------------------------------------------------------------------------------------------
disp('Loading settings.m ...')
run(settings_fname)
%-----------------------------------------------------------------------------------------------


%-----------------------------------------------------------------------------------------------
% Trim opt_metadata to only those things we want to include.
%-----------------------------------------------------------------------------------------------
 opt_metadata = opt_metadata(cell2mat(opt_metadata(:,end)) == 1,1:end-1);
%-----------------------------------------------------------------------------------------------

 
 %-----------------------------------------------------------------------------------------------
% Initialize the primary data structures used in the optimization algorithm.
%-----------------------------------------------------------------------------------------------
ui   = struct();
ctrl = struct();
data = struct();
nfo  = struct();
%-----------------------------------------------------------------------------------------------


%-----------------------------------------------------------------------------------------------
% Copy the settings into a structure to make the algorithm workspace less cluttered.
%-----------------------------------------------------------------------------------------------
ui.acc_crit      = acc_crit;
ui.adapt_freq    = adapt_freq;
ui.cool_sched    = cool_sched;
ui.data_fnames   = data_fnames;
ui.exp_mult      = exp_mult;
ui.mantissa      = mantissa;
ui.model         = model;
ui.multiplier    = multiplier;
ui.ndr           = ndr;
ui.niter         = niter;
ui.opt_data_dir  = opt_data_dir;
ui.opt_metadata  = opt_metadata;
ui.opt_type      = opt_type;
ui.prior_pdf     = prior_pdf;
ui.pfts          = pfts;
ui.rundir        = rundir;
ui.temp_start    = temp_start;
ui.verbose       = verbose;
ui.nps           = nps;
ui.top           = top;
ui.phi_1         = phi_1;
ui.phi_2         = phi_2;
%-----------------------------------------------------------------------------------------------

nfo.init_dir = pwd;                                               % Save current directory:
nfo.test     = ~sum(strcmp(model,{'ED2.1','out.mat'}));           % Is this a test?
if exist('run_external','var')
   ui.run_external = 'Dummy text. See init_optimizer.';
end

%----------------------------------------------------------------------------------------------%
% Look for opt.mat, infer init/restart status, determine opt_years.
%----------------------------------------------------------------------------------------------%
if ~ nfo.test
   disp(['Run Directory: ', ui.rundir])                       % Move to the run directory
   cd(ui.rundir)                                                      
   
   % Look for an optimization .mat file.
   nfo.opt_mat_fname = [ ui.rundir 'opt.mat' ];
   if exist(nfo.opt_mat_fname,'file')
      load(nfo.opt_mat_fname)
      if ctrl.iter == 1 && nfo.restart
         error('Iter should not be set to 1 while opt_mat exists restart == 1!')
      end
      disp([nfo.opt_mat_fname ' found! This is iter ' num2str(ctrl.iter)])
      disp('All initializations skipped, opt.mat loaded instead.')
      nfo.restart = 1;
   else
      disp([nfo.opt_mat_fname ' not found, considering this as a new optimization.'])
      disp('If you are trying to restart an opt. something is wrong.')
      disp('If you are not, this should be correct.')
      nfo.restart = 0;
   end
   disp(' ')
   disp(['Restart? (Boolean): ', num2str(nfo.restart)])
else
   % No 'restarting' of tests allowed; Just let them complete.
   nfo.restart = 0;
end
%----------------------------------------------------------------------------------------------%
% Throughout this optimization program p_means is used as the set of parameter means, p_sdevs as
% their standard deviations, and labels is used to identify these vars by name and to determine
% which pfts each 'version' of the parameter should be applied to. See settings_ed_opt for more
% information.
%----------------------------------------------------------------------------------------------%
if ~ nfo.restart
   nfo.simres = '';
   % Extract some information from the parameter matrix.
   if any(strcmp(ui.model,{'ED2.1','read_dir'}))
      means_ind = 4;
      sdevs_ind = 5;
      bnd_ind   = 6;
      label_rng = 1:3;
      mask_ind  = 7;
   else
      means_ind = 2;
      sdevs_ind = 3;
      bnd_ind   = 4;
      label_rng = 1;
      mask_ind  = 5;
   end
   row_msk     = cell2mat(params(:,mask_ind)) == 1;
   
   ui.means    = cell2mat(params(row_msk, means_ind)) *multiplier;
   ui.sdevs    = cell2mat(params(row_msk, sdevs_ind)) *multiplier;
   ui.bounds   = cell2mat(params(row_msk,   bnd_ind)) *multiplier;
   ui.labels   = params(row_msk, label_rng);

   ui.opt_metadata = opt_metadata;
   nfo.simres      = get_simres(opt_metadata);

   % Tell the user what's up
   if any(strcmp(ui.model,{'ED2.1','read_dir'}))
      disp(['ED Parameter matrix loaded with multiplier ', num2str(multiplier)])
      disp(params(cell2mat(params(:,end)) == 1,1:end-1));
   end
end
%-----------------------------------------------------------------------------------------%
% Allocate the arrays used in the optimization process.                                   %
% These will be used in SA as they are in DRAM: state_prop will get loaded into           %
% 'loaded_vars' and  copied into 'state_curr' if they are used in an accepted step.       %
% If they are not used in an accepted step they are put in rejected_var. Param_chain is,  %
% in both algorithms, the 'state' of the system.                                          %
%-----------------------------------------------------------------------------------------%
if ~nfo.restart
   nfo.nvar        = numel(ui.means)         ;    % Number of variables being optimized
   
   data.state      = zeros(nfo.nvar,1       );    % Current state
   hist.state      = zeros(nfo.nvar,ui.niter);    % List of accepted states
   hist.obj        = nan  (1       ,ui.niter);    % List of objective function values.

   if strcmp(opt_type,'PSO')
      ctrl.idr        = 1;
      hist.obj = nan(nps,ui.niter);
      hist.state      = zeros(nfo.nvar,ui.nps,ui.niter);       % List of states.
      hist.vels       = NaN(nfo.nvar,ui.nps,ui.niter);         % List of velocities.
   end
   
   % These do not exist in PSO.
   %if strcmp(opt_type,'PSO')
      hist.acc        = nan  (1       ,ui.niter);     % List of acceptance/rejections
      data.state_prop = ui.means                ;     % Initialize first state
      hist.state_prop = zeros(nfo.nvar,ui.niter);     % List of proposed states
   %end
   
   % Get observations against which to compare the model.
   disp('Retrieving observational data...')
   data.obs = get_obs( ui.opt_data_dir, ui.model, ui.data_fnames , nfo.simres);
end
%-----------------------------------------------------------------------------------------%
% Set up priors depending on which type is indicated in the namelist, and set up delayed  %
% rejection factors for if we're doing DRAM.                                              %
%-----------------------------------------------------------------------------------------%
if ~ nfo.restart && strcmp(opt_type,'DRAM')
   [ctrl.theta, ctrl.ga_k, ui.prior_pdf_type] = ... 
      def_priors(nfo.nvar, ui.means, ui.sdevs, ui.prior_pdf);

   ctrl.dr_fact(1) = 1;
   for idr = 2:ui.ndr
      ctrl.dr_fact(idr) = ctrl.dr_fact(idr - 1) * 0.1;
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
% For the MH algorithm we want to just cycle through iterations, i.e. we have a do-loop   %
% which we're setting up as a special case (when opt_type = 'DRAM') of the while loop.    %
%                                                                                         %
% For the SA, we actually want a while loop attuned to the annealing schedule and and our %
% minimum acceptable value of the objective function.                                     %
%-----------------------------------------------------------------------------------------%
if ~ nfo.restart
   nfo.tenths          = 1;               % Current tenth of iteration we're working in.
   ctrl.iter           = 1;               % Cycle over this var. in both algs. 
   ctrl.alpha          = zeros(ndr,1);    % Acceptance probability for both delayed reject, and SA.   
   ctrl.energy         = inf;             % If we're running the the SA alg this gets modified in loop.
   ctrl.energy_max     = 0;               % For stopping SA if our energy gets good enough.
   ctrl.temp_max       = 1000;            % Gets used to determine SA inst. step rejection rate
   ctrl.obj_curr       = 0;               % Current value of the objective function
   ctrl.curr_prior_wgt = 0;               % Current value of the prior function, not normalized.
   ctrl.burn_in        = 0.3;             % Fraction of runs which should be burn-in
end
%-----------------------------------------------------------------------------------------%




%-----------------------------------------------------------------------------------------%
% In case we are doing PSO, we'll need to initialize neighborhoods for the particles.     %
% Right now the only type of neighborhoods allowed have the Von Neumann topology.         %
%-----------------------------------------------------------------------------------------%
if ~ nfo.restart && strcmp(ui.opt_type,'PSO')
   
   %-------------------------------------------------------------------------------------------%
   % Set derived parameters
   %-------------------------------------------------------------------------------------------%
   ctrl.phi  = phi_1 + phi_2;                                        % Shorthand
   ctrl.chi  = 2/(ctrl.phi - 2 + sqrt(ctrl.phi^2 - 4*ctrl.phi));     % Constrictor
   
   %-------------------------------------------------------------------------------------------%
   % We want a connection structure with minimal redundancy, so we try to get the most
   % square grid possible by using the highest prime factor of the number of particles. 
   %-------------------------------------------------------------------------------------------%
   prime_fact = factor(nps);                       % Prime-factorize nps
   big_dim    = prime_fact(end);                   % Get long dim for rectangular grid
   for ip = 1:nps;                                 % Loop through particles
      b_ind = mod(ip + 1      , nps);              % Set index for particle "below" in grid
      a_ind = mod(ip - 1      , nps);              % ... "above" in grid
      r_ind = mod(ip + big_dim, nps);              % ... "to-the-right" in grid
      l_ind = mod(ip - big_dim, nps);              % ... "to-the-left" in grid

      nbrs = [b_ind, a_ind, r_ind, l_ind];         % Start packing them into useful struct
      nbrs(nbrs == 0) = nps;                       % Zeros is not an acceptable index.
      
      ctrl.nbrhd(ip,:) = nbrs;                     % Save the appropriate hbrhd topology
   end
   
   %-------------------------------------------------------------------------------------------%
   % Initialize positions and velocities
   %-------------------------------------------------------------------------------------------%
   range = repmat(ui.bounds(:,2) - ui.bounds(:,1),1,nps);      % Compute parameter ranges
   cents = repmat(ui.bounds(:,1) + range(:,1)/2  ,1,nps);      % Compute centers of ranges
   
   data.state = (rand(nfo.nvar,nps) - 0.5) .*range + cents;    % Recenter and expand rands.
   data.vels  = (rand(nfo.nvar,nps) - 0.5) .*range + cents;    % Recenter and expand rands.
 
   ctrl.vel_max = (range(:,1) - cents(:,1))*2;                 % Limit velocity to param range
   
   ctrl.pbs = data.state;
   ctrl.pbo = inf(1,nps);
end
%----------------------------------------------------------------------------------------------%

end

