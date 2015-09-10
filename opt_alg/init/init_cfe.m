function [ cfe ] = init_cfe( cfe, ui )
%INIT_ALG_SPEC_CTRL Summary of this function goes here
%   Detailed explanation goes here

   cfe.iter = 0;          % Controls the main loop of the program.
   cfe.run_xtrnl = strcmp(ui.sim_location,'external');
   cfe.run_local = strcmp(ui.sim_location,'local');
   
   cfe.init_dir = pwd;
   cfe.test_fns = {'Rosenbrock','Sphere','Eggholder','Styblinski-Tang'};
   cfe.is_test  = any(strcmp(ui.model,cfe.test_fns));
   
   cfe = parse_params(cfe,ui);
   
   cfe.uses_proposals = any(strcmp(ui.opt_type,{'SA','DRAM','NM'}));

   cfe.nvar   = numel(cfe.means);       % The number of model parameters being optimized.
   cfe.tenths = 1;                     % Current 1/10th of opt. iterations we're in.


   switch ui.opt_type
      case('DRAM')
         [cfe.theta, cfe.ga_k, ui.prior_pdf_type] = ...
            def_priors(cfe.nvar, cfe.means, cfe.sdevs, ui.prior_pdf);

         cfe.dr_fact(1) = 1;
         for idr = 2:ui.ndr
            cfe.dr_fact(idr) = cfe.dr_fact(idr - 1) * 0.1;
         end
         cfe.njobs = 1;
         cfe.fmt = get_fmt(1);
         
      case('SA')
         cfe.energy     = inf;  % If we're running the the SA alg this gets modified in loop.
         cfe.energy_max = 0;    % For stopping SA if our energy gets good enough.
         cfe.temp_max   = 1000; % Gets used to determine SA inst. step rejection rate
         cfe.njobs = 1;
         cfe.fmt = get_fmt(1);
         
         
      case('PSO')
         cfe.phi  = ui.phi_1 + ui.phi_2;                                  % Shorthand
         cfe.chi  = 2/(cfe.phi - 2 + sqrt(cfe.phi^2 - 4*cfe.phi));     % Constrictor

         %-------------------------------------------------------------------------------------------%
         % We want a connection structure with minimal redundancy, so we try to get the most
         % square grid possible by using the highest multiplicative factor of the num of particles. 
         %-------------------------------------------------------------------------------------------%
         prime_fact = sort(factor(ui.nps),'descend');    % Get the prime factorization of nps.
         if length(prime_fact) < 2;
            msg = 'Sorry, nps must have at least 2 prime factors.';
            error(msg)
         end
         [big_dim, ~] = get_grid_dims(prime_fact);       % Get biggest multiplicative factor of nps.
         for ip = 1:ui.nps;                              % Loop through particles
            b_ind = mod(ip + 1      , ui.nps);           % Set index for particle "below" in grid
            a_ind = mod(ip - 1      , ui.nps);           % ... "above" in grid
            r_ind = mod(ip + big_dim, ui.nps);           % ... "to-the-right" in grid
            l_ind = mod(ip - big_dim, ui.nps);           % ... "to-the-left" in grid

            nbrs = [b_ind, a_ind, r_ind, l_ind];         % Start packing them into useful struct
            nbrs(nbrs == 0) = ui.nps;                    % Zeros is not an acceptable index.

            cfe.nbrhd(ip,:) = nbrs;                     % Save the appropriate hbrhd topology
         end
         cfe.vel_max = repmat(cfe.bounds(:,2) - cfe.bounds(:,1),1,ui.nps);
         cfe.fmt = get_fmt(ui.nps);
         cfe.njobs = ui.nps;
         
      case('NM')
         cfe.snum = 1;
         for i = 0:(ui.nsimp-1)
            cfe.smplx_inds{i+1} = ((i*(cfe.nvar+1)+1):((i+1)*(cfe.nvar+1)))';
         end
         cfe.fmt = get_fmt(cfe.njobs);
         
         % This gets changed later, in the case of the NM alg.
         cfe.njobs = ui.nsimp*(cfe.nvar+1);
   end
   
   %-----------------------------------------------------------------------------------------%
   % Eigenvalues and covariances... better to not touch them until we need them...           %
   %-----------------------------------------------------------------------------------------%
   %call init_prop_cov_mat(maxvar, nvar, include_var)
   %call eigen_prop_cov_mat(nvar)
   %-----------------------------------------------------------------------------------------%

   if any(strcmp(ui.opt_type,{'SA','DRAM'}))
      cfe.alpha   = NaN(ndr,1);                   % Acceptance probability for proposed state 
      cfe.burn_in = 0.3;                          % Fraction of runs which should be burn-in
   end
   
   
end

