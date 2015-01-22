function [ filled_data ] = preproc_iso_data( )
%PROCESS_RDATA Summary of this function goes here
%   Detailed explanation goes here

% Load the isotopic data into matlab.
if ~exist('iso_data.mat')
   raw  = readtext('C:\Users\Dan\Moorcroft Lab\Data\Harvard Forest Archive\HF-FluxesEtc.tsv','\s');
else
   load('iso_data.mat')
end

data = cell2mat(raw(4:end,3:end));

nrows = size(data,1);
times = zeros(nrows,3);

whole_days = [];
whole_data = [];

count      = 0;
last_day   = times(1,3);

for i = 1:nrows
   datestr   = raw{2+i,1};
   times(i,1) = str2double(datestr(7:10));
   times(i,2) = str2double(datestr(4:5));
   times(i,3) = str2double(datestr(1:2));
   
   if times(i,3) ~= last_day;
      % Then it's a new day! See if we should save the last one.
      if count >= 32 % This is 75% of 36...
         last_data  = sum(data(i-count:i-1,:),1)/count;
         %whole_days = [whole_days; times(i-1,:), count/36];
         whole_data = [whole_data; times(i,:), last_data];
      end
      count = 0;
   end

   last_day = times(i,3);
   count = count + 1;
end

filled_data = fill_daily_data(whole_data);
save('iso_data.mat');

end