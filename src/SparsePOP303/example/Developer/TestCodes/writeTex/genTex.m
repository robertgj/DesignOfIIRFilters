function genTex(param, compResult, sedumiInfoVec, Errors, subsecNO, DefaultSeed, density, Vec)
%
% This function generates detailed results as tex file.
%
% 2012-04-07 M.Muramatsu, H.Waki and L.Tuncel
%
if nargin < 8
	Vec = [];
end

if nargin < 7 
	density = [];
	Vec = [];
end
if nargin < 6
	DefaultSeed = [];
	density = 1.0;
end

solver = param.SDPsolver;
backS = char(92); % char(165);
if subsecNO == 1 || subsecNO == 2 || subsecNO == 3
	fname = strcat('sec3.', num2str(subsecNO), '.tex');
	solver = [];
elseif subsecNO == 5
	ro = num2str(param.relaxOrder);
	fname = strcat('sec3.', num2str(subsecNO), '_ro', ro, '.tex');
elseif ~isempty(density)
	DENSITY = num2str(density);
	fname = strcat('sec3.', num2str(subsecNO), '_density', DENSITY, '.tex');
end
fid = fopen(fname, 'w+');
fprintf(fid, '%sdocumentclass[10pt]{article}\n', backS);
fprintf(fid, '%susepackage{graphicx}\n', backS);
fprintf(fid, '%ssetlength{%sevensidemargin}{0cm}\n', backS,backS);
fprintf(fid, '%ssetlength{%soddsidemargin}{0cm}\n', backS,backS);
fprintf(fid, '%ssetlength{%stextwidth}{6.45in}\n', backS,backS);
fprintf(fid, '%ssetlength{%stextheight}{9.2in}\n', backS,backS);
fprintf(fid, '%ssetlength{%stopmargin}{0.5in}\n', backS,backS);
fprintf(fid, '%ssetlength{%sheadheight}{0in}\n', backS,backS);
fprintf(fid, '%ssetlength{%sheadsep}{0in}\n', backS,backS);
fprintf(fid, '%ssetlength{%stopskip}{0in}\n', backS,backS);
fprintf(fid, '%spagestyle{empty}\n', backS);
if ~isempty(density)
	fprintf(fid, '%stitle{The details of numerical results in Subsection 3.%d with density %3.2f}\n', backS, subsecNO, density);
elseif subsecNO == 5
	fprintf(fid, '%stitle{The details of numerical results in Subsection 3.%d with relaxation order %d}\n', backS, subsecNO, param.relaxOrder);
else
	fprintf(fid, '%stitle{The details of numerical results in Subsection 3.%d}\n', backS, subsecNO);
end
fprintf(fid, '%sauthor{M. Muramatsu, H. Waki and L. Tun{%sc c}el}\n', backS, backS);
fprintf(fid, '%sdate{%stoday}\n', backS, backS);
fprintf(fid, '%sbegin{document}\n', backS);
fprintf(fid, '%spagestyle{empty}\n', backS);
fprintf(fid, '%smaketitle\n', backS);
if subsecNO == 1
	genTex3_1(param, compResult, sedumiInfoVec, Errors);
	fprintf(fid, '%sinput{sec3.1_table.tex}\n', backS);
	fprintf(fid, '%sinput{sec3.1_info_table.tex}\n', backS);
	fprintf(fid, '%sinput{sec3.1_error_table.tex}\n', backS);
elseif subsecNO == 2
	genTex3_2(param, compResult, sedumiInfoVec, Errors);
	fprintf(fid, '%sinput{sec3.2_table.tex}\n', backS);
	fprintf(fid, '%sinput{sec3.2_info_table_%s.tex}\n', backS, 'sedumi');
	fprintf(fid, '%sinput{sec3.2_error_table_%s.tex}\n', backS, 'sedumi');
	fprintf(fid, '%sinput{sec3.2_info_table_%s.tex}\n', backS, 'sdpt3');
	fprintf(fid, '%sinput{sec3.2_error_table_%s.tex}\n', backS, 'sdpt3');
