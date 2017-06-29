function errorTexSingle(param, probNumbers, problemList, compResult, sedumiInfoVec, Esize, fcname)

Psize = ceil(50/Esize);
backS = char(92); % char(165);
fcid = fopen(fcname, 'w+');
i = 0;
fprintf(fcid,'{%ssmall \n', backS);
header(fcid, param, Psize, i);
for kkk=1:length(probNumbers)
    k = probNumbers(kkk);
    fileName = problemList{k}.name;
    if ~isempty(fileName)
        i = i+1;
        fileName = getFileName(fileName);
        %%%-->
        outputResults(fcid, param, compResult, sedumiInfoVec, fileName, Esize, i);
        %%%<--
    end
    if mod(i,Psize) == 0
        footer(fcid, param, Psize, i);
        header(fcid, param, Psize, i);
    end
end
footer(fcid, param, Psize, i);
fprintf(fcid, '}\n');
fclose(fcid);
return

function header(fcid, param, Psize, i)
backS = char(92); % char(165);
aand = char(38);
fprintf(fcid,'%sbegin{table}[htdp]\n',backS);
%%%-->
caption = 'Iter,%numerr,%feasratio%and%dimacs%errors%by%';
caption = strcat(caption, param.SDPsolver,'%(',num2str(ceil(i/Psize)+1), ')');
caption = strrep(caption, '%', blanks(1));
%%%<--
fprintf(fcid,'%scaption{%s}\n',backS,caption);
fprintf(fcid,'%sbegin{center}\n',backS);
%%%-->
fprintf(fcid, '%sbegin{tabular}{|c|c|ccc|cccccc|}\n', backS);
fprintf(fcid, '%shline\n', backS);
fprintf(fcid, 'Problem%s $r$ %s Iter%s n.e.%s feasratio%s',aand, aand,aand,aand,aand);
fprintf(fcid, 'err1%s err2%s err3%s ',aand, aand,aand);
fprintf(fcid, 'err4%s err5%s err6 %s%s\n', aand, aand, backS, backS);
%%%<--
fprintf(fcid, '%shline\n', backS);
return

function outputResults(fcid, param, compResult, sedumiInfoVec, fileName, Esize, i)
backS = char(92); % char(165);
aand = char(38);
for j=1:Esize
    if j == 1
        fprintf(fcid,'{%ssmall %stt %s}',backS,backS,fileName);
    else
        fprintf(fcid,'%s',blanks(length(fileName)));
    end
    ro  = full(compResult{j}(i,1));
    iter = sedumiInfoVec{j}(i,1);nerr = sedumiInfoVec{j}(i,2);
    feas = sedumiInfoVec{j}(i,3);
    err1 = sedumiInfoVec{j}(i,4);err2 = sedumiInfoVec{j}(i,5);
    err3 = sedumiInfoVec{j}(i,6);err4 = sedumiInfoVec{j}(i,7);
    err5 = sedumiInfoVec{j}(i,8);err6 = sedumiInfoVec{j}(i,9);
    if strcmp(param.SDPsolver, 'sedumi')
        fprintf(fcid,'%s %d %s %2d %s',aand, ro,aand,iter, aand);
        fprintf(fcid,'%d %s %2.1e %s',nerr, aand, feas, aand);
    elseif strcmp(param.SDPsolver, 'sdpa')
        fprintf(fcid,'%s %d %s %2d %s',aand, ro,aand,iter, aand);
        status = statusOfSDPS(nerr);
        fprintf(fcid,'%s %s %2.1e %s',status, aand, feas, aand);
    end
    fprintf(fcid,'%2.1e %s %2.1e %s %2.1e %s',err1, aand, err2, aand, err3, aand);
    fprintf(fcid,'%2.1e %s %2.1e %s %2.1e ',err4, aand, err5, aand, err6);
    fprintf(fcid,'%s%s\n',backS,backS);
    if j==Esize
        fprintf(fcid, '%shline\n', backS);
    end
end
return


function footer(fcid, param, Psize, i)
backS = char(92); % char(165);
fprintf(fcid, '%send{tabular}\n', backS);
fprintf(fcid, '%send{center}\n', backS);
%%%-->
label = strcat(param.SDPsolver,'_errors', num2str(ceil(i/Psize)));
%%%<--
fprintf(fcid, '%slabel{%s}\n', backS,label);
fprintf(fcid, '%send{table}\n', backS);
return

function fileName = getFileName(name)
dotGmsPosition = strfind(name,'.gms');
len = 15;
if ~isempty(dotGmsPosition)
    minidx = min(len, dotGmsPosition-1);
else
    minidx = min(len, length(name));
end
fileName = name(1:minidx);
fileName = strrep(fileName, '_', '\_');
return

function status = statusOfSDPS(nerr)
if nerr == 0
    status = 'pdOPT';
elseif nerr == 1
    status = 'pdFEAS';
elseif nerr == 2
    status = 'dFEAS';
elseif nerr == 3
    status = 'pFEAS';
elseif nerr == 4
    status = 'pFEAD_dINF';
elseif nerr == 5
    status = 'pINF_dFEAS';
elseif nerr == 6
    status = 'pUNBD';
elseif nerr == 7
    status = 'dUNBD';
elseif nerr == 8
    status = 'pdINF';
elseif nerr == 9
    status = 'noINFO';
else
    status = '??';
end
return
