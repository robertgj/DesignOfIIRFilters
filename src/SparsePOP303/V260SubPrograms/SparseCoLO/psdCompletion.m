function [xVect] = psdCompletion(x,K,clique);

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

% perturbation to ensure that XMat(U,U) is positive definite
%
epsilon = 1.0e-10;
% If
% ??? Error using ==> chol
% Matrix must be positive definite.
%
% Error in ==> psdCompletion at 61
%                         LMat = chol(XMat(U,U)+epsilon*speye(nDim,nDim));
%
% Then take a larger epsilon
%
%%%%%%%%%%
rowPointer = 0;
% primal free variables
if isfield(K,'f') && ~isempty(K.f) && (K.f > 0)
    xVect = x(rowPointer+1:rowPointer+K.f,:);
    rowPointer = rowPointer+K.f;
else
    xVect = [];
end
% primal LP variables
if isfield(K,'l') && ~isempty(K.l) && (K.l > 0)
    xVect = [xVect; x(rowPointer+1:rowPointer+K.l,:)];
    rowPointer = rowPointer+K.l;
end
% primal SOCP variables
if isfield(K,'q') && ~isempty(K.q)
    qDim = sum(K.q);
    xVect = [xVect; x(rowPointer+1:rowPointer+qDim,:)];
    rowPointer = rowPointer+sum(K.q);
