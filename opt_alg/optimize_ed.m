function [hist_state, hist_obj, iter_best] = optimize_ed(varargin)
% Please see the bottom of this file for a description of the two optimization algorithms and
% other general notes.

%----------------------------------------------------------------------------------------------%
% Load the settings file for the DRAM/SA, then call a script to do initial book-keeping.
%----------------------------------------------------------------------------------------------%   
disp('Loading settings...')
% Either the user provided a specific name of a settings file, or default to 'settings'.
if nargin == 1; run(varargin{1}); else settings(); end

% Run the initialization script
initialize_optimizer()

%----------------------------------------------------------------------------------------------%
% Start iterating. Below are the actual optimization algorithms.
%----------------------------------------------------------------------------------------------%
while (iter <= niter && energy > energy_max)
   accept_mcmc_step = 0;

   %--------------------------------------------------------------------------------------%
   % Adapt proposal covariance matrix: Here we accommodate burn in by only adapting after %
   % 30% of iterations are complete, we only adapt with adapt_freq, and we only adapt if  %
   % we have less than 10% acceptance. This is a part of DRAM, not SA.                    %
   %--------------------------------------------------------------------------------------%
   if strcmp(opt_type,'DRAM')
      % Not yet complete.
      if(iter > floor(0.3*niter) && mod(iter,adapt_freq) == 0 && sum(hist_accept) < 10)
         %call adapt_prop_covar(niter, nvar, iter-1, param_chain)
         %call eigen_prop_cov_mat(nvar)
         %covar     = adapt_prop_covar()
         %eigenvals = eigen_prop_cov_mat()
      end
   elseif strcmp(opt_type,'SA')
      temp = get_temp(iter, niter, temp_start, cooling_sched, mantissa, exp_mult);
   end
   %--------------------------------------------------------------------------------------%



   %--------------------------------------------------------------------------------------%
   % Delayed Rejection Loop: ndr = 1 => No 'Actual' Delayed Rejection.                    %
   % If we're running the SA alg, we do still want to be in this loop, with ndr = 1.      %
   %--------------------------------------------------------------------------------------%
   idr = 1;
   while idr <= ndr && accept_mcmc_step == 0
      %-----------------------------------------------------------------------------------%
      %   Generate proposal for the params to be optimized and make sure they satisfy     %
      % the priors. If this is the first iteration, use initial state.                    %
      %-----------------------------------------------------------------------------------%
      if iter ~= 1
         state_prop = gen_proposal(state_curr, dr_factor, p_sdevs, opt_type, prior_pdf);
      end

      % Check state conforms to variable bounds.
      state_conforms = get_conformance(state_prop,model);
      %-----------------------------------------------------------------------------------%


      %-----------------------------------------------------------------------------------%
      % Only bother running the model + calculating weights if variables are acceptable.  %
      %-----------------------------------------------------------------------------------%
      if state_conforms
         if (dbug) 
            disp('%--------------------------------------------------------------------%')
            disp([' Iteration             : ', num2str(iter)])
            disp('%--------------------------------------------------------------------%')
            disp(['Delayed Rejection Step : ', num2str(idr)])
            disp(['Delayed Rejection Fact.: ', num2str(dr_factor(idr))])
            disp(' ')
         end
         %--------------------------------------------------------------------------------%
         % Run model and evaluate the objective function.                                 %
         %--------------------------------------------------------------------------------%
         if dbug; disp('Running the model... '); end
         output = run_model(state_prop, labels, pfts, rundir, model, simres, dbug);
            
         if iter == 1 && (~testing || strcmp(model,'read_dir'));
            if dbug; disp(' '); disp('Preprocessing the observational data... '); end
            obs = preproc_obs(obs,output,opt_metadata);
         end
         if dbug; disp(' '); disp('Calculating the objective function... '); end
         try
            stats = get_objective(output, obs, opt_metadata, model);
         catch ME
            ME.getReport()
            disp('Saving dump.mat')
            save('dump.mat')
            error('See Previous Messages.')
         end
            
         % For the ED model, we want to minimize the quant. (-1* log total likelihood)
         if ~testing || strcmp(model,'read_dir');
            obj_prop = stats.total_likely * (-1);
         else
            obj_prop = output;
         end
         
         %--------------------------------------------------------------------------------%
         % If this is the first run, save it's output.
         %--------------------------------------------------------------------------------%
         if iter == 1
            out_first  = output;
            out_best   = output;
            iter_best  = 1;
         end
         %--------------------------------------------------------------------------------%
         % If this is the best value of the objective function we've yet seen, save the
         % iteration number and the output. We can do this here because we automatically 
         % move there under both algorithms
         %--------------------------------------------------------------------------------%
         if obj_prop <= min(hist_obj)
            if dbug
               disp('New best state found!');
               disp(['Proposed objective: ' num2str(obj_prop)]);
               disp(['Previous best     : ' num2str(min(hist_obj))]);
            end
            out_best  = output;
            iter_best = iter;
         end
         %--------------------------------------------------------------------------------%
         %  Calculate weights of priors.                                                  %
         %--------------------------------------------------------------------------------%
         if strcmp(opt_type,'DRAM')
            if dbug; disp('Calculating the weights of the priors... '); end
            prop_prior_wgt = get_prior_wgt(state_prop, p_means, p_sdevs, theta, ga_k, ...
                                              prior_pdf_type, prior_pdf);
         end
         
         %--------------------------------------------------------------------------------%
         % Calculate the first delayed rejection factor, and always accept first iter.    %
         %--------------------------------------------------------------------------------%
         if dbug; disp('Calculating the rejection factor... '); end
         if(idr == 1)
            if iter == 1
               alpha = 1;
            else
               if strcmp(opt_type,'DRAM')
                  alpha(1) = get_DRAM_AR(obj_prop(1), prop_prior_wgt(1), obj_curr, curr_prior_wgt);
                  
               elseif strcmp(opt_type,'SA')
                  alpha = get_SA_alpha(obj_curr, obj_prop, temp, temp_max, accept_criteria);
                  
               end
            end

            if (dbug) 
               disp('%---------------------------------------------%')
               disp(' Displaying acceptance/rejection criteria:')
               disp('%---------------------------------------------%')
               disp(['alpha             : ', num2str(alpha(1))])
               if strcmp(opt_type,'SA')
                  disp(['temp              : ', num2str(temp)])
                  disp(['temp_start        : ', num2str(temp_start)])
                  disp(['temp_max          : ', num2str(temp_max)])                  
               end
               disp(['obj_prop          : ', num2str(obj_prop)])
               disp(['obj_curr          : ', num2str(obj_curr)])
               if strcmp(opt_type,'DRAM')
                  disp(['prop_prior_wgt    : ', num2str(prop_prior_wgt(1))])
                  disp(['curr_prior_wgt    : ', num2str(curr_prior_wgt)])
               end
               disp(' ')
            end

         %--------------------------------------------------------------------------------%
         % Calculate the second delayed rejection factor if we rejected the proposed step %
         % under the first alpha.                                                         %
         %--------------------------------------------------------------------------------%
         elseif(idr == 2) 
            %call dr_prop_rat(nvar, state_curr, rejected_var(1,1:nvar), state_prop, prop_ratio)
            
            alpha_inter = get_alpha(obj_prop(idr-1), prop_prior_wgt(idr-1), obj_prop(idr), prop_prior_wgt(idr));
            alpha(idr)  = min(1., exp(obj_prop(idr) + prop_prior_wgt(idr) - obj_curr - curr_prior_wgt) ...
                                     * prop_ratio * (1.0 - alpha_inter) / (1.0 - alpha(idr-1)));

            if (dbug) 
               disp(['alpha_inter       : ', num2str(alpha_inter)])
               disp(['alpha             : ', num2str(alpha(idr))])
               disp(['obj_prop(1)       : ', num2str(obj_prop(1))])
               disp(['obj_prop(2)       : ', num2str(obj_prop(idr-1))])
               disp(['prop_prior_wgt(1) : ', num2str(prop_prior_wgt(1))])
               disp(['prop_prior_wgt(2) : ', num2str(prop_prior_wgt(2))])
               disp(['obj_curr          : ', num2str(obj_curr)])
               disp(['curr_prior_wgt    : ', num2str(curr_prior_wgt)])
               disp(' ')
            end
         end
         %--------------------------------------------------------------------------------%

         
         
         
         %--------------------------------------------------------------------------------%
         % Determine acceptance...                                                        %
         % If we accept step, exit the delayed_reject loop and move on to the next iter.  %
         %--------------------------------------------------------------------------------%
         accept_test_rand = rand();
         
         if ( accept_test_rand < alpha(idr) ) 
            % Accept this step and record acceptance in the history
            accept_mcmc_step  = 1;
            hist_accept(iter) = 1;
            
            % Mark proposed state and objective as 'current'
            obj_curr   = obj_prop;
            state_curr = state_prop;
            
            % Update current prior weight if we're doing DRAM
            if strcmp(opt_type,'DRAM')
               curr_prior_wgt    = prop_prior_wgt(idr);
            end
         else
            % Update acceptance history.
            hist_accept(iter) = 0;
         end
         
         if (dbug)
            if accept_mcmc_step == 0;  disp('Step Rejected... ');                 end
            if accept_mcmc_step == 1;  disp('Step Accepted... ');                 end
            if strcmp(opt_type,'DRAM');disp(['idr            : ', num2str(idr)]); end
            disp(['rand           : ', num2str(accept_test_rand(1))])
            disp('Proposed state : ')
            disp(state_prop)
            disp(' ')
         end
      
         if idr == 2 && accept_mcmc_step == 0
            % decl_state(idr,:)  = state_prop;
         end
         
         hist_obj(iter)           = obj_curr;
         hist_obj_prop(iter)      = obj_prop;
         hist_state(:,iter)       = state_curr;
         hist_state_prop(:,iter)  = state_prop;

         %-------------------------------------------------------------------------------------%
         % Update Statistics History
         %-------------------------------------------------------------------------------------%
         if sum(strcmp(model,{'ED2.1','out.mat','read_dir'}))
            if iter == 1                                    % Do we need to create 'hist_stats'?
               hist_stats = stats;                          % If so, it only has curr. stats.
            else                                            % Otherwise we just save the ...
               hist_stats = update_struct(stats,hist_stats);% stats from this year to the hist.
            end
         end
         
         %-------------------------------------------------------------------------------------%
         % Want to indicate occassionally what our approx. location within the markov chain is.
         % We do so by printing a message after every 10% of total chain length.               
         %-------------------------------------------------------------------------------------%
         floor_iter  = floor(tenths/10 *niter);
         floor_str   = num2str(floor_iter);
         prev_floor  = floor((tenths - 1)/10 *niter);
         prev_str    = num2str(prev_floor);
         acc_rate    = num2str(sum(hist_accept(1:iter))/iter);

         % Print the message.
         if (iter >= floor_iter)
            disp( '%---- Progress indication --------------------------------------------%')
            disp([' Iterations ', prev_str, ' through ', floor_str ,' have completed.'])
            disp([' Acceptance rate over all runs: ', acc_rate])
            disp( '%---------------------------------------------------------------------%')
            disp( ' ')
            tenths = tenths + 1;
         end
         
         %-------------------------------------------------------------------------------------%
         % Update the iteration counter and save the state.
         %-------------------------------------------------------------------------------------%
         idr  = idr  + 1;
         iter = iter + 1;
         
         if sum(strcmp(model,{'ED2.1','out.mat','read_dir'}))
            if dbug; disp('Saving current program state to opt.mat...'); end;
            save('opt.mat')
         end
         %-------------------------------------------------------------------------------------%
      else % (Prior Validity Check)
         if (dbug)
            disp('Proposal does not conform to prior... ')
            %disp(' Proposed state: ')
            %disp(state_prop)
            %disp(' ')
         end
      end % Prior Validity Check
   end % Delayed Rejection Loop
