function solveExample(probNumbers, param0, filename)
if nargin < 3
	filename = [];
end
if nargin < 2
	param0 = [];	
end
% LASTN = maxNumCompThreads(4);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Solve all POPs in the directories GMSformat and POPformat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% To solve problem 3,
%   >> solveExample(3);
% To solve problems 2, 8 and 10,
%   >> solveExample([2, 8, 10]);
% To solve problems 11 through 20,
%   >> solveExample([11:20]);
% To solve all problems,
%   >> solveExample;
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This file is a component of SparsePOP
% Copyright (C) 2007 SparsePOP Project
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% List of GAMS scalar format POPs in the directory GMSformat
% These problems are from GLOBAL Library
%	http://www.gamsworld.org/global/globallib.htm
% Lower and upper bounds of variables are added to some of the problems.
% Some problems are scaled.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
problemList{1}.name = 'Bex2_1_1.gms'; problemList{1}.relaxOrder = 3;
problemList{2}.name = 'Bex2_1_2.gms';
problemList{3}.name = 'Bex2_1_3.gms';
problemList{4}.name = 'Bex2_1_4.gms';
problemList{5}.name = 'Bex2_1_5.gms';
problemList{6}.name = 'Bex2_1_8.gms';
problemList{7}.name = 'Bex3_1_1.gms'; problemList{7}.relaxOrder = 3;
problemList{8}.name = 'Bex3_1_2.gms';
problemList{9}.name = 'Bex3_1_4.gms'; problemList{9}.relaxOrder = 4; problemList{9}.perturbation = 1.0e-6;
problemList{10}.name = 'Bex5_2_2_case1.gms'; problemList{10}.sparseSW = 0;
% or
% problemList{10}.relaxOrder = 3; problemList{10}.sparseSW = 1;
problemList{11}.name = 'Bex5_2_2_case2.gms'; problemList{11}.sparseSW = 0;
% or
% problemList{11}.relaxOrder = 3; problemList{11}.sparseSW = 1;
problemList{12}.name = 'Bex5_2_2_case3.gms'; problemList{12}.sparseSW = 0;
% or
% problemList{12}.relaxOrder = 3; problemList{12}.sparseSW = 1;
problemList{13}.name = 'Bex5_2_5.gms'; problemList{13}.relaxOrder = 1;
% nDim = 32,
% problemList{13}.relaxOrder = 2;
problemList{14}.name = 'Bex5_3_2.gms'; problemList{14}.relaxOrder = 2;
% problemList{14}.printLevel = [1, 1];
% nDim = 23,
% problemList{13}.relaxOrder = 3;
problemList{15}.name = 'Bex5_4_2.gms'; problemList{15}.relaxOrder = 3;
problemList{16}.name = 'Bex9_1_1.gms'; problemList{16}.complementaritySW = 1;
problemList{17}.name = 'Bex9_1_2.gms'; problemList{17}.relaxOrder = 3; problemList{17}.complementaritySW = 1;
problemList{18}.name = 'Bex9_1_4.gms'; problemList{18}.complementaritySW = 1; problemList{18}.perturbation = 1.0e-6;
problemList{19}.name = 'Bex9_1_5.gms'; problemList{19}.complementaritySW = 1; problemList{19}.perturbation = 1.0e-6;
problemList{20}.name = 'Bex9_1_8.gms'; problemList{20}.complementaritySW = 1;
problemList{21}.name = 'Bex9_2_1.gms'; problemList{21}.sparseSW = 0; problemList{21}.complementaritySW = 1;
problemList{22}.name = 'Bex9_2_2.gms'; problemList{22}.complementaritySW = 1;
problemList{23}.name = 'Bex9_2_3.gms'; % problemList{23}.complementaritySW = 1;
problemList{24}.name = 'Bex9_2_4.gms'; problemList{24}.sparseSW = 0; problemList{24}.complementaritySW = 1;
problemList{25}.name = 'Bex9_2_5.gms'; problemList{25}.complementaritySW = 1;
problemList{26}.name = 'Bex9_2_6.gms'; problemList{26}.sparseSW = 0; problemList{26}.complementaritySW = 1;
problemList{27}.name = 'Bex9_2_7.gms'; problemList{27}.sparseSW = 0; problemList{27}.complementaritySW = 1;
problemList{28}.name = 'Bex9_2_8.gms'; problemList{28}.complementaritySW = 1;
problemList{29}.name = 'Balkyl.gms';   problemList{29}.relaxOrder = 3;
problemList{30}.name = 'Bst_bpaf1a.gms';
problemList{31}.name = 'Bst_bpaf1b.gms';
problemList{32}.name = 'Bst_e05.gms';
problemList{33}.name = 'Bst_e07.gms';
problemList{34}.name = 'Bst_jcbpaf2.gms';
problemList{35}.name = 'Bhaverly.gms';
problemList{36}.name = 'Babel.gms';
problemList{37}.name = 'alkylation.gms'; problemList{37}.relaxOrder = 3; problemList{37}.perturbation = 1.0e-4;
problemList{38}.name = 'Bst_bpk1.gms';
problemList{39}.name = 'Bst_bpk2.gms';
problemList{40}.name = 'Bst_bpv1.gms';
problemList{41}.name = 'Bst_bpv2.gms';
problemList{42}.name = 'Bst_e33.gms';
problemList{43}.name = 'Bst_e42.gms';
problemList{44}.name = 'Bst_robot.gms'; problemList{44}.perturbation = 1.0e-4;
problemList{45}.name = 'meanvar.gms';   problemList{45}.relaxOrder = 1;
problemList{46}.name = 'mhw4d.gms';
% problemList{47}.name = 'Bprolog.gms';
problemList{47}.name = [];
problemList{48}.name = 'st_cqpjk2.gms';
problemList{49}.name = 'st_e01.gms';
problemList{50}.name = 'st_e09.gms'; problemList{50}.relaxOrder = 3;
problemList{51}.name = 'st_e10.gms';
%
%problemList{52}.name = 'st_e20.gms';% This POP containts square roots.
problemList{52}.name ='';
problemList{53}.name = 'st_e23.gms';
problemList{54}.name = 'st_e24.gms';
problemList{55}.name = 'st_e34.gms';
% problemList{56}.name = 'st_e42.gms';
problemList{56}.name = [];
problemList{57}.name = 'st_fp5.gms';
problemList{58}.name = 'st_glmp_fp1.gms';
problemList{59}.name = 'st_glmp_fp2.gms'; problemList{59}.relaxOrder = 3;
problemList{60}.name = 'st_glmp_fp3.gms';
problemList{61}.name = 'st_glmp_kk90.gms';
%
problemList{62}.name = 'st_glmp_kk92.gms';
problemList{63}.name = 'st_glmp_kky.gms';
problemList{64}.name = 'st_glmp_ss1.gms';
problemList{65}.name = 'st_glmp_ss2.gms';
problemList{66}.name = 'st_iqpbk1.gms';
problemList{67}.name = 'st_iqpbk2.gms';
problemList{68}.name = 'st_jcbpaf2.gms';
problemList{69}.name = 'st_jcbpafex.gms';
problemList{70}.name = 'qp1.gms'; problemList{70}.relaxOrder = 1;
problemList{71}.name = 'qp2.gms'; problemList{71}.relaxOrder = 1;
%
problemList{72}.name = 'qp3.gms'; problemList{72}.relaxOrder = 1;
%problemList{72}.name = [];
problemList{73}.name = 'qp5.gms'; problemList{73}.relaxOrder = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% List of the SparsePOP format POPs in the directory POPformat
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
problemList{74}.name = 'RosenbrockLS(200,1)'; % problemList{74}.printLevel = [1, 1];
problemList{75}.name = 'BroydenBand(6)'; problemList{75}.relaxOrder = 3;
problemList{76}.name = 'BroydenTriLS(200)'; % problemList{76}.printLevel = [1, 1];
problemList{77}.name = 'ChainedSingular(200)'; % problemList{77}.printLevel = [1, 1];
problemList{78}.name = 'ChainedWood(200)'; % problemList{78}.printLevel = [1, 1];
problemList{79}.name = 'nondquar(200)'; % problemList{79}.printLevel = [1, 1];
problemList{80}.name = 'nonscomp(8)'; % problemList{80}.relaxOrder = 3;
problemList{81}.name = 'optControl(6,2,4,0)'; % problemList{81}.printLevel = [1, 1];
problemList{82}.name = 'optControl2(200)'; % problemList{82}.printLevel = [1, 1];
problemList{83}.name = 'randomUnconst(20,2,4,4,3201)';
problemList{84}.name = 'randomConst(20,2,4,4,3201)'; problemList{84}.relaxOrder = 3;
problemList{85}.name = 'randomwithEQ(20,2,4,4,3201)'; problemList{85}.relaxOrder = 2;
problemList{86}.name = 'genBMIEP(3,4,5,0)'; problemList{86}.relaxOrder = 2;
problemList{87}.name = 'alan.gms'; problemList{87}.relaxOrder = 2;
problemList{88}.name = 'himmel11.gms'; problemList{88}.relaxOrder = 2;
problemList{89}.name = 'gbd.gms'; problemList{89}.relaxOrder = 2;
problemList{90}.name = 'meanvarx.gms'; problemList{90}.relaxOrder = 2;
problemList{91}.name = 'sched-4-4711.gms'; problemList{91}.relaxOrder = 2;
problemList{92}.name = 'elimy.gms'; problemList{92}.relaxOrder = 2;
problemList{93}.name = 'genMAXCUT(8,1)'; problemList{93}.relaxOrder = 2;
problemList{94}.name = 'genBQP(8, 1)'; problemList{94}.relaxOrder = 2;
problemList{95}.name = 'genPIS(8)'; problemList{95}.relaxOrder = 2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[param0] = defaultParameter(param0);
param0.printLevel = [0,0];
%%%%%
% Choose
%param0.POPsolver = 'active-set';
%param0.POPsolver = '';
% or
if exist('fmincon', 'file') ~= 2
    param0.POPsolver = [];
