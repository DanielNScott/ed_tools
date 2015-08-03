function [ ] = mh_examples( ex_num )

if ex_num == 1
    Ex1()
elseif ex_num == 2
    Ex2()
elseif ex_num == 3
    Ex3()
end
    
end


function [ ] = Ex1()
%Ex1 Summary of this function goes here
%   Detailed explanation goes here

%MH_EX Is an implementation of the example found here:
% http://galton.uchicago.edu/~eichler/stat24600/Handouts/l12.pdf
% It
%   Detailed explanation goes here


% - Calculate a vector Y = Transpose([Y1,Y2,...,Yn]) with Yn ~ Bin(1,theta)
%   where theta has a nonstandard prior.
% - Let Sn be the sum of the elements of Y
% - Let the nonstandard prior for theta be prior(theta) (typical notation
%   for priors is pi(parameter), but pi is intrinsic in matlab)

prior  = @(theta) 2*cos(4*pi*theta)^2;
get_Yi = @(theta) MultinomialSampler([1-theta, theta]);

Y     = @(n) {repmat(get_Yi,[1,n])};
Sn    = @(Y) sum(Yi);

disp(prior(5))

disp(get_Yi(5))

disp(Y(3))
disp(Sn(Y))

end
function [ ] = Ex2()
%Ex2 Implements the historical example illustrated in
% http://www.youtube.com/watch?v=Dzx5xNT79TI.
%   Detailed explanation goes here

% Constants
N = 25;             % Number of particles
r = 0.005;          % Radius of particles
T = 283;            % Temperature

% Physical Constants
k = 1.38*10^-23;    % Boltzmann constant

% Functions
p      = @(x) exp(-Energy(x)/k*T);  % Non-normalized Boltzmann Distribution
ptilde = @(x) p*I(x);               % Boltzmann distribution with indicator

% Algorithm
% - Set initial configuration
% - Generate (valid) proposal
% - Accept/Reject proposal 
% - Repeat
end
function [ valid ] = I(x)
% This function returns the validity of a given configuration

N = size(x);

% 4 Cases - Interior, Horiz. Edge, Vert. Edge, Corner
for i = 1:N-1
    for j = i:N
        % Interior Case:
        if pdist([ x(i,:) ; x(j,:) ]) < 2*r
            valid = false;
            return
        end
    end
end

end


function [ Energy ] = Energy(x)
m = 1;              % Mass of particle
g = 9.8;            % Gravitational acceleration 

Energy = sum(m*g*x(:,2));
end


function [] = Ex3
%Ex3 Implements the example found in the video:
% https://www.youtube.com/watch?v=VGRVRjr0vyw

