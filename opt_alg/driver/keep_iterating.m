function [ tf ] = keep_iterating( cfe, niter, opt_type )
%KEEP_ITERATING Summary of this function goes here
%   Detailed explanation goes here

   base_cond = cfe.iter < niter;
   switch opt_type
      case('SA')
         other_conds = cfe.energy > cfe.energy_max;
      case({'PSO','NM','DRAM'})
         other_conds = 1;
   end
   tf = and(base_cond,other_conds);

end

