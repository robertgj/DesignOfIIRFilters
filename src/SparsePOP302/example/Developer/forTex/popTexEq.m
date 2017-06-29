function popTexEq(param, probNumbers, problemList, compResult, Esize, fpname)

Psize = floor(50/Esize);
backS = char(92); % char(165);
fpid = fopen(fpname, 'w+');
i = 0;
fprintf(fpid,'{%ssmall \n', backS);
header(fpid, param, Psize, i);
for kkk=1:length(probNumbers)
    k = probNumbers(kkk);
    fileName = problemList{k}.name;
    if ~isempty(fileName)
        i = i+1;
        fileName = getFileName(fileName);
        %%%-->
        outputResults(fpid, compResult, fileName, Esize, i);
        %%%<--
    end
    if mod(i,Psize) == 0
        footer(fpid, param, Psize, i);
        header(fpid, param, Psize, i);
    end
end
footer(fpid, param, Psize, i);
fprintf(fpid, '}\n');
fclose(fpid);
return

function header(fpid, param, Psize, i)
backS = char(92); % char(165);
aand = char(38);
fprintf(fpid,'%sbegin{table}[htdp]\n',backS);
%%%-->
caption = 'Results%by%POPsolver=';
caption = strcat(caption, param.POPsolver,'%(',num2str(ceil(i/Psize)+1), ')');
caption = strrep(caption, '%', blanks(1));
%%%<--
fprintf(fpid,'%scaption{%s}\n',backS,caption);
fprintf(fpid,'%sbegin{center}\n',backS);
%%%-->
fprintf(fpid, '%sbegin{tabular}{|c|cc|cccc|ccc|}\n', backS);
fprintf(fpid, '%shline\n', backS);
fprintf(fpid, 'Problem%s{%ssmall (rSW, eSW)}%s$r$%sSDPobj%s POPobj%s absE%s ',aand,backS,aand,aand, aand,aand,aand);
fprintf(fpid, '[$%ssec$] %s', backS, aand);
fprintf(fpid, 'POPobjL%s absEL%s ',aand,aand);
fprintf(fpid, '[$%ssec$]%s%s\n', backS, backS, backS);
%%%<--
fprintf(fpid, '%shline\n', backS);
return

function outputResults(fpid, compResult, fileName, Esize, i)
backS = char(92); % char(165);
aand = char(38);
for j=1:Esize
    if j == 1
        fprintf(fpid,'{%ssmall %stt %s}',backS,backS,fileName);
    else
        fprintf(fpid,'%s',blanks(length(fileName)));
    end
    ro  = full(compResult{j}(i,1));
    cpu = full(compResult{j}(i,5));
    cpuL= full(compResult{j}(i,10));
    objPL= full(compResult{j}(i,13));
    errL= full(compResult{j}(i,12));
    objS= full(compResult{j}(i,6));
    objP= full(compResult{j}(i,7));
    err = full(compResult{j}(i,9));
	if j == 1
		reduceEqualitiesSW = 0;
		elimFrSW = 0;
	elseif j == 2
		reduceEqualitiesSW = 0;
		elimFrSW = 1;
	elseif j == 3
		reduceEqualitiesSW = 1;
		elimFrSW = 0;
	elseif j == 4
		reduceEqualitiesSW = 1;
		elimFrSW = 1;
	elseif j == 5
		reduceEqualitiesSW = 2;
		elimFrSW = 0;
	elseif j == 6
		reduceEqualitiesSW = 2;
		elimFrSW = 1;
	end
    fprintf(fpid, '%s (%d, %d) %s %d %s ', aand, reduceEqualitiesSW, elimFrSW, aand, ro, aand);
    fprintf(fpid,'%6.5e %s %6.5e %s',objS, aand, objP, aand);
    fprintf(fpid,'%2.1e %s %3.2f %s',err, aand, cpu,aand);
    fprintf(fpid,'%6.5e %s ',objPL, aand);
    fprintf(fpid,'%2.1e %s %3.2f ',errL, aand, cpuL);
    fprintf(fpid,'%s%s\n',backS,backS);
    if j==Esize
        fprintf(fpid, '%shline\n', backS);
    end
end
return


function footer(fpid, param, Psize, i)
backS = char(92); % char(165);
fprintf(fpid, '%send{tabular}\n', backS);
fprintf(fpid, '%send{center}\n', backS);
%%%-->
label = strcat(param.SDPsolver,'_POPsolver', num2str(ceil(i/Psize)));
%%%<--
fprintf(fpid, '%slabel{%s}\n', backS,label);
fprintf(fpid, '%send{table}\n', backS);
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
