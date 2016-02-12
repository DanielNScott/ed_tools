function [ obj, hist ] = run_jobs_locally(cfe, obs, hist, state_prop, ui)
%SET_JOBS Summary of this function goes here
%   Detailed explanation goes here

vdisp('Running jobs locally...',0,ui.verbose)

cfe.njobs = size(state_prop,2);
obj       = nan(cfe.njobs,1);

if cfe.iter == 1
   [hist.stats.ref, hist.pred_ref] = run_job(ui.state_ref,cfe,obs,ui);
end

for job_num = 1:cfe.njobs
   obj(job_num) = run_job(state_prop(:,job_num),cfe,obs,ui);
end
%vdisp(['Jobs 1 through ' num2str(cfe.njobs) ' finished...'],0,ui.verbose)
   
end
