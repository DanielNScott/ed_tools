function [sol, trace] = particle_swarm( bnds, niter, nps, fn )
%PSO This is a first pass at a particle swarm optimizer.
%   Detailed explanation goes here

%----------------------------------------------------------------------------------------------%
% Test Settings
%----------------------------------------------------------------------------------------------%
% Search space as grid.
ss_cent = mean(bnds,2)';                                    % Specify center 
ss_rng  = range(bnds');                                     % Specify ranges of x,y vals, as +/-
ndim    = numel(ss_cent);

%----------------------------------------------------------------------------------------------%
% Von-Neumman Topology Canonical PSO.
% Canonical PSO is has only 2 influences on a particle, and constriction coefficients.
%----------------------------------------------------------------------------------------------%
phi_1  = 4.1;                                               % Strength of pbest attractor, > 4.
phi_2  = 4.1;                                               % Strength of gbest attractor, > 4.
phi    = phi_1 + phi_2;                                     % Shorthand
chi    = 2/(phi - 2 + sqrt(phi^2 - 4*phi));                 % Constrictor
%Vmax   = (ss_rng - ss_cent)*2;                             % Limit velocity to dynamic range.

locs = rand(nps,ndim) + repmat(ss_cent - 0.5,nps,1);        % Initialize positions, recenter
locs = locs .* repmat(ss_rng,nps,1);                        % Expand range

vels = rand(nps,ndim) + repmat(ss_cent - 0.5,nps,1);        % Initialize velocities, recenter
vels = vels .* repmat(ss_rng,nps,1);                        % Expand range

bests = fn(locs);                                           % Initialize particle objectives
loci  = locs;                                               % Set locations of bests as current

% Create neighborhoods
prime_fact = factor(nps);
vnt_dim1   = prod(prime_fact(1:end-1));
vnt_dim2   = prime_fact(end);
template   = zeros(1,nps);
for ip = 1:nps;
   b_ind = mod(ip+1,nps);
   u_ind = mod(ip-1,nps);
   r_ind = mod(ip+vnt_dim2,nps);
   l_ind = mod(ip-vnt_dim2,nps);
   
   nbrs = [b_ind, u_ind, r_ind, l_ind];
   nbrs(nbrs == 0) = nps;
   nbrhd(ip,:) = nbrs;
end

locg = nan(nps,ndim);
trace.loc  = nan(niter,nps,ndim);
trace.vals = nan(niter,nps);

trace.states     = nan(niter,ndim);
trace.objectives = nan(niter,1);

% Loop through actual PSO steps
for iter = 1:niter
   U_1  = rand(nps,ndim)*phi_1;
   U_2  = rand(nps,ndim)*phi_2;
   
   for ip = 1:nps
      best = min(bests(nbrhd(ip,:)'));
      if sum(bests == best) > 1
         ind = find(bests == best,1);
         locg(ip,:) = locs(ind,:);
      else
         locg(ip,:) = locs(bests == best,:);
      end
   end
      
   vels = chi*(vels + U_1.*(loci - locs) + U_2.*(locg - locs));
   locs = locs + vels;
   
   objs = fn(locs);
   msk  = objs < bests;

   loci(msk,:) = locs(msk,:);
   bests(msk)  = objs(msk);
   
   best_loc = locs(find(bests == min(bests),1),:);
   
   trace.states    (iter,:)   = locs(find(objs == min(objs),1),:);
   trace.objectives(iter)     = min(objs);
   trace.vals      (iter,:)   = objs;
   trace.locs      (iter,:,:) = locs;
end

sol = best_loc;



end
