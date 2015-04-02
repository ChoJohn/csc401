function [b, ll] = comp_b_ll(mfcc, M, gmm)
% Helper functions which computes TxM matrix of log(b_m(x_t))'s and log likelihood
% input: mfcc: concatenated training data for user TxD
%        M: number of components in model
%		 gmm: The appropriate struct for the current speaker's model

% output: b: TxM matrix of log(b_m(x_t))'s
%          ll: log likelihood of data under model

% D is number of dimensions, T is number of training cases
  D = size(mfcc,2);
  T = size(mfcc,1);

% First compute log of numerator
  num = zeros(T, M);
  for i=1:D
	num = num + (repmat(mfcc(:,i),1,M) - repmat(gmm.means(i,:),T,1)).^2 ./ squeeze(repmat(gmm.cov(i,i,:),1,T,1));
  end
  num = -1/2 * num;

  % More compact/easy form to use covs in
  comp_covs = zeros(D,M);
  for i=1:M
	comp_covs(:,i) = diag(gmm.cov(:,:,i));
  end

  % Log of denominator
  den = D/2*log(2*pi) + 1/2*repmat(sum(log(comp_covs),1),T,1);

  % Compute b
  b = num - den;

  % Compute log likelihood
  wb = gmm.weights * exp(b)';
  ll = sum(log(wb), 2) / T;

end
