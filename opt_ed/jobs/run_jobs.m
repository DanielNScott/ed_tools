function [ obj ] = run_jobs(cfe, obs, state_prop, ui)
%SET_JOBS Summary of this function goes here
%   Detailed explanation goes here

vdisp('Running jobs locally...',0,ui.verbose)

cfe.njobs = size(state_prop,2);
obj       = nan(cfe.njobs,1);

for job_num = 1:cfe.njobs
   obj(job_num) = run_job(state_prop(:,job_num),cfe,obs,ui);
end
%vdisp(['Jobs 1 through ' num2str(cfe.njobs) ' finished...'],0,ui.verbose)
   
end
