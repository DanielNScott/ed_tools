function [ ] = do_pso_task( particle_num )
%DO_PSO_TASK Gets called in every particle 
%   Detailed explanation goes here

particle_num = str2double(particle_num);
load('../pso.mat')

if ctrl.iter == 1
   load('../obs.mat')
   disp('obs.mat loaded')
else
   load('../particle_1/obs_proc.mat')
   disp('obs_proc.mat loaded')
   data.obs = obs;
end


if strcmp(ui.opt_type,'PSO')
   ui.rundir = [ui.rundir '/particle_' num2str(particle_num) '/'];
end
   
%--------------------------------------------------------------------------------%
% Run model.
%--------------------------------------------------------------------------------%
if ui.verbose >= 0; disp('Running the model... '); end
data.out = run_model(data.state(:,particle_num),ui,nfo);
%--------------------------------------------------------------------------------%


%--------------------------------------------------------------------------------%
% Preprocess observational data if it's necessary.
%--------------------------------------------------------------------------------%
if ctrl.iter == 1 && (~ nfo.test || strcmp(ui.model,'read_dir'));
   if ui.verbose >= 0; disp('Preprocessing the observational data... '); end
   data.obs = preproc_obs(data.obs, data.out, ui.opt_metadata);
end
%--------------------------------------------------------------------------------%


%--------------------------------------------------------------------------------%
% For some model output (things with prefix .Y. in their data structure paths) 
% we want to deal with partial sums of e.g. days/months, depending on what 
% observations are available. We process these here.
%--------------------------------------------------------------------------------%
if ~ nfo.test || strcmp(ui.model,'read_dir')
   data.out = rework_data(data.obs, data.out, ui.opt_metadata);
end
%--------------------------------------------------------------------------------%


%--------------------------------------------------------------------------------%
% Evaluate the objective function. This is where the opt. alg.
% is most likely to fail, so catch any potential errors and dump to a .mat.                                %
%--------------------------------------------------------------------------------%
if ui.verbose >= 0; disp('Calculating the objective function... '); end
try
   data.stats = get_objective(data.out, data.obs, ui.opt_metadata, ui.model);
catch ME
   ME.getReport()
   disp('Saving dump.mat')
   save('dump.mat')
   error('See Previous Messages.')
end

% For the ED model, we want to minimize the quantity (-1* log total likelihood)
if ~ nfo.test || strcmp(ui.model,'read_dir');
   ctrl.obj = data.stats.total_likely * (-1);
else
   ctrl.obj = data.out;
end
%--------------------------------------------------------------------------------%


% If this is the first particle and the first iteration, transfer back the processed
% observational data, otherwise just xfer the output and the objective. Elements of structures
% aren't valid variables here so we have to put them in "normal" vars.
out = data.out;
obj = ctrl.obj;
obs = data.obs;
stats = data.stats;
if particle_num == 1 && ctrl.iter == 1
   save('particle_out.mat','out')
   save('particle_obj.mat','obj')
   save('particle_stats.mat','stats')
   save('obs_proc.mat','obs')
else
   save('particle_out.mat','out')
   save('particle_obj.mat','obj')
   save('particle_stats.mat','stats')
end

end
