function genTex3_3(param,CompResult, InfoSDP, Errors, DefaultSeed)
fname = 'sec3.3_table.tex';
fid   = fopen(fname, 'w+');
genTable(fid, param, CompResult, InfoSDP, Errors);
fclose(fid);
N  = size(InfoSDP, 3);
for j=1:N
	nDim = 5*j;
	iname = strcat('sec3.3_info_table_sedumi_nDim', num2str(nDim), '.tex');
	iid   = fopen(iname, 'w+');
	genInfoTable(iid, param, CompResult, InfoSDP, Errors, 'sedumi', DefaultSeed, j);
	fclose(iid);
	ename = strcat('sec3.3_error_table_sedumi_nDim', num2str(nDim), '.tex');
	eid   = fopen(ename, 'w+');
	tmpseed = genErrorTable(eid, param, CompResult, InfoSDP, Errors, 'sedumi', DefaultSeed, j);
	fclose(eid);
	iname = strcat('sec3.3_info_table_sdpt3_nDim', num2str(nDim), '.tex');
	iid   = fopen(iname, 'w+');
	genInfoTable(iid, param, CompResult, InfoSDP, Errors, 'sdpt3', DefaultSeed, j);
	fclose(iid);
	ename = strcat('sec3.3_error_table_sdpt3_nDim', num2str(nDim), '.tex');
	eid   = fopen(ename, 'w+');
	tmpseed = genErrorTable(eid, param, CompResult, InfoSDP, Errors, 'sdpt3', DefaultSeed, j);
	fclose(eid);
end
return

function genTable(fid, param, CompResult, InfoSDP, Errors)
backS = char(92); % char(165);
aand = char(38);
fprintf(fid,'%sbegin{table}[htdp]\n',backS);
caption = 'Information%on%SDP%relaxation%problems%in%Subsection%3.3%';
caption = strrep(caption, '%', blanks(1));
fprintf(fid,'%scaption{%s}\n',backS,caption);
fprintf(fid,'%sbegin{center}\n',backS);
fprintf(fid,'{%sfootnotesize \n', backS);
fprintf(fid, '%sbegin{tabular}{|c|c|l|l||l|}\n', backS);
fprintf(fid, '%shline\n', backS);
fprintf(fid, '%smulticolumn{2}{|c|}{}%sLasserre%sAdaptive SOS%s%s%s\n', backS, aand, aand, aand, backS, backS);
fprintf(fid, '%shline\n', backS);
fprintf(fid, '$n$ %s Software ', aand);
fprintf(fid, '%s (%s#solved $|$ min.t, ave.t, max.t) ', aand, backS);
fprintf(fid, '%s (%s#solved $|$ min.t, ave.t, max.t) ', aand, backS);
fprintf(fid, '%s (minR, aveR, maxR)%s%s\n', aand, backS, backS); 
fprintf(fid, '%shline\n', backS);

NN = size(InfoSDP, 4);
N  = size(InfoSDP, 3);
L  = size(InfoSDP, 1);
LasCPU  = zeros(L, N, NN);
OurCPU  = zeros(L, N, NN);
maxLas  = zeros(L, N);
maxOur  = zeros(L, N);
aveLas  = zeros(L, N);
aveOur  = zeros(L, N);
minLas  = zeros(L, N);
minOur  = zeros(L, N);
LasObj  = zeros(L, N, NN);
OurObj  = zeros(L, N, NN);
minRatio= ones(L, N);
aveRatio= zeros(L, N);
maxRatio= zeros(L, N);
for solvers =1:L
	for i=1:N
		for j=1:NN
			LasCPU(solvers, i, j) = CompResult{solvers, 1, i, j}.cpuTime;
			OurCPU(solvers, i, j) = CompResult{solvers, 2, i, j}.cpuTime;
			if isempty(CompResult{solvers, 1, i, j}.SDPobj)
				LasObj(solvers, i, j) = nan;
				OurObj(solvers, i, j) = nan;
			else
				LasObj(solvers, i, j) = full(CompResult{solvers, 1, i, j}.SDPobj);
				OurObj(solvers, i, j) = full(CompResult{solvers, 2, i, j}.SDPobj);
			end
			if isnan(LasObj(solvers, i, j))
				maxRatio(solvers, i) = nan;
				aveRatio(solvers, i) = nan;
				minRatio(solvers, i) = nan;
			else
				aveRatio(solvers, i) = aveRatio(solvers, i) + LasObj(solvers, i, j)/OurObj(solvers, i, j);
				if maxRatio(solvers, i) < LasObj(solvers, i, j)/OurObj(solvers, i, j)
					maxRatio(solvers, i) = LasObj(solvers, i, j)/OurObj(solvers, i, j);
				end
				if minRatio(solvers, i) > LasObj(solvers, i, j)/OurObj(solvers, i, j)
					minRatio(solvers, i) = LasObj(solvers, i, j)/OurObj(solvers, i, j);
				end
			end
		end
		aveRatio(solvers, i) = aveRatio(solvers, i)/NN;
		maxLas(solvers, i) = max(LasCPU(solvers, i, :));
		minLas(solvers, i) = min(LasCPU(solvers, i, :));
		maxOur(solvers, i) = max(OurCPU(solvers, i, :));
		minOur(solvers, i) = min(OurCPU(solvers, i, :));
		aveLas(solvers, i) = sum(LasCPU(solvers, i, :))/NN;
		aveOur(solvers, i) = sum(OurCPU(solvers, i, :))/NN;
	end
