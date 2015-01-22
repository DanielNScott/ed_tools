function [ out ] = run_model(prop_state, labels, pfts, rundir, model, dbug)
%RUN_MODEL Summary of this function goes here
%   Detailed explanation goes here

if strcmp(model,'ED2.1');
   % Write the XML config. file: 
   if dbug; disp(' Writing config.xml...'); end;
   write_config_xml(prop_state, labels, pfts);

   %-------------------------------------------------------------------------------------------%
   %*** save local (MATLAB's) LIBRARY PATH
   libPathLocal = getenv('LD_LIBRARY_PATH');
   % Get machine path:
   [status, syspath] = system('printenv PATH');

   %*** set your global LIBRARY PATH 
   PATH_LD_LIBRARY = syspath;
   setenv('LD_LIBRARY_PATH', PATH_LD_LIBRARY); 

   % Run Model:
   % There are some compatability issues so for now we're disabling HDF5 version checking.
   setenv('HDF5_DISABLE_VERSION_CHECK','1');
   if dbug; disp(' Calling ed in shell...'); end;
   disp('pause 1:'); pause;
   !rm -rf ./analy/*
   !./ed 
   disp('pause 2:'); pause;
   setenv('HDF5_DISABLE_VERSION_CHECK','0')
   
   %*** restore session's MATLAB's library path
   setenv('LD_LIBRARY_PATH', libPathLocal); 
   %-------------------------------------------------------------------------------------------%
   
   
   % Create a namelist 
   if dbug; disp(' Reading namelist...'); end;
   nl = read_namelist('ED2IN','ED_NL');

   % Set things to direct import_poly
   stime = [nl.ITIMEA '-' nl.IDATEA '-' nl.IMONTHA '-' nl.IYEARA];
   ftime = [nl.ITIMEZ '-' nl.IDATEZ '-' nl.IMONTHZ '-' nl.IYEARZ];
   
   tmp = nl.FFILOUT; 
   slash_ind = strfind(tmp,'/');
   tmp = tmp(slash_ind(end)+1:end-1);
   
   ip_nl.f_type   = tmp;
   ip_nl.out_type = 'E';
   ip_nl.dir      = [rundir '/analy/'];
   ip_nl.splflg   = 1;
   ip_nl.c13out   = 0;
   ip_nl.start    = stime;
   ip_nl.end      = ftime;
   ip_nl.inc      = nl.ITIMEA;

   % Read in output from HDF5:
   if dbug; disp(' Reading HDF5 files...'); end;
   out = import_poly(ip_nl);
   
elseif strcmp(model,'out.mat');
   disp(' Loading out.mat as model output, per test condition.')
   load('r85 mpost.mat')
   out = mpost.data.r85DS;
   
elseif strcmp(model,'Rosenbrock');
   out = rosenbrock(prop_state(1), prop_state(2));
end

end