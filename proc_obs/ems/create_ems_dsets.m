function [] = create_ems_dsets(years,save_mat,ntraj,fill)
% CREATE_EMS_DSETS This function creates the data files which get read by get_obs.
%  It takes a vector of years to work with, reads them from the raw, unfilled ems data,
%  resamples that data based on the Hollinger & Richardson '05 characterization of the SD on the
%  double exponential distribution of hourly values centered @ the mean value specified by the
%  observation, computes aggregates over daily, monthly, and yearly resolutions (of both
%  day-time masked and night-time masked data) and produces files containing those aggregates
%  and their uncertainties (computed based on the resampling).
%
%  Inputs:
%     years    - a vector of years to read, e.g. [2010,2011,2012].
%     save_mat - a logical flag specifying whether or not to save the yearly results in .mat
%                files.
%     ntraj    - number of instantiations of time series from probability distribution
%     fill     - 'filled','unfilled', or 'hybrid' depending on the input data type
%
%  Note: The path to the csv containing 2 columns of data, year & nee. Whole years of data must
%  be present. If the csvread fails, check there is one row of headers.

for iyr = years
   yrstr  = num2str(iyr);
   endstr = num2str(iyr + 1);
   
   switch fill
      case('filled')
         in_fname = 'C:\Users\Dan\Moorcroft_Lab\data\USHa_MC\raw\hf004-02-filled-nee.csv';
         data     = csvread(in_fname,1,0);
      case('unfilled')
         in_fname = 'C:\Users\Dan\Moorcroft_Lab\data\USHa_MC\raw\hf004-02-obs-nee.csv';
         data     = csvread(in_fname,1,0);
      case('hybrid')
         in_fname = 'C:\Users\Dan\Moorcroft_Lab\data\USHa_MC\raw\hf004-02-obs-nee.csv';
         data_unf = csvread(in_fname,1,0);
         
         in_fname = 'C:\Users\Dan\Moorcroft_Lab\data\USHa_MC\raw\hf004-02-filled-nee.csv';
         data_fil = csvread(in_fname,1,0);
         
         msk_yr = data_fil(:,1) == iyr;
         data_fil = data_fil(msk_yr,:);
         data_unf = data_unf(msk_yr,:);
         data     = data_fil;
         
         msk_fill = data_unf(:,2) == -9999;
         data(msk_fill,2) = -9999;
         clear data_fil data_unf;
      otherwise
         error('Please specify fill as "filled", "unfilled", or "hybrid"')
   end

   NEE   = data(data(:,1)==iyr,2);
   NEE(NEE == -9999) = NaN;
   NEE_sd = get_nee_unc(NEE);
 
   NEE    = convert_units(NEE);
   NEE_sd = convert_units(NEE_sd);

   start_time = [yrstr  '-01-01-00-00-00'];
   end_time   = [endstr '-01-01-00-00-00'];
   
   clear data;
   
   disp(['Monte-Carlo resampling NEE for year: ' yrstr '...'])
   mcr = mc_ems_data(NEE,NEE_sd,ntraj,start_time,end_time);
   
   % From here this routine's contents should be replaced by calling
   % write_aggs()
   
   [nt_op,dt_op] = get_nt_dt_ops(iyr);
   mcr.hm       = NEE;
   mcr.hs       = NEE_sd;
   mcr.hm_day   = NEE    .*dt_op;
   mcr.hs_day   = NEE_sd .*dt_op;
   mcr.hm_night = NEE    .*nt_op;
   mcr.hs_night = NEE_sd .*nt_op;

   if save_mat
      if strcmp(fill,'unfilled')
         matname = ['mc_obs_res_' yrstr '.mat'];
      elseif strcmp(fill,'filled')
         matname = ['mc_filled_res_' yrstr '.mat'];
      elseif strcmp(fill,'hybrid')
         matname = ['mc_hybrid_res_' yrstr '.mat'];
      end

      disp(['Saving ' matname])
      disp(' ')
      save(matname,'mcr')
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
   out_data  = [tvec.yr     , ...
                mcr.ym      , ...
                mcr.ys      , ...
                mcr.ym_day  , ...
                mcr.ys_day  , ...
                mcr.ym_night, ...
                mcr.ys_night ];
   
   out_data(isnan(out_data)) = -9999;
   fid = fopen(out_fname,'wt');
   fprintf(fid,'"# NEE is in kgC/m2/yr"\n');
   header = 'Year, NEE, NEE_sd, NEE_Day, NEE_Day_sd, NEE_Night, NEE_Night_sd \n';
   fprintf(fid,header);
   dlmwrite(out_fname,out_data,'delimiter',',','-append');
   fclose(fid);

   % Monthly Write
   out_fname = ['nee_monthly_' yrstr '.csv'];
   out_data  = [tvec.mo     , ...
                mcr.mm      , ...
                mcr.ms      , ...
                mcr.mm_day  , ...
                mcr.ms_day  , ...
                mcr.mm_night, ...
                mcr.ms_night];
             
   out_data(isnan(out_data)) = -9999;
   fid = fopen(out_fname,'wt');
   fprintf(fid,'"# NEE is in kgC/m2/yr"\n');
   header = 'Year, Month, NEE, NEE_sd, NEE_Day, NEE_Day_sd, NEE_Night, NEE_Night_sd \n';
   fprintf(fid,header);
   dlmwrite(out_fname,out_data,'delimiter',',','-append');
   fclose(fid);

   % Daily Write
   out_fname = ['nee_daily_' yrstr '.csv'];
   out_data  = [tvec.dy     , ...
                mcr.dm      , ...
                mcr.ds      , ...
                mcr.dm_day  , ...
                mcr.ds_day  , ...
                mcr.dm_night, ...
                mcr.ds_night];
             
   out_data(isnan(out_data)) = -9999;
   fid = fopen(out_fname,'wt');
   fprintf(fid,'"# NEE is in kgC/m2/yr"\n');
   header = 'Year, Month, Day, NEE, NEE_sd, NEE_Day, NEE_Day_sd, NEE_Night, NEE_Night_sd \n';
   fprintf(fid,header);
   dlmwrite(out_fname,out_data,'delimiter',',','-append');
   fclose(fid);

   % Hourly Write
   out_fname = ['nee_hourly_' yrstr '.csv'];
   out_data  = [tvec.hr     , ...
                mcr.hm      , ...
                mcr.hs      , ...
                mcr.hm_day  , ...
                mcr.hs_day  , ...
                mcr.hm_night, ...
                mcr.hs_night];
             
   out_data(isnan(out_data)) = -9999;
   fid = fopen(out_fname,'wt');
   fprintf(fid,'"# NEE is in kgC/m2/yr"\n');
   header = 'Year, Month, Day, NEE, NEE_sd, NEE_Day, NEE_Day_sd, NEE_Night, NEE_Night_sd \n';
   fprintf(fid,header);
   dlmwrite(out_fname,out_data,'delimiter',',','-append');
   fclose(fid);
end

end