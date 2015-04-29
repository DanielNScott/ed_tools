function [ ctrl, data, hist ] = get_particle_data( ctrl, data, hist, nps, verbose )
%MERGE_PARTICLE_DATA Summary of this function goes here
%   Detailed explanation goes here

%----------------------------------------------------------------------------------------------%
%     Check up on particles. 
%----------------------------------------------------------------------------------------------%
file_list = cell(1,nps);
for i = 1:nps
   file_list{i} = ['./particle_' num2str(i) '/particle_obj.mat'];     % Particle Data Filename
end

wait_for(file_list,180,verbose)

%----------------------------------------------------------------------------------------------%
%     If they all exist, load the objectives.
%----------------------------------------------------------------------------------------------%
for i = 1:nps
   obj_name  = ['./particle_' num2str(i) '/particle_obj.mat']; % Particle Data Filename
   load(obj_name);                                             % Load each particle's data
   ctrl.obj(i) = obj;
   vdisp(['particle_' num2str(i) ' objective loaded.'],1,verbose)
end

% Create a mask for those objectives which are better than previous particle bests.
better_msk = ctrl.obj < ctrl.pbo;

% Set the particle best states to those resulting in such objectives, and save the objectives.
ctrl.pbs(:,better_msk) = data.state(:,better_msk);
ctrl.pbo(better_msk)   = ctrl.obj(better_msk);

% Save the best state yet encountered.
min_msk = ctrl.pbo == min(ctrl.pbo);
data.best_state = ctrl.pbs(:,min_msk);

% Save that state's output.
num_best   = find(min_msk);
out_name   = ['./particle_' num2str(num_best) '/particle_out.mat'];    % Particle Data Filename
stats_name = ['./particle_' num2str(num_best) '/particle_stats.mat'];  % Particle Data Filename
hist.out_best = load(out_name);                                        % Load data
data.stats    = load(stats_name);                                      % Load data
vdisp(['particle_' num2str(num_best) ' (best) out, stats loaded.'],1,verbose)

end


