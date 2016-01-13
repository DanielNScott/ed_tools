function [ pred_args ] = compare_refs( pred )
%COMPARE_REFS Summary of this function goes here
%   Detailed explanation goes here

figure()

p1data = [pred.best.T.MMEAN_NEP_PY; ...
          pred.ref.T.MMEAN_NEP_PY ; ...
          pred.best_11.T.MMEAN_NEP_PY; ...
          pred.ref_11.T.MMEAN_NEP_PY];
       
p2data = [pred.best.X.MMEAN_NEE; ...
          pred.ref.X.MMEAN_NEE ; ...
          pred.best_11.X.MMEAN_NEE; ...
          pred.ref_11.X.MMEAN_NEE];
       
p3data = [pred.best.Y.MMEAN_NEE_Day; ...
          pred.ref.Y.MMEAN_NEE_Day ; ...
          pred.best_11.Y.MMEAN_NEE_Day; ...
          pred.ref_11.Y.MMEAN_NEE_Day];
       
p4data = [pred.best.T.MMEAN_NEP_PY_Night; ...
          pred.ref.T.MMEAN_NEP_PY_Night ; ...
          pred.best_11.T.MMEAN_NEP_PY_Night; ...
          pred.ref_11.T.MMEAN_NEP_PY_Night];
       
p5data = [pred.best.X.MMEAN_NEE_Night; ...
          pred.ref.X.MMEAN_NEE_Night ; ...
          pred.best_11.X.MMEAN_NEE_Night; ...
          pred.ref_11.X.MMEAN_NEE_Night];
       
p6data = [pred.best.Y.MMEAN_NEE_Night; ...
          pred.ref.Y.MMEAN_NEE_Night ; ...
          pred.best_11.Y.MMEAN_NEE_Night; ...
          pred.ref_11.Y.MMEAN_NEE_Night];


subaxis(2,3,1)
plot(1:31,p1data,'-o')
title('\bf{Monthly NEP}')
legend({'best_10','ref_10','best_11','ref_11'},'Interpreter','None')

subaxis(2,3,2)
plot(1:31,p2data,'-o')
title('\bf{Monthly NEE}')
legend({'best_10','ref_10','best_11','ref_11'},'Interpreter','None')

subaxis(2,3,3)
plot(1:24,p3data,'-o')
title('\bf{Monthly NEE Day (Masked)}')
legend({'best_10','ref_10','best_11','ref_11'},'Interpreter','None')

subaxis(2,3,4)
plot(1:31,p4data,'-o')
title('\bf{Monthly NEP Night}')
legend({'best_10','ref_10','best_11','ref_11'},'Interpreter','None')

subaxis(2,3,5)
plot(1:31,p5data,'-o')
title('\bf{Monthly NEE Night}')
legend({'best_10','ref_10','best_11','ref_11'},'Interpreter','None')

subaxis(2,3,6)
plot(1:24,p6data,'-o')
title('\bf{Monthly NEE Night (Masked)}')
legend({'best_10','ref_10','best_11','ref_11'},'Interpreter','None')


end

