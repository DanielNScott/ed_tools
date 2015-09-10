function [obj_hist,best_pred,best_stats] = get_jobs(fmt,iter,njobs,obj_hist,sim_location,verbose)
%MERGE_PARTICLE_DATA Summary of this function goes here
%   Detailed explanation goes here

if strcmp(sim_location,'local'); return; end
vdisp('Retrieving jobs...',0,verbose)

prfx  = '/job_';

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
   obj_hist(job_num,iter) = obj;

   vdisp(['job_' num2str(job_num,fmt) ' objective loaded: ' num2str(obj)],1,verbose)

   best_pred  = [];
   best_stats = [];
   if (job_num == 1 && iter == 1) || (obj <= nanmin(nanmin(obj_hist(:,1:iter))))
      load(pred_name );
      load(stats_name);
      
      vdisp(['job_' num2str(job_num,fmt) ' is a new best!'],1,verbose)
      vdisp(['Pred. & stats loaded. Obj: ' num2str(obj)],1,verbose)

      best_pred  = pred;
      best_stats = stats;
   end

end

end

