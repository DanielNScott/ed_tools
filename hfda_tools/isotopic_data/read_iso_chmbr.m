function [ data ] = read_iso_chmbr( )
%READ_ISO_DATA Summary of this function goes here
%   Detailed explanation goes here

filename  = ['C:\Users\Dan\Moorcroft_Lab\data\' ...
             'harvard forest archive\hf-209-iso\HF-Chambers_Final_2012_2013.csv'];
seperator = ',';
fix_flg   = 0;

data = read_cols_to_flds(filename,seperator,fix_flg);

end

