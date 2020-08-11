function printTex(param, probNumbers, problemList, compResult, sedumiInfoVec, Esize)

Psize = 10;
percent = char(37);
backS = char(92); % char(165);
aand = char(38);
perc = char(37);
lbrace = char(123);
rbrace = char(125);
lbracket = char(91);
rbracket = char(93);
pipe = char(124);
str = date;
fname = strcat(param.SDPsolver,'_results', '_', str,'.tex');
fid = fopen(fname, 'w+');
fcname = strcat(param.SDPsolver,'_errors', '_', str,'.tex');
fcid = fopen(fcname, 'w+');
frname = strcat(param.SDPsolver,'_numresults', '_', str,'.tex');
frid = fopen(frname, 'w+');
fprintf(fid, '\\documentclass[10pt]{article}\n');
fprintf(fid, '\\setlength{\\evensidemargin}{0cm}\n');
fprintf(fid, '\\setlength{\\oddsidemargin}{0cm}\n');
fprintf(fid, '\\setlength{\\textwidth}{6.45in}\n');
fprintf(fid, '\\setlength{\\textheight}{9.2in}\n');
fprintf(fid, '\\setlength{\\topmargin}{0.5in}\n');
fprintf(fid, '\\setlength{\\headheight}{0in}\n');
fprintf(fid, '\\setlength{\\headsep}{0in}\n');
fprintf(fid, '\\setlength{\\topskip}{0in}\n');
fprintf(fid, '\\begin{document}\n');
fprintf(fid, '\\pagestyle{empty}\n');

i = 0;
fprintf(fid,'\n');
fprintf(fid,'We used the following parameters:\n');
fprintf(fid, '%sbegin{itemize}\n', backS);
fprintf(fid, '%sitem {%stt sparseSW}: %d\n', backS, backS,param.sparseSW);
fprintf(fid, '%sitem {%stt multiCliquesFactpr}: %d\n', backS, backS,param.multiCliquesFactor);
fprintf(fid, '%sitem {%stt boundSW}: %d\n', backS, backS,param.boundSW);
fprintf(fid, '%sitem {%stt reduceMomentMatSW}: %d\n', backS, backS,param.reduceMomentMatSW);
fprintf(fid, '%sitem {%stt complementaritySW}: %d\n', backS, backS,param.complementaritySW);
fprintf(fid, '%sitem {%stt binarySW}: %d\n', backS,backS,param.binarySW);
fprintf(fid, '%sitem {%stt SquareOneSW}: %d\n', backS,backS,param.SquareOneSW);
fprintf(fid, '%sitem {%stt reduceAMatSW}: %d\n', backS,backS,param.reduceAMatSW);
%fprintf(fid, '%sitem {%stt elimFrSW}: %d\n', backS,backS,param.elimFrSW);
fprintf(fid, '%sitem {%stt mex}: %d\n', backS,backS,param.mex);
fprintf(fid, '%send{itemize}\n',backS);
fprintf(fid, '%sinput{%s}', backS, fcname);
fprintf(fid, '%sinput{%s}', backS, frname);


