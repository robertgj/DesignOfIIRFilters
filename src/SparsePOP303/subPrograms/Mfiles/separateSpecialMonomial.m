function [CompSup, binarySup, SquareOneSup, ConstraintInfo] = separateSpecialMonomial(inEqPolySys,param)
% Kojima, 02/15/2005
% Separate_Special_Monomial ---> separateSpecialMonomial
% function [ConstraintInfo] = ...
%    Separate_Special_Monomial(inEqPolySys);
%
%substituteEqList --- list of equality that has only 2 or 1 monomial

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
ConstraintInfo.Term1.comp = [];
ConstraintInfo.Term2.combbinary = [];
ConstraintInfo.Term2.combsquare = [];
ConstraintInfo.Term2.equiv = [];
ConstraintInfo.Term2.constant = [];
ConstraintInfo.Term2.others = [];
ConstraintInfo.Others = [];
SquareOneSup = [];

EPS = 1.0e-8;
noOfInequality = size(inEqPolySys,2);
if param.complementaritySW == 1
    for i=1:noOfInequality
        typeCone = inEqPolySys{i}.typeCone;
        if typeCone == -1
            for j=1:inEqPolySys{i}.sizeCone
                %I = find(abs(inEqPolySys{i}.coef(:,j)) > EPS);
                %noTerms = length(I);
                noTerms = inEqPolySys{i}.noTerms;
				if noTerms == 1%% Complementality Constraint
                    ConstraintInfo.Term1.comp = [ConstraintInfo.Term1.comp,i];
	                %[i,noTerms]
					%full([inEqPolySys{i}.supports, inEqPolySys{i}.coef])
                elseif noTerms == 2
                    a1 = inEqPolySys{i}.coef(1,j);
                    a2 = inEqPolySys{i}.coef(2,j);
                    if a1*a2 == 0%% Complementality Constraint
                        ConstraintInfo.Term1.comp = [ConstraintInfo.Term1.comp,i];
                		%[i,noTerms]
						%full([inEqPolySys{i}.supports, inEqPolySys{i}.coef])
                        %elseif a1*a2 == -1%% Combinatorial Constraint
                        %substituteEqList.Terms2  = [substituteEqList.Terms2;i];
                    else
                        ConstraintInfo.Others = [ConstraintInfo.Others, i];
                    end
                else
                    ConstraintInfo.Others = [ConstraintInfo.Others, i];
                end
            end
        end
    end
end
if (~isempty(inEqPolySys)) && (param.complementaritySW == 1)
    CompSup = SupTerm1(inEqPolySys,ConstraintInfo);
else
    CompSup = [];
end
%
% 2009-12-20 H. Waki
% add the procedure which finds constraint xi^2 = 1 and save this index i into ConstraintInfo.Term2.combsquare.
%
SquareOneSup = [];
if param.SquareOneSW == 1 && isempty(ConstraintInfo.Term2.combsquare)
	if isempty(ConstraintInfo.Others)
		Idx = [];
		for i= 1:noOfInequality
			if inEqPolySys{i}.typeCone == -1
				Idx = [Idx ,i];
			end	
		end
	else
		Idx = ConstraintInfo.Others;
	end
	for i=Idx
		noTerms = inEqPolySys{i}.noTerms;
		%full([inEqPolySys{i}.supports, inEqPolySys{i}.coef])
		if noTerms == 2
			a1 = inEqPolySys{i}.coef(1,:);
			a2 = inEqPolySys{i}.coef(2,:);
			CoefTf = 0; 
			if a1 > 0 && a2 < 0
				if abs(a1 - 1) <EPS && abs(a2 + 1) < EPS
					CoefTf = 1;
				end
			elseif a1 < 0 && a2 > 0
				if abs(a1 + 1) <EPS && abs(a2 - 1) < EPS
					CoefTf = 1;
				end
			end
			SupTf = 0;
			sup1 = inEqPolySys{i}.supports(1,:);
			[row1, col1, val1] = find(sup1);
			sup2 = inEqPolySys{i}.supports(2,:);
			[row2, col2, val2] = find(sup2);
			%[row1, col1, val1; row2, col2, val2]	
			if length(row1) == 1 && isempty(row2) 
				if length(col1) == 1 && val1 == 2 
					SupTf = 1;
					SquareOneSup = [SquareOneSup, col1];
				else
					SupTf = 0;
				end
			elseif isempty(row1) && length(row2) == 1
				if length(col2) == 1 && val2 == 2 
					SupTf = 1;
					SquareOneSup = [SquareOneSup, col2];
				else
					SupTf = 0;
				end
			else
				SupTf = 0;
			end
			%[SupTf, CoefTf]
			if CoefTf == 1 && SupTf == 1
				ConstraintInfo.Term2.combsquare = [ConstraintInfo.Term2.combsquare, i];
				idx = find(ConstraintInfo.Others == i);
				ConstraintInfo.Others(idx) = [];
			end
		end
	end	
	%ConstraintInfo.Term2.combsquare
	%ConstraintInfo.Others
