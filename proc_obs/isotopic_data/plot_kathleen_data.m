function [] = plot_kathleen_data(CO2_all, sdev_all, ave, hr_nobs, dates)

gen_new_fig('Hourly Soil Resp 2012');

%----------------------------------------------------------------------------------------------%
% Plot Soil Respiration and SD's by Hour
%----------------------------------------------------------------------------------------------%
subaxis(2,3,1,'Spacing', 0.03, 'Padding', 0.02, 'Margin', 0.05)
hold on
plot(1:8784,CO2_all,'or','MarkerSize',4)
plot(1:8784,sdev_all,'xb','Markersize',4)
hold off

title('\bf{Soil Resp and SDs, vs Hour}')
ylabel('mgC/m^2/hr')
xlabel('Hour of 2012')
legend({'Soil Resp. Means','Soil Resp SDs'})

%sd_frac_ave = num2str(mean(sdev(~isnan(sdev))./CO2(~isnan(CO2)))*100);
%sd_frac_std = num2str(std(sdev(~isnan(sdev))./CO2(~isnan(CO2)))*100);

%text = {['Mean SD as % Resp: ' sd_frac_ave], ...
%        ['SD of Mean SD as % Resp: ', sd_frac_std]};
%annotation('textbox', [0.112,0.818,0.1,0.1],...
%           'String', text);

% Plot Number of Samples per Datum by Hour
subaxis(2,3,2,'Spacing', 0.03, 'Padding', 0.02, 'Margin', 0.05)
sum_hr_nobs = sum(hr_nobs,2);
plot(1:8784,sum(hr_nobs,2),'x','MarkerSize',4)
title('\bf{N_s, vs Hour}')
xlabel('Hour of 2012')
ylabel('Number of Samples in Datum')


% Plot Standard Deviation by Number of Samples and Hour
subaxis(2,3,3,'Spacing', 0.03, 'Padding', 0.02, 'Margin', 0.05)
big_msk = double(...
          [sum_hr_nobs ==  1, sum_hr_nobs ==  2, sum_hr_nobs ==  3, sum_hr_nobs ==  4, ...
           sum_hr_nobs ==  5, sum_hr_nobs ==  6, sum_hr_nobs ==  7, sum_hr_nobs ==  8, ...
           sum_hr_nobs ==  9, sum_hr_nobs == 10, sum_hr_nobs == 11, sum_hr_nobs == 12, ...
           sum_hr_nobs == 13, sum_hr_nobs ==  4, sum_hr_nobs == 15, sum_hr_nobs == 16]);
        
big_msk(big_msk == 0) = NaN;
blah = [
   sdev_all.*big_msk(:,1)./CO2_all.*big_msk(:,1), ...
   sdev_all.*big_msk(:,2)./CO2_all.*big_msk(:,2), ...
   sdev_all.*big_msk(:,3)./CO2_all.*big_msk(:,3), ...
   sdev_all.*big_msk(:,4)./CO2_all.*big_msk(:,4), ...
   sdev_all.*big_msk(:,5)./CO2_all.*big_msk(:,5), ...
   sdev_all.*big_msk(:,6)./CO2_all.*big_msk(:,6), ...
   sdev_all.*big_msk(:,7)./CO2_all.*big_msk(:,7), ...
   sdev_all.*big_msk(:,8)./CO2_all.*big_msk(:,8), ...
   sdev_all.*big_msk(:,9)./CO2_all.*big_msk(:,9), ...
   sdev_all.*big_msk(:,10)./CO2_all.*big_msk(:,10), ...
   sdev_all.*big_msk(:,11)./CO2_all.*big_msk(:,11), ...
   sdev_all.*big_msk(:,12)./CO2_all.*big_msk(:,12), ...
   sdev_all.*big_msk(:,13)./CO2_all.*big_msk(:,13), ...
   sdev_all.*big_msk(:,14)./CO2_all.*big_msk(:,14), ...
   sdev_all.*big_msk(:,15)./CO2_all.*big_msk(:,15), ...
   sdev_all.*big_msk(:,16)./CO2_all.*big_msk(:,16)];

plot(1:8784,blah(:,[1,6,11,15])*100,'x','MarkerSize',4)
legend({'2 Samples','6 Samples',' 11 Samples',' 16 Samples'}, 'Location', 'NorthWest')
title('\bf{CV and N_s, vs Hour}')
ylabel('Coefficient of Variation [%]')
xlabel('Hour of 2012')


% Plot Standard Deviation by Number of Samples in Datum
subaxis(2,3,4,'Spacing', 0.03, 'Padding', 0.02, 'Margin', 0.05)
plot(sum_hr_nobs,sdev_all./CO2_all*100,'x','MarkerSize',4)

