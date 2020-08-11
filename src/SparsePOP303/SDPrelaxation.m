function [param,SDPobjValue,POP,elapsedTime,SDPsolverInfo,SDPinfo] = ...
    SDPrelaxation(param,objPoly,ineqPolySys,lbd,ubd)
%
% SDPrelaxation
% solves a polinomial optimization problem described in SparsePOP format.
%
% Usage:
% [param,SDPobjValue,POP,elapsedTime,SDPsolverInfo,SDPinfo] = ...
%		SDPrelaxation(param,objPoly,ineqPolySys,lbd,ubd);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% objPoly, inEqPolySys, lbd, ubd form the SparsePOP format.
% param is a set of parameters. See below for the details.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% param: parameters actually used.
% SDPobjValue: the optimal value of SDP
% POP:
%   POP.xVect: an approximate solution for POP
%   POP.objValue: the objective value of xVect
%   POP.absError: an absolute error
%   POP.scaledError: an scaled error
% elapsedTime:
%   elapsedTime.conversion: cpu time consumed to convert POP to SDP relax.
%   elapsedTime.SDPsolver: cpu time consumed by SeDuMi.
%   elapsedTime.Total: total cpu time.
% SDPsolverInfo:
%   SDPsolverInfo.numerr: info.numerr of SeDuMi
%   SDPsolverInfo.pinf: info.pinf of SeDuMi
%   SDPsolverInfo.dinf: info.dinf of SeDuMi
% SDPinfo:
%   SDPinfo.rowSizeA: the number of rows of A.
%   SDPinfo.colSizeA: the number of columns of A.
%   SDPinfo.nonzeroInA: the number of nonzero elements in A.
%   SDPinfo.noOfLPvariables: the number of LP variables in SDP.
%   SDPinfo.noOfFRvariables: the number of Free variables in SDP.
%   SDPinfo.SDPblock: the row vector of sizes of SDP blocks.
%   SDPinfo.dimVar0: the number of varialbes in the original POP. 
%   SDPinfo.dimVar: the number of varialbes in the POP obtaind 
%                   from the original POP. 
%   SDPinfo.x: the primal (SOS) solution of the SDP relaxation 
%              problem obtained by SDP solver.
%   SDPinfo.y: the dual (LMI) solution of the SDP relaxation 
%              problem obtained by SDP solver.
%   SDPinfo.SeDuMiA: the coefficient matrix A in the SDP with the SeDuMi format
%   SDPinfo.SeDuMib: the coefficient vector b in the SDP with the SeDuMi format
%   SDPinfo.SeDuMic: the objective vector c in the SDP with the SeDuMi format
%   SDPinfo.SeDuMiK: the cone K in the SDP with the SeDuMi format
%   SDPinfo.objConstant: trans.objVonstant
%   SDPinfo.objValScale: trans.objValScale
%   SDPinfo.Amat: trans.Amat
%   SDPinfo.bVect: trans.bVect
%   SDPinfo.xIdxVec: all monomials in the obtained PSDP except for x^0
%   SDPinfo.fixedVar: fixedVar
%
% See UserGuide.pdf and/or the following reference:
%
% H. Waki, S. Kim, M. Kojima and M. Muramatsu,
% "Sums of Squares and Semidefinite Programming Relaxations
% for  Polynomial Optimization Problems with Structured Sparsity",
% SIAM Journal on Optimization Vol.17 (1) 218-242 (2006).
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

%$%$ Modified by Kojima 2007/08/05 --->
%
%   Added param.reduceEqualitiesSW as an input;
%               if reduceEqualitiesSW = 1 or 2 then the modified parts necessary for
%               exploiting equalities are carried out. 
%   If reduceEqualitiesSW = 1 then: 
%       (a) Exploiting equalities in POPs based on the Cong-Muramatsu-Kojima
%           paper, but their method is considerably simplified, so that
%           the implementation here is quite simple. 
%   If reduceEqualitesSW = 2 then:
%       (a) above.
%       (b) Exploiting equalities in SDPs based on the
%           Kobayashi-Nakata-Kojma paper. Their method is improved, but 
%           further investigation is necessary for handing the sparsity. 
%       (c) Removing redundant free variables. This is necessary for (b). 
%       (d) Removing redundant LP variables. The method (a) seems to create
%           lots of redundant LP variables, which could be eliminated for 
%           the computational efficiency. 
%   The current imlementation has not been fullly utilized the above
%   method.
%       (e) Restricted to param.multiCliquesFactor = 0. See the last part
%           of default3Parameter.m
%       (f) In (b) and (c), the sparsity has not been exploited fully. 
%       (g) SDPrelaxationMEX version needs to be developed. 
%
%$%$ <--- Kojima 2007/08/05
%
% SDPrelaxation
% solves a polinomial optimization problem described in SparsePOP format.
%


