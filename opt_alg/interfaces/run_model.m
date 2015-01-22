function [ output ] = run_model(state_prop, labels, pfts, rundir, model, simres, dbug)
%RUN_MODEL Summary of this function goes here
%   Detailed explanation goes here

if strcmp(model,'ED2.1');
   % Write the XML config. file: 
   if dbug; disp('Writing config.xml...'); end;
   write_config_xml(state_prop, labels, pfts);
   
   % Run Model:
   % There are some compatability issues so for now we're disabling HDF5 version checking.
   setenv('HDF5_DISABLE_VERSION_CHECK','1');
   if dbug; disp(' Calling ed in shell...'); end;
   !rm -rf ./analy/*
   %!export OMP_NUM_THREADS=24
   %!ulimit -s unlimited
   !./ed
   %system('./ed 1>out.txt 2>out.err');
   setenv('HDF5_DISABLE_VERSION_CHECK','0')

   % Read output:
   if dbug; disp('Copying model output... '); end
   output = get_output(rundir, simres, dbug);

elseif strcmp(model,'out.mat');
   disp(' Loading test_out.mat as model output, per test condition...')
   load('test_out.mat')
   output = mpost.data.r85DS;
   
elseif strcmp(model,'read_dir')
   if dbug; disp('Copying model output from directory, per test condition... '); end
   output = get_output(rundir, simres, dbug);

elseif strcmp(model,'Rosenbrock_2D');
   output = rosenbrock_2D(state_prop(1),state_prop(2),1,100);
end

end