function [ ui, cfe, obs, hist ] = setup_optim( settings_fname )
%READ_SETTINGS Summary of this function goes here
%   Detailed explanation goes here

%-----------------------------------------------------------------------------------------------
% Load the contents of the settings.m file into this function's namespace.
%-----------------------------------------------------------------------------------------------
disp('Loading settings.m ...')
run(settings_fname)
%-----------------------------------------------------------------------------------------------

%-----------------------------------------------------------------------------------------------
% Copy the settings into a structure to make the algorithm workspace less cluttered.
%-----------------------------------------------------------------------------------------------
user_input = who;

ui = struct();
for i = 1:length(user_input)
   iname = user_input{i};
   ui.(iname) = (eval(iname));
end

clearvars -except ui
%-----------------------------------------------------------------------------------------------


%-----------------------------------------------------------------------------------------------
% Trim opt_metadata to only those things we want to include.
%-----------------------------------------------------------------------------------------------
 ui.opt_metadata = ui.opt_metadata(cell2mat(ui.opt_metadata(:,end)) == 1,1:end-1);
%-----------------------------------------------------------------------------------------------

% Look for opt.mat, infer init/restart status, determine opt_years.
cfe.restart = 0; % By default.
disp(['Restart? (Boolean): ', num2str(cfe.restart)])
if ui.opt_mat_check
   if exist('./opt.mat','file')

      % Give primacy to new value of some vars:
      resub_override = ui.resub_override;
      disp('Resubmission override from current settings file taking primacy over opt.mat content.')

      load('./opt.mat')
      
      ui.resub_override = resub_override;
      cfe.restart = 1;
   end
end

if ~ cfe.restart
   cfe  = init_cfe(cfe,ui);
   hist = init_hist(cfe,ui);

   % Get observations against which to compare the model.
   if ~ cfe.is_test
      disp('Retrieving observational data...')
      obs = get_obs( ui.opt_data_dir, ui.obs_prefixes, cfe.simres, ui.obs_years);
   else
      obs = [];
   end
   
end
%-----------------------------------------------------------------------------------------%

end


function [ cfe ] = init_cfe( cfe, ui )
%INIT_ALG_SPEC_CTRL Summary of this function goes here
%   Detailed explanation goes here

   cfe.iter = 0;          % Controls the main loop of the program.
   cfe.multi_node  = strcmp(ui.sim_location,'external');
   cfe.single_node = strcmp(ui.sim_location,'local');
   
   cfe.init_dir = pwd;
   cfe.test_fns = {'Rosenbrock','Sphere','Eggholder','Styblinski-Tang'};
   cfe.is_test  = any(strcmp(ui.model,cfe.test_fns));
   
   cfe = parse_params(cfe,ui);
   
   cfe.uses_proposals = any(strcmp(ui.opt_type,{'SA','DRAM','NM'}));

   cfe.nvar   = numel(cfe.means);       % The number of model parameters being optimized.
   cfe.tenths = 1;                     % Current 1/10th of opt. iterations we're in.

   switch ui.opt_type         
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
    
   
end

function [ cfe ] = parse_params( cfe, ui )
%PARSE_METADATA Summary of this function goes here
%   Detailed explanation goes here

%----------------------------------------------------------------------------------------------%
% Throughout this optimization program p_means is used as the set of parameter means, p_sdevs as
% their standard deviations, and labels is used to identify these vars by name and to determine
% which pfts each 'version' of the parameter should be applied to. See settings_ed_opt for more
% information.
%----------------------------------------------------------------------------------------------%


cfe.simres = '';
% Extract some information from the parameter matrix.
if cfe.is_test
   label_rng = 1;
   means_ind = 2;
   sdevs_ind = 3;
   bnd_ind   = 4;
   mask_ind  = 5;
else
   label_rng = 1:3;
   means_ind = 4;
   sdevs_ind = 5;
   bnd_ind   = 6;
   mask_ind  = 7;
end
row_msk     = cell2mat(ui.params(:,mask_ind)) == 1;

cfe.means    = cell2mat(ui.params(row_msk, means_ind)) *ui.multiplier;
cfe.sdevs    = cell2mat(ui.params(row_msk, sdevs_ind)) *ui.multiplier;
cfe.bounds   = cell2mat(ui.params(row_msk,   bnd_ind)) *ui.multiplier;
cfe.labels   = ui.params(row_msk, label_rng);

cfe.simres  = get_simres(ui.opt_metadata);

% Tell the user what's up
if any(strcmp(ui.model,{'ED2.1','read_dir'}))
   disp(['ED Parameter matrix loaded with multiplier ', num2str(ui.multiplier)])
   disp(ui.params(cell2mat(ui.params(:,end)) == 1,1:end-1));
end

end

function [ dim1, dim2 ] = get_grid_dims( vector )
%GET_GRID_DIMS Finds the two largest mutiplicative factors for a number with prime factorization
%given by the input "vector"

   n_el      = numel(vector);
   while n_el > 2
      vector    = sort(vector,'descend');
      vector(2) = vector(2)*vector(3);
      vector    = [vector(1:2) vector(4:end)];
      n_el      = numel(vector);
   end
   vector = vector(1:2);
   vector = sort(vector,'descend');
   
   dim1 = vector(1);
   dim2 = vector(2);

end


function [ res ] = get_simres( opt_metadata )
%GET_SIMRES Returns a structure of logicals representing the resolution of this simulation.
%   Outputs 'res' with fields 'fast', 'daily', 'monthly', and 'yearly'

   res.fast    = any(strcmp(opt_metadata(:,1),'hourly'));
   res.daily   = any(strcmp(opt_metadata(:,1),'daily'));
   res.monthly = any(strcmp(opt_metadata(:,1),'monthly'));
   res.yearly  = any(strcmp(opt_metadata(:,1),'yearly'));