end
EPS = 1.0e-7;
Nsolved = zeros(L, 2, N);
for i=1:N
	nDim = 5*i;
	for solvers=1:L
		if solvers == 1
			fprintf(fid, '%2d %s SeDuMi ', nDim, aand);
		elseif solvers == 2
			fprintf(fid, '%s SDPT3 ', aand);
		elseif solvers == 3
			fprintf(fid, '%s SDPA ', aand);
		end
		for SW=1:2
			for j=1:NN
				objerr=full(Errors{solvers, SW, i, j}.objerr);
				err = full(Errors{solvers, SW, i, j}.absE);
				if ~isempty(objerr) && ~isempty(err)
					if abs(objerr) < EPS && abs(err) < EPS
						Nsolved(solvers, SW, i) = Nsolved(solvers, SW, i) + 1;
					end
				end	
    			end
			if SW == 1
				minT = minLas(solvers, i);
				aveT = aveLas(solvers, i);
				maxT = maxLas(solvers, i);
			elseif SW == 2
				minT = minOur(solvers, i);
				aveT = aveOur(solvers, i);
				maxT = maxOur(solvers, i);
			end
			fprintf(fid, '%s (%2d $|$ %3.2f %3.2f %3.2f) ', aand, Nsolved(solvers, SW, i), minT, aveT, maxT);
		end
		minR = minRatio(solvers, i);
		aveR = aveRatio(solvers, i);
		maxR = maxRatio(solvers, i);
		fprintf(fid, '%s (%2.1f, %2.1f, %2.1f) ', aand, minR, aveR, maxR);
		fprintf(fid,'%s%s\n',backS,backS);
	end
	fprintf(fid, '%shline\n', backS);
end
backS = char(92); % char(165);
fprintf(fid, '%send{tabular}\n', backS);
fprintf(fid, '}\n');
fprintf(fid, '%send{center}\n', backS);
label = strcat('subsec3.3_table');
fprintf(fid, '%slabel{%s}\n', backS,label);
fprintf(fid, '%send{table}\n', backS);
return

function genInfoTable(fid, param, CompResult, InfoSDP, Errors, solver, DefaultSeed, idx)
bS = char(92);
aand = char(38);
fprintf(fid, '%sbegin{table}[htdp]\n', bS);
NDIM = num2str(5*idx);
caption = strcat('Numerical%results%on%SDP%relaxation%problems');
caption = strcat(caption, '%for%POPs%with%$n=', NDIM, '$%in%Subsection%3.3%by%');
if strcmp(solver, 'sedumi')
	caption = strcat(caption,'SeDuMi');
	solvers = 1;
elseif strcmp(solver, 'sdpt3')
	caption = strcat(caption,'SDPT3');
	solvers = 2;
elseif strcmp(solver, 'sdpa')
	caption = strcat(caption,'SDPA');
	solvers = 3;
end
caption = strrep(caption, '%', blanks(1));
fprintf(fid, '%scaption{%s}\n', bS,caption);
fprintf(fid, '%sbegin{center}\n', bS);
fprintf(fid, '{%sfootnotesize\n', bS);
fprintf(fid, '%sbegin{tabular}{|c|c|cc|cc|cc|c|}\n', bS);
fprintf(fid, '%shline\n', bS);
fprintf(fid, 'Seed %s Type %s [rowA, colA] %s nnzA %s ', aand, aand, aand, aand);
fprintf(fid, 'SDPobj %s POPobj %s ', aand, aand);
fprintf(fid, '$%sepsilon_{%smbox{obj}}$  %s', bS, bS, aand);
fprintf(fid, '$%sepsilon_{%smbox{feas}}$ %s', bS, bS, aand);
fprintf(fid, '[$%ssec$]%s%s\n', bS, bS, bS);
fprintf(fid, '%shline\n', bS);

NN = size(InfoSDP, 4);
seed = DefaultSeed;
for j=1:NN
	seed = seed + 1000;
	for SW=1:2
		rowA= full(InfoSDP{solvers, SW, idx, j}.size(1));
		colA= full(InfoSDP{solvers, SW, idx, j}.size(2));
		nnzA= full(InfoSDP{solvers, SW, idx, j}.nnzA);
		objS= full(CompResult{solvers, SW, idx, j}.SDPobj);
		objP= full(CompResult{solvers, SW, idx, j}.POPobj);
		objerr=full(Errors{solvers, SW, idx, j}.objerr);
		err = full(Errors{solvers, SW, idx, j}.absE);
		cpu = full(CompResult{solvers, SW, idx, j}.cpuTime);
		if SW == 1
			fprintf(fid, ' %5d %s Lasserre %s ', seed, aand, aand);
		elseif SW == 2
			%fprintf(fid, '     %s Our      %s ', aand, aand);
			fprintf(fid, '     %s Adaptive SoS %s ', aand, aand);
		end
		fprintf(fid, '[%3d, %4d] %s %4d %s',rowA, colA, aand, nnzA, aand);
		fprintf(fid, '%6.5e %s %6.5e %s %2.1e %s',objS, aand, objP, aand, objerr, aand);
		fprintf(fid, '%2.1e %s %3.2f %s%s',err, aand, cpu, bS, bS);
	end
	fprintf(fid, '%shline\n', bS);
