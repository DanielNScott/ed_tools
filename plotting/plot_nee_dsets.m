function [ ] = plot_nee_dsets()
%NEE_SCRIPT Compares filled, unfilled, and monte-carlo resampled NEE data.

if exist('cache.mat','file')
   load cache.mat
else
   filled_2010 = csvread('C:\Users\Dan\Moorcroft_Lab\data\USHa_MC\raw\filled_nee_2010.csv');
   filled_2011 = csvread('C:\Users\Dan\Moorcroft_Lab\data\USHa_MC\raw\filled_nee_2011.csv');
   filled_2012 = csvread('C:\Users\Dan\Moorcroft_Lab\data\USHa_MC\raw\filled_nee_2012.csv');
   filled_2012 = [filled_2012; NaN(24,1)];

   fagg_2010 = aggregate_data(filled_2010,'2010-01-01-00-00-00','2011-01-01-00-00-00','ave');
   fagg_2011 = aggregate_data(filled_2011,'2011-01-01-00-00-00','2012-01-01-00-00-00','ave');
   fagg_2012 = aggregate_data(filled_2012,'2012-01-01-00-00-00','2013-01-01-00-00-00','ave');

   obs = csvread('C:\Users\Dan\Moorcroft_Lab\data\USHa_MC\raw\hf004-02-obs-nee.csv',1,0);

   obs_2010 = obs(obs(:,1) == 2010,2);
   obs_2011 = obs(obs(:,1) == 2011,2);
   obs_2012 = obs(obs(:,1) == 2012,2);

   oagg_2010 = aggregate_data(obs_2010,'2010-01-01-00-00-00','2011-01-01-00-00-00','ave');
   oagg_2011 = aggregate_data(obs_2011,'2011-01-01-00-00-00','2012-01-01-00-00-00','ave');
   oagg_2012 = aggregate_data(obs_2012,'2012-01-01-00-00-00','2013-01-01-00-00-00','ave');

   obs_2010(obs_2010 == -9999) = NaN;
   obs_2011(obs_2011 == -9999) = NaN;
   obs_2012(obs_2012 == -9999) = NaN;

   %obs_2010 = csvread('C:\Users\Dan\Moorcroft_Lab\data\USHa_MC\obs_nee\nee_hourly_2010.csv');
   %obs_2011 = csvread('C:\Users\Dan\Moorcroft_Lab\data\USHa_MC\obs_nee\nee_hourly_2011.csv');
   %obs_2012 = csvread('C:\Users\Dan\Moorcroft_Lab\data\USHa_MC\obs_nee\nee_hourly_2012.csv');

   tmp = load('ems_mc_sample/mc_obs_res_2010.mat');
   mc_2010 = tmp.mc;
   tmp = load('ems_mc_sample/mc_obs_res_2011.mat');
   mc_2011 = tmp.mc;
   tmp = load('ems_mc_sample/mc_obs_res_2012.mat');
   mc_2012 = tmp.mc;
   clear tmp
   
   save('cache.mat')
end


sp = 0.015;
pd = 0.02;
mn = 0.03;

% years  = {2010,2011,2012};
% titles = {'Hourly Mean NEE Values', ...
%           'Hourly Mean NEE Values', ...
%           'Hourly Mean NEE Values', ...
%           'Hourly Mean NEE Values', ...
%           'Hourly Mean NEE Values', ...
%           'Hourly Mean NEE Values', ...
%           'Hourly Mean NEE Values', ...
%           'Hourly Mean NEE Values', ...
%           'Hourly Mean NEE Values', ...
%           };

%------------------------------------------------------------%
figure('Name','NEE Data and Unc Totals')
%------------------------------------------------------------%
subaxis(3,3.5,1,'S',sp,'P',pd,'M',mn)
plot(1:8760,[filled_2010'; obs_2010'],'.');
title('\bf{Hourly Mean NEE Values, 2010}')
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

subaxis(3,3.5,4.5)
plot(1:8760,[filled_2011'; obs_2011'],'.');
title('\bf{Hourly Mean NEE Values, 2011}')
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

subaxis(3,3.5,8)
plot(1:8784,[filled_2012'; obs_2012'],'.');
title('\bf{Hourly Mean NEE Values, 2012}')
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

