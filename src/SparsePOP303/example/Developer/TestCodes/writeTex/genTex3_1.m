function genTex3_1(param,compResult, InfoSDP, Errors)

fname = strcat('sec3.1_table.tex');
fid   = fopen(fname, 'w+');
genTables(fid, param, compResult, InfoSDP, Errors);

iname = strcat('sec3.1_info_table.tex');
iid   = fopen(iname, 'w+');
genInfoTables(iid, param, compResult, InfoSDP, Errors);

ename = strcat('sec3.1_error_table.tex');
eid   = fopen(ename, 'w+');
genErrorTables(eid, param, compResult, InfoSDP, Errors);

fclose(fid);
fclose(iid);
fclose(eid);
return

function genTables(fid, param, compResult, sedumiInfoVec, Errors)
bS = char(92);
aand = char(38);
fprintf(fid, '%sbegin{table}[htdp]\n', bS);
caption1= strcat('The%approximate%optimal%value,%cpu%time,%the%number%of%iterations%');
%caption2= strcat('by%SeDuMi%,%SDPT3%and%SDPA%');
caption2= strcat('by%SeDuMi%and%SDPT3%in%Subsection%3.1');
caption = strcat(caption1, caption2);
caption = strrep(caption, '%', blanks(1));
fprintf(fid, '%scaption{%s}\n', bS,caption);
fprintf(fid, '%sbegin{center}\n', bS);
fprintf(fid, '{%sfootnotesize\n', bS);
fprintf(fid, '%sbegin{tabular}{|c|c|c|cc|}\n', bS);
fprintf(fid, '%shline\n', bS);
fprintf(fid, '$r$ %s Software %s iter.%s SDPobj %s [$%ssec$] %s%s ', aand, aand, aand, aand, bS, bS, bS);
fprintf(fid, '%shline\n', bS);

[M, N] = size(compResult);
for i=1:N
	for j=1:M
		ro = full(compResult{j, i}.ro);
		iter = full(Errors{j, i}.iter);
		sdpobj = full(compResult{j, i}.SDPobj);
		cputime= full(compResult{j, i}.cpuTime);
		if j == 1
			solver = 'SeDuMi';
			fprintf(fid, '%d%s%s%s%2d%s%8.7e%s%3.2f', ro, aand, solver, aand, iter, aand, sdpobj, aand, cputime); 		
		elseif j == 2
			solver = 'SDPT3';
			fprintf(fid, ' %s%s%s%2d%s%8.7e%s%3.2f', aand, solver, aand, iter, aand, sdpobj, aand, cputime); 		
		elseif j == 3
			solver = 'SDPA';
			fprintf(fid, ' %s%s%s%2d%s%8.7e%s%3.2f', aand, solver, aand, iter, aand, sdpobj, aand, cputime); 		
		end
		fprintf(fid, '%s%s\n', bS, bS);
	end
	fprintf(fid, '%shline\n', bS);
end	
fprintf(fid, '%send{tabular}\n', bS);
fprintf(fid, '}\n');
fprintf(fid, '%slabel{%s}\n', bS, 'subsec3.1_table');
fprintf(fid, '%send{center}\n', bS);
fprintf(fid, '%send{table}\n', bS);
return

function genInfoTables(iid, param, compResult, InfoSDP, Errors)
backS = char(92); % char(165);
aand = char(38);
fprintf(iid,'%sbegin{table}[htdp]\n',backS);
caption = strcat('Information%on%SDP%relaxation%problems%in%Subsection%3.1%by%SeDuMi%,%SDPT3%and%SDPA%');
caption = strrep(caption, '%', blanks(1));
fprintf(iid,'%scaption{%s}\n',backS,caption);
fprintf(iid,'%sbegin{center}\n',backS);
fprintf(iid,'{%sfootnotesize\n', backS);
fprintf(iid, '%sbegin{tabular}{|c|c|cc|ccccc|}\n', backS);
fprintf(iid, '%shline\n', backS);
fprintf(iid, '$r$%s Solver %s ', aand, aand);
fprintf(iid, '[rowA, colA]%s nnzA%s ',aand, aand);
fprintf(iid, 'SDPobj%s POPobj%s objErr%s absE%s ',aand,aand, aand,aand);
fprintf(iid, '[$%ssec$]%s%s\n', backS, backS, backS);
fprintf(iid, '%shline\n', backS);