end % Primary While Loop

if strcmp(model,'Rosenbrock_2D') 
   plot_rosenbrock_2D(1,100,[-3,3],[-3,3],0.1,0.1,'incs');
   hold on
   
   plot3(hist_state(1,:)  ,hist_state(2,:)  ,hist_obj(1,:)  ,'r' ,'linewidth' ,1.5);
   plot3(hist_state(1,1)  ,hist_state(2,1)  ,hist_obj(1,1)  ,'or','markers',10);
   plot3(hist_state(1,end),hist_state(2,end),hist_obj(1,end),'om','markers',10);
   
   plot3(hist_state(1,iter_best),...
         hist_state(2,iter_best),...
         hist_obj  (1,iter_best),'og','markers',10);
   set(gcf,'Name','Test Surface and States')
   legend({'Surface','State Trajectory','First State','Last State','Best State'})
  
      
   hold off
   figure('Name','Two Diagnostics')
   subaxis(2,1,1, 'Spacing', 0.03, 'Padding', 0.03, 'Margin', 0.03)
      hold on
      plot(1:niter,hist_obj)
      plot(iter_best,hist_obj(iter_best),'or')
      title('Objective History')
      legend({'Objectives','Best Objective'})
      hold off
   subaxis(2,1,2, 'Spacing', 0.035, 'Padding', 0.03, 'Margin', 0.035)
      hold on
      plot(1:niter,hist_state)
      plot(iter_best,hist_state(:,iter_best),'or')
      title('Param. Chains')
      legend({'Coord 1','Coord 2','Best States'})
      hold off
