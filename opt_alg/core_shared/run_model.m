function [ ctrl, data, nfo, ui ] = run_model( ctrl, data, nfo, ui )
%RUN_MODEL Summary of this function goes here
%   Detailed explanation goes here

vdisp('Running the model... ',0,ui.verbose);
if nfo.is_test
   data.out = run_test(data.state_prop,ui,nfo);
   ctrl.obj = data.out;

else
   data.out = run_ed(data.state_prop,ui,nfo);
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
end
%----------------------------------------------------------------------------------%



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

end

