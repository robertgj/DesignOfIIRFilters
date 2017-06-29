function [objPoly, inEqPolySys, lbd, ubd] = genHigherPoly(nDim, density, seed)

if nargin == 1
	seed = 3201;
end
objPoly.typeCone = 1;
objPoly.sizeCone = 1;	
objPoly.dimVar   = nDim;    
objPoly.degree   = 3;    
supports = genSimplexSupport(0,nDim,objPoly.degree,1:nDim);
rand('state',seed);
rvec  = sprandn(size(supports, 1), 1, density);
[row, col, val] = find(rvec);
objPoly.coef = val;
%objPoly.coef = (2*val-1);
objPoly.supports = supports(row, :);
objPoly.noTerms = size(objPoly.supports, 1);

%{
objPoly.coef = [ones(nDim, 1);objPoly.coef];
objPoly.degree = 4;
objPoly.supports = [objPoly.degree*speye(nDim); objPoly.supports];
objPoly.noTerms = objPoly.noTerms + nDim;
%}
inEqPolySys = cell(1, nDim-1);
for i=1:nDim-1
	inEqPolySys{i}.typeCone = 1;
	inEqPolySys{i}.sizeCone = 1;
	inEqPolySys{i}.dimVar   = nDim;    
	inEqPolySys{i}.degree   = 2;    
	inEqPolySys{i}.noTerms  = 2;
	inEqPolySys{i}.supports = sparse(inEqPolySys{i}.noTerms, inEqPolySys{i}.dimVar);
	inEqPolySys{i}.supports(1, i) = 1;
	inEqPolySys{i}.supports(1, i+1) = 1;
	inEqPolySys{i}.coef = [1;-0.5];
end
%{
inEqPolySys{nDim}.typeCone = 1;
inEqPolySys{nDim}.sizeCone = 1;
inEqPolySys{nDim}.dimVar   = nDim;    
inEqPolySys{nDim}.degree   = 2;    
inEqPolySys{nDim}.noTerms  = 3;
inEqPolySys{nDim}.supports = sparse(inEqPolySys{nDim}.noTerms, inEqPolySys{nDim}.dimVar);
inEqPolySys{nDim}.supports(1, nDim) = 2;
inEqPolySys{nDim}.supports(2, 1) = 2;
inEqPolySys{nDim}.coef = [-1;-1;1];
%}
%{
for i=1:size(inEqPolySys, 2)
	disp(i);
	disp(full([inEqPolySys{i}.supports,inEqPolySys{i}.coef])); 
end
%}
%lbd = -1.0e+10*ones(1, nDim);
%ubd =  1.0e+10*ones(1, nDim);
lbd = zeros(1, nDim);
ubd = ones(1, nDim);
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function supSet = genSimplexSupport(supType,nDim,r,subspaceIdxSet,order)
% supType = 0 or 1
% supspaceIdxSet \subset 1:nDim
%
% If supType == 0, then supSet consists of the elements 
% \{ v \in Z^n_+ : \sum_{i=1}^n v_i = r, v_j = 0 
% (j \not\in supSpaceIdxSet \}
% in the lexico graphical order. 
%
% If supType == 1 then supSet consists of the elements 
% \{ v \in Z^n_+ : \sum_{i=1}^n v_i \le r, v_j = 0 
% (j \not\in supSpaceIdxSet \}
% in the lexico graphical order. 
% 
if nargin < 5
  order = 'grevlex';
end
dimSubspace = length(subspaceIdxSet); 
if nDim <= 0
  error('!!! nDim <= 0 !!!');
elseif r < 0
  error('!!! r < 0 !!!');	
elseif dimSubspace == nDim
  if subspaceIdxSet(nDim) == nDim
    if supType == 0
      supSet = flatSimpSup(nDim,r);
    elseif supType == 1
      supSet = fullSimpSup(nDim,r);
    else
      error('!!! supType is neither 0 nor 1 !!!');
    end
  else
    error('!!! dimSubspace = nDim but subspaceIdxSet(nDim) not= nDim !!!');
  end
else
  supSet = restSimpSup(supType,nDim,r,subspaceIdxSet);
end

% Kojima, 02/15/2005
% [supSet,I] = Monomial_Sort(supSet, subspaceIdxSet, order);
[supSet,I] = monomialSort(supSet, subspaceIdxSet, order);
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function supSet = flatSimpSup(nDim,r)
% \{ v \in Z^n_+ : \sum_{i=1}^n v_i = r \}

if nDim == 0
  supSet = 0; 
elseif r == 0
  supSet = sparse(1,nDim);
elseif nDim == 1 
  supSet = r; 
else
  NumElem = nchoosek(nDim+r-1,r);
  supSet = sparse(NumElem,nDim);
  index = 0;
  for i=0:r
    aSupSet = flatSimpSup(nDim-1,i);
    [m,n] = size(aSupSet);
    Idx = index + (1:m);
    supSet(Idx,1) = repmat(r-i,m,1);
    supSet(Idx,2:n+1) = aSupSet;
    index = index + m;
  end
end
return; 		

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function supSet = fullSimpSup(nDim,r)
% \{ v \in Z^n_+ : \sum_{i=1}^nDim v_i \leq r \}

if nDim == 1;
  supSet = (0:r)';
  supSet = sparse(supSet);
elseif r == 0
  supSet = sparse(1,nDim);
else
  NumElem = nchoosek(nDim+r,r);
  supSet = sparse(NumElem,nDim);
  index = 0;
  for i=0:r
    aSupSet = flatSimpSup(nDim,i);
    m = size(aSupSet,1);
    Idx = index + (1:m);
    supSet(Idx,:) = aSupSet;
    index = index + m;
  end
end
return;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function supSet = restSimpSup(supType,nDim,r,subspaceIdxSet)

dimSubspace = length(subspaceIdxSet); 
%
% error handlng
%
if (nDim < dimSubspace) || (nDim < subspaceIdxSet(dimSubspace)) 
  error('!!! nDim < dimSubspace !!!');
end
if nDim == 0;
  error('!!! nDim = 0 !!!'); 
end
if dimSubspace == 0;
  error('!!! dimSupspace = 0 !!!');
end
if nDim < subspaceIdxSet(dimSubspace)
  error('!!! nDim < subspaceIdxSet(dimSubspace) !!!'); 
end
%
% end of error handling
%

if supType == 1
  %\{ v \in Z^n_+ : \sum_{i=1}^n v_i \le r, v_j = 0
  % (j \not\in supSpaceIdxSet) \}
  aSupSet = fullSimpSup(dimSubspace,r);
elseif supType ==0
  %\{ v \in Z^n_+ : \sum_{i=1}^n v_i = r, v_j = 0 
  % (j \not\in supSpaceIdxSet) \}
  aSupSet = flatSimpSup(dimSubspace,r); 
else
  error('!!! You should choose 1 or 0 as supType !!!'); 
end    
m = size(aSupSet,1); 
supSet = sparse(m,nDim);
supSet(:,subspaceIdxSet) = aSupSet;

return;
