%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Apc,cPc,Kpc,clique] = sparsePrimal(A,c,K,clique); 

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is a component of SparseCoLO 
% Copyright (C) 2009 
% Masakazu Kojima Group
% Department of Mathematical and Computing Sciences
% Tokyo Institute of Technology
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

printCpuTimeSW = 0; 

% The dimension of the SDP cone
sDim = K.s(1); % size(sparsityPatternMat,1);

debugSW = 0;
if debugSW == 1
    fprintf('cliques: \n');        
    for p=1:clique.NoC
        fprintf(' %2d: ',p);
        for i=1:length(clique.Set{p})
            fprintf(' %2d',clique.Set{p}(i));
        end
        fprintf('\n');        
    end
end

% constructing a clique graph ---> 
startingTime = cputime;
[adjacencyMatrixC,noOfEdges,edgeCostVectC,incidenceMatrixC] ... 
    = consructCliqueGraph(clique); 
if printCpuTimeSW == 1
    fprintf('/// cputime for consructCliqueGraph = %6.1e\n',cputime-startingTime); 
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The constructed clique graph is assumed to be connected, or %
% it is assumed to have a spanning tree containing all nodes. %
% This assumption should be removed in future evelopment.     %
%
% Solved by M. Yamashita , 12/2008 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% <--- constructing a clique graph

debugSW = 0;
if debugSW == 1
    fprintf('Information on the clique graph\n'); 
%     'sparsityPatternMat'
%     full(sparsityPatternMat)
    fprintf('%d x %d adjacencyMatrixC\n',clique.NoC,clique.NoC)
    fprintf('     ');
    for q=1:clique.NoC
        fprintf('%3d',q);
    end
    fprintf('\n');
    for p=1:clique.NoC
        fprintf('%3d: ',p); 
        for q=1:clique.NoC
            fprintf('%3d',full(adjacencyMatrixC(p,q)));
        end
        fprintf('\n');
    end
    fprintf('1 x %d edgeCostVectC\n',noOfEdges)
    fprintf('     ');
    for q=1:noOfEdges
        fprintf('%3d',full(edgeCostVectC(q)));
    end
    fprintf('\n');
    fprintf('%d x %d incidenceMatrixC\n',clique.NoC,noOfEdges)
    fprintf('     ');
    for q=1:noOfEdges
        fprintf('%3d',q);
    end
    fprintf('\n');
    for p=1:clique.NoC
        fprintf('%3d: ',p); 
        for q=1:noOfEdges
            fprintf('%3d',full(incidenceMatrixC(p,q)));
        end
        fprintf('\n');
    end
end

% Computing a maximum spanning tree from the clique graph ---> 
randSeed = 3201; 
startingTime = cputime;
[treeValue,adjacencyMatrixT,edgeCostVectT,incidenceMatrixT,basisIdx,BInv] ... 
    = maxSpanningTree2(clique,adjacencyMatrixC,edgeCostVectC,incidenceMatrixC,randSeed);
if printCpuTimeSW == 1
    fprintf('/// cputime for maxSpanningTree2 = %6.1e\n',cputime-startingTime); 
end
% <--- Computing a maximum spanning tree from the clique graph 

if printCpuTimeSW == 1
    fprintf('## no. of cliques = %4d, min clique = %3d, max clique = %3d, average size = %5.1f\n',...
        clique.NoC,clique.minC,clique.maxC,sum(clique.NoElem)/clique.NoC);
end

startingTime = cputime;
reductionSW = 1; %  reductionSW=1 makes faster 
if reductionSW == 1
%     bdUnionOfCliques = 20; 
%     [clique,adjacencyMatrixT,edgeCostVectT,incidenceMatrixT] = ... 
%         reduceTree0(clique,adjacencyMatrixT,edgeCostVectT,incidenceMatrixT,bdUnionOfCliques); 
    modifiedSW = 1; 
	sigma0 = 0.2;
    sigma1 = 0.3;
    iteration = 0; 
    maxIteration = 10; 
    while (modifiedSW == 1) && (iteration < maxIteration)
        iteration = iteration + 1; 
        modifiedSW = 0;        
%        startingTime = cputime;
        [modifiedSW,clique,adjacencyMatrixT,edgeCostVectT,incidenceMatrixT] = ...
            reduceTreeA(clique,adjacencyMatrixT,edgeCostVectT,incidenceMatrixT,sigma0);
%        fprintf('cputime for reduceTreeA = %6.1e\n',cputime-startingTime); 
%        startingTime = cputime;
        [modifiedSW,clique,adjacencyMatrixT,edgeCostVectT,incidenceMatrixT] = ...
            reduceTreeB(clique,adjacencyMatrixT,edgeCostVectT,incidenceMatrixT,sigma1);
%        fprintf('cputime for reduceTreeB = %6.1e\n',cputime-startingTime); 
%         sigma0 = sigma0 + 0.05; 
%         sigma1 = sigma1 + 0.05;
    end
    bdUnionOfCliques = 20; 
    [clique,adjacencyMatrixT,edgeCostVectT,incidenceMatrixT] = ... 
        reduceTree0(clique,adjacencyMatrixT,edgeCostVectT,incidenceMatrixT,bdUnionOfCliques); 
    if printCpuTimeSW == 1
        fprintf('## no. of cliques = %4d, min clique = %3d, max clique = %3d, average size = %5.1f\n',...
        clique.NoC,clique.minC,clique.maxC,sum(clique.NoElem)/clique.NoC);
    end
end
if printCpuTimeSW == 1
    fprintf('/// cputime for reduceTreeA, B and 0 = %6.1e\n',cputime-startingTime); 
end

