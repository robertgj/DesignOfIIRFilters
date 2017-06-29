function [AConvert,CConvert,KConvert,cliqueConvert,NoForest,retrieveInfo] = ...
        forestConvert(Apart,Cpart,sDim,oneClique)
% 
% Modified by M. Kojima, March 25, 2010         
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
    
    if issparse(Apart) ~=1
        Apart = sparse(Apart);
    end
    if issparse(Cpart) ~=1
        Cpart = sparse(Cpart);
    end
    % fprintf('mexForestConvert Start\n');
    [AtConvert,CtConvert,KConvert,cliqueConvert,NoForest,retrieveInfo] = ...
        mexForestConvert(Apart',Cpart',sDim,oneClique);
    % fprintf('mexForestConvert End\n');
    AConvert = AtConvert';
    CConvert = CtConvert';
    
    if 0 && NoForest == 1 
        Adiff = AConvert - Apart;
        Cdiff = CConvert - Cpart;
        if isempty(Adiff) == 0
            resA = 0
        else
            resA = sum(sum(abs(Adiff),1))
        end
        if isempty(Cdiff) == 0
            resC = 0
        else
            resC = sum(sum(abs(Cdiff),1))
        end
    end

    for kk=1:NoForest
        clique = cliqueConvert{kk};
        nDim = sDim;
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % In 'clique', mex function sets only
        %   'NoC', 'Elem', 'NoElem'.
        % For 'maxC', 'minC', 'idxMatrix', 'Set'
        % copy programs from cliquesFromSpMatD.m
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        clique.maxC = full(max(clique.NoElem));
        clique.minC = full(min(clique.NoElem));

% Modified by M. Kojima, March 25, 2010 --->         
%         modifySW = 1;
%         if modifySW == 0;
%             Cliques = sparse(nDim,nDim);
%             idx = 0;
%             for i=1:clique.NoC
%                 s = clique.NoElem(i);
%                 tmp = clique.Elem(idx+(1:s));
%                 idx = idx + s;
%                 Cliques(tmp,tmp) = 1;
%             end
%             debugSW = 1;
%             if debugSW == 1
%                 figure(10);
%                 spy(Cliques);
%             end
%         else
            Cliques = [];
            idx = 0;
            for i=1:clique.NoC
                s = clique.NoElem(i);
                tmp = clique.Elem(idx+(1:s));
                Cliques = [Cliques, sparse(tmp,1,1,nDim,1)];
                idx = idx + s;
            end
            Cliques = Cliques * Cliques';
%             debugSW = 0;
%             if debugSW == 1
%                 figure(20);
%                 spy(Cliques);
%             end
%        end
% <--- Modified by M. Kojima, March 25, 2010     
        
        Cliques = tril(Cliques);
        [I,J,V] = find(Cliques);
        s = length(V);
        clique.idxMatrix = sparse(J,I,(1:s),nDim,nDim,s);
        clique.Set{1} = clique.Elem(1:clique.NoElem(1));
        % clique.Set{1}
        for p=2:clique.NoC
            idx = sum(clique.NoElem(1:p-1));
            clique.Set{p} = clique.Elem(idx+(1:clique.NoElem(p)));
        %     clique.Set{p}
        end 
        cliqueConvert{kk} = clique;
    end
    