end
% primal SDP variables
if isfield(K,'s') && ~isempty(K.s)
    nDim = size(x,1);
    uVect = x(rowPointer+1:nDim,:);
    noOfSDPcones = length(K.s);
    rowPointer = 0;
    for kk=1:noOfSDPcones
        % Old Version for
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %
        % This program is effective only for cases where each clique{kk}
        % induces a connected clique graph.
        %
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % --->
        %         if clique{kk}.NoC > 1
        %             sDim = K.s(kk);
        %             XMat = reshape(uVect(rowPointer+1:rowPointer+sDim*sDim,1),sDim,sDim);
        %             [adjacencyMatrixC,noOfEdges,edgeCostVectC,incidenceMatrixC] ...
        %                 = consructCliqueGraph(clique{kk});
        %             %
        %             % We assume that the clique graph is connected
        %             %
        %             randSeed = 2009;
        %             [treeValue,adjacencyMatrixT,edgeCostVectT,incidenceMatrixT] ...
        %                 = maxSpanningTree(clique{kk},adjacencyMatrixC,edgeCostVectC,incidenceMatrixC,randSeed);
        %             kDim = size(incidenceMatrixT,2);
        %             %
        %             %
        %             %
        %             for i=1:clique{kk}.NoC-1
        %                 edgeSet = find(incidenceMatrixT(i,:) ~= 0);
        %                 if ~isempty(edgeSet)
        %                     j = edgeSet(1);
        %                     I = find(incidenceMatrixT(:,j)' ~= 0);
        %                     i2 = I(2);
        %                     U = intersect(clique{kk}.Set{i},clique{kk}.Set{i2});
        %                     S = setdiff(clique{kk}.Set{i},U);
        %                     T = setdiff(clique{kk}.Set{i2},U);
        %                     nDim = length(U);
        %                     % epsilon = 1.0e-10;
        %                     LMat = chol(XMat(U,U)+epsilon*speye(nDim,nDim));
        %                     XMat(S,T) = (XMat(S,U)/LMat)*(LMat'\XMat(U,T));
        %                     XMat(T,S) = XMat(S,T)';
        %                     clique{kk}.Set{i2} = union(clique{kk}.Set{i},clique{kk}.Set{i2});
        %                     incidenceMatrixT(i2,:) = incidenceMatrixT(i2,:) + incidenceMatrixT(i,:);
        %                     incidenceMatrixT(i,:) = sparse(1,kDim);
        %                 end
        %             end
        %             debugSW = 1;
        %             if debugSW == 1
        %                 d = eig(XMat);
        %                 fprintf('minimum eigenvalue of the completed matrix = %+6.1e\n',full(min(d')));
        %             end
        %             xVect = [xVect; reshape(XMat,sDim*sDim,1)];
        %         else
        %             xVect = [xVect; uVect(rowPointer+1:rowPointer+sDim*sDim,1)];
        %         end
        %         rowPointer = rowPointer + sDim*sDim;
        % <---
        % New version
        % --->
        if clique{kk}.NoC > 1
            sDim = K.s(kk);
            XMat = full(reshape(uVect(rowPointer+1:rowPointer+sDim*sDim,1),sDim,sDim));
            if ~isfield(clique{kk},'NoCliqueInForest')
%                1
                [adjacencyMatrixC,noOfEdges,edgeCostVectC,incidenceMatrixC] ...
                    = consructCliqueGraph(clique{kk});
                %
                % We assume that the clique graph is connected
                %
                randSeed = 2009;
                [treeValue,adjacencyMatrixT,edgeCostVectT,incidenceMatrixT] ...
                    = maxSpanningTree(clique{kk},adjacencyMatrixC,edgeCostVectC,incidenceMatrixC,randSeed);
                kDim = size(incidenceMatrixT,2);
                %
                %
                %
                for i=1:clique{kk}.NoC-1
                    edgeSet = find(incidenceMatrixT(i,:) ~= 0);
                    if ~isempty(edgeSet)
                        j = edgeSet(1);
                        I = find(incidenceMatrixT(:,j)' ~= 0);
                        i2 = I(2);
                        U = intersect(clique{kk}.Set{i},clique{kk}.Set{i2});
                        S = setdiff(clique{kk}.Set{i},U);
                        T = setdiff(clique{kk}.Set{i2},U);
                        nDim = length(U);
                        % epsilon = 1.0e-10;
                        LMat = chol(XMat(U,U)+epsilon*speye(nDim,nDim));
                        XMat(S,T) = (XMat(S,U)/LMat)*(LMat'\XMat(U,T));
                        XMat(T,S) = XMat(S,T)';
                        clique{kk}.Set{i2} = union(clique{kk}.Set{i},clique{kk}.Set{i2});
                        incidenceMatrixT(i2,:) = incidenceMatrixT(i2,:) + incidenceMatrixT(i,:);
                        incidenceMatrixT(i,:) = sparse(1,kDim);
                    end
                end
            else
%                2
                fPointer = 0;
                for ii=1:length(clique{kk}.NoCliqueInForest)
                    if clique{kk}.NoCliqueInForest(ii) > 1
                        tempClique.NoC = 0;
                        tempClique.NoElem = [];
                        tempClique.maxC = 0;
                        tempClique.minC = 1.0e10;
                        setIdx = 0;
                        for j=fPointer+1:fPointer+clique{kk}.NoCliqueInForest(ii)
                            tempClique.NoC = tempClique.NoC + 1;
                            tempClique.NoElem = [tempClique.NoElem,length(clique{kk}.Set{j})];
                            setIdx = setIdx + 1;
                            tempClique.Set{setIdx} = clique{kk}.Set{j};
                        end
                        tempClique.maxC = max(tempClique.NoElem);
                        tempClique.minC = min(tempClique.NoElem);
                        [adjacencyMatrixC,noOfEdges,edgeCostVectC,incidenceMatrixC] ...
                            = consructCliqueGraph(tempClique);
                        randSeed = 2009;
                        [treeValue,adjacencyMatrixT,edgeCostVectT,incidenceMatrixT] ...
                            = maxSpanningTree(tempClique,adjacencyMatrixC,edgeCostVectC,incidenceMatrixC,randSeed);
                        kDim = size(incidenceMatrixT,2);
                        for i=1:tempClique.NoC-1
                            edgeSet = find(incidenceMatrixT(i,:) ~= 0);
                            if ~isempty(edgeSet)
                                j = edgeSet(1);
                                I = find(incidenceMatrixT(:,j)' ~= 0);
                                i2 = I(2);
                                U = intersect(tempClique.Set{i},tempClique.Set{i2});
                                S = setdiff(tempClique.Set{i},U);
                                T = setdiff(tempClique.Set{i2},U);
                                nDim = length(U);
                                LMat = chol(XMat(U,U)+epsilon*speye(nDim,nDim));
                                XMat(S,T) = (XMat(S,U)/LMat)*(LMat'\XMat(U,T));
                                XMat(T,S) = XMat(S,T)';
                                tempClique.Set{i2} = union(tempClique.Set{i},tempClique.Set{i2});
                                incidenceMatrixT(i2,:) = incidenceMatrixT(i2,:) + incidenceMatrixT(i,:);
                                incidenceMatrixT(i,:) = sparse(1,kDim);
                            end
                        end
                        clear tempClique
                    end
                    fPointer = fPointer + clique{kk}.NoCliqueInForest(ii);                    
                end
                
            end
            debugSW = 1;
            if debugSW == 1
                d = eig(XMat);
                fprintf('the minimum eigenvalue of a completed SDP variable matrix = %+6.1e\n',full(min(d')));
            end
            xVect = [xVect; reshape(XMat,sDim*sDim,1)];
        else
            xVect = [xVect; uVect(rowPointer+1:rowPointer+sDim*sDim,1)];
        end
        rowPointer = rowPointer + sDim*sDim;
    end
end
return
