function genTex3_5(param,CompResult, InfoSDP, Errors, DefaultSeed, Vec)
fname = strcat('sec3.5_table_ro', num2str(param.relaxOrder), '.tex');
fid   = fopen(fname, 'w+');
genTable(fid, param, CompResult, InfoSDP, Errors, Vec);
N = size(Vec, 1);
RO = num2str(param.relaxOrder);
for j=1:N
	NDIM = num2str(Vec(j, 1)+Vec(j, 2)+1);
	KDIM = num2str(Vec(j, 3));
	solver = 'sedumi';
	iname = strcat('sec3.5_info_table_', solver, '_nDim', NDIM, '_kDim', KDIM, '_ro', RO, '.tex');
	iid   = fopen(iname, 'w+');
	genInfoTables(iid, param, CompResult, InfoSDP, Errors, solver, DefaultSeed, Vec(j, :), j);
	fclose(iid);
	ename = strcat('sec3.5_error_table_', solver, '_nDim', NDIM, '_kDim', KDIM, '_ro', RO, '.tex');
	eid   = fopen(ename, 'w+');
	genErrorTables(eid, param, CompResult, InfoSDP, Errors, solver, DefaultSeed, Vec(j, :), j);
	fclose(eid);
	solver = 'sdpt3';
	iname = strcat('sec3.5_info_table_', solver, '_nDim', NDIM, '_kDim', KDIM, '_ro', RO, '.tex');
	iid   = fopen(iname, 'w+');
	genInfoTables(iid, param, CompResult, InfoSDP, Errors, solver, DefaultSeed, Vec(j, :), j);
	fclose(iid);
	ename = strcat('sec3.5_error_table_', solver, '_nDim', NDIM, '_kDim', KDIM, '_ro', RO, '.tex');
	eid   = fopen(ename, 'w+');
	genErrorTables(eid, param, CompResult, InfoSDP, Errors, solver, DefaultSeed, Vec(j, :), j);
	fclose(eid);
end
return
%{
function genIters(fid2, param, CompResult, InfoSDP, Errors, Vec)
backS = char(92); % char(165);
aand = char(38);
fprintf(fid2,'%sbegin{table}[htdp]\n',backS);
caption = 'Iterations%of%';
if strcmp(solver, 'sedumi')
	caption = strcat(caption, 'SeDuMi');
elseif strcmp(solver, 'sdpt3')
	caption = strcat(caption, 'SDPT3');
elseif strcmp(solver, 'sdpa')
	caption = strcat(caption, 'SDPA');
end
caption = strcat(caption, '%for%SDP%relaxation%problems%in%Subsection%3.3%');
caption = strrep(caption, '%', blanks(1));
fprintf(fid2,'%scaption{%s}\n',backS,caption);
fprintf(fid2,'%sbegin{center}\n',backS);
fprintf(fid2,'{%sfootnotesize \n', backS);
fprintf(fid2, '%sbegin{tabular}{|c|c|ccc|}\n', backS);
fprintf(fid2, '%shline\n', backS);
fprintf(fid2, '$(n, m, k)$ %s Type%s ', aand, aand);
fprintf(fid2, 'min.iter. %save.iter. %smax.iter', aand, aand);
fprintf(fid2, '%s%s\n', backS, backS);
fprintf(fid2, '%shline\n', backS);
N = size(Vec, 1);
NN = size(Errors, 3);
LasIter = zeros(N, NN);
OurIter = zeros(N, NN);
for i=1:N
	for j=1:NN
		LasIter(i, j) = Errors{1, i, j}.iter;
		OurIter(i, j) = Errors{2, i, j}.iter;
	end
	maxLasIter(i, 1) = max(LasIter(i, :));
	maxOurIter(i, 1) = max(OurIter(i, :));
	minLasIter(i, 1) = min(LasIter(i, :));
	minOurIter(i, 1) = min(OurIter(i, :));
	aveLasIter(i, 1) = sum(LasIter(i, :))/NN;
	aveOurIter(i, 1) = sum(OurIter(i, :))/NN;
end
for i=1:N
	nDim = Vec(i, 1);
	kDim = Vec(i, 3);
	fprintf(fid2,'(%d, %d, %2d) %s Lasserre %s ', nDim, nDim, kDim, aand, aand);
	minI = minLasIter(i, 1);
	maxI = maxLasIter(i, 1);
	aveI = aveLasIter(i, 1);
	fprintf(fid2,'%2d %s %3.1f %s %2d %s', minI, aand, aveI, aand, maxI); 
	fprintf(fid2, '%s%s\n', backS, backS);
	%fprintf(fid2, '%s Our %s ', aand, aand);
	fprintf(fid2, '%s Adaptive SoS %s ', aand, aand);
	minI = minOurIter(i, 1);
	maxI = maxOurIter(i, 1);
	aveI = aveOurIter(i, 1);
	fprintf(fid2,'%2d %s %3.1f %s %2d %s', minI, aand, aveI, aand, maxI); 
	fprintf(fid2,'%s%s\n',backS,backS);
	fprintf(fid2,'%shline\n',backS);
end
fprintf(fid2, '%send{tabular}\n', backS);
fprintf(fid2, '}\n');
fprintf(fid2, '%send{center}\n', backS);
label = strcat('subsec3.5_iter_', solver);
fprintf(fid2, '%slabel{%s}\n', backS,label);
fprintf(fid2, '%send{table}\n', backS);
return
%}

