function printTexMultiple(param, Solvers, probNumbers, problemList, compResult, sedumiInfoVec, Esize);
%

% percent = char(37);
% backS = char(92); % char(165);
% aand = char(38);
% perc = char(37);
% lbrace = char(123);
% rbrace = char(125);
% lbracket = char(91);
% rbracket = char(93);
% pipe = char(124);
str = date;
mainTexMultiple(param,Solvers, str);
for j=2:size(Solvers, 2)
    if ~isempty(Solvers{j})
		solverNames = strcat(Solvers{1}, '_', Solvers{j}, '_');		
		frname = strcat(solverNames, 'numresults', '_', str,'.tex');
		fcname = strcat(solverNames, 'errors',     '_', str,'.tex');
		resultTexMultiple(param, Solvers, probNumbers, problemList, compResult, Esize, frname);
		errorTexMultiple(param, Solvers, probNumbers, problemList, compResult, sedumiInfoVec, Esize, fcname);
		if isfield(param,'POPsolver') && ~isempty(param.POPsolver)
			fpname = strcat(solverNames, 'popresults', '_', str,'.tex');
   			popTexMultiple(param, Solvers, probNumbers, problemList, compResult, Esize, fpname); 
		end
    end
end
return


function makeTexData(param, probNumbers, problemList, compResults, Solvers, solverIdx1, solverIdx2)

lenSolvers = length(Solvers);
if solverIdx2 <1 || solverIdx2 > lenSolvers
    error('## 1 <= solveIdx2 <= %d',lenSolvers);
end

percent = char(37);
backS = char(92); % char(165);
aand = char(38);
perc = char(37);
lbrace = char(123);
rbrace = char(125);
lbracket = char(91);
rbracket = char(93);
pipe = char(124);
fname = strcat(Solvers{solverIdx1},'_',Solvers{solverIdx2},'.tex');
fid = fopen(fname, 'w+');
i = 0;
fprintf(fid,'%s Output from solveExample.m ---> \n',percent);
fprintf(fid,'\n');
fprintf(fid,'{%ssmall \n', backS);
fprintf(fid,'%sbegin{table}[htdp]\n',backS);
caption = strcat(Solvers{solverIdx1},'\_',Solvers{solverIdx2});
fprintf(fid,'%scaption{%s}\n',backS,caption);
fprintf(fid,'%sbegin{center}\n',backS);
if ~isfield(param,'POPsolver') || isempty(param.POPsolver)
    fprintf(fid, '%sbegin{tabular}{|c|ccc|ccc|ccc|}\n', backS);
    fprintf(fid, '%shline\n', backS);
    fprintf(fid,'               &       &                 &         & %smulticolumn{3}{l|}{%s}                       & %smulticolumn{3}{l|}{%s}  %s%s\n',backS,Solvers{solverIdx1},backS,Solvers{solverIdx2},backS,backS);
    fprintf(fid,'Problem        & $r$ &   sizeA         &  nnzA   & eTime  & rObjErr  & absErr   & eTime  & rObjErr  & absErr %s%s\n',backS,backS);
else
    fprintf(fid, '%sbegin{tabular}{|c|ccc|ccc|ccc|}\n', backS);
    fprintf(fid, '%shline\n', backS);
    fprintf(fid,'               &       &                 &         & %smulticolumn{3}{l|}{%s(+fmincon)}             & %smulticolumn{3}{l|}{%s(+fmincon)}  %s%s\n',backS,Solvers{solverIdx1},backS,Solvers{solverIdx2},backS,backS);
    fprintf(fid,'Problem        & $r$ &   sizeA         &  nnzA   & eTime           & rObjErr  & absErr   & eTime           & rObjErr  & absErr %s%s\n',backS,backS);
end
fprintf(fid, '%shline\n', backS);
fprintf(fid,'%s\n',percent);
if ~isfield(param,'POPsolver') || isempty(param.POPsolver)
    sidx1 = 4 + (solverIdx1-1)*3 + 1;
    sidx2 = 4 + (solverIdx2-1)*3 + 1;
else
    sidx1 = 4 + (solverIdx1-1)*4 + 1;
    sidx2 = 4 + (solverIdx2-1)*4 + 1;
end
noProblems = length(probNumbers);
for kkk=1:noProblems
    k = probNumbers(kkk);
    fileName = problemList{k}.name;
    if ~isempty(fileName)
        dotGmsPosition = strfind(fileName,'.gms');
        len = 18;
        if ~isempty(dotGmsPosition)
            fileName = fileName(1:dotGmsPosition-1);
            len = length(fileName);
            if len < 18
                fileName = strcat(fileName,blanks(18-len));
            else
                len = 18;
            end
        end
        i = i+1;
        fileName = strrep(fileName, '_', '\_');
        fprintf(fid,'{%ssmall %s}',backS,fileName);
        fprintf(fid,'%s',blanks(18-len));
        fprintf(fid,'%s %d %s %6d x%7d %s %7d ',aand,full(compResults(i,1)),aand,full(compResults(i,2)),full(compResults(i,3)),aand,full(compResults(i,4)));
        if ~isfield(param,'POPsolver') || isempty(param.POPsolver)
            fprintf(fid,'%s %6.1f %s %+6.1e %s %+6.1e ',aand,full(compResults(i,sidx1)),aand,full(compResults(i,sidx1+1)),aand,full(compResults(i,sidx1+2)));
            fprintf(fid,'%s %6.1f %s %+6.1e %s %+6.1e',aand,full(compResults(i,sidx2)),aand,full(compResults(i,sidx2+2)),aand,full(compResults(i,sidx2+2)));
        else
            fprintf(fid,'%s %6.1f(%6.1f)  %s %+6.1e %s %+6.1e ',aand,full(compResults(i,sidx1)),full(compResults(i,sidx1+1)),aand,full(compResults(i,sidx1+2)),aand,full(compResults(i,sidx1+3)));
            fprintf(fid,'%s %6.1f(%6.1f)  %s %+6.1e %s %+6.1e',aand,full(compResults(i,sidx2)),full(compResults(i,sidx2+1)),aand,full(compResults(i,sidx2+2)),aand,full(compResults(i,sidx2+3)));
        end
        fprintf(fid,'%s%s\n',backS,backS);
    end
end
fprintf(fid, '%shline\n', backS);
fprintf(fid, '%s <--- Output from solveExample.m\n',percent);
fprintf(fid, '%send{tabular}\n', backS);
fprintf(fid, '%send{center}\n', backS);
label = strcat(Solvers{solverIdx1},Solvers{solverIdx2});
fprintf(fid, '%slabel{%s}\n', backS,label);
fprintf(fid, '%send{table}\n', backS);
fprintf(fid, '}\n');
fclose(fid);
return
