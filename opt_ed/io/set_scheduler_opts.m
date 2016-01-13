function [ ] = set_scheduler_opts( job_name, time, mem, niter, partition, sim_file_sys )
%SET_SCHEDULER_OPTS Summary of this function goes here
%   Detailed explanation goes here

if strcmp(sim_file_sys,'local')
   fname = 'wrap_script.sh';
   lnums = [12,13,14,15];
else
   error('set_scheduler_opts: Only local sim_file_sys is supported currently!')
   %fname = '';
   %lnums = [];
end

A = regexp( fileread(fname), '\n', 'split'); 

A(lnums) = {['#SBATCH -t ' num2str(time*niter)] ...
           ,['#SBATCH -p ' partition] ...
           ,['#SBATCH --mem=' num2str(mem)] ...
	        ,['#SBATCH -J ' job_name]};
        
fid = fopen(fname, 'w');
fprintf(fid, '%s\n', A{:});
fclose(fid);

end