end

% Return to whatever directory we started in.
% This is useful if we're not exiting matlab after running the alg.
cd(init_dir)

end
%==========================================================================================%
%==========================================================================================%




%==========================================================================================%
%==========================================================================================%

%------------------------------------------------------------------------------------------%
% Function for getting acceptance rates ('alphas') for DRAM
%------------------------------------------------------------------------------------------%
function [ AR ] = get_DRAM_AR(obj_prop, prop_prior_wgt, obj_curr, curr_prior_wgt )
   AR = min(1, exp(-1* (obj_prop - obj_curr + prop_prior_wgt - curr_prior_wgt)));
end

%------------------------------------------------------------------------------------------%
% Functions for getting acceptance rates ('alphas') for SA
%------------------------------------------------------------------------------------------%
function [alpha] = get_SA_alpha( obj_curr, obj_prop, temp, temp_max, accept_criteria)

   if obj_prop <= obj_curr
      alpha = 1;                                      % We always accept moves to better states
      return
   end
   
   if strcmp(accept_criteria,'Boltzmann')             % Use the "Metropolis Acceptance Criteria"
      alpha = exp(-(obj_prop - obj_curr)/temp);       % i.e. a Boltzmann Distribution.

   elseif strcmp(accept_criteria,'Sq_Decay')          % Squared decay is a reasonable
      alpha = (temp/temp_max)^2;                      % alternative
   
   elseif strcmp(accept_criteria,'Log_Decay')         % As is logarithmic decay
      alpha = (2- log10(100*(temp_max - temp)/temp_max))/2;

   end
   