startingTime1 = tic;

%% Outputs
elapsedTime.SDPsolver = 0.0;
[SDPinfo, SDPsolverInfo, POP, SDPobjValue] = initializeOutput(param);

% saving the original POP information
[objPoly0,ineqPolySys0,lbd0,ubd0] = saveOriginalPOP(objPoly,...
    ineqPolySys,lbd,ubd);

% Kojima 06/11/2007 --->
%
% param.reduceAMatSW = 1 ---> Reducing the coeeficient matrix A of SeDuMi;
%                    = 0 ---> Not reducing the coeeficient matrix A of SeDuMi;
%
infeasibleSW = 0;
% infeasibleSW = 2 ---> POP is found infeasible in nDimZero2 before applying SeDuMi;
% infeasibleSW = 1 ---> Primal SDP is found infeasible in solveSquareSDP before applying SeDuMi;
% infeasibleSW = 0.5 ---> SDP solver detects the infeasibility of the sparse SDP relaxation or its dual;
% infeasibleSW = 0 ---> apply the sparse SDP relaxation;
% infeasibleSW = -1 ---> SDP is solved by solveSquareSDP and has a unique
%                        feasible solution; SeDuMi is not applied;
% infeasibleSW = -2 ---> POP is found to have a unique feasible solution nDimZero2;
%
% SDPinfo.infeasibleSW = infeasibleSW, later;
%
% SDPinfo.reduceAMatSW = 2; all the variables of POP are fixed in deleteVar;
% SDPinfo.reduceAMatSW = 1; some equality constraints of the SeDuMi format primal SDP are linearly dependent;
% SDPinfo.reduceAMatSW = 0; no variable of POP is fixed;
%
% Removing redundant variables
deleteVarSW = 1;
if (param.reduceAMatSW == 1) && (deleteVarSW == 1)
    [objPoly,ineqPolySys,lbd,ubd,fixedVar] = deleteVar(objPoly,ineqPolySys,...
        lbd,ubd,param);
else
    fixedVar = [];
end

% If all variables vanish from the original POP by "deleteVar.m",
% SDP relaxations are not applied into the POP.
if objPoly.dimVar == 0
	SDPinfo.reduceAMatSW = 2;
	% SDPinfo.reduceAMatSW = 2 ---> all the variables of POP are fixed in
	% deleteVar;
	fprintf('## All variables of POP are fixed.\n');
	[POP, SDPobjValue,elapsedTime,SDPsolverInfo,infeasibleSW] = nDimZero2(objPoly,objPoly0,...
		ineqPolySys0,lbd0,ubd0,POP,SDPobjValue,elapsedTime,startingTime1,...
		SDPsolverInfo, fixedVar);
	SDPinfo.infeasibleSW = infeasibleSW;
	% SDPinfo.infeasibleSW = 2  ---> POP is found infeasible in nDimZero2
	%                                before applying SeDuMi;
	% SDPinfo.infeasibleSW = -2 ---> POP is found to have a unique feasible
	%                                solution in nDimZero2;
	elapsedTime.conversion = toc(startingTime1);
	elapsedTime.total = toc(startingTime1);
	return
elseif  ~isempty(fixedVar)
	noFixedVar = size(fixedVar,1);
	if noFixedVar == 1
		fprintf('## 1 variable of POP is fixed.\n');
	else
		fprintf('## %d variables of POP are fixed.\n',noFixedVar);
	end
	if noFixedVar == objPoly.dimVar
		reduceAMatSW = 2;
	elseif noFixedVar > 0
		reduceAMatSW = 1;
	else
		reduceAMatSW = 0;
	end
else
	reduceAMatSW = 0;
end
% <--- Kojima 06/11/2007

% printing information on the Polynomial SDP to be relaxed
fileId = 0;
if ischar(param.detailedInfFile)
    fileId = fopen(param.detailedInfFile,'a+');
end

if fileId > 0
    writeParameters(fileId,param);
    fprintf(fileId,'# POP to be solved\n');
    writePOP(fileId,objPoly,ineqPolySys,lbd,ubd);
