function [ ] = write_aggs( data, years, obs_name, obs_units )
%WRITE_AGGS Summary of this function goes here
%   Detailed explanation goes here

% Strings for start & end dates.
start_time = [num2str(years(1))     '-01-01-00-00-00'];
end_time   = [num2str(years(end)+1) '-01-01-00-00-00'];

% Vectors of date components:
time.yr = fill_dates('Y',start_time,end_time,'000000','-mat');
time.mo = fill_dates('M',start_time,end_time,'000000','-mat');
time.dy = fill_dates('D',start_time,end_time,'000000','-mat');
time.hr = fill_dates('I',start_time,end_time,'010000','-mat');

time.yr = time.yr(:,1);
time.mo = time.mo(:,1:2);
time.dy = time.dy(:,1:3);
time.hr = time.hr(:,1:4);

% A 'real' header and a template for the column-headers for each file: 
head1      = ['"# ' obs_name ' is in ' obs_units '"\n'];
head2_base = [obs_name ', ' obs_name '_sd, ' obs_name '_Day, ' obs_name '_Day_sd, ' ...
              obs_name '_Night, ' obs_name '_Night_sd \n'];

time_flds = {'yr','mo','dy','hr'};
time_long = {'yearly','monthly','daily','hourly'};
data_flds = {'y','m','d','h'};
cols      = {'Year, ','Month, ','Day, ','Hour, '};

% This is saving the means not the actual aggregates... that's ok though for now.
for iyr = years   
   for ires = 1:4
      tfld = time_flds{ires};
      dfld = data_flds{ires};
      
      res  = time_long{ires};
      
      curr_yr_packed = [num2str(iyr)  ,'-01-01-00-00-00'];
      next_yr_packed = [num2str(iyr+1),'-01-01-00-00-00'];
      
      beg_ind = get_date_index(start_time,curr_yr_packed,res);
      end_ind = get_date_index(start_time,next_yr_packed,res);
      
      out_fname = [lower(obs_name) '_' res '_' num2str(iyr) '.csv'];
      out_data  = [time.(tfld)   , ...
                   data.([dfld ,'m'      ])   , ...
                   data.([dfld ,'s'      ])   , ...
                   data.([dfld ,'m_day'  ])   , ...
                   data.([dfld ,'s_day'  ])   , ...
                   data.([dfld ,'m_night'])   , ...
                   data.([dfld ,'s_night'])   , ...
                  ];

      out_data(isnan(out_data)) = -9999;
      out_data = out_data(beg_ind:(end_ind-1),:);    
      
      disp(['Writing ' out_fname '...'])
      head2  = [[cols{1:ires}] head2_base];
      write(out_fname, head1, head2, out_data);
   end
end

end


function [] = write(fname,head1,head2,data)
   header = [head1 head2];
   fid = fopen(fname,'wt');
   fprintf(fid,header);
   dlmwrite(fname,data,'delimiter',',','-append');
   fclose(fid);
end

