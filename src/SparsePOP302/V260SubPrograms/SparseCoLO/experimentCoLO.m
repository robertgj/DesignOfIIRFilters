function experimentCoLO(A,b,c,K,J,parCoLO,parameterSet);
% ======================================================================
% Input 
% ======================================================================
%   LOP (Conic form Linear Optimization Problem)
%       minimize   c^T x 
%       subject to A x - b \in J,  x \in K
%   Here 
%       x : a column vector variable. 
%       K.f --- the number of free variables, e.g., K.f = [], 0 or 10
%       K.l --- the number of LP variables,e.g., K.l = [], 0 or 12 
%       K.q --- the structure of SOCP variables, e.g., K.q = [], 3 or [3,5] 
%       K.s --- the structure of SDP variables, e.g., K.s = [], 4 or [2,4]
%       J.f --- the number of equality constraints, e.g., J.f = [], 0 or 6
%       J.l --- the number of LP inequality constraints, e.g., J.l = [], 0 or 7
%       J.q --- the structure of SOCP constraints, e.g., J.q = [], 8 or [2,3] 
%       J.s --- the structure of SDP constraints, e.g., J.s = [], 2 or [3,6]
% 
%   parCoLO.SDPsolver 
%       = [] --- do not apply any method
%       = 'sdpa'   --- sdpa
%       = 'sedumi' --- sedumi
%       = 'sdpt3'  --- sdpt3
%       = ....
%
%   parCoLO.OPTIONsdpa   --- OPTION parameters for sdpa
%   parCoLO.parSeDuMi    --- parameters for sedumi
%   parCoLO.OPTIONSsdpt3 --- OPTION parameters for sdpt3
%
%   parameterSet = [parCoLO.domain,parCoLO.range,parCoLO.EQorLMI;... 
%                   parCoLO.domain,parCoLO.range,parCoLO.EQorLMI;...
%                   ...
%                   ]; 
%
% ======================================================================

% <Sample excecution>
% >> [A,b,c,K,J] = maxCutSDP(1,50,4,2009);
% >> parCoLO.SDPsolver = 'sdpa';
% >> parameterSet = [0,0,1; 1,0,1; 2,0,2];
% >> experimentCoLO(A,b,c,K,J,parCoLO,parameterSet);
% 
% SparseCoLO 1.10
% by K.Fujisawa, S.Kim, M.Kojima, Y.Okamoto and M. Yamashita,
% September 2009
% 
% parCoLO.domain = 0; parCoLO.range = 0; parCoLO.EQorLMI = 1
% LOP to be converted into equality standard form is already equality standard form.
% -SeDuMi Wrapper for SDPA Start-
% Converted to SDPA internal data / Starting SDPA main loop
% Converting optimal solution to Sedumi format
% -SeDuMi Wrapper for SDPA End-
% primalObjValue    = -3.19014001e+01, dualObjValue = -3.19014021e+01, gap = +1.99e-06
% primalfeasibility = +4.88e-15
% dualfeasibility   = +0.00e+00
% 
% 
% SparseCoLO 1.10
% by K.Fujisawa, S.Kim, M.Kojima, Y.Okamoto and M. Yamashita,
% September 2009
% 
% parCoLO.domain = 1; parCoLO.range = 0; parCoLO.EQorLMI = 1
% Apply the d-space conversion method using clique trees.
% LOP to be converted into equality standard form is already equality standard form.
% -SeDuMi Wrapper for SDPA Start-
% Converted to SDPA internal data / Starting SDPA main loop
% Converting optimal solution to Sedumi format
% -SeDuMi Wrapper for SDPA End-
% primalObjValue    = -3.19014014e+01, dualObjValue = -3.19014021e+01, gap = +6.58e-07
% primalfeasibility = +3.33e-13
% dualfeasibility   = +0.00e+00
% 
% 
% SparseCoLO 1.10
% by K.Fujisawa, S.Kim, M.Kojima, Y.Okamoto and M. Yamashita,
% September 2009
% 
% parCoLO.domain = 2; parCoLO.range = 0; parCoLO.EQorLMI = 2
% Apply the d-space conversion method using basis representation.
% LOP to be converted into LMI standard form is already LMI standard form.
% -SeDuMi Wrapper for SDPA Start-
% Converted to SDPA internal data / Starting SDPA main loop
% Converting optimal solution to Sedumi format
% -SeDuMi Wrapper for SDPA End-
% primalObjValue    = -3.19014023e+01, dualObjValue = -3.19014054e+01, gap = +3.12e-06
% primalfeasibility = +2.05e-07
% dualfeasibility   = +0.00e+00
% 
% 
% by SDPAM
% %slover    parCoLO  |     cpu time |          matrix A          |  Schur complement|   SDP blocks|
% %         d  r EQ/LMI  cpuC     cpuS          sizeA          nnzA      nnzS     nnzL   noBl  maxBl
% sdpa   & 0   0   1 &    0.0 &    0.2  &     50 x   2500 &      50 &    2500 &   1275 &    1 &   50\\
% sdpa   & 1   0   1 &    0.1 &    0.1  &     87 x   1121 &     172 &    3821 &   1954 &    4 &   20\\
% sdpa   & 2   0   2 &    0.0 &    0.1  &    264 x   1190 &    1190 &    8916 &   4626 &   36 &    8\\
% % max primal objective value over the  3 cases = -3.190140005793232e+01
% % min primal objective value over the  3 cases = -3.190140226049969e+01
% % max primal obj. value- min primal obj. value = +2.20e-06
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