end

% If x_i has a finite lower bound l_i,
% then a new variable y_i = x_i - l_i;
% hence y_i becomes a nonnegative variable.
trans.Amat = speye(objPoly.dimVar);
trans.bVect = sparse(objPoly.dimVar,1);
if param.symbolicMath == 1 && param.scalingSW == 1
	[objPoly,ineqPolySys,lbd,ubd,trans] = convert2(objPoly,...
	ineqPolySys,lbd,ubd);
end


% Incorprate lower and upper bounds into ineqPolySys
% to strengthen the relaxation
[ineqPolySys,lbdIdx,ubdIdx] = boundToIneqPolySys(ineqPolySys,lbd,ubd);

% removing a constant term from objPoly
CTermIndex = find(any(objPoly.supports,2) == 0);
NTermIndex = find(any(objPoly.supports,2) ~= 0);
trans.objConstant = 0.0;
if ~isempty(CTermIndex)
	trans.objConstant = sum(objPoly.coef(CTermIndex,1),1);
	objPoly.supports = objPoly.supports(NTermIndex,:);
	objPoly.coef = objPoly.coef(NTermIndex,:);
	objPoly.noTerms = length(NTermIndex);
end


% Conversion of the POP to be solved into a POP whose SDP relaxation
% is numerically stable.
trans.objValScale = 1.0;
variableScale = ones(1,objPoly.dimVar);
ineqValScale = ones(1,size(ineqPolySys,2));
writeTofile = 0;
% Scaling of lbd, ubd, objPoly and ineqPolySys.
% Scaling information, which we need to scale them back later,
% is available in objValScale,ineqValScale and variableScale.
if param.scalingSW == 1
	[objPoly,ineqPolySys,lbd,ubd,trans.objValScale,ineqValScale,...
		variableScale] = scalingPOP(objPoly,ineqPolySys,lbd,ubd);
	writeTofile = 1;
end
trans.Amat = trans.Amat * diag(variableScale);
if abs(param.perturbation) > 1.0e-12
	randSeed = 117;
	objPoly  = perturbObjPoly(objPoly, param.perturbation,randSeed);
	writeTofile = 1;
end
if param.eqTolerance > 1.0e-12
	ineqPolySys = relax1EqTo2Ineqs(objPoly,ineqPolySys,param.eqTolerance);
	writeTofile = 1;
end

if fileId > 0 && writeTofile == 1
	fprintf(fileId,'# Scaled and modified POP to be solved\n');
	writePOP(fileId,objPoly,ineqPolySys,lbd,ubd);
end

% Analyzing the correlation sparsity of POP and generating the maximal
% cliques of the csp graph induced from POP if param.sparseSW == 1.
clique = genClique(objPoly,ineqPolySys,param.sparseSW);
if fileId > 0
    writeClique(fileId,clique);
end

% Construction of basisIndices used in basisSupports.
% basisIndices vary depending on param.sparseSW and
% param.multiCliquesFactor
% Construction of basisSupports. 
%$%$ Kojima 2007/08/05 --->
%   (a) Exploiting equalities in POPs based on the Cong-Muramatsu-Kojima
%       paper, but their method is considerably simplified, so that
%       the implementation here is quite simple. 
[basisIndices, basisCliqueNo, ineqPolySys] = genBasisIndices(objPoly,...
    		ineqPolySys,clique.Set,param);
basisSupports = genBasisSupports(objPoly,ineqPolySys,basisIndices,basisCliqueNo, param); 
if fileId > 0
	writeBasisIndices(fileId,basisIndices);
	writeBasisSupports(fileId,basisSupports);
end
if param.reduceEqualitiesSW ~= 0
	[basisSupports] = reduceBasisSupports(ineqPolySys,basisIndices,...
    	basisSupports,basisCliqueNo,param);
end

if param.reduceMomentMatSW == 2 
	%fprintf('## Start reduceMomentMatSW = 2\n');
	%sTime = tic;
	[basisSupports,ineqBasis] = reduceSupSets2(objPoly,ineqPolySys,basisSupports,fixedVar, objPoly0.dimVar, param);  
	%fprintf('cpu time of reduceSupSet2 = %3.2f[sec]\n', toc(sTime));
	%fprintf('##   End reduceMomentMatSW = 2\n');
