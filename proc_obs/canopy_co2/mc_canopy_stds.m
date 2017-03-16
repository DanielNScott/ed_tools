% Monte Carlo Canopy Means

n_sample = 50;
n_heights = 7;
resampled_co2_mean = NaN(n_hrs,n_sample);

height_6_nan     = residuals( isnan(residuals(:,6)),6);
height_6_non_nan = residuals(~isnan(residuals(:,6)),6);
n_non_nan = length(height_6_non_nan);
height_6_filled  = [height_6_non_nan; height_6_non_nan; height_6_non_nan( randi(6956,[1,588]) )];

filled_residuals = residuals;
filled_residuals(:,6) = height_6_filled;

ground_level = 0;
can_depth = 20.75;

% Getting error bootstrap in random order so partial completion checkpoints yield useful
% results too. This is desireable, because this script will take hundreds of hours to run...
index_permutation = randperm(n_hrs);

for i = 1:n_hrs;
   hr_ind = index_permutation(i);

   for hgt_ind = 1:n_sample
      rand_index = randi(n_hrs, [1,n_heights]) + (0:n_hrs:n_hrs*(n_heights-1));
      rand_resid = filled_residuals(rand_index);

      co2_nans = isnan(big_co2(hr_ind, :));
      n_heights_missing = sum(co2_nans);

      perturbed_co2 = big_co2(hr_ind, :) + rand_resid;
      %perturbed_c13 = big_c13(i,:) + rand_resid;

      if n_heights_missing == 0
         co2_fit = fit(heights',perturbed_co2','a - b*log(c*x)','StartPoint',co2_fit_params(hr_ind, :),'Lower',[0,0,0]);
         %c13_fit = fit(heights',big_c13(i,:)','a - b*log(c*x)','StartPoint',c13_fit_params(i,:),'Lower',[0,0,0]);

      elseif n_heights_missing <= 3
         masked_heights = heights(~co2_nans);
         masked_co2     = perturbed_co2(~co2_nans);
         %masked_c13     = big_c13(i,~co2_nans);

         co2_fit = fit(masked_heights',masked_co2','a - b*log(c*x)','StartPoint',co2_fit_params(hr_ind, :),'Lower',[0,0,0]);
         %c13_fit = fit(masked_heights',masked_c13','a - b*log(c*x)','StartPoint',[4  ,1,5],'Lower',[0,0,0]);
      else
         continue
      end

      co2_fit_transp = @(x) co2_fit(x)';
      %c13_fit_transp = @(x) c13_fit(x)';

      resampled_co2_mean(hr_ind, hgt_ind)  = integral(co2_fit_transp, ground_level, can_depth) /can_depth;
      %c13_mean(i)  = integral(c13_fit_transp, 0, 20.75) /20.75;
   end

   %co2_fit_params(i,:) = [co2_fit.a, co2_fit.b, co2_fit.c];
   %c13_fit_params(i,:) = [c13_fit.a, c13_fit.b, c13_fit.c];
   
   %close all
   %hold on
   %plot(heights,big_co2(i,:),'o')
   %plot(co2_fit)
   %plot(20.75/2, co2_mean(i),'mx')
   
   %residuals_co2(i,:) = co2_fit(heights)' - big_co2(i,:);
   
   progress_percent = i/(n_hrs*n_sample)*100;

   if mod(i, 10) == 0
      clc;
      disp(['Progress [%]: ' num2str(progress_percent)]);
   end

   if mod(progress_percent,5) == 0
      disp(['Saving mc_canopy_stds_in_progress.mat'])
      save('mc_canopy_stds_in_progress.mat')
   end
end

save('mc_canopy_stds_finished.mat')