% Sparsity pattern information on equalites added to identify some
% variables in different matrix block variables ---> 
startingTime = cputime;
[idEqPattern] = genIdEqPattern(clique,edgeCostVectT,incidenceMatrixT);
if printCpuTimeSW == 1
    fprintf('/// cputime for genIdEqPattern3 = %6.1e\n',cputime-startingTime); 
end
% <--- Sparsity pattern information on equalites added to identify some
% variables in different matrix block variables 

% full(idEqPattern)
% 
% spy(idEqPattern);
% 
% XXXXX
% 
debugSW = 0;
if debugSW == 1
    fprintf('Information on the clique tree computed\n'); 
    fprintf('treeValue = %d\n',treeValue);
    fprintf('%d x %d adjacencyMatrixT\n',clique.NoC,clique.NoC)
    fprintf('     ');
    for q=1:clique.NoC
        fprintf('%3d',q);
    end
    fprintf('\n');
    for p=1:clique.NoC
        fprintf('%3d: ',p); 
        for q=1:clique.NoC
            fprintf('%3d',full(adjacencyMatrixT(p,q)));
        end
        fprintf('\n');
    end
    fprintf('edge '); 
    for q=1:clique.NoC-1
        fprintf('%3d',basisIdx(q)); 
    end    
    fprintf('\n'); 
    fprintf('1 x %d edgeCostVectT\n',clique.NoC-1)
    fprintf('     ');
    for q=1:clique.NoC-1
        fprintf('%3d',full(edgeCostVectT(q)));
    end
    fprintf('\n');
    fprintf('%d x %d incidenceMatrixT\n',clique.NoC,clique.NoC-1)
    fprintf('     ');
    for q=1:clique.NoC-1
        fprintf('%3d',q);
    end
    fprintf('\n');
    for p=1:clique.NoC
        fprintf('%3d: ',p); 
        for q=1:clique.NoC-1
            fprintf('%3d',full(incidenceMatrixT(p,q)));
        end
        fprintf('\n');
    end
    fprintf('Information on equalities added to identify some variables\n');
%    fprintf('   eqSize  idEqPattern\n'); 
    fprintf('idEqPattern\n'); 
    for q=1:clique.NoC
        fprintf('%3d',q);
    end
    fprintf('\n');
    for p=1:clique.NoC-1
        for q=1:clique.NoC
            fprintf('%3d',full(idEqPattern(p,q)));
        end
        fprintf('\n');
    end 
end

% XXXXX

% Construction of an equality form SDP ---> 
startingTime = cputime;
[Apc,cPc,Kpc] = primalOneSDP2(clique,sDim,idEqPattern,A,c,K); 
if printCpuTimeSW == 1
    fprintf('/// cputime for primalOneSDP2 = %6.1e\n',cputime-startingTime); 
end
%                checkSparsity(A,b,c,K);
%                XXXXX

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [modifiedSW,clique,adjacencyMatrixT,edgeCostVectT,incidenceMatrixT] = ... 
    reduceTreeA(clique,adjacencyMatrixT,edgeCostVectT,incidenceMatrixT,sigma0); 

modifiedSW = 0; 
noOfNodes = size(incidenceMatrixT,1); 
noOfEdges = size(incidenceMatrixT,2); 
nodeDegree = sum(spones(incidenceMatrixT),2); 
activeNode = [1:noOfNodes];
activeEdge = [1:noOfEdges]; 

%%%%%%%%%%
debugSW =0;
if debugSW == 1
	clique
    fprintf('\nInformation on cliques: \n');        
    for p=1:clique.NoC
        fprintf(' %2d: ',p);
        for i=1:length(clique.Set{p})
            fprintf(' %2d',clique.Set{p}(i));
        end
        fprintf('\n');        
    end
    fprintf('Information on the clique tree computed\n');    
    fprintf('%d x %d adjacencyMatrixT\n',clique.NoC,clique.NoC)
    fprintf('     ');
    for q=1:clique.NoC
        fprintf('%3d',q);
    end
    fprintf('\n');
    for p=1:clique.NoC
        fprintf('%3d: ',p); 
        for q=1:clique.NoC
            fprintf('%3d',full(adjacencyMatrixT(p,q)));
        end
        fprintf('\n');
    end
    fprintf('           1 x %d edgeCostVectT\n',clique.NoC-1)
    fprintf('         ');
    for q=1:clique.NoC-1
        fprintf('%3d',full(edgeCostVectT(q)));
    end
    fprintf('\n');
    fprintf('     nDeg, %d x %d incidenceMatrixT\n',clique.NoC,clique.NoC-1)
    fprintf('         ');
    for q=1:clique.NoC-1
        fprintf('%3d',q);
    end
    fprintf('\n');
    for p=1:clique.NoC
        fprintf('%3d: ',p);
        fprintf('%3d ',nodeDegree(p)); 
        for q=1:clique.NoC-1
            fprintf('%3d',full(incidenceMatrixT(p,q)));
        end
        fprintf('\n');
    end
end
%%%%%%%%%

% full(nodeDegree)

