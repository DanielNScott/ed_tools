function [] = set_jobs(iter,njobs,fmt,restart,state_prop,ui)
%SET_JOBS Summary of this function goes here
%   Detailed explanation goes here

vdisp('----- Output from set_jobs() ------',1,ui.verbose)
vdisp('Setting up jobs...',0,ui.verbose)

disp('state_prop:')
disp(state_prop)
vdisp(['set_jobs sees njobs as: ' num2str(njobs,fmt)],1,ui.verbose);
vdisp(' ',1,ui.verbose)

%--- Some parameters controlling submission ---%
not_restart   = ~restart;
use_srun      = strcmp(ui.alloc_method,'sbsr');
upfront_alloc = strcmp(ui.alloc_method,'upfront') || use_srun;


for job_num = 1:njobs
   %--- This is some NM specific setup ---%
   if strcmp(ui.opt_type,'NM') && job_num > ui.nsimp
      niter = 1;
   else
      niter = ui.niter;
   end
   
   %--- Set up directories ---%
   setup_dirs(job_num,niter,fmt,ui.job_wtime,ui.job_mem,ui.job_queue,ui.sim_file_sys,ui.verbose);

   %--- Decide to skip submission or not ---%
   not_iter_one  = iter > 1;
   if not_iter_one && not_restart && upfront_alloc
      vdisp('Upfront allocation on and iter > 1, skipping slurm interaction.',1,ui.verbose)
      vdisp(' ',1,ui.verbose)
     continue
   else
      
   %--- Job submission ---%
   dir = ['./job_' num2str(job_num,fmt)];	
   cd(dir)
   vdisp(['Submitting job ' num2str(job_num)],1,ui.verbose)
   
   opt_name = regexp(pwd,'/','split');
   opt_name = opt_name{end-1};
   setenv('niter'   ,      num2str(niter      )      )           % run_job will see as number
   setenv('job_num' ,['''' num2str(job_num,fmt) ''''])           % run_job will see as string
   setenv('proc_loc',['''' ui.rundir            ''''])           % run_job will see as string
   setenv('opt_name',      opt_name                  ) 
      
   if use_srun
      % srun ignores #SBATCH configs so we set them here.
      setenv('job_mem'  ,num2str(ui.job_mem ))
      setenv('job_wtime',num2str(ui.job_wtime*niter))
      
      % Submit the current job.
      !srun -J job_${job_num} -t ${job_wtime} --mem=${job_mem} ./run_job.sh  ${job_num} ${niter} &
   else
      !sbatch ./wrap_script.sh -p ${opt_name} './run_job.sh ${job_num} ${niter} ${proc_loc}' &
   end
   cd('../')
   vdisp(' ',1,ui.verbose)
   
   pause(0.5) % This delay exists to keep from overwhelming various systems.
   end
end
vdisp(['Jobs 1 through ' num2str(njobs) ' submitted...'],0,ui.verbose)
vdisp(' ',1,ui.verbose)

pause(10);
end

