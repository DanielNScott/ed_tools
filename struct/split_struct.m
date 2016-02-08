function [ struct, split_off ] = split_struct( struct, flds)
%SPLIT_STRUCT Summary of this function goes here
%   Detailed explanation goes here

for ifld = 1:numel(flds)
   fld = flds{ifld};
   split_off.(fld) = struct.(fld);
   struct = rmfield(struct,fld);
end

end

