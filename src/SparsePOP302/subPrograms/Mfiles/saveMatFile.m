function Newparam = saveMatFile(A, b, c, K, xIdxVec,param)

Newparam = param;
if isfield(param,'matFile') && ~isempty(param.matFile) && isfield(param, 'developmentSW') && param.developmentSW == 3
    save(param.matFile,'A','b','c','K', 'xIdxVec');
    if param.scalingSW == 1
        fprintf('## Saved the scaled SDP relaxation problem (A,b,c,K) in %s\n',param.matFile);
    else
        fprintf('## Saved the SDP relaxation problem (A,b,c,K) in %s\n',param.matFile);
    end
    Newparam.SDPsolverSW = 0;
end

return
