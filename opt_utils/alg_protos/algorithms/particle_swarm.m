function [sol, trace] = particle_swarm( bnds, niter, nps, fn )
%PSO This is a first pass at a particle swarm optimizer.
%   Detailed explanation goes here

% Useful constants:
ndim    = length(bnds);

% PSO parameter settings:
update_nbrhd  = 1;
adapt_inertia = 1;
adapt_nnbr    = 1;

min_neighbor_frac = 0.25;
min_inert         = 0.1;
max_inert         = 1.1;
start_inert       = 0.37;

cSelf = 1.49;
cSoc  = 1.49;
inert = repmat(start_inert, nps, 1);
neighbor_frac = min_neighbor_frac;

% Randomly initialize locations and vebest_loc_selfties
spread = repmat(bnds(:,2) - bnds(:,1),1,nps);               % Compute parameter spreads
cents  = repmat(bnds(:,1) + spread(:,1)/2 ,1,nps);          % Compute centers of ranges
         
locs = (rand(2,nps) - 0.5) .*spread + cents;                % Recenter & expand rands.
vels = (rand(2,nps) - 0.5) .*spread;                        % 

locs = locs';
vels = vels';

% Useful diagnostic:
%quiver(locs(:,1), locs(:,2), vels(:,1), vels(:,2), 'o')

bests = fn(locs);                                           % Initialize particle objectives
best_loc_self  = locs;                                               % Set locations of bests as current
best_loc = best_loc_self(bests == min(bests),:);

best_loc_glob = nan(nps,ndim);
trace.loc  = nan(niter,nps,ndim);
trace.vals = nan(niter,nps);

trace.states     = nan(niter,ndim);
trace.objectives = nan(niter,1);

% Loop through actual PSO steps
counter = 0;
%counter = zeros(nps,1);

for iter = 1:niter
  
   randSelf = rand(nps, ndim);
   randSoc  = rand(nps, ndim);

   nbrhd = create_neighborhoods(nps, update_nbrhd, neighbor_frac);
   
   % Get location of global best 
   for ip = 1:nps
      best = min(bests(nbrhd(ip,:)'));
      if sum(bests == best) > 1
         ind = find(bests == best,1);
         best_loc_glob(ip,:) = best_loc_self(ind,:);
      else
         best_loc_glob(ip,:) = best_loc_self(bests == best,:);
      end
   end
   
   % Standard velocity update
   vels = inert.*vels + cSelf*randSelf.*(best_loc_self - locs) + cSoc*randSoc.*(best_loc_glob - locs);
   
   % Add a decaying repulsion from other particles
   %for ip = 1:nps
   %    displacements = locs - locs(ip,:);
   %    dists = sqrt(sum(displacements.^2, 2));
   %    
   %    msk = setdiff(1:nps,ip);
   %    unit_vecs = displacements(msk,:) ./ repmat(dists(msk),1,2);
   %    speed = sqrt(sum(vels(ip,:).^2,2));
   %    force = -unit_vecs ./ repmat(dists(msk).^2,1,2);
   %    accel = sum(force)/nps * 1/2 * speed * (niter - iter)/iter;
   %    
   %    accel(isnan(accel)) = 0;
   %    vels(ip,:) = vels(ip,:) + accel;
   %end
   
   locs = locs + vels;
   
   % Random reshuffling of the worst locs
   %displacements = locs - best_loc;
   %dists = sqrt(sum(displacements.^2, 2));
   %shuffle_msk = dists < prctile(dists,5);
   %locs(shuffle_msk,:) = ((rand(2,sum(shuffle_msk)) - 0.5)' .* spread(:,1)' + best_loc) *(niter - iter + 1)/niter;
   
   % Clip locations and velocities
   range = bnds(:,2) - bnds(:,1);
   for dim = 1:ndim
      msk = locs(:,dim) < bnds(dim,1);
      locs(msk,dim) = bnds(dim,1);
      vels(msk,dim) = -vels(msk,dim);
      
      msk = locs(:,dim) > bnds(dim,2);
      locs(msk,dim) = bnds(dim,2);
      vels(msk,dim) = -vels(msk,dim);
      
      % Keep velocities from jumping between edges
      msk = abs(vels(:,dim)) > range(dim);
      vels(msk,dim) = vels(msk,dim)/1.5;
   end
   
   objs = fn(locs);
   improved = objs < bests;
   improved_globally = any(objs < min(min(bests)));

   best_loc_self(improved,:) = locs(improved,:);
   bests(improved)  = objs(improved);

   % -- Adaptation a-la MATLAB -- %
   if any(improved_globally)
      counter = max(0, counter - 1);
      neighbor_frac = min_neighbor_frac;
   else
      counter = counter + 1;
      neighbor_frac = neighbor_frac + min_neighbor_frac;
      neighbor_frac = min(neighbor_frac*nps, nps - 1)/nps;
   end
   
   if adapt_inertia == 1
       if counter < 2
          inert = max(min_inert, min(max_inert, 2*inert)); 
        elseif counter > 5
          inert = max(min_inert, min(max_inert, 0.5*inert));        
       end
   end
   %-------------------------------%
   
   best_loc = best_loc_self(bests == min(bests),:);
   
   trace.states    (iter,:)   = locs(find(objs == min(objs),1),:);
   trace.objectives(iter)     = min(objs);
   trace.vals      (iter,:)   = objs;
   trace.locs      (iter,:,:) = locs;
   
end

sol = best_loc;

end

function [nbrhd] = create_neighborhoods(nps, random, neighbor_fraction)

    include_self = 1;
    if random
        nnbrs = floor(nps*neighbor_fraction);
        nbrhd = NaN(nps, nnbrs);
        for ip = 1:nps
            nbrs = randperm(nps - 1, nnbrs);
            nbrs(nbrs > ip) = nbrs(nbrs > ip) + 1;
            nbrhd(ip,:) = nbrs;
        end
        if include_self
            nbrhd = [nbrhd, (1:nps)'];
        end
    else
        prime_fact = factor(nps);
        vnt_dim1   = prod(prime_fact(1:end-1));
        vnt_dim2   = prime_fact(end);
        template   = zeros(1,nps);

        for ip = 1:nps
           b_ind = mod(ip+1,nps);
           u_ind = mod(ip-1,nps);
           r_ind = mod(ip+vnt_dim2,nps);
           l_ind = mod(ip-vnt_dim2,nps);

           nbrs = [b_ind, u_ind, r_ind, l_ind];
           nbrs(nbrs == 0) = nps;
           nbrhd(ip,:) = nbrs;
        end
    end
end
