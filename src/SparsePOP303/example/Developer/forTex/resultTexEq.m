function resultTexEq(param, probNumbers, problemList, compResult,  Esize, frname)

frid = fopen(frname, 'w+');
Psize = floor(50/Esize);
backS = char(92); % char(165);
i = 0;
fprintf(frid,'{%ssmall \n', backS);
header(frid, param, Psize, i);
noProblems = length(probNumbers);
for kkk=1:noProblems
    k = probNumbers(kkk);
    fileName = problemList{k}.name;
    if ~isempty(fileName)
        fileName = getFileName(fileName);
        i = i+1;
        outputResults(frid, compResult, fileName, Esize, i);
    end
    if mod(i,Psize) == 0
        footer(frid, param, Psize, i);
        header(frid, param, Psize, i);
    end
end
footer(frid, param, Psize, i);
fprintf(frid, '}\n');
fclose(frid);
return

function header(frid, param, Psize, i)
backS = char(92); % char(165);
aand = char(38);
fprintf(frid,'%sbegin{table}[htdp]\n',backS);
caption = 'Information%on%SDP%relax.%by%';
caption = strcat(caption, '%',param.SDPsolver,'%(',num2str(ceil(i/Psize)+1), ')');
caption = strrep(caption, '%', blanks(1));
fprintf(frid,'%scaption{%s}\n',backS,caption);
fprintf(frid,'%sbegin{center}\n',backS);
fprintf(frid, '%sbegin{tabular}{|c|cc|cc|cccc|}\n', backS);
fprintf(frid, '%shline\n', backS);
fprintf(frid, 'Problem%s {%ssmall (rSW, eSW)}%s $r$ %s', aand, backS, aand, aand);
fprintf(frid, '[rowA, colA]%s nnzA%s ',aand, aand);
fprintf(frid, 'SDPobj%s POPobj%s absE%s ',aand, aand,aand);
fprintf(frid, '[$%ssec$]%s%s\n', backS, backS, backS);
fprintf(frid, '%shline\n', backS);
return

function outputResults(frid, compResult, fileName, Esize, i)
backS = char(92); % char(165);
aand = char(38);
for j=1:Esize
    if j==1
        fprintf(frid,'{%ssmall %stt %s}',backS,backS,fileName);
    else
        fprintf(frid,'%s',blanks(length(fileName)));
    end
    ro  = full(compResult{j}(i,1));
    rowA= full(compResult{j}(i,2));
    colA= full(compResult{j}(i,3));
    nnzA= full(compResult{j}(i,4));
    cpu = full(compResult{j}(i,5));
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
    fprintf(frid, '%s (%d, %d) %s %d %s ', aand, reduceEqualitiesSW, elimFrSW, aand, ro, aand);
    fprintf(frid, '[%3d, %4d] %s %4d %s',rowA, colA, aand, nnzA, aand);
    fprintf(frid,'%6.5e %s %6.5e %s',objS, aand, objP, aand);
    fprintf(frid,'%2.1e %s %3.2f ',err, aand, cpu);
    fprintf(frid,'%s%s\n',backS,backS);
    if j==Esize
        fprintf(frid, '%shline\n', backS);
    end
end
return

function footer(frid, param, Psize, i)
backS = char(92); % char(165);
fprintf(frid, '%send{tabular}\n', backS);
fprintf(frid, '%send{center}\n', backS);
label = strcat(param.SDPsolver,'_SDPinfo', num2str(ceil(i/Psize)));
fprintf(frid, '%slabel{%s}\n', backS,label);
fprintf(frid, '%send{table}\n', backS);
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
