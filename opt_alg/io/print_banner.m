function [ ] = print_banner(cfe,data,hist,ui,banner_type)
%PRINT_BANNER Summary of this function goes here
%   Detailed explanation goes here

if ui.verbose >= 1;
   switch lower(banner_type)
      case('iter/idr/dr_fact')
      disp('%--------------------------------------------------------------------%')
      disp([' Iteration             : ', num2str(cfe.iter)])
      disp('%--------------------------------------------------------------------%')
      
      if isfield(cfe,'dr_fact')
         disp(['Delayed Rejection Step : ', num2str(cfe.idr)])
         disp(['Delayed Rejection Fact.: ', num2str(cfe.dr_fact(cfe.idr))])
         disp(' ')
      end

      case('new best')
      disp('New best state found!');
      disp(['Proposed objective: ' num2str(cfe.obj_prop)]);
      disp(['Previous best     : ' num2str(min(hist.obj))]);

      case('a/r criteria')
      disp('%---------------------------------------------%')
      disp(' Displaying acceptance/rejection criteria:')
      disp('%---------------------------------------------%')
      if cfe.idr == 1
         disp(['alpha             : ', num2str(cfe.alpha(1))])

         if strcmp(ui.opt_type,'SA')
            disp(['temp              : ', num2str(cfe.temp)])
            disp(['temp_start        : ', num2str(ui.temp_start)])
            disp(['temp_max          : ', num2str(temp_max)])
         end

         disp(['obj_prop          : ', num2str(cfe.obj_prop)])
         disp(['obj_curr          : ', num2str(cfe.obj_curr)])

         if strcmp(ui.opt_type,'DRAM')
            disp(['prop_prior_wgt    : ', num2str(cfe.prop_prior_wgt(1))])
            disp(['curr_prior_wgt    : ', num2str(cfe.curr_prior_wgt)])
         end
         disp(' ')
      elseif cfe.idr == 2
         disp(['alpha_inter       : ', num2str(cfe.alpha_inter)])
         disp(['alpha             : ', num2str(cfe.alpha(cfe.idr))])
         disp(['obj_prop(1)       : ', num2str(cfe.obj_prop(1))])
         disp(['obj_prop(2)       : ', num2str(cfe.obj_prop(cfe.idr-1))])
         disp(['prop_prior_wgt(1) : ', num2str(cfe.prop_prior_wgt(1))])
         disp(['prop_prior_wgt(2) : ', num2str(cfe.prop_prior_wgt(2))])
         disp(['obj_curr          : ', num2str(cfe.obj_curr)])
         disp(['curr_prior_wgt    : ', num2str(cfe.curr_prior_wgt)])
         disp(' ')
      end

      case('acceptance/rejection')
      if cfe.acc_step == 0;  disp('Step Rejected... ');                 end
      if cfe.acc_step == 1;  disp('Step Accepted... ');                 end
      if strcmp(ui.opt_type,'DRAM');disp(['idr            : ', num2str(cfe.idr)]); end
      disp(['rand           : ', num2str(cfe.accept_test_rand(1))])
      disp('Proposed state : ')
      disp(data.state_prop)
      disp(' ')
   end
end


end

