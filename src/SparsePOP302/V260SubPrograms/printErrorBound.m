function printErrorBound(fileId,fValue,param,POP, SDPinfo)
if nargin == 4
	SDPinfo.infeasibleSW = 0;
	SDPinfo.dimVar0= size(SDPinfo.Amat,2);
	SDPinfo.dimVar = size(SDPinfo.xVect,2);
end
% 2011-07-03 H.Waki
% Comment for reduceAMatSW = 1
%if SDPinfo.dimVar ~= SDPinfo.dimVar0
%	if (param.printLevel(1) >= 1) 
%		fprintf('## Cannot apply the computation of error bounds because\n');
%		fprintf('## some variables in POP are removed by param.reduceAMatSW = 1.\n');
%		fprintf('## To compute error bounds, set param.reduceAMatSW = 0.\n');
%	end
%	if isfield(param,'printFileName') && ~isempty(param.printFileName) && isstr(param.printFileName)
%		fileId = fopen(param.printFileName,'a+');
%		fprintf(fileId, '## Cannot apply the computation of error bounds because\n');
%		fprintf(fileId, '## some variables in POP are removed by param.reduceAMatSW = 1.\n');
%		fprintf(fileId, '## To compute error bounds, set param.reduceAMatSW = 0.\n');
%		fclose(fileId);
%	end
%	return
if isempty(POP.xVect) && SDPinfo.infeasibleSW == 0.5
	fprintf(fileId, '## Cannot apply the computation of error bounds because\n');
	fprintf(fileId, '## the SDP relaxation problem is infeasible or the solution\n');
	fprintf(fileId, '## obtained by %s is very inaccurate.\n\n', param.SDPsolver);
	return	
elseif isempty(POP.xVect) || (isfield(param, 'POPsolver') && ~isempty(param.POPsolver) && isempty(POP.xVectL))
	fprintf(fileId, '## Cannot apply the computation of error bounds because\n');
	fprintf(fileId, '## SparsePOP cannot generate an approximate solution.\n');
	%if param.reduceMomentMatSW == 1
	%	fprintf(fileId, '## If you want to compute error bounds of an approximate solution of this problem,\n'); 
	%	fprintf(fileId, '## please solve this problem with param.reduceMomentMatSW = 0.\n\n');
	%end
	return
end
if fileId == 1
	printLevel = param.printLevel(1);
else
	printLevel = param.printLevel(2);
end
if iscell(param.errorBdIdx) 
	rr = size(param.errorBdIdx,2);
else
	rr = 1;
end
for r = 1:rr
	if iscell(param.errorBdIdx)
		errorBdIdx = param.errorBdIdx{r}; 
	else
		errorBdIdx = param.errorBdIdx;
	end
