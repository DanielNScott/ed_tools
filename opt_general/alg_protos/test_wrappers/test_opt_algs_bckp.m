function [] = test_opt_algs()
%TEST_OPT_ALGS() Summary of this function goes here
%   Detailed explanation goes here
clc
close all

%--------------------------------------------------------------%
% Benchmark Problem Specifications
%--------------------------------------------------------------%
probs.names = {'Rosenbrock-2D'       ...
              ,'Styblinski-Tang'     ...
              ,'Eggholder'           ...
              ,'Sphere'              ...
              };

probs.fns   = {@(x) rosenbrock(x)       ...
              ,@(x) styblinski_tang(x)  ...
              ,@(x) eggholder(x)        ...
              ,@(x) sphere_fn(x)        ...
              };
           
probs.bnds  = {[-3,3;-3,3]           ...
              ,[-3.5,3.5; -3.5,3.5]  ...
              ,[-512,512; -512,512]  ...
              ,[-10,10;-10,10]       ...
              ,[-512,512; -512,512]  ...
              };
           
probs.mins  = {[1,1]                  ...
              ,[-2.903534, -2.903534] ...
              ,[]    ...
              ,[0,0] ...
              };

probs.dims  = {2, 2, 2, 2};
probs.incs  = {0.1, 0.1, 8, 0.5};
probs.edge  = {'k','none','none','k'};

probs.stop_crit = {-inf, -inf, -inf, -inf};
probs.iter_lim  = {200 ,  200,  200,  200};

%--------------------------------------------------------------%
% Optimization Algorithm Test Settings
%--------------------------------------------------------------%
% Test algorithms: NE-SIMPSA, PSO, SA, MH
tests.names     = {'NM', 'NMSA_T=5', 'NMSA_T=10', 'SA_T=5', 'SA_T=10', 'PSO_6', 'PSO_10'};
tests.temps     = {   0,         5 ,         10 ,       5 ,       10 ,      0 ,       0 };
tests.nps       = {   0,         0 ,          0 ,       0 ,        0 ,      6 ,      10 };
tests.use_smplx = {   1,         1 ,          1 ,       0 ,        0 ,      0 ,       0 };
tests.algorithm = {'NM',       'NM',        'NM',     'SA',      'SA',   'PSO',    'PSO'};
tests.iter_lim  = { 200,        200,         200,     1000,      1000,      20,      20 };

% Standard Settings
params = [1,2,-1/2,1/2];

% Temperature Function Stuff
mantissa   = 6;
exp_mult   = 2;
cool_sched = 'Geometric';

%--------------------------------------------------------------%
% A few misc. settings.
%--------------------------------------------------------------%
run_older = 0;                % Run old nm algs?

spacing = 0.015;
padding = 0.03;
margin  = 0.015;
%--------------------------------------------------------------%