fprintf(fcid,'{%ssmall \n', backS);
fprintf(fcid,'%sbegin{table}[htdp]\n',backS);
caption = 'Iter,%numerr,%feasratio%and%dimacs%errors%by%';
caption = strcat(caption, param.SDPsolver,'%(',num2str(ceil(i/25)+1), ')');
caption = strrep(caption, '%', blanks(1));
fprintf(fcid,'%scaption{%s}\n',backS,caption);
fprintf(fcid,'%sbegin{center}\n',backS);
fprintf(fcid, '%sbegin{tabular}{|c|c|ccc|cccccc|}\n', backS);
fprintf(fcid, '%shline\n', backS);
fprintf(fcid, 'Problem%s SW %s Iter%s n.e.%s feasratio%s',aand, aand,aand,aand,aand);
fprintf(fcid, 'err1%s err2%s err3%s ',aand, aand,aand);
fprintf(fcid, 'err4%s err5%s err6 %s%s\n', aand, aand, backS, backS);
fprintf(fcid, '%shline\n', backS);
noProblems = length(probNumbers);
for kkk=1:noProblems
	k = probNumbers(kkk);
	fileName = problemList{k}.name;
	if ~isempty(fileName)
		dotGmsPosition = strfind(fileName,'.gms');
		len = 10;
		if ~isempty(dotGmsPosition)
			fileName = fileName(1:dotGmsPosition-1);
		else
			minidx = min(10, length(fileName));
			fileName = fileName(1:minidx);
		end
		i = i+1;
		fileName = strrep(fileName, '_', '\_');
		for j=1:Esize
			if j==1
				fprintf(fcid,'{%ssmall %stt %s}',backS,backS,fileName);
			else
				fprintf(fcid,'            ');
			end
			fprintf(fcid,'%s',blanks(10-len));
			ro  = full(compResult{j}(i,1));
			iter = sedumiInfoVec{j}(i,1);
			nerr = sedumiInfoVec{j}(i,2);
			feas = sedumiInfoVec{j}(i,3);
			err1 = sedumiInfoVec{j}(i,4);
			err2 = sedumiInfoVec{j}(i,5);
			err3 = sedumiInfoVec{j}(i,6);
			err4 = sedumiInfoVec{j}(i,7);
			err5 = sedumiInfoVec{j}(i,8);
			err6 = sedumiInfoVec{j}(i,9);
			if j == 1
				reduceEqualitiesSW = 0;
				elimFrSW = 0;
			elseif j == 2
				reduceEqualitiesSW = 1;
				elimFrSW = 0;
			elseif j == 3
				reduceEqualitiesSW = 1;
				elimFrSW = 1;
			elseif j == 4
				reduceEqualitiesSW = 2;
				elimFrSW = 0;
			elseif j == 5
				reduceEqualitiesSW = 2;
				elimFrSW = 1;
			end
			fprintf(fcid,'%s (%d, %d) %s %2d %s %d %s %3.2e %s',aand,reduceEqualitiesSW, elimFrSW,aand,iter, aand, nerr, aand, feas, aand);
			fprintf(fcid,'%2.1e %s %2.1e %s %2.1e %s',err1, aand, err2, aand, err3, aand);
			fprintf(fcid,'%2.1e %s %2.1e %s %2.1e ',err4, aand, err5, aand, err6);
			fprintf(fcid,'%s%s\n',backS,backS);
			if j == Esize 
				fprintf(fcid, '%shline\n', backS);
			end
		end
	end
	if mod(i,Psize) == 0	
		fprintf(fcid, '%send{tabular}\n', backS);
		fprintf(fcid, '%send{center}\n', backS);
		label = strcat(param.SDPsolver,'_errors', num2str(ceil(i/Psize)+1));
		fprintf(fcid, '%slabel{%s}\n', backS,label);
		fprintf(fcid, '%send{table}\n', backS);
		fprintf(fcid,'%sbegin{table}[htdp]\n',backS);
		caption = 'Iter,%numerr,%feasratio%and%dimacs%errors%by%';
		caption = strcat(caption, param.SDPsolver,'%(',num2str(ceil(i/25)+1), ')');
		caption = strrep(caption, '%', blanks(1));
		fprintf(fcid,'%scaption{%s}\n',backS,caption);
		fprintf(fcid,'%sbegin{center}\n',backS);
		fprintf(fcid, '%sbegin{tabular}{|c|c|ccc|cccccc|}\n', backS);
		fprintf(fcid, '%shline\n', backS);
		fprintf(fcid, 'Problem%s SW %s Iter%s n.e.%s feasratio%s',aand, aand,aand,aand,aand);
		fprintf(fcid, 'err1%s err2%s err3%s ',aand, aand,aand);
		fprintf(fcid, 'err4%s err5%s err6 %s%s\n', aand, aand, backS, backS);
		fprintf(fcid, '%shline\n', backS);
	end
end
fprintf(fcid, '%send{tabular}\n', backS);
fprintf(fcid, '%send{center}\n', backS);
label = strcat(param.SDPsolver,'_errors', num2str(ceil(i/Psize)+1));
fprintf(fcid, '%slabel{%s}\n', backS,label);
fprintf(fcid, '%send{table}\n', backS);
fprintf(fcid, '}\n');