title('\bf{CV vs N_s}')
ylabel('Coefficient of Variation [%]')
xlabel('Number of Samples in Hourly Datum')


% Plot Standard Deviation by Total Flux
subaxis(2,3,5,'Spacing', 0.03, 'Padding', 0.02, 'Margin', 0.05)
plot(CO2_all,sdev_all./CO2_all*100,'x','MarkerSize',4)

title('\bf{CV vs Total Flux}')
ylabel('Coefficient of Variation [%]')
xlabel('Total Flux [mgC/m^2/hr]')


% Plot Standard Deviation by Number of Chambers in Datum
subaxis(2,3,6,'Spacing', 0.03, 'Padding', 0.02, 'Margin', 0.05)
sum_hr_nchs = sum(-1*floor(-1*hr_nobs/2),2);
plot(sum_hr_nchs,sdev_all./CO2_all*100,'x','MarkerSize',4)
set(gca,'XLim',[0,10])

title('\bf{CV vs N_c_h}')
ylabel('Coefficient of Variation [%]')
xlabel('Number of Chambers in Datum')




%----------------------------------------------------------------------------------------------%
% Plot Mean of Standard Deviations by Number of Samples in Datum
%----------------------------------------------------------------------------------------------%
gen_new_fig('Mean CVs by N_s and N_c_h');
subaxis(2,2,1,'Spacing', 0.03, 'Padding', 0.02, 'Margin', 0.05)
for i= 1:16
   mean_by_ns(i) = nanmean(sdev_all.*big_msk(:,i)./CO2_all.*big_msk(:,i));
   std_by_ns(i)  = nanstd (sdev_all.*big_msk(:,i)./CO2_all.*big_msk(:,i));
end
plot(1:16, [mean_by_ns; std_by_ns]*100,'o')
title('\bf{CV Statistics, vs N_s}')
ylabel('Coefficient of Variation [%]')
xlabel('Number of Samples in Datum')
legend('Mean of CVs','SD of CVs')


%----------------------------------------------------------------------------------------------%
% Plot Mean of Standard Deviatons by Number of Chambers in Datum
%----------------------------------------------------------------------------------------------%
subaxis(2,2,2,'Spacing', 0.03, 'Padding', 0.02, 'Margin', 0.05)
sum_hr_nchs = sum(-1*floor(-1*hr_nobs/2),2);
nch_msk = double(...
          [sum_hr_nchs ==  1, sum_hr_nchs ==  2, sum_hr_nchs ==  3, sum_hr_nchs ==  4, ...
           sum_hr_nchs ==  5, sum_hr_nchs ==  6, sum_hr_nchs ==  7, sum_hr_nchs ==  8]);

for i= 1:8
   mean_by_nch(i) = nanmean(sdev_all.*nch_msk(:,i)./CO2_all.*nch_msk(:,i));
   std_by_nch(i)  = nanstd (sdev_all.*nch_msk(:,i)./CO2_all.*nch_msk(:,i));
end
plot(1:8, [mean_by_nch; std_by_nch]*100,'o')
title('\bf{Means and SDs of CVs, vs N_s}')
ylabel('Coefficient of Variation [%]')
xlabel('Number of Chambers in Datum')
legend('Mean CV','SD of CVs')


% Plot Number of Samples per Datum vs Number of Chambers per Datum
subaxis(2,2,3,'Spacing', 0.03, 'Padding', 0.02, 'Margin', 0.05)
nch_ns_counter = zeros(8,16);
cv_ns_counter  = zeros(10,16);
cv_hr_counter  = zeros(10,24);
aggregator     = zeros(8,16);

for irow = 1:length(sum_hr_nchs)
   if sum_hr_nchs(irow) == 0
      continue
   end
   if sum_hr_nchs(irow) > 8
      disp(['sum_hr_nchs: ', num2str(sum_hr_nchs(irow)), ' irow: ' num2str(irow)])
      continue
   end
   cv = sdev_all(irow)/CO2_all(irow)*100;
   
   if isnan(cv)
      disp(['cv is nan! irow: ' num2str(irow)])
      continue
   end
   
   nch_ns_counter(sum_hr_nchs(irow),sum_hr_nobs(irow)) = ...
      nch_ns_counter(sum_hr_nchs(irow),sum_hr_nobs(irow)) + 1;
   
   aggregator(sum_hr_nchs(irow),sum_hr_nobs(irow)) = ...
      aggregator(sum_hr_nchs(irow),sum_hr_nobs(irow)) + cv;
   
   cv_ns_bin = floor(cv/10)+1;
   hr_of_day = dates(irow,4);
   
   cv_ns_counter(cv_ns_bin,sum_hr_nobs(irow)) = ...
      cv_ns_counter(cv_ns_bin,sum_hr_nobs(irow)) + 1; 
   
   cv_hr_counter(cv_ns_bin, hr_of_day + 1) = ...
      cv_hr_counter(cv_ns_bin, hr_of_day + 1) + 1;