end

%------------------------------------------------------------------------------------------%
% Simulated Annealing temperature functions. 
%------------------------------------------------------------------------------------------%
function [ temp ] = get_temp(iter, niter, temp_start, cooling_sched, mantissa, exp_mult)

   if strcmp(cooling_sched,'Geometric')
   % Geometric decrease in temp.
   temp = temp_start* mantissa ^ (-iter/niter * exp_mult);
   
   elseif strcmp(cooling_sched,'Linear')
   % Linear decrease in temp from start to 0.
   temp = (niter - iter + 1)/niter * temp_start;
   
   elseif strcmp(cooling_sched,'Logarithmic')
   % Log, not sure this is implemented properly at the moment.
   temp = temp_start/log(iter + 2);
   
   end
end
%==========================================================================================%
%==========================================================================================%






%=============================================================================================%
% DRAM and Simulated Annealing                                                                %
%=============================================================================================%
% Here you will find some notes on the structures, implementations, and shared code between 
% the Delayed Rejection Adaptive Metropolis Hastings algorithm and the Simulated Annealing 
% algorithm.
%
%--------------------------------------------------------------------------------------------%
% The basic SA Algorithm in pseudocode                                                       %
%--------------------------------------------------------------------------------------------%
% 
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
%=============================================================================================%



%=============================================================================================%
% Some notes on the structure of this program.                                                %
%=============================================================================================%
% The program 'optimize_ed' implements both SA and DRAM. Right now, the delayed rejection and
% adaptive components of DRAM are still under development, but the basic Metropolis-Hastings
% algorithm is functional.
%
% (More to be added)
%=============================================================================================%