end

%param0.SDPsolver='sdpt3';
%param0.errorBdIdx = '';
%param0.mex = 0;
%param0.matFile=strcat('mex',num2str(param0.mex),'.mat');
param0.SDPsolverOutFile = 1;
%param0.detailedInfFile = strcat('dmex',num2str(param0.mex), '.out');
if isempty(filename) || nargin < 3
	param0.printFileName = strcat('tmpsp302.dev_mex',num2str(param0.mex),'_',param0.errorBdIdx,'_', param0.POPsolver,'.out');
else
	param0.printFileName = filename;
end
param0.printLevel = [2,2];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin == 0
    %    if strcmp(param0.SDPsolver,'sdpa')
    %        probNumbers = [1:12,14:72, 74:85];
    %    else
    probNumbers = [1:72 ,74:81, 83:95];
    %    end
    if param0.symbolicMath == 0
        if ~isfield(param0, 'SDPsolver') || strcmp(param0.SDPsolver,'sedumi')
            probNumbers = [1:12, 14:34, 37, 43:44, 47:53, 55:62, 64:69, 74:81, 83:87, 89:90, 93:95];
        else
            probNumbers = [1:12, 14:34, 37, 43:44, 47:53, 55:62, 64:69, 74:87, 89:90, 93:95];
        end
    end
