function ll = comp_ll(b, gmm, mfcc)
% Compute the log likelihood of given data under model in GMM
% input: b: TxM matrix of log(b_m(x_t))'s returned by comp_b
%        gmm: The current model
%        mfcc: The data we are computing the likelihood of

  wb = gmm.weights * exp(b)';
  ll = sum(log(wb), 2)
end
