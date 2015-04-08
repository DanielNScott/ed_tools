function [ data, fractions] = read_cballoc( )
%READ_CBALLOC Turns the 'cballoc.txt' file (a debugging output from growth_balive.f90) into
%   Detailed explanation goes here

% Read Data
raw = readtext('cballoc.txt','\s+');

% Readtext often gets things slightly wrong, this fixes them:
raw(1,1:end-1) = raw(1,2:end);
raw = raw(:,1:end-1);

% Create datastructure with fields for each column and the columns contents as a matrix.
data  = struct();
nflds = size(raw,2);
for fld_num = 1:nflds
   fld = raw{1,fld_num};
   data.(fld) = cell2mat(raw(2:end,fld_num));
end

extant_pfts = unique(data.PFT);
npfts       = numel(extant_pfts);
nrows       = size(data.PFT,1);

beg_str = pack_time(data.YEAR(1)  ,data.MONTH(1)  ,data.DAY(1)  ,0,0,0,'std');
end_str = pack_time(data.YEAR(end),data.MONTH(end),data.DAY(end),0,0,0,'std');
ndays   = get_date_index(beg_str,end_str,'daily') + 1;

bins    = zeros(ndays,npfts,2);
new_day = 0;
day_bin = 1;
for i = 1:nrows
   ths_day = data.DAY(i);
   
   if i >= 2
      new_day = ths_day ~= data.DAY(i-1);
   end
   
   if new_day
      day_bin = day_bin + 1;
   end
   
   on_allom_msk = strcmp(data.ON_ALLOMETRY(i),{'F','T'});
   pft_msk      = data.PFT(i) == extant_pfts;
   bins(day_bin,pft_msk,on_allom_msk) = bins(day_bin,pft_msk,on_allom_msk) + 1;
end

pft_totals = sum(bins,3);
fractions = bins ./ repmat(pft_totals,[1,1,2]);

end

