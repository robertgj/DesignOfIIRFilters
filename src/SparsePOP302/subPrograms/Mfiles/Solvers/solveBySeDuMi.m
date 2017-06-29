function [x, y, SDPobjValue, SDPsolverInfo] = solveBySeDuMi(fileId, A, b, c, K, param)

if isnumeric(param.SDPsolverOutFile) && (param.SDPsolverOutFile == 0)
	fprintf('- SeDuMi Start -\n');
end
if fileId > 0
	printLevel = 0;
	writeSeDuMiInputData(fileId,printLevel,A,b,c,K);
end

if isfield(param,'SDPsolverOutFile')
	if ischar(param.SDPsolverOutFile) && ~isempty(param.SDPsolverOutFile)
		%% Output to file
		pars.fid = fopen(param.SDPsolverOutFile,'a+');
		fprintf(pars.fid,'\n');
	elseif isnumeric(param.SDPsolverOutFile) && param.SDPsolverOutFile > 0
		%% Output to screen
		pars.fid = 1;
	else
		pars.fid = '';
	end
else
	%% No output
	pars.fid = '';
end
% applying the SeDuMi to the SDP
pars.eps = param.SDPsolverEpsilon;
pars.free = 0;
pars.errors = 1;
[x,y,SDPsolverInfo] = sedumi(A,b,c,K,pars);
if ~isfield(SDPsolverInfo, 'pinf')
	SDPsolverInfo.pinf = 0;
end
if ~isfield(SDPsolverInfo, 'dinf')
	SDPsolverInfo.dinf = 0;
end
if ~isfield(SDPsolverInfo, 'iter')
	SDPsolverInfo.iter = 0;
end
if ~isfield(SDPsolverInfo, 'numerr')
	SDPsolverInfo.numerr = 0;
end
if ~isfield(SDPsolverInfo, 'feasratio')
	SDPsolverInfo.feasratio = 0;
end
if ~isfield(SDPsolverInfo, 'err')
	SDPsolverInfo.err = NaN* ones(1, 6);
end

if isfield(param,'SDPsolverOutFile') && ischar(param.SDPsolverOutFile) && ~isempty(param.SDPsolverOutFile)
    fclose(pars.fid);
end

if isnumeric(param.SDPsolverOutFile) && (param.SDPsolverOutFile == 0)
	fprintf('- SeDuMi End -\n');
end
if isfield(SDPsolverInfo, 'pinf') && SDPsolverInfo.pinf == 1
	SDPobjValue = -Inf;
	if ~isfield(SDPsolverInfo, 'dinf')
		SDPsolverInfo.dinf = 0;
	end
elseif isfield(SDPsolverInfo,'dinf') && SDPsolverInfo.dinf == 1
	SDPobjValue = Inf;
	if ~isfield(SDPsolverInfo, 'pinf')
		SDPsolverInfo.pinf = 0;
	end
else
	SDPobjValue = -c'*x;
end
return