end

%
% 2011-04-29 H. Waki
% add the procedure which finds constraint xi^2 = xi and save this index i into ConstraintInfo.Term2.combbinary.
%
binarySup = [];
if param.binarySW == 1 && isempty(ConstraintInfo.Term2.combbinary)
	if isempty(ConstraintInfo.Others)
		Idx = [];
		for i= 1:noOfInequality
			if inEqPolySys{i}.typeCone == -1
				Idx = [Idx ,i];
			end	
		end
	else
		Idx = ConstraintInfo.Others;
	end
	for i=Idx
		noTerms = inEqPolySys{i}.noTerms;
		if noTerms == 2
			a1 = inEqPolySys{i}.coef(1,:);
			a2 = inEqPolySys{i}.coef(2,:);
			CoefTf = 0; 
			if a1 > 0 && a2 < 0
				if abs(a1 - 1) <EPS && abs(a2 + 1) < EPS
					CoefTf = 1;
				end
			elseif a1 < 0 && a2 > 0
				if abs(a1 + 1) <EPS && abs(a2 - 1) < EPS
					CoefTf = 1;
				end
			end
			SupTf = 0;
			sup1 = inEqPolySys{i}.supports(1,:);
			[row1, col1, val1] = find(sup1);
			sup2 = inEqPolySys{i}.supports(2,:);
			[row2, col2, val2] = find(sup2);
			
			if length(row1) == 1 && length(row2) == 1
				if col1 == col2
					if val1 == 1 && val2 == 2
						SupTf = 1;
					elseif val1 == 2 && val2 == 1
						SupTf = 1;
					else
						SupTf = 0;
					end
				else
					SupTf = 0;
				end
			else
				SupTf = 0;
			end
			if SupTf == 1
				binarySup = [binarySup, col1];
			end
			if CoefTf == 1 && SupTf == 1
				ConstraintInfo.Term2.combbinary = [ConstraintInfo.Term2.combbinary, i];
				idx = find(ConstraintInfo.Others == i);
				ConstraintInfo.Others(idx) = [];
			end
		end
	end	
	%ConstraintInfo.Term2.combsquare
	%ConstraintInfo.Others
end



return

function CompSup = SupTerm1(inEqPolySys,ConstraintInfo)

EPS = 1.0e-10;
LenTerm1 = length(ConstraintInfo.Term1.comp);
nDim = inEqPolySys{1}.dimVar;
CompSup = sparse(LenTerm1,nDim);
t = 0;
for j=1:LenTerm1
    i= ConstraintInfo.Term1.comp(j);
    for k=1:inEqPolySys{i}.sizeCone
        I = find(abs(inEqPolySys{i}.coef(:,k)) > EPS);
        if length(I) == 1
            t = t + 1;
            CompSup(t,:) = inEqPolySys{i}.supports;
        end
    end
end
return