end
function [ hist ] = init_hist( cfe, ui )
%INIT_HIST Summary of this function goes here
%   Detailed explanation goes here
   
   hist = struct();

   switch ui.opt_type
      case('PSO')
         vs_dim = ui.nps;
         hist.state = NaN(cfe.nvar,vs_dim,ui.niter);                 % Every state evaluated
         hist.obj   = NaN(         vs_dim,ui.niter);                 % Every sim.s objective.
         hist.vels  = NaN(cfe.nvar,vs_dim,ui.niter);                 % Particle velocities
         hist.pbo   = Inf(vs_dim  ,1              );                  % Best particle objective
         %hist.pbs   = NaN(cfe.nvar,vs_dim);                          % Best particle state
         
         spread = repmat(cfe.bounds(:,2) - cfe.bounds(:,1),1,vs_dim);  % Compute parameter spreads
         cents  = repmat(cfe.bounds(:,1) + spread(:,1)/2 ,1,vs_dim);  % Compute centers of ranges
         
         istate = (rand(cfe.nvar,vs_dim) - 0.5) .*spread + cents;    % Recenter & expand rands.
         ivels  = (rand(cfe.nvar,vs_dim) - 0.5) .*spread;            % 

         hist.pbs          = istate;
         hist.state(:,:,1) = istate;
         hist.vels(:,:,1)  = ivels;

      case({'DRAM','SA'})
         disp('Please note only sim_parallel == 1 functional for SA/DRAM at this time.')
         vs_dim = 1;
         hist.state = NaN(cfe.nvar,vs_dim,cfe.niter);                 % Every state evaluated
         hist.obj   = NaN(         vs_dim,ui.niter);                 % Objectives from every sim

         if strcmp(opt_type,'DRAM')
            hist.prior_wgt = NaN(vs_dim,ui.niter);                   % Priors' vals, not norm'd
         end
         
         hist.state(:,1,1) = cfe.means;
         
      case('NM')
         vs_dim = ui.nsimp*(cfe.nvar+1);
         hist.state = NaN(cfe.nvar,vs_dim,ui.niter);                 % Every state evaluated
         hist.obj   = NaN(         vs_dim,ui.niter);                 % Objectives from every sim
            
         hist.smplx(1:ui.nsimp) = ...
            struct('obj_r',NaN(1       ,ui.niter), ...
                   'obj_e',NaN(1       ,ui.niter), ...
                   'obj_c',NaN(1       ,ui.niter), ...
                   'pt_r' ,NaN(cfe.nvar,ui.niter), ...
                   'pt_e' ,NaN(cfe.nvar,ui.niter), ...
                   'pt_c' ,NaN(cfe.nvar,ui.niter), ...
                   'cent' ,NaN(cfe.nvar,ui.niter), ...
                   'snum' ,1                     , ...
                   'obj_s',NaN(cfe.nvar+1,ui.niter), ...
                   ...'step' ,cell(1      ,ui.niter), ...
                   'scnt' ,0                     , ...
                   'state',NaN(cfe.nvar,cfe.nvar+1,ui.niter));
         
%          hist.obj_r = NaN(ui.niter,ui.nsimp);
%          hist.obj_e = NaN(ui.niter,ui.nsimp);
%          hist.obj_c = NaN(ui.niter,ui.nsimp);
%          hist.cent  = cell(ui.niter,ui.nsimp);
%          hist.pt_r  = cell(ui.niter,ui.nsimp);
%          hist.pt_e  = cell(ui.niter,ui.nsimp);
%          hist.pt_c  = cell(ui.niter,ui.nsimp);
%          hist.step  = cell(ui.niter,ui.nsimp);
%          
%          for isimp = 1:ui.nsimp
%             hist.step{1,isimp} = 'eval_simplex';
%          end
         for isimp = 1:ui.nsimp
            hist.smplx(isimp).state(:,:,1) = random_states(cfe.bounds,cfe.nvar+1);
            hist.smplx(isimp).step = 'eval_simplex';
        end
   end
   
   if cfe.uses_proposals;
      hist.acc        = NaN(vs_dim,ui.niter);       % List of acceptance/rejections
   end
   
   hist.stats = struct();
   %if cfe.is_test
   %   hist.stats.total_likely = [];
   %else
   %   hist.stats.ns    = [];        % Number of samples
   %   hist.stats.SSTot = [];        % Sum of squares [total]            sum((obs - obs_ave)^2)
   %   hist.stats.SSRes = [];        % Sum of squared residuals [errors] sum((obs - pred   )^2)
   %   hist.stats.Sx    = [];        % Sum of observations               sum((obs          )  )
   %   hist.stats.Sy    = [];        % Sum of predictions                sum((pred         )  )
   %   hist.stats.Sx2   = [];        % Sum of square of obs.             sum((obs          )^2)
   %   hist.stats.Sy2   = [];        % Sum of square of pred.            sum((pred         )^2)
   %   hist.stats.SPxy  = [];        % Sum of product of obs. and pred.  sum((obs*pred     )  )

   %   hist.stats.total_likely = []; % Weighted sum of all likelihoods, to be objective fn.
   %end

end

function [states] = random_states(bounds,nstates)
nvars  = size(bounds,1);
spread = repmat(bounds(:,2) - bounds(:,1)  ,1,nstates);  % Compute parameter spreads
cents  = repmat(bounds(:,1) + spread(:,1)/2,1,nstates);  % Compute centers of ranges
states = (rand(nvars,nstates) - 0.5) .*spread + cents;
end




