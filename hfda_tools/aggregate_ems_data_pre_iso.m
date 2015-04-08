function[ ] = aggregate_ems_data()
%AGGREGATE_EMS_DATA Reads the two flux csv files (identified below) from HF data archive and
%aggregates them into formats meaningful to ED2.1 and optimize_ed.m
%   The files read should be specified below as 'somepath/hf004-02-filled.csv' (fluxes) and 
%   'somepath/hf004-02-final.csv'
%
% The structure of this file:
% 1) Read in a csv created from hf004-01-final.csv and hf004-02-filled.csv...
%    For example, the csv to be read should like this below... (but without spaces)
%
% Year, month, DoY, Hour, nee_e6mol/m2/s, sqrt(2*beta), FH2O_e.3mol.m2.s, sqrt(2*beta), CO2_ppb
% 1992,     1,   1,    0,           0.67,        0.335,            -9999,        -9999,   -9999
% 1992,     1,   1,    1,           0.49,        0.245,            -9999,        -9999,   -9999
% ...
% 2010,    12, 365,   23,           6.72,         3.36,            -9999,        -9999,   -9999
%
% 2) Convert NEE from umol/m2/s --> tC/ha and LH from kmol/m^2/s to W/m^2
%    - Conversion factors and useful quantities are calculated then applied
%
% 3) Initialize a bunch matrices to hold processed data
% 4) Cycle through years, months, and days to extract NEE and aggregate
% 5) Trim NaN's from matrix ends and...
% 6) Export data

%----------------------------------------------------------------------------------------------%
% Read in data and initialize a bunch of stuff
%----------------------------------------------------------------------------------------------%
base_path     = 'C:\Users\Dan\Moorcroft Lab\Data\Harvard Forest Archive\';
data_fname    = [base_path 'flux_stats_filled+edited.csv'];

data     = csvread(data_fname,1,0);             % Read EMS flux data from file
yr_start = data(1  ,1);                         % Get first year in data
yr_end   = data(end,1);                         % Get last year in data
years    = yr_start:yr_end;                     % Save list of years...
nyrs     = yr_end - yr_start + 1;               % ... and number of them.

amb_co2  = data(:,end);                         % Extract ambient CO2 Data
data     = data(:,1:end-1);                     % Remove it from further consideration.

                                                % Set two NEE conversions (parens in comment)
fact_1 = 1/10^6 * 44.0095 * 0.272892;           % g/m2/s = umol/m2/s *(mol/umol *g/mol *gC/gCO2)
fact_2 = 3600 * 10^4 * 1/10^6;                  % tC/ha  = g/m2/s    *(s/hr * m2/ha * tonne/g)
data(:,5:6) = data(:,5:6) *fact_1 *fact_2;      % ... and convert NEE, umol/m2/s -> tC/ha

                                                % Set a latent heat conv. (parens in comment)
fact_1 = 1/10^3 * 18.015 * 2.260;               % W/m2 = mmol/m2/s * (mol/mmol * g/mol * J/g)
msk    = ~(data(:,7) == -9999);                 % set mask to ignore -9999 i.e. missing vals.
data(msk,7:8) = data(msk,7:8) *fact_1;          % ... and convert LH, kmol/m2/s -> W/m2

data        = [data, NaN(length(data),4)];      % Append columns for daily, and nightly NEE. 

dmeans = NaN(nyrs*366,5);                       % Initialize daily   means matrix
mmeans = NaN(nyrs*12 ,4);                       % Initialize monthly means matrix
ymeans = NaN(nyrs    ,3);                       % Initialize yearly  means matrix
dcnt   = 1;                                     % Initialize day   counter
mcnt   = 1;                                     % Initialize month counter

% Urbanski et. al. yearly uncertainties, from 1992-2004
unc = [0.375, 0.466, 0.304, 0.360, 0.388, 0.372, ... 
       0.532, 0.481, 0.321, 0.519, 0.478, 0.349, 0.439]';

% Monthly night time hours mask
mnhrs = get_night_hours(1:12);