else
    if ~isfield(param0, 'SDPsolver') || strcmp(param0.SDPsolver,'sedumi')
        %
        % 2010-01-08 H. Waki
        %
        % SeDuMi_1_21 can not solve SDP relaxation problems
        % generated from qp3.gms and optControl2(200).
        % So, we skip these problems if 'probNumbers' contains them.
        idx73 = find(probNumbers == 73);
        idx82 = find(probNumbers == 82);
        idx = [idx73, idx82];
        probNumbers(idx) = [];
    end
end
% for my macbook
%idx6 = find(probNumbers == 6);
%probNumbers(idx6) = [];
%idx72 = find(probNumbers == 72);
%probNumbers(idx72) = [];
%
% Users should set SDP solvers for solving SDP relaxation problems.
% Users can use SeDuMi, SDPA, SDPT3, CSDP and SDPNAL.
%
% Remark:
% Names of some functions in SeDuMi coincide with those in SDPT3 and/or SDPNAL.
% (e.g. choltmpsiz.m)
% In addition, names of some functions in SDPT3 coincide with those in SDPNAL.
% (e.g. AXfun.m)
% We recommend that if one of these SDP solvers is used, then users should
% remove the others from your MATLAB path 
%
noSolvers = 1;
Solvers = cell(1, noSolvers);
Solvers{1} = 'sedumi';
%Solvers{2} = 'sdpa';
%Solvers{3} = 'csdp';
%Solvers{4} = 'sdpt3';
%Solvers{5} = 'sdpNAL';
if noSolvers ~= size(Solvers, 2)
    error('noSolvers mismatch the size of Solvers.');
