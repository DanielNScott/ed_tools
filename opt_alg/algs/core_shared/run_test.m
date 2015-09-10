function [ out ] = run_test(state,ui)
%RUN_TEST 
%   Detailed explanation goes here
   
switch lower(ui.model)
   case('rosenbrock')
      out = rosenbrock(state');
      
   case('read_dir')
      vdisp('Copying model output from directory, per test condition... ',1,ui.verbose);
      out = import_poly(ui.rundir, ui.verbose);
      
   case('out.mat')
      vdisp(' Loading test_out.mat as model output, per test condition...',1,ui.verbose);
      load('test_out.mat')
      out = mpost.data.r85DS;
end
   
end