%------------------------------------------------------------%
subaxis(3,3.5,2)
%plot(1:365,[fagg_2010.dmeans'; oagg_2010.dmeans'],'.');
plot(1:365,fagg_2010.dmeans','.');
hold on
errorbar(1:365,oagg_2010.dmeans',mc_2010.ds','.','Color',[0,0.48,0])
title('\bf{Daily Mean NEE Values, 2010}')
hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

subaxis(3,3.5,5.5)
%plot(1:365,[fagg_2011.dmeans'; oagg_2011.dmeans'],'.');
plot(1:365,fagg_2011.dmeans','.');
hold on
errorbar(1:365,oagg_2011.dmeans',mc_2011.ds','.','Color',[0,0.48,0])
title('\bf{Daily Mean NEE Values, 2011}')
hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

subaxis(3,3.5,9)
%plot(1:366,[fagg_2012.dmeans'; oagg_2012.dmeans'],'.');
plot(1:366,fagg_2012.dmeans','.');
hold on
errorbar(1:366,oagg_2012.dmeans',mc_2012.ds','.','Color',[0,0.48,0])
title('\bf{Daily Mean NEE Values, 2012}')
hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

%------------------------------------------------------------%
subaxis(3,3.5,3)
%plot(1:12,[fagg_2010.mmeans'; oagg_2010.mmeans'],'-.');
plot(1:12,fagg_2010.mmeans','-.');
hold on
errorbar(1:12,oagg_2010.mmeans',mc_2010.ms','-.','Color',[0,0.48,0])
title('\bf{Monthly Mean NEE Values, 2010}')
hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

subaxis(3,3.5,6.5)
%plot(1:12,[fagg_2011.mmeans'; oagg_2011.mmeans'],'-.');
plot(1:12,fagg_2011.mmeans','-.');
hold on
errorbar(1:12,oagg_2011.mmeans',mc_2011.ms','-.','Color',[0,0.48,0])
title('\bf{Monthly Mean NEE Values, 2011}')
hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

subaxis(3,3.5,10)
%plot(1:12,[fagg_2012.mmeans'; oagg_2012.mmeans'],'-.');
plot(1:12,fagg_2012.mmeans','-.');
hold on
errorbar(1:12,oagg_2012.mmeans',mc_2012.ms','-.','Color',[0,0.48,0])
title('\bf{Monthly Mean NEE Values, 2012}')
hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')


%------------------------------------------------------------%
subaxis(3,7,7)
%plot(1:12,[fagg_2010.mmeans'; oagg_2010.mmeans'],'-.');
%plot(1:12,fagg_2010.ymeans','-.');
%hold on
barwitherr([0;mc_2010.ys],[fagg_2010.ymeans;oagg_2010.ymeans])
%errorbar(1:2,oagg_2010.ymeans',mc_2010.ys','-.','Color',[0,0.48,0])
title('\bf{Yearly Mean NEE Values, 2010}')
%hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

%figure('Name','Monthly Means Comparison')
subaxis(3,7,14)
%plot(1:12,[fagg_2010.mmeans'; oagg_2010.mmeans'],'-.');
%plot(1:12,fagg_2010.ymeans','-.');
%hold on
barwitherr([0;mc_2011.ys],[fagg_2011.ymeans;oagg_2011.ymeans])
%errorbar(1:2,oagg_2010.ymeans',mc_2010.ys','-.','Color',[0,0.48,0])
title('\bf{Yearly Mean NEE Values, 2011}')
%hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

%figure('Name','Monthly Means Comparison')
subaxis(3,7,21)
%plot(1:12,[fagg_2010.mmeans'; oagg_2010.mmeans'],'-.');
%plot(1:12,fagg_2010.ymeans','-.');
%hold on
barwitherr([0;mc_2012.ys],[fagg_2012.ymeans;oagg_2012.ymeans])
%errorbar(1:2,oagg_2010.ymeans',mc_2010.ys','-.','Color',[0,0.48,0])
title('\bf{Yearly Mean NEE Values, 2012}')
%hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')
%------------------------------------------------------------%












%------------------------------------------------------------%
figure('Name','NEE Data and Unc Day')
%------------------------------------------------------------%
subaxis(3,3.5,1,'S',sp,'P',pd,'M',mn)
plot(1:8760,[fagg_2010.hourly_day'; oagg_2010.hourly_day'],'.');
title('\bf{Hourly Mean NEE Values, 2010}')
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

subaxis(3,3.5,4.5)
plot(1:8760,[fagg_2011.hourly_day'; oagg_2011.hourly_day'],'.');
title('\bf{Hourly Mean NEE Values, 2011}')
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

subaxis(3,3.5,8)
plot(1:8784,[fagg_2012.hourly_day'; oagg_2012.hourly_day'],'.');
title('\bf{Hourly Mean NEE Values, 2012}')
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

%------------------------------------------------------------%
subaxis(3,3.5,2)
%plot(1:365,[fagg_2010.dmeans'; oagg_2010.dmeans'],'.');
plot(1:365,fagg_2010.dmeans_day','.');
hold on
errorbar(1:365,oagg_2010.dmeans_day',mc_2010.ds_day','.','Color',[0,0.48,0])
title('\bf{Daily Mean NEE Values, 2010}')
hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

subaxis(3,3.5,5.5)
%plot(1:365,[fagg_2011.dmeans'; oagg_2011.dmeans'],'.');
plot(1:365,fagg_2011.dmeans_day','.');
hold on
errorbar(1:365,oagg_2011.dmeans_day',mc_2011.ds_day','.','Color',[0,0.48,0])
title('\bf{Daily Mean NEE Values, 2011}')
hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

subaxis(3,3.5,9)
%plot(1:366,[fagg_2012.dmeans'; oagg_2012.dmeans'],'.');
plot(1:366,fagg_2012.dmeans_day','.');
hold on
errorbar(1:366,oagg_2012.dmeans_day',mc_2012.ds_day','.','Color',[0,0.48,0])
title('\bf{Daily Mean NEE Values, 2012}')
hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

%------------------------------------------------------------%
subaxis(3,3.5,3)
%plot(1:12,[fagg_2010.mmeans'; oagg_2010.mmeans'],'-.');
plot(1:12,fagg_2010.mmeans_day','-.');
hold on
errorbar(1:12,oagg_2010.mmeans_day',mc_2010.ms_day','-.','Color',[0,0.48,0])
title('\bf{Monthly Mean NEE Values, 2010}')
hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

subaxis(3,3.5,6.5)
%plot(1:12,[fagg_2011.mmeans'; oagg_2011.mmeans'],'-.');
plot(1:12,fagg_2011.mmeans_day','-.');
hold on
errorbar(1:12,oagg_2011.mmeans_day',mc_2011.ms_day','-.','Color',[0,0.48,0])
title('\bf{Monthly Mean NEE Values, 2011}')
hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

subaxis(3,3.5,10)
%plot(1:12,[fagg_2012.mmeans'; oagg_2012.mmeans'],'-.');
plot(1:12,fagg_2012.mmeans_day','-.');
hold on
errorbar(1:12,oagg_2012.mmeans_day',mc_2012.ms_day','-.','Color',[0,0.48,0])
title('\bf{Monthly Mean NEE Values, 2012}')
hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')


%------------------------------------------------------------%
subaxis(3,7,7)
%plot(1:12,[fagg_2010.mmeans'; oagg_2010.mmeans'],'-.');
%plot(1:12,fagg_2010.ymeans','-.');
%hold on
barwitherr([0;mc_2010.ys_day],[fagg_2010.ymeans_day;oagg_2010.ymeans_day])
%errorbar(1:2,oagg_2010.ymeans',mc_2010.ys','-.','Color',[0,0.48,0])
title('\bf{Yearly Mean NEE Values, 2010}')
%hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

%figure('Name','Monthly Means Comparison')
subaxis(3,7,14)
%plot(1:12,[fagg_2010.mmeans'; oagg_2010.mmeans'],'-.');
%plot(1:12,fagg_2010.ymeans','-.');
%hold on
barwitherr([0;mc_2011.ys_day],[fagg_2011.ymeans_day;oagg_2011.ymeans_day])
%errorbar(1:2,oagg_2010.ymeans',mc_2010.ys','-.','Color',[0,0.48,0])
title('\bf{Yearly Mean NEE Values, 2011}')
%hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

%figure('Name','Monthly Means Comparison')
subaxis(3,7,21)
%plot(1:12,[fagg_2010.mmeans'; oagg_2010.mmeans'],'-.');
%plot(1:12,fagg_2010.ymeans','-.');
%hold on
barwitherr([0;mc_2012.ys_day],[fagg_2012.ymeans_day;oagg_2012.ymeans_day])
%errorbar(1:2,oagg_2010.ymeans',mc_2010.ys','-.','Color',[0,0.48,0])
title('\bf{Yearly Mean NEE Values, 2012}')
%hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')
%------------------------------------------------------------%








%------------------------------------------------------------%
figure('Name','NEE Data and Unc Night')
%------------------------------------------------------------%
subaxis(3,3.5,1,'S',sp,'P',pd,'M',mn)
plot(1:8760,[fagg_2010.hourly_night'; oagg_2010.hourly_night'],'.');
title('\bf{Hourly Mean NEE Values, 2010}')
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

subaxis(3,3.5,4.5)
plot(1:8760,[fagg_2011.hourly_night'; oagg_2011.hourly_night'],'.');
title('\bf{Hourly Mean NEE Values, 2011}')
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

subaxis(3,3.5,8)
plot(1:8784,[fagg_2012.hourly_night'; oagg_2012.hourly_night'],'.');
title('\bf{Hourly Mean NEE Values, 2012}')
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

%------------------------------------------------------------%
subaxis(3,3.5,2)
%plot(1:365,[fagg_2010.dmeans'; oagg_2010.dmeans'],'.');
plot(1:365,fagg_2010.dmeans_night','.');
hold on
errorbar(1:365,oagg_2010.dmeans_night',mc_2010.ds_night','.','Color',[0,0.48,0])
title('\bf{Daily Mean NEE Values, 2010}')
hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

subaxis(3,3.5,5.5)
%plot(1:365,[fagg_2011.dmeans'; oagg_2011.dmeans'],'.');
plot(1:365,fagg_2011.dmeans_night','.');
hold on
errorbar(1:365,oagg_2011.dmeans_night',mc_2011.ds_night','.','Color',[0,0.48,0])
title('\bf{Daily Mean NEE Values, 2011}')
hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

subaxis(3,3.5,9)
%plot(1:366,[fagg_2012.dmeans'; oagg_2012.dmeans'],'.');
plot(1:366,fagg_2012.dmeans_night','.');
hold on
errorbar(1:366,oagg_2012.dmeans_night',mc_2012.ds_night','.','Color',[0,0.48,0])
title('\bf{Daily Mean NEE Values, 2012}')
hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

%------------------------------------------------------------%
subaxis(3,3.5,3)
%plot(1:12,[fagg_2010.mmeans'; oagg_2010.mmeans'],'-.');
plot(1:12,fagg_2010.mmeans_night','-.');
hold on
errorbar(1:12,oagg_2010.mmeans_night',mc_2010.ms_night','-.','Color',[0,0.48,0])
title('\bf{Monthly Mean NEE Values, 2010}')
hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

subaxis(3,3.5,6.5)
%plot(1:12,[fagg_2011.mmeans'; oagg_2011.mmeans'],'-.');
plot(1:12,fagg_2011.mmeans_night','-.');
hold on
errorbar(1:12,oagg_2011.mmeans_night',mc_2011.ms_night','-.','Color',[0,0.48,0])
title('\bf{Monthly Mean NEE Values, 2011}')
hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

subaxis(3,3.5,10)
%plot(1:12,[fagg_2012.mmeans'; oagg_2012.mmeans'],'-.');
plot(1:12,fagg_2012.mmeans_night','-.');
hold on
errorbar(1:12,oagg_2012.mmeans_night',mc_2012.ms_night','-.','Color',[0,0.48,0])
title('\bf{Monthly Mean NEE Values, 2012}')
hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')


%------------------------------------------------------------%
subaxis(3,7,7)
%plot(1:12,[fagg_2010.mmeans'; oagg_2010.mmeans'],'-.');
%plot(1:12,fagg_2010.ymeans','-.');
%hold on
barwitherr([0;mc_2010.ys_night],[fagg_2010.ymeans_night;oagg_2010.ymeans_night])
%errorbar(1:2,oagg_2010.ymeans',mc_2010.ys','-.','Color',[0,0.48,0])
title('\bf{Yearly Mean NEE Values, 2010}')
%hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

%figure('Name','Monthly Means Comparison')
subaxis(3,7,14)
%plot(1:12,[fagg_2010.mmeans'; oagg_2010.mmeans'],'-.');
%plot(1:12,fagg_2010.ymeans','-.');
%hold on
barwitherr([0;mc_2011.ys_night],[fagg_2011.ymeans_night;oagg_2011.ymeans_night])
%errorbar(1:2,oagg_2010.ymeans',mc_2010.ys','-.','Color',[0,0.48,0])
title('\bf{Yearly Mean NEE Values, 2011}')
%hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')

%figure('Name','Monthly Means Comparison')
subaxis(3,7,21)
%plot(1:12,[fagg_2010.mmeans'; oagg_2010.mmeans'],'-.');
%plot(1:12,fagg_2010.ymeans','-.');
%hold on
barwitherr([0;mc_2012.ys_night],[fagg_2012.ymeans_night;oagg_2012.ymeans_night])
%errorbar(1:2,oagg_2010.ymeans',mc_2010.ys','-.','Color',[0,0.48,0])
title('\bf{Yearly Mean NEE Values, 2012}')
%hold off
legend({'Filled','Unfilled'})
ylabel('[kgC/m^2]')
%------------------------------------------------------------%






end

