%
% evalAlign
%
%  This is simply the script (not the function) that you use to perform your evaluations in 
%  Task 5. 

% some of your definitions
trainDir     = '/u/cs401/A2_SMT/data/Hansard/Training/';
testDir      = '/u/cs401/A2_SMT/data/Hansard/Testing/';
fn_LME       = TODO;
fn_LMF       = TODO;
numSentences = TODO;

% Train your language models. This is task 2 which makes use of task 1
%LME = lm_train( trainDir, 'e', fn_LME );
%LMF = lm_train( trainDir, 'f', fn_LMF );
% Load in previously trained language models
LME = load('~/out.lm', '-mat');
LME = LME.LM;
LMF = load('~/outf.lm', '-mat');
LMF = LMF.LM;

% Train your alignment model of French, given English 
%AMFE = align_ibm1( trainDir, numSentences );
% ... TODO: more 
% Load our alignment models

% TODO: a bit more work to grab the English and French sentences. 
%       You can probably reuse your previous code for this  

% Decode the test sentence 'fre'
eng = decode2( fre, LME, AMFE, '');

% TODO: perform some analysis





%%%%%% Helper functions %%%%%%%%%%

function [eng, fre] = read_hansard(mydir, numSentences)
%
% Read 'numSentences' parallel sentences from texts in the 'dir' directory.
%
% Important: Be sure to preprocess those texts!
%
% Remember that the i^th line in fubar.e corresponds to the i^th line in fubar.f
% You can decide what form variables 'eng' and 'fre' take, although it may be easiest
% if both 'eng' and 'fre' are cell-arrays of cell-arrays, where the i^th element of 
% 'eng', for example, is a cell-array of words that you can produce with
%
%         eng{i} = strsplit(' ', preprocess(english_sentence, 'e'));
%
  eng = {};
  fre = {};

  % TODO: your code goes here.
  % Get list of english and french files they will be aligned as the OS returns alphabetical order)
  DE = dir([mydir, filesep, '*', 'e']);
  DF = dir([mydir, filesep, '*', 'f']);
  linecount = 1;
  for iFile=1:length(DE)
	elines = textread([testDir, filesep, DE(iFile).name], '%s','delimiter','\n');
    flines = textread([testDir, filesep, DF(iFile).name], '%s','delimiter','\n');
	for i=1:length(elines)
		eng{linecount} = strsplit(' ', preprocess(elines{i}, 'e'));
		fre{linecount} = strsplit(' ', preprocess(flines{i}, 'f'));
		linecount = linecount + 1;
		if linecount > numSentences
			return
		end
	end
  end

end
