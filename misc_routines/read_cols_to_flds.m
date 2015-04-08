function [ data ] = read_cols_to_flds( filename, seperator, fix_flg )
%READ_COLS_TO_FIELDS Summary of this function goes here
%   Detailed explanation goes here

% Read Data
raw = readtext(filename,seperator);

%-----------------------------------------------------------
% Readtext often gets things slightly wrong, reading e.g. 
%     number_cats, number_dogs
%               1,           2
% into a cell as ...
%     {'','number_cats','number_dogs';...
%     [1],          [2],           [] }
% but specifying fix_flg = 1 fixes the issue.
%-----------------------------------------------------------
if fix_flg
   raw(1,1:end-1) = raw(1,2:end);
   raw = raw(:,1:end-1);
end

% Create datastructure with fields for each column and the columns contents as a matrix.
data  = struct();
nflds = size(raw,2);
for fld_num = 1:nflds
   fld = raw{1,fld_num};
   data.(fld) = cell2mat(raw(2:end,fld_num));
end

end

