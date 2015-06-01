function [ out ] = get_output( rundir, simres, verbose)
%GET_OUTPUT Summary of this function goes here
%   Detailed explanation goes here

   %--------------------------------------------------------------------------
   % Create a namelist 
   %--------------------------------------------------------------------------
   if verbose >= 0; disp(' Reading namelist...'); end;
   nl = read_namelist([rundir 'ED2IN'],'ED_NL');

   %--------------------------------------------------------------------------
   % Set things to direct import_poly
   %--------------------------------------------------------------------------
   stime  = [nl.IYEARA '-' nl.IMONTHA '-' nl.IDATEA '-' nl.ITIMEA];
   ftime  = [nl.IYEARZ '-' nl.IMONTHZ '-' nl.IDATEZ '-' nl.ITIMEZ];
   
   if isfield('nl','C13AF')
      c13out = str2double(nl.C13AF);
   else
      c13out = 0;
   end
   if c13out > 0;
      c13out = 1;
   end
   
   tmp = nl.FFILOUT; 
   slash_ind = strfind(tmp,'/');
   tmp = tmp(slash_ind(end)+1:end-1);
   
   ip_nl.f_type   = tmp;
   ip_nl.dir      = [rundir '/analy/'];
   ip_nl.splflg   = 1;
   ip_nl.c13out   = c13out;
   ip_nl.start    = stime;
   ip_nl.end      = ftime;
   ip_nl.inc      = nl.ITIMEA;

   %--------------------------------------------------------------------------
   % Read in output from HDF5:
   %--------------------------------------------------------------------------
   out = struct;
   
   if simres.daily;
      % Daily Read...
      if verbose >= 0
         disp(' ')
         disp(' Reading daily HDF5 files :')
         disp(['   ' ip_nl.dir ip_nl.f_type])
      end
      ip_nl.out_type = 'D';
      dout = import_poly(ip_nl);
      out  = merge_struct(dout ,out);
   end

   if simres.monthly || simres.yearly;
      % Monthly Read...
      if verbose >= 0
         disp(' ')
         disp(' Reading monthly HDF5 files :')
         disp(['   ' ip_nl.dir ip_nl.f_type])
      end
      ip_nl.out_type = 'Q';
      mout = import_poly(ip_nl);
      out  = merge_struct(mout ,out);
   end

   if simres.yearly;
      % Yearly Read...
      if verbose >= 0
         disp(' ')
         disp(' Reading yearly HDF5 files :')
         disp(['   ' ip_nl.dir ip_nl.f_type])
      end
      ip_nl.out_type = 'Y';
      yrout = import_poly(ip_nl);
      out   = merge_struct(yrout,out);
   end
   
   if simres.fast;
      % "Tower" Read...
      if verbose >= 0
         disp(' ')
         disp(' Reading Tower HDF5 files :')
         disp(['   ' ip_nl.dir ip_nl.f_type])
      end
      ip_nl.out_type = 'T';
      tout = import_poly(ip_nl);
      out   = merge_struct(tout,out);
   end
   
end

