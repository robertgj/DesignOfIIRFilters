function test20110620(probNumbers)
if nargin == 0
	probNumbers = [1:72 ,74:81, 83:95];
end

v = ver('symbolic');
if isempty(v)
	ptmp = [1:12, 14:34, 37, 43:44, 47:53, 55:62, 64:69, 74:81, 83:87, 89:90, 93:95];
	probNumbers = intersect(ptmp, probNumbers);
end

if isempty(probNumbers)
	fprintf('No problems.\n');
	return
end

%param0.reduceMomentMatSW = 2;

param0.printLevel = [2,2];
param0.SDPsolverOutFile = 1;

for i=1:2
	if i == 1
		param0.POPsolver='active-set';
	else
		param0.POPsolver='';
	end
	for j=1:2
		if j == 1
			param0.errorBdIdx='a';
		else
			param0.errorBdIdx='';
		end
		for k=1:2
			if k == 1
				param0.mex = 1;
			else
				param0.mex = 0;
			end	
			solveExample(probNumbers, param0);
		end
	end
end

return
