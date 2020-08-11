function work_check_sparsepop;
mrelease=version('-release');
fprintf('\n\n*** MATLAB %s Start ***\n\n', mrelease);
verS=303;
verS=num2str(verS);
ext = mexext;
if strcmp(ext, 'mexa64')'
	matlab_path='/home/waki9/Dropbox/matlab/';
elseif strcmp(ext, 'mexmaci64')
	matlab_path='/Users/waki9/Dropbox/matlab/';
end
Spath=strcat(matlab_path, 'SparsePOP', verS);
addpath(genpath(Spath));
Sedpath=strcat(matlab_path, 'sedumi-master');
addpath(genpath(Sedpath));
sdpnalp = 0; 
if sdpnalp == 1
	sdpnalppath=strcat(matlab_path, 'SDPNAL+v1.0');
	addpath(genpath(sdpnalppath));
	param0.SDPsolver = 'sdpnalplus';
end
debugSW = 0;
if debugSW == 1
	prob = [1:14, 28];
	test20110620(prob);
else
	%test20140728;
	prob1 = [36, 29, 2, 3, 13, 21, 24, 25, 27, 35, 38, 39, 40];
	if sdpnalp == 1
		prob2 = [41, 32, 42, 44, 92, 88, 45, 54];
	else
		prob2 = [41, 32, 42, 44, 92, 88, 45, 46, 72, 54, 63];
	end
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
	if sdpnalp ~= 1
		test20160908('Bex2_1_9.gms', param0);
		test20160908('Bex5_3_3.gms', param0);
		test20160908('Bprolog.gms', param0);
		test20160908('Bprolog2.gms', param0);
		%test20160908('Bex9_2_4.gms');
		%test20160908('Babel.gms');
		%test20160908('Bex2_1_9.gms');
	end
end
fprintf('\n\n*** MATLAB %s Quit ***\n\n', mrelease);
exit;
return
