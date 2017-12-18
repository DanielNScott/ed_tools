function [locs, objs] = flatten(state, vals, nps, niter)

%
locs = reshape(state, [size(state,1), nps*niter]);
locs = locs';
objs = vals(:);

end