end	
fprintf(fid, '%send{tabular}\n', bS);
fprintf(fid, '}\n');
fprintf(fid, '%slabel{subsec3.3_info_table_%s_nDim%s}\n', bS, solver, NDIM);
fprintf(fid, '%send{center}\n', bS);
fprintf(fid, '%send{table}\n', bS);
return

function seed = genErrorTable(eid, param, CompResult, InfoSDP, Errors, solver, DefaultSeed, idx)
bS = char(92); % char(165);
aand = char(38);
fprintf(eid,'%sbegin{table}[htdp]\n',bS);
NDIM = num2str(5*idx);
if strcmp(solver, 'sedumi')
	caption = 'Iter,%numerr,%and%DIMACS%errors%for%SDP%relaxation%problems%';
	caption = strcat(caption, 'for%POPs%with%$n=', NDIM, '$%in%Subsection%3.3%by%');
	caption = strcat(caption, 'SeDuMi');
	solvers = 1;
elseif strcmp(solver, 'sdpt3')
	caption = 'Iter,%termcode,%and%DIMACS%errors%for%SDP%relaxation%problems%';
	caption = strcat(caption, 'for%POPs%with%$n=', NDIM, '$%in%Subsection%3.3%by%');
	caption = strcat(caption, 'SDPT3');
	solvers = 2;
elseif strcmp(solver, 'sdpa')
	caption = 'Iter,%phasevalue,%and%DIMACS%errors%for%SDP%relaxation%problems%';
	caption = strcat(caption, 'for%POPs%with%$n=', NDIM, '$%in%Subsection%3.3%by%');
	caption = strcat(caption, 'SDPA');
	solvers = 3;
end
caption = strrep(caption, '%', blanks(1));
fprintf(eid,'%scaption{%s}\n',bS,caption);
fprintf(eid,'%sbegin{center}\n',bS);
fprintf(eid, '{%sfootnotesize\n', bS);
fprintf(eid, '%sbegin{tabular}{|c|c|cc|cccccc|}\n', bS);
fprintf(eid, '%shline\n', bS);
if strcmp(solver, 'sedumi')
	fprintf(eid, 'seed%s Type%s iter.%s numerr%s',aand,aand,aand,aand);
elseif strcmp(solver, 'sdpt3')
	fprintf(eid, 'seed%s Type%s iter.%s termcode%s',aand,aand,aand,aand);
elseif strcmp(solver, 'sdpa')
	fprintf(eid, 'seed%s Type%s iter.%s phasevalue%s',aand,aand,aand,aand);
end
fprintf(eid, 'err1%s err2%s err3%s ',aand, aand,aand);
fprintf(eid, 'err4%s err5%s err6 %s%s\n', aand, aand, bS, bS);
fprintf(eid, '%shline\n', bS);

NN = size(CompResult, 4);
seed = DefaultSeed;
for j=1:NN
	seed = seed + 1000;
	for SW=1:2
	        iter = Errors{solvers, SW, idx, j}.iter;
		nerr = Errors{solvers, SW, idx, j}.nerr;
		err1 = Errors{solvers, SW, idx, j}.dimacs(1);err2 = Errors{solvers, SW, idx, j}.dimacs(2);
		err3 = Errors{solvers, SW, idx, j}.dimacs(3);err4 = Errors{solvers, SW, idx, j}.dimacs(4);
		err5 = Errors{solvers, SW, idx, j}.dimacs(5);err6 = Errors{solvers, SW, idx, j}.dimacs(6);
		if SW == 1
			if strcmp(solver, 'sdpa') == 0
				fprintf(eid,'%5d%s Lasserre %s %2d %s %2d %s',seed, aand, aand,iter, aand, nerr, aand);
			else
				fprintf(eid,'%5d%s Lasserre %s %2d %s %s %s',seed, aand, aand,iter, aand, nerr, aand);
			end
		elseif SW == 2
			if strcmp(solver, 'sdpa') == 0
        		%fprintf(eid,' %s Our %s %2d %s %2d %s',aand, aand,iter, aand, nerr, aand);
        		fprintf(eid,' %s Adaptive SoS %s %2d %s %2d %s',aand, aand,iter, aand, nerr, aand);
			else
        		%fprintf(eid,' %s Our %s %2d %s %s %s',aand, aand,iter, aand, nerr, aand);
        		fprintf(eid,' %s Adaptive SoS %s %2d %s %s %s',aand, aand,iter, aand, nerr, aand);
			end
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
fprintf(eid, '%slabel{subsec3.3_error_table_%s_nDim%s}\n', bS, solver, NDIM);
fprintf(eid, '%send{table}\n', bS);
return
