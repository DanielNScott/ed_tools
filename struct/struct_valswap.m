function [ struct ] = struct_valswap( struct, valin, valout )
%STRUCT_NANSWAP Summary of this function goes here
%   Detailed explanation goes here

flds = fieldnames(struct);
for ifld = 1:numel(flds)
   fld = flds{ifld};
   struct.(fld)(struct.(fld) == valin) = valout;
end

end

