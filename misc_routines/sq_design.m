function [ design, colnames ] = sq_design( loc_matrix, labels )
%SQ_DESIGN Creates a design matrix for a linear model with constant,
%linear, and quadratic terms.
%   Detailed explanation goes here

   n_vars = size(loc_matrix,2);
   design = NaN(size(loc_matrix,1), 1 + n_vars + n_vars + nchoosek(n_vars,2));
   
   design(:,1) = 1;
   design(:, 2:(n_vars+1)) = loc_matrix;

   colnames = {'intercept'};
   colnames(2:(n_vars+1)) = labels;
      
   k = n_vars + 1;
   for i = 1:n_vars
      for j = 1:n_vars

         if j >= i
            k = k + 1;
            design(:,k) = loc_matrix(:,j) .* loc_matrix(:,i);
            
            if i == j
                colnames{k} = [labels{j}, '^2'];
            else
                colnames{k} = [labels{j}, '*', labels{i}];
            end
         else
            continue
         end

      end
   end

end

