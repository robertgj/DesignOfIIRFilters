%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modified by Kojima, 02/06/2005
% This module includes
% 	subStituteEq(basisSupports,ineqPolySys,ConstraintInfo);
% M. Kojima, 02/15/2005
% SubStituteEq ---> substituteEq
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
function [objPoly, val, basisSupports,momentSup,ineqBasis] = substituteEq(objPoly, basisSupports,ineqBasis,ineqPolySys,CompSup,binarySup, SquareOneSup,param)

% This function inserts simple equations into basisSupports,
% not Moment matrix.
% 

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

noOfBasisSupports = size(basisSupports,2);
[m,n] = size(CompSup);
if m*n == 0
   param.complementaritySW = 0; 
end

%%
%% Substitute complementarities into all basisSupports.
%%
if param.complementaritySW == 1 && ~isempty(CompSup)
    for i=1:noOfBasisSupports
        SupSet = basisSupports{i};
        SupSet = spones(SupSet);
        P = SupSet*CompSup';
        P = max(P,[],2);
        I = find(P == 2);
        if ~isempty(I)
            basisSupports{i}(I,:) = [];
        end
    end
end

% 
% 2009-12-21 H.Waki
% Substitute xi^2 = 1 into all basisSupports.
%
if param.SquareOneSW == 1 && ~isempty(SquareOneSup)
	for i=1:noOfBasisSupports
		SupSet = substituteSqOne(basisSupports{i}, SquareOneSup);
		basisSupports{i} = SupSet;
	end
end

% 
% 2011-04-29 H.Waki
% Substitute xi^2 = xi into all basisSupports.
%
%param.binarySW = 0;
if param.binarySW == 1 && ~isempty(binarySup)
	for i=1:noOfBasisSupports
		SupSet = substitutebinary(basisSupports{i}, binarySup);
		basisSupports{i} = SupSet;
	end
end

%%
%% Substitute into monomials appeared in localizing mat.
%%
if param.boundSW > 0 && param.complementaritySW == 1 && ~isempty(CompSup)
    SupSet = ineqBasis;
    SupSet = spones(SupSet);
    P = SupSet*CompSup';
    P = max(P,[],2);
    I = find(P == 2);
    if ~isempty(I)
       ineqBasis(I,:) = []; 
    end
end

% 
% 2009-12-21 H.Waki
% Substitute xi^2 = 1 into monomials appeared in localizing mat..
%
if param.boundSW > 0 && param.SquareOneSW == 1 && ~isempty(SquareOneSup)
	SupSet = substituteSqOne(ineqBasis, SquareOneSup);
	ineqBasis = SupSet;
end
% 
% 2011-04-29 H.Waki
% Substitute xi^2 = xi into monomials appeared in localizing mat..
%
if param.boundSW > 0 && param.binarySW == 1 && ~isempty(binarySup)
	SupSet = substitutebinary(ineqBasis, binarySup);
	ineqBasis = SupSet;
end

%%
%% Gather all monomials appeared in Moment Mat. and 
%% if monomials can be removed by complimentarity, we can do it!
%%
if param.boundSW > 0
    t = size(basisSupports,2);
    s = size(ineqPolySys,2);
    momentSup = [];
    for j = s+1:t
        SupSet = makeMoment(basisSupports{j});
        if param.complementaritySW == 1 && ~isempty(CompSup)
            tempSet = spones(SupSet);
            P = tempSet*CompSup';
            P = max(P,[],2);
            I = find(P == 2);
            if ~isempty(I)
                SupSet(I,:) = [];
            end
        end
        momentSup = [momentSup;SupSet];
    end
else
    momentSup = [];
end

%
% 2009-12-21 H.Waki
% Gather all monomials appeared in Moment Mat. and 
% if monomials can be removed by xi^2=1, we can do it!
%
if param.boundSW > 0 && param.SquareOneSW == 1 && ~isempty(SquareOneSup)
	SupSet = substituteSqOne(momentSup, SquareOneSup);
end

%
% 2011-04-29 H.Waki
% Gather all monomials appeared in Moment Mat. and 
% if monomials can be removed by xi^2=xi, we can do it!
%
if param.boundSW > 0 && param.binarySW == 1 && ~isempty(binarySup)
	SupSet = substitutebinary(momentSup, binarySup);
end

%
% 2011-06-22 H.Waki
% Reduce the objective function
%
if param.complementaritySW == 1 && ~isempty(CompSup)
        tmpSup = objPoly.supports;
        tmpSup = spones(tmpSup);
        P = tmpSup*CompSup';
        P = max(P,[],2);
        I = find(P == 2);
        if ~isempty(I)
		objPoly.supports(I,:) = [];
		objPoly.coef(I,:) = 0;
        end
end
if param.SquareOneSW == 1 && ~isempty(SquareOneSup)
	tmpSet = objPoly.supports(:, SquareOneSup);
	[mDim, nDim] = size(tmpSet);
	[Row, Col, Val] = find(mod(tmpSet, 2) == 1);
	tmpSet = sparse(Row, Col, 1, mDim, nDim);	
	objPoly.supports(:, SquareOneSup) = tmpSet;
end
if param.binarySW == 1 && ~isempty(binarySup)
	tmpSet = objPoly.supports(:, binarySup);
	[mDim, nDim] = size(tmpSet);
	[Row, Col, Val] = find(tmpSet);
	tmpSet = sparse(Row, Col, 1, mDim, nDim);	
	objPoly.supports(:, binarySup) = tmpSet;
end
objPoly = simplifyPolynomial(objPoly);
CTermIndex = find(any(objPoly.supports, 2) == 0);
val = 0.0;
if ~isempty(CTermIndex)
	val = sum(objPoly.coef(CTermIndex,1),1);
	objPoly.supports(CTermIndex,:) = [];
	objPoly.coef(CTermIndex,:) = [];
	objPoly.noTerms = objPoly.noTerms - length(CTermIndex);
end


return

function Sup = makeMoment(basisSupports)

% This function returns monomials appeared in Moment matrix and
% their row and column indeces.
%
% Sup is monomial set.

[m1,nDim] = size(basisSupports);
[Col,Row] = find(tril(ones(m1)));
Sup = sparse(length(Row),nDim);
UsedVar = find(any(basisSupports,1));
Sup(:,UsedVar) = basisSupports(Row,UsedVar) + basisSupports(Col,UsedVar);
return

%
% 2009-12-21 H. Waki
%
function NewSupSet = substituteSqOne(SupSet, sqonidx)
	tmpSet = SupSet(:, sqonidx);
	[mDim, nDim] = size(tmpSet);
	[Row, Col, Val] = find(mod(tmpSet, 2) == 1);
	tmpSet = sparse(Row, Col, 1, mDim, nDim);	
	SupSet(:, sqonidx) = tmpSet;
	%NewSupSet = SupSet;
	NewSupSet = my_unique(SupSet, 'rows');
return

%
% 2011-04-29 H. Waki
%
function NewSupSet = substitutebinary(SupSet, binaryidx)
	tmpSet = SupSet(:, binaryidx);
	[mDim, nDim] = size(tmpSet);
	[Row, Col, Val] = find(tmpSet);
	tmpSet = sparse(Row, Col, 1, mDim, nDim);	
	SupSet(:, binaryidx) = tmpSet;
	%NewSupSet = SupSet;
	NewSupSet = my_unique(SupSet, 'rows');
return
