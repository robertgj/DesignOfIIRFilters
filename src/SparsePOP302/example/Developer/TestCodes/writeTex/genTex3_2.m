function genTex3_2(param,CompResult, InfoSDP, Errors)
iname = 'sec3.2_table.tex';
gid   = fopen(iname, 'w+');
genTable(gid, param, CompResult, InfoSDP, Errors);

solver = 'sedumi';
iname = strcat('sec3.2_info_table_', solver, '.tex');
fid   = fopen(iname, 'w+');
genInfoTables(fid, param, CompResult, InfoSDP, Errors, solver);
solver = 'sdpt3';
iname = strcat('sec3.2_info_table_', solver, '.tex');
fid   = fopen(iname, 'w+');
genInfoTables(fid, param, CompResult, InfoSDP, Errors, solver);

solver = 'sedumi';
ename = strcat('sec3.2_error_table_', solver, '.tex');
eid   = fopen(ename, 'w+');
genErrorTables(eid, param, CompResult, InfoSDP, Errors, solver);
solver = 'sdpt3';
ename = strcat('sec3.2_error_table_', solver, '.tex');
eid   = fopen(ename, 'w+');
genErrorTables(eid, param, CompResult, InfoSDP, Errors, solver);

fclose(gid);
fclose(fid);
fclose(eid);
return

function genTable(fid, param, CompResult, InfoSDP, Errors)
bS = char(92);
aand = char(38);
fprintf(fid, '%sbegin{table}[htdp]\n', bS);
caption = strcat('Numerical%results%on%SDP%relaxation%problems%in%Subsection%3.2%');
caption = strrep(caption, '%', blanks(1));
fprintf(fid, '%scaption{%s}\n', bS,caption);
fprintf(fid, '%sbegin{center}\n', bS);
fprintf(fid, '{%sfootnotesize\n', bS);
fprintf(fid, '%sbegin{tabular}{|c|c|l|l|}\n', bS);
fprintf(fid, '%shline\n', bS);
fprintf(fid, '%smulticolumn{2}{|c|}{}%sLasserre%sAdaptive SOS%s%s\n', bS, aand, aand, bS, bS);
fprintf(fid, '%shline\n', bS);
fprintf(fid, '$r$ %s Software', aand);
fprintf(fid, '%s (SDPobj, POPobj$|$ $%sepsilon_{%smbox{obj}}, %sepsilon_{%smbox{feas}}$ $|$ [$%ssec$])', aand, bS, bS, bS, bS, bS);
fprintf(fid, '%s (SDPobj, POPobj$|$ $%sepsilon_{%smbox{obj}}, %sepsilon_{%smbox{feas}}$ $|$ [$%ssec$])%s%s\n', aand, bS, bS, bS, bS, bS, bS, bS);
fprintf(fid, '%shline\n', bS);

[L, M, N] = size(CompResult);
for i=1:N
        ro  = i;%full(param.relaxOrder);
	for solvers = 1:L
		if solvers == 1
			fprintf(fid, '%d %s SeDuMi', ro, aand);
		elseif solvers == 2
			fprintf(fid, '%sSDPT3', aand);
		elseif sovlers == 3	
			fprintf(fid, '%sSDPA', aand);
		end
		for j=1:M
		        objS= full(CompResult{solvers, j, i}.SDPobj);
        		objP= full(CompResult{solvers, j, i}.POPobj);
			objerr=full(Errors{solvers, j, i}.objerr);
        		err = full(Errors{solvers, j, i}.absE);
		        cpu = full(CompResult{solvers, j, i}.cpuTime);
        		fprintf(fid, '%s (%6.5e, %6.5e, $|$ %2.1e, %2.1e $|$ %3.2f)',aand, objS, objP, objerr, err, cpu);
		end
        	fprintf(fid, '%s%s\n',bS,bS);
	end
	fprintf(fid, '%shline\n', bS);
end	
fprintf(fid, '%send{tabular}\n', bS);
fprintf(fid, '}\n');
fprintf(fid, '%slabel{subsec3.2_table}\n', bS);
fprintf(fid, '%send{center}\n', bS);
fprintf(fid, '%send{table}\n', bS);
return

function genInfoTables(fid, param, CompResult, InfoSDP, Errors, solver)
bS = char(92);
aand = char(38);
fprintf(fid, '%sbegin{table}[htdp]\n', bS);
caption = strcat('Numerical%results%on%SDP%relaxation%problems%in%Subsection%3.2%by%');
if strcmp(solver, 'sedumi')
	caption = strcat(caption,'SeDuMi');
	idx = 1;
elseif strcmp(solver, 'sdpt3')
	caption = strcat(caption,'SDPT3');
	idx = 2;
elseif strcmp(solver, 'sdpa')
	caption = strcat(caption,'SDPA');
	idx = 3;
end
caption = strrep(caption, '%', blanks(1));
fprintf(fid, '%scaption{%s}\n', bS,caption);
fprintf(fid, '%sbegin{center}\n', bS);
fprintf(fid, '{%sfootnotesize\n', bS);
fprintf(fid, '%sbegin{tabular}{|c|c|cc|cc|cc|c|}\n', bS);
fprintf(fid, '%shline\n', bS);
fprintf(fid, '$r$ %s Type %s [rowA, colA] %s nnzA %s ', aand, aand, aand, aand);
fprintf(fid, 'SDPobj %s POPobj %s ', aand, aand);
fprintf(fid, '$%sepsilon_{%smbox{obj}}$  %s', bS, bS, aand);
fprintf(fid, '$%sepsilon_{%smbox{feas}}$ %s', bS, bS, aand);
fprintf(fid, '[$%ssec$]%s%s\n', bS, bS, bS);
fprintf(fid, '%shline\n', bS);