idxNode3 = find(nodeDegree' >= 3); 
for i1=idxNode3
    idxEdge3 = find(incidenceMatrixT(i1,:));    
    for j=idxEdge3
%         j
%         size(incidenceMatrixT)
%         
        adjTwoNodes = find(incidenceMatrixT(:,j)');       
        i2 = adjTwoNodes(1); 
        if i1 == i2
            i2 = adjTwoNodes(2); 
        end
        %%%%%%%%%%
        debugSW = 0; 
        if (debugSW == 1) && (i1==10) && (j==7)
            idxEdge3
            i1
            j
            adjTwoNodes
            i2
            nodeDegree(i2)
%             clique
%             clique.Elem
%             for p=1:clique.NoC
%                 clique.Set{p}
%             end
%            XXXXX
        end
        %%%%%%%%%
        sigma = min([edgeCostVectT(j)/clique.NoElem(i1),edgeCostVectT(j)/clique.NoElem(i2)]); 
        if (nodeDegree(i2) == 1) && (sigma > sigma0) 
            modifiedSW = 1; 
            incidenceMatrixT(i1,:) = incidenceMatrixT(i1,:) + incidenceMatrixT(i2,:); 
            incidenceMatrixT(:,j) = sparse(noOfNodes,1); 
            incidenceMatrixT(i2,:) = sparse(1,noOfEdges); 
            activeEdge = setdiff(activeEdge,j);
            activeNode = setdiff(activeNode,i2);
            clique.Set{i1} = union(clique.Set{i1},clique.Set{i2});
            clique.Set{i1} = sort(clique.Set{i1});
            clique.NoElem(i1) = length(clique.Set{i1}); 
            clique.Set{i2} = []; 
            clique.NoElem(i2) = 0;
            %%%%%%%%%%
            % 02/04/2009 ---> 
            % To fix bug; error when maxG32.mat was solved 
            % incidenceMatrixT was not updated correctly
            updtIdxSet = find(incidenceMatrixT(i1,:) ~= 0); 
            for k = updtIdxSet
                I = find(incidenceMatrixT(:,k)' ~= 0); 
                i3 = I(1); 
                if i3 == i1
                    i3 = I(2);
                end
                temp = edgeCostVectT(k);
                edgeCostVectT(k) = length(intersect(clique.Set{i1},clique.Set{i3})); 
%                 if temp ~= edgeCostVectT(k)
%                     XXXXX
%                 end
            end
            % <--- 02/04/2009 
            %%%%%%%%%%
            debugSW = 0;
            if (debugSW == 1) && (i1==10) && (j==7) 
%                 clique
%                 clique.Elem
                for p=1:clique.NoC
                    clique.Set{p}
                end
                activeEdge
                full(incidenceMatrixT)
                activeNode
                XXXX
            end
        end
    end
end
incidenceMatrixT = incidenceMatrixT(activeNode,activeEdge); 
edgeCostVectT = edgeCostVectT(1,activeEdge); 
pointer = 0;
clique.Elem = [];
clique.NoElem = [];
for p=1:clique.NoC
    if ~isempty(clique.Set{p}) 
        pointer = pointer + 1;
        clique.Set{pointer} = clique.Set{p};
        clique.Elem = [clique.Elem,clique.Set{p}];
        clique.NoElem = [clique.NoElem, length(clique.Set{p})]; 
    end
end
for p=pointer+1:clique.NoC
    clique.Set{p} = [];
    clear clique.Set{p}
end
clique.NoC = length(activeNode); 
clique.maxC = max(clique.NoElem);
clique.minC = min(clique.NoElem);


adjacencyMatrixT=sparse(clique.NoC,clique.NoC); 
for p=1:clique.NoC-1
    idx = find(incidenceMatrixT(:,p)'); 
    adjacencyMatrixT(idx(1),idx(2)) = edgeCostVectT(p);
end
nodeDegree = sum(spones(incidenceMatrixT),2); 

%%%%%%%%%%
debugSW =0;
if debugSW == 1
    clique
%     fprintf('\nInformation on cliques: \n');        
%     for p=1:clique.NoC
%         fprintf(' %2d: ',p);
%         for i=1:length(clique.Set{p})
%             fprintf(' %2d',clique.Set{p}(i));
%         end
%         fprintf('\n');        
%     end
    fprintf('Information on the clique tree computed\n');    
    fprintf('%d x %d adjacencyMatrixT\n',clique.NoC,clique.NoC)
    fprintf('     ');
    for q=1:clique.NoC
        fprintf('%3d',q);
    end
    fprintf('\n');
    for p=1:clique.NoC
        fprintf('%3d: ',p); 
        for q=1:clique.NoC
            fprintf('%3d',full(adjacencyMatrixT(p,q)));
        end
        fprintf('\n');
    end
    fprintf('           1 x %d edgeCostVectT\n',clique.NoC-1)
    fprintf('         ');
    for q=1:clique.NoC-1
        fprintf('%3d',full(edgeCostVectT(q)));
    end
    fprintf('\n');
    fprintf('     nDeg, %d x %d incidenceMatrixT\n',clique.NoC,clique.NoC-1)
    fprintf('         ');
    for q=1:clique.NoC-1
        fprintf('%3d',q);
    end
    fprintf('\n');
    for p=1:clique.NoC
        fprintf('%3d: ',p);
        fprintf('%3d ',nodeDegree(p)); 
        for q=1:clique.NoC-1
            fprintf('%3d',full(incidenceMatrixT(p,q)));
        end
        fprintf('\n');
    end
    XXXXX
end
%%%%%%%%%

% XXXXX

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [modifiedSW,clique,adjacencyMatrixT,edgeCostVectT,incidenceMatrixT] = ... 
    reduceTreeB(clique,adjacencyMatrixT,edgeCostVectT,incidenceMatrixT,sigma1); 

modifiedSW = 0; 
noOfNodes = size(incidenceMatrixT,1); 
noOfEdges = size(incidenceMatrixT,2); 
nodeDegree = sum(spones(incidenceMatrixT),2); 
activeNode = [1:noOfNodes];
activeEdge = [1:noOfEdges]; 

%%%%%%%%%%
debugSW =0;
if debugSW == 1
	clique
    fprintf('\nInformation on cliques: \n');        
    for p=1:clique.NoC
        fprintf(' %2d: ',p);
        for i=1:length(clique.Set{p})
            fprintf(' %2d',clique.Set{p}(i));
        end
        fprintf('\n');        
    end
    fprintf('Information on the clique tree computed\n');    
    fprintf('%d x %d adjacencyMatrixT\n',clique.NoC,clique.NoC)
    fprintf('     ');
    for q=1:clique.NoC
        fprintf('%3d',q);
    end
    fprintf('\n');
    for p=1:clique.NoC
        fprintf('%3d: ',p); 
        for q=1:clique.NoC
            fprintf('%3d',full(adjacencyMatrixT(p,q)));
        end
        fprintf('\n');
    end
    fprintf('           1 x %d edgeCostVectT\n',clique.NoC-1)
    fprintf('         ');
    for q=1:clique.NoC-1
        fprintf('%3d',full(edgeCostVectT(q)));
    end
    fprintf('\n');
    fprintf('     nDeg, %d x %d incidenceMatrixT\n',clique.NoC,clique.NoC-1)
    fprintf('         ');
    for q=1:clique.NoC-1
        fprintf('%3d',q);
    end
    fprintf('\n');
    for p=1:clique.NoC
        fprintf('%3d: ',p);
        fprintf('%3d ',nodeDegree(p)); 
        for q=1:clique.NoC-1
            fprintf('%3d',full(incidenceMatrixT(p,q)));
        end
        fprintf('\n');
    end
end
%%%%%%%%%

for j=1:noOfEdges
    adjTwoNodes = find(incidenceMatrixT(:,j)'); 
    i1 = adjTwoNodes(1);
    i2 = adjTwoNodes(2);
    if min(nodeDegree([i1,i2])) <= 2
        if nodeDegree(i1) < nodeDegree(i2)
            ii = i1;
            i1 = i2; 
            i2 = ii;
        end
        sigma = min([edgeCostVectT(j)/clique.NoElem(i1),edgeCostVectT(j)/clique.NoElem(i2)]); 
        if (sigma > sigma1) 
            modifiedSW = 1; 
            incidenceMatrixT(i1,:) = incidenceMatrixT(i1,:) + incidenceMatrixT(i2,:); 
            incidenceMatrixT(:,j) = sparse(noOfNodes,1); 
            incidenceMatrixT(i2,:) = sparse(1,noOfEdges); 
            activeEdge = setdiff(activeEdge,j);
            activeNode = setdiff(activeNode,i2);
            clique.Set{i1} = union(clique.Set{i1},clique.Set{i2});
            clique.Set{i1} = sort(clique.Set{i1});
            clique.NoElem(i1) = length(clique.Set{i1}); 
            clique.Set{i2} = []; 
            clique.NoElem(i2) = 0;
            %%%%%%%%%%
            % 02/04/2009 ---> 
            % To fix bug; error when maxG32.mat was solved 
            % incidenceMatrixT was not updated correctly
            updtIdxSet = find(incidenceMatrixT(i1,:) ~= 0); 
            for k = updtIdxSet
                I = find(incidenceMatrixT(:,k)' ~= 0); 
                i3 = I(1); 
                if i3 == i1
                    i3 = I(2);
                end
%                temp = edgeCostVectT(k);
                edgeCostVectT(k) = length(intersect(clique.Set{i1},clique.Set{i3})); 
%                 if temp ~= edgeCostVectT(k)
%                     XXXXX
%                end
            end
            % <--- 02/04/2009 
            %%%%%%%%%%
            debugSW = 0;
            if (debugSW == 1) && (i1==10) && (j==7) 
%                 clique
%                 clique.Elem
                for p=1:clique.NoC
                    clique.Set{p}
                end
                activeEdge
                full(incidenceMatrixT)
                activeNode
                XXXX
            end
        end
    end
end
incidenceMatrixT = incidenceMatrixT(activeNode,activeEdge); 
edgeCostVectT = edgeCostVectT(1,activeEdge); 
pointer = 0;
clique.Elem = [];
clique.NoElem = [];
for p=1:clique.NoC
    if ~isempty(clique.Set{p}) 
        pointer = pointer + 1;
        clique.Set{pointer} = clique.Set{p};
        clique.Elem = [clique.Elem,clique.Set{p}];
        clique.NoElem = [clique.NoElem, length(clique.Set{p})]; 
    end
end
for p=pointer+1:clique.NoC
    clique.Set{p} = [];
    clear clique.Set{p}
end
clique.NoC = length(activeNode); 
clique.maxC = max(clique.NoElem);
clique.minC = min(clique.NoElem);


adjacencyMatrixT=sparse(clique.NoC,clique.NoC); 
for p=1:clique.NoC-1
    idx = find(incidenceMatrixT(:,p)'); 
    adjacencyMatrixT(idx(1),idx(2)) = edgeCostVectT(p);
end
nodeDegree = sum(spones(incidenceMatrixT),2); 

%%%%%%%%%%
debugSW =0;
if debugSW == 1
    clique
%     fprintf('\nInformation on cliques: \n');        
%     for p=1:clique.NoC
%         fprintf(' %2d: ',p);
%         for i=1:length(clique.Set{p})
%             fprintf(' %2d',clique.Set{p}(i));
%         end
%         fprintf('\n');        
%     end
    fprintf('Information on the clique tree computed\n');    
    fprintf('%d x %d adjacencyMatrixT\n',clique.NoC,clique.NoC)
    fprintf('     ');
    for q=1:clique.NoC
        fprintf('%3d',q);
    end
    fprintf('\n');
    for p=1:clique.NoC
        fprintf('%3d: ',p); 
        for q=1:clique.NoC
            fprintf('%3d',full(adjacencyMatrixT(p,q)));
        end
        fprintf('\n');
    end
    fprintf('           1 x %d edgeCostVectT\n',clique.NoC-1)
    fprintf('         ');
    for q=1:clique.NoC-1
        fprintf('%3d',full(edgeCostVectT(q)));
    end
    fprintf('\n');
    fprintf('     nDeg, %d x %d incidenceMatrixT\n',clique.NoC,clique.NoC-1)
    fprintf('         ');
    for q=1:clique.NoC-1
        fprintf('%3d',q);
    end
    fprintf('\n');
    for p=1:clique.NoC
        fprintf('%3d: ',p);
        fprintf('%3d ',nodeDegree(p)); 
        for q=1:clique.NoC-1
            fprintf('%3d',full(incidenceMatrixT(p,q)));
        end
        fprintf('\n');
    end
%    XXXXX
end
%%%%%%%%%

% XXXXX

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [clique,adjacencyMatrixT,edgeCostVectT,incidenceMatrixT] = ... 
    reduceTree0(clique,adjacencyMatrixT,edgeCostVectT,incidenceMatrixT,bdUnionOfCliques); 

noOfNodes = size(incidenceMatrixT,1); 
noOfEdges = size(incidenceMatrixT,2); 
nodeDegree = sum(spones(incidenceMatrixT),2); 

%%%%%%%%%%
debugSW =0;
if debugSW == 1
	clique
    fprintf('\nInformation on cliques: \n');        
    for p=1:clique.NoC
        fprintf(' %2d: ',p);
        for i=1:length(clique.Set{p})
            fprintf(' %2d',clique.Set{p}(i));
        end
        fprintf('\n');        
    end
    fprintf('Information on the clique tree computed\n');    
    fprintf('%d x %d adjacencyMatrixT\n',clique.NoC,clique.NoC)
    fprintf('     ');
    for q=1:clique.NoC
        fprintf('%3d',q);
    end
    fprintf('\n');
    for p=1:clique.NoC
        fprintf('%3d: ',p); 
        for q=1:clique.NoC
            fprintf('%3d',full(adjacencyMatrixT(p,q)));
        end
        fprintf('\n');
    end
    fprintf('           1 x %d edgeCostVectT\n',clique.NoC-1)
    fprintf('         ');
    for q=1:clique.NoC-1
        fprintf('%3d',full(edgeCostVectT(q)));
    end
    fprintf('\n');
    fprintf('     nDeg, %d x %d incidenceMatrixT\n',clique.NoC,clique.NoC-1)
    fprintf('         ');
    for q=1:clique.NoC-1
        fprintf('%3d',q);
    end
    fprintf('\n');
    for p=1:clique.NoC
        fprintf('%3d: ',p);
        fprintf('%3d ',nodeDegree(p)); 
        for q=1:clique.NoC-1
            fprintf('%3d',full(incidenceMatrixT(p,q)));
        end
        fprintf('\n');
    end
end
%%%%%%%%%

continueSW = 1;
noOfCliques = clique.NoC; 
pointer = 0; 
edgeIdxChecked = sparse(1,clique.NoC-1); 
combinePair = sparse(noOfCliques,1);
largeCliqueIdx = find(clique.NoElem >= bdUnionOfCliques); 
combinePair(largeCliqueIdx) = 1;
while continueSW == 1
    edgeIdx = find(edgeIdxChecked == 0);
    continueSW = 0; 
    if ~isempty(edgeIdx)
        for e=edgeIdx
            nodeIdx = find(incidenceMatrixT(:,e)');
            %            combinePair(nodeIdx,1)'
            %             e
            %             nodeIdx

            if (nnz(combinePair(nodeIdx,1)') == 0)
                tempCliqueSet = union(clique.Set{nodeIdx(1)},clique.Set{nodeIdx(2)});
                lenTempCliqueSet = length(tempCliqueSet);
                %
                %                 lenTempCliqueSet
                %                 bdUnionOfCliques

                if lenTempCliqueSet <= bdUnionOfCliques
                    continueSW = 1;
                    pointer = pointer + 1;
                    if lenTempCliqueSet >= bdUnionOfCliques
                        combinePair(nodeIdx(1),1) = 1;
                    end
                    combinePair(nodeIdx(2),1) = -1;
                    %                     format long
                    %                     full(combinePair)
                    %                     format short
                    edgeCostVectT(e) = -pointer;
                    clique.Set{nodeIdx(1)} = tempCliqueSet;
                    clique.NoElem(nodeIdx(1)) = lenTempCliqueSet;
                    clique.Set{nodeIdx(2)} = [];
                    clique.NoElem(nodeIdx(2)) = 0;
                    incidenceMatrixT(nodeIdx(1),:) = incidenceMatrixT(nodeIdx(1),:)+incidenceMatrixT(nodeIdx(2),:);
                    edgeIdxChecked(e) = -1;
                else
                    edgeIdxChecked(e) = 1;
                end
            end
            debugSW = 0;
            if debugSW == 1
                fprintf('\n');
                fprintf('edgeIdxChecked\n         ') 
                for q=1:clique.NoC-1
                	fprintf('%3d',full(edgeIdxChecked(q)));
                end
                fprintf('\n');
                fprintf('    cPair, %d x %d incidenceMatrixT\n',clique.NoC,clique.NoC-1)
                fprintf('         ');
                for q=1:clique.NoC-1
                    fprintf('%3d',q);
                end
                fprintf('\n');
                for p=1:clique.NoC
                    fprintf('%3d: ',p);
                    fprintf('%3d ',combinePair(p,1));
                    for q=1:clique.NoC-1
                        fprintf('%3d',full(incidenceMatrixT(p,q)));
                    end
                    fprintf('\n');
                end
            end
        end
%         newNodeSetToCheck = intersect(find(combinePair >= 0),find(combinePair <= 1.0e6)); 
%         combinePair(newNodeSetToCheck,1) = 0;
    end    
end

%XXXXX

% full(edgeIdxChecked)
% % 
% full(combinePair')


newEdgeIdx = find(edgeIdxChecked >= 0); 
newNodeIdx = find(combinePair' >= 0);

% edgeCostVectT
% full(incidenceMatrixT)

edgeCostVectT = edgeCostVectT(newEdgeIdx); 
incidenceMatrixT = incidenceMatrixT(newNodeIdx,newEdgeIdx); 

% edgeCostVectT 
% 
% full(incidenceMatrixT)

pointer = 0;
clique.Elem = [];
clique.NoElem = [];
for p=1:clique.NoC
    if ~isempty(clique.Set{p}) 
        pointer = pointer + 1;
        clique.Set{pointer} = clique.Set{p};
        clique.Elem = [clique.Elem,clique.Set{p}];
        clique.NoElem = [clique.NoElem, length(clique.Set{p})]; 
    end
end
for p=pointer+1:clique.NoC
    clique.Set{p} = [];
    clear clique.Set{p}
end
clique.NoC = size(incidenceMatrixT,1); 


clique.maxC = max(clique.NoElem);
clique.minC = min(clique.NoElem);

adjacencyMatrixT=sparse(clique.NoC,clique.NoC); 
for p=1:clique.NoC-1
    idx = find(incidenceMatrixT(:,p)'); 
    adjacencyMatrixT(idx(1),idx(2)) = edgeCostVectT(p);
end
nodeDegree = sum(spones(incidenceMatrixT),2); 

%%%%%%%%%%
debugSW =0;
if debugSW == 1
    clique
%     fprintf('\nInformation on cliques: \n');        
%     for p=1:clique.NoC
%         fprintf(' %2d: ',p);
%         for i=1:length(clique.Set{p})
%             fprintf(' %2d',clique.Set{p}(i));
%         end
%         fprintf('\n');        
%     end
    fprintf('Information on the clique tree computed\n');    
    fprintf('%d x %d adjacencyMatrixT\n',clique.NoC,clique.NoC)
    fprintf('     ');
    for q=1:clique.NoC
        fprintf('%3d',q);
    end
    fprintf('\n');
    for p=1:clique.NoC
        fprintf('%3d: ',p); 
        for q=1:clique.NoC
            fprintf('%3d',full(adjacencyMatrixT(p,q)));
        end
        fprintf('\n');
    end
    fprintf('           1 x %d edgeCostVectT\n',clique.NoC-1)
    fprintf('         ');
    for q=1:clique.NoC-1
        fprintf('%3d',full(edgeCostVectT(q)));
    end
    fprintf('\n');
    fprintf('     nDeg, %d x %d incidenceMatrixT\n',clique.NoC,clique.NoC-1)
    fprintf('         ');
    for q=1:clique.NoC-1
        fprintf('%3d',q);
    end
    fprintf('\n');
    for p=1:clique.NoC
        fprintf('%3d: ',p);
        fprintf('%3d ',nodeDegree(p)); 
        for q=1:clique.NoC-1
            fprintf('%3d',full(incidenceMatrixT(p,q)));
        end
        fprintf('\n');
    end
    XXXXX
end
%%%%%%%%%

% XXXXX

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Apc,cPc,Kpc] = primalOneSDP(clique,sDim,idEqPattern,A,c,K); 

printCpuTimeSW = 0;

%%%%%%
Kpc.s = clique.NoElem; 
%%%%%%

% startingTime = cputime;

% clique element positions in vec X ---> 
for p=1:clique.NoC
    clPosInVecX{p} = ...
        reshape(ones(Kpc.s(p),1)*(clique.Set{p}-1)*sDim +clique.Set{p}'*ones(1,Kpc.s(p)),1,Kpc.s(p)*Kpc.s(p)); 
end
% <--- clique element positions in vec X

% <-- clique element positions in vec X
% clique element positions in vec X not covered by all the others ---> 
for p=1:clique.NoC
     UniqueClPosInVecX{p} = clPosInVecX{p};
     idx = setdiff([1:clique.NoC],p);     
%      nzIdx = find(adjacencyMatrixT(p,:)+adjacencyMatrixT(:,p)'); 
%      for i=nzIdx 
    for i=idx
         UniqueClPosInVecX{p} = setdiff(UniqueClPosInVecX{p},clPosInVecX{i});
     end
%      full(UniqueClPosInVecX{p})   
end
% <--- clique element positions in vec X not covered by all the others


%%%%%% blockPointer ---> 
blockPointer = zeros(1,clique.NoC);
for p=1:clique.NoC-1
    blockPointer(p+1) = blockPointer(p) + Kpc.s(p)*Kpc.s(p);
end
nDimPc = blockPointer(clique.NoC) + Kpc.s(clique.NoC)*Kpc.s(clique.NoC);   
%%%%%% <--- blockPointer

% fprintf('cputime for clPosInVecX, UniqueClPosInVecX and blockPointer = %5.1e\n',cputime-startingTime); 

modifySW = 1;
if modifySW == 0
    startingTime = cputime;
    cPc = sparse(1,nDimPc);
    for p=1:clique.NoC
        if isempty(find(c,1))
            p = clique.NoC;
        else % if ~isempty(find(c(1,clPosInVecX{p}),1))
            cPc(1,blockPointer(p)+1:blockPointer(p)+Kpc.s(p)*Kpc.s(p)) = ...
                cPc(1,blockPointer(p)+1:blockPointer(p)+Kpc.s(p)*Kpc.s(p)) + c(1,clPosInVecX{p});
            c(1,clPosInVecX{p}) = sparse(1,Kpc.s(p)*Kpc.s(p));
        end
    end
    if printCpuTimeSW == 1
        fprintf('cputime for cPc = %5.1e\n',cputime-startingTime);
    end
    startingTime = cputime;
    mDim = size(A,1);
    Apc = sparse(mDim,nDimPc);
    ApcPattern = [];
    for i=1:mDim
        CurrentEqSpPat = sparse(1,clique.NoC);
        for p=1:clique.NoC
            if isempty(find( A(i,:)))
                p = clique.NoC;
            elseif ~isempty(find(A(i,UniqueClPosInVecX{p})))
                Apc(i,blockPointer(p)+1:blockPointer(p)+Kpc.s(p)*Kpc.s(p)) = ...
                    Apc(i,blockPointer(p)+1:blockPointer(p)+Kpc.s(p)*Kpc.s(p))+A(i,clPosInVecX{p});
                A(i,clPosInVecX{p}) = sparse(1,Kpc.s(p)*Kpc.s(p));
                CurrentEqSpPat(1,p) = 1;
            end
        end
        ApcPattern = [ApcPattern; CurrentEqSpPat];
    end
    if printCpuTimeSW == 1
        fprintf('cputime for Apc part 1 = %5.1e\n',cputime-startingTime); 
    end
elseif modifySW == 1
%    startingTime = cputime;    
    mDim = size(A,1);
    cPc = sparse(1,nDimPc);
    Apc = sparse(mDim,nDimPc);
    ApcPattern = sparse(mDim,clique.NoC); 
    for p=1:clique.NoC
        cPc(1,blockPointer(p)+1:blockPointer(p)+Kpc.s(p)*Kpc.s(p)) = ...
            cPc(1,blockPointer(p)+1:blockPointer(p)+Kpc.s(p)*Kpc.s(p)) + c(1,clPosInVecX{p});
        c(1,clPosInVecX{p}) = sparse(1,Kpc.s(p)*Kpc.s(p));
        ApcPattern(:,p) = spones(sum(abs(A(:,UniqueClPosInVecX{p})),2));
        nzIdx = find(ApcPattern(:,p)');
        if ~isempty(nzIdx)
            nzDim = length(nzIdx);
            Apc(nzIdx,blockPointer(p)+1:blockPointer(p)+Kpc.s(p)*Kpc.s(p)) = ...
                Apc(nzIdx,blockPointer(p)+1:blockPointer(p)+Kpc.s(p)*Kpc.s(p))+A(nzIdx,clPosInVecX{p});
            A(nzIdx,clPosInVecX{p}) = sparse(nzDim,Kpc.s(p)*Kpc.s(p));
        end
    end
%    fprintf('cputime for cPc and Apc part 1 = %5.1e\n',cputime-startingTime); 
end

%%%%%%%%
% bPc = sparse(size(Apc,1),1); 
% checkSparsity(Apc,bPc,cPc,Kpc);
% XXXXX
%%%%%%%%

eqPattern = [ApcPattern; idEqPattern];

clear ApcPattern idEqPattern

% startingTime = cputime;

for i=1:mDim
    if ~isempty(find( A(i,:)))
        nzColIdx = find(eqPattern(i,:));
        zeroColIdx = find(eqPattern(i,:) == 0);
        while ~isempty(find( A(i,:)))
            if isempty(nzColIdx)
                zeroRowIdx = [1:mDim+clique.NoC-1];
            else
                zeroRowIdx = find(sum(eqPattern(:,nzColIdx),1)' == 0);
            end
            if ~isempty(zeroRowIdx)
                [temp,idx] = sort(sum(eqPattern(zeroRowIdx,zeroColIdx),1));
            else
%                idx = zeroColIdx; 
                idx = [1:length(zeroColIdx)]; 
            end
            j = 0; 
            while j < length(idx) 
            	j = j+1; 
                q = idx(j);
                p = zeroColIdx(q);
                if ~isempty(find(A(i,clPosInVecX{p})))
                    Apc(i,blockPointer(p)+1:blockPointer(p)+Kpc.s(p)*Kpc.s(p)) = ... 
                        Apc(i,blockPointer(p)+1:blockPointer(p)+Kpc.s(p)*Kpc.s(p))+A(i,clPosInVecX{p});
                    A(i,clPosInVecX{p}) = sparse(1,Kpc.s(p)*Kpc.s(p));
                    eqPattern(i,p) = 1;
                    j = length(idx);
                    nzColIdx = [nzColIdx,p];
                else
                    nzColIdx = [nzColIdx,p];
                end
            end
            zeroColIdx = setdiff(zeroColIdx,nzColIdx);
        end
    end
end

%%%%%%%
% bPc = sparse(size(Apc,1),1); 
% checkSparsity(Apc,bPc,cPc,Kpc);
% XXXXX
%%%%%%%

% fprintf('cputime for Apc part 2 = %5.1e\n',cputime-startingTime); 

%%%%%% <--- Construction of a coefficient matrix 1: Conversion of the original constraints A x = b
% startingTime = cputime;
modifySW = 1;
if modifySW == 0
    for i=mDim+1:mDim+clique.NoC-1
        clIdx = find(eqPattern(i,:));
        c1 = clIdx(1);
        c2 = clIdx(2);
        m1 = Kpc.s(c1); % length(clique.Set{c1});
        m2 = Kpc.s(c2); % length(clique.Set{c2});
        cc = intersect(clique.Set{c1},clique.Set{c2});
        [idx1,idx2] = find(clique.Set{c1}'*ones(1,m2) - ones(m1,1)*clique.Set{c2} == 0);
        lDim = length(idx1');
        for j = 1:lDim
            for k = j:lDim
                EMat1 = sparse(m1,m1);
                p = idx1(j,1);
                q = idx1(k,1);
                EMat1(p,q) = 1;
                EMat1(q,p) = 1;
                EMat2 = sparse(m2,m2);
                p = idx2(j,1);
                q = idx2(k,1);
                EMat2(p,q) = -1;
                EMat2(q,p) = -1;
                oneLine= sparse(1,nDimPc);
                oneLine(1,blockPointer(c1)+1:blockPointer(c1)+m1*m1) = reshape(EMat1,1,m1*m1);
                oneLine(1,blockPointer(c2)+1:blockPointer(c2)+m2*m2) = reshape(EMat2,1,m2*m2);
                Apc =[Apc;oneLine];
                %            bPc = [bPc;0];
            end
        end
    end
elseif modifySW == 1
    for i=mDim+1:mDim+clique.NoC-1
        clIdx = find(eqPattern(i,:));
        c1 = clIdx(1);
        c2 = clIdx(2);
        m1 = Kpc.s(c1); % length(clique.Set{c1});
        m2 = Kpc.s(c2); % length(clique.Set{c2});
        cc = intersect(clique.Set{c1},clique.Set{c2});
        [idx1,idx2] = find(clique.Set{c1}'*ones(1,m2) - ones(m1,1)*clique.Set{c2} == 0);
        idx1 = idx1';
        idx2 = idx2';
        lDim = length(idx1);        
%         full(eqPattern(i,:))
%         full(clIdx)
%         c1
%         c2
%         clique.Set{c1}
%         clique.Set{c2}
%         m1
%         m2
%         cc
%         idx1
%         idx2                
        oneBlock = sparse(lDim*(lDim+1)/2,nDimPc); 
        IMat1 = speye(m1*m1,m1*m1);         
        EMat1All0 = ones(lDim,1)*(idx1-ones(1,lDim))*m1 + idx1'*ones(1,lDim);          

        EMat1All = tril(EMat1All0,0);        
        Evect1All = reshape(EMat1All,1,lDim*lDim);
        nzIdx1 = find(Evect1All); 
        nzIdx1 = Evect1All(nzIdx1);
        oneBlock(:,blockPointer(c1)+1:blockPointer(c1)+m1*m1) = IMat1(nzIdx1,:); 
        
        %%%%% 
        EMat1All = triu(EMat1All0,0)'; 
        Evect1All = reshape(EMat1All,1,lDim*lDim);
        nzIdx1 = find(Evect1All); 
        nzIdx1 = Evect1All(nzIdx1);
        oneBlock(:,blockPointer(c1)+1:blockPointer(c1)+m1*m1) = ...
            oneBlock(:,blockPointer(c1)+1:blockPointer(c1)+m1*m1)+IMat1(nzIdx1,:); 
        %%%%%
        
        IMat2 = speye(m2*m2,m2*m2); 
        EMat2All0 = ones(lDim,1)*(idx2-ones(1,lDim))*m2 + idx2'*ones(1,lDim); 
        
        EMat2All = tril(EMat2All0,0);         
        Evect2All = reshape(EMat2All,1,lDim*lDim);
        nzIdx2 = find(Evect2All); 
        nzIdx2 = Evect2All(nzIdx2);
        oneBlock(:,blockPointer(c2)+1:blockPointer(c2)+m2*m2) = -IMat2(nzIdx2,:); 
        
        %%%%%
        EMat2All = triu(EMat2All0,0)';         
        Evect2All = reshape(EMat2All,1,lDim*lDim);
        nzIdx2 = find(Evect2All); 
        nzIdx2 = Evect2All(nzIdx2);
        oneBlock(:,blockPointer(c2)+1:blockPointer(c2)+m2*m2) = ... 
            oneBlock(:,blockPointer(c2)+1:blockPointer(c2)+m2*m2)-IMat2(nzIdx2,:); 
        %%%%%
 
%         kkk = length(nzIdx2); 
%         for kk=1:kkk
%             BMat = reshape(oneBlock(kk,blockPointer(c2)+1:blockPointer(c2)+m2*m2),m2,m2); 
%             norm(BMat - BMat',inf)
%         end

        Apc =[Apc;oneBlock];        
%         full(IMat1(nzIdx1,:))
%         full(IMat2(nzIdx2,:))
%         YYYYY
    end
end

%%%%%%%%
% bPc = sparse(size(Apc,1),1); 
% checkSparsity(Apc,bPc,cPc,Kpc);
% XXXXX
%%%%%%%%

% fprintf('cputime for Apc part 3 = %5.1e\n',cputime-startingTime);
%%%%%% <--- Construction of a coefficient matrix 2:

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [idEqPattern] = genIdEqPattern(clique,edgeCostVectT,incidenceMatrixT)
% Sparsity pattern information on equalites added to identify some
% variables in different matrix block variables
%%%%%%%%%%%%
% Output
%%%%%%%%%%%%
% Each pth row of idEqPattern is corresponding an edge of the input clique tree 
% described in basisIdx, which results in idEqPattern(p,*) equalites added. 
% Each column of idEqPattern is corresponding to a clique or a matrix block
% variable associated with the clique. 
idEqPattern = sparse(clique.NoC-1,clique.NoC);
for p=1:clique.NoC-1
    twoCliques = find(incidenceMatrixT(:,p)');    
    clique1 = twoCliques(1);
    clique2 = twoCliques(2);
    cost = edgeCostVectT(p)*(edgeCostVectT(p)+1)/2;
    idEqPattern(p,clique1) = cost;
    idEqPattern(p,clique2) = cost;
end
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


