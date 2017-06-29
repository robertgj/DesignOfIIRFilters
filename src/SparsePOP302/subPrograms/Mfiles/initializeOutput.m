function [SDPinfo, SDPsolverInfo, POP, SDPobjValue] = initializeOutput(param)

SDPobjValue = [];
POP.xVect = [];
POP.objValue = [];
POP.absError = [];
POP.scaledError = [];

SDPinfo.rowSizeA = 0;
SDPinfo.colSizeA = 0;
SDPinfo.nonzerosInA = 0;
SDPinfo.noOfFreevar = 0;
SDPinfo.noOfLPvariables = 0;
SDPinfo.SOCPblock = [];
SDPinfo.SDPblock = [];
SDPinfo.reduceAMatSW = 0;
SDPinfo.infeasibleSW = 0;
SDPinfo.objConstant = 0;
SDPinfo.objValScale = 1;
SDPinfo.SeDuMiA = [];
SDPinfo.SeDuMib = [];
SDPinfo.SeDuMic = [];
SDPinfo.SeDuMiK = [];;
SDPinfo.Amat = []; 
SDPinfo.bVect = [];

SDPsolverInfo.numerr = 0;
SDPsolverInfo.pinf = NaN;
SDPsolverInfo.dinf = NaN;
if strcmp(param.SDPsolver, 'sedumi') || isempty(param.SDPsolver)
	SDPsolverInfo.iter = 0;
	SDPsolverInfo.err = [NaN, NaN, NaN, NaN, NaN, NaN];
	SDPsolverInfo.feasratio = NaN;
elseif strcmp(param.SDPsolver, 'sdpa')
	SDPsolverInfo.dimacs = [NaN, NaN, NaN, NaN, NaN, NaN];
	SDPsolverInfo.phasevalue = '';
	SDPsolverInfo.iteration = 0;
elseif strcmp(param.SDPsolver, 'sdpt3')
	SDPsolverInfo.termcode = 0;
	SDPsolverInfo.iter = 0;
	SDPsolverInfo.obj = [NaN, NaN];
	SDPsolverInfo.cputime = 0;
	SDPsolverInfo.gap = 0;
	SDPsolverInfo.dimacs = [NaN, NaN, NaN, NaN, NaN, NaN];
	SDPsolverInfo.pinfeas = NaN;
	SDPsolverInfo.dinfeas = NaN;
elseif strcmp(param.SDPsolver, 'csdp')
	SDPsolverInfo.info = 0;
elseif strcmp(param.SDPsolver, 'sdpnal')
	%
	% SDPNAL does not return information on an approximated solution. 
	%
end

return 
