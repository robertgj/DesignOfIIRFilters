function [objPoly,ineqPolySys,lbd,ubd, minOrmax] = readGMS(fileName,symbolicMath)
%
% readGMS
% converts GAMS scalar format into SparsePOP format
%
% Usage:
% [objPoly,ineqPolySys,lbd,ubd] = readGMS(fileName,symbolicMath);
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Inputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% fileName: the file name written in GAMS scalar format.
% symbolicMath: 1 if you have the Symbolic Math Toolbox provieded by
%      MathWorks. With this option, parentheses in the file are
%      expanded automatically. Default value is 0.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Outputs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% objPoly, inEqPolySys, lbd, ubd form the SparsePOP format.
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
if nargin < 2
    symbolicMath = 0;
end
if nargout < 5
	minOrmax = 'min';
end    
if exist(fileName, 'file') ~= 2
    error('## Input file does not exist.');
end
minOrmax = 'min';

eqTo2ineqSW = 0;
eqTolerance = 0.0;

% Input %%%%%
% filename: GAMS data file name with .gms, for example "ex2_1_2.gms".
% eqTo2ineqSW
%   = 0;    to keep equalities as they are.
%   = 1;    to convert an equality f(x) = 0 into f(x) >= 0
%           and f(x) <=  eqTolerance.
% eqTolerance = 1e-4;
%%%%%%%%%%%%%
% Restriction:
%   1.  A line starting with '*' in the first column is regarded as a comment
%       line.
%   2.  At most one item of "Variables", "Positive Variables", "Equations",
%       constraints and bounds is contained in one line.
%	The end of one item is marked with ';'.
%	One item can be written in more than one line;
%       The first letter of each line can not be '*'.
%       For example,
%           Positive Variables x1,x2,x3,x4,
%               x5,x6;
%           e1..  +0.5*x1*x1 +0.5*x2*x2 +0.5*x3*x3 +0.5*x4*x4
%               +0.5*x5*x5 +10.5*x1 +7.5*x2
%               +3.5*x3 +2.5*x4 +1.5*x5 +10*x6 + objvar =E= 0;
%           x1.up = 1;
%       are allowed. But
%           x1.lo = 1; x1.up = 2;
%           e1..  +0.5*x1*x1 +0.5*x2*x2 +0.5*x3*x3 +0.5*x4*x4 +3.5
%                 *x3 +2.5*x4 +1.5*x5 +10*x6 + objvar =E= 0;
%       are not allowed.
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Output %%%%%
% objPoly
% ineqPolySys
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Variables
% noOfVariables <--- "Variables" in the GAMS file;
% varNames{k} (k=1,2,?ldots,noOfVariables)
%   <--- "Variables" in the GAMS file;
% posVarNames (k=1,2,?ldots,noOfVariables)
%   <--- "Positive Variables" in the GAMS file;
% noOfEquations
%   <--- "Equations" in the GAMS file;
% equationNames (i=1,2,?ldots,noOfEquations);
%   <--- "Equations" in the GAMS file;
% lbd(1,k) (k=1,2,?ldots,noOfVariables);
% ubd(1,k) (k=1,2,?ldots,noOfVariables);
% listOfTerms{i} (i=1,2,?ldots,noOfEquations);
%   --- the list of monomials of each equation.

%
% 2010-01-11 H.Waki 
% Convert file into one line separated by ';'.
% 
allStatements = fromFile(fileName);
%allStatements
minOrmaxIdx = strfind(allStatements, 'maximizing objvar');
if ~isempty(minOrmaxIdx)
	fprintf('## The inputted problem is the maximization problem.\n');
	fprintf('## We multiply -1 into the objective fuction for \n');
	fprintf('## converting it into the minimization problem. \n');
	minOrmax ='max';
else
	minOrmax ='min';
end

% Remove white spaces at the head and tail in all lines.
%
allStatements = removeWhiteSpaces(fileName, allStatements);
%allStatements



% Remove the line whose head is an asterisk.
%
allStatements = removeStar(allStatements);
%allStatements

% Get the name of variables
%
[varNames, allStatements] = getVarName(fileName, allStatements);
noOfVariables = size(varNames,2);
%allStatements
%varNames

% Get the name of nonnegative variables
%
[posVarNames, allStatements] = getPosvarName(fileName, allStatements);
checkPosVar(varNames, posVarNames);
%allStatements
%posVarNames

% Get the name of binary variables
%
[binVarNames, allStatements] = getBinaryName(fileName, allStatements);
checkBinVar(varNames, binVarNames);
%allStatements
%binVarNames

% Get the name of constraints
% Get the name of constraints
%
[equationNames, allStatements] = getEquationName(fileName, allStatements);
noOfEquations = size(equationNames,2);
%equationNames
%allStatements

% Get the constraints
%
%allStatements
[equationNames,listOfEquations, allStatements] = getEquation(fileName, allStatements, equationNames, symbolicMath);
%allStatements

% Get lower and upper bounds
%
[lbd, ubd, fixed, allStatements] = getLowerUpper(fileName, allStatements, varNames);
% allStatements
% varNames
% posVarNames
% equationNames
% listOfEquations
% lbd
% ubd
% fixed
clear allStatements

% finding the objective row
objRow = getObeRow(listOfEquations, noOfEquations);


