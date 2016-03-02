function [ params ] = fit_quadratic( data, bnds )
%FIT_QUADRATIC Summary of this function goes here


fn = @(coeff) ssq(data,coeff);

params = particle_swarm(bnds,4000,500,fn);


end



function [sum] = ssq(data,coeff)

myFun = @(x,a) a(:,1) + a(:,2)*x(1) + a(:,3)*x(2) + a(:,4)*x(1)*x(2) + a(:,5)*x(1)^2 + a(:,6)*x(2)^2;

sum = 0;
for ipt = 1:size(data,1)
   x = data(ipt,1:end-1);
   y = data(ipt,end);
   
   sum = sum + (y - myFun(x,coeff)).^2;
end

end