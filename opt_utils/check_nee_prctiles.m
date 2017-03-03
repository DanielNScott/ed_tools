function [] = check_nee_prctiles(history)
% This function takes a simulation 'hist' structure, masks out the
% smallest NEE data, produces histograms of the removed data,
% compares the aggregates that result from various such masks, and 
% produces plots of the distribution of NEE data before and after
% they are applied in order to verify that model fitting will be 
% only minimally affected.

% Masking out the smallest NEE values is motivated by the fact that
% such values produce extreme d13C excursions which, when being fit
% using a quadratic log likelihood (wrong but not such a horrible
% approximation), disproportionately impact model fitting. The
% best solution would be accurate uncertainties for such data points,
% but considering their rarity, removal is also adequate.


% Extract NEE
nee     = history.pred_ref.T.FMEAN_NEP_PY';
nee_c13 = history.pred_ref.T.FMEAN_NEP_C13_PY';

% Mask to first year
nee     = nee(1:(365*24));
nee_c13 = nee_c13(1:(365*24));

nee_d13C = get_d13C(nee_c13, nee);

% Percentiles
prctile_msk_low = abs(nee) < prctile(abs(nee), 0.5);
prctile_msk_med = abs(nee) < prctile(abs(nee),   1);
prctile_msk_hgh = abs(nee) < prctile(abs(nee),   2);

% Outliers
outlier_msk = abs(nee_d13C) > 100;

% Points to remove
rm_msk = and(prctile_msk_med,outlier_msk);

nee_low = nee;
nee_med = nee;
nee_hgh = nee;

[nee_c13_rm, nee_rm, nee_d13C_rm] = copy_convert_mask(nee_c13, nee, rm_msk);

nee_c13_low = nee_c13;
nee_c13_med = nee_c13;
nee_c13_hgh = nee_c13;

nee_low(prctile_msk_low) = NaN;
nee_med(prctile_msk_med) = NaN;
nee_hgh(prctile_msk_hgh) = NaN;

nee_c13_low(prctile_msk_low) = NaN;
nee_c13_med(prctile_msk_med) = NaN;
nee_c13_hgh(prctile_msk_hgh) = NaN;


nee_d13C_low = get_d13C(nee_c13_low, nee_low);
nee_d13C_med = get_d13C(nee_c13_med, nee_med);
nee_d13C_hgh = get_d13C(nee_c13_hgh, nee_hgh);

% Aggregate
%aggs     = aggregate_d13C_data(nee,nee_c13,'2011-01-01-00-00-00','2012-01-01-00-00-00','ave');
%aggs_low = aggregate_d13C_data(nee_low, nee_c13_low,'2011-01-01-00-00-00','2012-01-01-00-00-00','ave');
aggs_med = aggregate_d13C_data(nee_med, nee_c13_med,'2011-01-01-00-00-00','2012-01-01-00-00-00','ave');
aggs_old = aggregate_data(nee_d13C_med,'2011-01-01-00-00-00','2012-01-01-00-00-00','ave');
aggs_rm  = aggregate_d13C_data(nee_rm, nee_c13_rm,'2011-01-01-00-00-00','2012-01-01-00-00-00','ave');

%aggs_hgh = aggregate_d13C_data(nee_hgh, nee_c13_hgh,'2011-01-01-00-00-00','2012-01-01-00-00-00','ave');

%figure;
%plot(1:8760, [nee, nee_low, nee_med, nee_hgh])

%figure;
%plot(1:8760, [nee_c13, nee_c13_low, nee_c13_med, nee_c13_hgh])

%figure;
%plot(1:8760, [nee_d13C, nee_d13C_low, nee_d13C_med, nee_d13C_hgh])

disp(max(abs(nee_d13C    )))
disp(max(abs(nee_d13C_low)))
disp(max(abs(nee_d13C_med)))
disp(max(abs(nee_d13C_hgh)))

% Aggregates along with the hourly values
% At first I was confused by the results of this plot, but it makes sense
% that the "actual" aggregates are can either be more positive or negative
% than the means, because the mean is ignoring the direction of the C/C13
% flux
figure()
plot(1:8760, [tile_by_item(aggs_old.dmeans,24), ...
              tile_by_item(aggs_med.dmeans,24), ...
              tile_by_item(aggs_rm.dmeans,24), ...
              nee_d13C_med,...
              nee_d13C_rm])
legend({'bad dmeans','good dmeans','better dmeans', 'good hrly', 'better hrly'})
           

figure()
hist(nee(prctile_msk_med))

figure()
hist(nee(rm_msk))

%figure;
%hist(abs(nee_d13C(~isnan(nee_d13C)))    , 100)
%title('unedit')

%figure;
%hist(abs(nee_d13C_low(~isnan(nee_d13C_low))), 100)
%title('low')

%figure;
%hist(abs(nee_d13C_med(~isnan(nee_d13C_med))), 100)
%title('med')

%figure;
%hist(abs(nee_d13C_hgh(~isnan(nee_d13C_hgh))), 100)
%title('hgh')

end

function [heavy_out, total_out, d13C] = copy_convert_mask(heavy_in, total_in, msk)

heavy_out = heavy_in;
total_out = total_in;

heavy_out(msk) = NaN;
total_out(msk) = NaN;

d13C = get_d13C(heavy_out, total_out);

end
