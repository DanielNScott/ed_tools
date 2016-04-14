function [ state, vels ] = update_pso_state(state,vels,vel_max,chi,phi_1,phi_2,pbs,pbo,nbrhd,nvar,bnds)
%UPDATE_PSO_STATE Summary of this function goes here
%   Detailed explanation goes here

nps = size(state,2);

% Caluclate U_1 and U_2.
U_1 = rand(nvar,nps)*phi_1;
U_2 = rand(nvar,nps)*phi_2;

nbs = NaN(nvar,nps);

for ip = 1:nps
   nbo       = min(pbo(nbrhd(ip,:)'));    % Get the neighborhood best objective found

   msk  = pbo == nbo;
   inds = find(msk);
   if length(inds) > 1
      ignore_ind = 1 + round(rand);
      msk(inds(ignore_ind)) = 0;
   end

   nbs(:,ip) = state(:,msk);       % Get the neighborhood best state found
end

vels  = chi*(vels + U_1.*(pbs - state) + U_2.*(nbs - state));
state = state + vels;

for ip = 1:nps
   too_large = state(:,ip) > bnds(:,2);
   too_small = state(:,ip) < bnds(:,1);
   
   state(too_large,ip) = bnds(too_large,2);
   state(too_small,ip) = bnds(too_small,1);
end


clip_inds    = vels > vel_max;
%big_vel_max = repmat(vel_max,1,nps);
%clip_inds   = vels > big_vel_max;
vels(clip_inds) = vel_max(clip_inds);

end

