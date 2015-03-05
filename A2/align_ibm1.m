function AM = align_ibm1(trainDir, numSentences, maxIter, fn_AM)
%
%  align_ibm1
% 
%  This function implements the training of the IBM-1 word alignment algorithm. 
%  We assume that we are implementing P(foreign|english)
%
%  INPUTS:
%
%       dataDir      : (directory name) The top-level directory containing 
%                                       data from which to train or decode
%                                       e.g., '/u/cs401/A2_SMT/data/Toy/'
%       numSentences : (integer) The maximum number of training sentences to
%                                consider. 
%       maxIter      : (integer) The maximum number of iterations of the EM 
%                                algorithm.
%       fn_AM        : (filename) the location to save the alignment model,
%                                 once trained.
%
%  OUTPUT:
%       AM           : (variable) a specialized alignment model structure
%
%
%  The file fn_AM must contain the data structure called 'AM', which is a 
%  structure of structures where AM.(english_word).(foreign_word) is the
%  computed expectation that foreign_word is produced by english_word
%
%       e.g., LM.house.maison = 0.5       % TODO
% 
% Template (c) 2011 Jackie C.K. Cheung and Frank Rudzicz
  
  global CSC401_A2_DEFNS
  
  AM = struct();

  % Read in the training data
  [eng, fre] = read_hansard(trainDir, numSentences);

  % Initialize AM uniformly 
  AM = initialize(eng, fre);
  % Iterate between E and M steps
  for iter=1:maxIter,
    AM = em_step(AM, eng, fre);
  end

  % Manually add back in SENTSTART and SENTEND
  AM.SENTSTART.SENTSTART = 1;
  AM.SENTEND.SENTEND = 1;

  % Save the alignment model
  save( fn_AM, 'AM', '-mat'); 

  end





% --------------------------------------------------------------------------------
% 
%  Support functions
%
% --------------------------------------------------------------------------------

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
	elines = textread([mydir, filesep, DE(iFile).name], '%s','delimiter','\n');
    flines = textread([mydir, filesep, DF(iFile).name], '%s','delimiter','\n');
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


function AM = initialize(eng, fre)
%
% Initialize alignment model uniformly.
% Only set non-zero probabilities where word pairs appear in corresponding sentences.
%
    AM = struct(); % AM.(english_word).(foreign_word)

    % TODO: your code goes here
	% First, we will add all counts, and then normalize after
	% Notice that we go from second to 1 before last so we ignore
	% SENTSTART and SENTEND
	for sen=1:length(eng)
		for i=2:length(eng{sen})-1
			for j=2:length(fre{sen})-1
				if ~isfield(AM, eng{sen}{i})
					AM.(eng{sen}{i}) = struct();
				end
				if ~isfield(AM.(eng{sen}{i}), fre{sen}{j})
					AM.(eng{sen}{i}).(fre{sen}{j}) = 1;
				end
			end
		end
	end

	% Normalize our probabilities
	eng_w = fieldnames(AM);
	for i=1:length(eng_w)
		% Normalizing by summing over all french words for a given english word
		count = 0;
		fr_w = fieldnames(AM.(eng_w{i}));
		for j=1:length(fr_w)
			count = count + AM.(eng_w{i}).(fr_w{j});
		end
		for j=1:length(fr_w)
			AM.(eng_w{i}).(fr_w{j}) = AM.(eng_w{i}).(fr_w{j}) / count;
		end
	end
end

function t = em_step(t, eng, fre)
% 
% One step in the EM algorithm.
%
  % TODO: your code goes here
	% Get our lists of english and french words
	eng_w = fieldnames(t); 
	fr_w = {};
	for i=1:length(eng_w)
		fr_w = [fr_w; fieldnames(t.(eng_w{i}))];
	end

	% Initialize stuff
	fr_w = unique(fr_w);
	tcount = struct();
	total = struct();

	% Fill in tcount and total
	for sen=1:length(eng)
		uniq_fr = unique(fre{sen});
		uniq_eng = unique(eng{sen});
		% Remove SENTSTART and SENTEND
		uniq_fr = uniq_fr(~strcmp(uniq_fr(:), 'SENTEND') & ~strcmp(uniq_fr(:), 'SENTSTART'));
		uniq_eng = uniq_eng(~strcmp(uniq_eng(:), 'SENTEND') & ~strcmp(uniq_eng(:), 'SENTSTART'));
		for i=1:length(uniq_fr)
			denom_c = 0;
			for j=1:length(uniq_eng)
				% denom_c += P(f|e) * F.count(f)
				denom_c = denom_c + t.(uniq_eng{j}).(uniq_fr{i}) * sum(strcmp(fre{sen},uniq_fr{i}));
			end
			for j=1:length(uniq_eng)
				% If we haven't encountered these yet, initialize struct appropriately
				if ~isfield(tcount, uniq_fr{i})
					tcount.(uniq_fr{i}) = struct();
				end
				if ~isfield(tcount.(uniq_fr{i}), uniq_eng{j})
					tcount.(uniq_fr{i}).(uniq_eng{j}) = 0;
				end
				if ~isfield(total, uniq_eng{j})
					total.(uniq_eng{j}) = 0;
				end

				% Compute P(f|e) * F.count(f) * E.count(e) / denom_c
				to_add = t.(uniq_eng{j}).(uniq_fr{i}) * sum(strcmp(fre{sen},uniq_fr{i})) * sum(strcmp(eng{sen},uniq_eng{j})) / denom_c;

				%tcount(f,e) += P(f|e) * F.count(f) * E.count(e) / denom_c
				tcount.(uniq_fr{i}).(uniq_eng{j}) = tcount.(uniq_fr{i}).(uniq_eng{j}) + to_add;
				%total(e) += P(f|e) * F.count(f) * E.count(e) / denom_c
				total.(uniq_eng{j}) = total.(uniq_eng{j}) + to_add;
			end
		end
	end

	% Update our model
	for i=1:length(eng_w)
		fre_w = fieldnames(t.(eng_w{i}));
		for j=1:length(fre_w)
			t.(eng_w{i}).(fre_w{j}) = tcount.(fre_w{j}).(eng_w{i}) / total.(eng_w{i});
		end
	end

end


