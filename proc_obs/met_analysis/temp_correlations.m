function [ ] = temp_correlations( metdat )
%TEMP_CORRELATIONS Summary of this function goes here
%   Detailed explanation goes here

datlen = length(metdat.tmp);

figure('Name','Temperature and Its Auto-Correlation')
subaxis(2,1,1)
   plot(metdat.tmp,'.','MarkerSize',4)
   title('\bf{Temperature}')
   set(gca,'XLim',[1,datlen])

subaxis(2,1,2)
   hold on
   
   yr1_resample = repmat(metdat.tmp(1:365*24),1,3);
   yr1_resample_len = length(yr1_resample);
   [tcors,lags] = crosscorr(yr1_resample,yr1_resample,yr1_resample_len - 1);
   plot(lags,tcors,'r.','MarkerSize',4)
   
   [tcors,lags] = crosscorr(metdat.tmp,metdat.tmp,datlen-1);
   plot(lags,tcors,'.','MarkerSize',4)
   title('\bf{Auto-Correlations}')
   
   hold off
   

figure('Name','Temperature and Temp-VBDSF XCorr.')
subaxis(2,1,1)
   ax = plotyy(1:datlen,metdat.tmp,1:datlen,metdat.vbdsf);%,'.','MarkerSize',4)
   title('\bf{Temperature and VBDSF}')
   set(ax(1),'XLim',[1,datlen])
   set(ax(2),'XLim',[1,datlen])
   
   ax1child = get(ax(1),'Children');
   ax2child = get(ax(2),'Children');
   
   set(ax1child,'Marker','.')
   set(ax2child,'Marker','.')
   
   set(ax1child,'MarkerSize',4)
   set(ax2child,'MarkerSize',4)
   
   set(ax1child,'LineStyle','none')
   set(ax2child,'LineStyle','none')

subaxis(2,1,2)
   hold on
   
%    yr1_resample = repmat(metdat.tmp(1:365*24),1,3);
%    yr1_resample_len = length(yr1_resample);
%    [tcors,lags] = crosscorr(yr1_resample,yr1_resample,yr1_resample_len - 1);
%    plot(lags,tcors,'r.','MarkerSize',4)
   
   [tcors,lags] = crosscorr(metdat.tmp,metdat.vbdsf,datlen-1);
   plot(lags,tcors,'.','MarkerSize',4)
   title('\bf{Auto-Correlations}')
   
   m1 = find(tcors == max(tcors));
   m2 = find(tcors == max(tcors([1:m1-1,m1+1:end])));
   
   text(m1,tcors(m1),'cat')
   
   hold off


end

