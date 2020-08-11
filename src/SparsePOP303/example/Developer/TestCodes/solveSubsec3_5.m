function solveSubsec3_5(NN, relaxOrder)

%
% This function solves `NN' BMIEP in Subsection 3.5 with (n,m,k) = 
% (1,1,5), (1,1,10), (3,3,5) and (3,3,10)  
% by Lasserre's and our proposed relaxations, and generates tables which is 
% contained in Subsection 3.5 as TEX file.
% 
% `NN' should be a positive integer and the default value is 30.  
% `relaxOrder' is relaxation order and should be a positive integer.
% 
% 2012-04-07 M.Muramatsu, H.Waki and L.Tuncel
% 

if nargin < 2
	relaxOrder = 3;
end 
if nargin < 1
	NN = 30;
end

% Important setting for this numerical experiment
% The set of (n, m, k)
Vec = [ 1, 1, 5;
		1, 1, 10;
		1, 1, 15;
		3, 3, 5;
		3, 3, 10;
		3, 3, 15;
		5, 5, 5;
		5, 5, 10;
		5, 5, 15];
Vec = [3, 3, 10];
N = size(Vec, 1);
param0.aggressiveSW = 1;
param0.reduceMomentMatSW = 2;
param0.boundSW = 2;
param0.scalingSW = 0;
param0.mex = 0;
param0.relaxOrder = relaxOrder;
seed = 3201;
%
% You can control the tolerance for SDP solvers by setting 
% the following parameter.
% Default values:
% 1.0e-9 for SeDuMi
% 1.0e-8 for SDPT3
%
% param0.SDPsolverEpsilon = 1.0e-9;

[param] = defaultParameter(param0);
%
% You can display the log of SDP solvers and the final result.
% 
param.printLevel = [2,2];
param.SDPsolverOutFile = 1;
DefaultSeed = seed;
NoSolvers  = 2;
InfoSDP    = cell(NoSolvers, 2, N, NN);
CompResult = cell(NoSolvers, 2, N, NN);
Errors     = cell(NoSolvers, 2, N, NN);

for j=1:N
	nDim = Vec(j, 1);
	mDim = Vec(j, 2);
	kDim = Vec(j, 3);
	seed = DefaultSeed;
	for i=1:NN
		seed = seed + 1000;	
		[objPoly, inEqPolySys, lbd, ubd] = genBMIEPsparse(nDim, mDim, kDim, 0, seed);
		for solvers=1:NoSolvers
			if solvers == 1
				param.SDPsolver = 'sedumi';
			elseif solvers == 2
				param.SDPsolver = 'sdpt3';
			elseif solvers == 3
				param.SDPsolver = 'sdpa';
			end
			for sparseSW=1:2
				if sparseSW == 1
					param.sparseSW = 0;
					fprintf('## Solve POP in Subsection 3.5 with Lasserre''s SDP relaxation and r = %d by %s\n',param.relaxOrder, param.SDPsolver);
				elseif sparseSW == 2
					param.sparseSW = 2;
					fprintf('## Solve POP in Subsection 3.5 with our proposed SDP relaxation and r = %d by %s\n',param.relaxOrder, param.SDPsolver);
				end
				fprintf('## (nDim, kDim, i, seed) = (%2d, %2d, %2d, %5d)\n', nDim, kDim, i, seed);
				[param, SDPobjValue, POP, cpuTime, SDPsolverInfo, SDPinfo] = sparsePOP(objPoly, inEqPolySys, lbd, ubd, param);
				[infoSDP, compResult, errors] = getInfo(param, SDPsolverInfo, POP, SDPobjValue, SDPinfo, cpuTime);
				InfoSDP{solvers, sparseSW, j, i}    = infoSDP;
				CompResult{solvers, sparseSW, j, i} = compResult;
				Errors{solvers, sparseSW, j, i}     = errors;	
			end
		end	
	end
end	
genTex(param, CompResult, InfoSDP, Errors, 5, DefaultSeed);
return

function [InfoSDP, CompResult, Errors] = getInfo(param, SDPsolverInfo, POP, SDPobjValue, SDPinfo, cpuTime)

InfoSDP.size = [SDPinfo.rowSizeA, SDPinfo.colSizeA];
InfoSDP.nnzA = SDPinfo.nonzerosInA;
InfoSDP.nofr = SDPinfo.noOfFreevar;
InfoSDP.nolp = SDPinfo.noOfLPvariables; 
InfoSDP.sdp  = SDPinfo.SDPblock;  	
InfoSDP.avesdp  = sum(SDPinfo.SeDuMiK.s)/length(SDPinfo.SeDuMiK.s);
InfoSDP.maxsdp  = max(SDPinfo.SeDuMiK.s);  	
CompResult.SDPobj = SDPobjValue;
CompResult.ro = param.relaxOrder;
CompResult.POPobj = POP.objValue;
CompResult.cpuTime = cpuTime.SDPsolver;
if strcmp(param.SDPsolver, 'sedumi') || isempty(param.SDPsolver)
	Errors.dimacs = SDPsolverInfo.err;
	Errors.iter = SDPsolverInfo.iter;
	Errors.nerr = SDPsolverInfo.numerr;
elseif strcmp(param.SDPsolver, 'sdpt3')
	Errors.dimacs = SDPsolverInfo.dimacs';
	Errors.iter = SDPsolverInfo.iter;
	Errors.nerr = SDPsolverInfo.numerr;
elseif strcmp(param.SDPsolver, 'sdpa')
	Errors.dimacs = SDPsolverInfo.dimacs';
	Errors.iter = SDPsolverInfo.iteration;
	Errors.nerr = SDPsolverInfo.phasevalue;
end
Errors.objerr = (POP.objValue - SDPobjValue)/max(1, abs(SDPobjValue));
Errors.absE = POP.absError;
Errors.scaledE = POP.scaledError;
return
