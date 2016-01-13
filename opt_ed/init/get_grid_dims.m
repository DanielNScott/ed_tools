function [ dim1, dim2 ] = get_grid_dims( vector )
%GET_GRID_DIMS Finds the two largest mutiplicative factors for a number with prime factorization
%given by the input "vector"

   n_el      = numel(vector);
   while n_el > 2
      vector    = sort(vector,'descend');
      vector(2) = vector(2)*vector(3);
      vector    = [vector(1:2) vector(4:end)];
      n_el      = numel(vector);
   end
   vector = vector(1:2);
   vector = sort(vector,'descend');
   
   dim1 = vector(1);
   dim2 = vector(2);

end