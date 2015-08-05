function [ ] = do_pso_task_upfront( particle_num,obs_proc_loc,niter)
%DO_PSO_TASK Gets called in every particle 
%   Detailed explanation goes here

niter = str2double(niter);

for iter = 1:niter
   
   load('../pso.mat')
   wait_for('run_flag.txt',180,ui.verbose)

   if ~ nfo.is_test
      if ctrl.iter == 1
         load('../obs.mat')
         disp('obs.mat loaded')
      else
         load([obs_proc_loc,'/obs_proc.mat'])
         disp('obs_proc.mat loaded')
         data.obs = obs;
      end
   end

   if strcmp(ui.opt_type,'PSO')
      ui.rundir = [ui.rundir '/particle_' particle_num '/'];
      data.state_prop = data.state(:,str2double(particle_num));
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

   if str2double(particle_num) == 1 && ctrl.iter == 1 && ~nfo.is_test
      save('obs_proc.mat','obs')
   end

   save('particle_out.mat','out')
   save('particle_obj.mat','obj')
   save('particle_stats.mat','stats')
   
   delete('run_flag.txt')
end

end
