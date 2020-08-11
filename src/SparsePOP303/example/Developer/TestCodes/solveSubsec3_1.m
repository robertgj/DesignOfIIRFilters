function solveSubsec3_1(relaxOrder)

%
% This function solves POP in Subsection 3.1 with up to r = relaxOrder
% and generates tables which is contained in Subsection 3.1 as TEX file.  
% 
% `relaxOrder' should be a positive integer and the default value is 10.  
% User must add the matlab path of SeDuMi and SDPT3 for using this. 
% 
% 2012-04-07 M.Muramatsu, H.Waki and L.Tuncel
% 

if nargin == 0
	relaxOrder = 10;
end

filename = 'pop.gms';

% Important setting for this numerical experiment
param0.sparseSW = 2;
param0.reduceMomentMatSW = 0;
param0.boundSW = 0;
param0.scalingSW = 0;
param0.mex = 0;
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

NoSolvers = 2;
InfoSDP = cell(NoSolvers, relaxOrder);
CompResult = cell(NoSolvers,relaxOrder);
Errors = cell(NoSolvers,relaxOrder);
for solvers=1:NoSolvers
	if solvers == 1
		param.SDPsolver = 'sedumi';
	elseif solvers == 2
		param.SDPsolver = 'sdpt3';
	elseif solvers == 3
		param.SDPsolver = 'sdpa';
	else
		error('No solvers.');
	end
	for k = 1:relaxOrder
		param.relaxOrder = k;
		fprintf('## Solve POP in Subsection 3.1 with r = %d by %s\n',param.relaxOrder, param.SDPsolver);
		[param,SDPobjValue,POP,cpuTime,SDPsolverInfo,SDPinfo] = sparsePOP(filename,param);
		[infoSDP, compResult, errors] = getInfo(param, SDPsolverInfo, POP, SDPobjValue, SDPinfo, cpuTime);
		InfoSDP{solvers, k} = infoSDP;
		CompResult{solvers, k} = compResult;
		Errors{solvers, k} = errors;
	end
end
genTex(param, CompResult, InfoSDP, Errors, 1);
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
