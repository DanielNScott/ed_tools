function [ data ] = graph_css( )
%GRAPH_CSS Summary of this function goes here
%   Detailed explanation goes here

filename  = ['C:\Users\Dan\Moorcroft_Lab\Data\' ...
             'PSS_CSS\USHa1.lat42.54lon-72.17_toy.css'];
seperator = '\s';
fix_flg   = 0;

data = read_cols_to_flds(filename,seperator,fix_flg);

%----------------------------------------------------------------------------------------------%
% Get by-patch joint pft/size class distributions
%----------------------------------------------------------------------------------------------%
dbh_class   = [20,30,40,50,60,70];
pft_class   = [5,6,8,9,10,11];
patch_class = {'A1','A2'};
% patch_class = {'A1','A2','A3',          ...
%                'B1','B2','B3','B4',     ...
%                'C1','C2','C3','C4','C5',...
%                'D1','D2','D3','D4','D5',...
%                'E1','E2','E3','E4','E5',...
%                'F1','F2','F3','F4','F5',...
%                'G1','G2','G3','G4','G5',...
%                'H1','H2','H3','H4','H5' ...
%                };

npft   = numel(pft_class);
ndbhc  = numel(dbh_class);
npatch = numel(patch_class);

nchrt  = numel(data.cohort);

bins = zeros(npatch+1,npft,ndbhc);

% To vectorize comparisons, matrices need to be commensurable, so do some copying.
% Patch classing is less amenable to vectorization because it's a cell of characters...
big_dbhc = repmat(dbh_class,nchrt,1);
big_dbh  = repmat(data.dbh,1,ndbhc);

big_pftc = repmat(pft_class,nchrt,1);
big_pft  = repmat(data.pft,1,npft);

% Do comparisons
dbhc_msk = and(big_dbh < big_dbhc, big_dbh > big_dbhc - 10);
pftc_msk = big_pft == big_pftc;

nchars     = numel(data.patch);
data.patch = reshape(data.patch',1,nchars);
patch_msk = zeros(nchrt,npatch,1);
for ipatch = 1:npatch
   str_loc = strfind(data.patch,patch_class{ipatch}); % string location
   cor_ind = (str_loc + 1)/2;                         % corrosponding indices
   patch_msk(cor_ind,ipatch) = 1;

   for idbh = 1:ndbhc
      for ipft = 1:npft
         
      end
   end
   
   %bins(ipatch,:,:)
end


end

