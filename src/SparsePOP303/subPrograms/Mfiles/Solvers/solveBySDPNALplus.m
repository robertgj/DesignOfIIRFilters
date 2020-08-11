function [x,y,s,SDPobjValue, SDPsolverInfo] = solveBySDPNALplus(A, b, c, K, param)
    fprintf('## convert SeDuMi data to SDPT3 format\n');
    %tstart = clock;
    % smallbkldim = 2; 
    % smallbkldim = 40;
    % smallbkldim = 10;
    smallbkldim = 50;
    [blk,At,C,b,perm] = read_sedumi(A,b,c,K,smallbkldim);
    fprintf('## Finish the conversion\n');
    %fprintf('## time taken = %3.1e\n',etime(clock,tstart));
    %if strcmp(param.SDPsolver,'sdpNAL')
    % if strcmp(param.SDPsolver,'sdpnalplus')
    %     OPTIONS.inftol = param.SDPsolverEpsilon;
    %     OPTIONS.gaptol = param.SDPsolverEpsilon;
    %         plotyes  = 0;
    %         precond  = 1;
    %         proximal = 1;
    %         scale_data  = 2;
    %         OPTIONS.scale_data = scale_data;
    %         OPTIONS.plotyes  = plotyes;
    %         OPTIONS.proximal = proximal;
    %         OPTIONS.precond  = precond;
    %%%%%%%%%%
    if isfield(param,'SDPsolverMaxIter')
        OPTIONS.maxiter = param.SDPsolverMaxIter;
    end
    if isfield(param,'SDPsolverMaxTime')
        OPTIONS.maxtime = param.SDPsolverMaxTime;
    end
    if isfield(param,'SDPsolverEpsilon')
        OPTIONS.tol = param.SDPsolverEpsilon;
    end
    %%%%%%%%%%
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
    
    %     OPTIONS.printlevel = 2;
    %     OPTIONS.gaptol     = 1e-8;
    %     OPTIONS.inftol     = 1e-8;
    %     OPTIONS.steptol    = 1e-6;
    %     OPTIONS.maxit      = 100;
    
    % OPTIONS.tol = 1e-8;
    
    % [obj,X,y,Z,info,runhist] = sdpnal(blk,At,C,b, OPTIONS);
    % [obj,X,s,y,Z1,Z2,y2,v,info,runhist] = ...
    %         sdpnalplus(blk,AA,C,b,L,U,BB,l,u,OPTIONS,X,s,y,Z1,Z2,y2,v)
    startingTime = tic;
    %     [~, X, ~, y, S, ~, ~, ~, info, runhist] ...
    %         = sdpnalplus(blk,At,C,b,[],[],[],[],[],OPTIONS); % specify 0,1?
    L = -1e6;
    [~, X, ~, y, S, ~, ~, ~, info, runhist] ...
        = sdpnalplus(blk,At,C,b,L,[],[],[],[],OPTIONS); % specify 0,1?
    SDPsolverInfo = info;
    %if SDPsolverInfo.pinf == 0 && SDPsolverInfo.dinf == 0
    SDPobjValue = blktrace(blk,C,X);
    %end
    
    %fprintf('\nSDPsolverInfo.totaltime=%3.2e, elapsed time = %3.2e\n\n',...
    %    SDPsolverInfo.totaltime,toc(startingTime));
    SDPsolverInfo.elapsedTime = toc(startingTime);
    
    if ~isfield(info,'pinfeas') || info.pinfeas < 10^8
        SDPsolverInfo.pinf = 0;
    else
        SDPsolverInfo.pinf = 1;
    end
    if ~isfield(info,'dinfeas') || info.dinfeas < 10^8
        SDPsolverInfo.dinf = 0;
    else
        SDPsolverInfo.dinf = 1;
    end
    
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
    %%
    [x] = Xsdpt3Toxsedumi(X,blk,perm,startIdx);
    [s] = Xsdpt3Toxsedumi(S,blk,perm,startIdx);
    %%
    %     else
    %         error('## Should set ''param.SDPsolver'' to be your sdp solver.');
    %     end
    SDPsolverInfo.cpusec = SDPsolverInfo.totaltime; % sum(runhist.cputime);
    SDPsolverInfo.numerr = SDPsolverInfo.termcode;
end

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
