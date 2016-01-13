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
%obj_fn     = @(x) rosenbrock(x);
obj_fn     = @(x) styblinski_tang(x);
low_bnd    = -80;

bnds    = [-3,3; -3,3];
feas_fn = @(state) all(and(state(:) >= bnds(:,1), state(:) <= bnds(:,2)));

temp_start = 300;
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
[sa_sol,sa_trace] = simulated_annealing(state_init,iter_max,stop_crit,obj_fn,acc_fn,temp_fn ...
                                        ,nghbr_fn,feas_fn);
smplx = (rand(3,2) - 0.5)*6;
tobj_fn = @(x,temp,sgn) max(-80,obj_fn(x) - sgn*temp*log(rand));
[nmsa_sol,nmsa_trace,~] = nelder_mead_sa([1,2,-1/2,1/2],smplx,[-3,3;-3,3],tobj_fn,temp_fn,-80,iter_max);
%----------------------------------------------------------------------------------%


disp(['sa_sol  : ',num2str(sa_sol)])
disp(['nmsa_sol: ',num2str(nmsa_sol)])

fn = @(x) obj_fn(x');
figure()
hold on
plot_2D_fn([-3,3],[-3,3],0.1,0.1,'incs',fn);
plot3(sa_trace.states(:,1)  ,sa_trace.states(:,2)  ,sa_trace.objectives(:,1)  ,'--or','markers',12)
plot3(nmsa_trace.states(:,1),nmsa_trace.states(:,2),nmsa_trace.objectives(:,1),'--og','markers',12)
hold off

figure()
subaxis(2,2,2)
hist3(sa_trace.states(:,1:2)  ,'Edges',{-3:0.1:3,-3:0.1:3});

subaxis(2,2,4)
hist3(nmsa_trace.states(:,1:2),'Edges',{-3:0.1:3,-3:0.1:3});

subaxis(2,2,1)
hold on
plot(1:iter_max,sa_trace.states(:,1),  'r')
plot(1:iter_max,nmsa_trace.states(:,1),'g')
hold off

subaxis(2,2,3)
hold on
plot(1:iter_max,sa_trace.states(:,2)  ,'r')
plot(1:iter_max,nmsa_trace.states(:,2),'g')
hold off

end