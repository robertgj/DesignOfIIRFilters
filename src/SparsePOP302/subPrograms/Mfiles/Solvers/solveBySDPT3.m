function [x,y,SDPobjValue, SDPsolverInfo] = solveBySDPT3(fileId, A, b, c, K, param)
fprintf('## convert SeDuMi data to SDPT3 format\n');
%tstart = clock;
[blk,At,C,b] = read_sedumi(A,b,c,K);
fprintf('## Finish the conversion\n');
%fprintf('## time taken = %3.1e\n',etime(clock,tstart));
%if strcmp(param.SDPsolver,'sdpNAL')
if strcmp(param.SDPsolver,'sdpt3')
    OPTIONS.inftol = param.SDPsolverEpsilon;
    OPTIONS.gaptol = param.SDPsolverEpsilon;
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
    [obj,X,y,Z,info,runhist] = sqlp(blk,At,C,b, OPTIONS,[],[],[]);
	SDPsolverInfo = info;
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
    x = [];
    for p=1:size(blk,1)
        pblk = blk(p,:);
        if strcmp(pblk{1},'u')
            x = [x;X{p}];
        elseif strcmp(pblk{1},'l')
            x = [x;X{p}];
        elseif strcmp(pblk{1},'q')
            x = [x;X{p}];        
        elseif strcmp(pblk{1},'r')
            x = [x;X{p}];
        elseif strcmp(pblk{1},'s') && length(pblk{2}) == 1
            x = [x;X{p}(:)];
        elseif strcmp(pblk{1},'s') && length(pblk{2}) > 1
            sidx = 1;
            for i=1:length(pblk{2})
                eidx = sidx + pblk{2}(i)-1;
                idx = sidx:eidx;
                mat = X{p}(idx, idx);
                x = [x;mat(:)];
                sidx = eidx+1;
            end
        end
    end
    %if SDPsolverInfo.pinf == 0 && SDPsolverInfo.dinf == 0
        SDPobjValue = -blktrace(blk,C,X);
    %end
else
    error('## Should set ''param.SDPsolver'' to be your sdp solver.');
end
SDPsolverInfo.cpusec = sum(runhist.cputime);
SDPsolverInfo.numerr = SDPsolverInfo.termcode;

return
