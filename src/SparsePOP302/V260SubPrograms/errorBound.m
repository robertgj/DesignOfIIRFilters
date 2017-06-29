function [fValue,xCenterMat,zetaValueVect] = errorBound(param,SDPinfo,POP)

if isfield(param,'fValueUbd') && ~isempty(param.fValueUbd)
	objValue = (param.fValueUbd - SDPinfo.objConstant)/SDPinfo.objValScale;
	fValue = param.fValueUbd;
elseif isfield(POP,'objValueL') && ~isempty(POP.objValueL) && isnumeric(POP.objValueL)
	objValue = (POP.objValueL - SDPinfo.objConstant)/SDPinfo.objValScale;
	fValue = POP.objValueL;
elseif isfield(POP,'objValue') && ~isempty(POP.objValue) && isnumeric(POP.objValue)
	objValue = (POP.objValue - SDPinfo.objConstant)/SDPinfo.objValScale;
	fValue = POP.objValue;
else
	fprintf('## Neither of param.fValueUbd, POP.objValueL and POP.objValue is given,\n'),
	fprintf('   so error bound can not be computed\n');
	fValue = [];
	xCenterMat = [];
	zetaValueVect = [];
	return
end

%
% 2011-06-19 H.Waki
% check existence of x_i^2
%deg2Idx = find(sum(SDPinfo.xIdxVec,2) == 2);
%deg2 = SDPinfo.xIdxVec(deg2Idx,:);
%numdeg2 = length(deg2Idx);
%nDim = size(SDPinfo.xIdxVec, 2);
%for i=1:nDim
%    row = 1:numdeg2;
%    col = repmat(i, 1, numdeg2);
%    vec = sparse(row, col, 2, numdeg2, nDim);
%    tmp = sum(abs(deg2 - vec), 2);
%    tmpidx = find(tmp == 0);
%    if isempty(tmpidx)
%		if (param.printLevel(1) >= 1) 
%			fprintf('\n## Cannot apply the computation of error bounds because\n');
%			fprintf('## exist no variable corresponding to x(%d)^2 in the SDP relaxation problem\n', i);
%			fprintf('## To compute error bounds, the following parameter should be set to be zero:\n');
%			if param.SquareOneSW ~= 0
%				fprintf('## param.SquareOneSW\n');
%			end
%			if param.binarySW ~= 0
%				fprintf('## param.binarySW\n');
%			end
%		end
%		if isfield(param,'printFileName') && ~isempty(param.printFileName) && isstr(param.printFileName)
%			fileId = fopen(param.printFileName,'a+');
%			fprintf(fileId, '\n## Cannot apply the computation of error bounds because\n');
%			fprintf(fileId, '## exist no variable corresponding to x(%d)^2 in the SDP relaxation problem\n', i);
%			fprintf(fileId, '## To compute error bounds, the following parameter should be set to be zero:\n');
%			if param.SquareOneSW ~= 0
%				fprintf(fileId, '## param.SquareOneSW\n');
%			end
%			if param.binarySW ~= 0
%				fprintf(fileId, '## param.binarySW\n');
%			end
%			fclose(fileId);
%		end
%		fValue = [];
%		xCenterMat = [];
%		zetaValueVect = [];
%		return
%	end
%end
%
%
% 2011-06-19 H.Waki
% if the dimension of POP is different from the length
% of POP.xVect, then we do not apply the computaiton of 
% error bounds. 
%
% 2011-07-03 H.Waki
% Implemented for reduceAMatSW = 1. We omit this part.
%
%fiedIdx = SDPinfo.fixedVar(:,1);
%dimVar0 = SDPinfo.dimVar0;
%dimVar  = SDPinfo.dimVar;
%idx     = getIdxErr(param, dimVar, dimVar0, fixedIdx);
%Sup1    = sparse(length(idx), dimVar);
%SUP1(:, idx) = speye(length(idx));
%Sup2    = sparse(length(idx), dimVar);
%SUP2(:, idx) = 2*speye(length(idx));
%SUP     = [SUP1;SUP2];
%vidx    = ismember(SUP, SDPinfo.xIdxVec, 'rows');
%if all(vidx) ~= 1
%	if (param.printLevel(1) >= 1) 
%		fprintf('\n## Cannot apply the computation of error bounds because\n');
%		fprintf('## exist no variable corresponding to x(%d) in the SDP relaxation problem\n', i);
%		fprintf('## To compute error bounds, set param.reduceAMatSW = 0.\n');
%	end
%	if isfield(param,'printFileName') && ~isempty(param.printFileName) && isstr(param.printFileName)
%		fileId = fopen(param.printFileName,'a+');
%		fprintf(fileId, '\n## Cannot apply the computation of error bounds because\n');
%		fprintf(fileId, '## exist no variable corresponding to x(%d) in the SDP relaxation problem\n', i);
%		fprintf(fileId, '## To compute error bounds, set param.reduceAMatSW = 0.\n');
%		fclose(fileId);
%	end
%	fValue = [];
%	xCenterMat = [];
%	zetaValueVect = [];
%	return
%end


