function [ alpha ] = get_alpha( cfe, ui )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

if cfe.idr == 1
   if cfe.iter == 1
      alpha = 1;
   else
      % Function for getting acceptance rates ('alphas') for DRAM
      if strcmp(ui.opt_type,'DRAM')
         alpha = min(1, exp(-1* (cfe.obj_prop - cfe.obj + cfe.prop_prior_wgt - cfe.curr_prior_wgt)));
      end

      if strcmp(ui.opt_type,'SA')
         % Functions for getting acceptance rates ('alphas') for SA
         if cfe.obj_prop <= cfe.obj_curr
            alpha = 1;                                  % We always accept better states
            return
         end

         if strcmp(ui.acc_crit,'Boltzmann')             %
            alpha = boltzmann(cfe.temp,cfe.obj,cfe.obj_prop);

         elseif strcmp(ui.acc_crit,'Log_Decay')         % As is logarithmic decay
            alpha = log_decay(cfe.temp,cfe.temp_max);
         end
      end
   end
   
elseif idr == 2;
   %--------------------------------------------------------------------------------%
   % Calculate the second delayed rejection factor if we rejected the proposed step.%
   %--------------------------------------------------------------------------------%
   %call dr_prop_rat(nvar, data.state, rejected_var(1,1:nvar), data.state_prop, prop_ratio)

   alpha_inter = get_cfe.alpha(cfe.obj_prop(cfe.idr-1), prop_prior_wgt(cfe.idr-1), cfe.obj_prop(cfe.idr), prop_prior_wgt(cfe.idr));
   alpha(cfe.idr)  = min(1., exp(cfe.obj_prop(cfe.idr) + prop_prior_wgt(cfe.idr) - obj_curr - curr_prior_wgt) ...
                            * prop_ratio * (1.0 - cfe.alpha_inter) / (1.0 - cfe.alpha(cfe.idr-1)));

end

end

