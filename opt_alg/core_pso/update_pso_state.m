function [ state, vels ] = update_pso_state(state,vels,vel_max,chi,phi_1,phi_2,pbs,pbo,nbrhd,nvar)
%UPDATE_PSO_STATE Summary of this function goes here
%   Detailed explanation goes here

nps = size(state,2);

% Caluclate U_1 and U_2.
U_1 = rand(nvar,nps)*phi_1;
U_2 = rand(nvar,nps)*phi_2;

nbs = NaN(nvar,nps);

for ip = 1:nps
   nbo       = min(pbo(nbrhd(ip,:)'));    % Get the neighborhood best objective found
   nbs(:,ip) = state(:,pbo == nbo);       % Get the neighborhood best state found
end

vels  = chi*(vels + U_1.*(pbs - state) + U_2.*(nbs - state));
state = state + vels;

big_vel_max = repmat(vel_max,1,nps);
clip_inds   = vels > big_vel_max;
vels(clip_inds) = vel_max(clip_inds);

end
