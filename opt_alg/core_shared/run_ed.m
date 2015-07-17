function [ output ] = run_ed(state_prop, ui, nfo)
%RUN_ED Summary of this function goes here
%   Detailed explanation goes here

% Write the XML config. file: 
if ui.verbose >= 1; disp('Writing config.xml...'); end
write_config_xml(state_prop, ui.labels, ui.pfts);

% Run Model:
% There are some compatability issues so for now we're disabling HDF5 version checking.
setenv('HDF5_DISABLE_VERSION_CHECK','1');
if ui.verbose >= 1; disp(' Calling ed in shell...'); end
!rm -rf ./analy/*
%!export OMP_NUM_THREADS=24
%!ulimit -s unlimited
%if strcmp(ui.opt_type,'PSO')
%   !./ed 1>out.txt 2>out.err
%else
if isfield(ui,'run_external')
   !rm -f run_finished.txt
   !sbatch runed.sh
   wait_for('./run_finished.txt',180,ui.verbose);
   !rm -f run_finished.txt
else
   !./ed
end
%end
%system('./ed 1>out.txt 2>out.err');
setenv('HDF5_DISABLE_VERSION_CHECK','0')

% Read output:
output = import_poly(ui.rundir, ui.verbose);

end