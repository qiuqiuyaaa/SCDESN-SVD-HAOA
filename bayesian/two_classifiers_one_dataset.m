function [probs,plot_data] = two_classifiers_one_dataset(x, rope, cvruns)
% -------------------------------------------------------------------------
% Compute probabilities using a Bayesian correlated t-test. This function 
% was created using the text of the paper [Benavoli et al., 2017].
%
% Input: 
%     x = difference between the accuracies of classifiers A and B in a
%         cross-validation experiment
%     rope = the rope value ( = 1), assuming the accuracies are in [%] 
%     cvruns = how many times cross-validation was repeared ( = 1) 
%
% Output: 
%     probs = (A << B, A == B (rope), A >> B)
%     plot_data = the distributsion curve
% -------------------------------------------------------------------------
% L.Kuncheva 23/08/2020
%
if nargin == 1
    rope = 1; cvruns = 1;
elseif nargin == 2 || cvruns == 0
    cvruns = 1;
end

n = numel(x);
k = n/cvruns; % k-fold CV
rho = 1/k; % ratio between testing size and training size
v = var(x);
s = (1/n+rho/(1-rho))*v;
mu = mean(x);

% Create a t Location-Scale Distribution
% (Extended Student distribution)
pd = makedist('tLocationScale','mu',mu,'sigma',sqrt(s),'nu',n-1);

probs(1) = cdf(pd,-rope);
probs(2) = cdf(pd,rope) - cdf(pd,-rope);
probs(3) = cdf(pd,rope,'upper');

x = linspace(min(x)-0.005*min(x),max(x)+0.005*max(x));
y = pdf(pd,x);

plot_data(:,1) = x(:);
plot_data(:,2) = y(:);
