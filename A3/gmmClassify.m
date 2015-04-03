% Set M, eps value (these are the settings I used to generate my files before doing any experimentation)
M = 8;
eps = 0.1;
% Get trained models
[gmms, train_liks] = gmmTrain('/u/cs401/speechdata/Training', 100, eps, M);

test_files = dir('/u/cs401/speechdata/Testing/unkn_*.mfcc');
% Get test files into numeric order
names = {test_files.name};
S = sprintf('%s,', names{:});
D = sscanf(S, 'unkn_%d.mfcc,');
[~, name_indices] = sort(D);
test_names = names(name_indices);
test_liks = zeros(1,size(test_names, 2));
% For scoring purposes
labels = {'MMRP0','MPGH0','MKLW0','FSAH0','FVFB0','FJSP0','MTPF0','MRDD0','MRSO0','MKLS0','FETB0','FMEM0','FCJF0','MWAR0','MTJS0'};
top_5_count = 0;
top_1_count = 0;

% Go through all test files, find the max, and output to the appropriate file
for i=1:size(test_names, 2)
  % Load files
  test_mfcc = load(strcat('/u/cs401/speechdata/Testing/', test_names{i}));
  % Get each likelihood
  liks = zeros(1,size(gmms,2));
  for j=1:size(gmms,2)
	[~,ll] = comp_b_ll(test_mfcc, M, gmms{j});
	liks(j) = ll;
  end
  % Find top hits, print to file
  [res, ind] = sortrows(liks', -1);
  %disp(ind(1:5));
  %disp(res(1:5));
  write_name = strcat('~/401A3res/unkn_', int2str(i), '.lik');
  fileID = fopen(write_name, 'w');
  for j=1:5
	  if j == 1
	    test_liks(i) = res(j);
      end
	  if i <= 15
		  if strcmp(gmms{ind(j)}.name, labels(i))
			top_5_count = top_5_count + 1;
			if j == 1
				top_1_count = top_1_count + 1;
			end
		  end
	  end
	  fprintf(fileID, '%2.4f\t%s\n', res(j), gmms{ind(j)}.name);
  end
end
% Print counts of hits in top 5 and top 1
disp(top_1_count);
disp(top_5_count);
% Print average train likelihood per model
disp(mean(nonzeros(train_liks)));
% Print the average likelihood for best match
disp(mean(test_liks));
