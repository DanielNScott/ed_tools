function [ output ] = do_job( job_num )
%DO_JOB Summary of this function goes here
%   Detailed explanation goes here

if ischar(job_num)
   disp(['job_num was passed as a string.'])
   disp(['job_num : ' job_num])
   job_num = str2double(job_num);
end

output = (job_num - 1)*5:job_num*5;

hostname = system('hostname');
disp(['hostname: ' hostname]);
disp(['output  : ' mat2str(output)]);

end

