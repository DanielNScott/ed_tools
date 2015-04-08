function [ ] = plot_storalloc( data, fractions )
%PLOT_STORALLOC Plots the fraction of total cohorts having each phenology status by PFT. 
%   Input:
%     data - 
%     fractions -

extant_pfts = unique(data.PFT);
nmonths     = size(fractions(:,1,1));

gen_new_fig('Phenology Status Fractions By PFT');
for i = 1:npfts
   subaxis(2,3,i, 'Spacing', 0.015, 'Padding', 0.020, 'Margin', 0.03)
   
   cur_pft  = extant_pfts(i);
   cur_data = reshape(fractions(:,i,:),nmonths,4)';
   cur_data(cur_data == 0) = NaN;
 
   plot(1:nmonths,cur_data*100,'o')
   title(['\bf{PFT:  ',num2str(cur_pft),'}']);
   legend({'-2','-1','0','1'})%,'Location','SouthEast')
   
   set(gca,'YLim',[0,150])
   set(gca,'XLim',[0,nmonths+1])
   set(gca,'XGrid','on')
   
   set_monthly_labels(gca,data.MONTH(1))
   ylabel('% Cohorts with Phenology Status')
end


end

