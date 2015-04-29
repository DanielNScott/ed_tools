function [ ] = wait_for( file_list, wait_time, verb)
%WAIT_FOR Summary of this function goes here
%   Detailed explanation goes here

if ischar(file_list)
   file_list = {file_list};
end

vdisp('Waiting for file list: ',0,verb)
vdisp(file_list',0,verb)

waiting   = 1;
sum_exist = 0;

nobjects = length(file_list);
while waiting;
   for i = 1:nobjects
      obj_name  = file_list{i};                             % Particle Data Filename
      sum_exist = sum_exist + exist(obj_name,'file');       % Increment existence counter
   end
   
   if sum_exist == nobjects*2
      waiting = 0;
   else
      sum_exist = 0;
      pause(wait_time) 
   end
end
vdisp('Waiting complete, program execution proceeds.',0,verb)

end

