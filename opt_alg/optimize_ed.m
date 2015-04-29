function [hist, ui, ctrl, data, nfo] = optimize_ed(varargin)
% Please see the bottom of this file for general notes.

%----------------------------------------------------------------------------------------------%
%                                        Initialization                                        %
%                Load the settings file, then call a script to do initial book-keeping.        %
%----------------------------------------------------------------------------------------------%
if nargin == 1
   ui.settings_fname = varargin{1};
else
   ui.settings_fname = 'settings.m';
end

[ui, ctrl, data, nfo, hist] = init_optimizer(ui.settings_fname);
%----------------------------------------------------------------------------------------------%


%----------------------------------------------------------------------------------------------%
%                                         Main Loop                                            %
%----------------------------------------------------------------------------------------------%
while (ctrl.iter <= ui.niter && ctrl.energy > ctrl.energy_max)
   ctrl.acc_step = 0;


   %-------------------------------------------------------------------------------------------%
   %                                Adaptation and Temperature                                 %
   %-------------------------------------------------------------------------------------------%
   if strcmp(ui.opt_type,'DRAM')
      % Not yet functional, does nothing.
      %ctrl.covar = adapt_covar(ctrl,ui);
   elseif strcmp(ui.opt_type,'SA')
      ctrl.temp = get_temp(ui.cool_sched, ui.temp_start, ctrl.iter, ...
                           ui.niter, ui.mantissa, ui.exp_mult);
   end
   %-------------------------------------------------------------------------------------------%


   %-------------------------------------------------------------------------------------------%
   %                                    Delayed Rejection Loop                                 %
   %                       ndr = 1 => No 'actual' delayed rejection, as in SA                  %
   %-------------------------------------------------------------------------------------------%
   ctrl.idr = 1;
   while ctrl.idr <= ui.ndr && ctrl.acc_step == 0
      %----------------------------------------------------------------------------------------%
      %                                 Propose a State                                        %
      %----------------------------------------------------------------------------------------%
      if ctrl.iter ~= 1 && any(strcmp(ui.opt_type,{'SA','DRAM'}))
         data.state_prop = gen_proposal(data.state, ui.sdevs, ui.prior_pdf);
      end

      % Check state conforms to variable bounds.
      if ~strcmp(ui.opt_type,'PSO')
         ctrl.state_conforms = get_conformance(data.state_prop, ui.model);
      else
         ctrl.state_conforms = 1;
      end
      %----------------------------------------------------------------------------------------%


      %----------------------------------------------------------------------------------------%
      %                          Implement Algorithm if State Conforms                         %
      %----------------------------------------------------------------------------------------%
      if ctrl.state_conforms
         print_banner(ctrl,data,hist,ui,1);

         %-------------------------------------------------------------------------------------%
         %                           Main loop for DRAM and SA                                 %
         %-------------------------------------------------------------------------------------%
         if any(strcmp(ui.opt_type,{'DRAM','SA'}))
            
            %----------------------------------------------------------------------------------%
            %                                   Run Model                                      %
            %----------------------------------------------------------------------------------%
            if ui.verbose >= 0; disp('Running the model... '); end
            data.out = run_model(data.state_prop,ui,nfo);
            %----------------------------------------------------------------------------------%

            
            %----------------------------------------------------------------------------------%
            %                       Preprocess Observations (if necessary)                     %
            %----------------------------------------------------------------------------------%
            if ctrl.iter == 1 && (~ nfo.test || strcmp(ui.model,'read_dir'));
               if ui.verbose >= 0; disp('Preprocessing the observational data... '); end
               data.obs = preproc_obs(data.obs, data.out, ui.opt_metadata);
            end
            %----------------------------------------------------------------------------------%

            
            %----------------------------------------------------------------------------------%
            %                                   Rework Data                                    %
            % For some model output (things with prefix .Y. in their data structure paths)     %
            % we want to deal with partial sums of e.g. days/months, depending on what         %
            % observations are available. We process these here.                               %
            %----------------------------------------------------------------------------------%
            if ~ nfo.test || strcmp(ui.model,'read_dir')
               data.out = rework_data(data.obs, data.out, ui.opt_metadata);
            end
            %----------------------------------------------------------------------------------%

            

            %----------------------------------------------------------------------------------%
            %                             Calculate the Objective                              %
            % Evaluate the objective function. This is where the algorithm is mostly likely to %
            % fail due to source-code errors, so catch any faults and dump state to a .mat.    %
            %----------------------------------------------------------------------------------%
            if ui.verbose >= 0; disp('Calculating the objective function... '); end
            try
               data.stats = get_objective(data.out, data.obs, ui.opt_metadata, ui.model);
            catch ME
               ME.getReport()
               disp('Saving dump.mat')
               save('dump.mat')
               error('See Previous Messages.')
            end

            % For the ED model, we want to minimize the quantity (-1* log total likelihood)
            if ~ nfo.test || strcmp(ui.model,'read_dir');
               ctrl.obj_prop = data.stats.total_likely * (-1);
            else
               ctrl.obj_prop = data.out;
            end
            %----------------------------------------------------------------------------------%



            %----------------------------------------------------------------------------------%
            %                                Book Keeping                                      %
            %----------------------------------------------------------------------------------%
            if ctrl.iter == 1
               hist.out_first  = data.out;
               hist.out_best   = data.out;
               hist.iter_best  = 1;
            end
            
            if ctrl.obj_prop <= min(hist.obj)
               print_banner(ctrl,data,hist,ui,2);
               hist.out_best  = data.out;
               hist.iter_best = ctrl.iter;
            end
            %----------------------------------------------------------------------------------%


            
            %----------------------------------------------------------------------------------%
            %                          Calculate Weights of Priors                             %
            %----------------------------------------------------------------------------------%
            if strcmp(ui.opt_type,'DRAM')
               if ui.verbose >= 0; disp('Calculating the weights of the priors... '); end
               ctrl.prop_prior_wgt = get_prior_wgt(data.state_prop  , ...
                                                   ui.means         , ...
                                                   ui.sdevs         , ...
                                                   ctrl.theta       , ...
                                                   ctrl.ga_k        , ...
                                                   ui.prior_pdf_type, ...
                                                   ui.prior_pdf);
            end
            %----------------------------------------------------------------------------------%


            
            %----------------------------------------------------------------------------------%
            %                                Calculate Alpha                                   %
            %----------------------------------------------------------------------------------%
            if ui.verbose >= 0; disp('Calculating the rejection factor... '); end
            ctrl.alpha = get_alpha(ctrl,ui);
            print_banner(ctrl,data,hist,ui,ctrl.idr + 2);
            %----------------------------------------------------------------------------------%


            
            %----------------------------------------------------------------------------------%
            %                             Determine Acceptance                                 %
            % If we accept step, exit the delayed_reject loop and move on to the next iter.    %
            %----------------------------------------------------------------------------------%
            ctrl.accept_test_rand = rand();

            if ctrl.accept_test_rand < ctrl.alpha(ctrl.idr)
               % Accept this step and record acceptance in the history
               ctrl.acc_step       = 1;

               % Mark proposed state and objective as 'current'
               ctrl.obj   = ctrl.obj_prop;
               data.state = data.state_prop;

               % Update current prior weight if we're doing DRAM
               if strcmp(ui.opt_type,'DRAM')
                  curr_prior_wgt    = ctrl.prop_prior_wgt(ctrl.idr);
               end
            end
            print_banner(ctrl,data,hist,ui,5);
            %----------------------------------------------------------------------------------%
         %-------------------------------------------------------------------------------------%
            
            
         elseif strcmp(ui.opt_type,'PSO')
         %-------------------------------------------------------------------------------------%
         %                             Main loop for PSO                                       %
         %-------------------------------------------------------------------------------------%
            save('pso.mat')
            disp('Assigning PSO Tasks...')
            assign_pso_tasks(ui.nps,ui.verbose);
            
            %----------------------------------------------------------------------------------%
            %                       Update States and Velocities                               %
            %----------------------------------------------------------------------------------%
            [ ctrl, data, hist ]    = get_particle_data( ctrl, data, hist, ui.nps, ui.verbose);
            
            [data.state, data.vels] = update_pso_state(data.state   , data.vels, ...
                                                       ctrl.vel_max , ctrl.chi , ...
                                                       ui.phi_1     , ui.phi_2 , ...
                                                       ctrl.pbs     , ctrl.pbo , ...
                                                       ctrl.nbrhd   , nfo.nvar ); %, ...
                                                       %ui.verbose);
            %----------------------------------------------------------------------------------%
         %-------------------------------------------------------------------------------------%
         end

         
         
         %-------------------------------------------------------------------------------------%
         %                             Update Program History                                  %
         %-------------------------------------------------------------------------------------%
         try
            hist = update_hist(ui,ctrl,data,hist);
         catch ME
            ME.getReport()
         end
         %-------------------------------------------------------------------------------------%

         
         
         %-------------------------------------------------------------------------------------%
         %                             Indicate Progress                                       %
         %-------------------------------------------------------------------------------------%
         if ui.verbose >= 0
            print_progress(ctrl.iter, ui.niter, hist.acc_rate, hist.acc)
         end
         %-------------------------------------------------------------------------------------%

         
         
         %-------------------------------------------------------------------------------------%
         %                         Update Counters & Save State                                %
         %-------------------------------------------------------------------------------------%
         ctrl.idr  = ctrl.idr  + 1;
         ctrl.iter = ctrl.iter + 1;
         
         if sum(strcmp(ui.model,{'ED2.1','out.mat','read_dir'}))
            disp('Saving current program state to opt.mat...');
            save('opt.mat')
         end
         %-------------------------------------------------------------------------------------%
      
      else
         if ui.verbose >= 0; disp('Proposal does not conform to prior... '); end
      end % Conformity Check
   end    % Delayed Rejection Loop
