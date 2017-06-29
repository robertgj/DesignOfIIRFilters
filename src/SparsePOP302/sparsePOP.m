function [param,SDPobjValue,POP,cpuTime,SDPsolverInfo,SDPinfo] ...
    = sparsePOP(objPoly,ineqPolySys,lbd,ubd,param)
%
%  SPARSEPOP  a SPARSE SOS and SDP relaxations to a POP.
%
%  GENERAL DESCRIPTION
%
% 	POP is an abbreviation of Polynomial Optimization Problem.
% 	Calling this function, one obtains the optimal value of an SDP relaxation
% 	problem for a POP. A typical invoking line may be:
%
% >>  [param,SDPobjValue,POP,cpuTime,SDPsolverInfo,SDPinfo] = sparsePOP(DataFile);
%
% 	The meanings of argument and return values are described below.
%
%  FILE ARGUMENT
%
% 	DataFile must be a string containing the file name. The DataFile must
% 	be written in the GMS format or POP format. In the case of GMS format,
% 	for example, call with
% >> sparsePOP('Bex3_1_1.gms');
% 	Don't forget the extension .gms; the file name must be exact.
% 	In the case of POP format, you should write it as if you are calling matlab
% 	function, e.g.,
% >> sparsePOP('BroydenTri(10)');
% 	See userGuide.pdf for more details.
%
%  RETURN VALUES
%
% 	param is a structure of parameters used in the execution.
% 	For more details on param structure, see below.
%
% 	SDPobjValue is the optimal value of the SDP relaxation problem.
%
% 	POP is a structure containing information on the POP. Specifically,
% 	POP.xVect is a tentative solution for POP  calculated by the SDP relaxation.
% 	POP.objvalue is the objective value of POP.xVect.
% 	POP.absError is the maximum feasibility violation of POP.xVect.
% 	Their scaled values are also stored in POP.objValScaled and POP.scaledError.
%
% 	cpuTime is the time consumed by the program execution.
% 	cpuTime.SeDuMi is the time consumed by SeDuMi (SDP Solver),
% 	cpuTime.conversion is the time needed for generating SDP relaxation from POP,
% 	and cpuTime.total is the total.
%
% 	SDPsolverInfo is the information passed by SeDuMi. See the manual of SeDuMi
% 	for its details.
%
% 	SDPinfo contains some statistics of the SDP relaxation problem.
%
%  OPTIONAL PARAMETERS
%
% 	You can pass additional parameters in the second argument.
%
% >>  [param,SDPobjValue,POP,cpuTime,SDPsolverInfo,SDPinfo] = ...
%   sparsePOP(DataFile);
%
% 	Below are some of the entries of param frequently used. See userGuide.pdf
% 	for the complete information.
%
% 	param.relaxOrder	Relaxation order for the SDP relaxation.
%
% 	param.sparseSW		if 1, sparse SDP relaxation is used.
% 		if 0, then the dense (Lasserre's original) SDP relaxation is used.
%
% 	param.perturbation 	If 1, then sparsePOP perturbs the objective function
% 		so that the resulting problem has a unique optimal solution.
% 		If 0, no perturbation is performed.
%
% 	param.symbolicMath	if 1,   symbolic math toolbox is used.
% 		Be sure that you have	purchased the symbolic math toolbox
% 		from the MathWorks. if 0, it is not used.
%
%  ANOTHER ARGUMENT STYLE
%
% 	Invoking sparsePOP by the following line:
%
% >> [param,SDPobjValue,POP,cpuTime,SDPsolverInfo,SDPinfo] = ...
%     sparsePOP(objPoly,ineqPolySys,lbd,ubd,param)
%
% 	one can directly pass all the information of POP through MATLAB structures.
% 	See userGuide.pdf for the description of each component of the arguments.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% May 09, 2010 --->
%
% Choose either versionSW = 200, 220 or 260.
%
% In Version 2.15, we shifted the function which writes an SDP as the sdpa
% sparse format.
%
%
%%%%% <--- May 09, 2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% New features of sparsePOP260, May 9, 2010
%
% Computing error bounds based on the paper
%
% M. Kojima and M. Yamashita, "Enclosing Ellipsoids and Elliptic Cylinders
% of Semialgebraic Sets and Their Application to Error Bounds in Polynomial
% Optimization", November 2009.
%
% The user can specify the set of indices of variables whose values are to
% be checke in the new parameter param.errorBdIdx.
%   (a) If param.errorBdIdx = 'a' or 'A' then sparsePOP outputs xCenter and
%       zeta such that
%           ||x - xCenter|| <= sqrt(zeta)
%       for every feasible solution of the POP with an objective value,
%       where the objective falue is either the one given by
%       param.fValueUbd, the one computed by the param.POPsolver, or the one
%       computed by the param.SDPsolver.
%   (b) If param.errorBdIdx = indexSet then then sparsePOP outputs xCenter
%       and zeta such that
%           ||x(indexSet) - xCenter(indexSet)|| <= sqrt(zeta)
%       for every feasible solution x of the POP with an objective value,
%       where the objective falue is either the one given by
%       param.fValueUbd, the one computed by the param.POPsolver, or the one
%       computed by the param.SDPsolver.  For example,
%       param.errorBdIdx = 1, param.errorBdIdx = [1,3,5],
%       param.errorBdIdx = [2:10].
%   (c) The user can specify multiple index sets. For example,
%       param.errorBdIdx{1} = 'a';
%       param.errorBdIdx{2} = 1;
%       param.errorBdIdx{3} = [2,3];
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% New features of sparsePOP210, April 03, 2009
%
% (1) Input for nonlinear least square problem. The user can represent a
% constrained nonlinear least square problem
%   minimize    \sum_{j=1}^m f_j(x)^2
%   subject to  g_k(x) >= 0 (or = 0) (k=1,2,...,m), lbd_i <= x_i <= ubd_i
% in the SparsePOP format. Each function f_j in the objective function is
% described in terms of objPoly{j}, while the constraint of the problem in
% terms of ineqPolySys, lbd and ubd in the same way as a nominal POP.
% When size(objOpt,2) >= 2, the sparsePOP automatically regards that the
% given problem is a nonlinear least square problem. and applie the
% sparse/dense SDP relaxation to it. For example,
% >> sparsePOP('BroydenTriLS.m');
%
% (2) Refinement of solutions by local optimization methods. Optimization Toolbox
% is necessary to use this feature. The new version sparsePOP210 incorporated
% MATLAB functions
%     fmincon, fminunc and lsqnonlin in Optimization Toolbox,
% so that the user can refine the solution obtained from the SDP relaxation
% by setting the parameter
%     param.POPsolver = 'active-set';
%     param.POPsolver = 'interior-point';
%     param.POPsolver = 'trust-region-reflective'; % or
%     param.POPsolver = 'lsqnonlin';
% The former three methods are for general polynomial optimization problems,
% while the last 'lsqnonlin' is valid only for nonlinear least square problems
% with bounded variables and no equality/inequality constraint (ineqPolySys =[]).
% For example,
% >> param.POPsolver = 'active-set';
% >> sparsePOP210('example1.gms',param);
% to apply fmincon with 'active-set' method. Or
% >> pram.POPsolver = 'lsqnonlin';
% >> sparsePOP210('BroydenTriLS(10)',param);
% We also note that
%   POPfmincon.m and POPlsqnonlin.m
% can be used as standalone MATLAB progams to solve POPs and polynnomial
% least square problems described in terms of the SparsePOP format.
% They are stored in the directory subPrograms/V210Subprogams
%
%%%%% <--- April 3, 2009

%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is a component of SparsePOP
% Copyright (C) 2007-2011 SparsePOP Project
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

%%%%% May 1, 2012 --->
versionSW = 302;
if versionSW == 302
    fprintf('\nSparsePOP 3.02\nby H.Waki, S.Kim, M.Kojima,');
    fprintf(' M.Muramatsu,\n   H.Sugimoto and M.Yamashita,');
    fprintf(' December 2016\n\n');
elseif versionSW == 301
    fprintf('\nSparsePOP 3.01\nby H.Waki, S.Kim, M.Kojima,');
    fprintf(' M.Muramatsu,\n   H.Sugimoto and M.Yamashita,');
    fprintf(' October 2015\n\n');
elseif versionSW == 300
    fprintf('\nSparsePOP 3.00\nby H.Waki, S.Kim, M.Kojima,');
    fprintf(' M.Muramatsu,\n   H.Sugimoto and M.Yamashita,');
    fprintf(' September 2014\n\n');
elseif versionSW == 299
    fprintf('\nSparsePOP 2.99\nby H.Waki, S.Kim, M.Kojima,');
    fprintf(' M.Muramatsu,\n   H.Sugimoto and M. Yamashita,');
    fprintf(' February 2012\n\n');
elseif versionSW == 298
    fprintf('\nSparsePOP 2.98\nby H.Waki, S.Kim, M.Kojima,');
    fprintf(' M.Muramatsu,\n   H.Sugimoto and M. Yamashita,');
    fprintf(' December 2011\n\n');
elseif versionSW == 297
    fprintf('\nSparsePOP 2.97\nby H.Waki, S.Kim, M.Kojima,');
    fprintf(' M.Muramatsu,\n   H.Sugimoto and M. Yamashita,');
    fprintf(' September 2011\n\n');
elseif versionSW == 296
    fprintf('\nSparsePOP 2.96\nby H.Waki, S.Kim, M.Kojima,');
    fprintf(' M.Muramatsu,\n   H.Sugimoto and M. Yamashita,');
    fprintf(' August 2011\n\n');
elseif versionSW == 295
    fprintf('\nSparsePOP 2.95\nby H.Waki, S.Kim, M.Kojima,');
    fprintf(' M.Muramatsu,\n   H.Sugimoto and M. Yamashita,');
    fprintf(' July 2011\n\n');
elseif versionSW == 290
    fprintf('\nSparsePOP 2.90\nby H.Waki, S.Kim, M.Kojima,');
    fprintf(' M.Muramatsu,\n   H.Sugimoto and M. Yamashita,');
    fprintf(' June 2011\n\n');
elseif versionSW == 285
    fprintf('\nSparsePOP 2.85\nby H.Waki, S.Kim, M.Kojima,');
    fprintf(' M.Muramatsu,\n   H.Sugimoto and M. Yamashita,');
    fprintf(' May 2011\n\n');
elseif versionSW == 280
    fprintf('\nSparsePOP 2.80\nby H.Waki, S.Kim, M.Kojima,');
    fprintf(' M.Muramatsu,\n   H.Sugimoto and M. Yamashita,');
    fprintf(' February 2011\n\n');
elseif versionSW == 260
    fprintf('\nSparsePOP 2.60\nby H.Waki, S.Kim, M.Kojima,');
    fprintf(' M.Muramatsu,\n   H.Sugimoto and M. Yamashita,');
    fprintf(' May 2010\n\n');
elseif versionSW == 220
    fprintf('\nSparsePOP 2.20\nby H.Waki, S.Kim, M.Kojima,');
    fprintf(' M.Muramatsu,\n   H.Sugimoto and M. Yamashita,');
    fprintf(' July 2009\n\n');
else
    fprintf('\nSparsePOP 2.00 by H.Waki, S.Kim, M.Kojima,');
    fprintf(' M.Muramatsu and H.Sugimoto\n');
    fprintf('                                            ');
    fprintf('                June 2007\n\n');
end
%%%%% <--- August 22, 2011

if exist('checkBMI') ~= 2 || exist('simplifyPolynomial') ~= 2
	addpath(genpath(pwd));
end

% Check whether the input problemData is a gms file or
% polynomial format file and set problemName by eleminating '.gms' from
% the gms file or '(...)' from the polynomial format file

gmsSW = 0;
polySW = 0;
mFileSW = 0;
if nargin == 1
    problemData = objPoly;
    param = [];
elseif nargin == 2
    problemData = objPoly;
    param = ineqPolySys;
elseif nargin == 3
    error('Input has something wrong.');
else
    polySW = 1;
    if nargin == 4
        param = [];
    end
    if (size(objPoly,2) == 1) && (isfield(objPoly,'dimVar'))
        nDim = objPoly.dimVar;
    elseif (size(objPoly,2) > 1) && (isfield(objPoly{1},'dimVar'))
        nDim = objPoly{1}.dimVar;
    else
        error('Set a value in the field dimVar of objPoly.');
    end
    mDim = size(ineqPolySys,2);
    nDim = num2str(nDim);
    mDim = num2str(mDim);
    problemData = strcat('nDim: ', nDim, ', mDim: ', mDim, '.');
end

if polySW == 0
    % Input is described in either the GAMS format or the SparsePOP format.
    gmsForm = strfind(problemData,'.gms');
    if length(gmsForm) == 1
        %
        % Input is a gms file.
        %
        gmsSW = 1;
    elseif length(gmsForm) >1 || isempty(problemData)
        %
        % if input has more than one string 'gms', we regard it as error.
        %
        error('Input problem must be a gms file or polynomial format file.');
    elseif isempty(gmsForm) && ~isempty(problemData)
        %
        % Input is an m-file which returns POP in the SparsePOP format.
        %
        mFileSW = 1;
    end
end


% param
param = defaultParameter(param);

startingTime = tic;
% read Data
if gmsSW == 1 % the input file is a gms file
    [objPoly,ineqPolySys,lbd,ubd, minOrmax] = readGMS(problemData,param.symbolicMath);
elseif mFileSW == 1
    [objPoly,ineqPolySys,lbd,ubd] = eval(problemData);
    minOrmax = 'min';
else
    minOrmax = 'min';
end

if size(ineqPolySys, 2) == 1
	ineqPolySys = ineqPolySys';	
end

%%%%% April 3, 2009 --->
% Checking whether the given problem is a least square problem
%
%   minimize    \sum objPoly{i}^2
%   subject to  ineqPolySys, lbd and ubd
%
% If size(objPoly,2) >= 2, then replace objPoly by LSobjPoly and set
%       objPoly = \sum objPolyLS{i}^2.
% Else LSobjPoly = [].
if (versionSW >= 210) && (size(objPoly,2) >= 2)
    startingTime2 = tic;
    [objPoly,LSobjPoly] = checkMultipleObj(objPoly);
    cpuTimeSingleObj = toc(startingTime2);
else
    LSobjPoly = [];
end
%%%%% <--- April 3, 2009

% checking param.errorBdIdx
if ~isempty(param.errorBdIdx)
	if iscell(param.errorBdIdx)
		rr = size(param.errorBdIdx,2);
	else
		rr = 1;
	end
	NonEmptyIdx = [];
	for r = 1:rr
		if iscell(param.errorBdIdx)
			if ischar(param.errorBdIdx{r}) && (strcmp(param.errorBdIdx{r},'a') || strcmp(param.errorBdIdx{r},'A'))
				param.errorBdIdx{r} = 1:objPoly.dimVar;
			end
			rangeIdx = ismember(param.errorBdIdx{r}, 1:objPoly.dimVar);
			rangeIdx = find(rangeIdx == 0);
			if ~isempty(rangeIdx)
				error('Should set param.errorBdIdx correctly.');
			end
			if ~isempty(param.errorBdIdx{r})
				NonEmptyIdx = [NonEmptyIdx, r];
			end
		else
			if ischar(param.errorBdIdx) && (strcmp(param.errorBdIdx,'a') || strcmp(param.errorBdIdx,'A'))
				param.errorBdIdx = 1:objPoly.dimVar;
			end
			rangeIdx = ismember(param.errorBdIdx, 1:objPoly.dimVar);
			rangeIdx = find(rangeIdx == 0);
			if ~isempty(rangeIdx)
				error('Should set param.errorBdIdx correctly.');
			end
		end
	end
	if ~isempty(NonEmptyIdx)
    		if (size(objPoly,2) == 1) && (isfield(objPoly,'dimVar'))
        		nDim = objPoly.dimVar;
		elseif (size(objPoly,2) > 1) && (isfield(objPoly{1},'dimVar'))
			nDim = objPoly{1}.dimVar;
		end
		tmpCell = cell(1, length(NonEmptyIdx));
		for i=1:length(NonEmptyIdx)
			tmpCell{1,i} = param.errorBdIdx{1,NonEmptyIdx(i)};
			maxIdx = max(tmpCell{1,i});
			if maxIdx > nDim
				fprintf('## errorBdIdx has something wrong.\n');
				error('## errorBdIdx contains an index which is more than the number of POP.');
			end
		end
		param.errorBdIdx = tmpCell;
	end

end
%
% 2011-11-30 H.Waki
% If POP has a polynomial sdp constriant, 
% we set param.scalingSW = 0.
%
tf = checkBMI(objPoly, ineqPolySys, lbd, ubd);
if tf == 1
	param.scalingSW = 0;
end
cpuTimeReadData = toc(startingTime);


%%%%%
% Add objPoly.sizeCone = 1 if it is not specified by the user
if ~isfield(objPoly,'sizeCone')
    objPoly.sizeCone = 1;
end
% Add ineqPolySys{i}.sizeCone = 1 if it is not specified by the user
for i=1:size(ineqPolySys,2);
    if ~isfield(ineqPolySys{i},'sizeCone')
        ineqPolySys{i}.sizeCone = 1;
    end
end

if isfield(param,'multiCliquesFactor') && ischar(param.multiCliquesFactor)
    param.multiCliquesFactor = objPoly.dimVar;
end

% check inputs
if issparse(lbd)
    lbd = full(lbd);
end
if size(lbd, 1) ~= 1
    if size(lbd, 2) ~= 1
        error('lbd should be a row vector.');
    else
        lbd = lbd';
    end
end
if issparse(ubd)
    ubd = full(ubd);
end
if size(ubd, 1) ~= 1
    if size(ubd, 2) ~= 1
        error('ubd should be a row vector.');
    else
        ubd = ubd';
    end
end

continueSW = checkPOP(objPoly,ineqPolySys,lbd,ubd,param);
if continueSW == 0
    error('## Some inconsistensy in input data, objPoly, ineqPolySys, lbd, ubd and param ##\n');
end

% Compute relaxOrder
rOtmp = ceil(objPoly.degree/2);
for i=1:size(ineqPolySys,2)
    tmpdeg = ceil(ineqPolySys{i}.degree/2);
    rOtmp = max(rOtmp,tmpdeg);
end
if ~isfield(param,'relaxOrder')
    param.relaxOrder = rOtmp;
elseif isfield(param,'relaxOrder') && param.relaxOrder < rOtmp
    param.relaxOrder = rOtmp;
end

%%%%%%%%%%
% perturbation
%%%%%%%%%%
if abs(param.perturbation) > 1.0e-12
    randSeed = 2008;
    objPoly  = perturbObjPoly(objPoly, param.perturbation,randSeed);
    param.perturbation = 0.0;
end
%%%%%%%%%%

if param.mex == 1
    %
    % If mex files exist in your MATLAB search path, you uese mex version
    %
    [param,SDPobjValue,POP,cpuTime,SDPsolverInfo,SDPinfo] = ...
        SDPrelaxationMex(param,objPoly,ineqPolySys,lbd,ubd);
elseif param.mex == 0
    %
    % If mex files do not exist in your MATLAB search path, you uese no
    % mex version
    %
    [param,SDPobjValue,POP,cpuTime,SDPsolverInfo,SDPinfo] = ...
        SDPrelaxation(param,objPoly,ineqPolySys,lbd,ubd);
else
    error('set param.mex = 1 or 0');
end

if strcmp(minOrmax, 'max')
    SDPobjValue = -SDPobjValue;
    POP.objValue = -POP.objValue;
end

if exist('cpuTimeReadData','var')
    cpuTime.readData = cpuTimeReadData;
end
if exist('cpuTimeSingleObj','var')
    cpuTime.singleObj = cpuTimeSingleObj;
end

if param.printLevel(1) >= 1
    printSolution(1,param.printLevel(1),problemData,param,SDPobjValue,...
        POP,cpuTime,SDPsolverInfo,SDPinfo);
end

if ischar(param.printFileName) && ~isempty(param.printFileName)
    if param.printLevel(2) == 0
        param.printLevel(2) = 2;
    end
    fileId = fopen(param.printFileName,'a+');
    printSolution(fileId,param.printLevel(2),problemData,param,...
        SDPobjValue,POP,cpuTime,SDPsolverInfo,SDPinfo);
    fclose(fileId);
end

%%%%% April 3, 2009 --->
% Application of MATLAB functions
%   fmincon ('interior-point', 'active-set', 'trust-region-reflective' method)
%       for constrained minimization problems
%   lsqnonlin for nonlinear least square problems with bounds
% To use these functions, Optimization Toolbox is necessary.
[param,POP,cpuTime] = ExploitOptTool(versionSW,LSobjPoly, objPoly, ineqPolySys, lbd, ubd, POP, SDPinfo, SDPsolverInfo,SDPobjValue, cpuTime, param, minOrmax);
% <--- April 3, 2009
%%%%%
% May 9, 2010 --->
if (versionSW >= 260) && (~isempty(param.errorBdIdx)) && (SDPinfo.infeasibleSW == 0 || SDPinfo.infeasibleSW == 0.5)
	if isempty(POP.xVect) || (~isempty(POP.xVect) && isfield(param, 'POPsolver') && ~isempty(param.POPsolver) && isempty(POP.xVectL)) 
		if (param.printLevel(1) >= 1) 
			printErrorBound(1,[],param,POP, SDPinfo);
		end
		if isfield(param,'printFileName') && ~isempty(param.printFileName) && isstr(param.printFileName)
			fileId = fopen(param.printFileName,'a+');
			printErrorBound(fileId,[],param,POP, SDPinfo);
			fclose(fileId);
		end
	elseif (isfield(param,'fValueUbd') && ~isempty(param.fValueUbd)) || ...
           (isfield(param,'SDPsolver') && ~isempty(param.SDPsolver)) || ...
           (isfield(param,'POPsolver') && ~isempty(param.POPsolver))
		fprintf('\n## Computing error bound\n');
		tic;
		[fValue,POP.xCenter,POP.zeta] = errorBound(param,SDPinfo,POP);
		eTimeErrorBound = toc;
		if (param.printLevel(1) >= 1) && (~isempty(fValue))
			fprintf('\n## elapsed time of computing error bounds = %8.2f [sec]\n',eTimeErrorBound);
			printErrorBound(1,fValue,param,POP, SDPinfo);
		end
		if ischar(param.printFileName) && ~isempty(param.printFileName)  && (~isempty(fValue))
			fileId = fopen(param.printFileName,'a+');
			fprintf(fileId, '\n\n## elapsed time of computing error bounds = %8.2f\n',eTimeErrorBound);
			printErrorBound(fileId,fValue,param,POP, SDPinfo);
			fclose(fileId);
		end
	else
		fprintf('## Neither of param.fValueUbd, POP.objValueL and POP.objValue is given,\n'),
		fprintf('## so error bound can not be computed\n');
	end
end
% <--- May 9, 2010

return