function genTable(fid, param, CompResult, InfoSDP, Errors, Vec)
backS = char(92); % char(165);
aand = char(38);
fprintf(fid,'%sbegin{table}[htdp]\n',backS);
caption = 'Information%on%SDP%relaxation%problems%in%Subsection%3.5%with%relaxation%order%=%';
caption = strcat(caption, num2str(param.relaxOrder));
caption = strrep(caption, '%', blanks(1));
fprintf(fid,'%scaption{%s}\n',backS,caption);
fprintf(fid,'%sbegin{center}\n',backS);
fprintf(fid,'{%sfootnotesize \n', backS);
fprintf(fid, '%sbegin{tabular}{|c|c|l|l||l|}\n', backS);
fprintf(fid, '%shline\n', backS);
fprintf(fid, '%smulticolumn{2}{|c|}{}%sLasserre%sAdaptive SOS%s%s%s\n', backS, aand, aand, aand, backS, backS);
fprintf(fid, '%shline\n', backS);
fprintf(fid, '$(n, m, k)$ %s Software', aand);
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
N = size(Vec, 1);
for i=1:N
	nDim = Vec(i, 1);
	mDim = Vec(i, 2);
	kDim = Vec(i, 3);
	for solvers=1:L
		if solvers == 1
			fprintf(fid, '(%d, %d, %2d) %s SeDuMi ', nDim, mDim, kDim, aand);
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
label = strcat('subsec3.5_table');
fprintf(fid, '%slabel{%s}\n', backS,label);
fprintf(fid, '%send{table}\n', backS);
return

function genInfoTables(fid, param, CompResult, InfoSDP, Errors, solver, DefaultSeed, vec, idx)
nDim = vec(1, 1);
mDim = vec(1, 2);
kDim = vec(1, 3);
NDIM = num2str(vec(1, 1));
MDIM = num2str(vec(1, 2));
KDIM = num2str(vec(1, 3));
bS = char(92);
aand = char(38);
fprintf(fid, '%sbegin{table}[htdp]\n', bS);
caption = strcat('Numerical%results%on%SDP%relaxation%problems');
caption = strcat(caption, '%for%BMIEPs%with%$(n, m, k)=(', NDIM, ',', MDIM, ',', KDIM ,')$%in%Subsection%3.5%by%');
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
fprintf(fid, 'seed %s Type %s [rowA, colA] %s nnzA %s ', aand, aand, aand, aand);
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
			fprintf(fid, ' %5d %s Lasserre %s ', seed,aand, aand);
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
fprintf(fid, '%slabel{subsec3.5_info_table_%s_nDim%s_kDim%s}\n', bS, solver, NDIM, KDIM);
fprintf(fid, '%send{center}\n', bS);
fprintf(fid, '%send{table}\n', bS);
return

function genErrorTables(eid, param, CompResult, InfoSDP, Errors, solver, DefaultSeed, vec, idx)
nDim = vec(1, 1);
mDim = vec(1, 2);
kDim = vec(1, 3);
NDIM = num2str(vec(1, 1));
MDIM = num2str(vec(1, 2));
KDIM = num2str(vec(1, 3));
bS = char(92); % char(165);
aand = char(38);
fprintf(eid,'%sbegin{table}[htdp]\n',bS);
if strcmp(solver, 'sedumi')
	caption = 'Iter,%numerr,%and%DIMACS%errors%for%SDP%relaxation%problems%';
	caption = strcat(caption, 'for%BMIEPs%with%$(n,m,k)=(', NDIM,',',MDIM,',',KDIM,')$%');
	caption = strcat(caption, '%in%Subsection%3.5%by%');
	caption = strcat(caption, 'SeDuMi');
	solvers = 1;
elseif strcmp(solver, 'sdpt3')
	caption = 'Iter,%termcode,%and%DIMACS%errors%for%SDP%relaxation%problems%';
	caption = strcat(caption, 'for%BMIEPs%with%$(n,m,k)=(', NDIM,',',MDIM,',',KDIM,')$%');
	caption = strcat(caption, '%in%Subsection%3.5%by%');
	caption = strcat(caption, 'SDPT3');
	solvers = 2;
elseif strcmp(solver, 'sdpa')
	caption = 'Iter,%phasevalue,%and%DIMACS%errors%for%SDP%relaxation%problems%';
	caption = strcat(caption, 'for%BMIEPs%with%$(n,m,k)=(', NDIM,',',MDIM,',',KDIM,')$%');
	caption = strcat(caption, '%in%Subsection%3.5%by%');
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
        	nerr = Errors{solvers, SW, idx, j}.nerr;
        	err1 = Errors{solvers, SW, idx, j}.dimacs(1);err2 = Errors{solvers, SW, idx, j}.dimacs(2);
	        err3 = Errors{solvers, SW, idx, j}.dimacs(3);err4 = Errors{solvers, SW, idx, j}.dimacs(4);
        	err5 = Errors{solvers, SW, idx, j}.dimacs(5);err6 = Errors{solvers, SW, idx, j}.dimacs(6);
		if SW == 1
			if strcmp(solver, 'sdpa') == 0
        		fprintf(eid,'%5d %s Lasserre %1s %2d %s %2d %s',seed, aand, aand,iter, aand, nerr, aand);
			else
        		fprintf(eid,'%5d %s Lasserre %1s %2d %s %s %s',seed, aand, aand,iter, aand, nerr, aand);
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
fprintf(eid, '%slabel{subsec3.5_error_table_%s_nDim%s_kDim%s}\n', bS, solver, NDIM, KDIM);
fprintf(eid, '%send{table}\n', bS);
return
