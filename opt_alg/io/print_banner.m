function [ ] = print_banner(ctrl,data,hist,ui,banner_num )
%PRINT_BANNER Summary of this function goes here
%   Detailed explanation goes here

if ui.verbose >= 1;
   if banner_num == 1
      disp('%--------------------------------------------------------------------%')
      disp([' Iteration             : ', num2str(ctrl.iter)])
      disp('%--------------------------------------------------------------------%')
      disp(['Delayed Rejection Step : ', num2str(ctrl.idr)])
      disp(['Delayed Rejection Fact.: ', num2str(ctrl.dr_fact(ctrl.idr))])
      disp(' ')

   elseif banner_num == 2
      disp('New best state found!');
      disp(['Proposed objective: ' num2str(ctrl.obj_prop)]);
      disp(['Previous best     : ' num2str(min(hist.obj))]);

   elseif banner_num == 3
      disp('%---------------------------------------------%')
      disp(' Displaying acceptance/rejection criteria:')
      disp('%---------------------------------------------%')
      disp(['alpha             : ', num2str(ctrl.alpha(1))])

      if strcmp(ui.opt_type,'SA')
         disp(['temp              : ', num2str(ctrl.temp)])
         disp(['temp_start        : ', num2str(ui.temp_start)])
         disp(['temp_max          : ', num2str(temp_max)])
      end

      disp(['obj_prop          : ', num2str(ctrl.obj_prop)])
      disp(['obj_curr          : ', num2str(ctrl.obj_curr)])

      if strcmp(ui.opt_type,'DRAM')
         disp(['prop_prior_wgt    : ', num2str(ctrl.prop_prior_wgt(1))])
         disp(['curr_prior_wgt    : ', num2str(ctrl.curr_prior_wgt)])
      end
      disp(' ')

   elseif banner_num == 4
      disp(['alpha_inter       : ', num2str(ctrl.alpha_inter)])
      disp(['alpha             : ', num2str(ctrl.alpha(ctrl.idr))])
      disp(['obj_prop(1)       : ', num2str(ctrl.obj_prop(1))])
      disp(['obj_prop(2)       : ', num2str(ctrl.obj_prop(ctrl.idr-1))])
      disp(['prop_prior_wgt(1) : ', num2str(ctrl.prop_prior_wgt(1))])
      disp(['prop_prior_wgt(2) : ', num2str(ctrl.prop_prior_wgt(2))])
      disp(['obj_curr          : ', num2str(ctrl.obj_curr)])
      disp(['curr_prior_wgt    : ', num2str(ctrl.curr_prior_wgt)])
      disp(' ')

   elseif banner_num == 5
      if ctrl.acc_step == 0;  disp('Step Rejected... ');                 end
      if ctrl.acc_step == 1;  disp('Step Accepted... ');                 end
      if strcmp(ui.opt_type,'DRAM');disp(['idr            : ', num2str(ctrl.idr)]); end
      disp(['rand           : ', num2str(ctrl.accept_test_rand(1))])
      disp('Proposed state : ')
      disp(data.state_prop)
      disp(' ')
   end
end


end

