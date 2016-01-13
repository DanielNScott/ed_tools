function [ ] = comp_nee_dsets()
%comp_nee_dsets Compares filled, unfilled, and monte-carlo resampled NEE data.

clc;
close all;

if exist('comp_cache.mat','file')
   disp('Loading Cache Data...')
   load comp_cache.mat

else
   %--------------------------------%
   % Load Hourly Data:
   %--------------------------------%
   disp('Loading Rick Data...')
   rick_dat = read_cols_to_flds('C:\Users\Dan\moorcroft_lab\data_matlab\rick\hr_data_iso.csv',',',0,0);

   rick{1} = [];
   rick{2} = rick_dat.NEE(rick_dat.Year == 2011);
   rick{3} = rick_dat.NEE(rick_dat.Year == 2012);

   disp('Loading Filled Data...')
   fill{1} = csvread('C:\Users\Dan\Moorcroft_Lab\data_observed\USHa_MC\raw\filled_nee_2010.csv');
   fill{2} = csvread('C:\Users\Dan\Moorcroft_Lab\data_observed\USHa_MC\raw\filled_nee_2011.csv');
   fill{3} = csvread('C:\Users\Dan\Moorcroft_Lab\data_observed\USHa_MC\raw\filled_nee_2012.csv');
   fill{3} = [fill{3}; NaN(24,1)];

   disp('Loading Unfilled Data...')
   obs    = csvread('C:\Users\Dan\Moorcroft_Lab\data_observed\USHa_MC\raw\hf004-02-obs-nee.csv',1,0);
   unf{1} = obs(obs(:,1) == 2010,2);
   unf{2} = obs(obs(:,1) == 2011,2);
   unf{3} = obs(obs(:,1) == 2012,2);

   clear rick_dat;
   clear obs;

   %--------------------------------%
   % Substitute NaNs for -9999
   %--------------------------------%
   disp('Substituting NaNs...')
   rick{1}(rick{1} == -9999) = NaN;
   rick{2}(rick{2} == -9999) = NaN;
   rick{3}(rick{3} == -9999) = NaN;

   fill{1}(fill{1} == -9999) = NaN;
   fill{2}(fill{2} == -9999) = NaN;
   fill{3}(fill{3} == -9999) = NaN;

   unf{1}(unf{1} == -9999) = NaN;
   unf{2}(unf{2} == -9999) = NaN;
   unf{3}(unf{3} == -9999) = NaN;

   %--------------------------------%
   % Aggregate Data
   %--------------------------------%
   disp('Aggregating Filled Data...')
   fagg{1} = aggregate_data(fill{1},'2010-01-01-00-00-00','2011-01-01-00-00-00','ave');
   fagg{2} = aggregate_data(fill{2},'2011-01-01-00-00-00','2012-01-01-00-00-00','ave');
   fagg{3} = aggregate_data(fill{3},'2012-01-01-00-00-00','2013-01-01-00-00-00','ave');

   disp('Aggregating Unfilled Data...')
   uagg{1} = aggregate_data(unf{1},'2010-01-01-00-00-00','2011-01-01-00-00-00','ave');
   uagg{2} = aggregate_data(unf{2},'2011-01-01-00-00-00','2012-01-01-00-00-00','ave');
   uagg{3} = aggregate_data(unf{3},'2012-01-01-00-00-00','2013-01-01-00-00-00','ave');

   disp('Aggregating Rick Data...')
   ragg{1} = struct();
   ragg{2} = aggregate_data(rick{2},'2011-01-01-00-00-00','2012-01-01-00-00-00','ave');
   ragg{3} = aggregate_data(rick{3},'2012-01-01-00-00-00','2013-01-01-00-00-00','ave');
   
   ragg{1}.dmeans = [];
   ragg{1}.mmeans = [];
   ragg{1}.ymeans = [];

   %--------------------------------%
   % Create masks of common hours.
   %--------------------------------%
   disp('Creating Common Hour Masks...')
   min_msk{1} = ~(isnan(fill{1}) + isnan(unf{1})                  );
   min_msk{2} = ~(isnan(fill{2}) + isnan(unf{2}) + isnan(rick{2}) );
   min_msk{3} = ~(isnan(fill{3}) + isnan(unf{3}) + isnan(rick{3}) );

   %--------------------------------%
   % Mask the data sets.
   %--------------------------------%
   disp('Masking Data...')
   rm{1} = rick{1};
   rm{2} = rick{2};
   rm{3} = rick{3};
   
   rm{2}(~min_msk{2}) = NaN;
   rm{3}(~min_msk{3}) = NaN;
   
   fm{1} = fill{1};
   fm{2} = fill{2};
   fm{3} = fill{3};
   
   fm{1}(~min_msk{1}) = NaN;
   fm{2}(~min_msk{2}) = NaN;
   fm{3}(~min_msk{3}) = NaN;
   
   um{1} = unf{1};
   um{2} = unf{2};
   um{3} = unf{3};
   
   um{1}(~min_msk{1}) = NaN;
   um{2}(~min_msk{2}) = NaN;
   um{3}(~min_msk{3}) = NaN;
   
   %--------------------------------%
   % Aggregate the masked data.
   %--------------------------------%
   disp('Aggregating Masked Filled Data...')
   fmagg{1} = aggregate_data(fm{1},'2010-01-01-00-00-00','2011-01-01-00-00-00','ave');
   fmagg{2} = aggregate_data(fm{2},'2011-01-01-00-00-00','2012-01-01-00-00-00','ave');
   fmagg{3} = aggregate_data(fm{3},'2012-01-01-00-00-00','2013-01-01-00-00-00','ave');

   disp('Aggregating Masked Unfilled Data...')
   umagg{1} = aggregate_data(um{1},'2010-01-01-00-00-00','2011-01-01-00-00-00','ave');
   umagg{2} = aggregate_data(um{2},'2011-01-01-00-00-00','2012-01-01-00-00-00','ave');
   umagg{3} = aggregate_data(um{3},'2012-01-01-00-00-00','2013-01-01-00-00-00','ave');

   disp('Aggregating Masked Rick Data...')
   rmagg{1} = struct();
   rmagg{2} = aggregate_data(rm{2},'2011-01-01-00-00-00','2012-01-01-00-00-00','ave');
   rmagg{3} = aggregate_data(rm{3},'2012-01-01-00-00-00','2013-01-01-00-00-00','ave');
   
   rmagg{1}.dmeans = [];
   rmagg{1}.dmeans_day = [];
   rmagg{1}.dmeans_night = [];
   rmagg{1}.mmeans = [];
   rmagg{1}.mmeans_day = [];
   rmagg{1}.mmeans_night = [];
   rmagg{1}.ymeans = [];
   rmagg{1}.ymeans_day = [];
   rmagg{1}.ymeans_night = [];
   
   disp('Saving comp_cache.mat')
   save('comp_cache.mat')