percent = char(37);
backS = char(92); % char(165);
aand = char(38);
perc = char(37);
lbrace = char(123);
rbrace = char(125);
lbracket = char(91);
rbracket = char(93);
pipe = char(124);

if (nargin <= 4)
    J.f = size(A,1);
    parCoLO.SDPsolver = 'sedumi';
    [parameterSet] = defaultParCoLO(A,b,c,K,J); 
elseif (nargin <= 5)
    if isempty(J) 
        J.f = size(A,1);
    end
    parCoLO.SDPsolver = 'sedumi';
    [parameterSet] = defaultParCoLO(A,b,c,K,J); 
elseif (nargin <= 6) || isempty(parameterSet) 
    if isempty(J) 
        J.f = size(A,1);
    end
    [parameterSet] = defaultParCoLO(A,b,c,K,J); 
end

if isempty(parCoLO) || ~isfield(parCoLO,'SDPsolver')
    parCoLO.SDPsolver = 'sedumi';
end

if ~isfield(parCoLO,'parSeDuMi')
    parCoLO.parSeDuMi.free = 1;
    parCoLO.parSeDuMi.eps = 1.0e-9;
    parCoLO.parSeDuMi.fid = 0;
end

if  ~isfield(parCoLO,'OPTIONsdpa')
    parCoLO.OPTIONsdpa.epsilonStar  = 1.0E-7;
    parCoLO.OPTIONsdpa.epsilonDash  = 1.0E-7;
    parCoLO.OPTIONsdpa.print  = '';
end

if  ~isfield(parCoLO,'OPTIONSsdpt3')
    parCoLO.OPTIONSsdpt3.printlevel = 0;
end
    
SW = [];
conversionTime = [];
sdpCpuTime = [];
primalObjectiveValues = [];
pdGap = [];
pfeasibility = [];
dfeasibility = [];
matAinfo = [];
SDPinfo = [];
coSpMatinfo = [];

