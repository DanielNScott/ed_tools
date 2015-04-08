function [ ] = plot_cballoc( data, fractions )
%PLOT_STORALLOC Plots the fraction of total cohorts having each phenology status by PFT. 
%   Input:
%     data - 
%     fractions -

extant_pfts = unique(data.PFT);
npfts       = numel(extant_pfts);
ndays       = size(fractions(:,1,1),1);

gen_new_fig('Phenology Status Fractions By PFT');
for i = 1:npfts
   subaxis(2,3,i, 'Spacing', 0.015, 'Padding', 0.020, 'Margin', 0.03)
   
   cur_pft  = extant_pfts(i);
   cur_data = reshape(fractions(:,i,2),ndays,1)';
   cur_data(cur_data == 0) = NaN;
 
   plot(1:ndays,cur_data*100,'.','markersize',6)
   title(['\bf{PFT:  ',num2str(cur_pft),'}']);
   %legend({'False','True'})%,'Location','SouthEast')
   
   set(gca,'YLim',[0,150])
   set(gca,'XLim',[0,ndays+1])
   set(gca,'XGrid','on')
   
   %set_monthly_labels(gca,data.MONTH(1))
   ylabel('% Cohorts on Allometry')
end


end