% Consider sampling from the distribution:
%   f(x) = N(5,9)I(1 <= x <= 6)
%
% Then f is prop. to 
%   exp(-(x-5)^2/18)*I(1 <= x <= 6)
%
% and we can choose a proposal distribution
%   q(x|x^(j) = N(x^(j),1) 
%
% and let x^(0)=5.

% Here superscripts denote location in the chain, i.e. x^(i) is the ith
% value and x^(0) is the initialization.

% Algorithm:
% - Sample x* from q(x|x^(j))
% - Calculate acceptance prob. rho(x^(j),x*) = min(1,ratio) where
%       ratio = f(x*)/f(x^(j)) * q(x^(j)|x*) / q(x*|x^(j))
% - Set x^(j+1) = x* with prob. rho(x^(j),x*), and to x^(j) with 1-rho.

% Here we implement superscripts as subscripts on array x so that the
% vector x represents the whole chain at any given time, and we initialize
% with x(1) since matlab is not 0 indexed.

niter = 10000;
x     = zeros(1,niter);
x(1)  = 5;

f         = @(x) exp(-(x-5).^2/18).*(x >= 1 & x <= 6);
prop_dist = @(x) normrnd(x,1);

gaussian  = @(x) 1/(3*(2*pi)^0.5)*exp(-(x-5).^2/18);

% Likelihood is the pdf of the proposal distribution, but it doesn't need
% to be normalized because we're using likelihood ratios and the
% normalization factor is not dependent on the mean, only on sigma which
% will remain the same throughout the algorithm.
likely = @(x,mu,sigma) exp(-(x-mu)^2/(2*sigma^2)); 

for i = 2:niter
    prop  = prop_dist(x(i-1));
    ratio = f(prop)/f(x(i-1)) ...
            * likely( x(i-1) , prop, 1 ) / likely( prop , x(i-1) , 1);
    accept_prob = min(1,ratio);
    accept = (rand() <= accept_prob);
    if accept
        x(i) = prop;
    else
        x(i) = x(i-1);
    end
end

% Construct a list of values of the density we're trying to sample from so
% we can plot it on the histograms... remaining density is what we have to
% add to the density to normalize it; Since we've cut off the mass outside
% [1,6] we have to add it back in under the curve in the valid domain. 
remaining_density = 0.04;
density = gaussian(1:0.001:6-0.001) + remaining_density;

gen_new_fig('Metropolis-Hastings Example 3')

% Samples vs Iterations
subaxis(2,3,1, 'Spacing', 0.03, 'Padding', 0.03, 'Margin', 0.015)
    plot(x(1:100));
    ylabel('x[1:100]')
    xlabel('Iterations');
subaxis(2,3,2, 'Spacing', 0.03, 'Padding', 0.03, 'Margin', 0.015)
    plot(x(1:1000));
    ylabel('x[1:1,000]')
    xlabel('Iterations');
subaxis(2,3,3, 'Spacing', 0.03, 'Padding', 0.03, 'Margin', 0.015)
    plot(x(1:10000));
    ylabel('x[1:10,000]')
    xlabel('Iterations');

% Density vs Samples
subaxis(2,3,4, 'Spacing', 0.03, 'Padding', 0.03, 'Margin', 0.015)
    hold on
    gen_norm_hist(x,[0,7],10)
    plot(1:0.001:6-0.001,density,'r')
    ylabel('Density')
    xlabel('Value');
    set(gca,'XLim',[0,7])
    %hold off
    
subaxis(2,3,5, 'Spacing', 0.03, 'Padding', 0.03, 'Margin', 0.015)
    hold on
    gen_norm_hist(x,[0,7],100)
    plot(1:0.001:6-0.001,density,'r')
    ylabel('Density')
    xlabel('Value');
    %set(gca,'YLim',[0,0.2])
    set(gca,'XLim',[0,7])
    
subaxis(2,3,6, 'Spacing', 0.03, 'Padding', 0.03, 'Margin', 0.015)
    hold on
    plot(1:0.001:6-0.001,density,'r')
    gen_norm_hist(x,[0,7],1000)
    ylabel('Density')
    xlabel('Value');
    %set(gca,'YLim',[0,0.2])
    set(gca,'XLim',[0,7])


end

%% ANOTHER EXAMPLE
% This is an implementation of basic MCMC to solve the Knapsack Problem @:
% http://www.cs.cornell.edu/selman/cs475/lectures/intro-mcmc-lukas.pdf

% Problem definition:
% Given m items with weights w[i] and values v[i], and a knapsack with
% weight limit b, find the most valuable subset of items that fit.

% Representation:
% z = (z1, ..., z2) in {0,1}^m means we take item i
% feasible solutions: omega = { z ; sum(w[i]*z[i] <= b}
% problem: maximize sum( v[i]*z[i] ) subject to z in omega.

% Algorithm: Given current X[t] = (z1, ..., zm), generate X[t+1] by...
% 1) Choosing J in {1,...,m} randomly
% 2) Flip z[j], i.e. let y = (z1, ..., 1-z[j], ..., z[m])
% 3) if y is not feasible then let X[t+1] = X[t]
% 4) if y is feasible set X[t+1] = y with prob. alpha, otherwise as in (3)

% Here alpha is min{1, exp(beta * sum(v[i]*( y[i] - z[i] )) )}

% Target distribution:
% pi(Z) = 1/C_beta * exp(beta* sum(v[i]z[i]))


% MCMC for sampling from a uniform distribution...

% Ordinary Monte Carlo:
% Calculate expectation mu = E[g(X)] where g is a real-valued function on
% the state space in which X is a random variable.

% EX 1.
% mu is expectation of uniform random numbers from X.

% EX 2.
% mu is expectation of square of floor of random numbers from X.

% Suppose one can simulate i.i.d. samples from X. Define
% mu_hat_n = 1/n * sum(g(X[i])). If we introduce Y[i] = g(X[i]) then Y[i]
% are i.i.d. with mean mu and variance sigma^2 = var[g(X)]. Also, mu_hat_n
% is the sample mean of Y[i] and the CLT indicates that it 's normally
% distributed around mu with variance sigma^2 / n.

% The variance can be estimated with the sample variance sigma_hat_n^2 =
% 1/n * sum((g(X[i]) - mu_hat_n)^2)


%% YET ANOTHER

% This is an implementation of basic MCMC to solve the Knapsack Problem @:
% http://www.cs.cornell.edu/selman/cs475/lectures/intro-mcmc-lukas.pdf

% Problem definition:
% Given m items with weights w[i] and values v[i], and a knapsack with
% weight limit b, find the most valuable subset of items that fit.

% Representation:
% z = (z1, ..., z2) in {0,1}^m means we take item i
% feasible solutions: omega = { z ; sum(w[i]*z[i] <= b}
% problem: maximize sum( v[i]*z[i] ) subject to z in omega.

% Algorithm: Given current X[t] = (z1, ..., zm), generate X[t+1] by...
% 1) Choosing J in {1,...,m} randomly
% 2) Flip z[j], i.e. let y = (z1, ..., 1-z[j], ..., z[m])
% 3) if y is not feasible then let X[t+1] = X[t]
% 4) if y is feasible set X[t+1] = y with prob. alpha, otherwise as in (3)

% Here alpha is min{1, exp(beta * sum(v[i]*( y[i] - z[i] )) )}

% Target distribution:
% pi(Z) = 1/C_beta * exp(beta* sum(v[i]z[i]))
