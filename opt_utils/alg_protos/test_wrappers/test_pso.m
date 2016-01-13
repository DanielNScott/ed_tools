function [ ] = test_pso( )
%TEST_PSO Summary of this function goes here
%   Detailed explanation goes here

niter = 6;
nps = 4;
bnds = [-3,3;-3,3];

fn = @(x) rosenbrock(x);

[trace, objs] = particle_swarm(bnds,niter,nps,fn);

% Trace has size [niter,nps,2]
% Objs has size [niter,nps] 

best_obj = min(objs,[],2);
min_msk = objs == repmat(best_obj,1,nps);
x_coord = trace(:,:,1);
y_coord = trace(:,:,2);

best_x = x_coord(min_msk);
best_y = y_coord(min_msk);

best_xy = [best_x,best_y];

global_best_obj = min(best_obj);
best_ind = best_obj == min(best_obj);
global_best_xy = best_xy(best_ind,:);

fn = @(x) rosenbrock(x');
plot_2D_fn([-3,3],[-3,3],0.1,0.1,'incs',fn);
hold on
plot3(best_x,best_y,best_obj,'or')
plot3(global_best_xy(1),global_best_xy(2),global_best_obj,'og')
hold off

disp(['best loc: ', num2str(global_best_xy)])
disp(['best obj: ', num2str(global_best_obj)])








niter = 10;
nps = 10;
bnds = [-3,3;-3,3];

fn = @(x) rosenbrock(x);

[trace, objs] = particle_swarm(bnds,niter,nps,fn);

% Trace has size [niter,nps,2]
% Objs has size [niter,nps] 

best_obj = min(objs);
min_msk = objs == repmat(best_obj,niter,1);
x_coord = trace(:,:,1);
y_coord = trace(:,:,2);

best_x = x_coord(min_msk);
best_y = y_coord(min_msk);

best_xy = [best_x,best_y];

global_best_obj = min(best_obj);
best_ind = best_obj == min(best_obj);
global_best_xy = best_xy(best_ind,:);

fn = @(x) rosenbrock(x');
plot_2D_fn([-3,3],[-3,3],0.1,0.1,'incs',fn);
hold on
plot3(best_x,best_y,best_obj,'or')
plot3(global_best_xy(1),global_best_xy(2),global_best_obj,'og')
hold off

disp(['best loc: ', num2str(global_best_xy)])
disp(['best obj: ', num2str(global_best_obj)])



end

