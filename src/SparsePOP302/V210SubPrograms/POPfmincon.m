function [x,fval,exitflag,output] ...
    = POPfmincon(objPoly,ineqPolySys,lbd,ubd,x0,options);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  POPfmincon ---   minimization of a POP in the SparsePOP format
%                   using fmincon and fminunc
% 
%  GENERAL DESCRIPTION
% 
% 	POP is an abbreviation of Polynomial Optimization Problem.
%   A typical invoking line may be:
% 
% >>  [x,fval,exitflag,output] = POPfmincon(DataFile);
% 
% 	The meanings of argument and return values are described below.
% 
%  FILE ARGUMENT
% 
% 	DataFile must be a string containing the file name. The DataFile must
% 	be written in the GMS format or POP format. In the case of GMS format,
% 	for example, call with
% >> [x,fval,exitflag,output] = POPfmincon('Bex3_1_1.gms');
% 	In the case of POP format, you should write it as if you are calling matlab
% 	function, e.g.,
% >> [x,fval,exitflag,output] = POPfmincon('BroydenTri(10)');
% 	See userGuide.pdf for more details.
%
%   You can specify an initial point x0 and options for fmincon and fminunc;
% >> [x,fval,exitflag,output] = POPfmincon('Bex3_1_1.gms',x0);
% >> [x,fval,exitflag,output] = POPfmincon('Bex3_1_1.gms',x0,options);
% 
%  RETURN VALUES
% 
%   x : an approximate optimal solution
%   fval : the objective function value at x 
%   exitflag : output from fmincon or fminunc
%   output : output from fmincon or fminunc
%  
%  OTHER ARGUMENT STYLES
% 
% 	Invoking sparsePOP by the following line:
% 
% >> [x,fval,exitflag,output] ...
%     = POPfmincon(objPoly,ineqPolySys,lbd,ubd);
% >> [x,fval,exitflag,output] ...
%     = POPfmincon(objPoly,ineqPolySys,lbd,ubd,x0);
% >> [x,fval,exitflag,output] ...
%     = POPfmincon(objPoly,ineqPolySys,lbd,ubd,x0,options);
% 
% 	One can directly pass all the information of POP through MATLAB structures.
% 	See userGuide.pdf for the description of each component of the arguments.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

if ischar(objPoly)
    % Input is described in either the GAMS format or the SparsePOP format.
	problemData = objPoly;
    if nargin == 3
        x0 = ineqPolySys; 
        options = lbd;         
    elseif nargin == 2
        x0 = ineqPolySys;         
        options = optimset('Algorithm','trust-region-reflective','GradObj','on',...
            'GradConstr','on','HessFcn',@hessianfcn,'Display','off');        
    else
        x0 = [];         
        options = optimset('Algorithm','trust-region-reflective','GradObj','on',...
            'GradConstr','on','HessFcn',@hessianfcn,'Display','off');        
    end    
    gmsForm = strfind(problemData,'.gms');
    gmsSW = 0; 
    mFileSW = 0;
    if length(gmsForm) == 1
        %
        % Input is a gms file.
        %
        gmsSW = 1;
    elseif length(gmsForm) >1 || isempty(problemData)
        %
        % if input has more than one string 'gms', we regard it as error.
        %
        error('Input problem must be a gms file or polynomial format file.');
    elseif isempty(gmsForm) && ~isempty(problemData)
        %
        % Input is an m-file which returns POP in the SparsePOP format.
        %
        mFileSW = 1;
    end
    % param
    param = [];
    param = defaultParameter(param);    
    % read Data
    if gmsSW == 1 % the input file is a gms file
        [objPoly,ineqPolySys,lbd,ubd,minOrmax] = readGMS(problemData,param.symbolicMath);
    elseif mFileSW == 1
        [objPoly,ineqPolySys,lbd,ubd] = eval(problemData);
	minOrmax = 'min';
    end
elseif ~exist('options')
     options = optimset('Algorithm','trust-region-reflective','GradObj','on',...
            'GradConstr','on','HessFcn',@hessianfcn,'Display','off');        
end

if ~exist('x0','var')
    x0 = [];
end

if (size(objPoly,2) >= 2) && (~isempty(ineqPolySys))
    % a polynomial constrained least square problem
    fprintf('## The problem is regarded as a nonlinear least square problem with\n');
    fprintf('## ineqality/equality constraints and bounds since it involves\n');
    fprintf('## multiple objective functions; size(objPoly,2) >= 2.\n')
