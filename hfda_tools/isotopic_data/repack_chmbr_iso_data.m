function [ ] = repack_chmbr_iso_data(show)
%REPACK_CHMBR_ISO_DATA Summary of this function goes here
%   Detailed explanation goes here

filename  = ['C:\Users\Dan\Moorcroft_Lab\data\' ...
             'harvard forest archive\HF-SoilPlotIsotopeFluxResults_Safe_Chars.csv'];
seperator = ',';
fix_flg   = 0;

data = read_cols_to_flds(filename,seperator,fix_flg);


%PROC_ISODATA Transforms the isotope data into a hourly dataset for use with optimizer.
%  
%  The data input is full of gaps and is on a 40-minute sampling freq. With the optimization
%     framework we use fast-freq ED output of hourly means, so we want to get estimates of
%     these hourly means from the data for comparison. To do this, we'll interpolate to the half
%     hour mark whenever we're not on a gap boundary, in which case we'll just use the value
%     we're given for whatever time in that hour as the hourly ave.

%----------------------------------------------------------------------------------------------%
% Get start and end dates and create a NaN matrix with entries for every hour between them,
% inclusive of the last.
%----------------------------------------------------------------------------------------------%
beg_str = pack_time(data.YYYY(1)    ,1 ,1 ,1 ,0,0,'std');
end_str = pack_time(data.YYYY(end)+1,1 ,1 ,1 ,0,0,'std');
%nhrs    = get_date_index(beg_str,end_str,'hourly') - 1;        % (sr is endpoint inclusive)
nday    = get_date_index(beg_str,end_str,'daily')  - 1;        % (sr is endpoint inclusive)

d13C     = NaN(nday,1);
d13C_err = NaN(nday,1);
% CO2      = NaN(nhrs,1);
% CO2_err  = NaN(nhrs,1);

year      = NaN(nday,1);
month     = NaN(nday,1);
day       = NaN(nday,1);
%hour     = NaN(nhrs,1);

no_dat    = data.Del13_Control == -9999;

data.Del13_Control = data.Del13_Control(~no_dat);
data.YYYY = data.YYYY(~no_dat);
data.MO   = data.MO(~no_dat);
data.DD   = data.DD(~no_dat);

diel_nobs = zeros(24,1);
day_nobs  = zeros(nday,1);
ndata     = size(data.YYYY,1);
%----------------------------------------------------------------------------------------------%





%----------------------------------------------------------------------------------------------%
% Aggregate data                                                                               %
%----------------------------------------------------------------------------------------------%
agg     = 0;
agg_err = 0;

for idata = 1:ndata
   itime = pack_time(data.YYYY(idata),data.MO(idata),...       % Time of datum
           data.DD(idata),0,0,0,'std');                        % ...
   index = get_date_index(beg_str,itime,'daily')+2;            % Index for datum in 'temp'

   new_day = idata ~=1 && index ~= old_index;                  % Is this a new day?
   if new_day                                                  % If so, save yesterday's data
      d13C(old_index)     = agg    /day_nobs(old_index);
      d13C_err(old_index) = agg_err/day_nobs(old_index);
      
      agg     = 0;
      agg_err = 0;
   end
   
   hour = data.HH(idata) + 1;                                  % Converting from 0-23 -> 1-24
   
   diel_nobs(hour) = diel_nobs(hour) + 1;                      % Increment diel obs counter
   day_nobs(index) = day_nobs(index) + 1;                      % Increment obs-per-day counter
   
   agg     = agg     + data.Del13_Control(idata);
   agg_err = agg_err + 0.5;                                    % This is a VERY ~ error estimate
   
   old_index = index;                                          % Save the index for next loop
end
%----------------------------------------------------------------------------------------------%

%----------------------------------------------------------------------------------------------%
% Create year, month, day, hour fields for times without data.                                 %
%----------------------------------------------------------------------------------------------%
days  = [];
mos   = [];

mo_days = reshape(yrfrac(1:12,2012:2013,'-days')',24,1);
yrs     = [repmat(2012,nday/2-0.5,1); repmat(2013,nday/2+0.5,1)];

for imo = 1:24
   mos   = [mos  ; repmat(mod(imo-1,12)+1,mo_days(imo),1)];
   days  = [days ; reshape(repmat(1:mo_days(imo),1,1),mo_days(imo),1)];
end

dates = [yrs,mos,days];
%----------------------------------------------------------------------------------------------%


%----------------------------------------------------------------------------------------------%
% Pack data for export.                                                                        %
%----------------------------------------------------------------------------------------------%
dy_data = [dates,d13C,d13C_err];

if show
   figure();
   set(gcf,'Name','daily means')
   errorbar(1:731,dy_data(:,4),dy_data(:,5),'or')

   figure();
   set(gcf,'Name','number of obs per day')
   plot(1:731,day_nobs,'ob')

   figure();
   set(gcf,'Name','diel histogram')
   bar(1:24,diel_nobs,'m')
end

dy_data(isnan(dy_data)) = -9999;
%----------------------------------------------------------------------------------------------%


%----------------------------------------------------------------------------------------------%
% Export Data                                                                                  %
%----------------------------------------------------------------------------------------------%
header_line_1 = ['"# Soil Respiration d13C [permilVPDB]"\n'];

header_line_2 = ['Year, Month, Day, SR_d13C, SR_d13C_sd \n'];
              
fid = fopen('chmbr_isoflux.csv','wt');
fprintf(fid,header_line_1);
fprintf(fid,header_line_2);
dlmwrite('chmbr_isoflux.csv',dy_data,'delimiter',',','-append');
fclose(fid);
%----------------------------------------------------------------------------------------------%


end

