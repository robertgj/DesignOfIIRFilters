function [reduceAMatSW,infeasibleSW,A,b,PMat,QMat,nzRowIdxUMat,x,y] = reduceSizeA4(A,b,c,K); 
% Cheking the linear dependence of the row vectors of the matrix A.
% If they are linearly dependent, then  
% (a) reduce the system of equations A x = b,
% (b) detect whether it is infeasible, and/or
% (c) compute the unique feasible solution if the system is nonsingular and
% square.

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is a component of SparsePOP 
% Copyright (C) 2007 SparsePOP Project
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
debugSW = 0;
%full([A, -b])
%rank(full([A, -b]))
%size([A, -b])
if debugSW == 1
	%full([A, -b])
	%rank(full([A, -b]))
	%size([A, -b])
	EPS = eps*max(size(A))*norm(A,inf);
	dA = A;
	db = b;
	dreduceAMatSW = 0;
	dinfeasibleSW = 0;
end
reduceAMatSW = 0;
infeasibleSW = 0; 
x = [];
y = [];
[rowSizeAorg,colSizeAorg] = size(A); 

method = 'lu';;
if strcmp(method, 'lu')
	%sTime = tic;
	[indepColIdx, feasibilitySW] = removeDependColumns1(A',b');
	[mDim, nDim] = size(A);
	idx = 1:mDim;
	addIdx = setdiff(idx, indepColIdx);	
	colIdx = [indepColIdx, addIdx];
	rowIdx = 1:nDim;
	%cput = toc(sTime);
	%fprintf('## cputime of finding linealy dependency by LU = %3.2f[sec]\n', cput);
else
	error('method should be gauss or lu.');
end

[mDim, nDim] = size(A);
nzRowIdxUMat = indepColIdx;
PMat = sparse(colIdx,(1:mDim),1,mDim, mDim, mDim);
QMat = sparse((1:nDim),rowIdx, 1,nDim, nDim, nDim);
if length(indepColIdx) < length(colIdx)
	fprintf('## The equality constraints of the SeDuMi format primal SDP are linearly dependent,\n'); 
	if length(colIdx) - length(indepColIdx) > 1 
        	fprintf('   so %d equalities are eliminated to restore the linear independence.\n',length(colIdx) - length(indepColIdx));
    	else
        	fprintf('   so 1 equality is eliminated to restore the linear independence.\n');
	end
	reduceAMatSW = 1; 
	if feasibilitySW == -1 
		infeasibleSW = 1; 
		fprintf('## The equality constraints of the SeDuMi format primal SDP are inconsistent,\n');
		fprintf('   so the primal SDP is infeasible.\n');
	else
		Areduced = A(indepColIdx,:); 
		breduced = b(indepColIdx,:);
		A = Areduced;               
		b = breduced;
		%full([A, -b])
	end
end
if debugSW == 1
	% the following is the previous function, but this does not work correctly.
	[LMat,UMat,dPMat,Q] = lu(dA); 
	[rowSizeLMat,colSizeLMat] = size(LMat); 
	% full(A)
	% full(b)
	% full(LMat)
	% full(UMat)
	if colSizeLMat < rowSizeLMat
		identityMatrix = speye(rowSizeLMat,rowSizeLMat); 
		LMat = [LMat, identityMatrix(:,(colSizeLMat+1):rowSizeLMat)]; 
	end
	diagAbsUMat = diag(abs(UMat));
	dnzRowIdxUMat = find(diagAbsUMat' > EPS);
	zeroRowIdxUMat = find(diagAbsUMat' <= EPS);
	rankUMat = length(dnzRowIdxUMat);
	if rankUMat < rowSizeLMat
		fprintf('## The equality constraints of the SeDuMi format primal SDP are linearly dependent,\n'); 
		if rowSizeLMat - rankUMat > 1 
        		fprintf('   so %d equalities are eliminated to restore the linear independence.\n',rowSizeLMat - rankUMat);
 	   	else
        		fprintf('   so %d equality is eliminated to restore the linear independence.\n',rowSizeLMat - rankUMat);
		end
		dreduceAMatSW = 1; 
		bTransformed = LMat\(dPMat * db);
		infesibilityError = norm(bTransformed(zeroRowIdxUMat,1)); 
		if infesibilityError > EPS
			dinfeasibleSW = 1; 
			fprintf('## The equality constraints of the SeDuMi format primal SDP are inconsistent,\n');
			fprintf('   so the primal SDP is infeasible.\n');
		else
			dAreduced = dPMat*dA; 
			dAreduced = dAreduced(dnzRowIdxUMat,:); 
			dbreduced = dPMat*db;
			dbreduced = dbreduced(dnzRowIdxUMat,:);
			dA = dAreduced;               
			db = dbreduced;
			%full([A, -b])
			%full([dA, -db])
		end
	end
	fprintf('gap of row = %3d\n', length(setdiff(dnzRowIdxUMat,indepColIdx)));
end
rowSizeAnew = size(A,1); 
%     full(A)
%     full(PMat)
if rowSizeAnew == colSizeAorg
	fprintf('## The equality constraints of the SeDuMi format primal SDP forms a nonsingular\n')
	fprintf('   square system which determines a unique primal solution if the SDP is feasible.\n'); 
	[x,y,infeasibleSW] = solveSquareSDP(A,b,c,K); 
	% infeasibleSW =  1 ---> primal SDP is infeasible
	% infeasibleSW = -1 ---> feasible, the SDP has been solved by solveSquareSDP 
	if infeasibleSW == 1
		fprintf('## The primal SDP is infeasible.\n');
	else 
		fprintf('## Primal and dual optimal solutions of the SDP are computed, so SeDuMi will not\n');
		fprintf('   be applied.\n');
	end
end
return

function [x,y,infeasibleSW] = solveSquareSDP(A,b,c,K); 
EPS = eps*max(size(A))*norm(A,inf);
if ~isempty(K.s)
	fprintf('## The coefficient matrix A is not legitimate! ##\n'); 
	exit;
end
infeasibleSW = -1; 
x = A\b; y = A'\c; 
pointer = K.f; 
if K.l > 0 
	i = pointer;
	while (i < pointer+K.l) & (infeasibleSW == -1) 
		i=i+1;
		if x(i) <= -EPS
			infeasibleSW = 1;
		end
	end
	pointer = pointer + K.l;
end
return
