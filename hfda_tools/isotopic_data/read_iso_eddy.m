function [ data ] = read_iso_eddy( )
%READ_ISO_DATA Summary of this function goes here
%   Detailed explanation goes here

filename  = ['C:\Users\Dan\Moorcroft_Lab\data\' ...
             'harvard forest archive\hf-209-iso\HF-FluxesEtc-safe_chars.tsv'];
seperator = '\s';
fix_flg   = 0;

data = read_cols_to_flds(filename,seperator,fix_flg);

end

