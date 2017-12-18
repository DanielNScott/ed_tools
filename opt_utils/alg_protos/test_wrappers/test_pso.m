function [ ] = test_pso(title_addendum)
%TEST_PSO Summary of this function goes here
%   Detailed explanation goes here
n_repetitions = 500;
bnds  = [0.5,3.5; -0.5,3];
hist_edges = 0.0:0.05:1;
max_dist_to_sol = sqrt(sum([[1,1] - bnds(:,1)'].^2));


niter_set = [20,30,40,50,60,200];
figure();
for niter_num = 1:length(niter_set)

    niter = niter_set(niter_num);
    solutions = NaN(n_repetitions,2);
    
    for i = 1:n_repetitions
       nps   = 20;
       inc   = 0.1;
       fn    = @(x) rosenbrock(x);
       gn    = @(x) rosenbrock(x');

       % Find the minimum.
       [sol, ~] = particle_swarm(bnds,nps,niter,fn);

       solutions(i,:) = sol;
    end
    
    subplot(2, length(niter_set)/2, niter_num)
    data = histogram(sqrt(sum((solutions - [1,1]).^2,2)),hist_edges, 'Normalization', 'probability');
    hold on; 
    bar(data.BinEdges(1:end-1)+0.05,cumsum(data.Values),'FaceAlpha',0.3)

    title(['nps = 20, niter = ',num2str(niter)])
    xlabel({'Distance from Solution',['Max Possible ', num2str(max_dist_to_sol)]})
    ylabel('Percent in Bin')
    
    legend({'hist','cdf'})
    
    ylim([0,1])
    xlim([0,max(hist_edges)])
    %disp(solutions)
end
suptitle({'\bf{Dependence of solution quality on max iterations}', title_addendum})

%%
nps_set = [4,8,16,20,30,60];
figure();
for nps_num = 1:length(nps_set)

    nps = nps_set(nps_num);
    solutions = NaN(n_repetitions,2);
    
    for i = 1:n_repetitions
       niter = 40;
       inc   = 0.1;
       fn    = @(x) rosenbrock(x);
       gn    = @(x) rosenbrock(x');

       % Find the minimum.
       [sol, ~] = particle_swarm(bnds,nps,niter,fn);

       solutions(i,:) = sol;
    end
    
    subplot(2, length(nps_set)/2, nps_num)
    data = histogram(sqrt(sum((solutions - [1,1]).^2,2)),hist_edges, 'Normalization', 'probability');
    hold on; 
    bar(data.BinEdges(1:end-1)+0.05,cumsum(data.Values),'FaceAlpha',0.3)

    title(['nps = ', num2str(nps), ', niter = 40'])
    xlabel({'Distance from Solution',['Max Possible ', num2str(max_dist_to_sol)]})
    ylabel('Percent in Bin')
    
    legend({'hist','cdf'})
    
    ylim([0,1])
    xlim([0,max(hist_edges)])
    %disp(solutions)
end
suptitle({'\bf{Dependence of solution quality on num. particles}', title_addendum})


%%
% Determine the x-domain and y-domain (the parameter space grid)
% used in plotting the fit surface.
xdom = -3:0.1:3;
ydom = -3:0.1:3;

[meshVec1,meshVec2] = meshgrid(xdom,ydom);

% Get the actual objectives on the mesh-grid so we can plot the
% objective function along with the fit.
obj = rosenbrock([meshVec1(:),meshVec2(:)]);
obj = reshape(obj,length(xdom),length(ydom));

%-------------------------------------------------------------------------%
% Plot things
%-------------------------------------------------------------------------%
figure();
% Plot the Rosenbrock Function.
hold on
plot_2D_fn( bnds(1,:), bnds(2,:), inc, inc, 'incs', gn, 'none');
plot3(1, 1, rosenbrock([1,1]),'or')
title('\bf{Response Surface (Global)}')

th = 0:pi/50:2*pi;
xunit = 0.25 * cos(th) + 1;
yunit = 0.25 * sin(th) + 1;
h = plot3(xunit, yunit, repmat(40,length(th),1));
hold off
legend({'Objective fn', 'Solution', 'Circle with R = 0.25'})


end