%----------------------------------------------------------------------------------------------%
% Now start aggregating year/month/daily means.
%----------------------------------------------------------------------------------------------%
for yr_num = 1:nyrs
   yr     = years(yr_num);                         % Get the current year
   yr_dat = data(data(:,1) == yr,:);               % Mask out this year's data.
   ymean  = sum(yr_dat(:,5));                      % Get total yearly flux
   
   if yr < 2005
      yunc = unc(yr_num);                          % Get yearly uncertainty; If we have info use
   else                                            % it, otherwise use the average proportional
      yunc = 0.2*ymean;                            % uncertainty multiplied by the yearly NEE.
   end
   
   ymeans(yr_num,:) = [yr, ymean, yunc];           % Save to the pre-allocated matrix.

   yr_days = 365 + is_leap_year(yr)*1;             % Get the number of days in this year
   mo_days = yrfrac(1:12,yr)*yr_days;              % Get the number of days in each month
   
   for imo = yr_dat(1,2):yr_dat(end,2)
      mo_dat = yr_dat(yr_dat(:,2) == imo,:);       % Mask out this months data
      mmean          = sum(mo_dat(:,5));           % Sum to get total monthly flux
      munc           = yunc/12;                    % Assume all months contr. = to yrly unc
      mmeans(mcnt,:) = [yr, imo, mmean, munc];     % Save to the pre-allocated matrix.
      mcnt = mcnt + 1;                             % Increment counter
      
      for id = mo_dat(1,3):mo_dat(end,3)           % The 'd' in 'id' is actually day of year
         dom = id - sum(mo_days(1:imo-1));         % Get the day of the month this is.
         
         d_dat = mo_dat(mo_dat(:,3) == id,:);      % Extract this day's data,
         dmean          = sum(d_dat(:,5));         % Sum to get total daily flux
         dunc           = munc/mo_days(imo);       % Assume all days contr. = to monthly unc
         dmeans(dcnt,:) = [yr,imo,dom,dmean,dunc]; % Save to the pre-allocated matrix.
         
         ind1 = (dcnt-1)*24 + 1;                   % Get lower index in data of this day
         ind2 = (dcnt  )*23 + dcnt;                % Get upper index in data of this day
         data(ind1:ind2,3) = repmat(dom,24,1);     % Change data DOY -> DOM
         hr_dat = data(ind1:ind2,[5:6,9:12]);      % Extract hourly NEE from day for processing.
         
         nmsk = logical(mnhrs(imo,:)');            % Create a mask for night hours
         hr_dat( nmsk,3:4) = hr_dat( nmsk,1:2);    % Set NEE_Night and NEE_Night_sd
         hr_dat(~nmsk,5:6) = hr_dat(~nmsk,1:2);    % Set NEE_Day   and NEE_Day_sd
         hr_dat(isnan(hr_dat)) = -9999;            % Turn NaN's into -9999s for output
         
         data(ind1:ind2,5:6  ) = hr_dat(:,1:2);    % Xfer NEE back to 'data'
         data(ind1:ind2,9:10 ) = hr_dat(:,3:4);    % Xfer NEE_Night back to 'data'
         data(ind1:ind2,11:12) = hr_dat(:,5:6);    % Xfer NEE_Day back to 'data'
         
         dcnt = dcnt + 1;                          % Increment day counter
      end
   end
end

%----------------------------------------------------------------------------------------------%
% Aggregating is done, trim NaN's off the end.
%----------------------------------------------------------------------------------------------%
num_d_nans = sum(isnan(dmeans(:,1)));
num_m_nans = sum(isnan(mmeans(:,1)));
num_y_nans = sum(isnan(ymeans(:,1)));
dmeans = dmeans(1:end-num_d_nans,:);
mmeans = mmeans(1:end-num_m_nans,:);
ymeans = ymeans(1:end-num_y_nans,:);


%----------------------------------------------------------------------------------------------%
% Write CSVs with data in format for optimize_ed
%----------------------------------------------------------------------------------------------%
fid = fopen('./hourly_flux_stats_filled.csv','wt');
fprintf(fid,'"# NEE is in tC/ha"\n');
header = ['Year, Month, Day, Hour, NEE, NEE_sd, Latent, Latent_sd, NEE_Night, NEE_Night_sd,' ...
         ' NEE_Day, NEE_Day_sd\n'];
fprintf(fid,header);
dlmwrite('hourly_flux_stats_filled.csv' ,data,'delimiter',',','-append');
fclose(fid);

fid = fopen('./daily_flux_stats_filled.csv','wt');
fprintf(fid,'"# NEE is in tC/ha"\n');
fprintf(fid,'Year, Month, Day, NEE, NEE_sd\n');
dlmwrite('daily_flux_stats_filled.csv' ,dmeans,'delimiter',',','-append');
fclose(fid);

fid = fopen('./monthly_flux_stats_filled.csv','wt');
fprintf(fid,'"# NEE is in tC/ha"\n');
fprintf(fid,'Year, Month, NEE, NEE_sd\n');
dlmwrite('monthly_flux_stats_filled.csv' ,mmeans,'delimiter',',','-append');
fclose(fid);

fid = fopen('./yearly_flux_stats_filled.csv','wt');
fprintf(fid,'"# NEE is in tC/ha"\n');
fprintf(fid,'Year, NEE, NEE_sd\n');
dlmwrite('yearly_flux_stats_filled.csv' ,ymeans,'delimiter',',','-append');
fclose(fid);


%----------------------------------------------------------------------------------------------%
% Write HDF5 files for ambient CO2 concentrations.
%----------------------------------------------------------------------------------------------%



end
