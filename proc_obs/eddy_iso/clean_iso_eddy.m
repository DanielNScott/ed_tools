function [ NEE_d13C ] = clean_iso_eddy( NEE_d13C, NEE )
%CLEAN_ISO_EDDY Removes some outliers in the NEE d13C data and examines what impact this should
%have on the data-set re. fitting.

% Create a mask
msk = or(NEE_d13C >= 200,NEE_d13C <= -200);

% Examine the effects
space = 0.03;
pad   = 0.03;
marg  = 0.03;

figure('Name','NEE d13C Cleanup Analysis');
subaxis(2,3,1,'S',space,'P',pad,'M',marg)
   plot(abs(NEE),NEE_d13C,'or')
   set(gca,'XGrid','on')
   set(gca,'YGrid','on')
   title('NEE \delta^1^3C as a Function of |NEE|')
   xlabel('Abs(NEE) [\mumol/m^2/s]')
   ylabel('NEE \delta^1^3C [permil VPDB]')
   
subaxis(2,3,2,'S',space,'P',pad,'M',marg)
   plot(abs(NEE(msk)),NEE_d13C(msk),'or')
   set(gca,'XGrid','on')
   set(gca,'YGrid','on')
   title('Excluded \delta^1^3C as a Fn. of Excluded |NEE|')
   xlabel('Abs(NEE) [\mumol/m^2/s]')
   ylabel('NEE \delta^1^3C [permil VPDB]')

subaxis(2,3,3,'S',space,'P',pad,'M',marg)
   plot(NEE(msk),NEE_d13C(msk),'or')
   set(gca,'XGrid','on')
   set(gca,'YGrid','on')
   title('Excluded \delta^1^3C as Fn. of Excluded NEE')
   xlabel('NEE [\mumol/m^2/s]')
   ylabel('NEE \delta^1^3C [permil VPDB]')

subaxis(2,3,4,'S',space,'P',pad,'M',marg)
   histogram(abs(NEE),100)
   set(gca,'XGrid','on')
   set(gca,'YGrid','on')
   title('Histogram of |NEE|')
   xlabel('Abs(NEE) [\mumol/m^2/s]')
   ylabel('Bin Count')

subaxis(2,3,5,'S',space,'P',pad,'M',marg)
   histogram(abs(NEE(msk)),100)
   set(gca,'XGrid','on')
   set(gca,'YGrid','on')
   title('Histogram of Excluded |NEE|')
   xlabel('Abs(NEE) [\mumol/m^2/s]')
   ylabel('Bin Count')

subaxis(2,3,6,'S',space,'P',pad,'M',marg)
   histogram(NEE(msk),100)
   set(gca,'XGrid','on')
   set(gca,'YGrid','on')
   title('Histogram of Excluded NEE')
   xlabel('NEE [\mumol/m^2/s]')
   ylabel('Bin Count')

% Apply the mask and return. 
NEE_d13C(msk) = NaN;

end

