function [ filled_data ] = nanfill_data( data, res )
%NANFILL_DATA(data,res) Takes a data vector with associated dates and fills gaps at resolution
%'res' with nans.

% Get start and end times to compile a list of dates...
start_yr  = data(1  ,1);
end_yr    = data(end,1);
start_mo  = data(1  ,2);
end_mo    = data(end,2);
start_day = 1;
end_day   = 1;
start_hr  = 0;
end_hr    = 0;
inc       = '000000';

if strcmp(res,'daily');
   start_day = data(1  ,3);
   end_day   = data(end,3);
   if strcmp(res,'hourly')
      start_hr = data(1  ,4);
      end_hr   = data(end,4);
      inc      = '010000';
   end
end

% Pack the times into strings to use with the date tool...
start = pack_time(start_yr,start_mo,start_day,start_hr,0,0);
fin   = pack_time(end_yr  ,end_mo  ,end_day  ,end_hr  ,0,0);

% Get the list of dates and initialized a matrix for the filled data.
date_list = fill_dates(res,start,fin,inc,'-mat');
nan_data  = NaN(length(date_list),size(data,2));

% Cycle through the rows of 'filled_data' and insert the data we actually have if possible.
for idate = 1:numel(date_list)
   yr  = date_list(1);
   mo  = date_list(2);
   day = date_list(3);
   hr  = date_list(4);
   
   ths_yr_data  = data(data(:,1) == yr,2:end);
   ths_mo_data  = ths_yr_data(ths_yr_data(:,1)   == mo ,2:end);
   ths_day_data = ths_mo_data(ths_mo_data(:,1)   == day,2:end);
   ths_hr_data  = ths_day_data(ths_day_data(:,1) == hr,2:end);

   nan_data(idate,1:4) = [yr,mo,day,hr];
   if ~isempty(ths_hr_data)
         nan_data(idate,5:end) = ths_hr_data;
   end
end


end

