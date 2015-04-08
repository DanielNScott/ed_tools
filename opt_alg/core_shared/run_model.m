function [ output ] = run_model(state_prop, ui, nfo)
%RUN_MODEL Summary of this function goes here
%   Detailed explanation goes here

if strcmp(ui.model,'ED2.1');
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
      !./ed
   %end
   %system('./ed 1>out.txt 2>out.err');
   setenv('HDF5_DISABLE_VERSION_CHECK','0')

   % Read output:
   if ui.verbose >= 1; disp('Copying model output... '); end
   output = get_output(ui.rundir, nfo.simres, ui.verbose);

elseif strcmp(ui.model,'out.mat');
   if ui.verbose >= 1; disp(' Loading test_out.mat as model output, per test condition...'); end
   load('test_out.mat')
   output = mpost.data.r85DS;
   
elseif strcmp(ui.model,'read_dir')
   disp('Copying model output from directory, per test condition... ');
   output = get_output(ui.rundir, nfo.simres, ui.verbose);

elseif strcmp(ui.model,'Rosenbrock');
   output = rosenbrock_fn(state_prop);
   
end

end