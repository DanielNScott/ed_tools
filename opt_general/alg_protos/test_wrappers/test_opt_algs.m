function [] = test_opt_algs()
%TEST_OPT_ALGS() Summary of this function goes here
%   Detailed explanation goes here
clc
close all

%--------------------------------------------------------------%
% Benchmark Problem Specifications
%--------------------------------------------------------------%
probs.names = {'Sphere'              ...
              ,'Rosenbrock-2D'       ...
              ,'Styblinski-Tang-2D'  ...
              ,'Eggholder'           ...
              ...
              ,'Rosenbrock-4D'       ...
              ,'Styblinski-Tang-4D'  ...
              ...
              ,'Rosenbrock-8D'       ...
              ,'Styblinski-Tang-8D'  ...
              };

probs.fns   = {@(x) sphere_fn(x)        ...
              ,@(x) rosenbrock(x)       ...
              ,@(x) styblinski_tang(x)  ...
              ,@(x) eggholder(x)        ...
              ...
              ,@(x) rosenbrock(x)       ...
              ,@(x) styblinski_tang(x)  ...
              ...
              ,@(x) rosenbrock(x)       ...
              ,@(x) styblinski_tang(x)  ...
              };
           
probs.bnds  = {[-10,10;-10,10]       ...
              ,[-3,3;-3,3]           ...
              ,[-3.5,3.5; -3.5,3.5]  ...
              ,[-512,512; -512,512]  ...
              ...
              ,[-3,3; -3,3; -3,3; -3,3] ...
              ,[-3.5,3.5; -3.5,3.5; -3.5,3.5;  -3.5,3.5;]  ...
              ...
              ,[-3,3; -3,3; -3,3; -3,3; -3,3; -3,3; -3,3; -3,3] ...
              ,[-3.5,3.5; -3.5,3.5; -3.5,3.5;  -3.5,3.5; ...
                -3.5,3.5; -3.5,3.5; -3.5,3.5;  -3.5,3.5;]  ...
              };
           
probs.sols  = {[        0,         0] ...
              ,[        1,         1] ...
              ,[-2.903534, -2.903534] ...
              ,[      512,  404.2319] ...
              ...
              ,[        1,         1,        1,         1] ...
              ,[-2.903534, -2.903534,-2.903534, -2.903534] ...
              ...
              ,[        1,         1,        1,         1,        1,         1,        1,         1] ...
              ,[-2.903534, -2.903534,-2.903534, -2.903534,-2.903534, -2.903534,-2.903534, -2.903534] ...
              };
           
probs.worst = {[  10,   10] ...
              ,[  -3,   -3] ...
              ,[0.1568, 0.1560] ...
              ,[-512, -512] ...
              ...
              ,[  -3,   -3,  -3,   -3] ...
              ,[0.1568, 0.1560,0.1568, 0.1560,] ...
              ...
              ,[  -3,   -3,  -3,   -3,  -3,   -3,  -3,   -3] ...
              ,[0.1568, 0.1560,0.1568, 0.1560,0.1568, 0.1560,0.1568, 0.1560] ...
              };
           
probs.mins  = {   0.0       ...
              ,   0.0       ...
              , -39.16599*2 ...
              ,-959.6407    ...
              ...
              ,   0.0       ...
              , -39.16599*4 ...
              ...
              ,   0.0       ...
              , -39.16599*8 ...
              };
           
probs.max   = {  100       ...
              ,14416       ...
              ,    0.3616  ...
              ,1010.1      ...
              ...
              ,43248       ...
              ,0.7824      ...
              ...
              ,100912      ...
              ,1.5649      ...
              };
           
probs.ave   = {   66.75    ...
              , 1897.1     ...
              ,  -35.0567  ...
              ,   -4.4991  ...
              ...
              , 5760       ...
              ,  -63.5999  ...
              ...
              ,13476       ...
              , -127.13    ...
              };
           
probs.oq2bnds   = { [0.5,1], [0,1], [-1,1], [-1,1], [0,1], [-1,1], [0,1], [-1,1]};
probs.dims      = {2, 2, 2, 2, 4, 4, 8, 8};
probs.incs      = { 0.5, 0.1, 0.1, 8, NaN, NaN, NaN, NaN};
probs.edge      = {'k','k','none','none', '', '', '', ''};
probs.stop_crit = {-inf, -inf, -inf, -inf, -inf, -inf, -inf, -inf};

%--------------------------------------------------------------%
% Optimization Algorithm Test Settings
%--------------------------------------------------------------%
tests.algs      = {     'NM',   'SA',     'PSO'};  % Alg name.
tests.ctrl      = {   0:1:20, 2:2:60,    8:4:88};  % Temp. or nps.
tests.iter_lim  = { 20:5:100,   1000,  20:5:100};  % Max interations
tests.nsample   = {       50,     50,        50};  % Repeat tests

