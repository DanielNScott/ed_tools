addpath(genpath('/home/dan/code/harvard/ed_tools/'))
load('/home/dan/documents/harvard/data/observations/harvard_forest_archives/hf-209-iso/orig/integrate_canopy_means_results.mat')

time_data = prof_data;

time.Min   = prof_data.MI;
time.Hour  = prof_data.HH;
time.Year  = prof_data.YYYY;
time.Month = prof_data.MO;
time.Day   = prof_data.DD;

can_data.co2 = big_co2(:,7);
can_data.c13 = big_c13(:,7);

licd_can_data      = licd(can_data, time, 1);
licd_can_data.d13C = get_d13C(licd_can_data.c13, licd_can_data.co2);

% This is loaded from the data Bill sent:
% /home/dan/documents/harvard/data/observations/supp_CO2_data_from_bill_2010_2013.dat
CO2ppm(CO2ppm == -9999) = NaN;

filled_mean_amb_co2 = nanmean([[NaN(8760,1);licd_can_data.co2], CO2ppm1],2);

% look ahead, look back

ndays    = 10;
back_msk = zeros(1,24*ndays);
fwd_msk  = zeros(1,24*ndays);
i_max    = length(filled_mean_amb_co2);
for i = 1:i_max
   back_msk = zeros(1,24*ndays);
   fwd_msk  = zeros(1,24*ndays);
   
   indices = (0:24:24*(ndays-1)) + i;
   
   inds_bck = 2*i - 24 - indices;
   inds_fwd = 24 + indices;
   
   %disp(['Iteration ' num2str(i)])
   %disp(inds_bck(inds_bck > 0))
   %disp(inds_fwd(inds_fwd < i_max))
   %disp(' ')
   
   inds_bck = inds_bck(inds_bck > 0);
   inds_fwd = inds_fwd(inds_fwd < i_max);
   
   if isnan(filled_mean_amb_co2(i))
      filled_mean_amb_co2(i) = nanmean(filled_mean_amb_co2([inds_bck,inds_fwd]));
   end
end

% Linear regression of d13C on ambient CO2: y = -0.048*x + 11
d13C_fill = -0.048*filled_mean_amb_co2(isnan(licd_can_data.d13C)) + 11;
filled_mean_amb_d13C = licd_can_data.d13C;
filled_mean_amb_d13C(isnan(filled_mean_amb_d13C)) = d13C_fill;

% Write out files
mo_names = {'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'};
for yr = 2010:2013
   % The endpoints of each month
   % Padded with leading zero so the for loop below can index
   % the start and end of each month
   mo_index = [0 cumsum(yrfrac(1:12, yr, '-days'))*24];
   for mo = 1:12
      mo_start = mo_index(mo)+1;
      mo_end   = mo_index(mo+1);
      
      filename = ['atmCO2_', num2str(yr), mo_names{mo}, '.h5'];
      
      
      npts = mo_end - mo_start + 1;
      dims = [npts, 1, 1];
      
      h5create(filename,'/co2', dims )
      h5write(filename,'/co2' , reshape(filled_mean_amb_co2(mo_start:mo_end), dims))
      
      h5create(filename,'/co2_d13C', dims)
      h5write(filename,'/co2_d13C', reshape(filled_mean_amb_d13C(mo_start:mo_end), dims))
   end
end