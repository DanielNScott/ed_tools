function [ data, fractions] = read_storalloc()
%READ_STORALLOC Turns the 'storalloc.txt' file (a debugging output from structural_alloc.f90)
%into some graphs of phenology_status fractions by pft over time.
%   Output:
%     data - 
%     fractions - 
%     extant_pfts - 
%     fractions - 

% Read Data
raw = readtext('storalloc.txt','\s+');

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

% Get the list of pfts and the number of rows of data.
extant_pfts = unique(data.PFT);
npfts       = numel(extant_pfts);
nrows       = size(data.PFT,1);

% Determine how many months output we have.
beg_str = pack_time(data.YEAR(1)  ,data.MONTH(1)  ,0,0,0,0,'std');
end_str = pack_time(data.YEAR(end),data.MONTH(end),0,0,0,0,'std');
nmonths = get_date_index(beg_str,end_str,'monthly') + 1;

% Set up bins to count phenology status by cohort by pft.
bins   = zeros(nmonths,npfts,4);
new_mo = 0;
mo_bin = 1;
for i = 1:nrows
   ths_mo = data.MONTH(i);
   
   if i >= 2
      new_mo = ths_mo ~= data.MONTH(i-1);
   end
   
   if new_mo
      mo_bin = mo_bin + 1;
   end
   
   ps_selector  = data.PHEN_STATUS(i) == [-2,-1,0,1];
   pft_selector = data.PFT(i) == extant_pfts;
   bins(mo_bin,pft_selector,ps_selector) = bins(mo_bin,pft_selector,ps_selector) + 1;
end

% Make phenology status by cohort by pft into phenology status by fraction of cohorts by pft.
pft_totals = sum(bins,3);
fractions  = bins ./ repmat(pft_totals,[1,1,4]);

end

