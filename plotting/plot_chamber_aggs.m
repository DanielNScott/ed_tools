function [ ] = plot_chamber_aggs( mc )
%PLOT_CHAMBER_AGGS Summary of this function goes here
%   Detailed explanation goes here

space = 0.03;
pad   = 0.03;
marg  = 0.03;

subaxis(3,1,1,'S',space,'P',pad,'M',marg)
   errorbar(mc.dm,mc.ds,'.r')
   set(gca,'XGrid','on')
   set(gca,'YGrid','on')
   title('Aggregated Daily Soil Efflux')
   ylabel('Soil Efflux [kgC/m^2/yr]')
   xlabel('Day')

subaxis(3,1,2,'S',space,'P',pad,'M',marg)
   errorbar(mc.mm,mc.ms,'.r')
   set(gca,'XGrid','on')
   set(gca,'YGrid','on')
   title('Aggregated Monthly Soil Efflux')
   ylabel('Soil Efflux [kgC/m^2/yr]')
   xlabel('Month')

subaxis(3,1,3,'S',space,'P',pad,'M',marg)
   barwitherr(mc.ys,mc.ym)
   set(gca,'XGrid','on')
   set(gca,'YGrid','on')
   title('Aggregated Yearly Soil Efflux')
   ylabel('Soil Efflux [kgC/m^2/yr]')
   xlabel('Year')
   
end

