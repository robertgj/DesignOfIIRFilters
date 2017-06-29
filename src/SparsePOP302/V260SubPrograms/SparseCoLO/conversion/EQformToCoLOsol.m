function [xVect,yVect] = EQformToCoLOsol(x,y,CoLOno,seqLOPs);

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

rowPointer = 0; 
% primal free variables
if isfield(seqLOPs{CoLOno-1}.K,'f') && ~isempty(seqLOPs{CoLOno-1}.K.f) && (seqLOPs{CoLOno-1}.K.f > 0)
    xVect = x(rowPointer+1:rowPointer+seqLOPs{CoLOno-1}.K.f,:);    
else
    xVect = [];
end
if isfield(seqLOPs{CoLOno}.K,'f') && ~isempty(seqLOPs{CoLOno}.K.f) && (seqLOPs{CoLOno}.K.f > 0)
    rowPointer = rowPointer+seqLOPs{CoLOno}.K.f; 
end
% primal LP variables
if isfield(seqLOPs{CoLOno-1}.K,'l') && ~isempty(seqLOPs{CoLOno-1}.K.l) && (seqLOPs{CoLOno-1}.K.l > 0)
    xVect = [xVect; x(rowPointer+1:rowPointer+seqLOPs{CoLOno-1}.K.l,:)];
end
if isfield(seqLOPs{CoLOno}.K,'l') && ~isempty(seqLOPs{CoLOno}.K.l) && (seqLOPs{CoLOno}.K.l > 0)
    rowPointer = rowPointer+seqLOPs{CoLOno}.K.l; 
end
% primal SOCP variables
if isfield(seqLOPs{CoLOno-1}.K,'q') && ~isempty(seqLOPs{CoLOno-1}.K.q)
    qDim = sum(seqLOPs{CoLOno-1}.K.q); 
    xVect = [xVect; x(rowPointer+1:rowPointer+qDim,:)];
end
if isfield(seqLOPs{CoLOno}.K,'q') && ~isempty(seqLOPs{CoLOno}.K.q)
    rowPointer = rowPointer+sum(seqLOPs{CoLOno}.K.q);
end
% primal SDP variables
if isfield(seqLOPs{CoLOno-1}.K,'s') && ~isempty(seqLOPs{CoLOno-1}.K.s)
    SDPdim = sum(seqLOPs{CoLOno-1}.K.s .* seqLOPs{CoLOno-1}.K.s);
    xVect = [xVect; x(rowPointer+1:rowPointer+SDPdim,:)];
end

rowPointer = 0; 

if isfield(seqLOPs{CoLOno-1}.J,'f') && ~isempty(seqLOPs{CoLOno-1}.J.f)  && (seqLOPs{CoLOno-1}.J.f > 0)
    yVect = y(rowPointer+1:rowPointer+seqLOPs{CoLOno-1}.J.f,:);
    rowPointer = rowPointer+seqLOPs{CoLOno-1}.J.f; 
else
    yVect = [];
end
% dual LP variables
if isfield(seqLOPs{CoLOno-1}.J,'l') && ~isempty(seqLOPs{CoLOno-1}.J.l) && (seqLOPs{CoLOno-1}.J.l > 0)
    yVect = [yVect; y(rowPointer+1:rowPointer+seqLOPs{CoLOno-1}.J.l,:)];
    rowPointer = rowPointer+seqLOPs{CoLOno-1}.J.l; 
end
% dual SOCP variables
if isfield(seqLOPs{CoLOno-1}.J,'q') && ~isempty(seqLOPs{CoLOno-1}.J.q)
    qDim = sum(seqLOPs{CoLOno-1}.J.q); 
    yVect = [yVect; y(rowPointer+1:rowPointer+qDim,:)];
end
% dualSDP variables
if isfield(seqLOPs{CoLOno-1}.J,'s') && ~isempty(seqLOPs{CoLOno-1}.J.s)    
    uVect = seqLOPs{CoLOno}.convMat*y;
    yVect = [yVect;uVect];
end

return




    