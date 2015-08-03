function [ result ] = sphere_fn( coord )
%SPHERE_FN Computes the "sphere test function"

npts = size(coord,1);
result = NaN(npts,1);
for irow = 1:npts
   result(irow) = coord(irow,:) * coord(irow,:)';
end
end

