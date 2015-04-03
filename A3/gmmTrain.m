function [gmms, liks] = gmmTrain( dir_train, max_iter, epsilon, M )
% gmmTain
%
%  inputs:  dir_train  : a string pointing to the high-level
%                        directory containing each speaker directory
%           max_iter   : maximum number of training iterations (integer)
%           epsilon    : minimum improvement for iteration (float)
%           M          : number of Gaussians/mixture (integer)
%
%  output:  gmms       : a 1xN cell array. The i^th element is a structure
%                        with this structure:
%                            gmm.name    : string - the name of the speaker
%                            gmm.weights : 1xM vector of GMM weights
%                            gmm.means   : DxM matrix of means (each column 
%                                          is a vector
%                            gmm.cov     : DxDxM matrix of covariances. 
%                                          (:,:,i) is for i^th mixture
%           liks       : a 1x30 array of the final log likelihoods
	liks = zeros(1,30);
	speakers = dir(dir_train);
	gmms = {};
	curr_speak = 0;
  for i=1:size(speakers,1)
	  % Load data
 	if strcmp(speakers(i).name, '.') || strcmp(speakers(i).name, '..')
	 continue
	end	 
	curr_speak = curr_speak + 1;
	gmms{curr_speak} = struct();
	gmms{curr_speak}.name = speakers(i).name;
	mfccs = dir(strcat(dir_train, '/', speakers(i).name, '/*.mfcc'));
	mfcc = [];
	for j=1:size(mfccs,1)
	  to_load = strcat(dir_train, '/', speakers(i).name, '/', mfccs(j).name);
	  single = load(to_load);
	  mfcc = [mfcc; single];
	end
	p = randperm(size(mfcc,1));
	mfcc = mfcc(p,:);

	% Random initialize
	[mus, sigmas, omegas] = initialize(mfcc, M);
	gmms{curr_speak}.weights = omegas;
	gmms{curr_speak}.means = mus;
	gmms{curr_speak}.cov = sigmas;

	% Do actual training
	prev_L = -Inf;
	improvement = Inf;
	j = 0;
	while j <= max_iter && improvement > epsilon
      [mus, sigmas, omegas, ll] = em_step(mfcc, M, gmms{curr_speak});
	  gmms{curr_speak}.weights = omegas;
	  gmms{curr_speak}.means = mus;
	  gmms{curr_speak}.cov = sigmas;
	  improvement = ll - prev_L;
	  prev_L = ll;
	  i;
	  j;
	  j = j+1;
	end
	liks(i) = ll;
  end
end

function [mus, sigmas, omegas] = initialize(mfcc, M)
  % Initialize mus to random lines from the data
  % (data is already shuffled)
  D = size(mfcc,2);
  mus = mfcc(1:M, :)';
  % Initialize omegas to 1/M, sigmas to identity
  omegas = 1/M * ones(1,M);
  sigmas = repmat(eye(D),1,1,M);
end

function [mus, sigmas, omegas, ll] = em_step(mfcc, M, gmm)
  % D is number of dimensions, T is number of training cases
  D = size(mfcc,2);
  T = size(mfcc,1);
  % First do E-step, compute conditional probability and ll

  % First, compute our TxM matrix of b's and ll
  [b, ll] = comp_b_ll(mfcc, M, gmm);
  
  % Compute conditional probabilities p(m|x_t,theta) so we can use it in M-step
  wb = repmat(gmm.weights,T,1) .* exp(b);
  conds = wb ./ repmat(sum(wb, 2), 1, M);

  % M-step, compute our updates
  % Precompute the sum we're going to use a lot
  sum_t_conds = sum(conds, 1);
  omegas = sum_t_conds / T;
  mus = mfcc' * conds ./ repmat(sum_t_conds, D, 1);
  % We will have to expand sigmas to diagonals, but first compute it like this
  comp_sigmas = ((mfcc.^2)' * conds ./ repmat(sum_t_conds, D, 1)) - mus.^2;
  sigmas = zeros(D,D,M);
  % Expand them
  for i=1:M
    sigmas(:,:,i) = diag(comp_sigmas(:,i));
  end
end
		
