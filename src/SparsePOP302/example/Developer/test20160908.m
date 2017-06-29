function test20160908(pname)
if nargin == 0 || isempty(pname) || exist(pname, 'file') ~= 2
	fprintf('No problems.\n');
	return
end

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
				param0.printFileName = filename;
				sparsePOP(pname, param0);
			end
		end
	end
end
return
