function [ ui, cfe, obs, hist ] = init_alg( settings_fname )
%READ_SETTINGS Summary of this function goes here
%   Detailed explanation goes here

%-----------------------------------------------------------------------------------------------
% Load the contents of the settings.m file into this function's namespace.
%-----------------------------------------------------------------------------------------------
disp('Loading settings.m ...')
run(settings_fname)
%-----------------------------------------------------------------------------------------------

%-----------------------------------------------------------------------------------------------
% Copy the settings into a structure to make the algorithm workspace less cluttered.
%-----------------------------------------------------------------------------------------------
user_input = who;

ui = struct();
for i = 1:length(user_input)
   iname = user_input{i};
   ui.(iname) = (eval(iname));
end

clearvars -except ui
%-----------------------------------------------------------------------------------------------


%-----------------------------------------------------------------------------------------------
% Trim opt_metadata to only those things we want to include.
%-----------------------------------------------------------------------------------------------
 ui.opt_metadata = ui.opt_metadata(cell2mat(ui.opt_metadata(:,end)) == 1,1:end-1);
%-----------------------------------------------------------------------------------------------

% Look for opt.mat, infer init/restart status, determine opt_years.
cfe.restart = 0; % By default.
disp(['Restart? (Boolean): ', num2str(cfe.restart)])
if ui.opt_mat_check
   if exist('./opt.mat','file')

      % Give primacy to new value of some vars:
      resub_override = ui.resub_override;
      disp('Resubmission override from current settings file taking primacy over opt.mat content.')

      load('./opt.mat')
      
      ui.resub_override = resub_override;
      cfe.restart = 1;
   end
end

if ~ cfe.restart
   cfe  = init_cfe(cfe,ui);
   hist = init_hist(cfe,ui);

   % Get observations against which to compare the model.
   if ~ cfe.is_test
      disp('Retrieving observational data...')
      obs = get_obs( ui.opt_data_dir, ui.obs_prefixes, cfe.simres, ui.obs_years);
   else
      obs = [];
   end
   
end
%-----------------------------------------------------------------------------------------%

end
