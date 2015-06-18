function [ ctrl, data, hist ] = get_particle_data( ctrl, data, hist, nps, verbose )
%MERGE_PARTICLE_DATA Summary of this function goes here
%   Detailed explanation goes here

%----------------------------------------------------------------------------------------------%
%     Check up on particles. 
%----------------------------------------------------------------------------------------------%
% file_list = cell(1,nps);
% for i = 1:nps
%    file_list{i} = ['./particle_' num2str(i) '/particle_obj.mat'];     % Particle Data Filename
% end
% 
% wait_for(file_list,180,verbose)

prfx = '/particle_';

%----------------------------------------------------------------------------------------------%
%     If they all exist, load the objectives.
%----------------------------------------------------------------------------------------------%
for i = 1:nps
   obj_name  = ['.' prfx num2str(i) prfx 'obj.mat']; % Particle Data Filename
   wait_for(obj_name,180,verbose)
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
num_best   = num2str(find(min_msk));
out_name   = ['.' prfx num_best prfx 'out.mat'];    % Particle Data Filename
stats_name = ['.' prfx num_best prfx 'stats.mat'];  % Particle Data Filename

load(out_name);
load(stats_name);

hist.out_best = out;	
data.stats    = stats;

vdisp(['particle_' num_best ' (best) out, stats loaded.'],1,verbose)

end