for test_num = 4:5
   algorithm = tests.algorithm{test_num};   
   use_smplx = tests.use_smplx{test_num};
   iter_lim  = tests.iter_lim {test_num};
   
   gen_new_fig(['Surface and States: ' tests.names{test_num}])
   
   for prob_num = 1:4
      %--------------------------------------------------------------%
      % Initialize Test Problem Properties
      %--------------------------------------------------------------%
      inc    = probs.incs{prob_num};
      dims   = probs.dims{prob_num};
      edge   = probs.edge{prob_num};
      bounds = probs.bnds{prob_num};
      rng    = cell(dims);
      cent   = cell(dims);

      for idim = 1:dims;
         rng{idim}  = bounds(idim,2) - bounds(idim,1);   
         cent{idim} = mean(bounds(idim,:));
      end

      test_fn    = probs.fns      {prob_num};
      stop_crit  = probs.stop_crit{prob_num};
      %--------------------------------------------------------------%


      %--------------------------------------------------------------%
      % Initialize NM-SIMPSA Specific Stuff
      %--------------------------------------------------------------%
      if use_smplx
         smplx = NaN(idim+1,idim);
         for idim = 1:dims
            smplx(:,idim) = (rand(dims+1,1) - 0.5)*rng{idim} + cent{idim};  
         end

         ptrb_fn = @(x,temp,sgn) test_fn(x) + sgn*temp*lognrnd(0,1)/10;
      else
         smplx = NaN(idim+1,idim);
         for idim = 1:dims
            smplx(:,idim) = (rand(dims+1,1) - 0.5)*rng{idim} + cent{idim};  
         end
         state_init = smplx(1,:);
      end

      temp_start = tests.temps{test_num};
      temp_fn = @(iter) get_temp(cool_sched, temp_start, iter, iter_lim, mantissa, exp_mult);
      %--------------------------------------------------------------%



      %--------------------------------------------------------------%
      % Run the algorithms. Solution vectors are rows.
      %--------------------------------------------------------------%
      if run_older
         % Two older instantiations of the algorithms:
         sol_nmr = nelder_mead_rec([], params, smplx, bounds, test_fn, 0, 0);
         sol_nm  = nelder_mead(params, smplx, bounds, test_fn, iter_lim);

         % A newer version with per-iteration up-front function evaluation
         [sol_nm2,trace_nm2,iter_nm2] = nelder_mead_v2 ...
            (params, smplx, bounds, test_fn, stop_crit, iter_lim);
      end
      
      switch algorithm
         case('NM')
            [sol,trace,iter] = nelder_mead_sa ...
               (params, smplx, bounds, ptrb_fn, temp_fn, stop_crit, iter_lim);
            
         case('SA')
            feas_fn = @(state) all(and(state(:) >= bounds(:,1), state(:) <= bounds(:,2)));

            acc_fn   = @(temp,obj_cur,obj_prop) metropolis(temp, obj_cur, obj_prop);
            temp_fn  = @(iter) log_cool(temp_start,iter,iter_lim);

            sigma    = 1;
            nghbr_fn = @(pt_cur,pt_prev,temp) (rand(1,2)*6 - 3)*(temp/temp_start + 0.1);
            
            [sol,trace] = simulated_annealing ...
               (state_init, iter_lim, stop_crit, test_fn, acc_fn, temp_fn, nghbr_fn, feas_fn);
            
         case('PSO')
            [trace, objs] = particle_swarm(bnds,niter,nps,fn);

            % Trace has size [niter,nps,2]
            % Objs  has size [niter,nps] 

            best_obj = min(objs,[],2);
            min_msk = objs == repmat(best_obj,1,nps);
            x_coord = trace(:,:,1);
            y_coord = trace(:,:,2);

            best_x  = x_coord(min_msk);
            best_y  = y_coord(min_msk);
            best_xy = [best_x,best_y];

            global_best_obj = min(best_obj);
            best_ind        = best_obj == min(best_obj);
            global_best_xy  = best_xy(best_ind,:);
      end
      %--------------------------------------------------------------%



      %fmt = '%6.4f ';
      %disp('==========================================================')
      %disp([' Test Fn: ', probs.names{prob_num}])
      %disp('---------------- Solution Found --- Iters --- Stop Crit.--')
      %disp(['NE-SIMPSA     : [', num2str(sol,fmt), ']     ',num2str(iter_nmsa)])

      if use_smplx
         init_fvals  = test_fn(smplx);
         [~, order]  = sort(init_fvals);
         smplx       = smplx(order,:);
      end

      %--------------------------------------------------------------%
      % Plot the Surface & Trace
      %--------------------------------------------------------------%
      subaxis(2,2,prob_num,'S',spacing,'P',padding,'M',margin)
      hold on

      % ---- Plot the Surface: ------%
      gn = @(x) test_fn(x');
      plot_2D_fn( bounds(1,:), bounds(2,:), inc, inc, 'incs', gn, edge);

      % ---- Plot the Trace: ------%
      if use_smplx
         smplx_fig = [smplx     , test_fn(smplx     ); ...
                      smplx(1,:), test_fn(smplx(1,:))  ...
                      ];

         plot3( smplx_fig(:,1) ...
              , smplx_fig(:,2) ...
              , smplx_fig(:,3) ...
              ,'-or','markers',12)
      end

      plot3( trace.states(:,1) ...
           , trace.states(:,2) ...
           , trace.objectives  ...
           ,'--om','markers',12);

      if use_smplx
         legend({'Surface','Initial Simplex','Best States'})
      else
         legend({'Surface','Best States'})
      end
         
      %set(gca,'CameraPosition',[-18.5,-36.0,1025])
      %set(gca,'CameraViewAngle',11)
      hold off
      %--------------------------------------------------------------%

   end
end

end










% 
% fmt = '%6.4f ';
% disp('==========================================================')
% disp(' Starting higher NE-SIMPSA temperature tests ... ')
% disp('==========================================================')
% disp('Test Fn: Eggholder')
% 
% itest  = 5;
% dims   = probs.dims{itest};
% rng    = cell(dims);
% cent   = cell(dims);
% bounds = probs.bnds{itest};
% 
% for idim = 1:dims;
%    rng{idim}  = bounds(idim,2) - bounds(idim,1);
%    cent{idim} = mean(bounds(idim,:));
% end
% 
% sols = NaN(21,20,2);
% for itemp = 0:10:200
%    disp(['Temperature: ', num2str(itemp)])
%    disp('---- Solution Found --- Iters --- Stop Crit.--')
% 
%    for istart = 1:20
%       %--------------------------------------------------------------%
%       % Initialize NM Specific Stuff
%       %--------------------------------------------------------------%
%       smplx = NaN(idim+1,idim);
%       for idim = 1:dims
%          smplx(:,idim) = (rand(dims+1,1) - 0.5)*rng{idim} + cent{idim};  
%       end 
%       params = [1,2,-1/2,1/2];
%       %--------------------------------------------------------------%
% 
% 
% 
%       %--------------------------------------------------------------%
%       % Initialize iteration limits, stop points, some functions.
%       %--------------------------------------------------------------%
%       iter_lim  = 200;
%       stop_crit = -inf;
%       fn = probs.fns{itest};
%       %--------------------------------------------------------------%
% 
% 
% 
%       %--------------------------------------------------------------%
%       % Initialize NE-SIMPSA Stuff
%       %--------------------------------------------------------------%
%       cool_sched = 'Geometric';
%       mantissa   = 6;
%       exp_mult   = 2;
%       temp_start = itemp;
% 
%       gn      = @(x,temp,sgn) fn(x) + sgn*temp*lognrnd(0,1)/10; 
%       temp_fn = @(iter,niter) get_temp(cool_sched, temp_start, iter, niter, mantissa, exp_mult);
%       %--------------------------------------------------------------%
% 
%       [sol,~,iters] = nelder_mead_sa(params, smplx, bounds, gn, temp_fn, stop_crit, iter_lim);
% 
%       init_fvals  = fn(smplx);
%       [~, order]  = sort(init_fvals);
%       smplx = smplx(order,:);
% 
%       disp(['   [', num2str(sol,fmt), ']     ',num2str(iters),' ', itemp, ' ', num2str(istart)])
%       sols(1+itemp/10,istart,:) = sol;
%    end
% end
% 
