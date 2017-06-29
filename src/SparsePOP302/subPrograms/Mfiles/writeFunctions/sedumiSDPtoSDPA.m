function sedumiSDPtoSDPA(fileName,A,b,c,K)
%
% Input
%   if nargin == 1, then load A,b,c and K from *.mat file, convert them 
%   into SDPA sparse format, 
%   and write them *.dat-s file.
%
%   if nargin == 5, then convert A, b, c and K into SDPA sparse format, 
%   and write them in *.dat-s file. 
%

%
% Programed by M. Kojima in 2008 and Modified by H. Waki in 2009.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is a component of SparsePOP 
% Copyright (C) 2007-2009 SparsePOP Project
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
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

if nargin == 1
    dotMatPosition0 = strfind(fileName,'.mat');
    if isempty(dotMatPosition0)
        fileName = strcat(fileName,'.mat');
        dotMatPosition = strfind(fileName,'.mat');
    else
        ii = length(dotMatPosition0);
        dotMatPosition = dotMatPosition0(ii);
        if dotMatPosition+3 < length(fileName)
            fileName = strcat(fileName,'.mat');
            dotMatPosition = length(fileName) - 3;
        end
    end
    outFileName = strcat(fileName(1:dotMatPosition),'dat-s');
%    fileName
    S = load(fileName,'-mat','A','b','c','K');
    writeSDPA(outFileName,S.A,S.b,S.c,S.K); 
elseif nargin == 5
    outFileName = fileName; 
    dotDatsPosition0 = strfind(outFileName,'.dat-s');
    if isempty(dotDatsPosition0)
        outFileName = strcat(outFileName,'.dat-s');
    else
        ii = length(dotDatsPosition0);
        dotDatsPosition = dotDatsPosition0(ii);
        if dotDatsPosition+5 < length(outFileName)
            outFileName = strcat(outFileName,'.dat-s');
        end
    end
    writeSDPA(outFileName,A,b,c,K);     
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function writeSDPA(sdpaDataFileName,A,b,c,K)

%fprintf('## Write SeDuMi SDP data to the file %s.\n',sdpaDataFileName);  

[mDim,nDim] = size(A);

if size(c,1) < size(c,2)
    c = c';
end

if isfield(K,'f') && ~isempty(K.f) && K.f > 0
    fprintf('## Each free variable is splitted into two LP variables.\n');
    A = [-A(:,1:K.f), A]; 
    c = [-c(1:K.f,1); c]; 
    if isfield(K,'l') && ~isempty(K.l) && K.l > 0
        K.l = 2*K.f+K.l;
    else
        K.l = 2*K.f;
    end
    K.f = [];    
end
if isfield(K,'q') && ~isempty(K.q)
    fprintf('## SDPA cannot handle Qcone.\n');
    fprintf('## Please set param.sdpaDataFile to be empty.\n');
    return 
end
if isfield(K,'r') && ~isempty(K.r)
    fprintf('## SDPA cannot handle Rcone.\n');
    fprintf('## Please set param.sdpaDataFile to be empty.\n');
    return
end

sdpaDataId = fopen(sdpaDataFileName,'w'); 
% sdpaDataId  = 1; 

if isfield(K,'l') && K.l > 0
    nBlock = 1; 
    bLOCKsTRUCT = -K.l; 
else
    nBlock = 0;
    bLOCKsTRUCT = [];
end
if isfield(K,'s') && ~isempty(K.s) 
    nBlock = nBlock + length(K.s);
    bLOCKsTRUCT = [bLOCKsTRUCT, K.s];
end

fprintf(sdpaDataId,'" %s, mDim = %d, nBlock = %d\n',sdpaDataFileName,mDim,nBlock);
fprintf(sdpaDataId,'%6d = mDim \n',mDim);
fprintf(sdpaDataId,'%6d = nBlock \n',nBlock);
fprintf(sdpaDataId,'   ');
%for i=1:length(bLOCKsTRUCT)
%    fprintf(sdpaDataId,'%d ',bLOCKsTRUCT(i));
%end
fprintf(sdpaDataId,'%d ',full(bLOCKsTRUCT));
fprintf(sdpaDataId,'\n');
fprintf(sdpaDataId,'{ ');