%     LSobjPoly = objPoly; 
%     objPoly = [];
%     for i=1:size(LSobjPoly,2)
%         tempPoly = multiplyPolynomials(LSobjPoly{i},LSobjPoly{i});
%         objPoly = plusPolynomials(objPoly,tempPoly);
%     end
    LSobjPoly = objPoly;
    clear objPoly; 
    objPoly.typeCone = 1;
    objPoly.sizeCone = 1;
    objPoly.dimVar   = LSobjPoly{1}.dimVar;
    objPoly.degree = 0;
    objPoly.noTerms  = 0;
    objPoly.supports = [];
    objPoly.coef = [];
    for i=1:size(LSobjPoly,2)
        tempPoly = multiplyPolynomials(LSobjPoly{i},LSobjPoly{i});
        objPoly.degree = max([objPoly.degree,tempPoly.degree]); 
        objPoly.noTerms = objPoly.noTerms + tempPoly.noTerms;
        objPoly.supports= [objPoly.supports;tempPoly.supports];
        objPoly.coef    = [objPoly.coef;tempPoly.coef];        
    end
    objPoly = simplifyPolynomial(objPoly);
elseif(size(objPoly,2) >= 2) 
    % a polynomial least square problem with bounds
    fprintf('## The problem is regarded as a nonlinear least square problem with\n');
    fprintf('## bounds since it involves multiple objective functions; size(objPoly,2) >= 2.\n')
    [x,fval,exitflag,output] = POPlsqnonlin(objPoly,lbd,ubd,x0,options);
    return
end

% if ~isempty(options) && isfield(options,'Display') && strcmp(options.Display,'iter')
fprintf('\n## fmincon or fminunc in Optimization Toolbox\n'); 
%end

if isempty(x0)
    x0 = ones(objPoly.dimVar,1);
elseif size(x0,1) < size(x0,2)
    x0 = x0';
end

if size(x0,1) == 1
    x0 = x0(1,1)*ones(objPoly.dimVar,1);
end
%
% 2011-05-28 H.Waki
%
if issparse(x0)
	x0 = full(x0);
end

startingTime = cputime; 

% if isempty(ineqPolySys) && isempty(lbd) && isempty(ubd)
if isempty(ineqPolySys) && (isempty(lbd) || max(lbd) < -1.0e10) && (isempty(ubd) || min(ubd) > 1.0e10)
   [x,fval,exitflag,output,gradRowVector,HessianMat] = fminunc(@objFunction,x0,options);
elseif isempty(ineqPolySys)
    NineqPolySys = [];
    NeqPolySys = [];
    [x,fval,exitflag,output,gradRowVector,HessianMat] = fmincon(@objFunction,x0,[],[],[],[],lbd,ubd,@nonlcon,options);
else
    [A,b,Aeq,beq,NineqPolySys,NeqPolySys] = genConstraint(ineqPolySys);
    [x,fval,exitflag,output,gradRowVector,HessianMat] = fmincon(@objFunction,x0,A,b,Aeq,beq,lbd,ubd,@nonlcon,options);
end
% fprintf('Algorithm = %s cputime = %7.2e\n',output.algorithm,cputime-startingTime);
% Nested function that computes the objective function, its gradient and
% its Hessian matrix
% --->
    function [fval,gradRowVector,HessianMat] = objFunction(x)
        [fval]= evalPolynomial(objPoly,x);
        [gradRowVector] = evalGradPoly(objPoly,x);
        [HessianMat] = evalHessianMatPoly(objPoly,x);
    end
% <--- 
% Nested function that computes the constraint functions and their
% gradients
% --->
    function [c,ceq,gradc,gradceq] = nonlcon(x);
        c = []; ceq = [];
        gradc = []; gradceq = [];
        if ~isempty(NineqPolySys)
            noConstraints = size(NineqPolySys,2);
            for i=1:noConstraints
                [fval]= evalPolynomial(NineqPolySys{i},x);
                c = [c; -fval];
                [gradRowVector] = evalGradPoly(NineqPolySys{i},x);
                gradc = [gradc; -gradRowVector];
            end
            gradc = gradc'; 
        end
        if ~isempty(NeqPolySys)
            noConstraints = size(NeqPolySys,2);
            for i=1:noConstraints
                [fval]= evalPolynomial(NeqPolySys{i},x);
                ceq = [ceq; -fval];
                [gradRowVector] = evalGradPoly(NeqPolySys{i},x);
                gradceq = [gradceq; -gradRowVector];
            end
            gradceq = gradceq';
        end
    end