% Standard Settings
params = [1,2,-1/2,1/2];

% Temperature Function Stuff
mantissa   = 6;
exp_mult   = 2;
cool_sched = 'Geometric';
plot_flag  = 0;

%--------------------------------------------------------------%
% A few misc. settings.
%--------------------------------------------------------------%
run_older = 0;                % Run old nm algs?
plot_flg  = 0;
nprobs    = numel(probs.names);

spacing = 0.015;
padding = 0.03;
margin  = 0.015;

%--------------------------------------------------------------%


for alg_num = [1,3]
   alg = tests.algs{alg_num};
   use_smplx = strcmp(alg,'NM');
   nsamples  = tests.nsample{alg_num};
   
   ctrl  = tests.ctrl{alg_num};
   nctrl = numel(ctrl);

   ilim  = tests.iter_lim{alg_num};
   nilim = numel(ilim);
   
   sq.(alg) = NaN(nprobs,nctrl,nilim,nsamples);
   oq.(alg) = NaN(nprobs,nctrl,nilim,nsamples);
   
   for prob_num = 1:nprobs
      %--------------------------------------------------------------%
      % Initialize Test Problem Properties
      %--------------------------------------------------------------%
      name   = probs.names{prob_num};
      inc    = probs.incs{prob_num};
      dims   = probs.dims{prob_num};
      edge   = probs.edge{prob_num};
      bounds = probs.bnds{prob_num};
      rng    = cell(dims);
      cent   = cell(dims);
      hist   = struct();

      for idim = 1:dims;
         rng{idim}  = bounds(idim,2) - bounds(idim,1);   
         cent{idim} = mean(bounds(idim,:));
      end

      test_fn    = probs.fns      {prob_num};
      stop_crit  = probs.stop_crit{prob_num};
            
      prob_sol   = probs.sols{prob_num};
      prob_min   = probs.mins{prob_num};
      worst_sol  = probs.worst{prob_num};
      
      loc_wght = sqrt(sum((prob_sol - worst_sol).^2)); % Euclidean Distance
      obj_wght = abs(prob_min - probs.ave{prob_num});
      %obj_wght_1 = abs(prob_min - probs.max{prob_num});
      %--------------------------------------------------------------%
   
      for sample_num = 1:nsamples
         for ctrl_num = 1:nctrl
            for ilim_num = 1:nilim
               %--------------------------------------------------------------%
               % Initialize Test Condition
               %--------------------------------------------------------------%
               iter_lim  = ilim(ilim_num);
               
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

               temp_start = ctrl(ctrl_num);
               nps        = ctrl(ctrl_num);
               temp_fn = @(iter) get_temp(cool_sched, temp_start, iter, iter_lim, mantissa, exp_mult);
               %--------------------------------------------------------------%


               %--------------------------------------------------------------%
               % Run the algorithms. Solution vectors are rows.
               %--------------------------------------------------------------%
               switch alg
                  case('NM')
                     [sol,trace] = nelder_mead_sa ...
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
                     [sol,trace] = particle_swarm(bounds,iter_lim,nps,test_fn);
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

               obj = test_fn(sol);

               sq.(alg)(prob_num,ctrl_num,ilim_num,sample_num) = 1 - sqrt(sum((sol - prob_sol).^2))/loc_wght;
               oq.(alg)(prob_num,ctrl_num,ilim_num,sample_num) = 1 - abs(obj - prob_min)    /obj_wght;
               %oq.(alg)(prob_num,ctrl_num,sample_num) = 1 - abs(obj - prob_min)    /obj_wght_1;

               hist = update_hist(hist,sol,obj,trace,smplx,use_smplx,ctrl_num,ilim_num,sample_num);
            end
         end
      end

      if 0 %dims <= 2
         %--------------------------------------------------------------%
         % Plot the Surface & Trace
         %--------------------------------------------------------------%
         subaxis(4,2,prob_num*2 - 1,'S',spacing,'P',padding,'M',margin)
         hold on

         % ---- Plot the Surface: ------%
         gn = @(x) test_fn(x');
         plot_2D_fn( bounds(1,:), bounds(2,:), inc, inc, 'incs', gn, edge);

         % ---- Plot the Trace: ------%
         %if use_smplx
         %   smplx_fig = [hist.best_smplx_found     , test_fn(hist.best_smplx_found     ); ...
         %                hist.best_smplx_found(1,:), test_fn(hist.best_smplx_found(1,:))  ...
         %                ];

         %   plot3( smplx_fig(:,1) ...
         %        , smplx_fig(:,2) ...
         %        , smplx_fig(:,3) ...
         %        ,'-or','markers',12)
         %end

         %plot3( hist.best_trc_found{1}.states(:,1) ...
         %     , hist.best_trc_found{1}.states(:,2) ...
         %     , hist.best_trc_found{1}.objectives  ...
         %     ,'--om','markers',12);

         %plot3( hist.worst_trc_found{1}.states(:,1) ...
         %     , hist.worst_trc_found{1}.states(:,2) ...
         %     , hist.worst_trc_found{1}.objectives  ...
         %     ,'--og','markers',12)


         %if use_smplx
         %   legend({'Fn','Init Smplx','Trace_B','Trace_W'})
         %else
            legend({'Fn','Tr_B','Tr_W'})
         %end

         %set(gca,'CameraPosition',[-18.5,-36.0,1025])
         %set(gca,'CameraViewAngle',11)
         hold off
         %--------------------------------------------------------------%
      end
   end
   
   if plot_flag
      for fig_num = 1:2
         gen_new_fig([alg, '-Fig-', num2str(fig_num)])
         for plt_num = 1:4
            prob_num = plt_num + (fig_num-1)*4;

            mean_sq = squeeze(mean(sq.(alg)(prob_num,:,:,:),4));
            mean_oq = squeeze(mean(oq.(alg)(prob_num,:,:,:),4));
            %sdev_sq = squeeze( std(sq.(alg)(prob_num,:,:,:),0,4));
            %sdev_oq = squeeze( std(oq.(alg)(prob_num,:,:,:),0,4));

            % Left Panels
            subaxis(4,2,plt_num*2-1) %,'S',spacing,'P',padding,'M',margin)
               surf(ilim,ctrl,mean_oq)

               xlabel('Iteration Limit')
               ylabel('Control Parameter')
               zlabel('Obj. Quality Index')
               title(['\bf{' probs.names{prob_num} '}'])

            % Right Panels
            subaxis(4,2,plt_num*2) %,'S',spacing,'P',padding,'M',margin)
               surf(ilim,ctrl,mean_sq)

               xlabel('Iteration Limit')
               ylabel('Control Parameter')
               zlabel('Sol. Quality Index')
               title(['\bf{' probs.names{prob_num} '}'])
              %plot(1:nctrl,obj_quality.(algorithm)(prob_num,:),'-o')
         end
      end
   end