end
for i=1:noSolvers
    if isempty(Solvers{i})
        error('## Some of ''Solvers'' are empty.');
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


Esize = noSolvers;
sedumiInfoVec = cell(1,Esize);
compResult = cell(1,Esize);
for k = probNumbers
	fileName = problemList{k}.name;
	if ~isempty(fileName)
		for solver = 1:noSolvers
			param = getParam(problemList{k}, Solvers{solver},param0);
			fprintf('\n\n%d: %s\n', k, fileName);
			[param,SDPobjValue,POP,cpuTime,SeDuMiInfo,SDPinfo] = sparsePOP(fileName,param);
			oneLine = getInfo(SeDuMiInfo, param);
			sedumiInfoVec{solver} = [sedumiInfoVec{solver}; oneLine];
			oneLine = getResult(POP, SDPinfo, cpuTime, SDPobjValue, param);
			compResult{solver} = [compResult{solver}; full(oneLine)];
		end
	else
		param = param0;
	end
end
if noSolvers > 1
	%printTexMultiple(param, Solvers, probNumbers, problemList, compResult, sedumiInfoVec, Esize);
elseif noSolvers == 1
	%printTexSingle(param, probNumbers, problemList, compResult, sedumiInfoVec, Esize);
end
return

function param = getParam(problemList, solver, param0)
param = param0;
param.SDPsolver = solver;
if isfield(problemList,'sparseSW')
	param.sparseSW = problemList.sparseSW;
end
if isfield(problemList,'relaxOrder')
	param.relaxOrder = problemList.relaxOrder;
else
	param.relaxOrder = 2;
end
if isfield(problemList,'perturbation')
	param.perturbation = problemList.perturbation;
end
if isfield(problemList,'complementaritySW')
	param.complementaritySW = problemList.complementaritySW;
end
if isfield(param0,'POPsolver') && ~isempty(param0.POPsolver) &&  isfield(problemList,'POPsolver')
	param.POPsolver = problemList.POPsolver;
end
if isfield(problemList,'printLevel')
	param.printLevel = problemList.printLevel;
end
if strcmp(param.SDPsolver, 'csdp') || strcmp(param.SDPsolver, 'sdpNAL')
	param.errorBdIdx = '';
end

return

function oneLine = getResult(POP, SDPinfo, cpuTime, SDPobjValue, param)
if isempty(SDPobjValue)
	SDPobjValue = NaN;
end
if isempty(POP.objValue)
	POP.objValue = NaN;
end
if isempty(POP.absError)
	POP.absError = NaN;
end
if isempty(POP.scaledError)
	POP.scaledError = NaN;