[M, N] = size(compResult);
for i=1:N
	for j=1:M
        ro  = full(compResult{j, i}.ro);
        rowA= full(InfoSDP{j, i}.size(1));
        colA= full(InfoSDP{j, i}.size(2));
        nnzA= full(InfoSDP{j, i}.nnzA);
        cpu = full(compResult{j, i}.cpuTime);
        objS= full(compResult{j, i}.SDPobj);
        objP= full(compResult{j, i}.POPobj);
		objerr=full(Errors{j, i}.objerr);
        err = full(Errors{j, i}.absE);
		if j == 1
			solver = 'SeDuMi';
        	fprintf(iid, '%d %s %s %s ', ro, aand, solver, aand);
		elseif j == 2
			solver = 'SDPT3';
        	fprintf(iid, ' %s %s %s ', aand, solver, aand);
		elseif j == 3
			solver = 'SDPA';
        	fprintf(iid, ' %s %s %s ', aand, solver, aand);
		end
        fprintf(iid, '[%3d, %4d] %s %4d %s',rowA, colA, aand, nnzA, aand);
        fprintf(iid,'%6.5e %s %6.5e %s %2.1e %s',objS, aand, objP, aand, objerr, aand);
        fprintf(iid,'%2.1e %s %3.2f ',err, aand, cpu);
        fprintf(iid,'%s%s\n',backS,backS);
    end
	fprintf(iid, '%shline\n', backS);
end
fprintf(iid, '%send{tabular}\n', backS);
fprintf(iid, '}\n');
fprintf(iid, '%send{center}\n', backS);
fprintf(iid, '%slabel{%s}\n', backS, 'subsec3.1_info_table');
fprintf(iid, '%send{table}\n', backS);
return

function genErrorTables(eid, param, compResult, InfoSDP, Errors)
backS = char(92); % char(165);
aand = char(38);
fprintf(eid,'%sbegin{table}[htdp]\n',backS);
caption = 'Iter,%numerr%(termcode),%and%DIMACS%errors%for%SDP%relaxation%in%Subsection%3.1';
caption = strrep(caption, '%', blanks(1));
fprintf(eid,'%scaption{%s}\n',backS,caption);
fprintf(eid,'%sbegin{center}\n',backS);
fprintf(eid,'{%ssmall \n', backS);
fprintf(eid, '%sbegin{tabular}{|c|c|cc|cccccc|}\n', backS);
fprintf(eid, '%shline\n', backS);
%if strcmp(solver, 'sedumi')
	fprintf(eid, '$r$%s Solver%s iter.%s numerr%s',aand,aand,aand,aand);
%elseif strcmp(solver, 'sdpt3')
%	fprintf(eid, '$r$%s Solver%s iter.%s termcode%s',aand,aand,aand,aand);
%elseif strcmp(solver, 'sdpa')
%	fprintf(eid, '$r$%s Solver%s iter.%s phasevalue%s',aand,aand,aand,aand);
%end
fprintf(eid, 'err1%s err2%s err3%s ',aand, aand,aand);
fprintf(eid, 'err4%s err5%s err6 %s%s\n', aand, aand, backS, backS);
fprintf(eid, '%shline\n', backS);

[M, N] = size(compResult);
for i=1:N
	for j=1:M
        iter = Errors{j, i}.iter;
		nerr = Errors{j, i}.nerr;
        ro  = full(compResult{j, i}.ro);
        nerr = Errors{j, i}.nerr;
        err1 = Errors{j, i}.dimacs(1);err2 = Errors{j, i}.dimacs(2);
        err3 = Errors{j, i}.dimacs(3);err4 = Errors{j, i}.dimacs(4);
        err5 = Errors{j, i}.dimacs(5);err6 = Errors{j, i}.dimacs(6);
		if j == 1
        	fprintf(eid,'%d%s SeDuMi %s %2d %s %2d %s',ro, aand, aand,iter, aand, nerr, aand);
		elseif j == 2
			solver = 'SDPT3';
        	fprintf(eid,' %s SDPT3 %s %2d %s %2d %s',aand, aand,iter, aand, nerr, aand);
		elseif j == 3
			solver = 'SDPA';
        	fprintf(eid,' %s SDPA %s %2d %s %s %s',aand, aand,iter, aand, nerr, aand);
		end
        fprintf(eid,'%2.1e %s %2.1e %s %2.1e %s',err1, aand, err2, aand, err3, aand);
        fprintf(eid,'%2.1e %s %2.1e %s %2.1e   ',err4, aand, err5, aand, err6);
        fprintf(eid,'%s%s\n',backS,backS);
    end
	fprintf(eid, '%shline\n', backS);
end
fprintf(eid, '%send{tabular}\n', backS);
fprintf(eid, '}\n');
fprintf(eid, '%send{center}\n', backS);;
fprintf(eid, '%slabel{%s}\n', backS, 'subsec3.1_error_table');
fprintf(eid, '%send{table}\n', backS);
return
