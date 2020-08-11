function printSolution(fileId,printLevel,dataFileName,param,...
    SDPobjValue,POP,elapsedTime,SDPsolverInfo,SDPinfo)
%
% printSolution
% prints solutions obtained by sparsePOP.
%
% Usage:
%
% printSolution(fileId,printLevel,dataFileName,param,SDPobjValue,...
%	POP,elapsedTime,SDPsolverInfo,SDPinfo);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fileId: the file ID where output goes. If this is 1, then the output is
%       the standard output (i.e., the screen). Default is 1.
% printLevel: controls how much information should be printed.
%       A larger value gives more information. Default value is 2.
% dataFileName: the name of the problem.
% The rest of the input arguments must be the outputs of sparsePOP.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% none.

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

if printLevel >= 1
    if (param.SDPsolverSW == 0) || (SDPinfo.infeasibleSW <= -1) || (SDPinfo.infeasibleSW >= 1);
        fprintf(fileId,'\n## Computational Results by sparsePOP.m ##\n');
    else
        fprintf(fileId,'\n## Computational Results by sparsePOP.m');
        if strcmp(param.SDPsolver,'sedumi')
            fprintf(fileId,' with SeDuMi ##\n');
        elseif strcmp(param.SDPsolver,'sdpa')
            fprintf(fileId,' with SDPA ##\n');
        elseif strcmp(param.SDPsolver,'sdpt3')
            fprintf(fileId,' with SDPT3 ##\n');
        elseif strcmp(param.SDPsolver,'sdpNAL') || strcmp(param.SDPsolver, 'sdpnal')
            fprintf(fileId,' with SDPNAL ##\n');
        elseif strcmp(param.SDPsolver,'csdp')
            fprintf(fileId,' with CSDP ##\n');
        elseif strcmp(param.SDPsolver,'sdpNALplus') || strcmp(param.SDPsolver, 'sdpnalplus')
            fprintf(fileId,' with SDPNAL+ ##\n');
        else
            fprintf(fileId,' ##\n');
        end
    end
    fprintf(fileId,'## Printed by printSolution.m ##\n');
end
if ~isempty(dataFileName)
    fprintf(fileId,'# Problem File Name   = %s\n',dataFileName);
end

if printLevel >= 1
    fprintf(fileId,'# parameters:\n');
    fprintf(fileId,'  relaxOrder          = %d\n',param.relaxOrder);
    fprintf(fileId,'  sparseSW            = %d\n',param.sparseSW);
    if ischar(param.multiCliquesFactor) == 1
        fprintf(fileId,'  multiCliquesFactror = %s\n',param.multiCliquesFactor);
    elseif isnumeric(param.multiCliquesFactor) == 1
        if param.multiCliquesFactor ~=1
            fprintf(fileId,'  multiCliquesFactror = %d\n',param.multiCliquesFactor);
        end
    end
    if param.scalingSW == 0
        fprintf(fileId,'  scalingSW           = %d\n',param.scalingSW);
    end
    if param.boundSW == 0 || param.boundSW == 1
        fprintf(fileId,'  boundSW             = %d\n',param.boundSW);
    end
    if param.eqTolerance > 1.0e-10
        fprintf(fileId,'  eqTolerance         = %6.2e\n',param.eqTolerance);
    end
    if param.perturbation > 1.0e-10
        fprintf(fileId,'  perturbation        = %6.2e\n',param.perturbation);
    end
    if param.reduceMomentMatSW ~= 1
        fprintf(fileId,'  reduceMomentMatSW   = %d\n',param.reduceMomentMatSW);
    end
    if param.complementaritySW == 1
        fprintf(fileId,'  complementaritySW   = %d\n',param.complementaritySW);
    end
    if param.SquareOneSW == 0
        fprintf(fileId,'  SquareOneSW         = %d\n',param.SquareOneSW);
    end
    if param.binarySW == 0
        fprintf(fileId,'  binarySW            = %d\n',param.binarySW);
    end
    if param.reduceAMatSW == 0
        fprintf(fileId,'  reduceAMatSW        = %d\n',param.reduceAMatSW);
    end
    if param.SDPsolverSW ~= 1
        fprintf(fileId,'  SDPsolverSW         = %d\n',param.SDPsolverSW);
    end
    if ischar(param.SDPsolverOutFile) == 1
        fprintf(fileId,'  SDPsolverOutFile    ');
        fprintf(fileId,'= %s\n',param.SDPsolverOutFile);
    elseif isnumeric(param.SDPsolverOutFile) == 1
        if param.SDPsolverOutFile ~= 0
            fprintf(fileId,'  SDPsolverOutFile    ');
            fprintf(fileId,'= %d\n',param.SDPsolverOutFile);
        end
    end
    if ~isempty(param.detailedInfFile)
        if ischar(param.detailedInfFile)
            fprintf(fileId,'  detailedInfFile     = %s\n',param.detailedInfFile);
        end
    end
    if ischar(param.sdpaDataFile) && ~isempty(param.sdpaDataFile)
        fprintf(fileId,'  sdpaDataFile        ');
        fprintf(fileId,'= %s\n',param.sdpaDataFile);
    end
    if ischar(param.printFileName) == 1 && ~isempty(param.printFileName)
        fprintf(fileId,'  printFileName       ');
        fprintf(fileId,'= %s\n',param.printFileName);
    elseif isnumeric(param.printFileName) == 1
        if param.printFileName == 0
            fprintf(fileId,'  printFileName       ');
            fprintf(fileId,'= %d\n',param.printFileName);
        end
    end
    %if param.printLevel(1) ~= 2 || param.printLevel(2) ~= 0
    %		fprintf(fileId,'  printLevel       = [%d, %d]',param.printLevel(1), param.printLevel(2));
    %end
    if param.symbolicMath ~=1
        fprintf(fileId,'  symbolicMath        = %d\n', param.symbolicMath);
    end
    if param.mex ~= 1
        fprintf(fileId,'  mex                 = %d\n', param.mex);
    end
    if isfield(param, 'aggressiveSW') && param.aggressiveSW == 1 && param.reduceMomentMatSW ~= 0
        fprintf(fileId,'  aggressiveSW        = %d\n', param.aggressiveSW);
    end
