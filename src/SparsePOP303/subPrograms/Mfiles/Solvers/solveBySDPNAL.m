function [x,y,SDPobjValue, SDPsolverInfo] = solveBySDPNAL(A, b, c, K, param)
    fprintf('## convert SeDuMi data to SDPT3 format\n');
    %tstart = clock;
    [blk,At,C,b,perm] = read_sedumi(A,b,c,K);
    fprintf('## Finish the conversion\n');
    %fprintf('## time taken = %3.1e\n',etime(clock,tstart));
    %if strcmp(param.SDPsolver,'sdpNAL')
    %   if strcmp(param.SDPsolver,'sdpnal')
    %%%%% 2018/04/24 Kojima --->
    if isfield(param,'SDPsolverMaxIter')
        OPTIONS.maxiter = param.SDPsolverMaxIter;
    end
    %         if isfield(param,'SDPsolverMaxTime')
    %             OPTIONS.maxtime = param.SDPsolverMaxTime;
    %         end
    if isfield(param,'SDPsolverEpsilon')
        OPTIONS.tol = param.SDPsolverEpsilon;
    end
    %%%%% 2018/04/24 Kojima --->
    if isfield(param,'SDPsolverOutFile')
        if isnumeric(param.SDPsolverOutFile) && (param.SDPsolverOutFile == 1)
            OPTIONS.printlevel = 3;
        elseif isnumeric(param.SDPsolverOutFile) && (param.SDPsolverOutFile == 0)
            OPTIONS.printlevel = 1;
        elseif ischar(param.SDPsolverOutFile)
            %
            % Cannot print the result of sdpt3 into file.
            %
            %OPTIONS.printlevel = param.SDPsolverOutFile;
            fprintf('## Cannot print the result of sdpt3 into file.\n');
            fprintf('## Instead, display the result.\n');
            OPTIONS.printlevel = 3;
        end
    else
        OPTIONS.printlevel = 1;
    end
    %%%% <--- 2018/04/24 Kojima
    
    plotyes  = 0;
    precond  = 1;
    proximal = 1;
    scale_data  = 2;
    OPTIONS.scale_data = scale_data;
    OPTIONS.plotyes  = plotyes;
    OPTIONS.proximal = proximal;
    OPTIONS.precond  = precond;
    
    [obj,X,y,Z,info,runhist] = sdpnal(blk,At,C,b, OPTIONS);
    SDPsolverInfo = info;
    %if SDPsolverInfo.pinf == 0 && SDPsolverInfo.dinf == 0
    SDPobjValue = blktrace(blk,C,X);
    %end
    if info.pinfeas < 10^8
        SDPsolverInfo.pinf = 0;
    else
        SDPsolverInfo.pinf = 1;
    end
    if info.dinfeas < 10^8
        SDPsolverInfo.dinf = 0;
    else
        SDPsolverInfo.dinf = 1;
    end
    
    %%%%% 2018/04/24 Kojima --->
    s0 = 1;
    if isfield(K,'f') && K.f > 0
        s0 = s0 + K.f;
    end
    if isfield(K,'l') && K.l > 0
        s0 = s0 + K.l;
    end
    
    startIdx = [s0,K.s .* K.s];
    for i=2:length(startIdx)
        startIdx(i) = startIdx(i-1)+startIdx(i);
    end
    
    [x] = Xsdpt3Toxsedumi(X,blk,perm,startIdx);
    [s] = Xsdpt3Toxsedumi(Z,blk,perm,startIdx);
    %%%% <--- 2018/04/24 Kojima
    
    %     else
    %         error('## Should set ''param.SDPsolver'' to be your sdp solver.');
    %     end
    SDPsolverInfo.cpusec = sum(runhist.cputime);
    SDPsolverInfo.numerr = SDPsolverInfo.termcode;

end

%%%%% 2018/04/24 Kojima --->
function [x] = Xsdpt3Toxsedumi(X,blk,perm,startIdx)
    x = zeros(startIdx(end)-1,1);
    rstart = 1;
    for p=1:size(blk,1)
        pblk = blk(p,:);
        if strcmp(pblk{1},'u') || strcmp(pblk{1},'l') || strcmp(pblk{1},'q') || strcmp(pblk{1},'r')
            rend = rstart + length(X{p})-1;
            x(rstart:rend) = X{p};
            rstart = rend + 1; 
        elseif strcmp(pblk{1},'s') && length(pblk{2}) == 1
            rstart = startIdx(perm{p});
            rend = startIdx(perm{p}+1)-1;
            x(rstart:rend) = X{p}(:);
            % x = [x;X{p}(:)];
        elseif strcmp(pblk{1},'s') && length(pblk{2}) > 1
            sidx = 1;
            for i=1:length(pblk{2})
                eidx = sidx + pblk{2}(i)-1;
                idx = sidx:eidx;
                mat = X{p}(idx, idx);
                % x = [x;mat(:)];
                rstart = startIdx(perm{p}(i)); 
                rend = rstart+length(mat(:))-1; 
                x(rstart:rend) = mat(:); 
                sidx = eidx+1;
            end
        end
    end
end
%%%% <--- 2018/04/24 Kojima 

