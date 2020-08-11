function SUP = addSup(A, B, uniqueSW)
if nargin == 2
	uniqueSW = 0;
end
mDimA = size(A, 1);
mDimB = size(B, 1);
aidx  = 1:mDimA;
aidx  = aidx(ones(1, mDimB), :);
aidx  = aidx(:);
bidx  = (1:mDimB)';
bidx  = bidx(:, ones(1, mDimA));
bidx  = bidx(:);
SUP   = A(aidx, :) + B(bidx, :); 
if uniqueSW == 1
	SUP = my_unique(SUP, 'rows');
end
return
