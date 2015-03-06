%
% evalAlign
%
%  This is simply the script (not the function) that you use to perform your evaluations in 
%  Task 5. 

% some of your definitions
trainDir     = '/u/cs401/A2_SMT/data/Hansard/Training/';
testFile     = '/u/cs401/A2_SMT/data/Hansard/Testing/Task5';
fn_LME       = '~/LM_e';
fn_LMF       = '~/LM_f';
fn_AM        = '~/AM_';
sizes        = {1000, 10000, 15000, 30000, 100000};

% Train your language models. This is task 2 which makes use of task 1
LME = lm_train( trainDir, 'e', fn_LME );
LMF = lm_train( trainDir, 'f', fn_LMF );

% Train your alignment model of French, given English 
%AMFE = align_ibm1( trainDir, numSentences );
% ... TODO: more 
% This is the code that would create the models I used, actally training them would take ~15 hours total

am = {};
for i=1:length(sizes)
	am{i} = align_ibm1(trainDir, sizes{i}, 10, strcat(fn_AM, int2str(sizes{i}/1000), 'K'));
end

% TODO: a bit more work to grab the English and French sentences. 
%       You can probably reuse your previous code for this  

% This is hard-coded because of the weird format; there are many files in this directory and I only want this one
[eng, fre] = load_test(testFile);

% TODO: perform some analysis
prop = {};
for model=1:length(am)
	total = 0;
	correct = 0;
	for i=1:length(fre)
		trans = decode2(fre{i}, LME, am{model}, '');
		correct = correct + score_align(strsplit(' ', trans), strsplit(' ', eng{i}));
		total = total + length(strsplit(' ', trans)) - 2;
		disp(strcat('Finished ', int2str(i)));
	end
	disp(int2str(correct));
	disp(int2str(total));
	prop{model} = correct / total;
	disp(strcat('Done with model ', int2str(model)));
end

