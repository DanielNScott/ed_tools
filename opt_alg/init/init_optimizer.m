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
ctrl = struct();
data = struct();
nfo  = struct();
hist = struct();
ui   = struct();
%-----------------------------------------------------------------------------------------------


%-----------------------------------------------------------------------------------------------
% Copy the settings into a structure to make the algorithm workspace less cluttered.
%-----------------------------------------------------------------------------------------------
ui.acc_crit      = acc_crit;
ui.adapt_freq    = adapt_freq;
ui.cool_sched    = cool_sched;
ui.data_fnames   = data_fnames;
ui.obs_prefixes  = obs_prefixes;
ui.exp_mult      = exp_mult;
ui.mantissa      = mantissa;
ui.model         = model;
ui.multiplier    = multiplier;
ui.ndr           = ndr;
ui.niter         = niter;
ui.opt_data_dir  = opt_data_dir;
ui.opt_metadata  = opt_metadata;
ui.opt_type      = opt_type;
ui.params        = params;
ui.prior_pdf     = prior_pdf;
ui.pfts          = pfts;
ui.rundir        = rundir;
ui.temp_start    = temp_start;
ui.verbose       = verbose;
ui.nps           = nps;
ui.top           = top;
ui.phi_1         = phi_1;
ui.phi_2         = phi_2;
ui.obs_years     = obs_years;

if exist('use_dcs','var')
   ui.use_dcs    = use_dcs;
   ui.job_mem    = job_mem;
   ui.job_queue  = job_queue;
   ui.job_wtime  = job_wtime;
else
   ui.use_dcs    = 0;
end
%-----------------------------------------------------------------------------------------------

nfo.init_dir = pwd;                                   % Save current directory:
test_fns     = {'Rosenbrock','Sphere'};               % Define which model options are tests
nfo.is_test  = any(strcmp(model,test_fns));           % Is this a test?

if exist('run_external','var')
   ui.run_external = 'Dummy text. See init_optimizer.';
end

% Look for opt.mat, infer init/restart status, determine opt_years.
if ~ nfo.is_test
   [ctrl, data, hist, nfo, ui] = check_for_opt_mat(ctrl, data, hist, nfo, ui);
else
   nfo.restart = 0;
end

if ~ nfo.restart
   [nfo,ui] = parse_params(nfo,ui);
end
% 
% switch ui.opt_type
%    case('PSO')
%       nfo.det_evol = 1;
% 
%    case({'DRAM','SA'})
%       nfo.det_evol = 0;
% end

%-----------------------------------------------------------------------------------------%
% Allocate the arrays used in the optimization process.                                   %
% These will be used in SA as they are in DRAM: state_prop will get loaded into           %
% 'loaded_vars' and  copied into 'state_curr' if they are used in an accepted step.       %
% If they are not used in an accepted step they are put in rejected_var. Param_chain is,  %
% in both algorithms, the 'state' of the system.                                          %
%-----------------------------------------------------------------------------------------%
if ~ nfo.restart
   nfo.nvar        = numel(ui.means)         ;    % Number of variables being optimized
   
   data.state      = zeros(nfo.nvar,1       );    % Current state
   hist.state      = zeros(nfo.nvar,ui.niter);    % List of accepted states
   hist.obj        = nan  (1       ,ui.niter);    % List of objective function values.

   if strcmp(opt_type,'PSO')
      ctrl.idr   = 1;
      hist.obj   = nan(nps,ui.niter);
      hist.state = zeros(nfo.nvar,ui.nps,ui.niter);       % List of states.
      hist.vels  = NaN(nfo.nvar,ui.nps,ui.niter);         % List of velocities.
   end
   
   % These do not exist in PSO.
   %if strcmp(opt_type,'PSO')
      hist.acc        = nan  (1       ,ui.niter);     % List of acceptance/rejections
      data.state_prop = ui.means                ;     % Initialize first state
      hist.state_prop = zeros(nfo.nvar,ui.niter);     % List of proposed states
   %end
   
   % Get observations against which to compare the model.
   if ~ nfo.is_test
      disp('Retrieving observational data...')
      %data.obs = get_obs( ui.opt_data_dir, ui.data_fnames , nfo.simres);
      data.obs = get_obs_new( ui.opt_data_dir, ui.obs_prefixes, nfo.simres, ui.obs_years);
   else
      data.obs = 0;
   end
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
   % square grid possible by using the highest multiplicative factor of the num of particles. 
   %-------------------------------------------------------------------------------------------%
   prime_fact   = sort(factor(nps),'descend');     % Get the prime factorization of nps.
   [big_dim, ~] = get_grid_dims(prime_fact);       % Get biggest multiplicative factor of nps.
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
   spread = repmat(ui.bounds(:,2) - ui.bounds(:,1),1,nps);     % Compute parameter spreads
   cents  = repmat(ui.bounds(:,1) + spread(:,1)/2 ,1,nps);     % Compute centers of ranges
   
   data.state = (rand(nfo.nvar,nps) - 0.5) .*spread + cents;   % Recenter and expand rands.
   data.vels  = (rand(nfo.nvar,nps) - 0.5) .*spread + cents;   % Recenter and expand rands.
 
   ctrl.vel_max = spread(:,1);                                 % Limit velocity to param spread
   
   ctrl.pbs = data.state;
   ctrl.pbo = inf(1,nps);
end
%----------------------------------------------------------------------------------------------%

end