[L, M, N] = size(CompResult);
for i=1:N
	for j=1:M
        ro  = i;%full(param.relaxOrder);
        rowA= full(InfoSDP{idx, j, i}.size(1));
        colA= full(InfoSDP{idx, j, i}.size(2));
        nnzA= full(InfoSDP{idx, j, i}.nnzA);
        objS= full(CompResult{idx, j, i}.SDPobj);
        objP= full(CompResult{idx, j, i}.POPobj);
	objerr=full(Errors{idx, j, i}.objerr);
        err = full(Errors{idx, j, i}.absE);
        cpu = full(CompResult{idx, j, i}.cpuTime);
		if j == 1
			fprintf(fid, '%d %s Lasserre %s ', ro, aand, aand);
		elseif j == 2
			%fprintf(fid, '   %s Our      %s ', aand, aand);
			fprintf(fid, '   %s Adaptive SoS %s ', aand, aand);
		end
        fprintf(fid, '[%3d, %4d] %s %4d %s',rowA, colA, aand, nnzA, aand);
        fprintf(fid, '%6.5e %s %6.5e %s %2.1e %s',objS, aand, objP, aand, objerr, aand);
        fprintf(fid, '%2.1e %s %3.2f ',err, aand, cpu);
        fprintf(fid, '%s%s\n',bS,bS);
	end
	fprintf(fid, '%shline\n', bS);
end	
fprintf(fid, '%send{tabular}\n', bS);
fprintf(fid, '}\n');
fprintf(fid, '%slabel{subsec3.2_info_table_%s}\n', bS, solver);
fprintf(fid, '%send{center}\n', bS);
fprintf(fid, '%send{table}\n', bS);
return

function genErrorTables(eid, param, CompResult, InfoSDP, Errors, solver)
bS = char(92); % char(165);
aand = char(38);
fprintf(eid,'%sbegin{table}[htdp]\n',bS);
if strcmp(solver, 'sedumi')
	caption = 'Iter,%numerr,%and%DIMACS%errors%for%SDP%relaxation%problems%in%Subsection%3.2%by%';
	caption = strcat(caption, 'SeDuMi');
	idx = 1;
elseif strcmp(solver, 'sdpt3')
	caption = 'Iter,%termcode,%and%DIMACS%errors%for%SDP%relaxation%problems%in%Subsection%3.2%by%';
	caption = strcat(caption, 'SDPT3');
	idx = 2;
elseif strcmp(solver, 'sdpa')
	caption = 'Iter,%phasevalue,%and%DIMACS%errors%for%SDP%relaxation%problems%in%Subsection%3.2%by%';
	caption = strcat(caption, 'SDPA');
	idx = 3;
end
caption = strrep(caption, '%', blanks(1));
fprintf(eid,'%scaption{%s}\n',bS,caption);
fprintf(eid,'%sbegin{center}\n',bS);
fprintf(eid,'{%sfootnotesize \n', bS);
fprintf(eid, '%sbegin{tabular}{|c|c|cc|cccccc|}\n', bS);
fprintf(eid, '%shline\n', bS);
if strcmp(solver, 'sedumi')
	fprintf(eid, '$r$%s Type%s iter.%s numerr%s',aand,aand,aand,aand);
elseif strcmp(solver, 'sdpt3')
	fprintf(eid, '$r$%s Type%s iter.%s termcode%s',aand,aand,aand,aand);
elseif strcmp(solver, 'sdpa')
	fprintf(eid, '$r$%s Type%s iter.%s phasevalue%s',aand,aand,aand,aand);
end
fprintf(eid, 'err1%s err2%s err3%s ',aand, aand,aand);
fprintf(eid, 'err4%s err5%s err6 %s%s\n', aand, aand, bS, bS);
fprintf(eid, '%shline\n', bS);

[L, M, N] = size(CompResult);
for i=1:N
	for j=1:M
        iter = Errors{idx, j, i}.iter;
        ro  = full(CompResult{idx, j, i}.ro);
        nerr = Errors{idx, j, i}.nerr;
        err1 = Errors{idx, j, i}.dimacs(1);err2 = Errors{idx, j, i}.dimacs(2);
        err3 = Errors{idx, j, i}.dimacs(3);err4 = Errors{idx, j, i}.dimacs(4);
        err5 = Errors{idx, j, i}.dimacs(5);err6 = Errors{idx, j, i}.dimacs(6);
		if j == 1
        	fprintf(eid,'%d%s Lasserre %s %2d %s %2d %s',ro, aand, aand,iter, aand, nerr, aand);
		elseif j == 2
        	fprintf(eid,' %s Adaptive SoS %s %2d %s %2d %s',aand, aand,iter, aand, nerr, aand);
		end
        fprintf(eid,'%2.1e %s %2.1e %s %2.1e %s',err1, aand, err2, aand, err3, aand);
        fprintf(eid,'%2.1e %s %2.1e %s %2.1e ',err4, aand, err5, aand, err6);
        fprintf(eid,'%s%s\n',bS,bS);
    end
	fprintf(eid, '%shline\n', bS);
end
fprintf(eid, '%send{tabular}\n', bS);
fprintf(eid, '}\n');
fprintf(eid, '%send{center}\n', bS);
fprintf(eid, '%slabel{subsec3.2_error_table_%s}\n', bS, solver);
fprintf(eid, '%send{table}\n', bS);
return
