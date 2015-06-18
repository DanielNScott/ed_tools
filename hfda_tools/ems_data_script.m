function [] = ems_data_script(years,save_mat)

for iyr = years
   yrstr  = num2str(iyr);
   endstr = num2str(iyr + 1);
   
   in_fname = 'C:\Users\Dan\Moorcroft_Lab\data\USHa_MC\raw\hf004-02-obs-nee.csv';
   data     = csvread(in_fname,1,0);
   
   NEE   = data(data(:,1)==iyr,2);
   NEE(NEE == -9999) = NaN;
   NEE_sd = get_nee_unc(NEE);
 
   NEE    = convert_units(NEE);
   NEE_sd = convert_units(NEE_sd);

   start_time = [yrstr  '-01-01-00-00-00'];
   end_time   = [endstr '-01-01-00-00-00'];
   
   clear data;
   
   disp(['MC generation of NEE for year: ' yrstr '...'])
   mc = mc_ems_data(NEE,NEE_sd,10000,start_time,end_time);
   
   [nt_op,dt_op] = get_nt_dt_ops(iyr);
   mc.hm       = NEE;
   mc.hs       = NEE_sd;
   mc.hm_day   = NEE    .*dt_op;
   mc.hs_day   = NEE_sd .*dt_op;
   mc.hm_night = NEE    .*nt_op;
   mc.hs_night = NEE_sd .*nt_op;

   if save_mat
      matname = ['mc_obs_res_' yrstr '.mat'];

      disp(['Saving ' matname])
      disp(' ')
      save(matname,'mc')
   end
   
   tvec.yr = fill_dates('Y',start_time,end_time,'000000','-mat');
   tvec.yr = tvec.yr(:,1);

   tvec.mo = fill_dates('M',start_time,end_time,'000000','-mat');
   tvec.mo = tvec.mo(:,1:2);

   tvec.dy = fill_dates('D',start_time,end_time,'000000','-mat');
   tvec.dy = tvec.dy(:,1:3);

   tvec.hr = fill_dates('I',start_time,end_time,'010000','-mat');
   tvec.hr = tvec.hr(:,1:3);
   
   % This is saving the means not the actual aggregates... that's ok though for now.
   % Yearly Write
   out_fname = ['nee_yearly_' yrstr '.csv'];
   out_data  = [tvec.yr,mc.ym,mc.ys,mc.ym_day,mc.ys_day,mc.ym_night,mc.ys_night];
   out_data(isnan(out_data)) = -9999;
   fid = fopen(out_fname,'wt');
   fprintf(fid,'"# NEE is in kgC/m2/yr"\n');
   header = 'Year, NEE, NEE_sd, NEE_Day, NEE_Day_sd, NEE_Night, NEE_Night_sd \n';
   fprintf(fid,header);
   dlmwrite(out_fname,out_data,'delimiter',',','-append');
   fclose(fid);

   % Monthly Write
   out_fname = ['nee_monthly_' yrstr '.csv'];
   out_data  = [tvec.mo,mc.mm,mc.ms,mc.mm_day,mc.ms_day,mc.mm_night,mc.ms_night];
   out_data(isnan(out_data)) = -9999;
   fid = fopen(out_fname,'wt');
   fprintf(fid,'"# NEE is in kgC/m2/yr"\n');
   header = 'Year, Month, NEE, NEE_sd, NEE_Day, NEE_Day_sd, NEE_Night, NEE_Night_sd \n';
   fprintf(fid,header);
   dlmwrite(out_fname,out_data,'delimiter',',','-append');
   fclose(fid);

   % Daily Write
   out_fname = ['nee_daily_' yrstr '.csv'];
   out_data  = [tvec.dy,mc.dm,mc.ds,mc.dm_day,mc.ds_day,mc.dm_night,mc.ds_night];
   out_data(isnan(out_data)) = -9999;
   fid = fopen(out_fname,'wt');
   fprintf(fid,'"# NEE is in kgC/m2/yr"\n');
   header = 'Year, Month, Day, NEE, NEE_sd, NEE_Day, NEE_Day_sd, NEE_Night, NEE_Night_sd \n';
   fprintf(fid,header);
   dlmwrite(out_fname,out_data,'delimiter',',','-append');
   fclose(fid);

   % Hourly Write
   out_fname = ['nee' yrstr '_hourly_.csv'];
   out_data  = [tvec.hr,mc.hm,mc.hs,mc.hm_day,mc.hs_day,mc.hm_night,mc.hs_night];
   out_data(isnan(out_data)) = -9999;
   fid = fopen(out_fname,'wt');
   fprintf(fid,'"# NEE is in kgC/m2/yr"\n');
   header = 'Year, Month, Day, NEE, NEE_sd, NEE_Day, NEE_Day_sd, NEE_Night, NEE_Night_sd \n';
   fprintf(fid,header);
   dlmwrite(out_fname,out_data,'delimiter',',','-append');
   fclose(fid);
end

end