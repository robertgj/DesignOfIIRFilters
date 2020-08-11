function testForDebug


problemList{01}.name = 'example10.gms';
problemList{02}.name = 'example11.gms';
problemList{03}.name = 'example12.gms';
problemList{04}.name = 'example13.gms';
problemList{05}.name = 'example14.gms';
problemList{06}.name = 'example15.gms';
problemList{07}.name = 'example16.gms';
problemList{08}.name = 'example110(5)';
problemList{09}.name = 'example111(5)';
problemList{10}.name = 'example112(5)';
problemList{11}.name = 'example113(5)';
problemList{12}.name = 'example114(5)';
problemList{13}.name = 'example115(5)';
problemList{14}.name = 'example2.gms';
problemList{15}.name = 'example20.gms';
problemList{16}.name = 'example21.gms';
problemList{17}.name = 'example22.gms';
problemList{18}.name = 'example30.gms';
problemList{19}.name = 'example31.gms';
problemList{20}.name = 'example32.gms';
problemList{21}.name = 'example33.gms';
problemList{22}.name = 'example40.gms';
problemList{23}.name = 'example41.gms';
problemList{24}.name = 'example42.gms';
problemList{25}.name = 'example43.gms';
problemList{26}.name = 'exampleInfeasible.gms';
problemList{27}.name = 'exampleUnbound.gms';
problemList{28}.name = 'parenthesis.gms';
problemList{29}.name = 'parenthesis2.gms';
problemList{30}.name = 'noConstantTerm.gms';
problemList{31}.name = 'elimy.gms';
problemList{32}.name = 'example2.gms';
problemList{33}.name = 'Cex9_2_8.gms';
problemList{34}.name = 'strange.gms';

param.POPsolver='active-set';
param.errorBdIdx='a';
for r=1:2
	param.relaxOrder = r;
	for i=1:2
		param.mex = i-1;
		param.printFileName = strcat('check_mex', num2str(param.mex), '.out');
		for k=1:size(problemList, 2)
			problem = problemList{k}.name;
			[param0,SDPobjValue,POP,cpuTime,SDPsolverInfo,SDPinfo] = sparsePOP(problem,param);
		end
		param.aggressiveSW = 1;
		[param0,SDPobjValue,POP,cpuTime,SDPsolverInfo,SDPinfo] = sparsePOP(problemList{30}.name,param);	
		[param0,SDPobjValue,POP,cpuTime,SDPsolverInfo,SDPinfo] = sparsePOP(problemList{31}.name,param);	
		param.aggressiveSW = 0;
	end
end

return