% analyzing list of constraints.
% separating each line of polynomial equation into the list of monomials.
listOfTerms = cell(1,noOfEquations);
eqOrIneq = cell(1,noOfEquations);
rightValue = cell(1,noOfEquations);
for i=1:noOfEquations
    idx = findstr(listOfEquations{i},'=');
    %equationNames{i}
    if isempty(idx) || length(idx) ~= 2
        error('## The constaint of ''%s'' should have ''=E='', ''=G='' or ''=L=''.\n## Should check the kind of the constriant and/or the position of '';''. ', equationNames{i});
        %elseif length(idx) > 2
        %    listOfEquations{i}
        %    error('## The constaint of ''%s'' have more than one ''=''.', equationNames{i});
    end
	%listOfEquations{i}
    [listOfTerms{i},eqOrIneq{i},rightValue{i}] = separate(listOfEquations{i}, symbolicMath);
    %listOfTerms{i}
    %eqOrIneq{i}
    %rightValue{i}
    checkConstraints(listOfTerms{i}, eqOrIneq{i}, rightValue{i}, equationNames{i});
end


% finding the objective term in the objective row
noOfTerms = size(listOfTerms{objRow},2);
p = 1;
temp = [];
while (p <= noOfTerms) && isempty(temp)
    temp = findstr(listOfTerms{objRow}{p},'objvar');
    if ~isempty(temp)
        objTerm = p;
    end
    p = p+1;
end

% eliminating objvar from varNames
p=0;
idx = 0;
for i=1:noOfVariables
    if strcmp('objvar',varNames{i}) ~= 1
        p = p+1;
        varNames{p} = varNames{i};
	else
		idx = i;
    end
end
if idx == 0
	error('## Should write ''objvar'' at the objective function in your problem.');
end
noOfVariables = noOfVariables -1;
%fixed = fixed(1:noOfVariables);
lbd(idx) = [];
ubd(idx) = [];
fixed(idx) = [];

printSW = 0;
if printSW == 1
    nnn = size(lbd,2);
    for i=1:nnn
        fprintf('%+6.2e ',lbd(1,i));
    end
    fprintf('\n');
    for i=1:nnn
        fprintf('%+6.2e ',ubd(1,i));
    end
    fprintf('\n');
end

q = 0;
if listOfTerms{objRow}{objTerm}(1) == '-'
	objConstant = -rightValue{objRow};
	objFunction = cell(1,noOfTerms);
	for p=1:noOfTerms
		if p ~= objTerm
			q = q+1;
			objFunction{q} = listOfTerms{objRow}{p};
		end
    end
else
    objConstant = rightValue{objRow};
	objFunction = cell(1,noOfTerms);
    for p=1:noOfTerms
        if p ~= objTerm
            q = q+1;
            ll = length(listOfTerms{objRow}{p});
            if listOfTerms{objRow}{p}(1) == '-'
                objFunction{q} = strcat('+',listOfTerms{objRow}{p}(2:ll));
            else
                objFunction{q} = strcat('-',listOfTerms{objRow}{p}(2:ll));
            end
        end
    end
end

% eliminating the objective row from listOfTerms
q = 0;
for p=1:noOfEquations
    if p ~=objRow
        q = q+1;
        listOfTerms{q} = listOfTerms{p};
        eqOrIneq{q} = eqOrIneq{p};
        rightValue{q} = rightValue{p};
    end
end
noOfEquations = noOfEquations - 1;

debug = 0; 
if debug == 1
    fprintf('varNames:   ')
    for i=1:noOfVariables
        fprintf('%5s     ',varNames{i});
    end
    fprintf('\n');
    if isempty(posVarNames) ~= 1
        ll = size(posVarNames,2);
        fprintf('posVarNames:')
        for i=1:ll
            fprintf('%5s     ',posVarNames{i});
        end
        fprintf('\n');
    end
    if isempty(binVarNames) ~= 1
        ll = size(binVarNames,2);
        fprintf('binVarNames:')
        for i=1:ll
            fprintf('%5s     ',binVarNames{i});
        end
        fprintf('\n');
    end
    fprintf('lbd   : ');
    for i=1:noOfVariables
        fprintf('%+7.2e ',lbd(i));
    end
    fprintf('\n');
    fprintf('ubd   : ');
    for i=1:noOfVariables
        fprintf('%+7.2e ',ubd(i));
    end
    fprintf('\n');
    fprintf('objFunction : ');
    ll = size(objFunction,2);
    for j=1:ll
        fprintf('%s ',objFunction{j});
    end
    fprintf('\n');
    for i=1:noOfEquations
        fprintf('%2d : ',i);
        ll = size(listOfTerms{i},2);
        for j=1:ll
            fprintf('%s ',listOfTerms{i}{j});
        end
        fprintf(' %s ',eqOrIneq{i});
        fprintf(' %+8.3e \n',rightValue{i});
    end
end

objPoly = getObjPoly(noOfVariables, varNames, objFunction, objConstant, fileName);
if strcmp(minOrmax, 'max')
	objPoly.coef = -objPoly.coef;
end
objPoly = simplifyPolynomial(objPoly);

% ineqPolySys
if ~isempty(binVarNames)
	ineqPolySys = cell(1,noOfEquations+size(binVarNames, 2));
else
	ineqPolySys = cell(1,noOfEquations);