end
oneLine = param.relaxOrder;
oneLine = [oneLine,SDPinfo.rowSizeA];
oneLine = [oneLine,SDPinfo.colSizeA];
oneLine = [oneLine,SDPinfo.nonzerosInA];
oneLine = [oneLine,cpuTime.SDPsolver];
if ~isfield(param,'POPsolver') || isempty(param.POPsolver)
	relError = (POP.objValue-SDPobjValue)/(max([1,abs(POP.objValue)]));
	oneLine = [oneLine,SDPobjValue];
	oneLine = [oneLine,POP.objValue];
	oneLine = [oneLine,relError];
	oneLine = [oneLine,POP.absError];
else
	oneLine = [oneLine,cpuTime.localMethod];
	relErrorL = (POP.objValueL-SDPobjValue)/(max([1,abs(POP.objValueL)]));
	if ~isempty(relErrorL)
		oneLine = [oneLine,relErrorL];
	else
		oneLine = [oneLine,NaN];
	end
	if ~isempty(POP.absErrorL)
		oneLine = [oneLine,POP.absErrorL];
	else
		oneLine = [oneLine,NaN];
	end
	relError = (POP.objValue-SDPobjValue)/(max([1,abs(POP.objValue)]));
	oneLine = [oneLine,SDPobjValue];
	oneLine = [oneLine,POP.objValue];
	oneLine = [oneLine,relError];
	oneLine = [oneLine,POP.absError];
	if ~isempty(POP.objValueL)
		oneLine = [oneLine,POP.objValueL];
	else
		oneLine = [oneLine,NaN];
	end
end
return

function oneLine = getInfo(SeDuMiInfo, param)
if strcmp(param.SDPsolver, 'sedumi')
	iter = SeDuMiInfo.iter;
	nerr = SeDuMiInfo.numerr;
	feas = SeDuMiInfo.feasratio;
	errs = SeDuMiInfo.err;
elseif strcmp(param.SDPsolver, 'sdpa')
	iter = SeDuMiInfo.iteration;
	if strcmp(SeDuMiInfo.phasevalue, 'pdOPT')
		nerr = 0;
	elseif strcmp(SeDuMiInfo.phasevalue, 'pdFEAS')
		nerr = 1;
	elseif strcmp(SeDuMiInfo.phasevalue, 'dFEAS')
		nerr = 2;	
	elseif strcmp(SeDuMiInfo.phasevalue, 'pFEAS')
		nerr = 3;	
	elseif strcmp(SeDuMiInfo.phasevalue, 'pFEAS_dINF')
		nerr = 4;	
	elseif strcmp(SeDuMiInfo.phasevalue, 'pINF_dFEAS')
		nerr = 5;	
	elseif strcmp(SeDuMiInfo.phasevalue, 'pUNBD')
		nerr = 6;	
	elseif strcmp(SeDuMiInfo.phasevalue, 'dUNBD')
		nerr = 7;
	elseif strcmp(SeDuMiInfo.phasevalue, 'pdINF')
		nerr = 8;
	elseif strcmp(SeDuMiInfo.phasevalue, 'noINFO')
		nerr = 9;
	else
		nerr = -1;
	end
	feas = max(SeDuMiInfo.primalError, SeDuMiInfo.dualError);
	errs = SeDuMiInfo.dimacs';
elseif strcmp(param.SDPsolver, 'sdpt3')
	iter = SeDuMiInfo.iter;
	nerr = SeDuMiInfo.numerr;
	feas = max(SeDuMiInfo.pinfeas, SeDuMiInfo.dinfeas);
	errs = SeDuMiInfo.dimacs';
elseif strcmp(param.SDPsolver, 'sdpnal')
	iter = SeDuMiInfo.iter;
	nerr = SeDuMiInfo.numerr;
	feas = max(SeDuMiInfo.errs(1), SeDuMiInfo.errs(3));
	errs = SeDuMiInfo.errs;
end
oneLine = [iter, nerr, feas, errs(1:6)];
return