else
	[basisSupports,ineqBasis] = reduceSupSets(objPoly,ineqPolySys,basisSupports,fixedVar, objPoly0.dimVar, param);  
end
%	for i=1:size(basisSupports, 2)
%		fprintf('i = %2d \n', i);
%		disp(full(basisSupports{i}));
%	end
%if param.reduceEqualitiesSW ~= 0 && param.reduceMomentMatSW ~= 0
%	[basisSupports] = reduceBasisSupports(ineqPolySys,basisIndices,...
%    	basisSupports,basisCliqueNo,param);
%end
[CompSup, binarySup, SquareOneSup, ConstraintInfo] = separateSpecialMonomial(ineqPolySys,param);
[objPoly, val, basisSupports,momentSup,ineqBasis] = substituteEq(objPoly, basisSupports,...
    ineqBasis,ineqPolySys,CompSup,binarySup,SquareOneSup,param);
trans.objConstant = trans.objConstant + val;
if fileId > 0
    fprintf(fileId,'# basisSupports after reduction\n');
    writeBasisSupports(fileId,basisSupports);
end

% Add bounds to all monoials
[ineqPolySys,basisSupports,boundList] = addBoundToPOP(ineqPolySys,...
    basisSupports,lbd,ubd,momentSup,ineqBasis,lbdIdx,ubdIdx,param);

[SDPA,xIdxVec] = PSDPtoLSDP(objPoly,ineqPolySys,basisSupports,boundList,...
    CompSup,ConstraintInfo, param);
Degree = sum(xIdxVec,2);
linearterms = find(Degree==1);
%
% 2011-11-14 H.Waki
%
constterm = find(Degree==0);
if ~isempty(constterm)
	linearterms = linearterms -1;
end
% PSDP is converted into the dual problem.
[A, b, c, K] = SDPAtoSeDuMi(SDPA);

% Kojima 06/11/2007 --->
% Cheking the linear dependence of the row vectors of the matrix A.
% If they are linearly dependent, then
% (a) reduce the system of equations A x = b,
% (b) detect whether it is infeasible, and/or
% (c) compute the unique feasible solution if the system is nonsingular and
% square.
% Set reducedMatSW = 0 to suppress this function
%
%
if param.reduceAMatSW == 1
    % infeasibleSW =  1 ---> primal SDP is infeasible
    % infeasibleSW =  0 ---> feasible and to be solved by SeDuMi if param.SDPsolverSW == 1
    % infeasibleSW = -1 ---> feasible, the SDP is square and to be solved by solveSquareSDP
    %                        Not necessary to apply SeDuMi
    [rowSizeAorg,colSizeAorg] = size(A);
    reduceAMatSW = 0;
    [reduceAMatSW,infeasibleSW,A,b,PMat,QMat,nzRowIdxUMat,x,y] = reduceSizeA4(A,b,c,K);
    %    infeasibleSW
	if infeasibleSW == 1
		SDPobjValue = -Inf;
		POP.objValue= NaN;
	end
else
    reduceAMatSW = 0;
end
% <--- Kojima 06/11/2007

% 2012-01-09  H. Waki
% 2012-05-29  H. Waki
if param.reduceAMatSW == 1
    [SDPinfo, xIdxVec] = getSeDuMiData(A, b, c, K, xIdxVec, SDPinfo,nzRowIdxUMat);
end
%%%%% April 3, 2009
% param.matFile is only for the developers' use but not for general users
%
param.developmentSW = 3;
param = saveMatFile(A,b,c,K,xIdxVec,param);
% <--- param.matFile
%%%%%

% Kojima 06/11/2007 --->
% information on SDP solved
SDPinfo = getSDPinfo(A,K, reduceAMatSW, infeasibleSW, SDPinfo);
SDPinfo.fixedVar = fixedVar;
SDPinfo.dimVar = objPoly.dimVar;
SDPinfo.dimVar0= objPoly0.dimVar;
% <--- Kojima 06/11/2007

if isfield(param,'sdpaDataFile') && ischar(param.sdpaDataFile) && ~isempty(param.sdpaDataFile)
	if exist('SedumiToSDPA','file') == 2 && ~isempty(K.s)
		SedumiToSDPA(param.sdpaDataFile, A, b, c, K);
	else
    		sedumiSDPtoSDPA(param.sdpaDataFile,A,b,c,K);
	end
	%
	% 2011-05-05 H.Waki	
	%
	if length(linearterms) == objPoly0.dimVar
		getScaleInfo(objPoly0, fixedVar, linearterms, trans.Amat, trans.bVect, param);
	else
		fprintf('## Some variables in POP are elimenated by setting param.reduceMomentMatSW = 1 \n');
		fprintf('## and/or param.reduceAMatSW = 1.\n');
		fprintf('## To obtain information on scaling, set param.reduceMomentMatSW = 0 \n');
		fprintf('## and param.reduceAMatSW = 0.\n');
	end