end

save test_opt_algs.mat


end

   %         hold on
   %         errorbar(tests.ctrl{alg_num}, mean_sq, sdev_sq, '-ob')
   %         errorbar(tests.ctrl{alg_num}, mean_oq, sdev_oq, '-or')
   %         hold off

         %plot(tests.ctrl{alg_num}, ...
         %    [ mean(sq.(alg)(prob_num,:,:),3) ...
         %    ; mean(oq.(alg)(prob_num,:,:),3)], '-o')

   %         set(gca,'XLim',[tests.ctrl{alg_num}(1), tests.ctrl{alg_num}(end)])
   %         set(gca,'YLim',probs.oq2bnds{prob_num})
   %         legend('SQI','OQI','Location','SouthEast') %_1','OQI_2')
   %         legend('OQI','Location','SouthEast') %_1','OQI_2')




function [hist] = update_hist(hist,sol,obj,trace,smplx,use_smplx,ctrl_num,ilim_num,sample_num)

   if ctrl_num == 1
      hist.best_sol_found(sample_num,:  ) = sol;
      hist.best_obj_found(sample_num    ) = obj;
      %hist.best_trc_found{sample_num    } = trace;

      %hist.worst_sol_found(sample_num,:  ) = sol;
      %hist.worst_obj_found(sample_num    ) = obj;
      %hist.worst_trc_found{sample_num    } = trace;

      %if use_smplx
      %   hist.best_smplx_found = smplx;
      %   hist.worst_smplx_found = smplx;
      %end
   else
      if obj < hist.best_obj_found(sample_num    )
         hist.best_sol_found(sample_num,:  ) = sol;
         hist.best_obj_found(sample_num    ) = obj;
       %  hist.best_trc_found{sample_num    } = trace;

         %if use_smplx
         %   hist.best_smplx_found = smplx;
         %end
      %elseif obj > hist.worst_obj_found(sample_num    )
         %hist.worst_sol_found(sample_num,:  ) = sol;
         %hist.worst_obj_found(sample_num    ) = obj;
         %hist.worst_trc_found{sample_num    } = trace;

         %if use_smplx
         %   hist.worst_smplx_found(sample_num,:,:) = smplx;
         %end
      end
   end
end

function [hist] = init_hist(nsamples)

hist.best_sol_found = nan(nsamples,2  );
hist.best_obj_found = nan(nsamples    );
%hist.best_trc_found{sample_num    } = trace;

%hist.worst_sol_found(sample_num,:  ) = sol;
%hist.worst_obj_found(sample_num    ) = obj;
%hist.worst_trc_found{sample_num    } = trace;

end


