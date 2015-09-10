function [ ] = do_parallel_jobs( )
%DO_PARALLEL_JOBS Summary of this function goes here
%   Detailed explanation goes here

njobs     = 6;
job_mem   = 430;
job_wtime = 5;

for ijob = 1:njobs
   job_num = num2str(ijob);
   cd(['./job_', job_num])
   
   % Set the environment vars.
   setenv('job_num'  ,job_num)
   setenv('job_mem'  ,num2str(job_mem)  )
   setenv('job_wtime',num2str(job_wtime))
  
   % Make sure the environment variables are being set correctly. 
   !echo "job_num  : ${job_num}"
   !echo "job_mem  : ${job_mem}"
   !echo "job_wtime: ${job_wtime}"
   
   % Submit the current job
   !srun -J job_${job_num} -t ${job_wtime} --mem=${job_mem} ./do_job.sh ${job_num} &
   cd('../')
   
   disp(' ')
   pause(1)
end

pause(100)


end

