function [x, y, SDPobjValue, SDPsolverInfo] = solveBySDPA(A,b,c,K,param)
    OPTION.epsilonStar  = max([param.SDPsolverEpsilon,1.0e-7]);
    OPTION.epsilonDash  = max([param.SDPsolverEpsilon,1.0e-7]);
    if isnumeric(param.SDPsolverOutFile) && (param.SDPsolverOutFile == 1)
        OPTION.print = 'display';
    elseif isnumeric(param.SDPsolverOutFile) && (param.SDPsolverOutFile == 0)
        OPTION.print = '';
    elseif ischar(param.SDPsolverOutFile)
        OPTION.print = param.SDPsolverOutFile;
    end
    OPTION.isDimacs = 1;
    [x,y,SDPsolverInfo] = sedumiwrap(A,b,c,K,[],OPTION);
    %save('testXY.mat','x','y');
    if strcmp(SDPsolverInfo.phasevalue,'pFEAS') || strcmp(SDPsolverInfo.phasevalue,'pdFEAS') || ...
        strcmp(SDPsolverInfo.phasevalue,'pdOPT') || strcmp(SDPsolverInfo.phasevalue,'pFEAS_dINF') || ...
        (SDPsolverInfo.primalError < 1.0e-3)
        SDPsolverInfo.pinf = 0;
    else
        SDPsolverInfo.pinf = 1;
    end
    if strcmp(SDPsolverInfo.phasevalue,'dFEAS') || strcmp(SDPsolverInfo.phasevalue,'pdFEAS') || ...
        strcmp(SDPsolverInfo.phasevalue,'pdOPT') || strcmp(SDPsolverInfo.phasevalue,'dFEAS_pINF') || ...
        (SDPsolverInfo.dualError < 1.0e-3)
        SDPsolverInfo.dinf = 0;
    else
        SDPsolverInfo.dinf = 1;
    end
    SDPobjValue = c'*x;
    SDPsolverInfo.cpusec = SDPsolverInfo.sdpaTime;
    if strcmp(SDPsolverInfo.phasevalue, 'noINFO')
        SDPsolverInfo.numerr = 2;
    elseif ~strcmp(SDPsolverInfo.phasevalue, 'pdOPT')
        SDPsolverInfo.numerr = 1;
    else
        SDPsolverInfo.numerr = 0;
    end
end
