function logProb = lm_prob(sentence, LM, type, delta, vocabSize)
%
%  lm_prob
% 
%  This function computes the LOG probability of a sentence, given a 
%  language model and whether or not to apply add-delta smoothing
%
%  INPUTS:
%
%       sentence  : (string) The sentence whose probability we wish
%                            to compute
%       LM        : (variable) the LM structure (not the filename)
%       type      : (string) either '' (default) or 'smooth' for add-delta smoothing
%       delta     : (float) smoothing parameter where 0<delta<=1 
%       vocabSize : (integer) the number of words in the vocabulary
%
% Template (c) 2011 Frank Rudzicz

  logProb = -Inf;

  % some rudimentary parameter checking
  if (nargin < 2)
    disp( 'lm_prob takes at least 2 parameters');
    return;
  elseif nargin == 2
    type = '';
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  end
  if (isempty(type))
    delta = 0;
    vocabSize = length(fieldnames(LM.uni));
  elseif strcmp(type, 'smooth')
    if (nargin < 5)  
      disp( 'lm_prob: if you specify smoothing, you need all 5 parameters');
      return;
    end
    if (delta <= 0) or (delta > 1.0)
      disp( 'lm_prob: you must specify 0 < delta <= 1.0');
      return;
    end
  else
    disp( 'type must be either '''' or ''smooth''' );
    return;
  end

  words = strsplit(' ', sentence);

  % TODO: the student implements the following
	logProb = 0;
	for i=1:len(words)-1
		% First, get our counts
		if isfield(LM.bi, words{i}) & isfield(LM.bi.(words{i}), words{i+1})
			numcount = LM.bi.(words{i}).(words{i+1});	
		else
			numcount = 0;
		end

		if isfield(LM.uni, words{i})
			dencount = LM.uni.(words{i});
		else
			dencount = 0;
		end
		
		% Next, compute numerator and denominator and add
		num = numcount + delta;
		den = dencount + delta * vocabSize;
		if den == 0 & num == 0
			logProb = -Inf
		else
			logProb += log2(num);
			logProb -= log2(den);
		end
	end	
  % TODO: once upon a time there was a curmudgeonly orangutan named Jub-Jub.
return