end

nch_ns_counter(nch_ns_counter == 0) = NaN;
mean_sds = aggregator ./nch_ns_counter;

bar3(nch_ns_counter)
title('\bf{N_c_h - N_s Histogram }')
ylabel('Number of Chambers in Datum')
xlabel('Number of Observations in Datum')
zlabel('Number of Data in Bin')



% Plot Number of Samples per Datum vs Number of Chambers per Datum
subaxis(2,2,4,'Spacing', 0.03, 'Padding', 0.02, 'Margin', 0.05)
bar3(cv_ns_counter)
title('\bf{CV - N_s Histogram}')
xlabel('Number of Observations in Datum')
ylabel('Coefficient of Variation [%]')
zlabel('Number of Data in Bin')



% Plot Number of Samples per Datum vs Number of Chambers per Datum
subaxis(2,2,2,'Spacing', 0.03, 'Padding', 0.02, 'Margin', 0.05)
bar3(cv_hr_counter)
title('\bf{CV - Hour of Day Histogram}')
xlabel('Hour of the Day')
ylabel('Coefficient of Variation [%]')
zlabel('Number of Data in Bin')




%----------------------------------------------------------------------------------------------%
% Plot Number of Samples per Datum vs Number of Chambers per Datum
%----------------------------------------------------------------------------------------------%
gen_new_fig('Monthly Means of the Diurnal Cycle');
subaxis(2,2,1,'Spacing', 0.03, 'Padding', 0.02, 'Margin', 0.05)
bar3(ave.qmeans')
title('\bf{Monthly Mean Diurnal Cycle: Perspective 1}')
ylabel('Hour of the Day')
xlabel('Month of 2012')
zlabel('Flux [mgC/m^2/hr]')


subaxis(2,2,2,'Spacing', 0.03, 'Padding', 0.02, 'Margin', 0.05)
bar3(ave.qmeans')
title('\bf{Monthly Mean Diurnal Cycles: Perspective 2}')
ylabel('Hour of the Day')
xlabel('Month of 2012')
zlabel('Flux [mgC/m^2/hr]')


subaxis(2,2,3,'Spacing', 0.03, 'Padding', 0.02, 'Margin', 0.05)
bar3(ave.qsdevs'./ave.qmeans')
title('\bf{CVs in Diurnal Cycle: Perspective 1}')
ylabel('Hour of the Day')
xlabel('Month of 2012')
zlabel('Coefficient of Variation [%]')


subaxis(2,2,4,'Spacing', 0.03, 'Padding', 0.02, 'Margin', 0.05)
bar3(ave.qsdevs'./ave.qmeans')
title('\bf{CVs in Diurnal Cycle: Perspective 2}')
ylabel('Hour of the Day')
xlabel('Month of 2012')
zlabel('Coefficient of Variation [%]')



%----------------------------------------------------------------------------------------------%
% Plot Monthly and Daily Means and CVs
%----------------------------------------------------------------------------------------------%
gen_new_fig('');
subaxis(2,2,1,'Spacing', 0.03, 'Padding', 0.03, 'Margin', 0.05)
hold on
plot(1:366,ave.dmeans','ob','MarkerSize',4)
plot(1:366,ave.dsdevs','xr','MarkerSize',4)
hold off
title('\bf{Daily Stats.}')
xlabel('DoY of 2012')
ylabel('Flux [mgC/m^2/hr]')
legend({'Daily Means','Daily SDs'})

subaxis(2,2,2,'Spacing', 0.03, 'Padding', 0.03, 'Margin', 0.05)
hold on
plot(ave.mmeans','--ob')
plot(ave.msdevs','--xr')
hold off
title('\bf{Monthly Stats.}')
xlabel('Month of 2012')
ylabel('Flux [mgC/m^2/hr]')
legend({'Monthly Means','Monthly SDs'})


subaxis(2,2,3,'Spacing', 0.03, 'Padding', 0.03, 'Margin', 0.05)
hold on
plot(1:366,ave.dmeans_day','ob','MarkerSize',4)
plot(1:366,ave.dsdevs_day','or','MarkerSize',4)
plot(1:366,ave.dmeans_night','og','MarkerSize',4)
plot(1:366,ave.dsdevs_night','om','MarkerSize',4)
hold off
title('\bf{Day and Night Hour Stats.}')
xlabel('DoY of 2012')
ylabel('Flux [mgC/m^2/hr]')
legend({'Day Hour Means','Day Hour SDs','Night Hour Means','Night Hour SDs'})





end

