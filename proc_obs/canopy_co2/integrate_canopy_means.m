function [co2_mean, c13_mean, d13C_mean] = integrate_canopy_means(use_cache)
% This function reads a tsv of canopy height-profile co2 and d13C data,
% fits a curve to the profile at each time point and then computes
% an average co2 concentration and d13C value by integrating that curve
% from ground level to a pre-determined canopy height set in accordance
% with the can_depth variable in ED.

if use_cache
   load('integrate_canopy_means.mat');
   disp('Loaded integrate_canopy_means.mat rather than tsv file.')
else
   profile_fname = '/home/dan/documents/harvard/data/observations/harvard_forest_archives/hf-209-iso/orig/HF-Profiles.tsv';
   prof_data = read_cols_to_flds(profile_fname,'\t',0,0);
   
   save('integrate_canopy_means.mat');
end

heights = [0.2, 1.0, 7.5, 12.5, 18.3, 24.1, 29.0];

big_co2 = [prof_data.CO2_0_2m_ppm_,  prof_data.CO2_1_0m_ppm_, ...
           prof_data.CO2_7_5m_ppm_,  prof_data.CO2_12_5m_ppm_,...
           prof_data.CO2_18_3m_ppm_, prof_data.CO2_24_1m_ppm_,...
           prof_data.CO2_29_0m_ppm_];

big_d13C = [prof_data.Del13_0_2m_ppm_,  prof_data.Del13_1_0m_ppm_,  ...
            prof_data.Del13_7_5m_ppm_,  prof_data.Del13_12_5m_ppm_, ...
            prof_data.Del13_18_3m_ppm_, prof_data.Del13_24_1m_ppm_, ...
            prof_data.Del13_29_0m_ppm_];
         
big_co2 (big_co2  == 9999) = NaN;
big_d13C(big_d13C == 9999) = NaN;

big_c13 = get_C13(big_co2, big_d13C);

n_hrs = length(big_co2);

% Pre-allocate memory
co2_mean  = NaN(n_hrs,1);
c13_mean  = NaN(n_hrs,1);
residuals = NaN(n_hrs,7);

co2_fit_params = NaN(n_hrs,3);
c13_fit_params = NaN(n_hrs,3);
for i = 1:n_hrs;

   co2_nans = isnan(big_co2(i,:));
   n_heights_missing = sum(co2_nans);
   
   if n_heights_missing == 0
      co2_fit = fit(heights',big_co2(i,:)','a - b*log(c*x)','StartPoint',[400,1,5],'Lower',[0,0,0]);
      c13_fit = fit(heights',big_c13(i,:)','a - b*log(c*x)','StartPoint',[4  ,1,5],'Lower',[0,0,0]);
      
   elseif n_heights_missing <= 3
      masked_heights = heights(~co2_nans);
      masked_co2     = big_co2(i,~co2_nans);
      masked_c13     = big_c13(i,~co2_nans);
      
      co2_fit = fit(masked_heights',masked_co2','a - b*log(c*x)','StartPoint',[400,1,5],'Lower',[0,0,0]);
      c13_fit = fit(masked_heights',masked_c13','a - b*log(c*x)','StartPoint',[4  ,1,5],'Lower',[0,0,0]);
   else
      continue
   end
   
   co2_fit_transp = @(x) co2_fit(x)';
   c13_fit_transp = @(x) c13_fit(x)';
   
   co2_mean(i)  = integral(co2_fit_transp, 0, 20.75) /20.75;
   c13_mean(i)  = integral(c13_fit_transp, 0, 20.75) /20.75;

   
   co2_fit_params(i,:) = [co2_fit.a, co2_fit.b, co2_fit.c];
   c13_fit_params(i,:) = [c13_fit.a, c13_fit.b, c13_fit.c];
   
   %close all
   %hold on
   %plot(heights,big_co2(i,:),'o')
   %plot(co2_fit)
   %plot(20.75/2, co2_mean(i),'mx')
   
   residuals_co2(i,:) = co2_fit(heights)' - big_co2(i,:);
   residuals_c13(i,:) = c13_fit(heights)' - big_c13(i,:);
   
   if mod(i,5) == 0
      clc;
      disp(['Progress [%]: ' num2str(i/14501*100)]);
   end
end

d13C_mean = get_d13C(c13_mean, co2_mean);

figure()
for i = 1:7
   subplot(2,4,i)
   hist(residuals(:,i),200);
   title(['\bf{Residuals for Height ', num2str(heights(i)), '}'])
   set(gca,'XLim',[-30,30]);
   %set(gca,'YLim',[0,500]);
end
savefig('CO2 Profile Residuals')

save('integrate_canopy_means_results.mat');

end