%        zeta = full(POP.zeta(r));
	zeta = sqrt(full(POP.zeta(r)));
	xCenter = full(POP.xCenter(r,:)); 
	if length(errorBdIdx) == length(xCenter)
		if iscell(param.errorBdIdx) 
			fprintf(fileId,'## Error bound with param.errorBdIdx{%d} = [ 1:%d ]\n',r,length(xCenter));
		else
			fprintf(fileId,'## Error bound with param.errorBdIdx = [ 1:%d ]\n',length(xCenter));
		end
		fprintf(fileId,'   ||x - POP.xCenter(%d,:)|| <= sqrt(POP.zeta(%d)) = %+12.7e\n',r,r,zeta);
		fprintf(fileId,'   ||x - POP.xCenter(%d,:)||/max{1,||POP.xCenter(%d,:)||} <= %+12.7e\n',r,r,zeta/max([1,norm(POP.xCenter(r,:))]));
		fprintf(fileId,'   for every feasible solution x of the POP with the obj. value <= %+13.7e.\n',fValue); 
		if printLevel >=2
			fprintf(fileId,'   Here POP.xCenter(%d,:) = \n',r);
				lenOFx = length(xCenter);
				ii = 0;
				for j=1:lenOFx
					ii = ii+1;
					fprintf(fileId,'  %4d:%+13.7e',j,full(xCenter(j)));
					if ii == 5
						fprintf(fileId,'\n');
						ii = 0;
					end
				end
				if ii > 0
					fprintf(fileId,'\n');
				end
			end            
		elseif length(errorBdIdx) == 1
			if iscell(param.errorBdIdx) 
				fprintf(fileId,'## Error bound with param.errorBdIdx{%d} = [ %d ]\n',r,errorBdIdx);
			else
				fprintf(fileId,'## Error bound with param.errorBdIdx = [ %d ]\n',errorBdIdx);
			end
			fprintf(fileId,'   |x(%d) - POP.xCenter(%d,%d)| <= sqrt(POP.zeta(%d)) = %+12.7e\n',errorBdIdx,r,errorBdIdx,r,zeta);
			fprintf(fileId,'   |x(%d) - POP.xCenter(%d,%d)|/max{1,|POP.xCenter(%d,%d)|} <= %+12.7e\n',errorBdIdx,r,errorBdIdx,r,errorBdIdx,zeta/max([1,abs(POP.xCenter(r,errorBdIdx))]));
			fprintf(fileId,'   for every feasible solution x of the POP with the obj. value <= %+13.7e.\n',fValue); 
			fprintf(fileId,'   Here POP.xCenter(%d,%d) = %+13.7e\n',r,errorBdIdx,full(xCenter(errorBdIdx)));
		else % 1 < length(errorBdIdx) < length(xCenter)
			if iscell(param.errorBdIdx) 
				fprintf(fileId,'## Error bound with param.errorBdIdx{%d} = [ ',r);
			else
				fprintf(fileId,'## Error bound with param.errorBdIdx = [ ');
			end
			for i=1:length(errorBdIdx)
				fprintf(fileId,'%d ',errorBdIdx(i));                    
			end
			fprintf(fileId,']\n'); 
			if iscell(param.errorBdIdx)           
				fprintf(fileId,'   ||x(param.errorBdIdx{%d}) - POP.xCenter(%d,param.errorBdIdx{%d})|| <= sqrt(POP.zeta(%d)) = %+12.7e\n',r,r,r,r,zeta);
				fprintf(fileId,'   ||x(param.errorBdIdx{%d}) - POP.xCenter(%d,param.errorBdIdx{%d})||/||max{1,POP.xCenter(%d,param.errorBdIdx{%d})||} <=  %+12.7e\n',...
					r,r,r,r,r,zeta/max([1,norm(POP.xCenter(r,errorBdIdx))]));               
				%fprintf(fileId,'   ||x(param.errorBdIdx{%d}) - POP.xCenter(%d,param.errorBdIdx{%d})||/||POP.xCenter(%d,param.errorBdIdx{%d})|| <=  %+12.7e\n',...
				%	r,r,r,r,r,zeta/norm(POP.xCenter(r,errorBdIdx)));               
			else
				fprintf(fileId,'   ||x(param.errorBdIdx) - POP.xCenter(%d,param.errorBdIdx)|| <= sqrt(POP.zeta(%d)) = %+12.7e\n',r,r,zeta);
				fprintf(fileId,'   ||x(param.errorBdIdx) - POP.xCenter(%d,param.errorBdIdx)||/max{1,||POP.xCenter(%d,param.errorBdIdx)||} <= %+12.7e\n',... 
					r,r,zeta/max([1,norm(POP.xCenter(r,errorBdIdx))]));
			end    
			fprintf(fileId,'   for every feasible solution x of the POP with the obj. value <= %+13.7e.\n',fValue); 
			ii = 0;
			if printLevel >=2
				if iscell(param.errorBdIdx)
					fprintf(fileId,'   Here POP.xCenter(%d,param.errorBdIdx{%d}) = \n',r,r);       
				else
					fprintf(fileId,'   Here POP.xCenter(%d,param.errorBdIdx) = \n',r);
				end    
				ii = 0;
				for j=errorBdIdx
					ii = ii+1;
					fprintf(fileId,'  %4d:%+13.7e',j,full(xCenter(j)));
					if ii == 5
						fprintf(fileId,'\n');
						ii = 0;
					end
				end
				if ii > 0
					fprintf(fileId,'\n');
				end
			end            
		end       
	end
end
