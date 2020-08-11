function writeGMS(fname, objPoly, ineqPolySys, lbd, ubd)

if nargin ~= 5
	error('## The number of input should be five.');
end
%
% Check inputs
%
nDim = objPoly.dimVar;
mDim = size(ineqPolySys,2);

continueSW = 1;

% Check objPoly
[continueSW] = checkPolynomial(objPoly,nDim,0,continueSW);
for i=1:mDim
    % Check ineqPolySys{i}
    [continueSW] = checkPolynomial(ineqPolySys{i},nDim,i,continueSW);
end
% Check lbd
lenLbd = length(lbd);
if lenLbd ~= nDim
    fprintf('## the length of lbd=%d ~= objPoly.dimVar=%d ##\n',lenLbd,nDim);
    continueSW = 0;
end
% Check ubd
lenUbd = length(ubd);
if lenUbd ~= nDim
    fprintf('## the length of ubd=%d ~= objPoly.dimVar=%d ##\n',lenUbd,nDim);
    continueSW = 0;
end

fid = fopen(fname, 'w+');
fprintf(fid, 'Variables ');
for i=1:nDim
	fprintf(fid, 'x%d, ', i);
end
fprintf(fid, 'objvar;\n');
fprintf(fid, 'Equations ');
for i=1:mDim+1
	fprintf(fid, 'e%d, ', i);
end
fprintf(fid, ';\n');

fprintf(fid, 'e1.. ');
for j=1:objPoly.noTerms
	coef = objPoly.coef(j);
	support = objPoly.supports(j,:);
	[row, col] = find(support);
	fprintf(fid, '%+8.4g ', full(coef));
	for k=1:length(col)
		fprintf(fid, '*x%d', col(k));
	end	
	fprintf(fid, ' ');
end
fprintf(fid, '-objvar =E= 0;\n');

for i=1:mDim
	fprintf(fid, 'e%d.. ', i+1);
	for j=1:ineqPolySys{i}.noTerms
		coef = ineqPolySys{i}.coef(j);
		support = ineqPolySys{i}.supports(j,:);
		[row, col] = find(support);
		fprintf(fid, '%+8.4g ', full(coef));
		for k=1:length(col)
			fprintf(fid, '*x%d', col(k));
		end	
		fprintf(fid, ' ');
	end
	if ineqPolySys{i}.typeCone == 1
		fprintf(fid, ' =G= 0;\n');
	elseif ineqPolySys{i}.typeCone == -1
		fprintf(fid, ' =E= 0;\n');
	end
end
fprintf(fid, '\n');
[row, col] = find(lbd > -1.0e+8);
for j=1:length(col)
	fprintf(fid, 'x%d.lo = %+8.4g;\n', col(j), lbd(col(j)));
end
%fprintf(fid, '\n');
[row, col] = find(ubd < +1.0e+8);
for j=1:length(col)
	fprintf(fid, 'x%d.up = %+8.4g;\n', col(j), ubd(col(j)));
end
fprintf(fid,'\n');
fclose(fid);
return

function [continueSW] = checkPolynomial(poly,nDim,i,continueSW)
if (i == 0)
    % Check typeCone of objPoly
    if (abs(poly.typeCone) > 1)
        fprintf('## Only typeCone = -1, 0 or 1 is possible in objPoly ##\n');
        continueSW = 0;
    end
    % Check sizeCone of objPoly
    if (i == 0) && (isfield(poly,'sizeCone')) && (poly.sizeCone ~= 1)
        fprintf('## Only sizeCone = 1 is possible in objPoly ##\n');
        continueSW = 0;
    end
    % <--- Checking of sizeCone only when sizeCone is specified;
else % i >= 1
    % Check typeCone and sizeCone of ineqPolysys{i}
    if (poly.typeCone == -1) || (poly.typeCone == 1) % real equality or inequality
        % Kojima, 02/15/05
        % Checking of sizeCone only when sizeCone is specified; --->
        if (isfield(poly,'sizeCone')) && (poly.sizeCone ~= 1)
            fprintf('## Only sizeCone = 1 is possible when sizeCone = 1 in ineqPolySys{%d} ##\n',i);
            continueSW = 0;
        end
    else
        fprintf('## typeCone=%d needs to be either -1 or 1 in ineqPolySys{%d} ##\n',poly.typeCone,i);
        continueSW = 0;
    end
