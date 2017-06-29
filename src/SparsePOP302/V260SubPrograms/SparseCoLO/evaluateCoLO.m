function [primalObjValue, dualObjValue, primalfeasibility, dualfeasibility] = ...
    evaluateCoLO(x,y,A,b,c,K,J,cliqueDomain,cliqueRange); 
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

    if size(c,1) < size(c,2)
        c = c';
    end
    if size(b,1) < size(b,2)
        b = b';
    end
    primalObjValue = full(c'*x);
    dualObjValue = full(b'*y);

    primalfeasibility = 0.0;
    primalResidual = (A*x - b)';
    % isDomain = 0; 
    primalfeasibility = primalfeasibility + ...
        computeOneCone(primalResidual,J,0,cliqueRange);
    % isDomain = 1; 
    primalfeasibility = primalfeasibility + ...
        computeOneCone(x,K,1,cliqueDomain);

    dualfeasibility = 0.0;
    dualResidual = (c-A'*y)';
%     dualfeasibility = dualfeasibility + ...
%         computeOneCone(dualResidual,K,1,cliqueDomain);
%     dualfeasibility = dualfeasibility + ...
%         computeOneCone(y,J,0,cliqueRange);
    % isDomain = 0; 
    dualfeasibility = dualfeasibility + ...
        computeOneCone(dualResidual,K,0,cliqueDomain);
    % isDomain = 1; 
    dualfeasibility = dualfeasibility + ...
        computeOneCone(y,J,1,cliqueRange);
    
    debugSW = 1;
    if debugSW == 1
        fprintf('primalObjValue    = %+15.8e, dualObjValue = %+15.8e, gap = %+7.2e\n',...
                primalObjValue,dualObjValue,primalObjValue-dualObjValue);
        fprintf('primalfeasibility = %+7.2e\n',primalfeasibility);
        fprintf('dualfeasibility   = %+7.2e\n',dualfeasibility);
    end

    return

end

function feasibility = computeOneCone(residual,K,isDomain,clique)
    rowPointer = 0;   
    feasibility = 0;
    if isfield(K,'f') && ~isempty(K.f) && K.f > 0
%         if isDomain == 1
%             feasibility = feasibility + ...
%                 norm(residual(rowPointer+1:rowPointer+K.f),inf);
%         end
        if isDomain == 0
            feasibility = feasibility + ...
                norm(residual(rowPointer+1:rowPointer+K.f),inf);
        end
        rowPointer = rowPointer + K.f; 
    end % end of K.f
    if isfield(K,'l') && ~isempty(K.l) && K.l > 0
        feasibility = feasibility + max([0, - min(residual(rowPointer+1:rowPointer+K.l))]);
        rowPointer = rowPointer + K.l;
    end % end of K.l
    if isfield(K,'q') && ~isempty(K.q)
        for i=1:length(K.q)
            feasibility = feasibility + max([0, -(residual(rowPointer+1) + norm(residual(rowPointer+2:rowPointer+K.q(i))))]);
            rowPointer = rowPointer + K.q(i);
        end
    end % end of K.q
    if isfield(K,'s') && ~isempty(K.s)
        for i=1:length(K.s)
            oneMat = reshape(residual(rowPointer+1:rowPointer+K.s(i)*K.s(i)),K.s(i),K.s(i)); 
            oneMat = (oneMat + oneMat')/2; 
            if isempty(clique) || clique{i}.NoC == 1
                %            clique{i}
                d = eig(oneMat); 
                feasibility = feasibility + max([0, -min(d)]);
            else
                for j=1:clique{i}.NoC
                    idx = clique{i}.Set{j}; 
                    d = eig(oneMat(idx,idx)); 
                    feasibility = feasibility + max([0, -min(d)]);
                end            
            end
            rowPointer = rowPointer + K.s(i)*K.s(i);
        end
    end % end of K.s
end

