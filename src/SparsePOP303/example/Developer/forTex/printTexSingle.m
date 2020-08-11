function printTexSingle(param, probNumbers, problemList, compResult, sedumiInfoVec, Esize)

%

% percent = char(37);
% backS = char(92); % char(165);
% aand = char(38);
% perc = char(37);
% lbrace = char(123);
% rbrace = char(125);
% lbracket = char(91);
% rbracket = char(93);
% pipe = char(124);
str = date;
fname = strcat(param.SDPsolver,'_results', '_', str,'.tex');
fcname = strcat(param.SDPsolver,'_errors', '_', str,'.tex');
frname = strcat(param.SDPsolver,'_numresults', '_', str,'.tex');
fpname = strcat(param.SDPsolver,'_popresults', '_', str,'.tex');
mainTexSingle(param,fname, fcname, frname, fpname);
resultTexSingle(param, probNumbers, problemList, compResult, Esize, frname);
errorTexSingle(param, probNumbers, problemList, compResult, sedumiInfoVec, Esize, fcname);
if isfield(param,'POPsolver') && ~isempty(param.POPsolver)
   popTexSingle(param, probNumbers, problemList, compResult, Esize, fpname); 
end
return
