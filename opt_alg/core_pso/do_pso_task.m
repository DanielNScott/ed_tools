function [ ] = do_pso_task( particle_num )
%DO_PSO_TASK Gets called in every particle 
%   Detailed explanation goes here

particle_num = str2double(particle_num);
load('../pso.mat')

if ~ nfo.is_test
   if ctrl.iter == 1
      load('../obs.mat')
      disp('obs.mat loaded')
   else
      load('../particle_1/obs_proc.mat')
      disp('obs_proc.mat loaded')
      data.obs = obs;
   end
end

if strcmp(ui.opt_type,'PSO')
   ui.rundir = [ui.rundir '/particle_' num2str(particle_num) '/'];
   data.state_prop = data.state(:,particle_num);
end
   
%--------------------------------------------------------------------------------%
% Run model.
%--------------------------------------------------------------------------------%
[ctrl, data, nfo, ~] = run_model(ctrl, data, nfo, ui);
%--------------------------------------------------------------------------------%


% If this is the first particle and the first iteration, transfer back the processed
% observational data, otherwise just xfer the output and the objective. Elements of structures
% aren't valid variables here so we have to put them in "normal" vars.
out = data.out;
obj = ctrl.obj_prop;
obs = data.obs;
stats = data.stats;

if nfo.is_test
   obj = out;
end

if particle_num == 1 && ctrl.iter == 1
   save('particle_out.mat','out')
   save('particle_obj.mat','obj')
   save('particle_stats.mat','stats')
   if ~ nfo.is_test
      save('obs_proc.mat','obs')
   end
else
   save('particle_out.mat','out')
   save('particle_obj.mat','obj')
   save('particle_stats.mat','stats')
end

end
