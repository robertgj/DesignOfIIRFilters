function [SDPinfo, xIdxVec] = getSeDuMiData(A, b, c, K, xIdxVec, SDPinfo, nzRowIdxUMat)
if nargin == 6
	mDim = size(A, 1); 
	nzRowIdxUMat = 1:mDim;
end
SDPinfo.SeDuMiA = A;
SDPinfo.SeDuMib = b;
SDPinfo.SeDuMic = c;
SDPinfo.SeDuMiK = K;
if any(xIdxVec(1,:), 2) == 0
	if size(xIdxVec, 1) ~= length(nzRowIdxUMat)+1
		%xIdxVec = xIdxVec(1+nzRowIdxUMat, :);
		xIdxVec = [xIdxVec(1,:);xIdxVec(1+nzRowIdxUMat, :)];
	end
else
	if size(xIdxVec, 1) ~= length(nzRowIdxUMat)
		xIdxVec = xIdxVec(nzRowIdxUMat,:);
	end
end
return