end
elapsedTime.conversion = toc(startingTime1);

%************************************************************************
%               The part of solving SDP relaxation problem 
%************************************************************************
if (param.SDPsolverSW == 1) && (SDPinfo.infeasibleSW == 0)
	if ~isfield(K, 'f')
		K.f = 0;
	end
	if exist('elimFrVar', 'file') && param.elimFrSW == 1 && K.f > 0 
		%   (b) Exploiting equalities in SDPs based on the
		%       Kobayashi-Nakata-Kojma paper. Their method is improved, but 
		%       further investigation is necessary for handing the sparsity. 
		%   (d) Removing redundant LP variables. The method (a) seems to create
		%       lots of redundant LP variables, which could be eliminated for 
		%       the computational efficiency.          
		fprintf('## Remove free variables by elimFrVar.m.\n');
		pars.eliminateFreeVarSW = 2;
		[probInf, tildeAMat2, tildebVect2, tildecVect, tildeK] = elimFrVar(A, b, c, K, pars);
		% Elimineate primal variables are not recovered in this
		% implementation becasue they are not used in the SDP relaxaton of
		% a POP. 
		SDPinfo = getSDPinfo(tildeAMat2,tildeK, SDPinfo.reduceAMatSW, SDPinfo.infeasibleSW, SDPinfo);
		[tildex, tildey, SDPobjValue, SDPsolverInfo] = sdpSolve(fileId, tildeAMat2, tildebVect2, tildecVect, tildeK, param, startingTime1);
		[x,y] = recoverSolution(probInf, tildex, tildey);
		SDPobjValue = -c'*x;
	else
		[x, y, SDPobjValue, SDPsolverInfo] = sdpSolve(fileId, A, b, c, K, param, startingTime1);
	end
	if SDPinfo.reduceAMatSW == 1
		yVect = zeros(rowSizeAorg,1);
		yVect(1:length(nzRowIdxUMat),1) = y;
		y = PMat'*yVect;
	end
	elapsedTime.SDPsolver = SDPsolverInfo.cpusec;
	if SDPsolverInfo.pinf == 0 && SDPsolverInfo.dinf == 0
		%        SDPobjValue = -c'*x;
		% computing an approximate solution of the POP
		[POP,SDPobjValue] = genApproxSolution(y,linearterms,SDPobjValue,...
			objPoly,objPoly0,ineqPolySys0,lbd0,ubd0,param,trans,fixedVar);
		%[feasVec, objValueVec, solVec] = samplingSol(POP, y,objPoly,objPoly0,ineqPolySys0,lbd0,ubd0,param,trans,fixedVar, xIdxVec);
		%sol = refineSol(SDPinfo, y);
	else
		SDPinfo.infeasibleSW = 0.5;
	end
elseif (SDPinfo.infeasibleSW == -1)
	SDPsolverInfo.pinf = 0;
	SDPsolverInfo.dinf = 0;
	yVect = zeros(rowSizeAorg,1);
	yVect(1:length(nzRowIdxUMat),1) = y;
	y = PMat'*yVect;
	SDPobjValue = -c'*x;
	% computing an approximate solution of the POP
	[POP,SDPobjValue] = genApproxSolution(y,linearterms,SDPobjValue,...
		objPoly,objPoly0,ineqPolySys0,lbd0,ubd0,param,trans,fixedVar);
elseif (param.SDPsolverSW == 0)
	x = [];
	y = [];
	if fileId > 0
		writeSeDuMiInputData(fileId,0,A,b,c,K);
	end
end
if fileId > 0
    fclose('all');
end
elapsedTime.total = toc(startingTime1);

SDPinfo.x = x;
SDPinfo.y = y;
SDPinfo.xIdxVec = xIdxVec;
SDPinfo.objConstant = trans.objConstant; 
SDPinfo.objValScale = trans.objValScale; 
SDPinfo.Amat = trans.Amat; 
SDPinfo.bVect = trans.bVect;

return