end

if (-1 <= SDPinfo.infeasibleSW) && (SDPinfo.infeasibleSW <= 1)
    noOfSDPblocks = length(SDPinfo.SDPblock);
    if noOfSDPblocks > 0
        aveSDPblock = sum(SDPinfo.SDPblock)/noOfSDPblocks;
        maxSDPblock = max(SDPinfo.SDPblock);
    else
        aveSDPblock = 0;
        maxSDPblock = 0;
    end
    if (param.SDPsolverSW == 1) && (SDPinfo.infeasibleSW == 0)
        if strcmp(param.SDPsolver,'sedumi')
            fprintf(fileId,'# SDP solved by SeDuMi:\n');
        elseif strcmp(param.SDPsolver,'sdpa')
            fprintf(fileId,'# SDP solved by SDPA:\n');
        elseif strcmp(param.SDPsolver,'csdp')
            fprintf(fileId,'# SDP solved by CSDP:\n');
        elseif strcmp(param.SDPsolver,'sdpt3')
            fprintf(fileId,'# SDP solved by SDPT3:\n');
        elseif strcmp(param.SDPsolver,'sdpNAL') || strcmp(param.SDPsolver, 'sdpnal')
            fprintf(fileId,'# SDP solved by sdpNAL:\n');
        end
    elseif (param.SDPsolverSW == 0) && (SDPinfo.infeasibleSW == 0)
        fprintf(fileId,'# Estimated size of SDP to be solved:\n');
    elseif SDPinfo.reduceAMatSW <= 1
        fprintf(fileId,'# SDP relaxation problem:\n');
    end
    if SDPinfo.reduceAMatSW <= 1
        if issparse(SDPinfo.rowSizeA)
            SDPinfo.rowSizeA = full(SDPinfo.rowSizeA);
        end
        if issparse(SDPinfo.colSizeA)
            SDPinfo.colSizeA = full(SDPinfo.colSizeA);
        end
        fprintf(fileId,'  size of A           = [%d,%d]\n',SDPinfo.rowSizeA,SDPinfo.colSizeA);
        if issparse(SDPinfo.nonzerosInA)
            SDPinfo.nonzerosInA = full(SDPinfo.nonzerosInA);
        end
        fprintf(fileId,'  no of nonzeros in A = %d\n',SDPinfo.nonzerosInA);
        if issparse(SDPinfo.noOfLPvariables)
            SDPinfo.noOfLPvariables = full(SDPinfo.noOfLPvariables);
        end
        fprintf(fileId,'  no of LP variables  = %d\n',SDPinfo.noOfLPvariables);
        if issparse(SDPinfo.noOfFreevar)
            SDPinfo.noOfFreevar = full(SDPinfo.noOfFreevar);
        end
        fprintf(fileId,'  no of FR variables  = %d\n',SDPinfo.noOfFreevar);
        if SDPinfo.SOCPblock > 0
            if issparse(SDPinfo.SOCPblock)
                SDPinfo.SOCPblock = full(SDPinfo.SOCPblock);
            end
            fprintf(fileId,'  no of SOCP blocks    = %d\n',SDPinfo.SOCPblock);
        end
        if issparse(noOfSDPblocks)
            noOfSDPblocks = full(noOfSDPblocks);
        end
        fprintf(fileId,'  no of SDP blocks    = %d\n',noOfSDPblocks);
        if issparse(maxSDPblock)
            maxSDPblock = full(maxSDPblock) ;
        end
        fprintf(fileId,'  max size SDP block  = %d\n',maxSDPblock);
        if issparse(aveSDPblock)
            aveSDPblock = full(aveSDPblock);
        end
        fprintf(fileId,'  ave size SDP block  = %6.2e\n',aveSDPblock);
    end
