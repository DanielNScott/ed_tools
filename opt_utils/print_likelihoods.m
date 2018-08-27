function [] = print_likelihoods(hist)

for res = {'hourly','daily','monthly','yearly'}
   res = res{:};
   
   fields = fieldnames(hist.stats.ref.likely.(res));
   
   for fld = fields'
      fld = fld{:};
      likely_ref = nansum(hist.stats.ref.likely.(res).(fld));
      likely_best = nansum(hist.stats.likely.(res).(fld)(:,hist.iter_best));
     
      text = [res, ' ', fld, '; (', num2str(likely_ref,4), ',', num2str(likely_best,4), ')'];
      disp(text);
      
      dlmwrite('likelihoods.txt',text,'-append', 'delimiter','')

   end

end


%fields = {'total_likely', 'total_likely_c_pool', 'total_likely_c_flux', 'total_likely_c13_pool', ...
%   'total_likely_c13_flux', 'total_likely_not_c'};

%for fld = fields
%   fld = {:};
%   text = [fld, '; (', num2str(hist.stats.ref.(fld), 4), ',', num2str(hist.stats.(fld),4), ')'];
%   disp(text);
%      
%   dlmwrite('likelihoods.txt',text,'-append', 'delimiter','')
%end
