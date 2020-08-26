function [objPoly, ineqPolySys, lbd, ubd] = genPIS(nDim)
%
% This function generates the problem of partitioning an integer sequence. 
%
% Description of this problem:
% For a = (a1, a2, ..., am)^T, where a1, ..., am: integer
% if there exists x in {-1, 1}^n such that a^T x = 0, 
% the sequence can be partitioned. 
%
% For this problem, we formulate it as follows:
% minimize    (a^Tx)^2
% subject to  x_i^2 = 1 (i=1, ..., n)
%
% If the minimum value is zero, then the sequence can be partitioned by the solution.
% Otherwise, the sequence cannot be partitioned. 
%
% See the following paper for more detail:
%
% S. Kim and M. Kojima, "Solving polynomial least squares problems 
% via semidefinite programming relaxations", 
% Journal of Global Optimization VOL.46 (1) 1-23 (2010).
%
% 2011-06-22 H.Waki
%

u = 10; % given integer
k = ceil(2*nDim/3);
if nDim - k < 1
  error('nDim should be more than 1.');
end

if exist('OCTAVE_VERSION','builtin')
  rand('state', 3201);
  rvec = rand(nDim, 1);
else
  mv= ver('matlab');
  mv = str2num(mv.Version);
  if mv > 7.7
	s = RandStream('mt19937ar','Seed', 3201);
  else
	rand('twister',3201);
  end
  if mv > 7.7
	rvec = rand(s, nDim, 1);
  else
	rvec = rand(nDim, 1);
  end
end

for i=1:k
	a(i, 1) = ceil(u*rvec(i)); 
end
s = sum(a(1:k,1), 1);
for i=k+1:nDim-1
	a(i, 1) = ceil(u*rvec(i)); 
end
a(nDim, 1) = s  - sum(a(k+1:end-1, 1), 1);
if a(nDim, 1) < 0
	error('Choose other setting u and k');
end
%idx = randperm(nDim);
%a = a(idx);
%a'
W = a*a';
U = triu(W) + tril(W, -1)';

% objPoly 
objPoly.typeCone = 1;
objPoly.dimVar   = nDim;    
objPoly.degree   = 2;    
objPoly.sizeCone = 1;	

kDim = nnz(U);
objPoly.noTerms  = kDim;

objPoly.support = sparse(kDim, nDim);
objPoly.coef = zeros(kDim, 1);
[row, col, val] = find(U);
for i=1:kDim
	if row(i) == col(i)
		objPoly.supports(i, row(i)) = 2;
	else
		objPoly.supports(i, row(i)) = 1;
		objPoly.supports(i, col(i)) = 1;
	end
	objPoly.coef(i, 1) = val(i); 
end

% ineqPolySys
ineqPolySys = cell(1,nDim);
for i=1:nDim
	ineqPolySys{i}.typeCone = -1;
	ineqPolySys{i}.sizeCone = 1;
	ineqPolySys{i}.dimVar   = nDim;    
	ineqPolySys{i}.degree   = 2;    
	ineqPolySys{i}.noTerms  = 2;
	ineqPolySys{i}.supports = sparse(2, nDim);
	ineqPolySys{i}.supports(1, i) = 2;
	ineqPolySys{i}.coef = [1;-1];
end

lbd = repmat(-1.0e+10, 1, nDim);
ubd = repmat( 1.0e+10, 1, nDim);


return