end
if eqTo2ineqSW == 0
    for i=1:noOfEquations
        pointer = i;
        [statusSW, poly, msg] = convToPolynomial(noOfVariables,varNames,...
            listOfTerms{i},eqOrIneq{i},rightValue{i});
        ineqPolySys{i} = poly;
        if statusSW ~= 0
            error('%s## Should check the %d%s constraint.', msg, i, thWord(i));
        end
	ineqPolySys{i} = simplifyPolynomial(ineqPolySys{i});
	%size(ineqPolySys{i}.supports)
        %full(ineqPolySys{i}.supports)
	%size(ineqPolySys{i}.coef)
        %full(ineqPolySys{i}.coef')
    end
    pointer = noOfEquations;
else % eqTo2ineqSW == 1
    pointer = 0;
    for i=1:noOfEquations
        if (eqOrIneq{i} == 'G')
            pointer = pointer + 1;
            [statusSW, poly, msg] = convToPolynomial(noOfVariables,varNames,...
                listOfTerms{i},eqOrIneq{i},rightValue{i});
            ineqPolySys{pointer} = poly;
        elseif (eqOrIneq{i} == 'L')
            pointer = pointer + 1;
            [statusSW, poly, msg] = convToPolynomial(noOfVariables,varNames,...
                listOfTerms{i},eqOrIneq{i},rightValue{i});
            ineqPolySys{pointer} = poly;
        else
            pointer = pointer + 1;
            [statusSW, poly, msg] = convToPolynomial(noOfVariables,varNames,...
                listOfTerms{i},'G',rightValue{i});
            ineqPolySys{pointer} = poly;
            pointer = pointer + 1;
            [statusSW, poly, msg] = convToPolynomial(noOfVariables,varNames,...
                listOfTerms{i},'L',rightValue{i}+eqTolerance);
            ineqPolySys{pointer} = poly;
        end
        if statusSW ~= 0
            error('%s## Should check the %d%s constraint.', msg, i, thWord(i));
        end
    end
end
%tmpL = cell(1,1);
tmpL = cell(1,2);
for i=1:size(binVarNames,2)
	%x^2 = 1
	%tmpL{1} = strcat('1*',binVarNames{i}, '*', binVarNames{i});
	%tmpE = 'E';
	%tmpR = 1;
	%x(x-1) = 0	
	tmpL{1} = strcat('1*',binVarNames{i}, '*', binVarNames{i});
	tmpL{2} = strcat('-1*',binVarNames{i});
	tmpE = 'E';
	tmpR = 0;	
        [statusSW, poly, msg] = convToPolynomial(noOfVariables,varNames,tmpL,tmpE,tmpR);
        ineqPolySys{i+noOfEquations} = poly;
        if statusSW ~= 0
            error('%s## Should check the %d%s constraint.', msg, i, thWord(i+noOfEquations));
        end
	%full(ineqPolySys{i+noOfEquations}.supports)
	%ineqPolySys{i+noOfEquations}
end
% pointer = noOfEquations;
% iEqPolySys --- nonnegativity
if isempty(posVarNames) ~= 1
    ll = size(posVarNames,2);
    for i=1:ll
        lbd = posToInEqPolySys(noOfVariables,varNames,posVarNames{i},lbd);
    end
end

% Print for debug
debug = 0;
if debug
	writePOP(1, objPoly, ineqPolySys, lbd, ubd);
end
return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function allStatements = fromFile(fileName)
fileIDX = fopen(fileName, 'r');
allStatements = [];
nextSW = 0;
while 1
    oneLine = fgetl(fileIDX);
    if ~ischar(oneLine)
        break;
    end
    [nextSW, statements] = fromOneLine(oneLine, nextSW);
    if nextSW == 0
        if ~isempty(statements)
            statements = deblank(statements);
        end
        if ~isempty(statements)
            statements = strtrim(statements);
        end
    end
    allStatements = [allStatements, statements];
end
allStatements = deblank(allStatements);
allStatements = strtrim(allStatements);
%allStatements
%error();
fclose(fileIDX);
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [nextSW, statements] = fromOneLine(oneLine, nextSW)
statements = [];
if nextSW == 0
    oneLine = deblank(oneLine);
    oneLine = strtrim(oneLine);
end
if isempty(oneLine)
	return
end
if nextSW == 0 && ~isempty(oneLine) && strcmp(oneLine(1), '*')
    return
end
idx = strfind(oneLine, ';');
disp(statements);
if isempty(idx)
    statements = [statements, oneLine];
    nextSW = 1;
else
    while ~isempty(idx)
        if idx(1) == 1
            oneLine(1) = [];
        else
            statements = [statements, oneLine(1:idx(1))];
            if idx(1) <= length(oneLine)
                oneLine(1:idx(1)) = [];
            else
                nextSW = 0;
                break;
            end
        end
        if ~isempty(oneLine)
            oneLine = deblank(oneLine);
        end
        if ~isempty(oneLine)
            oneLine = strtrim(oneLine);
        end
        if isempty(oneLine)
            nextSW = 0;
            return
        elseif strcmp(oneLine(1), '*')
            nextSW = 0;
           return 
        end
        idx = findstr(oneLine, ';');
    end
    if ~isempty(oneLine)
        statements = [statements, oneLine];
        nextSW = 1;
    end
end

%nextSW
%statements

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function allStatements = removeStar(allStatements)
idx = strfind(allStatements, ';');
sidx = 1;
removeIdx = [];
for i=1:length(idx)
    eidx = idx(i);
    onestate = allStatements(sidx:eidx);
    if strcmp(onestate(1), '*')
        removeIdx = [removeIdx; sidx, eidx];
    end
    sidx = eidx + 1;
end
if sidx <= length(allStatements) && strcmp(allStatements(sidx),'*')
    eidx = length(allStatements);
   removeIdx = [removeIdx; sidx, eidx]; 
end
p = size(removeIdx,1);
for i=1:p
    sidx = removeIdx(p-i+1,1);
    eidx = removeIdx(p-i+1,2);
    allStatements(sidx:eidx) = [];
end
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function allStatements = removeWhiteSpaces(fileName, allStatements)
idx = findstr(allStatements, ';');
if isempty(idx)
    error('## ''%s'' does not have any '';''.', fileName);
elseif idx(end) ~= length(allStatements)
    error('## '';'' does not exist at the end of the last statement of ''%s''.', fileName);
end
NewAllStatements = [];
sidx = 1;
for i=1:length(idx)
    eidx = idx(i);
    oneLine = allStatements(sidx:eidx);
    sidx = eidx + 1;
    oneLine = deblank(oneLine);
    oneLine = strtrim(oneLine);
    NewAllStatements = [NewAllStatements, oneLine];
end
allStatements = NewAllStatements;
% Remove lines which are undefined in SparsePOP.
%
idx = strfind(allStatements, 'Model');
if ~isempty(idx)
    Lines = allStatements(idx(1):end);
    aidx = strfind(Lines, 'all');
    sidx = strfind(Lines, '/');
    if ~isempty(aidx) && ~isempty(sidx)
        allStatements(idx(1):end) = [];
    end
end
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [varNames, allStatements] = getVarName(fileName, allStatements)
idx = findstr(allStatements, ';');
if isempty(idx)
    error('## ''%s'' does not have any '';''.', fileName);
elseif idx(end) ~= length(allStatements)
    error('## '';'' does not exist at the end of the last statement of ''%s''.', fileName);
end
% get the definition of Variables
sidx = 1;
varNames = [];
for i=1:length(idx)
    eidx = idx(i);
    oneLine = allStatements(sidx:eidx);
    %oneLine
    Vidx = strfind(oneLine, 'Variables');
    if ~isempty(Vidx) && length(Vidx) == 1 && Vidx(1) == 1
        [tmp,oneLine] = strtok(oneLine);
        
        if ~isempty(oneLine)
            wsidx = strfind(oneLine, ' ');
            oneLine(wsidx) = [];
            %oneLine
            p = 0;
            [varNames,p,moreSW] = getListOfNames(oneLine,varNames,p);
            while moreSW == 1
                [varNames,p,moreSW] = getListOfNames(oneLine,varNames,p);
            end
            allStatements(sidx:eidx) = [];
            break;
        end
    end
    sidx = eidx + 1;
end
if isempty(varNames)
    error('## ''%s'' does not have the line of ''Variables''.',fileName);
end
objflag = 0;
for j=1:size(varNames,2)
    if strcmp(varNames{j}, 'objvar')
        objflag = 1;
        break;
    end
end
if objflag == 0
    error('## The reserved keyword ''%s'' is not defined.\n## Should check the line of ''Variables'' and the position of '';''.','objvar');
end

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [posVarNames, allStatements] = getPosvarName(fileName, allStatements)
% get the definition of Positive Variables
idx = findstr(allStatements, ';');
sidx = 1;
posVarNames = [];
for i=1:length(idx)
    eidx = idx(i);
    oneLine = allStatements(sidx:eidx);
    Pidx = strfind(oneLine, 'Positive');
    if ~isempty(Pidx)
        [tmp,oneLine] = strtok(oneLine);
        oneLine = strtrim(oneLine);
        Vidx = strfind(oneLine, 'Variables');
        if ~isempty(Vidx)
		oneLine = oneLine(Vidx+9:end);
		while true
			if strcmp(oneLine(1), blanks(1))
				oneLine = oneLine(2:end);
			else
				break;
			end
		end
            %[tmp,oneLine] = strtok(oneLine);
            if ~isempty(oneLine)
                wsidx = strfind(oneLine, ' ');
                oneLine(wsidx) = [];
                p = 0;
                [posVarNames,p,moreSW] = getListOfNames(oneLine,posVarNames,p);
                while moreSW == 1
                    [posVarNames,p,moreSW] = getListOfNames(oneLine,posVarNames,p);
                end
            end
            %posVarNames
            allStatements(sidx:eidx) = [];
            break;
        end
    end
    sidx = eidx + 1;
end

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function checkPosVar(varNames, posVarNames)

for i=1:size(posVarNames,2)
    eqflag = 0;
   for j=1:size(varNames,2)
      if strcmp(posVarNames{i}, varNames{j})
          eqflag = 1;
          break;
      end
   end
   if eqflag == 0
      error('## ''%s'' is not defined in the line of ''Variables''.\n## Should check the line of ''Positive Variables'' and the position of '';''.', posVarNames{i}); 
   end
end
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [binVarNames, allStatements] = getBinaryName(fileName, allStatements)
% get the definition of Binary Variables
idx = findstr(allStatements, ';');
sidx = 1;
binVarNames = [];
for i=1:length(idx)
    eidx = idx(i);
    oneLine = allStatements(sidx:eidx);
    Pidx = strfind(oneLine, 'Binary');
	if isempty(Pidx)
    		Pidx = strfind(oneLine, 'Binaries');
	end
    if ~isempty(Pidx)
        [tmp,oneLine] = strtok(oneLine);
        oneLine = strtrim(oneLine);
        Vidx = strfind(oneLine, 'Variables');
	if isempty(Vidx)
        	Vidx = strfind(oneLine, 'variables');
	end
        if ~isempty(Vidx)
		oneLine = oneLine(Vidx+9:end);
		while true
			if strcmp(oneLine(1), blanks(1))
				oneLine = oneLine(2:end);
			else
				break;
			end
		end
            if ~isempty(oneLine)
                wsidx = strfind(oneLine, ' ');
                oneLine(wsidx) = [];
                p = 0;
                [binVarNames,p,moreSW] = getListOfNames(oneLine,binVarNames,p);
                while moreSW == 1
                    [binVarNames,p,moreSW] = getListOfNames(oneLine,binVarNames,p);
                end
            end
            %binVarNames
            allStatements(sidx:eidx) = [];
            break;
        end
    end
    sidx = eidx + 1;
end

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function checkBinVar(varNames, binVarNames)

for i=1:size(binVarNames,2)
    eqflag = 0;
   for j=1:size(varNames,2)
      if strcmp(binVarNames{i}, varNames{j})
          eqflag = 1;
          break;
      end
   end
   if eqflag == 0
      error('## ''%s'' is not defined in the line of ''Variables''.\n## Should check the line of ''Binary Variables'' and the position of '';''.', binVarNames{i}); 
   end
end
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [equationNames, allStatements] = getEquationName(fileName, allStatements)
% get the definition of Equations
idx = findstr(allStatements, ';');
if isempty(idx)
    error('## ''%s'' does not have the line of ''Equations''.',fileName); 
elseif idx(end) ~= length(allStatements)
    error('## '';'' does not exist at the end of the last statement of ''%s''.', fileName);
end
sidx = 1;
equationNames  = [];
for i=1:length(idx)
    eidx = idx(i);
    oneLine = allStatements(sidx:eidx);
    Eidx = strfind(oneLine, 'Equations');
    if ~isempty(Eidx)
        [tmp,oneLine] = strtok(oneLine);
        if ~isempty(oneLine)
            wsidx = strfind(oneLine, ' ');
            oneLine(wsidx) = [];
            p = 0;
            [equationNames,p,moreSW] = getListOfNames(oneLine,equationNames,p);
            while moreSW == 1
                [equationNames,p,moreSW] = getListOfNames(oneLine,equationNames,p);
            end
            allStatements(sidx:eidx) = [];
            break;
        end
    end
    sidx = eidx + 1;
end

if isempty(equationNames)
   error('## ''%s'' does not have the line of ''Equations''.',fileName); 
end
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [NewEquationNames, listOfEquations, allStatements] = getEquation(fileName, allStatements, equationNames, symbolicMath)
% get the objective function and all the constraints
idx = findstr(allStatements, ';');
if isempty(idx)
    error('## ''%s'' does not have the line of ''Equations''.',fileName); 
elseif idx(end) ~= length(allStatements)
    error('## '';'' does not exist at the end of the last statement of ''%s''.', fileName);
end
sidx = 1;
eqIdx = ones(1, size(equationNames,2));
pp = 1;
listOfEquations = [];
NewEquationNames = [];
for i=1:length(idx)
    eidx = idx(i);
    oneLine = allStatements(sidx:eidx); 
    eNameidx = strfind(oneLine, '..');
    usedflag = 0;
    if ~isempty(eNameidx)
        if eNameidx(1) == 1
            error('## ''%s'' has a line which consists of only ''..''.', fileName);
        end
        eName=oneLine(1:eNameidx-1);
	while true
		if strcmp(eName(end), blanks(1))
			eName = eName(1:end-1);
		else
			break;
		end
	end
        %eName
        for j=1:size(equationNames,2)
            if strcmp(equationNames{j}, eName)
		%oneLine
		tmpidx = strfind(oneLine, '..');
		tmpidx = tmpidx + 1;
		%equationNames{j}
                %tmpidx = length(eName) + 2;
                if tmpidx >= length(oneLine)
                   error('## The %d%s constraint does not have any statemets.', i, thWord(i)); 
                end
                statement = oneLine(tmpidx+1:end);
                statement = strtrim(statement);
		%statement
                eqIdx(j) = 0;
                NewEquationNames{pp}  = eName;
                [listOfEquations, pp] = getlistOfEquations(statement, listOfEquations, pp, symbolicMath);
                %allStatements(sidx:eidx) = [];
                usedflag = 1;
                break;
            end
        end
        if usedflag == 0
           error('## ''%s'' is not defined in the line of ''Equations''.', eName); 
        end
    end
    sidx = eidx + 1;
end

%listOfEquations
%eqIdx
if any(eqIdx) == 1
    eqNo = find(eqIdx==1);
    error('## The constraint of ''%s'' is not defined in ''%s''.\n## Should check the line of ''Equations'' and the position of '';''.',equationNames{eqNo(1)}, fileName);
end
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [lbd, ubd, fixed, allStatements] = getLowerUpper(fileName, allStatements, varNames)
% get all upper and lower bounds.
idx = findstr(allStatements, ';');
sidx = 1;
noOfVariables = size(varNames,2);
lbd = -1.0e10* ones(1,noOfVariables);
ubd = 1.0e10* ones(1,noOfVariables);
fixed = lbd;
for i=1:length(idx)
    eidx = idx(i);
    oneLine = allStatements(sidx:eidx);
    sidx = eidx + 1;
    pidx = strfind(oneLine, '.');
    dpidx= strfind(oneLine,'..');
    usedflag = 0;
    if ~isempty(pidx) && isempty(dpidx)
        if pidx(1) == 1
            error('## The variable in the line ''%s'' is undefined.', oneLine);
        end
        oneVar = oneLine(1:pidx(1)-1);
        if pidx(1) == length(oneLine)
            error('## The lower or upper bound of ''%s'' is undefined.', onevar);
        end
        bound = oneLine(pidx(1)+1:end);
        for j=1:noOfVariables
            if strcmp(oneVar, varNames{j})
                eqidx = strfind(bound, '=');
                scidx = strfind(bound,';');
                if isempty(eqidx)
                    error('## The line ''%s'' does not have ''=''.', oneLine);
                elseif eqidx(1) >= length(bound)
                    error('## The value of the lower or uppper bound of ''%s'' is not defined.', oneVar);
                elseif isempty(scidx)
                    error('## The line ''%s'' does not have '';''.', oneLine);
                elseif scidx(1) < eqidx(1)+2
                    %scidx(1)
                    %eqidx(1)+2
                    error('## The line ''%s'' does not have '';''.', oneLine);
                end
                asciiVal = bound(eqidx(1)+1:scidx(1)-1);
                usedflag = 1;
                if isempty(asciiVal)
                    error('## The value of the lower bound of ''%s'' is undefined.', oneVar);
                end
                val = str2double(asciiVal);
                if isnan(val)
                   error('## The bound of ''%s'' is ''%s''.\n## This is not a numerical value.',oneVar, asciiVal); 
                elseif ~isfinite(val)
                    error('## The bound of ''%s'' should be finite.', oneVar);
                end
                if strcmp(bound(1:2),'lo')
                    lbd(1,j) = val;
                    break;
                elseif strcmp(bound(1:2),'up')
                    ubd(1,j) = val;
                    break;
                elseif strcmp(bound(1:2),'fx')
                    fixed(1,j) = val;
                    lbd(1,j) = val;
                    ubd(1,j) = val;
                    break;
                %else
                %    error('## ''%s'' is not a reserved keyword.',bound(1:2));
                end
                
            end
        end
        if usedflag == 0
            %allStatements
            error('## ''%s'' is not defined in the line of ''Variables''.', oneVar);
        end
    end
end
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [listOfEquations, pp] = getlistOfEquations(oneLine, listOfEquations, pp, symbolicMath)
%
% 2011-11-18 H.Waki
% Fixed a bug in this function. 
idx = find(isspace(oneLine));
oneLine(idx) = [];
if symbolicMath == 1	
	% new version
	if ~isempty(strfind(oneLine,'('))
		%x1 = sym('x1');
		%x1 = sym('objvar');
		%loca = strfind(oneLine,'objvar');
		%if isempty(loca)
			loca = strfind(oneLine,'=');
			loca = loca(1) -1;
		%else
			%loca = loca(1) -3; % for objvar
		%	loca = loca(1) -2; % for objvar
		%end
		%oneLine(1:loca)
		%20161018 H. Waki modified
		tempf = collect(sym(oneLine(1:loca)), sym('objvar'));
		oneLinetmp = char(vpa(expand(tempf),50));
		oneLine = strcat(oneLinetmp, oneLine(loca+1:end));
	end
	% old version
	%{
	if ~isempty(strfind(oneLine,'('))
		%x1 = sym('x1');
		x1 = sym('objvar');
		%loca = strfind(oneLine,'objvar');
		%if isempty(loca)
			loca = strfind(oneLine,'=');
			loca = loca(1) -1;
		%else
			%loca = loca(1) -3; % for objvar
		%	loca = loca(1) -2; % for objvar
		%end
		%oneLine(1:loca)
		oneLinetmp = char(vpa(expand(collect(oneLine(1:loca),x1)),50));
		oneLine = strcat(oneLinetmp, oneLine(loca+1:end));
	end
	%}
else
	if ~isempty(strfind(oneLine,'('))
		error('Please expand parenthesises by your hand.');
	end
end
idx = find(isspace(oneLine));
oneLine(idx) = [];
%oneLine
listOfEquations{pp} = oneLine;
pp = pp+1;
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [varNames,p,moreSW] = getListOfNames(oneLine,varNames,p)
while (~isempty(oneLine))
    [oneName,remLine] = strtok(oneLine,' ,');
    if ~isempty(oneName)
        p = p+1;
        varNames{p} = oneName;
    end
    oneLine = remLine;
end
lenLastVar = length(varNames{p});
if varNames{p}(lenLastVar) == ';'
    moreSW = 0;
    if lenLastVar == 1
        p = p-1;
    else
        varNames{p} = varNames{p}(1:lenLastVar-1);
    end
else
    moreSW = 1;
end
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function objRow = getObeRow(listOfEquations, noOfEquations)
objRow = [];
for i=1:noOfEquations
    temp = findstr(listOfEquations{i},'objvar');
    if isempty(temp) ~= 1
        objRow = [objRow,i];
    end
end
if isempty(objRow)
	error('## Should write the reserved keyword ''objvar'' at the objective function in your problem.');
elseif length(objRow) > 1
    error('## %d lines in your problem have the reserved keyword ''objvar''.\n## Should write one ''objvar'' in your problem.',length(objRow));
end
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [listOfTerms,eqOrIneq,rightValue] = separate(oneLine, symbolicMath)

[formerPart,latterPart] = strtok(oneLine,'=');
eqOrIneq = latterPart(2);
ll = length(latterPart);
tmpstr = str2num(latterPart(4:ll-1));
if isempty(tmpstr)
	% new version
	rightValue = latterPart(4:ll-1);
	idx = isspace(rightValue);
	rightValue(idx) = [];
	addformerPart = strcat('-(', rightValue, ')');
	formerPart = strcat(formerPart, addformerPart); 
	if symbolicMath == 0
		error('Need SymbolicMath Toolbox.');
	end
	%20161018 H. Waki modified
	tempf = collect(sym(formerPart), sym('x1'));
	formerPart = char(vpa(expand(tempf),50));
	rightValue = 0;
	% old version
	%{
	rightValue = latterPart(4:ll-1);
	idx = isspace(rightValue);
	rightValue(idx) = [];
	addformerPart = strcat('-(', rightValue, ')');
	formerPart = strcat(formerPart, addformerPart); 
	if symbolicMath == 0
		error('Need SymbolicMath Toolbox.');
	end
	x1 = sym('x1');
	formerPart = char(vpa(expand(collect(formerPart,x1)),50));
	rightValue = 0;
	%}
else
	rightValue = str2num(latterPart(4:ll-1));
end

% formerPart
k = 0;
idx = isspace(formerPart);
formerPart(idx) = [];
ll = length(formerPart);

while ll > 0
    if formerPart(1) == ';'
        break;
    else
        k = k+1;
        ii = 1;
        SignVec = [];
        while 1
            if (formerPart(1) == '-') || (formerPart(1) == '+')
                SignVec(ii) = formerPart(1);
                formerPart = formerPart(2:ll);
                ll = length(formerPart);
                ii = ii + 1;
            elseif (formerPart(1) ~= '-') && (formerPart(1) ~= '+') && (ii == 1)
                SignVec(ii) = '+';
                break;
            elseif (formerPart(1) ~= '-') && (formerPart(1) ~= '+') && (ii ~= 1)
                break;
            end
        end
        minus_num = length(findstr(SignVec, '-'));
        if ~isempty(SignVec) && mod(minus_num, 2) == 1
            listOfTerms{k} = '-';
        elseif ~isempty(SignVec) && mod(minus_num, 2) == 0
            listOfTerms{k} = '+';
        end
        %fprintf('listOfTerms{%d} = %s\n', k, listOfTerms{k});
        %fprintf('before formerPart = %s\n', formerPart);
        [oneTerm,formerPart] = strtok(formerPart,'-+;');
        %fprintf('oneTerm = %s\n', oneTerm);
        %fprintf('after formerPart = %s\n', formerPart);
        ll = length(formerPart);
        lenOneTerm = length(oneTerm);
        if (lenOneTerm > 0) && ((oneTerm(lenOneTerm) == 'e') || (oneTerm(lenOneTerm) == 'E')) ...
                && findstr(oneTerm,'.') && (ll > 0) && isempty(findstr(oneTerm,'*'))
            signE = formerPart(1);
            if (signE == '+') || (signE == '-')
                [oneTerm1,formerPart] = strtok(formerPart,'-+;');
                oneTerm = strcat(oneTerm,signE);
                oneTerm = strcat(oneTerm,oneTerm1);
            end
            %fprintf('oneTerm = %s\n', oneTerm);
        end
        %fprintf('oneTerm = %s\n', oneTerm);
        ll = length(formerPart);
        %if isspace(listOfTerms{k})
        %    listOfTerms{k} = oneTerm;
        %else
            listOfTerms{k} = strcat(listOfTerms{k},oneTerm);
        %end
        %fprintf('listOfTerms{%d} = %s\n', k, listOfTerms{k});
    end    
end

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function str = thWord(i)
if mod(i, 10) == 1 && i ~= 11
	str = 'st';
elseif mod(i, 10) == 2 && i ~= 12
	str = 'nd';
elseif mod(i, 10) == 3 && i ~= 13
	str = 'rd';
else
	str = 'th';
end
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function checkConstraints(listOfTermsI, eqOrIneqI, rightValueI, eqName)
if ~strcmp(eqOrIneqI,'E') && ~strcmp(eqOrIneqI,'G') && ~strcmp(eqOrIneqI, 'L') && ~strcmp(eqOrIneqI, 'e') && ~strcmp(eqOrIneqI, 'g') && ~strcmp(eqOrIneqI, 'l')
	error('## The constraint of ''%s'' should have ''=E='', ''=G='' or ''=L=''.\n## Should check the constraint.',eqName);
end
if isempty(listOfTermsI)
	error('## The left-hand side of the constraint of ''%s'' is empty.\n## Should write the constraint correctly.',eqName);
elseif isempty(eqOrIneqI)
	error('## The constraint of ''%s'' does not have ''=L='', ''=G='' and ''=E='' in your file.', eqName);
elseif isempty(rightValueI)
    error('## The right-hand side of the constraint of ''%s'' is not a numerical value.\n## Should write the constraint correctly.', eqName);
elseif ~isnumeric(rightValueI)
	error('## The right-hand side of the constraint of ''%s'' is not a numerical value.\n## Should write the constraint correctly.', eqName);
end
% check rightValue{i}
% the rightValue{i} must be a constant value.
if ~isnumeric(rightValueI) || isempty(rightValueI) || isnan(rightValueI)
    error('## The right-hand side of the constraint of ''%s'' is not a numerical value.\n## Should write the constraint correctly.', eqName);
end

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [statusSW, coef,supportVec, msg] = convertOneTerm(noOfVariables,...
    varNames,oneTerm)

msg = [];
statusSW = 0;
supportVec = sparse(1,noOfVariables);
if isempty(oneTerm)
    coef = [];
    supportVec = [];
    return
elseif isletter(oneTerm(2)) 
    if oneTerm(1) == '+'
        coef = 1.0;
    else
        coef = -1.0;
    end
    oneTerm = oneTerm(2:end);
else
    [temp,oneTerm] = strtok(oneTerm,'*');
    coef = str2num(temp);
end
while isempty(oneTerm) ~= 1
    [oneVariable,oneTerm] = strtok(oneTerm,'*');
    kk = length(oneVariable);
    pp = findstr(oneVariable,'^');
    powerPart = 1;
    if isempty(pp) ~= 1
        powerPart = str2num(oneVariable(pp+1:kk));
        oneVariable = oneVariable(1:pp-1);
    end
    i = 1;
    while (i <= noOfVariables)
        if strcmp(oneVariable,varNames{i})
            supportVec(1,i) = supportVec(1,i) + powerPart;
            break;
            %i = noOfVariables + 1;
        else
            i = i+1;
        end
    end
    if i == noOfVariables + 1
        statusSW = -1;
        [msg, errmsg] = sprintf('## ''%s'' is not defined in the line of ''Variables''.\n', oneVariable); 
    end
    
end
return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [statusSW, poly, msg] = convToPolynomial(noOfVariables,varNames,listOfTerms,...
    eqOrIneq,rightValue)
noOfTerms = size(listOfTerms,2);
statusSW = 0;
msg = [];
if strcmp(eqOrIneq, 'E') || strcmp(eqOrIneq, 'e')
    poly.typeCone = -1;
else
    poly.typeCone = 1;
end
poly.sizeCone = 1;
poly.degree = 0;
poly.dimVar = noOfVariables;
if abs(rightValue) > 1.0e-10
    poly.noTerms = noOfTerms + 1;
    poly.supports = sparse(1,poly.dimVar);
    poly.coef = -rightValue;
else
    poly.noTerms = noOfTerms;
    poly.supports = [];
    poly.coef = [];
end
for p=1:noOfTerms
    oneTerm = listOfTerms{p};
    [statusSW, coef,supportVec, msg] = convertOneTerm(noOfVariables,varNames,oneTerm);
    if statusSW ~= 0
       return 
    end
    poly.supports = [poly.supports; supportVec];
    poly.coef = [poly.coef;coef];
    %	full(supportVec)
    degree = full(sum(supportVec));
    poly.degree = max(poly.degree,degree);
end
% poly.degree
if eqOrIneq == 'L' || eqOrIneq == 'l'
    poly.coef = - poly.coef;
end

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [lbd]  = posToInEqPolySys(noOfVariables,varNames,oneVariable,lbd)

%poly.typeCone = 1;
%poly.sizeCone = 1;
%poly.degree = 1;
%poly.dimVar = noOfVariables;
%poly.noTerms = 1;
%poly.supports = sparse(zeros(1,poly.dimVar));
%poly.coef = [1];

i = 1;
while (i <= noOfVariables)    
    if strcmp(oneVariable,varNames{i})
        %		poly.supports(1,i) = 1;
        lbd(i) = max(lbd(i),0);
        break;
        %i = noOfVariables + 1;
    else
        i = i+1;
    end
end

if i == noOfVariables + 1
   error('## ''%s'' is not defined in the line of ''Variables''.\n## Should check the line of ''Variables'' in your file.',oneVariable); 
end

return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function objPoly = getObjPoly(noOfVariables, varNames, objFunction, objConstant, fileName)

if isempty(objFunction{1})
	objPoly.dimVar = noOfVariables;
	objPoly.typeCone = 1;
	objPoly.sizeCone = 1;
	objPoly.noTerms  = 1;
	objPoly.degree   = 0;
	objPoly.supports = sparse(objPoly.noTerms, objPoly.dimVar);
	objPoly.coef     = 0;
	return
end

[statusSW, objPoly1, msg] = convToPolynomial(noOfVariables,varNames,objFunction,'G',0);
if statusSW ~= 0
    error('%s## Should check the line of the objective function in ''%s''.', msg, fileName);
end

% objConstant = 0;
objPoly =simplifyPolynomial(objPoly1);
if (any(objPoly.supports(1,:),2) == 0 )
    objPoly.coef(1,1) = objConstant + objPoly.coef(1,1);
elseif abs(objConstant) > 1.0e-12
    objPoly.coef = [objConstant; objPoly.coef];
    objPoly.supports = [sparse(1,objPoly.dimVar); objPoly.supports];
    objPoly.noTerms = objPoly.noTerms +1;
end
return
