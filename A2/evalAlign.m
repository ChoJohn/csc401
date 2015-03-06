%
% evalAlign
%
%  This is simply the script (not the function) that you use to perform your evaluations in 
%  Task 5. 

% some of your definitions
trainDir     = '/u/cs401/A2_SMT/data/Hansard/Training/';
testDir      = '/u/cs401/A2_SMT/data/Hansard/Testing/';
fn_LME       = '~/LM_e';
fn_LMF       = '~/LM_f';

% Train your language models. This is task 2 which makes use of task 1
%LME = lm_train( trainDir, 'e', fn_LME );
%LMF = lm_train( trainDir, 'f', fn_LMF );

% Train your alignment model of French, given English 
%AMFE = align_ibm1( trainDir, numSentences );
% ... TODO: more 
% This is the code that would create the models I used, actally training them would take ~15 hours

%sizes = {1000, 10000, 15000, 30000, 100000};
%am = {};
%for i=1:5
	%am{i} = align_ibm1('/u/cs401/A2_SMT/data/Hansard/Training/', sizes{i}, 10, strcat('~/AM_', int2str(sizes{i}/1000), 'K'));
%end

% TODO: a bit more work to grab the English and French sentences. 
%       You can probably reuse your previous code for this  
[eng, fre] = load_test('/u/cs401/A2_SMT/data/Hansard/Testing/Task5');

% TODO: perform some analysis
prop = {}
for model=1:length(am)
	total = 0;
	correct = 0;
	for i=1:length(fre)
		trans = decode(fre{i}, LME, am{model}, '');
		correct = correct + score_align(trans, eng{i});
		total = total + length(trans) - 2;
	end
	prop{model} = correct / total;
end

