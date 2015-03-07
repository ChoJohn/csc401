function score = score_bleu(trans, orig, N)

% Implementation of bleu scoring 
% trans: cell array of cell arrays, representing sentences and then words inside them. We treat this as the translation
% orig: cell array of cell arrays, representing sentences and then words inside them. We treat this is as the reference corpus
% N: max size of n-grams we will consider

	for i=1:length(trans)
		orig{i} = strsplit(' ', orig{i});
		trans{i} = strsplit(' ', trans{i});
	end

	% Compute brevity penalty
	hyp_length = sum(cellfun('length', trans)) - 2*length(trans);	
	orig_length = sum(cellfun('length', orig)) - 2*length(orig);
	if hyp_length > orig_length
		bp = 1;
	else
		bp = exp(1-orig_length/hyp_length);
	end
	exponent = 0;
	for n=1:N
		% We give them all equal weighting
		exponent = exponent + 1/N * log(mod_prec(trans, orig,n));
	end

	score = bp * exp(exponent);
end

% Helper function to compute the modified precision for n-grams of length n
function p_n = mod_prec(trans, orig, n)
	count = 0;
	count_matched = 0;
	for sen=1:length(trans)
		% - 2 for start and end, - (n-1) for amount of n-grams
		count = count + length(trans{sen}) - 1 - n;
		% Check matches
		for i=2:length(trans{sen})-n
			if is_matched(trans{sen}(i:i+n-1), orig{sen}, n)
				count_matched = count_matched + 1;
			end
		end
	end
	p_n = count_matched / count;
end

% Helper function to see if an n-gram is matched in the original sentence
function matched = is_matched(gram, orig, n)
	for i=2:length(orig)-n
		matched = 1;
		for j=1:n
			if ~strcmp(gram{j}, orig{i})
				matched = 0;
				break;
			end
		end
		if matched
			return
		end
	end

	matched = 0;
	return
end

