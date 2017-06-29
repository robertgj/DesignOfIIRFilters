function [parameterSet] = defaultParCoLO(A,b,c,K,J)

maxSDPmatrixSize0 = 10;
updForConversion = 1.0;
maxSDPmatrixSize1 = 20; 

if nargin == 1
    fileName = A; 
    % Check whether ifileName has the extension '.mat' --->
    dotMatPosition0 = strfind(fileName,'.mat');
    % <--- Check whether fileName has the extension '.mat'
    if isempty(dotMatPosition0)
        [A,b,c,K,J] = eval(fileName);
    else
        S = load(fileName,'-mat');
        A = S.A;
        b = S.b;
        c = S.c;
        K = S.K;
        if isfield(S,'J')
            J = S.J;
        else
            J.f = size(A,1);
        end
        clear S
    end
end

% fprintf('\n');   
% fprintf('Diagnosis of LOP\n');


[domainConv] = whichConversion(A,c,K,maxSDPmatrixSize0,updForConversion,maxSDPmatrixSize1);

[conv] = whichConversion(-A',b,J,maxSDPmatrixSize0,updForConversion,maxSDPmatrixSize1);
rangeConv = [];
for j=1:length(conv)
    if conv(j) == 0
        rangeConv = [rangeConv, 0];
    else 
        rangeConv = [rangeConv, 3-conv(j)];
    end
end
parameterSetHead = [];
parameterSetTail = [];
for i=1:length(domainConv)
    if (domainConv(i) == 0) % && (~isfield(K,'s') || isempty(K.s))
        for j=1:length(rangeConv)
            if rangeConv(j) == 0
                if isfield(J,'f') && ~isempty(J.f) && J.f == size(A,1) 
                    parameterSetHead = [parameterSetHead; 0,0,1]; 
%                    parameterSetTail = [parameterSetTail; 0,0,2];                    
                else
                    parameterSetHead = [parameterSetHead; 0,0,2]; 
                    parameterSetTail = [0,0,1; parameterSetTail];                    
                end
            elseif rangeConv(j) == 1
                parameterSetHead = [parameterSetHead; 0,1,2]; 
            else % rangeConv(j) == 2
                parameterSetHead = [parameterSetHead; 0,2,1];                 
%                parameterSetTail = [parameterSetTail; 0,2,2]; 
            end            
        end
    elseif (domainConv(i) == 1)
        for j=1:length(rangeConv)
            if rangeConv(j) == 0
                parameterSetHead = [parameterSetHead; 1,0,1]; 
            elseif rangeConv(j) == 1                
%                parameterSetHead = [parameterSetHead; 1,1,1]; 
                parameterSetTail = [1,1,1; parameterSetTail; 1,1,2]; 
            else % rangeConv(j) == 2
                parameterSetHead = [parameterSetHead; 1,2,1];                 
%                parameterSetTail = [parameterSetTail; 1,2,2]; 
            end            
        end
    else % (domainConv(i) == 2)
        for j=1:length(rangeConv)
            if rangeConv(j) == 0
                parameterSetHead = [parameterSetHead; 2,0,2]; 
%                parameterSetTail = [parameterSetTail; 2,0,1]; 
            elseif rangeConv(j) == 1                
                parameterSetHead = [parameterSetHead; 2,1,2]; 
            else % rangeConv(j) == 2
%                parameterSetHead = [parameterSetHead; 2,2,2]; 
                parameterSetTail = [2,2,2; parameterSetTail; 2,2,1];                 
            end            
        end
    end
end

parameterSet = [parameterSetHead; parameterSetTail];

fprintf('\nparCoLO.domain = %d; parCoLO.range = %d; parCoLO.EQorLMI = %d\n',... 
        parameterSet(1,1),parameterSet(1,2),parameterSet(1,3)); 
if size(parameterSet,1) > 1
    fprintf('Also try:\n')
    for i=2:size(parameterSet,1)
        fprintf('    parCoLO.domain = %d; parCoLO.range = %d; parCoLO.EQorLMI = %d\n',...
            parameterSet(i,1),parameterSet(i,2),parameterSet(i,3));
    end
%    fprintf('\n');
end

return

function [conv] = whichConversion(A,c,K,maxSDPmatrixSize0,updForConversion,maxSDPmatrixSize1)
if ~isfield(K,'s') || isempty(K.s)
%     fprintf('No SDP matrix variable, so the d-space conversion is not relevant\n');
%     fprintf('Take parCoLO.domain = 0\n');
    conv = 0; 
    return
else
    if max(K.s) <= maxSDPmatrixSize0
        conv = 0;
    else
        conv = [];
    end
    colPointer = 0; 
    % Check the dimensions of free variables
    if isfield(K,'f') && ~isempty(K.f) && K.f > 0
        colPointer = colPointer + K.f;
    end
    % Check the dimensions of LP variables
    if isfield(K,'l') && ~isempty(K.l) && K.l > 0
        colPointer = colPointer + K.l;
    end
    % Check the dimensions of SOCP variables
    if isfield(K,'q') && ~isempty(K.q)
        qDim = sum(K.q);
        colPointer = colPointer + qDim;
    end
    noOfSDPcones = length(K.s);
    volumeRatio = []; 
    for kk=1:noOfSDPcones
        sDim = K.s(kk);
        KAdd.s = sDim; 
%        if sDim > maxSDPmatrixSize0
            [sparsityPatternMat] = ...
                genSparsityPatternMat(A(:,colPointer+(1:sDim*sDim)),c(colPointer+(1:sDim*sDim),1),KAdd);
            [oneClique] = cliquesFromSpMatD(sparsityPatternMat);
            if (sDim > maxSDPmatrixSize0) && (oneClique.maxC < sDim)
                tempRatio = oneClique.NoElem/sDim;
                volumeRatio = [volumeRatio, [sDim; oneClique.maxC; sum((tempRatio.*tempRatio).*tempRatio)]];
            end
%        end
    end
%     volumeRatio(:,2) * (K.s)' / sum(K.s)
    if ~isempty(volumeRatio) && min(volumeRatio(3,:)) <= updForConversion
%         fprintf('Enough domain sarsity to apply a d-space conversion method\n');        
        if max(volumeRatio(2,:)) < maxSDPmatrixSize1
%             fprintf('Each decomposed SDP matrix size < %d, so take parCoLO.domain = 1 or 2\n',maxSDPmatrixSizeD);  
            conv = [conv,2,1];
        else
%            fprintf('Some decomposed SDP matrix size >= %d, so take parCoLO.domain = 1\n',maxSDPmatrixSizeD);  
            conv = [conv,1,2]; 
        end
    else
%         fprintf('Not enough domain sarsity to apply a d-space conversion method\n');        
%         fprintf('Take parCoLO.domain = 0\n');
        conv = [0]; 
    end
end




    
    
    