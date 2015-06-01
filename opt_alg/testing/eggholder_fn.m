function [ result ] = eggholder_fn( coords )
%EGGHOLDER_FN is a benchmarking function for opt. algs.
%   This function achieves a minimum of -959.6407 @ (512,404.2319), with the restricted domain
%   -512 < x,y < 512

   if any(coords < 512) || any(coords > 512)
      error('An evaluation of the eggholder fn with inputs outside its domain was attempted.')
   end

   x = coords(1);
   y = coords(2);
   
   result = -(y+47) *sin(sqrt(abs( y + x/2 + 47 ))) - x *sin(sqrt(abs( x - (y+47) )));
   
end

