function [param,SDPobjValue,POP,elapsedTime,SDPsolverInfo,SDPinfo] = ... 
    SDPrelaxationMex(param,objPoly,ineqPolySys,lbd,ubd)

% 
% SDPrelaxationMex wroks as SDPrelaxation to solve a polinomial optimization 
% problem described in SparsePOP format. The main part of SDPrelaxationMex 
% is written in C++ to speed up the cnversion of a given POP into an SDP 
% relaxation problem. 
% Usage: 
% [param,SDPobjValue,POP,elapsedTime,SDPsolverInfo,SDPinfo] = ...
%		SDPrelaxation(param,objPoly,ineqPolySys,lbd,ubd);
%
% NOTICE: This program does not check the validness of inputs. Users must 
% check it by subPrograms/Mfiles/checkPOP.m in advance when they use this program.
% Moreover, input polynomials must not have monomials whose coefficients are zero. 
%
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
startingTime1 = tic;

%% Outputs
elapsedTime.SDPsolver = 0.0;
[SDPinfo, SDPsolverInfo, POP, SDPobjValue] = initializeOutput(param);

%************************************************************************
fileId = 0;
if ischar(param.detailedInfFile)
	fileId = fopen(param.detailedInfFile,'a');  
end

% saving the original POP information
[objPoly0,ineqPolySys0,lbd0,ubd0] = saveOriginalPOP(objPoly,...
    ineqPolySys,lbd,ubd); 
SDPinfo.dimVar0 = objPoly0.dimVar;

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
    %noFixedVar = length(fixedVar);
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

%*************************************************************************
%                       Make special data-type used in mex function
%*************************************************************************
[   typelist,...
    sizelist,...
    degreelist,...
    dimvarlist,...
    notermslist,...
    supdata,...
    coefdata ] = make_mexdata(objPoly, ineqPolySys);

%[s,w]=system('top -b -n 1 | grep MATLAB | head -1 ');
%if s == 0
%	disp(w);
%end

%************************************************************************
%                        Convert POP (Part1)
%************************************************************************
%fprintf('+++ Convert Part1 +++\n');
[   new_typelist,...
    new_sizelist,...
    new_degreelist,...
    new_dimvarlist,...
    new_notermslist,...
    new_lbd,...
    new_ubd,...
    new_supdata,...
    new_coefdata,...
    objconst,...
    scalevalue,...
    bvect,...
    permmatrix,...
    cspmatrix,...
	lbdIdx,...
    ubdIdx] = mexconv1( typelist, sizelist, degreelist, dimvarlist,notermslist,lbd,ubd,supdata,coefdata,param);
trans.objConstant = objconst;

%[s,w]=system('top -b -n 1 | grep MATLAB | head -1 ');
%if s == 0
%	disp(w);
%end
% transform objPoly into sparsePOP format.
NewobjPoly.typeCone = new_typelist(1);
NewobjPoly.sizeCone = new_sizelist(1);
NewobjPoly.degree = new_degreelist(1);
NewobjPoly.dimVar = new_dimvarlist(1);
NewobjPoly.noTerms = new_notermslist(1);
NewobjPoly.supports = sparse(new_supdata(:,1:NewobjPoly.noTerms)');
NewobjPoly.coef = new_coefdata(1,1:NewobjPoly.noTerms)';
%full([NewobjPoly.supports, NewobjPoly.coef])
%[s,w]=system('top -b -n 1 | grep MATLAB | head -1 ');
%if s == 0
%	disp(w);
%end

%************************************************************************
%              Chordal Extension by Cholesky decompostion
%************************************************************************
if param.sparseSW == 1
	cspmatrix = cspmatrix + cspmatrix';
	cspmatrix = cspmatrix + 5*new_dimvarlist(1)*speye(new_dimvarlist(1));
	[oriIdx,stats] = symamd(cspmatrix);
	[extmatrix,p] = chol(cspmatrix(oriIdx,oriIdx));
	if(p > 0)
		error('Correlative sparsity matrix is not positive definite\n');
	end
	extmatrix = extmatrix';
elseif param.sparseSW == 0
    s = size(cspmatrix,1);
    extmatrix = speye(s);
    oriIdx = (1:s);
else
	error('## param.sparseSW should be 0 or 1.');
end
if ~issparse(extmatrix)
	extmatrix = sparse(extmatrix);
end
if ~issparse(oriIdx)
	oriIdx = sparse(oriIdx);
end
%[s,w]=system('top -b -n 1 | grep MATLAB | head -1 ');
%if s == 0
%	disp(w);
%end

%************************************************************************
%                           Convert POP (Part2)
%************************************************************************
%fprintf('+++ Convert Part2 +++\n');
%
[ SDPA , linearterms, xIdxVec, objconst] = mexconv2(...
    new_typelist, ...
    new_sizelist, ...
    new_degreelist, ...
    new_dimvarlist, ...
    new_notermslist, ...
    new_lbd,...
    new_ubd,...
    new_supdata,...
    new_coefdata,...
    param,...
    extmatrix,...
    oriIdx,...
    lbdIdx,...
	ubdIdx);
% 2010-01-09 H.Waki
% We need to apply matrix transpose into xIdxVec.
%
xIdxVec = xIdxVec';

% PSDP is converted into the dual problem.  
[A, b, c, K] = SDPAtoSeDuMi(SDPA); 

% This command works well on Linux and Unix.
%[s,w]=system('top -b -n 1 | grep MATLAB | head -1 ');
%if s == 0
%	disp(w);
%end

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
if param.reduceAMatSW == 1
    [SDPinfo, xIdxVec] = getSeDuMiData(A, b, c, K, xIdxVec, SDPinfo,nzRowIdxUMat);
end

%%%%% April 3, 2009
% param.matFile ---> 
%
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

%
% 2009-07-06 Waki
% add the function to write SDP as the sdpa sparse format.
%
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
		getScaleInfo(objPoly0, fixedVar, linearterms, permmatrix, bvect, param);
	else
		fprintf('## Some variables in POP are elimenated by setting param.reduceMomentMatSW = 1 \n');
		fprintf('## and/or param.reduceAMatSW = 1.\n');
		fprintf('## To obtain information on scaling, set param.reduceMomentMatSW = 0 \n');
		fprintf('## and param.reduceAMatSW = 0.\n');
	end
end

elapsedTime.conversion = toc(startingTime1);

trans.Amat = permmatrix;
trans.bVect = bvect;
trans.objConstant = trans.objConstant + objconst;
trans.objValScale = scalevalue(1);
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
       		[POP,SDPobjValue] = genApproxSolution(y,...
     			linearterms,SDPobjValue,NewobjPoly,objPoly0,...
			ineqPolySys0,lbd0,ubd0,param,trans,fixedVar);
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
       	[POP,SDPobjValue] = genApproxSolution(y,...
     			linearterms,SDPobjValue,NewobjPoly,objPoly0,...
			ineqPolySys0,lbd0,ubd0,param,trans,fixedVar);
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

