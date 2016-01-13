function [] = test_nm()
%TEST_NM Summary of this function goes here
%   Detailed explanation goes here
clc
close all
   
test_selector = 1:4;
test_names = {'Rosenbrock-2D', 'Styblinski-Tang', 'Eggholder', 'Sphere', 'Eggholder Temp Test'};
test_fns   = {@(x) rosenbrock(x), @(x) styblinski_tang(x), ...
              @(x) eggholder(x) , @(x) sphere_fn(x), @(x) eggholder(x)};
test_bnds  = {[-3,3;-3,3], [-3.5,3.5; -3.5,3.5], [-512,512; -512,512], [-10,10;-10,10], ...
              [-512,512; -512,512]};
test_dims  = {2,2,2,2,2};
test_incs  = {0.1,0.1,8,0.5,8};
test_temps = {0,0,0,0,[0,200]};

figure()
for itest = test_selector;
   
   dims   = test_dims{itest};
   rng    = cell(dims);
   cent   = cell(dims);
   bounds = test_bnds{itest};
   
   for idim = 1:dims;
      rng{idim}  = bounds(idim,2) - bounds(idim,1);   
      cent{idim} = mean(bounds(idim,:));
   end
   
   %--------------------------------------------------------------%
   % Initialize NM Specific Stuff
   %--------------------------------------------------------------%
   smplx = NaN(idim+1,idim);
   for idim = 1:dims
      smplx(:,idim) = (rand(dims+1,1) - 0.5)*rng{idim} + cent{idim};  
   end 
   params = [1,2,-1/2,1/2];
   %--------------------------------------------------------------%



   %--------------------------------------------------------------%
   % Initialize iteration limits, stop points, some functions.
   %--------------------------------------------------------------%
   iter_lim  = 200;
   stop_crit = -inf;
   fn = test_fns{itest};
   %--------------------------------------------------------------%



   %--------------------------------------------------------------%
   % Initialize NE-SIMPSA Stuff
   %--------------------------------------------------------------%
   cool_sched = 'Geometric';
   mantissa   = 6;
   exp_mult   = 2;
   temp_start = test_temps{itest};

   gn      = @(x,temp,sgn) fn(x) + sgn*temp*lognrnd(0,1)/10; 
   temp_fn = @(iter,niter) get_temp(cool_sched, temp_start, iter, niter, mantissa, exp_mult);
   %--------------------------------------------------------------%




   %--------------------------------------------------------------%
   % Run the algorithms. Solution vectors are rows.
   %--------------------------------------------------------------%
   % Two older instantiations of the algorithms:
   sol_1 = nelder_mead_rec([], params, smplx, bounds, fn, 0, 0);
   sol_2 = nelder_mead(params, smplx, bounds, fn, iter_lim);

   % A newer version with per-iteration up-front function evaluation
   [sol_3,trace3,iter3] = nelder_mead_v2(params, smplx, bounds, fn, stop_crit, iter_lim);
   %--------------------------------------------------------------%

   [sol_4,trace4,iter4] = nelder_mead_sa(params, smplx, bounds, gn, temp_fn, stop_crit, iter_lim);

   fmt = '%6.4f ';
   disp('==========================================================')
   disp([' Test Fn: ', test_names{itest}])
   disp('---------------- Solution Found --- Iters --- Stop Crit.--')
   %disp(['Recursive NM  : [', num2str(sol_1,fmt), ']'])
   %disp(['Non-Recursive : [', num2str(sol_2,fmt), ']'])
   %disp(['Upfront F-Eval: [', num2str(sol_3,fmt), ']     ',num2str(iter3)])
   disp(['NE-SIMPSA     : [', num2str(sol_4,fmt), ']     ',num2str(iter4)])

   init_fvals  = fn(smplx);
   [~, order]  = sort(init_fvals);
   smplx = smplx(order,:);

   subaxis(2,2,itest)
   hold on
   gn = @(x) fn(x');
   inc = test_incs{itest};
   plot_2D_fn(bounds(1,:),bounds(2,:),inc,inc,'incs',gn);

   % state trajectory:
   smplx_fig = [smplx, fn(smplx) ; smplx(1,:), fn(smplx(1,:))];

   plot3(smplx_fig(:,1),smplx_fig(:,2),smplx_fig(:,3),'--or','markers',12)
   plot3(trace3(:,1), trace3(:,2) ,fn(trace3),'--og','markers',12);
   plot3(trace4(:,1), trace4(:,2) ,fn(trace4),'--om','markers',12);

   set(gcf,'Name','Test Surface and States')
   legend({'Surface','Initial Simplex','NM','NE-SIMPSA'})
   hold off
end

fmt = '%6.4f ';
disp('==========================================================')
disp(' Starting higher NE-SIMPSA temperature tests ... ')
disp('==========================================================')
disp('Test Fn: Eggholder')

itest  = 5;
dims   = test_dims{itest};
rng    = cell(dims);
cent   = cell(dims);
bounds = test_bnds{itest};

for idim = 1:dims;
   rng{idim}  = bounds(idim,2) - bounds(idim,1);
   cent{idim} = mean(bounds(idim,:));
end

sols = NaN(21,20,2);
for itemp = 0:10:200
   disp(['Temperature: ', num2str(itemp)])
   disp('---- Solution Found --- Iters --- Stop Crit.--')

   for istart = 1:20
      %--------------------------------------------------------------%
      % Initialize NM Specific Stuff
      %--------------------------------------------------------------%
      smplx = NaN(idim+1,idim);
      for idim = 1:dims
         smplx(:,idim) = (rand(dims+1,1) - 0.5)*rng{idim} + cent{idim};  
      end 
      params = [1,2,-1/2,1/2];
      %--------------------------------------------------------------%



      %--------------------------------------------------------------%
      % Initialize iteration limits, stop points, some functions.
      %--------------------------------------------------------------%
      iter_lim  = 200;
      stop_crit = -inf;
      fn = test_fns{itest};
      %--------------------------------------------------------------%



      %--------------------------------------------------------------%
      % Initialize NE-SIMPSA Stuff
      %--------------------------------------------------------------%
      cool_sched = 'Geometric';
      mantissa   = 6;
      exp_mult   = 2;
      temp_start = itemp;

      gn      = @(x,temp,sgn) fn(x) + sgn*temp*lognrnd(0,1)/10; 
      temp_fn = @(iter,niter) get_temp(cool_sched, temp_start, iter, niter, mantissa, exp_mult);
      %--------------------------------------------------------------%

      [sol,~,iters] = nelder_mead_sa(params, smplx, bounds, gn, temp_fn, stop_crit, iter_lim);

      init_fvals  = fn(smplx);
      [~, order]  = sort(init_fvals);
      smplx = smplx(order,:);

      disp(['   [', num2str(sol,fmt), ']     ',num2str(iters),' ', itemp, ' ', num2str(istart)])
      sols(1+itemp/10,istart,:) = sol;
   end
end



end

