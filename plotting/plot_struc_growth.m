function [ ] = plot_struc_growth( data )
%PLOT_STRUC_GROWTH Summary of this function goes here
%   Detailed explanation goes here

co_msks = [data.ICO == 1, ...
           data.ICO == 2, ...
           data.ICO == 3, ...
           data.ICO == 4, ...
           data.ICO == 5, ...
           ];

msk = co_msks(:,1);

m1 = '-ob';
m2 = '-or';

delta_ba = data.BA_OUT(co_msks(:,1)) - data.BA_IN(co_msks(:,1));
delta_ba = delta_ba .* data.NPLANT_OUT(msk);

bag = data.BAG_OUT(co_msks(:,1));
bag_el_1 = bag(1);
bag = bag(2:end) - bag(1:end-1);

bam = data.BAM_OUT(co_msks(:,1));
bam_el_1 = bam(1);
bam = bam(2:end) - bam(1:end-1);

calc_dba = [bag_el_1 - bam_el_1; bag - bam]/12;

nel = numel(delta_ba);

sp = 0.015;
pd = 0.015;
pt = 0.03;
pb = 0.03;
ma = 0.03;
mt = 0.03;
mb = 0.03;

figure()
   subaxis(3,4,1,'S',sp,'P',pd,'PT',pt,'PB',pb,'M',ma,'MT',mt,'MB',mb)
   hold on
   plot(data.BA_IN (msk).* data.NPLANT_IN (msk),m1)
   plot(data.BA_OUT(msk).* data.NPLANT_OUT(msk),m2)
   hold off
   std_fmt(gca,'Basal Area',{'BA In','BA Out'},'Month','m^2/ha',nel);
   
   subaxis(3,4,2,'S',sp,'P',pd,'PT',pt,'PB',pb,'M',ma,'MT',mt,'MB',mb)
   hold on
   plot(data.BAG_IN (msk).* data.NPLANT_IN (msk),m1)
   plot(data.BAG_OUT(msk).* data.NPLANT_OUT(msk),m2)
   hold off
   std_fmt(gca,'Basal Area Growth',{'BAG In','BAG Out'},'Month','m^2/ha',nel);
   
   subaxis(3,4,3,'S',sp,'P',pd,'PT',pt,'PB',pb,'M',ma,'MT',mt,'MB',mb)
   hold on
   plot(data.BAM_IN (msk).* data.NPLANT_IN (msk),m1)
   plot(data.BAM_OUT(msk).* data.NPLANT_OUT(msk),m2)
   hold off
   std_fmt(gca,'Basal Area Mort',{'BAM In','BAM Out'},'Month','m^2/ha',nel);
   
   subaxis(3,4,4,'S',sp,'P',pd,'PT',pt,'PB',pb,'M',ma,'MT',mt,'MB',mb)
   hold on
   plot(data.NPLANT_IN (msk),m1)
   plot(data.NPLANT_OUT(msk),m2)
   hold off
   std_fmt(gca,'Plant Density',{'NPLANT In','NPLANT Out'},'Month','#/m^2',nel);
   
   
   
   
   subaxis(3,4,5,'S',sp,'P',pd,'PT',pt,'PB',pb,'M',ma,'MT',mt,'MB',mb)
   hold on
   plot(delta_ba,'-om')
   plot(calc_dba,'-ok')
   hold off
   std_fmt(gca,'\Delta BA',{'BA_o_u_t - BA_i_n','BAG - BAM'},'Month','m^2/ha',nel);
   
   subaxis(3,4,6,'S',sp,'P',pd,'PT',pt,'PB',pb,'M',ma,'MT',mt,'MB',mb)
   hold on
   plot(bag,m1)
   %plot(bag,m2)
   hold off
   std_fmt(gca,'Basal Area Growth (Non-Cumulative)',{'BAG'},'Month','m^2/ha',nel);
   
   subaxis(3,4,7,'S',sp,'P',pd,'PT',pt,'PB',pb,'M',ma,'MT',mt,'MB',mb)
   hold on
   plot(bam,m1)
   %plot(bam,m2)
   hold off
   std_fmt(gca,'Basal Area Mort (Non-Cumulative)',{'BAM'},'Month','m^2/ha',nel);
   
   
   
   
   subaxis(3,4,9,'S',sp,'P',pd,'PT',pt,'PB',pb,'M',ma,'MT',mt,'MB',mb)
   plot(data.TOTAL_BA_PY(msk),m1)
   std_fmt(gca,'Total Basal Area',{''},'Month','m^2/ha',nel);
   
   subaxis(3,4,10,'S',sp,'P',pd,'PT',pt,'PB',pb,'M',ma,'MT',mt,'MB',mb)
   plot(data.TOTAL_BAG_PY(msk),m1)
   std_fmt(gca,'Total Basal Area Growth (Non-Cumulative)',{''},'Month','m^2/ha',nel);
   
   subaxis(3,4,11,'S',sp,'P',pd,'PT',pt,'PB',pb,'M',ma,'MT',mt,'MB',mb)
   plot(data.TOTAL_BAM_PY(msk),m1)
   std_fmt(gca,'Total Basal Area Mort',{''},'Month','m^2/ha',nel);
   
   subaxis(3,4,12,'S',sp,'P',pd,'PT',pt,'PB',pb,'M',ma,'MT',mt,'MB',mb)
   plot(data.TOTAL_BAR_PY(msk),m1)
   std_fmt(gca,'Total Basal Area Recruit',{''},'Month','m^2/ha',nel);
   

end

function [gca] = std_fmt(gca,name,lgnd,xlab,ylab,nel)
   title(['\bf{' name '}'])
   if ~strcmp(lgnd{1},'')
      legend(lgnd,'Location','NorthWest')
   end
   set(gca,'XGrid','On')
   set(gca,'YGrid','On')
   xlabel(xlab)
   ylabel(ylab)
   set(gca,'XLim',[0,nel+1]);
   set_monthly_labels(gca,6)
end