end

% Compute statistics...
% R^2 = 1 - (SSres/SStot)
% SSres = Sum(Residual^2) = Sum( (ypred - ydata    )^2 )
% SStot = Sum(Total^2)    = Sum( (ydata - ydatamean)^2 )

disp('Plotting...')
sp = 0.015;
pd = 0.02;
mn = 0.03;

gen_new_fig('NEE Data and Unc Totals')
lgnd = {{'Filled','Unfilled'}       , ...
        {'Filled','Unfilled','Rick'}, ...
        {'Filled','Unfilled','Rick'} };
      
year_list = {'2010','2011','2012'};
res_list  = {'Hourly','Daily','Monthly','Yearly'};
      
for irow = 1:3
   add  = 4*(irow-1) - 0.5*(irow-1);
   rend = 7*irow;

   nhrs    = length(fill{irow});
   ndays   = length(fagg{irow}.dmeans);
   nmonths = length(fagg{irow}.mmeans);

   % HOURLY
   subaxis(3,3.5,1+add,'S',sp,'P',pd,'M',mn)
   plot(1:nhrs,[fill{irow}'; unf{irow}'; rick{irow}'],'.');
   title(['\bf{' res_list{1} ' Mean NEE Values, ' year_list{irow} '}'])
   legend(lgnd{irow})
   ylabel('[kgC/m^2]')

   % DAILY
   subaxis(3,3.5,2+add)
   plot(1:ndays,[fagg{irow}.dmeans'; uagg{irow}.dmeans'; ragg{irow}.dmeans'],'.');
   legend(lgnd{irow})
   title(['\bf{' res_list{2} ' Mean NEE Values, ' year_list{irow} '}'])
   ylabel('[kgC/m^2]')

   % MONTHLY
   subaxis(3,3.5,3+add)
   plot(1:nmonths,[fagg{irow}.mmeans'; uagg{irow}.mmeans'; ragg{irow}.mmeans'],'-o');
   legend(lgnd{irow})
   title(['\bf{' res_list{3} ' Mean NEE Values, ' year_list{irow} '}'])
   ylabel('[kgC/m^2]')

   % YEARLY
   subaxis(3,7,rend)
   bar([fagg{irow}.ymeans,uagg{irow}.ymeans,ragg{irow}.ymeans]')
   legend(lgnd{irow})
   title(['\bf{' res_list{4} ' Mean NEE Values, ' year_list{irow} '}'])
   ylabel('[kgC/m^2]')
end

gen_new_fig('NEE Data and Unc Totals')
for irow = 1:3
   add  = 4*(irow-1) - 0.5*(irow-1);
   rend = 7*irow;

   nhrs    = length(fill{irow});
   ndays   = length(fmagg{irow}.dmeans);
   nmonths = length(fmagg{irow}.mmeans);

   % HOURLY
   subaxis(3,3.5,1+add,'S',sp,'P',pd,'M',mn)
   plot(1:nhrs,[fm{irow}'; um{irow}'; rm{irow}'],'.');
   title(['\bf{' res_list{1} ' Mean NEE Values, ' year_list{irow} '}'])
   legend(lgnd{irow})
   ylabel('[kgC/m^2]')

   % DAILY
   subaxis(3,3.5,2+add)
   plot(1:ndays,[fmagg{irow}.dmeans'; umagg{irow}.dmeans'; rmagg{irow}.dmeans'],'.');
   legend(lgnd{irow})
   title(['\bf{' res_list{2} ' Mean NEE Values, ' year_list{irow} '}'])
   ylabel('[kgC/m^2]')

   % MONTHLY
   subaxis(3,3.5,3+add)
   plot(1:nmonths,[fmagg{irow}.mmeans'; umagg{irow}.mmeans'; rmagg{irow}.mmeans'],'-o');
   legend(lgnd{irow})
   title(['\bf{' res_list{3} ' Mean NEE Values, ' year_list{irow} '}'])
   ylabel('[kgC/m^2]')

   % YEARLY
   subaxis(3,7,rend)
   bar([fmagg{irow}.ymeans,umagg{irow}.ymeans,rmagg{irow}.ymeans]')
   title('\bf{Yearly Mean NEE Values, 2010}')
   legend(lgnd{irow})
   title(['\bf{' res_list{4} ' Mean NEE Values, ' year_list{irow} '}'])
   ylabel('[kgC/m^2]')
end



   rmagg{1}.hourly_day = [];
   rmagg{1}.hourly_night = [];
   rmagg{1}.dmeans = [];
   rmagg{1}.dmeans_day = [];
   rmagg{1}.dmeans_night = [];
   rmagg{1}.mmeans = [];
   rmagg{1}.mmeans_day = [];
   rmagg{1}.mmeans_night = [];
   rmagg{1}.ymeans = [];
   rmagg{1}.ymeans_day = [];
   rmagg{1}.ymeans_night = [];









gen_new_fig('NEE Data and Unc Totals')
for irow = 1:3
   add  = 4*(irow-1) - 0.5*(irow-1);
   rend = 7*irow;

   nhrs    = length(fill{irow});
   ndays   = length(fmagg{irow}.dmeans);
   nmonths = length(fmagg{irow}.mmeans);

   % HOURLY
   subaxis(3,3.5,1+add,'S',sp,'P',pd,'M',mn)
   plot(1:nhrs,[fmagg{irow}.hourly_day'; umagg{irow}.hourly_day'; rmagg{irow}.hourly_day'],'.');
   title(['\bf{' res_list{1} ' Mean NEE Values, ' year_list{irow} '}'])
   legend(lgnd{irow})
   ylabel('[kgC/m^2]')

   % DAILY
   subaxis(3,3.5,2+add)
   plot(1:ndays,[fmagg{irow}.dmeans_day'; umagg{irow}.dmeans_day'; rmagg{irow}.dmeans_day'],'.');
   legend(lgnd{irow})
   title(['\bf{' res_list{2} ' Mean NEE Values, ' year_list{irow} '}'])
   ylabel('[kgC/m^2]')

   % MONTHLY
   subaxis(3,3.5,3+add)
   plot(1:nmonths,[fmagg{irow}.mmeans_day'; umagg{irow}.mmeans_day'; rmagg{irow}.mmeans_day'],'-o');
   legend(lgnd{irow})
   title(['\bf{' res_list{3} ' Mean NEE Values, ' year_list{irow} '}'])
   ylabel('[kgC/m^2]')

   % YEARLY
   subaxis(3,7,rend)
   bar([fmagg{irow}.ymeans_day,umagg{irow}.ymeans_day,rmagg{irow}.ymeans_day]')
   title('\bf{Yearly Mean NEE Values, 2010}')
   legend(lgnd{irow})
   title(['\bf{' res_list{4} ' Mean NEE Values, ' year_list{irow} '}'])
   ylabel('[kgC/m^2]')
end

gen_new_fig('NEE Data and Unc Totals')
for irow = 1:3
   add  = 4*(irow-1) - 0.5*(irow-1);
   rend = 7*irow;

   nhrs    = length(fill{irow});
   ndays   = length(fmagg{irow}.dmeans);
   nmonths = length(fmagg{irow}.mmeans);

   % HOURLY
   subaxis(3,3.5,1+add,'S',sp,'P',pd,'M',mn)
   plot(1:nhrs,[fmagg{irow}.hourly_night'; umagg{irow}.hourly_night'; rmagg{irow}.hourly_night'],'.');
   title(['\bf{' res_list{1} ' Mean NEE Values, ' year_list{irow} '}'])
   legend(lgnd{irow})
   ylabel('[kgC/m^2]')

   % DAILY
   subaxis(3,3.5,2+add)
   plot(1:ndays,[fmagg{irow}.dmeans_night'; umagg{irow}.dmeans_night'; rmagg{irow}.dmeans_night'],'.');
   legend(lgnd{irow})
   title(['\bf{' res_list{2} ' Mean NEE Values, ' year_list{irow} '}'])
   ylabel('[kgC/m^2]')

   % MONTHLY
   subaxis(3,3.5,3+add)
   plot(1:nmonths,[fmagg{irow}.mmeans_night'; umagg{irow}.mmeans_night'; rmagg{irow}.mmeans_night'],'-o');
   legend(lgnd{irow})
   title(['\bf{' res_list{3} ' Mean NEE Values, ' year_list{irow} '}'])
   ylabel('[kgC/m^2]')

   % YEARLY
   subaxis(3,7,rend)
   bar([fmagg{irow}.ymeans_night,umagg{irow}.ymeans_night,rmagg{irow}.ymeans_night]')
   title('\bf{Yearly Mean NEE Values, 2010}')
   legend(lgnd{irow})
   title(['\bf{' res_list{4} ' Mean NEE Values, ' year_list{irow} '}'])
   ylabel('[kgC/m^2]')
end




end