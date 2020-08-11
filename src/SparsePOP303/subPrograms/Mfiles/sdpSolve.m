function [x, y, SDPobjValue, SDPsolverInfo] = sdpSolve(fileId, A, b, c, K, param, startingTime1)

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is a component of SparsePOP
% Copyright (C) 2007 SparsePOP Project
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

%%%%%%%%%%
% 2018/06/05 Kojima

%%%%% April 3, 2009 --->
% param.SDPsolver is only for the developers' use but not for general
% users

if fileId > 0
	printLevel = 0;
	writeSeDuMiInputData(fileId,printLevel,A,b,c,K);
end

versionSW = 210;
startingTime2 = toc(startingTime1);
if versionSW < 210
    [x,y,SDPsolverInfo] = solveBySeDuMi(A,b,c,K,param);
elseif versionSW == 210
    if ~isfield(param,'SDPsolver') || strcmp(param.SDPsolver,'sedumi') ...
            || isempty(param.SDPsolver)
        [x, y, SDPobjValue, SDPsolverInfo] = solveBySeDuMi(A, b, c, K, param);
    elseif strcmp(param.SDPsolver,'sdpa')
        [x, y, SDPobjValue, SDPsolverInfo] = solveBySDPA(A, b, c, K, param);
    elseif strcmp(param.SDPsolver,'sdpt3')
        [x,y, SDPobjValue, SDPsolverInfo] = solveBySDPT3(A, b, c, K, param);
    elseif strcmp(param.SDPsolver, 'sdpnal')
        [x,y, SDPobjValue, SDPsolverInfo] = solveBySDPNAL(A, b, c, K, param);
    elseif strcmp(param.SDPsolver, 'sdpnalplus')
        % [x,y, SDPobjValue, SDPsolverInfo] = solveBySDPNALplus(fileId, A, b, c, K, param);
        [x,y,s,SDPobjValue,SDPsolverInfo] = solveBySDPNALplus(A, b, c, K, param); 
    elseif strcmp(param.SDPsolver, 'csdp')
        [x,y, SDPobjValue, SDPsolverInfo] = solveByCSDP(A, b, c, K, param);
    else
        error('## ''param.SDPsolver'' is invalid.');
    end
end

SDPobjValue = - SDPobjValue;

SDPsolverInfo.cpusec = toc(startingTime1) - startingTime2;

return
