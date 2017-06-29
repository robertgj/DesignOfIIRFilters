function idx = getIdxErr(param, dimVar, dimVar0, fixedIdx)

%
% 2011-07-03 H.Waki
% We assume that we have already converted param.errorBdIdx='a' or 'A' 
% into 1:objPoly.dimVar.
%

idx = 1:dimVar;
if ~isfield(param, 'errorBdIdx')
	return
elseif iscell(param.errorBdIdx)
	for i=1:size(param.errorBdIdx,2);
		if ~isempty(param.errorBdIdx{i})	
			idx = [param.errorBdIdx{i},idx];
		end
	end
	idx = unique(idx);
elseif isempty(param.errorBdIdx)
	return
else
	idx = unique(param.errorBdIdx);
end
if ~isempty(fixedIdx)
	idx = setdiff(idx, fixedIdx');
	origIdx = setdiff(1:dimVar0, fixedIdx');
	newidx = 1:dimVar0;
	newidx(origIdx) = 1:dimVar;
	idx = newidx(idx);
end
return
