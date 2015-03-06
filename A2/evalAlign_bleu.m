% Assumes LME, am are loaded as in evalAlign.m

testFile     = '/u/cs401/A2_SMT/data/Hansard/Testing/Task5';

[eng, fre] = load_test(testFile);

scores = {};
for model=1:length(am)
	trans = {};
	for i=1:length(fre)
		trans{i} = decode2(fre{i}, LME, am{model}, '');
	end
	scores{model} = score_bleu(trans, eng, 4);
	disp('Done with a model');
end
