function score = score_align(trans, orig)

% Score using our ad-hoc metric with 
% trans: the result of using our decoder
% orig: the true english translation.

% We will ignore the sentence start and end
	score = 0;
	for i=2:min(length(trans), length(orig))-1
		if strcmp(trans{i}, orig{i})
			score = score + 1;
		end
	end
	
	score = score / length(trans);

end
