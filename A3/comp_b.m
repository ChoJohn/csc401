function b = comp_b(mfcc, M, gmm)
% Helper functions which computes TxM matrix of log(b_m(x_t))'s
% input: mfcc: concatenated training data for user
%        M: number of components in model
%		 gmm: The appropriate struct for the current speaker's model

% output: b: TxM matrix of log(b_m(x_t))'s

% D is number of dimensions, T is number of training cases
  D = size(mfcc,2);
  T = size(mfcc,1);

% First compute log of numerator
  num = zeros(T, M);
  for i=1:dims
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
  b = num - den;

end
