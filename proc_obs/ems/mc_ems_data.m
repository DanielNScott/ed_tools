function [ out ] = mc_ems_data( data, sds, nsamples, start_date, end_date, dist )
%MCMC_EMS_DATA Summary of this function goes here
%   Detailed explanation goes here

if strcmp(dist,'laprnd')
   samples = laprnd(data,sds,nsamples);
elseif strcmp(dist,'normrnd')
   samples = nan(length(data),nsamples);
   for i = 1:nsamples
      samples(:,i) = normrnd(data,sds);
   end
else
   error('Please specify a distribution, either normrnd or laprnd.')
end

aggs = aggregate_data(samples,start_date,end_date,'ave');

out.ym       = nanmean(aggs.ymeans      ,2);
out.ym_day   = nanmean(aggs.ymeans_day  ,2);
out.ym_night = nanmean(aggs.ymeans_night,2);

out.ys       = nanstd(aggs.ymeans'      )';
out.ys_day   = nanstd(aggs.ymeans_day'  )';
out.ys_night = nanstd(aggs.ymeans_night')';

out.mm       = nanmean(aggs.mmeans      ,2);
out.mm_day   = nanmean(aggs.mmeans_day  ,2);
out.mm_night = nanmean(aggs.mmeans_night,2);

out.ms       = nanstd(aggs.mmeans'      )';
out.ms_day   = nanstd(aggs.mmeans_day'  )';
out.ms_night = nanstd(aggs.mmeans_night')';

out.dm       = nanmean(aggs.dmeans      ,2);
out.dm_day   = nanmean(aggs.dmeans_day  ,2);
out.dm_night = nanmean(aggs.dmeans_night,2);

out.ds       = nanstd(aggs.dmeans'      )';
out.ds_day   = nanstd(aggs.dmeans_day'  )';
out.ds_night = nanstd(aggs.dmeans_night')';

[beg_yr, ~, ~, ~, ~, ~ ] = tokenize_time( start_date, 'std', 'num' );
[end_yr, ~, ~, ~, ~, ~ ] = tokenize_time( end_date  , 'std', 'num' );

yr_list = beg_yr:(end_yr - 1);

[nt_op, dt_op] = get_nt_dt_ops(yr_list);

% The hourly data in the aggregate_data output is actually means over
% the set of samples from the MC procedure, not the original observations.
out.hm       = data;
out.hs       = sds ;
out.hm_day   = data.*dt_op;
out.hs_day   = sds .*dt_op;
out.hm_night = data.*nt_op;
out.hs_night = sds .*nt_op;

end