elseif subsecNO == 3
	genTex3_3(param, compResult, sedumiInfoVec, Errors, DefaultSeed);
	fprintf(fid, '%sinput{sec3.3_table.tex}\n', backS);
	fprintf(fid, '%sclearpage\n', backS);
	N = size(sedumiInfoVec, 3);
	for i=1:N
		nDim = 5*i;
		fprintf(fid, '%sinput{sec3.3_info_table_sedumi_nDim%d.tex}\n', backS, nDim);
		fprintf(fid, '%sinput{sec3.3_error_table_sedumi_nDim%d.tex}\n', backS, nDim);
		fprintf(fid, '%sclearpage\n', backS);
		fprintf(fid, '%sinput{sec3.3_info_table_sdpt3_nDim%d.tex}\n', backS, nDim);
		fprintf(fid, '%sinput{sec3.3_error_table_sdpt3_nDim%d.tex}\n', backS, nDim);
		fprintf(fid, '%sclearpage\n', backS);
	end
elseif subsecNO == 4
	fprintf(fid, '%ssection{The case where the density is %2.1f}\n', backS, density);
	genTex3_4(param, compResult, sedumiInfoVec, Errors, DefaultSeed, density);
	DENSITY = num2str(density);
	fprintf(fid, '%sinput{sec3.4_table_density%s.tex}\n', backS, DENSITY);
	fprintf(fid, '%sclearpage\n', backS);
	N = size(compResult, 3);
	for i=1:N
		if i > 12
			nDim = 10*(i-6);
		else
			nDim = 5*i;
		end
		fprintf(fid, '%sinput{sec3.4_info_table_sedumi_nDim%d_density%s.tex}\n', backS, nDim, DENSITY);
		fprintf(fid, '%sinput{sec3.4_error_table_sedumi_nDim%d_density%s.tex}\n', backS, nDim, DENSITY);
		fprintf(fid, '%sclearpage\n', backS);
		fprintf(fid, '%sinput{sec3.4_info_table_sdpt3_nDim%d_density%s.tex}\n', backS, nDim, DENSITY);
		fprintf(fid, '%sinput{sec3.4_error_table_sdpt3_nDim%d_density%s.tex}\n', backS, nDim, DENSITY);
		fprintf(fid, '%sclearpage\n', backS);
	end
elseif subsecNO == 5
	genTex3_5(param, compResult, sedumiInfoVec, Errors, DefaultSeed, Vec);
	ro = param.relaxOrder;
	fprintf(fid, '%sinput{sec3.5_table_ro%d.tex}\n', backS, ro);
	fprintf(fid, '%sclearpage\n', backS);
	N = size(Vec, 1);
	for i=1:N
		nDim = Vec(i, 1)+Vec(i, 2)+1;
		kDim = Vec(i, 3);
		solver = 'sedumi';
		fprintf(fid, '%sinput{sec3.5_info_table_%s_nDim%d_kDim%d_ro%d.tex}\n', backS, solver, nDim, kDim, ro);
		fprintf(fid, '%sinput{sec3.5_error_table_%s_nDim%d_kDim%d_ro%d.tex}\n', backS, solver, nDim, kDim, ro);
		fprintf(fid, '%sclearpage\n', backS);
		solver = 'sdpt3';
		fprintf(fid, '%sinput{sec3.5_info_table_%s_nDim%d_kDim%d_ro%d.tex}\n', backS, solver, nDim, kDim, ro);
		fprintf(fid, '%sinput{sec3.5_error_table_%s_nDim%d_kDim%d_ro%d.tex}\n', backS, solver, nDim, kDim, ro);
		fprintf(fid, '%sclearpage\n', backS);
	end
end
fprintf(fid, '%send{document}\n', backS);
fclose(fid);
return
