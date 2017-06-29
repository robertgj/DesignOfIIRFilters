function mainTex(param, Solvers, str)

backS = char(92); % char(165);
fname = strcat('NumericalResults_', str, '.tex');
fid = fopen(fname, 'w+');
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
fprintf(fid,'\n');
fprintf(fid,'We used the following parameters:\n');
fprintf(fid, '%sbegin{itemize}\n', backS);
fprintf(fid, '%sitem {%stt sparseSW}: %d\n', backS, backS,param.sparseSW);
if ischar(param.multiCliquesFactor)
	fprintf(fid, '%sitem {%stt multiCliquesFactor}: %s\n', backS, backS,param.multiCliquesFactor);
else
	fprintf(fid, '%sitem {%stt multiCliquesFactor}: %d\n', backS, backS,param.multiCliquesFactor);
end
fprintf(fid, '%sitem {%stt boundSW}: %d\n', backS, backS,param.boundSW);
fprintf(fid, '%sitem {%stt reduceMomentMatSW}: %d\n', backS, backS,param.reduceMomentMatSW);
%fprintf(fid, '%sitem {%stt complementaritySW}: %d\n', backS, backS,param.complementaritySW);
fprintf(fid, '%sitem {%stt binarySW}: %d\n', backS,backS,param.binarySW);
fprintf(fid, '%sitem {%stt SquareOneSW}: %d\n', backS,backS,param.SquareOneSW);
fprintf(fid, '%sitem {%stt reduceAMatSW}: %d\n', backS,backS,param.reduceAMatSW);
%fprintf(fid, '%sitem {%stt elimFrSW}: %d\n', backS,backS,param.elimFrSW);
fprintf(fid, '%sitem {%stt mex}: %d\n', backS,backS,param.mex);
fprintf(fid, '%send{itemize}\n',backS);

for j=2:size(Solvers, 2)
    if ~isempty(Solvers{j})
		solverNames = strcat(Solvers{1}, '_', Solvers{j}, '_');		
		%fname  = strcat(solverNames, 'results',    '_', str,'.tex');
		fcname = strcat(solverNames, 'errors',     '_', str,'.tex');
		frname = strcat(solverNames, 'numresults', '_', str,'.tex');
		fpname = strcat(solverNames, 'popresults', '_', str,'.tex');
        %fprintf(fid, '%sinput{%s}\n', backS, fname );
        fprintf(fid, '%sinput{%s}\n', backS, frname);
        fprintf(fid, '%sinput{%s}\n', backS, fcname);
		if isfield(param, 'POPsolver') && ~isempty(param.POPsolver)
        	fprintf(fid, '%sinput{%s}\n', backS, fpname);
		end
    end
end
fprintf(fid, '\\end{document}\n');
fclose(fid);
return
