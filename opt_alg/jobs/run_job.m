function [ varargout ] = run_job( job_num_str, niter, pso_loc )
%RUN_JOB Gets called in every particle 
%   Detailed explanation goes here

job_num   = str2double(job_num_str);
niter_str = num2str(niter);

[~,job_host] = system('hostname');
disp(' ')
disp('----------------- Input Args & Job Info ---------------------')
disp(['job number       : ' job_num_str])
disp(['niter            : ' niter_str  ])
disp(['pso location     : ' pso_loc    ])
disp(['Output from pwd  : ' pwd        ])
disp(['Executing on host: ' job_host   ])
disp('-------------------------------------------------------------')
disp(' ')

% This needs to happen on iter 1 for cfe.xtrnl to exist.
load(pso_mat_fname)

% When running locally, this loop has 1 iteration.
% When running externally, this loop moves in step with the loop in optimize_ed.
for iter = 1:niter
   disp(['Iteration: ' num2str(iter)])
   
   % Setup filenames used throughout this function
   job_dir         = [pso_loc '/job_' job_num_str '/'];
   
   % Inputs filenames (obs_proc may also be output)
   pso_mat_fname   = [pso_loc '/pso.mat' ];
   obs_mat_fname   = [pso_loc '/obs.mat' ];
   obs_proc_fname  = [pso_loc '/obs_proc.mat'];
   run_flag_fname  = [job_dir 'run_flag.txt' ];
   
   % Output filenames
   dump_fname      = [job_dir '/dump.mat'];
   job_obj_fname   = [job_dir 'job_obj.mat'  ];
   job_pred_fname  = [job_dir 'job_pred.mat' ];
   job_stats_fname = [job_dir 'job_stats.mat'];

   % Print the filenames in use.
   disp('--------------------------------------------------')
   disp('Filenames being used by this job:')
   disp('--------------------------------------------------')
   disp(['job_dir        : ' job_dir        ])
   disp(['pso_mat_fname  : ' pso_mat_fname  ])
   disp(['obs_mat_fname  : ' obs_mat_fname  ])
   disp(['obs_proc_fname : ' obs_proc_fname ])
   disp(['run_flag_fname : ' run_flag_fname ])
   disp(['dump_fname     : ' dump_fname     ])
   disp(['job_obj_fname  : ' job_obj_fname  ])
   disp(['job_pred_fname : ' job_pred_fname ])
   disp(['job_stats_fname: ' job_stats_fname])
   disp('--------------------------------------------------')
   disp(' ')
   
   % Now start actually doing things.
   if cfe.run_xtrnl
      wait_for(run_flag_fname,10,1)
      load(pso_mat_fname)
      %if iter > 1
         %vdisp(['Current dir: ' pwd],1,ui.verbose)
         %load('../pso.mat')
         
         %wait_for(job_conf_fname,10,ui.verbose)
         %pause(3)
         %load(job_conf_fname)
      %end
      if strcmp(ui.opt_type,'PSO')
         ui.rundir = job_dir;
      end
      state = state_prop(:,job_num);
      
      vdisp('State: ',1,ui.verbose)
      vdisp(state,1,ui.verbose)
   end

   vdisp('Running the model... ',0,ui.verbose);
   if cfe.is_test
      obj  = run_test(state,ui);
      pred = obj;
      stats.total_likely = obj;
   else
      if iter == 1
         load(obs_mat_fname)
         disp('obs.mat loaded')
      else
         load(obs_proc_fname)
         disp('obs_proc.mat loaded')
      end

      %-------------------------------------------------------------------------------%
      % Here we do the following:                                                     %
      % 1) Run the model.                                                             %
      %                       Preprocess Observations (if necessary)                  %
      %                                   Rework Data                                 %
      % For some model output (things with prefix .Y. in their data structure paths)  %
      % we want to deal with partial sums of e.g. days/months, depending on what      %
      % observations are available. We process these here.                            %
      %-------------------------------------------------------------------------------%
      pred = run_ed(state, cfe.labels, ui.pfts, ui.verbose);
      if iter == 1
         vdisp('Preprocessing the observational data... ',0,ui.verbose);
         obs = preproc_obs(obs, pred, ui.opt_metadata);
      end
      pred = rework_data(obs, pred, ui.opt_metadata);
      %-------------------------------------------------------------------------------%

      %----------------------------------------------------------------------------------%
      %                             Calculate the Objective                              %
      % Evaluate the objective function. This is where the algorithm is mostly likely to %
      % fail due to source-code errors, so catch any faults and dump state to a .mat.    %
      %----------------------------------------------------------------------------------%
      vdisp('Calculating the objective function... ',0,ui.verbose);
      try
         stats = get_stats(pred, obs, ui.opt_metadata);
      catch ME
         ME.getReport()
         disp('Saving dump.mat')
         save(dump_fname)
         error('See Previous Messages.')
      end

      % For the ED model, we want to minimize the quantity (-1* log total likelihood)
      obj = stats.total_likely * (-1);
      %----------------------------------------------------------------------------------%


      % If this is the first particle and the first iteration, transfer back the processed
      % observational data, otherwise just xfer the output and the objective. Elements of structures
      % aren't valid variables here so we have to put them in "normal" vars.
      if job_num == 1 && iter == 1 && ~cfe.is_test
         vdisp('Saving obs_proc.mat.',1,ui.verbose)
         save(obs_proc_fname,'obs')
      end

   end
   
   
   if cfe.run_xtrnl
      vdisp(['Deleting ' run_flag_fname],1,ui.verbose)
      delete(run_flag_fname)
      pause(10)
      vdisp('Saving *.mat files.',1,ui.verbose)
      save(job_obj_fname,'obj'  )
      save(job_pred_fname,'pred' )
      save(job_stats_fname,'stats')
   end

   if nargout > 0;
      varargout{1} = obj;
      if ~cfe.is_test
         varargout{2} = pred;
      end
   end
   
end

end
