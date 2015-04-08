function [  ] = PSO(  )
%PSO This is a first pass at a particle swarm optimizer.
%   Detailed explanation goes here

% Search space as grid.
ss_cent = [0,0];           % Specify center 
ss_rng  = [3,3];           % Specify ranges of x,y vals, as +/-

%----------------------------------------------------------------------------------------------%
% Von-Neumman Topology Canonical PSO.
% Canonical PSO is has only 2 influences on a particle, and constriction coefficients.
%----------------------------------------------------------------------------------------------%
niter  = 40;
nps    = 20;                                                % Set number of particles.
phi_1  = 4.1;                                               % Strength of pbest attractor, > 4.
phi_2  = 4.1;                                               % Strength of gbest attractor, > 4.
phi    = phi_1 + phi_2;                                     % Shorthand
chi    = 2/(phi - 2 + sqrt(phi^2 - 4*phi));                 % Constrictor
Vmax   = (ss_rng - ss_cent)*2;                              % Limit velocity to dynamic range.

locs = rand(nps,2) + repmat(ss_cent - 0.5,nps,1);           % Initialize positions, recenter
locs = locs .* repmat(ss_rng*2,nps,1);                      % Expand range

vels = rand(nps,2) + repmat(ss_cent - 0.5,nps,1);           % Initialize velocities, recenter
vels = vels .* repmat(ss_rng*2,nps,1);                      % Expand range

bests = rosenbrock_fn(locs);                                % Initialize particle objectives
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

locg = nan(nps,2);
% Loop through actual PSO steps
for iter = 2:niter
   U_1  = rand(nps,2)*phi_1;
   U_2  = rand(nps,2)*phi_2;
   
   for ip = 1:nps
      best = min(bests(nbrhd(ip,:)'));
      locg(ip,:) = locs(bests == best,:);
   end
      
   vels = chi*(vels + U_1.*(loci - locs) + U_2.*(locg - locs));
   locs = locs + vels;
   
   objs = rosenbrock_fn(locs);
   msk  = objs < bests;

   loci(msk,:) = locs(msk,:);
   bests(msk)  = objs(msk);
   
   best_loc = locs(bests == min(bests),:);
end


plot_rosenbrock_2D([-3,3],[-3,3],0.1,0.1,'incs');
hold on
plot3(loci(:,1),loci(:,2),bests,'or')
hold off

disp(['best loc: ', num2str(best_loc)])
disp(['best obj: ', num2str(min(bests))])

end
