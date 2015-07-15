function [ ] = fake_pso_task(dir)
%FAKE_PSO_TASK Enacts the same proceedure as do_pso_task (for ED), except without run_ed.
%   Inputs:
%     particle_num: Which particle state is this one pretending to have?
%     dir         : What is this particle's directory name? 

addpath(genpath('/n/moorcroftfs2/dscott/ed_tools'));
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
   ui.rundir = [ui.rundir dir];
end 

% Read output:
if ui.verbose >= 1; disp('Copying model output... '); end
data.out = get_output(ui.rundir, nfo.simres, ui.verbose);

   %-------------------------------------------------------------------------------%
   %                       Preprocess Observations (if necessary)                  %
   %-------------------------------------------------------------------------------%
   if ctrl.iter == 1
      vdisp('Preprocessing the observational data... ',0,ui.verbose);
      data.obs = preproc_obs(data.obs, data.out, ui.opt_metadata);
   end
   %-------------------------------------------------------------------------------%
 
 
   %-------------------------------------------------------------------------------%
   %                                   Rework Data                                 %
   % For some model output (things with prefix .Y. in their data structure paths)  %
   % we want to deal with partial sums of e.g. days/months, depending on what      %
   % observations are available. We process these here.                            %
   %-------------------------------------------------------------------------------%
   data.out = rework_data(data.obs, data.out, ui.opt_metadata);
   %-------------------------------------------------------------------------------%


 
%----------------------------------------------------------------------------------%
%                             Calculate the Objective                              %
% Evaluate the objective function. This is where the algorithm is mostly likely to %
% fail due to source-code errors, so catch any faults and dump state to a .mat.    %
%----------------------------------------------------------------------------------%
vdisp('Calculating the objective function... ',0,ui.verbose);
try
   data.stats = get_objective(data.out, data.obs, ui.opt_metadata, ui.model);
catch ME
   ME.getReport()
   disp('Saving dump.mat')
   save('dump.mat')
   error('See Previous Messages.')
end
 
% For the ED model, we want to minimize the quantity (-1* log total likelihood)
if nfo.is_test;
   ctrl.obj_prop = data.out;
else
   ctrl.obj_prop = data.stats.total_likely * (-1);
end
%----------------------------------------------------------------------------------%

 
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
 
if ctrl.iter == 1
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

