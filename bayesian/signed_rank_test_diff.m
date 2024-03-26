function [samples, probs] = signed_rank_test_diff(x,rope,prior,T)
% -------------------------------------------------------------------------
% Input: 
%     x = difference between the accuracies of classifiers A and B
%     rope = the rope value ( = 1), assuming the accuracies are in [%] 
%     prior = "prior strength" (recommended value 0.5)
%     T = number of repetitions (50,000 -- 150,000)
%
% Output: 
%     sample = an array of size Tx3. Column 1: theta_left, column 2: 
%              theta_rope, column 3: theta_right. If rope == 0, the 
%              middle column contains NaN.
%     probs =  [p_left, p_rope, p_right]
% -------------------------------------------------------------------------
% L.Kuncheva 26/06/2020

% Translated from Janez Demsar's library baycomp
% https://github.com/janezd/baycomp/blob/master/baycomp/multiple.py

% See also
% https://baycomp.readthedocs.io/en/latest/

% Paper: [A. Benavoli, G. Corani, J. Demsar, M. Zaffalon, "Time for a
% Change: a Tutorial for Comparing Multiple Classifiers Through Bayesian
% Analysis", Journal of Machine Learning Research 18 (2017) 1-36.]


heaviside = @(a,thresh) (a>thresh) + (0.5*(a==thresh));

weights = [prior, ones(1,numel(x))];
x = [0; x(:)]'; % add z0 = 0
N = numel(x);
sums = diff_sums(x);

above_rope = heaviside(sums, 2*rope);
below_rope = heaviside(-sums, 2*rope);
above_0 = heaviside(sums, 0);

A = gamrnd(repmat(weights,T,1),1);
A = A./repmat(sum(A,2),1,N); % Dirichlet priors

samples = zeros(T,3);

if rope
    for i = 1:T
        w = A(i,:); % sampled weights
        prod_weights = w' * w; % outer product
        samples(i,1) = sum(sum(prod_weights .* below_rope));
        samples(i,3) = sum(sum(prod_weights .* above_rope));
    end
    samples(:,2) = 1 - samples(:,1) - samples(:,3);
    
else
    for i = 1:T
        w = A(i,:); % sampled weights
        prod_weights = w' * w; % outer product
        samples(i,3) = sum(sum(prod_weights .* above_0));
    end
    samples(:,1) = 1 - samples(:,3);
    samples(:,2) = nan;
end

[~,winners] = max(samples,[],2);
t = tabulate(winners);

p_left = t(t(:,1) == 1,3);
p_right = t(t(:,1) == 3,3);
p_rope = t(t(:,1) == 2,3);

probs = [p_left, p_rope, p_right];

end
function z = diff_sums(x)
n = numel(x);
z = repmat(x',1,n) + repmat(x,n,1);
% This is Demsar's function diff_sums assuming that the sum has been 
% already calculated in x, and 0 (z0) is appended at the beginning. 
end


