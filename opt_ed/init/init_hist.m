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
