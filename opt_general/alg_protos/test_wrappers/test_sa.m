function [ ] = test_sa()
%   SA Input Args:
%       s0: Initial state of system.
%     kmax: Parameter defining annealing schedule.
%     emax: Energy below which any solution is acceptable.
%        E: Energy function (to be minimized)
%        P: Acceptance function for state transitions
%     temp: Temperature function, giving temp from num. of iters.
%    nghbr: Probabilistic function generating 'neighboring states' of s.
%

close all
clc

%----------------------------------------------------------------------------------%
% General search configuration, and temperature.
%----------------------------------------------------------------------------------%
state_init = rand(1,2)*6 - 3;
iter_max   = 1000;
stop_crit  = -inf;
obj_fn     = @(x) rosenbrock(x);

bnds    = [-3,3; -3,3];
feas_fn = @(state) all(and(state(:) >= bnds(:,1), state(:) <= bnds(:,2)));

temp_start = 0.01;
%----------------------------------------------------------------------------------%


%----------------------------------------------------------------------------------%
% These define classic Boltzmann Annealing
%----------------------------------------------------------------------------------%
acc_fn   = @(temp,obj_cur,obj_prop) metropolis(temp, obj_cur, obj_prop);
temp_fn  = @(iter) log_cool(temp_start,iter,iter_max);

sigma    = 1;
nghbr_fn = @(pt_cur,pt_prev,temp) (rand(1,2)*6 - 3)*(temp/temp_start + 0.1);
%----------------------------------------------------------------------------------%



%----------------------------------------------------------------------------------%
% Do simulated annealing.
%----------------------------------------------------------------------------------%
[sbest,trace] = simulated_annealing(state_init,iter_max,stop_crit,obj_fn,acc_fn,temp_fn,...
                                    nghbr_fn,feas_fn);
%----------------------------------------------------------------------------------%


disp(['sbest: ',num2str(sbest)])
fn = @(x) obj_fn(x)';
figure()
hold on
plot_2D_fn([-3,3],[-3,3],0.1,0.1,'incs',fn);
plot3(trace.states(:,1),trace.states(:,2),trace.objectives(:,1),'--or','markers',12)
hold off

figure()
subaxis(1,2,1)
plot(1:iter_max,trace.states(:,1))

subaxis(1,2,2)
plot(1:iter_max,trace.states(:,2))

end