kk = size(parameterSet,1);
for k = 1:kk
    parCoLO.domain = parameterSet(k,1);
    parCoLO.range = parameterSet(k,2);
    parCoLO.EQorLMI = parameterSet(k,3);
    %    fprintf('Start Experiment: domain =%2d, range =%2d, EQorLMI =%2d\n',...
    %            parCoLO.domain,parCoLO.range,parCoLO.EQorLMI);
    [x,y,infoCoLO,cliqueDomain,cliqueRange,LOP] = sparseCoLO(A,b,c,K,J,parCoLO);
    convTime = infoCoLO.CPUdomain + infoCoLO.CPUrange + infoCoLO.CPUEQorLMI;
    %
    [primalObjValue, dualObjValue, primalfeasibility, dualfeasibility] = evaluateCoLO(x,y,A,b,c,K,J,cliqueDomain,cliqueRange);
    SW = [SW; [parCoLO.domain, parCoLO.range, parCoLO.EQorLMI]];
    conversionTime = [conversionTime, convTime];
    sdpCpuTime = [sdpCpuTime, infoCoLO.CPUsolver];
    primalObjectiveValues = [primalObjectiveValues, primalObjValue];
    pfeasibility = [pfeasibility, primalfeasibility];
    dfeasibility = [dfeasibility, dualfeasibility];
    %
    if isfield(LOP.J,'f') && LOP.J.f == size(LOP.A,1)
        pdGap = [pdGap, abs(primalObjValue-dualObjValue)];
        [matrixA,SDPcone,coSpMat] = checkSparsityEQform(LOP.A,LOP.b,LOP.c,LOP.K);
    elseif isfield(LOP.K,'f') && LOP.K.f == size(LOP.A,2)
        pdGap = [pdGap, abs(dualObjValue-primalObjValue)];
        [matrixA,SDPcone,coSpMat] = checkSparsityEQform(-LOP.A',-LOP.c,-LOP.b,LOP.J);
    end
    %
    matAinfo = [matAinfo; [matrixA.size(1),matrixA.size(2) ,matrixA.nnz, matrixA.constSComp]];
    %
    SDPinfo = [SDPinfo; [SDPcone.noOfCones, SDPcone.sizeMax, SDPcone.sizeMin, SDPcone.sizeAve, SDPcone.volSDP]];
    %
    coSpMatinfo = [coSpMatinfo; [coSpMat.size, coSpMat.lbdNnz, coSpMat.nnz, coSpMat.nnzLMat]];
    fprintf('\n');
end

fprintf('\n');
%         if ~isempty(fileName)
%             fprintf('%s %s ',percent,fileName);
%             if ~isempty(outFileID)
%                 fprintf(outFileID,'%s %s ',percent,fileName);
%             end
%         end
if strcmp(parCoLO.SDPsolver,'sedumi')
    fprintf('%s by SeDuMi\n',percent);
    %             if ~isempty(outFileID)
    %                 fprintf(outFileID,'by SeDuMi\n');
    %             end
elseif strcmp(parCoLO.SDPsolver,'sdpa')
    fprintf('%s by SDPAM\n',percent);
    %             if ~isempty(outFileID)
    %                 fprintf(outFileID,'by SDPAM\n');
    %             end
elseif strcmp(parCoLO.SDPsolver,'sdpt3')
    fprintf('%s by SDPT3\n',percent);
    %             if ~isempty(outFileID)
    %                 fprintf(outFileID,'by SDPT3\n');
    %             end
end
fprintf('%sslover    parCoLO  |%scpu time |%s   matrix A          |%s Schur complement|   SDP blocks|\n',...
    percent,blanks(5),blanks(7),blanks(1));
fprintf('%s         d  r EQ/LMI  cpuC     cpuS          sizeA          nnzA      nnzS     nnzL   noBl  maxBl\n',...
    percent);
%
%         if ~isempty(outFileID)
%             fprintf(outFileID,'%sslover    parCoLO  |%scpu time |%s   matrix A          |%s Schur complement|   SDP blocks|\n',...
%                 percent,blanks(6),blanks(7),blanks(1));
%             fprintf(outFileID,'%s        d  r EQ/LMI  cpuC     cpuS          sizeA          nnzA      nnzS     nnzL   noBl  maxBl\n',...
%                 percent);
%         end
for i=1:length(sdpCpuTime)
    if strcmp(parCoLO.SDPsolver,'sedumi')
        fprintf('sedumi %s ',aand);
    elseif strcmp(parCoLO.SDPsolver,'sdpa')
        fprintf('sdpa   %s ',aand);
    elseif strcmp(parCoLO.SDPsolver,'sdpt3')
        fprintf('sdpt3  %s ',aand);
    end
    fprintf('%1d   %1d   %1d %s %6.1f %s %6.1f  %s %6d x%7d %s %7d %s %7d %s %6d %s %4d %s %4d%s%s\n',...
        SW(i,1),SW(i,2),SW(i,3),aand,conversionTime(i),aand,sdpCpuTime(i),...
        aand,matAinfo(i,1),matAinfo(i,2),aand,matAinfo(i,3),aand,coSpMatinfo(i,3),...
        aand,coSpMatinfo(i,4),aand,SDPinfo(i,1),aand,SDPinfo(i,2),backS,backS);
    %
    %             if ~isempty(outFileID)
    %                 if strcmp(parCoLO.SDPsolver,'sedumi')
    %                     fprintf(outFileID,'sedumi %s',aand);
    %                 elseif strcmp(parCoLO.SDPsolver,'sdpa')
    %                     fprintf(outFileID,'sdpa   %s',aand);
    %                 elseif strcmp(parCoLO.SDPsolver,'sdpt3')
    %                     fprintf(outFileID,'sdpt3  %s',aand);
    %                 end
    %                 fprintf(outFileID,'%1d   %1d   %1d %s %6.1f %s %6.1f  %s %6d x%7d %s %7d %s %7d %s %6d %s %4d %s %4d%s%s\n',...
    %                     SW(i,1),SW(i,2),SW(i,3),aand,conversionTime(i),aand,sdpCpuTime(i),...
    %                     aand,matAinfo(i,1),matAinfo(i,2),aand,matAinfo(i,3),aand,coSpMatinfo(i,3),...
    %                     aand,coSpMatinfo(i,4),aand,SDPinfo(i,1),aand,SDPinfo(i,2),backS,backS);
    %             end
end
if length(sdpCpuTime) > 1
    fprintf('%s max primal objective value over the %2d cases = %+20.15e\n',percent,length(sdpCpuTime),max(primalObjectiveValues));
    fprintf('%s min primal objective value over the %2d cases = %+20.15e\n',percent,length(sdpCpuTime),min(primalObjectiveValues));
    fprintf('%s max primal obj. value- min primal obj. value = %+7.2e\n',percent,max(primalObjectiveValues)-min(primalObjectiveValues));
    %
    %             if ~isempty(outFileID)
    %                 fprintf(outFileID,'%s max primal objective value over the %2d cases = %+20.15e\n',percent,length(sdpCpuTime),max(primalObjectiveValues));
    %                 fprintf(outFileID,'%s min primal objective value over the %2d cases = %+20.15e\n',percent,length(sdpCpuTime),min(primalObjectiveValues));
    %                 fprintf(outFileID,'%s max primal obj. value- min primal obj. value = %+7.2e\n',percent,max(primalObjectiveValues)-min(primalObjectiveValues));
    %             end
end
fprintf('\n');
%         if ~isempty(outFileID)
%             fprintf(outFileID,'%s\n',percent);
%         end

% d = parCoLO.domain
% r = parCoLO.range
% EQ/LMI = parCoLO.EQorLMI
% cpuC = the cpu time in second for conversion
% cpuS = the cpu time in second for SeDuMi
% sizeA = the size of A
% nnzA = the number of nonzeros in A
% nnzS = the number of nonzeros in the Schur complement matrix
% nnzL = the number of nonzeros in the sparse Cholesky factor of the
%        Schur complement matrix
% noBl = the number of SDP blocks
% maxBl = the maximum size of SDP block

return
    