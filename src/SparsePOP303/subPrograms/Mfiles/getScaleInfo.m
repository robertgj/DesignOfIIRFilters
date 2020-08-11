function  getScaleInfo(objPoly0, fixedVar, linearterms, transA, transb, param)

nDim = objPoly0.dimVar;
removeIdx = [];
remainIdx = (1:nDim);
if ~isempty(fixedVar)
    removeIdx = fixedVar(:,1);
    remainIdx = setdiff((1:nDim),fixedVar(:,1));
end

if isfield(param,'sdpaDataFile') && ischar(param.sdpaDataFile) && ~isempty(param.sdpaDataFile)
	idx = findstr(param.sdpaDataFile,'.dat-s');
	if ~isempty(idx)
		infoFile = strcat(param.sdpaDataFile(1:idx),'info');
       		 fprintf('# The information on scaling for this POP\n');
	        fprintf('# is written in %s. See UserGuide.pdf for the detail.\n',infoFile);
		fid = fopen(infoFile,'w+');
		%%fprintf(fid,'%10.8f\t# scaling coefficient for objective function\n',trans.objValScale);
		%%fprintf(fid,'%10.8f\t# constant coefficient for objective function\n',trans.objConstant);
		DiagMat = zeros(nDim,1);	
		Order   = -1*ones(nDim,1);
		Vect    = zeros(nDim,1);
		if ~isempty(fixedVar)	
			DiagMat(remainIdx) = diag(transA);
			Order(remainIdx) = linearterms;
			Vect(removeIdx) = fixedVar(:,2);
			Vect(remainIdx) = transb;
		else
			DiagMat = diag(transA);
			Order = linearterms;
			Vect = transb;
		end
		
		for i=1:nDim
			fprintf(fid,'%2d\t%10.8f\t%10.8f\n',Order(i),full(DiagMat(i)),full(Vect(i)));
		end
		fprintf('\n');
		fclose(fid);
	end
end


return
