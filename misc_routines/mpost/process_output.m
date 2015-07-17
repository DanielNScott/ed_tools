function [] = process_output(sim_names)
%PROCESS_OUTPUT: This function is called by mpost.sh and is intended to interface a shell with
%some ED post processing scripts written in Matlab.
%  Inputs: 
%     - sim_names: Names of polygon folders found, as a string with no whitespace.
%     - call_loc : The directory this script was called from.

%----------- Inform user of minor preprocessing. ----------------------------------------------%
% Tell the user what this script sees. 
disp('process_output sees the input varaible sim_names as:')
disp(sim_names)

% Reformat the sim_names variable to be more easily used in Matlab scripts. 
sim_names = textscan(sim_names,'%s','Delimiter',',');    % Returns 1x1 cell w/ a cell in it.
sim_names = sim_names{1};                                % Extract the interior cell.

% Tell the user what this is interpreted as.
disp('Which is being interpreted as the set of polygons: ')
disp(sim_names)

mpost = struct();

for sim_num = 1:numel(sim_names)
   cur_sim_name = sim_names{sim_num};
   sim_dir      = [pwd(),'/',cur_sim_name];
   mpost.(cur_sim_name) = import_poly(sim_dir,0);
end

%----------- Save the Data to a .mat file ------------------------------------%
write_time = clock;
write_time = strcat(num2str(write_time(1)),'_',num2str(write_time(2)),'_', ... 
                    num2str(write_time(3)),'_',num2str(write_time(4)),'_', ...
                    num2str(write_time(5)));

mpost.write_time = write_time;

disp('==================================================================')
disp(['Saving mpost_',write_time,'.mat ...'])
save(['mpost_',write_time],'mpost')

disp(' ')
disp('mpost_interface has finished!')
end
