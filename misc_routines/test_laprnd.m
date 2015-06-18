
samples = laprnd([0;1;NaN;-0.5],[1;0.3;NaN;0.5],10000);
hist = zeros(41,1);
for j = 1:size(samples,1)
   ind  = 0;
   for i = -2:0.1:2
      ind = ind+1;
      hist(ind,j) = sum(and(samples(j,:) <= i,samples(j,:) > i - 0.1));
   end
end
figure();
plot(-2:0.1:2,hist')