% -b

for i=1:mDim
    %
    % 2008/04/21 Waki
    % Modified the format of output of b
    if mod(b(i,1),1) == 0 
       fprintf(sdpaDataId,'%+d ',-full(b(i,1)));
    else
       fprintf(sdpaDataId,'%+20.15e ',-full(b(i,1)));
    end
end
fprintf(sdpaDataId,'}\n');

% the list of column indices that indicate the starting point of each block 
% in the constraint matrix A
% ---> 
blkStartingIdx = [];
blkSeDuMi = 0; 
for j=1:length(bLOCKsTRUCT)
    block = bLOCKsTRUCT(j);
	blkStartingIdx = [blkStartingIdx, blkSeDuMi+1]; 
    if block < 0
        blkSeDuMi = blkSeDuMi - block; 
    else
        blkSeDuMi = blkSeDuMi + block*block; 
    end
end
% <---
% the list of column indices that indicate the starting point of each block 
% in the constraint matrix A

rowSize = 0;
% -c ---> F_0
k = 0; 
nzIdxVect = find(c(:,1)'); 
for p = nzIdxVect
    minusIdxVect = find(blkStartingIdx - p <= 0);
    block = length(minusIdxVect); 
    q = p - blkStartingIdx(block) + 1; 
    blkSize = bLOCKsTRUCT(block);
    if blkSize < 0 
        i = q; 
        j = q; 
        if mod(c(p,1),1) == 0 % ~isfloat(c(p,1))
            fprintf(sdpaDataId,'%5d %5d %5d %5d  %+d\n',k,block,i,j,-full(c(p,1)));
        else
            fprintf(sdpaDataId,'%5d %5d %5d %5d  %+20.15e\n',k,block,i,j,-full(c(p,1)));
       end
	rowSize = rowSize + 1;
    else
        i = ceil(q / blkSize); 
        j = mod(q,blkSize);
        if j == 0
            j = blkSize;
        end
        if i <= j
            if mod(c(p,1),1) == 0 %~isfloat(c(p,1))
                fprintf(sdpaDataId,'%5d %5d %5d %5d  %+d\n',k,block,i,j,-full(c(p,1))); 
            else
                fprintf(sdpaDataId,'%5d %5d %5d %5d  %+20.15e\n',k,block,i,j,-full(c(p,1))); 
           end
		rowSize = rowSize + 1;
        end        
    end    
end
% -A ---> F_1, ... F_mDim
for k=1:mDim
    nzIdxVect = find(A(k,:)); 
    for p = nzIdxVect
        minusIdxVect = find(blkStartingIdx - p <= 0);
        block = length(minusIdxVect);
        q = p - blkStartingIdx(block) + 1;
        blkSize = bLOCKsTRUCT(block);
        if blkSize < 0
            i = full(q);
            j = full(q);
            if mod(A(k,p),1) == 0 % ~isfloat(A(k,p))
                fprintf(sdpaDataId,'%5d %5d %5d %5d  %+d\n',k,block,i,j,-full(A(k,p)));
            else
                fprintf(sdpaDataId,'%5d %5d %5d %5d  %+20.15e\n',k,block,i,j,-full(A(k,p)));
            end
		rowSize = rowSize + 1;
        else
            i = full(ceil(q / blkSize));
            j = full(mod(q,blkSize));
            if j == 0
                j = full(blkSize);
            end
            if i <= j
                if mod(A(k,p),1) == 0 % ~isfloat(A(k,p))
                    fprintf(sdpaDataId,'%5d %5d %5d %5d  %+d\n',k,block,i,j,-full(A(k,p)));
                else
                    fprintf(sdpaDataId,'%5d %5d %5d %5d  %+20.15e\n',k,block,i,j,-full(A(k,p)));
                end
		rowSize = rowSize + 1;
            end
        end
    end
end

fclose(sdpaDataId);

fprintf('# Output : SDPA sparse format data\n'); 
fprintf('  File name = %s\n', sdpaDataFileName);
fprintf('  mDim = %d, nBlock = %d\n', mDim, nBlock); 
fprintf('  size of bVect = 1 * %d\n', mDim);
fprintf('  size of sparseMatrix = %d * 5\n', rowSize);

return
