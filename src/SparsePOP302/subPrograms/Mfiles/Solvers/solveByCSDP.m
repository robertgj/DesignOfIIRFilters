function [x, y, SDPobjValue, SDPsolverInfo] = solveByCSDP(fileId, A, b, c, K, param)

if isnumeric(param.SDPsolverOutFile) && (param.SDPsolverOutFile == 0)
	fprintf('- CSDP Start -\n');
end
if fileId > 0
	printLevel = 0;
	writeSeDuMiInputData(fileId,printLevel,A,b,c,K);
end

if isfield(param,'SDPsolverOutFile')
	if ischar(param.SDPsolverOutFile) && ~isempty(param.SDPsolverOutFile)
        %
        % Cannot print the result of sdpt3 into file.
        %
        fprintf('## Cannot print the result of csdp into file.\n');
        fprintf('## Instead, display the result.\n');
        pars.printlevel = 1;
	elseif isnumeric(param.SDPsolverOutFile) && param.SDPsolverOutFile > 0
		%% Output to screen
		pars.printlevel = 1;
	else
		pars.printlevel = 0;
	end
else
	%% No output
	pars.printlevel = 0;
end
% applying the SeDuMi to the SDP
pars.eps = param.SDPsolverEpsilon;
pars.free = 0;
if exist('convertf.m','file') ~= 2
    error('## Should add ''convertf.m'' of CSDP in your MATLAB path.');
else
    [newA,newb,newc,newK] = convertf(A,b,c,K);
end
if ~isfield(newK,'f')
   newK.f = 0; 
end
if ~isfield(newK,'l')
   newK.l = 0; 
end
if ~isfield(newK,'q')
    newK.q = [];
end
if ~isfield(newK,'s')
    newK.s = [];
end
%pars.errors = 1;
[x,y,z,Info] = csdp(newA,newb,newc,newK,pars);
SDPsolverInfo.info = Info;

if isfield(param,'SDPsolverOutFile') && ischar(param.SDPsolverOutFile) && ~isempty(param.SDPsolverOutFile)
    fclose(pars.fid);
end

if isnumeric(param.SDPsolverOutFile) && (param.SDPsolverOutFile == 0)
	fprintf('- CSDP End -\n');
end
if any(isnan(x))
	SDPobjValue = NaN;
else
	SDPobjValue = -newc'*x;
end
if Info ~= 0
    SDPsolverInfo.numerr = 2;
else
    SDPsolverInfo.numerr = 0;
end

s = newA'*y-z;
idx = find(isnan(s));
if any(idx)
	pInf = 1.0e+10;
    	SDPsolverInfo.numerr = 2;
else
	if issparse(s)
		pInf = newb'*y/norm(full(s),'fro');
	else
		pInf = newb'*y/norm(s,'fro');
	end
end
resb = newA*x;
idx = find(isnan(resb));
if any(idx)
	dInf = 1.0e+10;
    	SDPsolverInfo.numerr = 2;
else
	if issparse(resb)
		dInf = -newc'*x/norm(full(resb));
	else
		dInf = -newc'*x/norm(resb);
	end

end


if pInf > 1.0e+8
    SDPsolverInfo.pinf = 1;
else
    SDPsolverInfo.pinf = 0;
end
if dInf > 1.0e+8
    SDPsolverInfo.dinf = 1;
else
    SDPsolverInfo.dinf = 0;
end
    
return
