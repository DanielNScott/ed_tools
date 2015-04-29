function [ out ] = import_poly_multi(namelist, simres, dbug )
%IMPORT_POLY_multi Is a wrapper for calling import poly at multiple resolutions
%   Detailed explanation goes here

   out = struct;
   % Fast Read...
   if simres.fast;
      if dbug
         disp(' ')
         disp(' Reading FAST HDF5 files :')
         disp(['   ' namelist.dir namelist.f_type])
      end
      namelist.out_type = 'I';
      fout = import_poly(namelist,dbug);
      out  = merge_struct(fout ,out);
   end
   
   % Daily Read...
   if simres.daily;
      if dbug
         disp(' ')
         disp(' Reading DAILY HDF5 files :')
         disp(['   ' namelist.dir namelist.f_type])
      end
      namelist.out_type = 'D';
      dout = import_poly(namelist,dbug);
      out  = merge_struct(dout ,out);
   end

   % Monthly Read...
   if simres.monthly;
      if dbug
         disp(' ')
         disp(' Reading MONTHLY HDF5 files :')
         disp(['   ' namelist.dir namelist.f_type])
      end
      namelist.out_type = 'Q';
      mout = import_poly(namelist,dbug);
      out  = merge_struct(mout ,out);
   end

   % Yearly Read...
   if simres.yearly;
      if dbug
         disp(' ')
         disp(' Reading yearly HDF5 files :')
         disp(['   ' namelist.dir namelist.f_type])
      end
      namelist.out_type = 'Y';
      yrout = import_poly(namelist,dbug);
      out   = merge_struct(yrout,out);
   end
   
   % "Tower" Read...
   if simres.fast;
      if dbug
         disp(' ')
         disp(' Reading Tower HDF5 files :')
         disp(['   ' namelist.dir namelist.f_type])
      end
      namelist.out_type = 'T';
      tout = import_poly(namelist,dbug);
      out   = merge_struct(tout,out);
   end
   
end

