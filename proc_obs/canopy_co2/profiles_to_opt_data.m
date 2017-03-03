function [ ] = profiles_to_opt_data(co2_mean, c13_mean)
%PROFILES_TO_OPT_DATA creates ed_opt observations from pre-processed
% profile data, the output of INTEGRATE_PROFILES.m

% Read profile data to extract time vectors.
profile_fname = '/home/dan/documents/harvard/data/observations/harvard_forest_archives/hf-209-iso/orig/HF-Profiles.tsv';

tsv_data  = dlmread(profile_fname, '\t', 1, 0);
time_data = tsv_data(:, 1:5);

time.Min   = time_data(:, 5);
time.Hour  = time_data(:, 4);
time.Year  = time_data(:, 3);
time.Month = time_data(:, 2);
time.Day   = time_data(:, 1);

data.co2  = co2_mean;
data.c13  = c13_mean;

licd_data = licd(data, time, 1);
licd_data.co2_std = abs(licd_data.co2 * 0.1); % Totally invented atm...

%plot(licd_data.co2)

licd_data.d13C = get_d13C(licd_data.c13, licd_data.co2);

beg_str = pack_time(2011,1,1,0,0,0,'std');
end_str = pack_time(2014,1,1,0,0,0,'std');

mc_co2  = mc_ems_data (licd_data.co2, ...
                       licd_data.co2_std, ...
                       5000, beg_str, end_str, 'normrnd');

mc_d13C = mc_d13C_data(licd_data.c13, abs(licd_data.c13)*0.005, ...
                       licd_data.co2, abs(licd_data.co2)*0.005, ...
                       4000, beg_str, end_str, 'normrnd');

end

