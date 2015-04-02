% Set M value
M = 8;
% Get trained models
gmms = gmmTrain('/u/cs401/speechdata/Training', 50, 0.1, M);

test_files = dir('/u/cs401/speechdata/Testing/unkn_*.mfcc');

% Go through all test files, find the max, and output to the appropriate file
for i=1:size(test_files,1)
  test_mfcc = load(strcat('/u/cs401/speechdata/Testing/', test_files{i}.name));
  liks = zeros(1,size(gmms,2));
  for i=1:size(gmms,2)
	[~,ll] = comp_b_ll(test_mfcc, M, gmms{i});
	liks(i) = ll;
  end
  [res, ind] = sortrows(liks);
  disp(ind(1:5));
  disp(res(1:5));
end
