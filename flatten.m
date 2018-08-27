function [locs, objs] = flatten(state, obj, nps, niter)

%
locs = reshape(state, [size(state,1), nps*niter]);
locs = locs';
objs = obj(:);

end