% <--- 
% Nested function that computes the Hessian matrix of the Lagrangian
% function 
% ---> 
    function [HessianMatLag] = hessianfcn(x,lambda)
        [HessianMatLag] = evalHessianMatPoly(objPoly,x);
        if ~isempty(NineqPolySys) && ~isempty(lambda.ineqnonlin)
            %             size(NineqPolySys,2)
            %             size(lambda.ineqnonlin)
            for i=1:size(NineqPolySys,2)
                [HessianMat] = evalHessianMatPoly(NineqPolySys{i},x);
                HessianMatLag = HessianMatLag - lambda.ineqnonlin(i)*HessianMat;
            end
        end
        if ~isempty(NeqPolySys) && ~isempty(lambda.eqnonlin)
            %             size(NeqPolySys,2)
            %             size(lambda.eqnonlin)
            for i=1:size(NeqPolySys,2)
                [HessianMat] = evalHessianMatPoly(NeqPolySys{i},x);
                HessianMatLag = HessianMatLag - lambda.eqnonlin(i)*HessianMat;
            end
        end
    end
    function [w] = HessMultFcn(x,lambda,v)
        [HessianMatLag] = hessianfcn(x,lambda);
        w = HessianMatLag*v;
    end
% <--- 
%fprintf('\n'); 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [value,maxAbsMonomial] = evalPolynomial(polyIn,xVect)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % Modified by Kojima, 01/06/05
    % (1) 	The modified version outputs the maximum absolute value,
    % 	maxAbsMonimial of monomials involved in the polynomial
    % 	evaluated at xVect. This gives information how many digits
    % 	are reliable in the evaluation of the polynomial.
    % 	For example, if p(x_1,x_2) = 3*x_1^2 - 0.5*x_1*x_2^2
    % 	and (x_1,x_2) = (-2,3) then
    % 		maxAbsMonomial = max{3*2^2, 0.5*2*3^2} = 12.
    % (2) 	Setting the negligiblly small number to be epsilon instead
    %	of a constant 1.0e-5 in the previous version.
    %	epsilon = 1.0e-8;
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %
    % A single polynomial described as
    %	polyIn.typeCone = -1, 1, 2, or 3
    %	polyIn.sizeCone >= 1
    % 	polyIn.dimVar --- a positive integer
    % 	polyIn.degree --- a positive integer
    % 	polyIn.noTerms --- a positive integer
    % 	polyIn.supports --- a noTerms \times nDim matrix
    % 	polyIn.coef --- a polyIn.noTerms \times size(polyIn.coef,2) matrix.
    % evalPolynomial(polyIn,xVect) returns a real function
    %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    epsilon = 0;%1.0e-8;
    nDim = size(xVect,1);
    if nDim ~= polyIn.dimVar
        error('!!! nDim ~= polyIn.dimVar !!!');
    end
    colSize = size(polyIn.coef,2);
    constant = sum(polyIn.supports,2);
    I = find(constant == 0);
    notI = find(constant > 0);
    typeCone = polyIn.typeCone;
    if ~isempty(I);
        value = sum(polyIn.coef(I,:),1);%1\times sizeCone vector
        value = value';
        maxAbsMonomial = norm(value,inf);
        supSet = polyIn.supports(notI,:);
        coef = polyIn.coef(notI,:);
        noTerms = length(notI);
    else
        value = zeros(colSize,1);
        maxAbsMonomial = 0.0;
        supSet = polyIn.supports;
        coef = polyIn.coef;
        noTerms = polyIn.noTerms;
    end
    if noTerms > 0
        I = find(abs(xVect) > epsilon);
        notI = find(abs(xVect) <= epsilon);
        tempxVect = ones(noTerms,1)* xVect(I)';
        if ~isempty(I)
            monomial = power(tempxVect,supSet(:,I));
            monomial = prod(monomial,2);
        else
            t = size(supSet,1);
            monomial = zeros(t,1);
        end
        J = find(any(supSet(:,notI),2)>0);
        monomial(J) = 0.0;
        value = value + coef'* monomial;
        AllElemVal = coef.*monomial;
        CandMaxVal = max(abs(AllElemVal),2);
        maxAbsMonomial = max(maxAbsMonomial,norm(CandMaxVal,inf));
    elseif isempty(I)
        error('input polynomial is empty.');
    end
	%
	% 2011-05-28 H.Waki
	%
	if issparse(value)
		value = full(value);
	end
	if issparse(maxAbsMonomial)
		maxAbsMonomial = full(maxAbsMonomial);
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [gradRowVector] = evalGradPoly(polyIn,xVect);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Input:
    % xVect : an nDim column vector.
    % polyIn is a single polynomial described as
    %	polyIn.typeCone = -1 or 1; 2 (socp case) and 3 (sdp case) are not
    %                               accepted.
    %	polyIn.sizeCone = 1
    % 	polyIn.dimVar --- a positive integer
    % 	polyIn.degree --- a positive integer
    % 	polyIn.noTerms --- a positive integer
    % 	polyIn.supports --- a noTerms \times nDim matrix
    % 	polyIn.coef --- a polyIn.noTerms column vector.
    % Output:
    % gradRowVector: the gradient row vector of the polynomial at xVect.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    epsilon = 1.0e-15;
    nDim = size(xVect,1);
    if nDim ~= polyIn.dimVar
        error('!!! nDim ~= polyIn.dimVar !!!');
    end
    gradRowVector = sparse(1,nDim);
    for i=1:nDim
        colIndex = find(polyIn.supports(:,i)' > 0);
        if ~isempty(colIndex)
            lenColIndex = length(colIndex);
            tmpSupport = polyIn.supports(colIndex,:);
            tmpSupport(:,i) = tmpSupport(:,i) - ones(lenColIndex,1);
            tmpCoefValue = polyIn.coef(colIndex,1) .* polyIn.supports(colIndex,i);
            I = find(abs(xVect) >= epsilon);
            notI = find(abs(xVect) < epsilon);
            tempxVect = ones(lenColIndex,1)* xVect(I)';
            monomial = power(tempxVect,tmpSupport(:,I));
            monomial = prod(monomial,2);
            J = find(sum(tmpSupport(:,notI),2)>0);
            monomial(J) = 0.0;
            gradRowVector(1,i) = tmpCoefValue'* monomial;
        end
    end
	if issparse(gradRowVector)
		gradRowVector = full(gradRowVector);
	end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [HessianMat] = evalHessianMatPoly(polyIn,xVect);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Input:
    % xVect : an nDim column vector.
    % polyIn is a single polynomial described as
    %	polyIn.typeCone = -1 or 1; 
    %	polyIn.sizeCone = 1
    % 	polyIn.dimVar --- a positive integer
    % 	polyIn.degree --- a positive integer
    % 	polyIn.noTerms --- a positive integer
    % 	polyIn.supports --- a noTerms \times nDim matrix
    % 	polyIn.coef --- a polyIn.noTerms column vector.
    % Output:
    % HessianMat: the Hessian matrix of the polynomial at xVect.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    epsilon = 1.0e-15;
    nDim = size(xVect,1);
    if nDim ~= polyIn.dimVar
        error('!!! nDim ~= polyIn.dimVar !!!');
    end
    HessianMat = sparse(nDim,nDim);
    if polyIn.degree >= 2
        xVectNnzIdx = find(abs(xVect') >= epsilon);
        xVectZeorIdx = find(abs(xVect') < epsilon);
        xVect(xVectZeorIdx,1) = 0;
        termIdx = find(sum(polyIn.supports,2)' >= 2);        
        for t=termIdx
            nzPowerIdx = find(polyIn.supports(t,:) >= 1);
            lenNzPowerIdx = length(nzPowerIdx);
            for p=1:lenNzPowerIdx
                i = nzPowerIdx(p);
                tempSupport = polyIn.supports(t,:);
                tempSupport(1,i) = tempSupport(1,i)-2;
                if tempSupport(1,i) >= 0
                    nzSupIdx = find(tempSupport > 0);
                    if ~isempty(nzSupIdx)
                        if isempty(find(xVect(nzSupIdx,1)' == 0))
                            monomial = power(xVect(nzSupIdx,1)',tempSupport(1,nzSupIdx));
                            HessianMat(i,i) = HessianMat(i,i)+polyIn.coef(t,1)*polyIn.supports(t,i)*(polyIn.supports(t,i)-1)*prod(monomial);
                        end
                    else
                        HessianMat(i,i) = HessianMat(i,i)+polyIn.coef(t,1)*polyIn.supports(t,i)*(polyIn.supports(t,i)-1);
                    end
                end
                tempSupport(1,i) = tempSupport(1,i)+1;
                for q=p+1:lenNzPowerIdx
                    j = nzPowerIdx(q);
                    tempSupport(1,j) = tempSupport(1,j)-1;
                    nzSupIdx = find(tempSupport > 0);
                    if ~isempty(nzSupIdx)
                        if isempty(find(xVect(nzSupIdx,1)' == 0))
                            monomial = power(xVect(nzSupIdx,1)',tempSupport(1,nzSupIdx));
                            HessianMat(i,j) = HessianMat(i,j)+polyIn.coef(t,1)*polyIn.supports(t,i)*polyIn.supports(t,j)*prod(monomial);
                            HessianMat(j,i) = HessianMat(i,j);
                        end
                    else
                        HessianMat(i,j) = HessianMat(i,j)+polyIn.coef(t,1)*polyIn.supports(t,i)*polyIn.supports(t,j);
                        HessianMat(j,i) = HessianMat(i,j);
                    end
                end
            end
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [A,b,Aeq,beq,NineqPolySys,NeqPolySys] = genConstraint(ineqPolySys);   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    noConstraints = size(ineqPolySys,2);
    % classification of constraints ---> 
    LineqIdx = [];
    LeqIdx = [];
    NineqIdx = [];
    NeqIdx = [];
    for i=1:noConstraints
        if ineqPolySys{i}.degree == 1
            if ineqPolySys{i}.typeCone == 1
                LineqIdx = [LineqIdx, i];
            else % ineqPolySys{i}.type == -1
                LeqIdx = [LeqIdx, i];
            end
        else % ineqPolySys{i}.degree >= 2
            if ineqPolySys{i}.typeCone == 1
                NineqIdx = [NineqIdx, i];
            else % ineqPolySys{i}.type == -1
                NeqIdx = [NeqIdx, i];
            end            
        end
    end
    % <--- classification of constraints
    % Linear inequality constraints A x <= b ---> 
    A = [];
    b = [];
	if ~isempty(LineqIdx)
       for i = LineqIdx
            colSum = sum(ineqPolySys{i}.supports,2); 
            constantIdx = find(colSum' == 0);
            linearIdx = find(colSum' > 0);
            if isempty(constantIdx)
               b = [b; 0];  
            else
                b = [b; ineqPolySys{i}.coef(constantIdx,1)];
            end
            oneCoefVector = -ineqPolySys{i}.coef(linearIdx,1)'*ineqPolySys{i}.supports(linearIdx,:);
            A = [A; oneCoefVector]; 
       end
    end
    % <--- Linear inequality constraints Aeq x = beq
    % Linear equality constraints A x <= b ---> 
    Aeq = [];
    beq = [];
	if ~isempty(LeqIdx)
       for i = LeqIdx
            colSum = sum(ineqPolySys{i}.supports,2); 
            constantIdx = find(colSum' == 0); 
            linearIdx = find(colSum' > 0);
            if isempty(constantIdx)
               beq = [beq; 0];  
            else
                beq = [beq; ineqPolySys{i}.coef(constantIdx,1)];
            end    
            oneCoefVector = -ineqPolySys{i}.coef(linearIdx,1)'*ineqPolySys{i}.supports(linearIdx,:);            
            Aeq = [Aeq; oneCoefVector]; 
       end
    end
    % <--- Linear equality constraints Aeq x = beq
    % Nonlinear inequality constraints c(x) <= 0 
    NineqPolySys = [];
    if ~isempty(NineqIdx)
        pointer = 0;
        for i=NineqIdx
            pointer = pointer+1;
            NineqPolySys{pointer} = ineqPolySys{i}; 
        end
    end
    % <--- Noninear inequality constraints c(x) <= 0 
    % Nonlinear equality constraints ceq(x) = 0 --->
    NeqPolySys = [];
    if ~isempty(NeqIdx)
        pointer = 0;
        for i=NeqIdx
            pointer = pointer+1;
            NeqPolySys{pointer} = ineqPolySys{i}; 
        end
    end    
    % <--- Noninear equality constraints ceq(x) = 0
    %
    % 2011-05-28 H. Waki
    %
    if issparse(A)
       A = full(A); 
    end
    if issparse(Aeq)
       Aeq = full(Aeq); 
    end
    if issparse(b)
       b = full(b); 
    end
    if issparse(beq)
       beq = full(beq); 
    end
end
