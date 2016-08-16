function [Betas, Regressors, Labels, Squares, fHandle] = llsqfit(obj,params,plabs)
% Here we'll solve Y = XB for X using the '\' operator

nobs     = length(obj);
nparams  = size(params,2);
nsqterms = nchoosek(nparams + 2 - 1, 2); 

Regressors = NaN  (nobs,1 + nparams + nsqterms);
Squares = zeros(1   ,1 + nparams + nsqterms);

% Construct Regressors matrix
for i = 1:nobs;
   
   Regressors(i,1) = 1;
   
   for j = 1:nparams
      Regressors(i,j+1) = params(i,j);
      
      if i == 1 && exist('plabs','var')
         Labels{j+1} = plabs{j};
      end
      
      for k = 1:nparams - (j-1)
         offset = max( (j-2)*(j-1)/2, 0);
         index  = k + (1 + nparams) + (j-1)*nparams - offset;
         Regressors(i,index) = params(i,j)*params(i, k + (j-1));
         
         if k == 1
            Squares(index) = 1;
         end
         if i == 1 && exist('plabs','var')
            Labels{index} = [plabs{j} '*' plabs{k + (j-1)}];
         end
      end
   end

end




if exist('plabs','var')
   Labels  = Labels';
else
   Labels = [];
end

% Standard OLS Regression:
Betas = Regressors\obj;
% B = (X'*X)^(-1)*(X'*obj);
 
% Ridge Regression:
%lambda = 0;
%B = ( X'*X + lambda*diag(ones(1,1+nparams+nsqterms)) )^(-1)*(X'*obj);

end


function [prediction] = quadratic_fn(X,Betas)


end
