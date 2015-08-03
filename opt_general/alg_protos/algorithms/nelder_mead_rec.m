function [sol] = nelder_mead_rec(x,p,pts,c,f,step,count)
%Nelder_Mead is a recursive implementation of the Nelder-Mead optimization algorithm
%   sol:   Best solution found.
%   x:     Used for passing in centroid, reflected, etc points.
%   p:     Parameters used by the algorithm.
%   pts:   Initial simplex. Each point is a row vector.
%   c:     Constraints on the domains of the coordinate functions of pts. as npts-by-2 matrix.
%   f:     Function to be minimized.
%   step:  Branch of the algorithm being executed.
%   count: Current recursive call count (i.e. stack depth)
%
%   If initializing, start with step = 0, count = 0, x = [].
%   Common params are p = [1,2,-1/2,1/2].
%   p(1) = reflection, p(2) = expansion, p(3) = contraction, p(4) = shrink

if isempty(c);
    c(1:size(pts,1),1) = -inf;
    c(1:size(pts,1),2) = inf;
end

if count > 490
    disp('Killed by count')
    sol = pts(1,:);
    step = -1;
end

% If we're initializing, initialize x.
if step == 0;
     count = count+1;
     x = zeros(4,size(pts,2));
     x(:,:) = NaN;
     sol = nelder_mead_rec(x,p,pts,c,f,1,count);
end

if step == 1
    count = count+1;
    % Order the pts according to their fn values:
    [~, order] = sort(f(pts));
    pts        = pts(order,:);
    
    % Check to see if we're done:
    if abs(f(pts(1,:))) < 0.0001
        sol = pts(1,:);
    else
        % Calculate center of gravity of the points excluding the worst.
        % Worst point is last in s_pts, and centroid is analogue of mean:
        x0 = sum(pts(1:end-1,:),1)/size(pts(1:end-1,:),1);
        x(1,:) = x0;
        print_det(x,pts,f,'contraction done, move on');
        sol = nelder_mead_rec(x,p,pts,c,f,3,count);
    end
end
    
if step == 3
    count = count+1;
    % Unpack x as nec. (done for ease of coding / clarity)
    x0 = x(1,:);
    % Compute domain constrained reflected point:
    xr = x0 + p(1)*(x0 - pts(end,:));
    
    for i = 1:length(xr)
        if xr(i) < c(i,1)
            xr(i) = c(i,1);
        elseif xr(i) > c(i,2)
            xr(i) = c(i,2);
        end
    end
    x(2,:) = xr;
    
    % Compare with best and second worst points.
    if and( f(pts(1,:)) <= f(xr) , f(xr) < f(pts(end-1,:)))
        pts = vertcat(pts(1:end-1,:),xr);
        print_det(x,pts,f,'reflection just right, sub for worst');
        % Then go to step 1
        sol = nelder_mead_rec(x,p,pts,c,f,1,count);
        
    elseif f(xr) < f(pts(1,:))
        print_det(x,pts,f,'reflection is best, try expansion');
        % Then go to step 4
        sol = nelder_mead_rec(x,p,pts,c,f,4,count);
        
    else
        % We have f(xr) >= f(pts(end-1,:))
        % Go to step 5
        print_det(x,pts,f,'reflection not best, try contraction');
        sol = nelder_mead_rec(x,p,pts,c,f,5,count);
    end
end

if step == 4
    count = count+1;
    % Unpack x as nec. (done for ease of coding / clarity)
    x0 = x(1,:);
    xr = x(2,:);
    
    % Compute domain constrained expanded point:
    xe = x0 + p(2)*(x0 - pts(end,:));
    for i = 1:length(xe)
        if xe(i) < c(i,1)
            xe(i) = c(i,1);
        elseif xe(i) > c(i,2)
            xe(i) = c(i,2);
        end
    end
    x(3,:) = xe;
    
    % Compare with reflected point:
    if f(xe) < f(xr)
        pts = vertcat(pts(1:end-1,:),xe);
        print_det(x,pts,f,'use expansion');
        sol = nelder_mead_rec(x,p,pts,c,f,1,count);
    else
        pts = vertcat(pts(1:end-1,:),xr);
        print_det(x,pts,f,'expand fails, use reflection');
        sol = nelder_mead_rec(x,p,pts,c,f,1,count);
    end
end
   
if step == 5
    count = count+1;
    % Unpack x as nec. (done for ease of coding / clarity)
    x0 = x(1,:);

    % Compute the domain constrained contracted point:
    xc = x0 + p(3)*(x0 - pts(end,:));
    for i = 1:length(xc)
        if xc(i) < c(i,1)
            xc(i) = c(i,1);
        elseif xc(i) > c(i,2)
            xc(i) = c(i,2);
        end
    end
    x(4,:) = xc;
    
    if f(xc) < f(pts(end,:))
        print_det(x,pts,f,'5a');
        pts = vertcat(pts(1:end-1,:),xc);
        sol = nelder_mead_rec(x,p,pts,c,f,1,count);
    else
        print_det(x,pts,f,'contract fails, try shrink');
        sol = nelder_mead_rec(x,p,pts,c,f,6,count);
    end
end

if step == 6
    count = count+1;
    % Reduce...
    for i = 2:size(pts,1);
        pts(i,:) = pts(1,:) + p(4)*(pts(i,:) - pts(1,:));    
    end
    % Enforce domain constraints
    for j = 1:size(pts,1)
        for i = 1:length(pts(j,:))
            if pts(j,i) < c(i,1)
                pts(j,i) = c(i,1);
            elseif pts(j,i) > c(i,2)
                pts(j,i) = c(i,2);
            end
        end
    end
    print_det(x,pts,f,'shrink');
    sol = nelder_mead_rec(x,p,pts,c,f,1,count);
end


end


function [] = print_det(x,pts,f,tag)

% disp(['------------- step ',tag,' ------------------'])
% disp('pts = ')
% disp(pts)
% disp('f(pts)=')
% disp(f(pts))
% disp('x = ')
% disp(x)
% disp('f(x) = ')
% disp(f(x))


end