if ~isfield(param,'POPsolver') || isempty(param.POPsolver)
	i = 0;
	fprintf(frid,'{%ssmall \n', backS);
	fprintf(frid,'%sbegin{table}[htdp]\n',backS);
	caption = 'Information%on%SDP%relax.%by%';
	caption = strcat(caption, '%',param.SDPsolver,'%(',num2str(ceil(i/Psize)+1), ')');
	caption = strrep(caption, '%', blanks(1));
	fprintf(frid,'%scaption{%s}\n',backS,caption);
	fprintf(frid,'%sbegin{center}\n',backS);
	fprintf(frid, '%sbegin{tabular}{|c|cc|cc|cccc|}\n', backS);
	fprintf(frid, '%shline\n', backS);
	fprintf(fid, 'Problem%s SW %s r.o.%s ', aand, aand, aand); 
	fprintf(frid, '[rowA, colA]%s nnzA%s ',aand, aand);
	fprintf(frid, 'SDPobj%s POPobj%s absE%s ',aand, aand,aand);
	fprintf(frid, '[$%ssec$]%s%s\n', backS, backS, backS);
	fprintf(frid, '%shline\n', backS);
	noProblems = length(probNumbers);
	for kkk=1:noProblems
		k = probNumbers(kkk);
		fileName = problemList{k}.name;
		dotGmsPosition = strfind(fileName,'.gms');
		if ~isempty(dotGmsPosition)
			fileName = fileName(1:dotGmsPosition-1);
		else
			minidx = min(10, length(fileName));
			fileName = fileName(1:minidx);
		end
		len = 10;
		i = i+1;
		fileName = strrep(fileName, '_', '\_');
		for j=1:Esize
			if j==1
				fprintf(frid,'{%ssmall %stt %s}',backS,backS,fileName);
			else
				fprintf(frid,'            ');
			end
			fprintf(frid,'%s',blanks(10-len));

			ro  = full(compResult{j}(i,1));
			rowA= full(compResult{j}(i,2));
			colA= full(compResult{j}(i,3));
			nnzA= full(compResult{j}(i,4));
			cpu = full(compResult{j}(i,5));
			objS= full(compResult{j}(i,6));
			objP= full(compResult{j}(i,7));
			err = full(compResult{j}(i,8));
			if j == 1
				reduceEqualitiesSW = 0;
				elimFrSW = 0;
			elseif j == 2
				reduceEqualitiesSW = 1;
				elimFrSW = 0;
			elseif j == 3
				reduceEqualitiesSW = 1;
				elimFrSW = 1;
			elseif j == 4
				reduceEqualitiesSW = 2;
				elimFrSW = 0;
			elseif j == 5
				reduceEqualitiesSW = 2;
				elimFrSW = 1;
			end
			fprintf(frid, '%s (%d, %d) %s %d %s ', aand, reduceEqualitiesSW, elimFrSW, aand, ro, aand); 
			fprintf(frid, '[%3d, %4d] %s %4d %s',rowA, colA, aand, nnzA, aand);
			fprintf(frid,'%6.5e %s %6.5e %s %2.1e %s %3.2f ',objS, aand, objP, aand, err, aand, cpu);
			fprintf(frid,'%s%s\n',backS,backS);
			if j == Esize 
				fprintf(frid, '%shline\n', backS);
			end
		end
		if mod(i,Psize) == 0	
			fprintf(frid, '%send{tabular}\n', backS);
			fprintf(frid, '%send{center}\n', backS);
			label = strcat(param.SDPsolver,'_SDPinfo', num2str(ceil(i/Psize)+1));
			fprintf(frid, '%slabel{%s}\n', backS,label);
			fprintf(frid, '%send{table}\n', backS);
			fprintf(frid,'%sbegin{table}[htdp]\n',backS);
			caption = 'Information%on%SDP%relax.%by%';
			caption = strcat(caption, '%',param.SDPsolver,'%(',num2str(ceil(i/Psize)+1), ')');
			caption = strrep(caption, '%', blanks(1));
			fprintf(frid,'%scaption{%s}\n',backS,caption);
			fprintf(frid,'%sbegin{center}\n',backS);
			fprintf(frid, '%sbegin{tabular}{|c|cc|cc|cccc|}\n', backS);
			fprintf(frid, '%shline\n', backS);
			fprintf(frid, 'Problem%s SW %s r.o.%s ', aand, aand, aand); 
			fprintf(frid, '[rowA, colA]%s nnzA%s ',aand, aand);
			fprintf(frid, 'SDPobj%s POPobj%s absE%s ',aand, aand,aand);
			fprintf(frid, '[$%ssec$]%s%s\n', backS, backS, backS);
			fprintf(frid, '%shline\n', backS);
		end
	end
end
fprintf(frid, '%send{tabular}\n', backS);
fprintf(frid, '%send{center}\n', backS);
label = strcat(param.SDPsolver,'_SDPinfo', num2str(ceil(i/Psize)+1));
fprintf(frid, '%slabel{%s}\n', backS,label);
fprintf(frid, '%send{table}\n', backS);
fprintf(frid, '}\n');

fprintf(fid, '\\end{document}\n');
fclose(fid);
fclose(fcid);
fclose(frid);
return