end       % Primary While Loop

% Return to whatever directory we started in.
% This is useful if we're not exiting matlab after running the alg.
cd(nfo.init_dir)

end
%==========================================================================================%
%==========================================================================================%








%=============================================================================================%
% DRAM, Simulated Annealing, and PSO                                                          %
%=============================================================================================%
% Here you will find some notes on the structures, implementations, and shared code between 
% the Delayed Rejection Adaptive Metropolis Hastings algorithm, the Simulated Annealing 
% algorithm, and the Particle Swarm Optimization algorithm.
%
%--------------------------------------------------------------------------------------------%
% The basic SA Algorithm in pseudocode                                                       %
%--------------------------------------------------------------------------------------------%
% iteration = 1;
% while iter < max_iters and (energy > max_acceptable_energy)
%     set Temperature  = Temperature_Function(iter,max_iters)
%     set new_State    = neighbor_generating_function(state)
%     set new_Energy   = Energy_Function(new_state)
%
%     if Acceptance_Probability_Function(Energy,new_Energy,Temperature) > Uniform_Rand
%        set state  = new_State
%        set energy = new_Energy
%     end
%
%     if new_Energy < best_Energy
%        set best_Energy = new_Energy
%        set best_State  = new_State
%     end
%
%     add state to list of visited states
%     add energy to list of visited energies
%
%     set iteration = iteration + 1
% end while
%
%
%--------------------------------------------------------------------------------------------%
% The DRAM (Delayed Rejection Adaptive Metropolis Hastings) Algorithm in pseudocode          %                                                       %
%--------------------------------------------------------------------------------------------%
%
%
%
%----------------------------------------------------------------------------------------------%
% Canonical PSO in pseudocode                                                                  %
%----------------------------------------------------------------------------------------------%
%
%
%
%==============================================================================================%



%=============================================================================================%
% Some notes on the structure of this program.                                                %
%=============================================================================================%
% The program 'optimize_ed' implements both SA and DRAM. Right now, the delayed rejection and
% adaptive components of DRAM are still under development, but the basic Metropolis-Hastings
% algorithm is functional.
%
% (More to be added)
%=============================================================================================%
