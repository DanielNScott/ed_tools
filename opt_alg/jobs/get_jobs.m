function [hist] = get_jobs(fmt,iter,njobs,hist,sim_location,verbose)
%MERGE_PARTICLE_DATA Summary of this function goes here
%   Detailed explanation goes here

if strcmp(sim_location,'local'); return; end
vdisp('Retrieving jobs...',0,verbose)

prfx  = '/job_';
new_global_best = 0;

for job_num = 1:njobs
   vdisp(' ',1,verbose)
   vdisp(['Current directory: ',pwd],1,verbose)
   obj_name   = ['.' prfx num2str(job_num,fmt) prfx 'obj.mat'  ];
   pred_name  = ['.' prfx num2str(job_num,fmt) prfx 'pred.mat' ];
   stats_name = ['.' prfx num2str(job_num,fmt) prfx 'stats.mat'];

   wait_for(obj_name  ,5,verbose)
   wait_for(pred_name ,5,verbose)
   wait_for(stats_name,5,verbose)

   load(obj_name  );
   load(stats_name)
   hist.obj(job_num,iter) = obj;

   vdisp(['job_' num2str(job_num,fmt) ' objective: ' num2str(obj)],1,verbose)

   if job_num == 1 && iter == 1
      best_job_stats = stats;
      new_global_best = 1;
   end
   
   if obj <= nanmin(nanmin(hist.obj(:,iter)))
      vdisp(['job_' num2str(job_num,fmt) ' is a new iteration best!'],1,verbose)
      best_job_stats = stats;

      if obj <= nanmin(nanmin(hist.obj(:,1:iter)))
         new_global_best = job_num;
         vdisp(['job_' num2str(job_num,fmt) ' is a new global best!'],1,verbose)
      end
   end
end

hist.stats = update_struct(best_job_stats,hist.stats);

if new_global_best
   pred_name  = ['.' prfx num2str(new_global_best,fmt) prfx 'pred.mat' ];
   load(pred_name);
   hist.pred_best = pred;
end


end

