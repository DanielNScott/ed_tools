function [ result ] = sphere_fn( coord )
%SPHERE_FN Computes the "sphere test function" 
   result = coord(:)' * coord(:);
end