end
if ((param.SDPsolverSW == 1) && (SDPinfo.infeasibleSW == 0)) || (SDPinfo.infeasibleSW == -1)
    if ~isempty(SDPsolverInfo)
        if strcmp(param.SDPsolver,'sedumi')
            fprintf(fileId,'# SeDuMi information:\n');
            fprintf(fileId,'  SeDuMi.pars.eps      = %6.2e\n',param.SDPsolverEpsilon);
            fprintf(fileId,'  SDPsolverInfo.numerr = %d\n',SDPsolverInfo.numerr);
            if SDPsolverInfo.numerr == 1
                fprintf(fileId,'      SeDuMi stopped before SeDuMi.pars.eps = %6.2e is attained.\n',param.SDPsolverEpsilon);
            elseif SDPsolverInfo.numerr >= 2
                fprintf(fileId,'      SeDuMi stopped because of serious numerical difficulties.\n');
            end
            fprintf(fileId,'  SDPsolverInfo.pinf   = %d\n',SDPsolverInfo.pinf);
            if SDPsolverInfo.pinf ~= 0
                fprintf(fileId,'      No primal feasible solution is obtained.\n');
                fprintf(fileId,'      No finite lower bound has been computed for POP objective function.\n');
            end
            fprintf(fileId,'  SDPsolverInfo.dinf   = %d\n',SDPsolverInfo.dinf);
            if SDPsolverInfo.dinf ~= 0
                fprintf(fileId,'      No dual feasible solution is obtained.\n');
                fprintf(fileId,'      POP is probably infeasible.\n');
            end
        elseif strcmp(param.SDPsolver,'sdpa')
            fprintf(fileId,'# SDPA   information:\n');
            fprintf(fileId,'  epsilonStar       = %6.2e\n',param.SDPsolverEpsilon);
            fprintf(fileId,'  epsilonDash       = %6.2e\n',param.SDPsolverEpsilon);
            %            fprintf(fileId,'  p.infeasibility   = %d\n',SDPsolverInfo.pinf);
            if SDPsolverInfo.pinf ~= 0
                fprintf(fileId,'      No primal feasible solution is obtained.\n');
                fprintf(fileId,'      No finite lower bound has been computed for POP objective function.\n');
            end
            %            fprintf(fileId,'  d.infeasibility   = %d\n',SDPsolverInfo.dinf);
            if SDPsolverInfo.dinf ~= 0
                fprintf(fileId,'      No dual feasible solution is obtained.\n');
                fprintf(fileId,'      POP is probably infeasible.\n');
            end
        end
    end
    if (SDPinfo.infeasibleSW == -1) || (SDPsolverInfo.pinf == 0 && SDPsolverInfo.dinf == 0)
        fprintf(fileId,'# Approximate optimal value information:\n');
        if SDPinfo.infeasibleSW == 0
            fprintf(fileId,'  SDPobjValue         = %+13.7e\n',SDPobjValue);
        end
        if ~isempty(POP.xVect)
            if issparse(POP.objValue)
                POP.objValue = full(POP.objValue);
            end
            fprintf(fileId,'  POP.objValue        = %+13.7e\n',POP.objValue);
            relobj = abs(POP.objValue-SDPobjValue)/max(1,abs(POP.objValue));
            if SDPinfo.infeasibleSW == 0
                fprintf(fileId,'  relative obj error  = %+8.3e\n',relobj);
            end
            if issparse(POP.absError)
                POP.absError = full(POP.absError);
            end
            fprintf(fileId,'  POP.absError        = %+8.3e\n',POP.absError);
            if issparse(POP.scaledError)
                POP.scaledError = full(POP.scaledError);
            end
            fprintf(fileId,'  POP.scaledError     ');
            fprintf(fileId,'= %+8.3e\n',POP.scaledError);
        end
    else
        %if SDPsolverInfo.pinf == 0 && SDPsolverInfo.dinf ~= 0
        %    fprintf(fileId,'  Dual SDP relaxation problem is infieasible.\n');
        %    fprintf(fileId,'  The original POP may be also infeasible.\n');
        %elseif SDPsolverInfo.pinf ~= 0 && SDPsolverInfo.dinf == 0
        %    fprintf(fileId,'  Primal SDP problem is infieasible.\n');
        %    fprintf(fileId,'  Increase param.relaxOrder and solve this POP.\n');
        %elseif SDPsolverInfo.pinf ~= 0 && SDPsolverInfo.dinf ~= 0
        %    fprintf(fileId,'  Primal and Dual SDP problems are infieasible.\n');
        %    %fprintf(fileId,'  The original POP may be also infeasible.\n');
        %end
    end
