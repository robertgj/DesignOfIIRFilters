function work_check_sparsepop;
mrelease=version('-release');
fprintf('\n\n*** MATLAB %s Start ***\n\n', mrelease);
verS=302;
verS=num2str(verS);
ext = mexext;
if strcmp(ext, 'mexa64')'
	matlab_path='/home/waki9/Dropbox/matlab/';
elseif strcmp(ext, 'mexmaci64')
	matlab_path='/Users/waki9/Dropbox/matlab/';
end
Spath=strcat(matlab_path, 'SparsePOP', verS);
addpath(genpath(Spath));
Sedpath=strcat(matlab_path, 'SeDuMi_1_3');
addpath(genpath(Sedpath));
debugSW = 0;
if debugSW == 1
	prob = [1:14, 28];
	test20110620(prob);
else
	%test20140728;
	prob1 = [36, 29, 2, 3, 13, 21, 24, 25, 27, 35, 38, 39, 40];
	prob2 = [41, 32, 42, 44, 92, 88, 45, 46, 70, 71, 72, 54, 63];
	prob = sort([prob1, prob2]);
	param0.printLevel = [2,2];
	param0.SDPsolverOutFile = 1;
	for k=1:2
		if k == 1
			param0.mex = 1;
		else
			param0.mex = 0;
		end	
		solveExample(prob, param0);
	end
	test20160908('Bex2_1_9.gms');
	test20160908('Bex5_3_3.gms');
	test20160908('Bprolog.gms');
	test20160908('Bprolog2.gms');
	%test20160908('Bex9_2_4.gms');
	%test20160908('Babel.gms');
	%test20160908('Bex2_1_9.gms');
end
fprintf('\n\n*** MATLAB %s Quit ***\n\n', mrelease);
exit;
return
