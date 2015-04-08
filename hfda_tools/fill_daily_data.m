function [ filled_data ] = fill_daily_data( data )
%FILL_DAYS Summary of this function goes here
%   Detailed explanation goes here

% Get start and end times to compile a list of dates...
start_yr  = data(1  ,1);
start_mo  = data(1  ,2);
start_day = data(1  ,3);
end_yr    = data(end,1);
end_mo    = data(end,2);
end_day   = data(end,3);

% Pack the times into strings to use with the date tool...
start = pack_time(0,0,0,start_day,start_mo,start_yr);
fin   = pack_time(0,0,0,end_day  ,end_mo  ,end_yr  );

% Get the list of dates and initialized a matrix for the filled data.
date_list   = fill_dates('D',start,fin,'')';
filled_data = NaN(length(date_list),size(data,2));

% Cycle through the rows of 'filled_data' and insert the data we actually have if possible.
for idate = 1:numel(date_list)
   [yr,mo,day,~,~,~] = tokenize_time(date_list{idate},'std','num');
   
   ths_yr_data  = data(data(:,1) == yr,2:end);
   ths_mo_data  = ths_yr_data(ths_yr_data(:,1) == mo ,2:end);
   ths_day_data = ths_mo_data(ths_mo_data(:,1) == day,2:end);

   filled_data(idate,1:3) = [yr,mo,day];
   if ~isempty(ths_day_data)
         filled_data(idate,4:end) = ths_day_data;
   end
end


end