elseif (SDPinfo.infeasibleSW == 0.5)
        if SDPsolverInfo.pinf == 0 && SDPsolverInfo.dinf ~= 0
            fprintf(fileId,'  Dual SDP relaxation problem is infeasible.\n');
            fprintf(fileId,'  The original POP may be also infeasible.\n');
        elseif SDPsolverInfo.pinf ~= 0 && SDPsolverInfo.dinf == 0
            fprintf(fileId,'  Primal SDP problem is infeasible.\n');
            fprintf(fileId,'  Increase param.relaxOrder and solve this POP.\n');
        elseif SDPsolverInfo.pinf ~= 0 && SDPsolverInfo.dinf ~= 0
            fprintf(fileId,'  Primal and Dual SDP problems are infeasible.\n');
        end
elseif (SDPinfo.infeasibleSW == 1)
    fprintf(fileId,'# Primal SDP is infeasible!\n');
    fprintf(fileId,'  No finite lower bound has been computed for the POP objective function!\n');
elseif (SDPinfo.infeasibleSW == 2)
    fprintf(fileId,'# POP is infeasible!\n');
elseif (SDPinfo.infeasibleSW == -2)
    fprintf(fileId,'# Approximate optimal value information:\n');
    fprintf(fileId,'  POP has a unique feasible solution\n');
    if issparse(POP.objValue)
        POP.objValue = full(POP.objValue);
    end
    fprintf(fileId,'  POP.objValue        = %+13.7e\n',POP.objValue);
    if issparse(POP.absError)
        POP.absError = full(POP.absError);
    end
    fprintf(fileId,'  POP.absError        = %+8.3e\n',POP.absError);
    if issparse(POP.scaledError)
        POP.scaledError = full(POP.scaledError);
    end
    fprintf(fileId,'  POP.scaledError     ');
    fprintf(fileId,'= %+8.3e\n',POP.scaledError);
end

if (param.SDPsolverSW == 1) && (SDPinfo.infeasibleSW == 0)
    fprintf(fileId,'# elapsed time:\n');
    versionSW = 210;
    if versionSW == 210 && isfield(elapsedTime,'readData')
        fprintf(fileId,'  elapsedTime.readData    = %8.2f\n',elapsedTime.readData);
        elapsedTime.total = elapsedTime.total + elapsedTime.readData;
    end
    if versionSW == 210 && isfield(elapsedTime,'singleObj')
        fprintf(fileId,'  elapsedTime.singleObj   = %8.2f\n',elapsedTime.singleObj);
        elapsedTime.total = elapsedTime.total + elapsedTime.singleObj;
    end
    fprintf(fileId,'  elapsedTime.conversion  = %8.2f\n',elapsedTime.conversion);
    if strcmp(param.SDPsolver,'sedumi')
        fprintf(fileId,'  elapsedTime.SeDuMi      = %8.2f\n',elapsedTime.SDPsolver);
    elseif strcmp(param.SDPsolver,'sdpa')
        fprintf(fileId,'  elapsedTime.SDPA        = %8.2f\n',elapsedTime.SDPsolver);
    elseif strcmp(param.SDPsolver,'sdpt3')
        fprintf(fileId,'  elapsedTime.SDPT3       = %8.2f\n',elapsedTime.SDPsolver);
    elseif strcmp(param.SDPsolver,'sdpNAL') || strcmp(param.SDPsolver, 'sdpnal')
        fprintf(fileId,'  elapsedTime.sdpNAL      = %8.2f\n',elapsedTime.SDPsolver);
    end
    fprintf(fileId,'  elapsedTime.total       = %8.2f\n',elapsedTime.total);
