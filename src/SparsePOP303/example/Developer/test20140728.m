function test20140728(probNumbers)
if nargin == 0
	probNumbers = [1:72 ,75, 80:81, 83:95];
end

v = ver('symbolic');
if isempty(v)
	ptmp = [1:12, 14:34, 37, 43:44, 47:53, 55:62, 64:69, 75, 81, 83:87, 89:90, 93:95];
	probNumbers = intersect(ptmp, probNumbers);
end

if isempty(probNumbers)
	fprintf('No problems.\n');
	return
end

%param0.reduceMomentMatSW = 2;

param0.printLevel = [2,2];
param0.SDPsolverOutFile = 1;
param0.POPsolver='active-set';
param0.errorBdIdx='a';

for i=1:2
	if i == 1
		param0.reduceMomentMatSW = 2;
	else
		param0.reduceMomentMatSW = 1;
	end
	for j=1:2
		if j == 1
			param0.aggressiveSW = 1;
		else
			param0.aggressiveSW = 0;
		end
		for k=1:2
			if k == 1
				param0.mex = 1;
			else
				param0.mex = 0;
			end
			for ell=1:2
				if ell == 1
					param0.sparseSW = 1;
				else
					param0.sparseSW = 3;
				end
				MEX = num2str(param0.mex);
				MOM = num2str(param0.reduceMomentMatSW);
				AGG = num2str(param0.aggressiveSW);
				SPSW = num2str(param0.sparseSW);
				filename = strcat('tmpsp302_mex', MEX, '_redMOM', MOM, '_agg', AGG, '_SPSW', SPSW, '.out');	
				solveExample(probNumbers, param0, filename);
			end
		end
	end
end
return