end
% Check dimVar.
if (0 < i) && (poly.dimVar ~= nDim)
    fprintf('## ineqPolySys{%d}.dimVar=%d ~= objPoly.dimVar=%d ##\n',i,poly.dimVar,nDim);
    continueSW = 0;
end
% Check the sizes of supports,
rowSizeS = size(poly.supports,1);
colSizeS = size(poly.supports,2);
if poly.noTerms ~= rowSizeS
    if i == 0
        fprintf('## objPoly.noTerms=%d ~= size(objPoly.supports,1)=%d ##\n',...
            poly.noTerms,size(poly.supports,1));
    else
        fprintf('## ineqPolySys{%d}.noTerms=%d ~= size(ineqPolySys{%d}.supports,1)=%d ##\n',...
            i,poly.noTerms,i,size(poly.supports,1));
    end
    continueSW = 0;
end
if poly.dimVar ~= colSizeS
    if i == 0
        fprintf('## objPoly.dimVar=%d ~= size(objPoly.supports,2)=%d ##\n',nDim,size(poly.supports,2));
    else
        fprintf('## ineqPolySys{%d}.dimVar=%d ~= size(ineqPolySys{%d}.supports,2)=%d ##\n',...
            i,poly.dimVar,i,size(poly.supports,2));
    end
    continueSW = 0;
end
% Check the sizes of coef.
rowSizeC = size(poly.coef,1);
colSizeC = size(poly.coef,2);
if poly.noTerms ~= rowSizeC
    if i == 0
        fprintf('## objPoly.noTerms=%d ~= size(objPoly.coef,1)=%d ##\n',...
            poly.noTerms,size(poly.coef,1));
    else
        fprintf('## ineqPolySys{%d}.noTerms=%d ~= size(ineqPolySys{%d}.coef,1)=%d ##\n',...
            i,poly.noTerms,i,size(poly.coef,1));
    end
    continueSW = 0;
end
if abs(poly.typeCone) <= 2
    if colSizeC ~= poly.sizeCone
        if i == 0
            fprintf('## objPoly.coef ~= noTerms x objPoly.sizeCone  ##\n');
        else
            fprintf('## ineqPolySys{%d}.coef ~= noTerms x ineqPolySys{%d}.sizeCone ##\n',i,i);
        end
        continueSW = 0;
    end
elseif (i > 0) && (poly.typeCone == 3)
    if colSizeC ~= poly.sizeCone * poly.sizeCone
        fprintf('## ineqPolySys{%d}.coef ~= noTerms x (ineqPolySys{%d}.sizeCone*ineqPolySys{%d}.sizeCone) ##\n',i,i,i);
        continueSW = 0;
    end
end
% Check whether the supports are nonnegative integers
indexSet = find(poly.supports < 0);
if ~isempty(indexSet)
    if i == 0
        fprintf('## Some element objPoly.supports is negative   ##\n');
    else
        fprintf('## Some element of ineqPolySys{%d}.supports is negative ##\n',i);
    end
    continueSW = 0;
end
indexSet = find(sum(poly.supports - ceil(poly.supports),2));
if ~isempty(indexSet)
    if i == 0
        fprintf('## Some element objPoly.supports is not integer ##\n');
    else
        fprintf('## Some element of ineqPolySys{%d}.supports is not integer ##\n',i);
    end
    continueSW = 0;
end
% Check degree.
degree = max(sum(poly.supports,2));
if degree ~= poly.degree
    if i == 0
        fprintf('## objPoly.degree is different from max(sum(objPoly.supports,2)) ##\n');
    else
        fprintf('## ineqPolySys{%d}.degree is different from max(sum(ineqPolySys{%d}.supports,2)) ##\n',i,i);
    end
    continueSW = 0;
end
%% Check more than one identical supports
%if exist('mexconv3') == 3
%	%disp(full(supmat));	
%	[temp, M, N] = quickUnique(poly.supports);
%	%disp(full(temp));
%	%disp(length(M));
%	%disp(length(N));	
%else
	[temp, M, N] = unique(poly.supports,'rows');
%end
if length(N) > length(M)
    if i == 0
        fprintf('## objPoly involves more than one idientical support row vectors in objPoly.supports ##\n');
    else
        fprintf('## ineqPolySys{%d} involves more than one idientical support row vectors in ineqPolySys{%d}.supports ##\n',i,i);
    end
	%full([poly.supports])
	%full([poly.coef])
    continueSW = 0;
end

return;




