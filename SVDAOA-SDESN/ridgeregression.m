
function [ W ] = ridgeregression( X, Y, esn)

W = Y'*X'*pinv(X*X'+esn.lambda*eye(size(X,1))); 
end