xCenterMat = [];
zetaValueVect = [];
if iscell(param.errorBdIdx)
	rr = size(param.errorBdIdx,2);
else
	rr = 1;
end
for r = 1:rr
	if iscell(param.errorBdIdx)
		activeIdxSet = param.errorBdIdx{r};
	else
		activeIdxSet = param.errorBdIdx;
	end
	
	[xCenter,zetaValue,infoCoLO] = expEllipsoid(param,SDPinfo,objValue,activeIdxSet);
	xCenterMat = [xCenterMat; xCenter'];
	zetaValueVect = [zetaValueVect; zetaValue];
	%          xCenter'
	%          zetaValue
end

end

function [xCenter,zetaValue,infoCoLO] = expEllipsoid(param,SDPinfo,objValue,activeIdxSet)
% function expEllipsoid(A,b,c,K,J,xIdxVec,objValue,objConstant)
%A = SDPinfo.A;
%b = SDPinfo.b;
%c = SDPinfo.c;
%K = SDPinfo.K;
%J = SDPinfo.J;
A = -(SDPinfo.SeDuMiA)';
b = -SDPinfo.SeDuMic;
c = -SDPinfo.SeDuMib;
K = SDPinfo.SeDuMiK;
K.f = size(SDPinfo.SeDuMiA, 1);
J = SDPinfo.SeDuMiK;
xIdxVec = SDPinfo.xIdxVec;
trans.objConstant = SDPinfo.objConstant;
trans.objValScale = SDPinfo.objValScale;
trans.Amat = SDPinfo.Amat;
trans.bVect = SDPinfo.bVect;

rowPointer = 0;
mDim = size(A,1);
nDim = size(A,2);
dimVar = size(xIdxVec,2);

if (nargin <= 3) || (isempty(activeIdxSet))
    activeIdxSet = [1:dimVar];
end

%
% 2011-07-03 H.Waki
% Implementation for reduceAMatSW = 1
% -->
fixedIdx = [];
fixedVal = [];
origIdx  = 1:SDPinfo.dimVar;
if isfield(SDPinfo, 'fixedVar') && ~isempty(SDPinfo.fixedVar)
	fixedIdx = SDPinfo.fixedVar(:,1); 
	fixedVal = SDPinfo.fixedVar(:,2);
	origIdx = setdiff(1:SDPinfo.dimVar0, fixedIdx');
	idx = 1:SDPinfo.dimVar0;
	idx(origIdx) = 1:length(origIdx);
	idx(fixedIdx)= fixedVal';
	activeIdxSet2   = setdiff(activeIdxSet, fixedIdx');
	%activeIdxSet2
	%fixedIdx
	if isempty(activeIdxSet2)
		fprintf('## All variables in param.errorBdIdx are fixed.\n');
		xCenter = zeros(SDPinfo.dimVar0, 1);
		xCenter(activeIdxSet) = idx(activeIdxSet);
		%xCenter
		zetaValue = 0.0;
		infoCoLO = [];
		return
	else
		activeIdxSet   = idx(activeIdxSet2);
	end
end
% <--


% Check J.f
if isfield(J,'f') && ~isempty(J.f) && J.f > 0
    AFree = A(rowPointer+1:rowPointer+J.f,:);
    bFree = b(rowPointer+1:rowPointer+J.f,:);
    rowPointer = rowPointer + J.f;
else
    AFree = [];
    bFree = [];
    J.f = 0;
end
% Check J.l
if isfield(J,'l') && ~isempty(J.l) && J.l > 0
    ALP = A(rowPointer+1:rowPointer+J.l,:);
    bLP = b(rowPointer+1:rowPointer+J.l,:);
    rowPointer = rowPointer + J.l;
else
    ALP = [];
    bLP = [];
    J.l = 0;
end
% Check J.s
if isfield(J,'s') && ~isempty(J.s)
    ASDP = A(rowPointer+1:mDim,:);
    bSDP = b(rowPointer+1:mDim,:);
    dimSDP = mDim-rowPointer;
else
    ASDP = [];
    bSDP = [];
    J.s = [];
end
%

% Adding c'*x <= objValue to the constraint
% (-c)'*x - (-objValue) >= 0
ALP = [ALP; -c'];
bLP = [bLP; -objValue];
J.l = J.l+1;

A = [AFree;ALP;ASDP];
b = [bFree;bLP;bSDP];
mDim = mDim+1;

if 0 == 1
    [x,y] = sparseCoLO(A,b,c,K,J);
    format long;
    c'*x+objConstant
    format short;
end

SDPsolver = param.SDPsolver;

trans.Amat0 = trans.Amat;
ellipsoidScaling = max(diag(trans.Amat));
trans.Amat = trans.Amat/ellipsoidScaling;

if (strcmp(SDPsolver,'sedumi')) || (strcmp(SDPsolver,'sdpt3'))% || (length(activeIdxSet) < dimVar)
    %SDPsolver = 'sedumi';
    lenActIdxSet = length(activeIdxSet);
    c = sparse(nDim+1,1);
    c(nDim+1,1) = 1;
    xIdxVec2 = xIdxVec';
    xDegVec = sum(xIdxVec2,1);
    for i=activeIdxSet
        %             oneLine = zeros(1,dimVar);
        %             oneLine(1,i) = 2;
        %             [tf,loc0] = ismember(oneLine,xIdxVec,'rows');
        %            c(loc0,1) = -trans.Amat(i,i)^2;
        candIdx = find(xIdxVec2(i,:) == 2);
        ii = find(xDegVec(1,candIdx) == 2);
        loc1 = candIdx(ii);
        c(loc1,1) = -trans.Amat(i,i)^2;
        %             if loc0 ~= loc1
        %                 fprintf('loc0 = %d, loc1 = %d\n',loc0,loc1)
        %             end
    end
    if ~isempty(AFree)
        AFree = [AFree,sparse(size(AFree,1),1)];
    end
    if ~isempty(ALP)
        ALP = [ALP,sparse(size(ALP,1),1)];
    end
    if ~isempty(ASDP)
        ASDP = [ASDP,sparse(size(ASDP,1),1)];
    end
    nDim = nDim+1;
    K.f = K.f+1;
    %%%%%
    ASOCP = sparse(2+lenActIdxSet,nDim);
    ASOCP(1,nDim) = 1;
    ASOCP(2,nDim) = -1;
    ASOCP(3:2+lenActIdxSet,1:dimVar) = 2*trans.Amat(activeIdxSet,:);
    J.q = 2+lenActIdxSet;
    bSOCP = sparse(2+lenActIdxSet,1);
    bSOCP(1:2,1) = [-1;-1];
    A = [AFree; ALP; ASOCP; ASDP];
    b = [bFree; bLP; bSOCP; bSDP];
    %%%%%
    parCoLO.domain = 0;
    parCoLO.range = 0;
    parCoLO.EQorLMI = 2;
    parCoLO.SDPsolver = SDPsolver;
    if strcmp(SDPsolver, 'sedumi')
        if isnumeric(param.SDPsolverOutFile) && (param.SDPsolverOutFile == 0)
            parCoLO.sedumipar.fid = 0;
        else
            parCoLO.sedumipar.fid = 1;
        end
        parCoLO.sedumipar.free = 0;
        % parCoLO.sedumipar.eps = 1.0e-9;
        parCoLO.sedumipar.eps = 1.0e-8;
    elseif strcmp(SDPsolver, 'sdpt3')
        if isnumeric(param.SDPsolverOutFile) && (param.SDPsolverOutFile == 0)
            parCoLO.sdpt3OPTIONS.printlevel = 0;
        else
            parCoLO.sdpt3OPTIONS.printlevel = 3;
        end
        % parCoLO.sdpt3OPTIONS.eps = 1.0e-9;
        parCoLO.sdpt3OPTIONS.eps = 1.0e-8;
    end
    %parCoLO
	if isnumeric(param.SDPsolverOutFile) && (param.SDPsolverOutFile == 0)
		if strcmp(SDPsolver, 'sedumi')
			fprintf('- SeDuMi Start for Computing Error Bounds -\n');
		elseif strcmp(SDPsolver, 'sdpa')
			fprintf('- SDPA Start for Computing Error Bounds -\n');
		elseif strcmp(SDPsolver,'sdpt3')
			fprintf('- SDPT3 Start for Computing Error Bounds -\n');
		end
	end
	[x,y,infoCoLO] = sparseCoLO(A,b,c,K,J,parCoLO);
	if isnumeric(param.SDPsolverOutFile) && (param.SDPsolverOutFile == 0)
		if strcmp(SDPsolver, 'sedumi')
			fprintf('- SeDuMi End for Computing Error Bounds -\n');
		elseif strcmp(SDPsolver, 'sdpa')
			fprintf('- SDPA End for Computing Error Bounds -\n');
		elseif strcmp(SDPsolver,'sdpt3')
			fprintf('- SDPT3 End for Computing Error Bounds -\n');
		end
	end
    %infoCoLO
    %     infoCoLO
    %     infoCoLO.SDPsolver
    if (strcmp(SDPsolver,'sedumi'))
        fprintf('## SDPsolver = %s, pinf = %d, dinf = %d, numerr = %d\n',...
            parCoLO.SDPsolver,infoCoLO.SDPsolver.pinf,infoCoLO.SDPsolver.dinf,infoCoLO.SDPsolver.numerr);
    elseif strcmp(SDPsolver, 'sdpt3')
        fprintf('## SDPsolver = %s, pinf = %2.1e, dinf = %2.1e, termcode = %d\n',...
            parCoLO.SDPsolver,infoCoLO.SDPsolver.pinfeas,infoCoLO.SDPsolver.dinfeas, infoCoLO.SDPsolver.termcode);
    end
else
    oneBlockSize = 40;
    lenActiveIdxSet = length(activeIdxSet);
    if (lenActiveIdxSet <= oneBlockSize)
        c = sparse(nDim+1,1);
        c(nDim+1,1) = 1;
        for i=activeIdxSet
            oneLine = sparse(1,dimVar);
            oneLine(1,i) = 2;
            %full(xIdxVec)
            %full(oneLine)
            [tf,loc] = ismember(oneLine,xIdxVec,'rows');
            %i
            %loc
            %length(c)
            c(loc,1) = -trans.Amat(i,i)^2;
        end
        if ~isempty(AFree)
            AFree = [AFree,sparse(size(AFree,1),1)];
        end
        if ~isempty(ALP)
            ALP = [ALP,sparse(size(ALP,1),1)];
        end
        if ~isempty(ASDP)
            ASDP = [ASDP,sparse(size(ASDP,1),1)];
        end
        nDim = nDim+1;
        K.f = K.f+1;
        
        %
        %             ASDPadd = sparse((1+dimVar)*(1+dimVar),nDim);
        %             bSDPadd = sparse((1+dimVar)*(1+dimVar),1);
        ASDPadd = sparse((1+lenActiveIdxSet)*(1+lenActiveIdxSet),nDim);
        bSDPadd = sparse((1+lenActiveIdxSet)*(1+lenActiveIdxSet),1);
        rowPointer = 0;
        ASDPadd(1,nDim) = 1; % t
        ASDPadd(2:1+lenActiveIdxSet,activeIdxSet) = trans.Amat(activeIdxSet,activeIdxSet);
        rowPointer = rowPointer+1+lenActiveIdxSet;
        kk = 0;
        for k=activeIdxSet
            kk = kk+1;
            ASDPadd(rowPointer+1,k) = trans.Amat(k,k);
            bSDPadd(rowPointer+1+kk,1) = -1;
            rowPointer = rowPointer + 1+lenActiveIdxSet;
        end
        %
        
        ASDP = [ASDP;ASDPadd];
        bSDP = [bSDP; bSDPadd];
        A = [AFree; ALP; ASDP];
        b = [bFree; bLP; bSDP];
        J.s = [J.s,(1+lenActiveIdxSet)];
        parCoLO.domain = 0;
        parCoLO.range = 0;
        parCoLO.EQorLMI = 2;
        parCoLO.SDPsolver = 'sdpa';
        if param.SDPsolverOutFile == 0
            parCoLO.sdpaOPTION.print = '';
        elseif param.SDPsolverOutFile == 1
            parCoLO.sdpOPTION.print = 'display';
        else
            parCoLO.sdpaOPTION.print = param.SDPsolverOutFile;
            outFileIdx = fopen(param.SDPsolverOutFile,'a');
            fprintf(outFileIdx,'\n\n');
            fclose(outFileIdx);
        end
	if isnumeric(param.SDPsolverOutFile) && (param.SDPsolverOutFile == 0)
		if strcmp(SDPsolver, 'sdpa')
			fprintf('- SDPA Start for Computing Error Bounds -\n');
		end
	end
        [x,y,infoCoLO] = sparseCoLO(A,b,c,K,J,parCoLO);
	if isnumeric(param.SDPsolverOutFile) && (param.SDPsolverOutFile == 0)
		if strcmp(SDPsolver, 'sdpa')
			fprintf('- SDPA End for Computing Error Bounds -\n');
		end
	end
        fprintf('## SDPsolver = %s, primalError = %+6.1e, dualError = %+6.1e, pahsevalue = %s\n',...
            parCoLO.SDPsolver,infoCoLO.SDPsolver.primalError,infoCoLO.SDPsolver.dualError, infoCoLO.SDPsolver.phasevalue);
    else
        residual = mod(lenActiveIdxSet,oneBlockSize);
        if residual > 0
            Jadd.s = 1+residual;
        else
            Jadd.s = [];
        end
        Jadd.s = [ones(1,(lenActiveIdxSet-residual)/oneBlockSize)*(1+oneBlockSize),Jadd.s];
        noOfSDPconesAdd = length(Jadd.s);
        c = sparse(nDim+noOfSDPconesAdd,1);
        c(nDim+1:nDim+noOfSDPconesAdd,1) = ones(noOfSDPconesAdd,1);
        for i=activeIdxSet
            oneLine = sparse(1,dimVar);
            oneLine(1,i) = 2;
            [tf,loc] = ismember(oneLine,xIdxVec,'rows');
            c(loc,1) = -trans.Amat(i,i)^2;
        end
        if ~isempty(AFree)
            AFree = [AFree,sparse(size(AFree,1),noOfSDPconesAdd)];
        end
        if ~isempty(ALP)
            ALP = [ALP,sparse(size(ALP,1),noOfSDPconesAdd)];
        end
        if ~isempty(ASDP)
            ASDP = [ASDP,sparse(size(ASDP,1),noOfSDPconesAdd)];
        end
        nDim0 = nDim;
        nDim = nDim+noOfSDPconesAdd;
        K.f = K.f+noOfSDPconesAdd;
        colPointer = 0;
        for p=1:noOfSDPconesAdd
            idxSetAdd = activeIdxSet(colPointer+1:colPointer+Jadd.s(p)-1);
            ASDPadd = sparse(Jadd.s(p)*Jadd.s(p),nDim);
            bSDPadd = sparse(Jadd.s(p)*Jadd.s(p),1);
            rowPointer = 0;
            ASDPadd(1,nDim0+p) = 1; % t
            ASDPadd(2:Jadd.s(p),colPointer+1:colPointer+(Jadd.s(p)-1)) = ...
                trans.Amat(idxSetAdd,idxSetAdd);
            rowPointer = rowPointer +Jadd.s(p);
            kk = 0;
            for k=idxSetAdd
                kk = kk+1;
                ASDPadd(rowPointer+1,k) = trans.Amat(k,k);
                bSDPadd(rowPointer+1+kk,1) = -1;
                rowPointer = rowPointer + Jadd.s(p);
            end
            ASDP = [ASDP;ASDPadd];
            bSDP = [bSDP;bSDPadd];
            colPointer = colPointer + Jadd.s(p) - 1;
        end
        A = [AFree; ALP; ASDP];
        b = [bFree; bLP; bSDP];
        J.s = [J.s,Jadd.s];
        parCoLO.domain = 0;
        parCoLO.range = 0;
        parCoLO.EQorLMI = 2;
        parCoLO.SDPsolver = 'sdpa';
        if param.SDPsolverOutFile == 0
            parCoLO.sdpaOPTION.print = '';
        elseif param.SDPsolverOutFile == 1
            parCoLO.sdpOPTION.print = 'display';
        else
            parCoLO.sdpaOPTION.print = param.SDPsolverOutFile;
            outFileIdx = fopen(param.SDPsolverOutFile,'a');
            fprintf(outFileIdx,'\n\n');
            fclose(outFileIdx);
        end
        [x,y,infoCoLO] = sparseCoLO(A,b,c,K,J,parCoLO);
        fprintf('## SDPsolver = %s, phasevalue = %s, primalError = %+6.1e, dualError = %+6.1e\n',...
            SDPsolver,infoCoLO.SDPsolver.phasevalue,infoCoLO.SDPsolver.primalError,infoCoLO.SDPsolver.dualError);
    end
end

% 2011-07-03 H.Waki
% <--
NewxCenter = trans.Amat0*x(1:dimVar,1)+trans.bVect;
xCenter = zeros(SDPinfo.dimVar0,1);
xCenter(fixedIdx,1) = fixedVal;
xCenter(origIdx, 1) = NewxCenter;

% <--
zetaValue = full((ellipsoidScaling)^2*(-c'*x));

%     fprintf('## zeta = %+6.1e, sqrt(zeta) = %+6.1e, sqrt(zeta)/||xCenter|| = %+6.1e\n',...
%         full(zetaValue),full(sqrt(zetaValue)),full(sqrt(zetaValue)/norm(xCenter')));

end

