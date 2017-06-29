%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% M. Kojima, 02/06/2006
% The main function of this module is:
%	reduceSupSets(objPoly,inEqPolySys,basisSupports);
% This module contains the following functions:
%	mulSupport(basisSup, inEqSup)
%   printGInfo(G0Key,G1Key,GcandidateKey,GstarKey,iteration)
%   printBasisInfo(noConst,basisSupports)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [basisSupports,ineqBasis] = reduceSupSets2(objPoly,inEqPolySys,basisSupports,fixedVar, dimVar0, param)


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
nDim = objPoly.dimVar;
mDim = size(inEqPolySys,2);
kDim = size(basisSupports,2);
noOfinEqPolySys = size(inEqPolySys,2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if param.boundSW == 0 && param.reduceMomentMatSW == 0
    ineqBasis = [];
    return
end
if param.boundSW == 1
	tempFe = cell(1,noOfinEqPolySys+1);
	tempFe{1} = [objPoly.supports',sparse(nDim,1)];
	for j=1:noOfinEqPolySys
	    sup = mulSupport(basisSupports{j}, inEqPolySys{j});
    		tempFe{j+1} = sup';
	end
	ineqBasis = [tempFe{1:noOfinEqPolySys+1}]';
	ineqBasis = my_unique(ineqBasis, 'rows');
end
if param.boundSW == 1 && param.reduceMomentMatSW == 0
    return
elseif param.boundSW == 2 && param.reduceMomentMatSW == 0
    return
end
if param.boundSW == 0 && param.reduceMomentMatSW ~= 0
    ineqBasis = [];
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Attach a random key number to each support of Fe
hashSW = 0;
rVector = rand(nDim,1);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Fsup = cell(kDim, 1);
typeC = cell(kDim, 1);
for i=1:mDim
    if hashSW == 1
        Fsup{i} = inEqPolySys{i}.supports * rVector;
    else
        Fsup{i} = inEqPolySys{i}.supports;
    end
    typeC{i} = inEqPolySys{i}.typeCone;
end
for i=mDim+1:kDim
    if hashSW == 1
        Fsup{i} = sparse(1, nDim) * rVector;
    else
        Fsup{i} = sparse(1, nDim);
    end
    typeC{i} = 1;
end
%
% 2011-07-03 H.Waki
% Implementation for param.errorBdIdx
% <--
if isfield(param, 'aggressiveSW') && param.aggressiveSW == 1
	if isfield(param,'errorBdIdx') && ~isempty(param.errorBdIdx)
		if isempty(fixedVar)
			fixedIdx = [];
		else
			fixedIdx = fixedVar(:,1);
		end
		idx = getIdxErr(param, nDim, dimVar0, fixedIdx);
		add2Sup = sparse(length(idx), nDim);
		add2Sup(:, idx) = 2*speye(length(idx));
		%full(add2Sup)
	else
		add2Sup = [];
	end
else
	add2Sup = 2*speye(nDim);
end
objSup = [sparse(1, nDim);add2Sup;objPoly.supports];
objSup = my_unique(objSup, 'rows');
%full(objSup)
% -->

flag = true;
epsilon = 1.0e-6;
%printBasisInfo(0,basisSupports)
count = 0;

%for i=1:size(inEqPolySys, 2)
%	inEqPolySys{i}
%	full([inEqPolySys{i}.supports, inEqPolySys{i}.coef])
%end
%fprintf('mDim = %d\n', mDim);
%fprintf('kDim = %d\n', kDim);
while flag
	%printBasisInfo(0,basisSupports)
    count = count + 1;
    %fprintf('count = %d\n', count);
    DeltaSet = genDeltaSet(objSup, inEqPolySys, basisSupports, typeC, Fsup, rVector, hashSW, epsilon);
    %fprintf('DeltaSet(%d) -- %d\n', count, size(DeltaSet,1));
    %disp(full(DeltaSet));
    flag = false;
    %dIdx = [];
    ddim = size(DeltaSet, 1);
    removeIdx = cell(1,kDim);
    tmpsup    = cell(1,kDim);
    for p=1:ddim
	jumpflag = false;
        %supIdx = [];
        coefVec = [];
        delta = DeltaSet(p,:);
        [pdim, tmpC]  = cellfun(@size, basisSupports);
        for i=1:kDim
            %pdim = size(basisSupports{i}, 1);
            if ~isempty(removeIdx{i})|| p == 1
                if typeC{i} ~= -1
                    if hashSW == 1
                        tmpbSup = 2*basisSupports{i} * rVector;
                    else
                        tmpbSup = 2*basisSupports{i};
                    end
                elseif typeC{i} == -1
                    if hashSW == 1
                        tmpbSup = basisSupports{i} * rVector;
                    else
                        tmpbSup = basisSupports{i};
                    end
                end
                tmpsup{i} = addSup(Fsup{i}, tmpbSup);
                pdim(i) = size(basisSupports{i},1);
                removeIdx{i} = [];
            end
            qidx = [];
            if hashSW == 1
                if ~isempty(tmpsup{i})
                    qidx = find(abs(tmpsup{i} - delta) < epsilon);
                end
            else
                if ~isempty(tmpsup{i})
                    s = size(tmpsup{i},1);
                    qidx = find(sum(abs(tmpsup{i} - delta(ones(1, s),:)),2) < epsilon);
                end
            end
            for q=qidx'%1:pdim*fdim
                %if abs(tmpsup(q,:) - delta) < epsilon
                j = ceil(q/pdim(i));
                k = mod(q, pdim(i));
                if k == 0;
                    k = pdim(i);
                end
                %supIdx = [i, j, k;supIdx];
		%fprintf('(i, j, k) = (%d, %d, %d)\n', i, j, k);
                removeIdx{i} = [removeIdx{i}, k];
                if i <= mDim
                    if typeC{i} ~= -1
                        %size(inEqPolySys{i}.coef)
                        %[j, q, pdim]
                        coef = inEqPolySys{i}.coef(j, :);
                    else
                        coef = [inEqPolySys{i}.coef(j,:); -inEqPolySys{i}.coef(j,:)];
                        jumpflag = true;
                        break;
                    end
                else
                    coef = 1;
                end
		coefVec = [coef(:);coefVec];
                %end
            end
            if jumpflag == true
                break;
            end
        end
	%if ~isempty(coefVec)
	%	fprintf('delta = ');
	%	disp(full(delta));
	%	fprintf('coefVec = ');
	%	disp(full(coefVec'));
	%else
	%	fprintf('empty.\n');
	%	for ii=1:kDim
	%		disp(removeIdx{ii});
	%	end
	%end
        if ~isempty(coefVec) && jumpflag == false
            rowIdx = find(coefVec > -epsilon);
            if length(rowIdx) == length(coefVec) || isempty(rowIdx)
                % delete supports from all basisSupports
                for ii=1:kDim
                    %removeIdx{ii}= supIdx((supIdx(:,1)==ii), 3);
                    if ~isempty(removeIdx{ii})
                        basisSupports{ii}(removeIdx{ii}, :) = [];
                    end
                end
                flag = true;
            else
                for ii=1:kDim
                    removeIdx{ii} = [];
                end
            end
        else
            for ii=1:kDim
                removeIdx{ii} = [];
            end
        end
        if jumpflag == true
            jumpflag = false;
        end
    end
end

if param.boundSW == 2	
	tempFe = cell(1,noOfinEqPolySys+1);
	tempFe{1} = [objPoly.supports',sparse(nDim,1)];
	for j=1:noOfinEqPolySys
		%fprintf('j = %d\n',j);
		%full(inEqPolySys{j}.supports)
		%full(basisSupports{j})
	    sup = mulSupport(basisSupports{j}, inEqPolySys{j});
    		tempFe{j+1} = sup';
	end
	ineqBasis = [tempFe{1:noOfinEqPolySys+1}]';
	ineqBasis = my_unique(ineqBasis, 'rows');
end

%{
nDim = size(ineqBasis,2);
[A, I] = monomialSort(ineqBasis, 1:nDim, 'grevlex');
for k=1:size(A,1)
	fprintf('sup.%d : sup.idx : ',k-1);
	[row, col,val] = find(A(k,:));
	for kk=1:length(col)
		fprintf('%2d ', col(kk));
	end
	fprintf('sup.val: ');
	for kk=1:length(val)
		fprintf('%2d ', val(kk));
	end
	fprintf('\n');
end
%}
%full(A)
%size(ineqBasis)
%printBasisInfo(0,basisSupports)
return


function DeltaSet = genDeltaSet(objSup, inEqPolySys, basisSupports, typeC, Fsup, rVector, hashSW, epsilon)

nDim = size(objSup,2);
kDim = size(basisSupports, 2);
mDim = size(inEqPolySys, 2);
G0Key = cell(kDim,1);
for i=1:kDim
    if hashSW == 1
        G0Key{i} = basisSupports{i} * rVector;
    else
        G0Key{i} = basisSupports{i};
    end
end
noOFpoints = cellfun('size',G0Key,1);
% Tj = {a+b+c | a in Fj, b, c\in Gj, b neq c}
% F0 cup bigcup_j Tj
Tj = cell(kDim,1);
for j=1:kDim
    if typeC{j} ~= -1
        idx = 1:noOFpoints(j);
        idx = idx(ones(noOFpoints(j),1),:);
        %idx = repmat(idx, noOFpoints(j),1);
        idx1 = triu(idx, 1);
        [row, col, val1] = find(idx1);
        idx2 = triu(idx',1);
        [row, col, val2] = find(idx2);
        %[val1';val2']
        tmp = G0Key{j}(val1, :) + G0Key{j}(val2, :);
        tmp = my_unique(tmp, 'rows');
    else
        tmp = G0Key{j};
    end
    if isempty(tmp)
        Tj{j} = [];
    else
        Tj{j} = addSup(tmp, Fsup{j}, 1);
    end
end
%disp(Tj);
if hashSW == 1
    RemoveSups = objSup*rVector;
    RemoveSups = [sparse(1,nDim)*rVector;RemoveSups];
else
    RemoveSups = objSup;
    RemoveSups = [sparse(1,nDim);RemoveSups];
end
for j=1:kDim
    RemoveSups = [Tj{j};RemoveSups];
end
if hashSW == 0
    RemoveSups = my_unique(RemoveSups, 'rows');
elseif hashSW == 1
    RemoveSups = unique(RemoveSups);
end
%fprintf('RemoveSups = ');
%disp(full(RemoveSups));

Fj2Gj = cell(kDim,1);
for j=1:kDim
    if typeC{j} ~= -1
        tmp = 2* G0Key{j};
    else
        tmp = G0Key{j};
    end
    if isempty(tmp)
        Fj2Gj{j} = [];
    else
        Fj2Gj{j} = addSup(tmp, Fsup{j}, 1);
    end
end
DeltaSet = [];
for j=1:kDim
    DeltaSet = [Fj2Gj{j};DeltaSet];
end
if hashSW == 0
    DeltaSet = my_unique(DeltaSet, 'rows');
elseif hashSW == 1
    DeltaSet = unique(DeltaSet);
end
%fprintf('DeltaSet = ');
%disp(full(DeltaSet));
if hashSW == 1
    idx = [];
    for i=1:size(DeltaSet,1)
        vec = DeltaSet(i,:);
        tmp = abs(RemoveSups - vec);
        rowidx = find(tmp <= epsilon);
        if ~isempty(rowidx)
            idx = [i, idx];
        end
    end
    %{
    rsize = size(RemoveSups,1);
    dsize = size(DeltaSet,1);
    ridx = 1:rsize;
    ridx = ridx(ones(1,dsize),:);
    ridx = ridx(:);
    
    didx = (1:dsize)';
    didx = didx(:, ones(1,rsize));
    didx = didx(:);
    
    tmp = abs(RemoveSups(ridx,:) - DeltaSet(didx,:));
    
    rowIdx = find(tmp < epsilon);
    
    for r=rowIdx'
        k = mod(r, dsize);
        if k == 0
           k = dsize;
        end
        idx = [idx, k];
    end
    %}
    idx = unique(idx);
    DeltaSet(idx, :) = [];
else
    DeltaSet = setdiff(DeltaSet, RemoveSups, 'rows');
end
%if hashSW == 1
%	DeltaSet = DeltaSet * rVector;
%end


return


function sup = mulSupport(basisSup, inEqPolySys)
%
% This function constructs all monomials in valid SDP constrants
% made by multiplying inequality and Moment matrix.
%
% Moreover, choose only monomials that belong in Fe (all elements
% are even.)
%

[m0,nDim0] = size(basisSup);
[m1,nDim1] = size(inEqPolySys.supports);
if nDim0 ~= nDim1
    error('dimension of sup2 is different form sup1!');
else
    nDim = nDim0;
end
usedVarL = find(any(inEqPolySys.supports,1));

if inEqPolySys.typeCone ~= -1
    %%
    %% find all monomials appeared in  Moment matrix
    %%
    mat = ones(m0);
    [col,row] = find(triu(mat));
    Msup = sparse(length(row),nDim);
    usedVarM = find(any(basisSup,1));
    Msup(:,usedVarM) = basisSup(row,usedVarM) + basisSup(col,usedVarM);
    
    %% find all monomials appeared in valid SDP
    m0 = size(Msup,1);
    idx1 = repmat((1:m0),1,m1);
    sup = Msup(idx1,:);
    idx2 = repmat((1:m1),m0,1);
    idx2 = idx2(:);
    sup(:,usedVarL) = sup(:,usedVarL) + inEqPolySys.supports(idx2,usedVarL);
elseif inEqPolySys.typeCone == -1
    %%
    %% find all monomials appeared in valid SDP
    %%
    row = repmat((1:m0),1,m1);
    sup = basisSup(row,:);
    idx = repmat((1:m1),m0,1);
    idx = idx(:);
    sup(:,usedVarL) = sup(:,usedVarL) + inEqPolySys.supports(idx,usedVarL);
end
return

function printBasisInfo(noConst,basisSupports)
fprintf('** basisSupports\n');
cc = size(basisSupports,2);
for p=noConst+1:cc
    rowSize = size(basisSupports{p},1);
    fprintf('%2d : %d\n',p, rowSize);
    for i=1:rowSize
        fprintf('    ');
        vec = basisSupports{p}(i,:);
        if issparse(vec)
            fprintf('%2d',full(vec'));
        else
            fprintf('%2d',vec');
        end
        fprintf('\n');
    end
end
return