else % param.SDPsolverSW == 0
    versionSW = 210;
    elapsedTime.total = elapsedTime.conversion;
    fprintf(fileId,'# elapsed time:\n');
    if versionSW == 210 && isfield(elapsedTime,'readData')
        fprintf(fileId,'  elapsedTime.readData    = %8.2f\n',elapsedTime.readData);
        elapsedTime.total = elapsedTime.total + elapsedTime.readData;
    end
    if versionSW == 210 && isfield(elapsedTime,'singleObj')
        fprintf(fileId,'  elapsedTime.singleObj   = %8.2f\n',elapsedTime.singleObj);
        elapsedTime.total = elapsedTime.total + elapsedTime.singleObj;
    end
    fprintf(fileId,'  elapsedTime.conversion  = %8.2f\n',elapsedTime.conversion);
    fprintf(fileId,'  elapsedTime.total       = %8.2f\n',elapsedTime.total);
end

if (SDPinfo.infeasibleSW <= 0) && (param.SDPsolverSW==1) ...
        && (printLevel >= 2) && ~isempty(POP.xVect) % && ~isempty(SDPsolverInfo)
    fprintf(fileId,'# Approximate optimal solution information:\n');
    fprintf(fileId,'  POP.xVect = ');
    lenOFx = length(POP.xVect);
    k = 0;
    for j=1:lenOFx
        if mod(k,5) == 0
            fprintf(fileId,'\n  ');
        end
        k = k+1;
        fprintf(fileId,'%4d:%+13.7e ',j,POP.xVect(j));
    end
    fprintf(fileId,'\n');
elseif (param.SDPsolverSW==1) && isempty(POP.xVect) && ~isempty(SDPsolverInfo)
    if printLevel >= 2 && SDPsolverInfo.pinf == 0 && SDPsolverInfo.dinf == 0
		fprintf(fileId, '## SparsePOP cannot generate an approximate solution.\n');
		%if param.reduceMomentMatSW == 1 && param.reduceAMatSW == 1
		%	fprintf(fileId, '## If you want to generate an approximate solution of this problem,\n'); 
		%	fprintf(fileId, '## please solve this problem with\n');
		%	fprintf(fileId, '## param.reduceMomentMatSW = 0 and param.reduceAMatSW == 0.\n\n');
		%elseif param.reduceMomentMatSW == 1 && param.reduceAMatSW == 0
		%	fprintf(fileId, '## If you want to generate an approximate solution of this problem,\n'); 
		%	fprintf(fileId, '## please solve this problem with param.reduceMomentMatSW = 0.\n\n');
		%elseif param.reduceMomentMatSW == 0 && param.reduceAMatSW == 1
		%	fprintf(fileId, '## If you want to generate an approximate solution of this problem,\n'); 
		%	fprintf(fileId, '## please solve this problem with param.reduceAMatSW = 0.\n\n');
		%end
		if param.reduceMomentMatSW == 1
			fprintf(fileId, '## If you want to generate an approximate solution of this problem,\n'); 
			fprintf(fileId, '## please solve this problem with param.reduceMomentMatSW = 0.\n');
		end
	elseif (printLevel == 1) && (SDPsolverInfo.pinf ~= 0 || SDPsolverInfo.dinf ~= 0)
		fprintf(fileId, '## SparsePOP cannot generate an approximate solution because\n');
		fprintf(fileId, '## the SDP relaxation problem is infeasible or the solution\n');
		fprintf(fileId, '## obtianed by %s is very inaccurate.\n', param.SDPsolver);
    end
end
return
