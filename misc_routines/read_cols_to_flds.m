function [ data ] = read_cols_to_flds( filename, seperator, nhead, fix_flg )
%read_cols_to_flds( filename, seperator, nhead, fix_flg )
%   Reads a seperator seperated file with nhead headers & name filename into a matlab structure
%   with columns as fields. Field names come from the first non-header row.

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
looks_bad = isempty(cell2mat(raw(3:end,end)));

if fix_flg || looks_bad
   raw(1,1:end-1) = raw(1,2:end);
   raw = raw(:,1:end-1);
end

% Create datastructure with fields for each column and the columns contents as a matrix.
data  = struct();
nflds = size(raw,2);
for fld_num = 1:nflds
   raw_fld = raw{1+nhead,fld_num};
   fix_fld = char_sub(raw_fld,'.','_');
   data.(fix_fld) = cell2mat(raw(2+nhead:end,fld_num));
end

end

