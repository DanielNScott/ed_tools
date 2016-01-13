function [ cfe, hist] = update_alg( cfe, hist, ui )
%PRE_SIM_ALG_PIECES Summary of this function goes here
%   Detailed explanation goes here

cfe.iter = cfe.iter + 1;

switch ui.opt_type
case('DRAM')
   % Not yet functional, does nothing.
   %cfe.covar = adapt_covar(cfe,ui);

   cfe.idr = cfe.idr + 1;
   if cfe.idr > ui.ndr
      cfe.idr = 1;
   end
   if cfe.idr == 1;
      hist.acc(cfe.iter) = 0;
   end

case('SA')
   hist.acc(cfe.iter) = 0;
   cfe.temp = get_temp(ui.cool_sched, ui.temp_start, cfe.iter, ...
                        ui.niter, ui.mantissa, ui.exp_mult);
case('NM')
   if strcmp(ui.opt_type,'NM') && cfe.iter > 1
      cfe.njobs = size(ui.nsimp,2);
   end
   
case('PSO')
   % PSO is deterministic
   if cfe.iter ~= 1
      state = hist.state(:,:,cfe.iter - 1);
      vels  = hist.vels (:,:,cfe.iter - 1);
      vel_max = cfe.vel_max;
      chi   = cfe.chi;
      phi_1 = ui.phi_1;
      phi_2 = ui.phi_2;
      pbs   = hist.pbs;
      pbo   = hist.pbo;
      nbrhd = cfe.nbrhd;
      nvar  = size(hist.state,1);
      [state_prop, vels] = update_pso_state(state,vels,vel_max,chi,phi_1,phi_2,pbs,pbo,nbrhd,nvar);
      hist.state(:,:,cfe.iter) = state_prop;
      hist.vels (:,:,cfe.iter) = vels;
   end   
end


end

