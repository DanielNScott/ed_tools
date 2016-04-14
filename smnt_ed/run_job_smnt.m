function [ ] = run_job_smnt(job_id,params)
%RUN_JOB_SMNT Summary of this function goes here
%   Detailed explanation goes here

disp(job_id)
disp(params)

obj = sum(params);

fname = ['job_obj_' num2str(job_id) '.txt'];
fileID = fopen(fname,'w');
fprintf(fileID,'%10.5f',obj);
fclose(fileID);

end

