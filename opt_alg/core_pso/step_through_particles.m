function [ ] = step_through_particles(nps,iter,niter,restart,time_per_sim,mem_per_sim,verbose)
%

%----------------------------------------------------------------------------------------------%
% Set a each other particle running.
%----------------------------------------------------------------------------------------------%
fmt = '%i';
if nps >= 10
   fmt = '%02i';
   if nps >= 100
      fmt = '%03i';
   end
end
obs_proc_loc = ['../particle_' num2str(1,fmt)];
for i = 1:nps
   dir    = ['particle_' num2str(i,fmt)];                         % Set particle directory
   cd(dir)
   
   obj_name = './particle_obj.mat';                               % Name file w/ objective
   out_name = './particle_out.mat';                               % Name file w/ model output

   if exist(obj_name,'file')                                      % If old data exists...
      delete(obj_name)                                            % Delete it ...
      vdisp(['file removed: ' obj_name],1,verbose)                % ... and notify!
   end

   if exist(out_name,'file')                                      % If old data exists...
      delete(out_name)                                            % Delete it ...
      vdisp(['file removed: ' out_name],1,verbose)                % ... and notify!
   end

   fopen('run_flag.txt','wt');
   fclose('all');
   
   if iter == 1 || restart
      setenv('PARTICLE_NUM',num2str(i,fmt))                          % This is how the particle
      setenv('NITER',num2str(niter))                                 % This is how the particle
      setenv('OBS_PROC_LOC',obs_proc_loc)                            % This is how the particle

         % Run the particle!
      if verbose >= 1
%         if i > nsimp && strcmp(opt_type,'nm')
%            niter = 1;
%         end
         
         set_scheduler_opts(time_per_sim,niter,mem_per_sim)
         !sbatch ./run_particle_upfront.sh $PARTICLE_NUM $OBS_PROC_LOC $NITER &
      else
         !sbatch ./run_particle_upfront.sh $PARTICLE_NUM $OBS_PROC_LOC $NITER 1>/dev/null &
      end
   end
   cd('../')                                                      % Up one so we can repeat.
end
vdisp(['Particles 1 through ' num2str(nps) ' submitted...'],0,verbose)
%----------------------------------------------------------------------------------------------%

end

function [] = set_scheduler_opts(time,niter,mem)

fname = 'run_particle_upfront.sh';
A = regexp( fileread(fname), '\n', 'split');
A{10} = ['#SBATCH -t ' num2str(time*60*niter)];
A{12} = ['#SBATCH --mem=' num2str(mem)];
fid = fopen(fname, 'w');
fprintf(fid, '%s\n', A{:});
fclose(fid);

end

