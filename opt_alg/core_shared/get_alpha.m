function [ alpha ] = get_alpha( ctrl, ui )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if ctrl.idr == 1
   if ctrl.iter == 1
      alpha = 1;
   else
      % Function for getting acceptance rates ('alphas') for DRAM
      if strcmp(ui.opt_type,'DRAM')
         alpha = min(1, exp(-1* (ctrl.obj_prop - ctrl.obj + ctrl.prop_prior_wgt - ctrl.curr_prior_wgt)));
      end

      if strcmp(ui.opt_type,'SA')
         % Functions for getting acceptance rates ('alphas') for SA
         if ctrl.obj_prop <= ctrl.obj_curr
            alpha = 1;                                 % We always accept better states
            return
         end

         if strcmp(ui.acc_crit,'Boltzmann')                   % Use the "Metropolis Acceptance Criteria"
            alpha = exp(-(ctrl.obj_prop - ctrl.obj)/ctrl.temp);    % i.e. a Boltzmann Distribution.

         elseif strcmp(ui.acc_crit,'Sq_Decay')          % Squared decay is a reasonable
            alpha = (ctrl.temp/ctrl.temp_max)^2;                      % alternative

         elseif strcmp(ui.acc_crit,'Log_Decay')         % As is logarithmic decay
            alpha = (2- log10(100*(ctrl.temp_max - ctrl.temp)/ctrl.temp_max))/2;

         end
      end
   end
   
elseif idr == 2;
   %--------------------------------------------------------------------------------%
   % Calculate the second delayed rejection factor if we rejected the proposed step.%
   %--------------------------------------------------------------------------------%
   %call dr_prop_rat(nvar, data.state, rejected_var(1,1:nvar), data.state_prop, prop_ratio)

   alpha_inter = get_ctrl.alpha(ctrl.obj_prop(ctrl.idr-1), prop_prior_wgt(ctrl.idr-1), ctrl.obj_prop(ctrl.idr), prop_prior_wgt(ctrl.idr));
   alpha(ctrl.idr)  = min(1., exp(ctrl.obj_prop(ctrl.idr) + prop_prior_wgt(ctrl.idr) - obj_curr - curr_prior_wgt) ...
                            * prop_ratio * (1.0 - ctrl.alpha_inter) / (1.0 - ctrl.alpha(ctrl.idr-1)));

end

end

