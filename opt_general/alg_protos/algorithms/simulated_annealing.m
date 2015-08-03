function [state_best,hist] = simulated_annealing ...
                        (state_init,iter_max,stop_crit,obj_fn,acc_fn,temp_fn,nghbr_fn,is_feasable)
%SIMULATED_ANNEALING Performs simulated annealing.
% Input:
%   state_init: Initial state of system.
%     iter_max: Parameter defining annealing schedule.
%    stop_crit: Energy below which any solution is acceptable.
%       obj_fn: Energy function (to be minimized)
%       acc_fn: Probability distribution for state transitions
%      temp_fn: Temperature function, giving temp from num. of iters.
%     nghbr_fn: Probabilistic function generating 'neighboring states' of s.
%
%   Output Vars:
%    sbest: Best state found
%    trace: Structure of states and corrosponding energies trace.
    
% Initialize vectors of states trace and their energies.
state = state_init;
obj   = obj_fn(state_init);

state_best = state_init;
obj_best   = obj;

ndim = length(state_init);
hist = struct();
hist.states     = nan(iter_max,ndim);
hist.objectives = nan(iter_max,1);

state_prev = rand(1,2)*6 - 3;

iter = 1;
while iter <= iter_max && (obj > stop_crit)
   temp     = temp_fn(iter);
   feasible = 0;
   
   while not(feasible)
      state_prop = nghbr_fn(state,state_prev,temp);
      feasible   = is_feasable(state_prop);
   end
   
   obj_prop = obj_fn(state_prop);
   if acc_fn(temp,obj,obj_prop) > rand()
      state_prev = state;
      state     = state_prop;
      obj       = obj_prop;
   end
   
   if obj_prop < obj_best
      state_best = state_prop;
      obj_best   = obj_prop;
   end
   
   hist.states(iter,:) = state;
   hist.objectives(iter) = obj;
   iter = iter + 1;
end

end
