function [ ] = test_pso_curv_covar( )
%TEST_PSO_CURV_COVAR Summary of this function goes here
%   Detailed explanation goes here

% Set PSO params and problem specifications
nps   = 20;
niter = 60;
bnds  = [-3,3; -3,3];
inc   = 0.1;
fn    = @(x) rosenbrock(x);
gn    = @(x) rosenbrock(x');

% Find the minimum.
[sol, trace] = particle_swarm(bnds,nps,niter,fn);

% Get particle distances from the solution
flat_locs = reshape(trace.locs,[nps*niter,2]);
flat_objs = reshape(trace.vals,[nps*niter,1]);
big_sol   = repmat(sol,[nps*niter,1]);
diffs     = sqrt(sum((flat_locs - big_sol).^2,2));

% Mask out 10th percentile of data in terms of euclidean distance.
% These particles will be used to construct the response surface.
msk   = diffs < prctile(diffs,2);
blocs = flat_locs(msk,:);

% Find the minimum and maximum locations to plot particles in
% parameter space.
blocmin = min(blocs);
blocmax = max(blocs);

blocrng = blocmax - blocmin;
blocinc = blocrng/50;

% Get the response surface aka second order fit surface.
[funHand,goodOfFit,fitOut] = fit([blocs(:,1),blocs(:,2)],flat_objs(msk),'poly22');
%params = fit_quadratic([blocs(:,1),blocs(:,2),flat_objs(msk)],repmat([-400,400],6,1));

% Determine the x-domain and y-domain (the parameter space grid)
% used in plotting the fit surface.
xdom = (blocmin(1)-blocrng(1)):blocinc(1):(blocmin(1)+blocrng(1));
ydom = (blocmin(2)-blocrng(2)):blocinc(2):(blocmin(2)+blocrng(2));

[meshVec1,meshVec2] = meshgrid(xdom,ydom);
funVals = funHand(meshVec1(:),meshVec2(:));
funVals = reshape(funVals,length(xdom),length(ydom));

% Create best-point-transects of fit at the solution.
% SX     = size(X);
btranx = [repmat(sol(1,1),1,length(xdom)); ydom]';
btrany = [xdom; repmat(sol(1,2),1,length(xdom))]';

btranxval = funHand(btranx);
btranyval = funHand(btrany);

% Get the actual objectives on the mesh-grid so we can plot the
% objective function along with the fit.
obj = rosenbrock([meshVec1(:),meshVec2(:)]);
obj = reshape(obj,length(xdom),length(ydom));

% Gradient from fit at optimization solution:
[dfdx, dfdy, dfdxx, dfdxy, dfdyy] = differentiate(funHand,sol(1),sol(2));
gradNorm = sqrt(dfdx^2 + dfdy^2);
unitDir  = -1*[dfdx/gradNorm, dfdy/gradNorm];

% Find & evaluate the minimum of the response surface;
%resp_sol = fminsearch(fh,sol);
%resp_min = fn(resp_sol);

% Create a figure window
gen_new_fig('fig');
subaxis(2,2,1)
   % Plot the Rosenbrock Function.
   plot_2D_fn( bnds(1,:), bnds(2,:), inc, inc, 'incs', gn, 'none');

subaxis(2,2,2)
   % Plot the 90th-percentile best-particle locations & the solution
   hold on
   scatter(blocs(:,1),blocs(:,2))
   scatter(sol(1),sol(2),'or')            % Plot the solution
   quiver( sol(1),sol(2),-dfdx,-dfdy)     % Plot the local downhill direction.
   quiver( sol(1),sol(2), dfdy,-dfdx)     % Plot the local characteristic direction.
   hold off
   
   disp(['dfdxx: ', num2str(dfdxx)])
   disp(['dfdyy: ', num2str(dfdyy)])
   disp(['dfdxy: ', num2str(dfdxy)])
   
   % Local characteristic subspaces? Relationship to covariation?

subaxis(2,2,3)
   % Plot the response surface
   surf(xdom,ydom,funVals,'EdgeColor','none')
   alpha(0.5)

   set(gca,'XLim',[xdom(1),xdom(end)])
   set(gca,'YLim',[ydom(1),ydom(end)])

%    ylims = get(gca,'YLim');
%    xlims = get(gca,'XLim');
%    yp = ylims(2)*ones(SX);
   
   hold on
   surf(xdom,ydom,obj,'EdgeColor','none')
   alpha(0.5)

   plot3(btranx(:,1),btranx(:,2),btranxval,'-','Color','g','LineWidth',1)
   plot3(btrany(:,1),btrany(:,2),btranyval,'-','Color','r','LineWidth',1)
   xlabel('x axis')
   ylabel('y axis')

   xlims = get(gca,'XLim');
   ylims = get(gca,'YLim');

   % Get the projections onto the x-axis and y-axis
   pontoxax = [repmat(xlims(2),length(ydom),1),btranx(:,2)];
   pontoyax = [btrany(:,1),repmat(ylims(2),length(ydom),1)];

   % Plot them
   plot3(pontoxax(:,1),pontoxax(:,2),btranxval,'-b')
   plot3(pontoyax(:,1),pontoyax(:,2),btranyval,'-m')
   plot3(sol(1,1),sol(1,2),rosenbrock(sol),'or')

   legend({'Fit Surf.','Obj Fn.','X-Transect @ Best','Y-Transect @ Best' ...
          ,'X-Transect Proj.','Y-Transect Proj.','Solution'})

%gof.adjrsquare
%pause

end