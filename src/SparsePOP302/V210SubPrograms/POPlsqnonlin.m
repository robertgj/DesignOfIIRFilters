function [x,fval,exitflag,output] = POPlsqnonlin(LSobjPoly,lbd,ubd,x0,options)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  POPlsqnonlin --- a nonlinear least sqaure minimization with bounds described 
%                   in the SparsePOP format using lsqnonlin
%
%   Here a nonlinear least sqaure minimization problem is of the form 
%       minimize    \sum_{k=1}^m f_k(x)
%       subject to  lbd_i <= x_i ubd_i (i=1,2,...,n)
%   The function f_k in the objective function is described in terms of
%   objPolyLS{k}. 
% 
%  GENERAL DESCRIPTION
% 
%   A typical invoking line may be:
% 
% >>  [x,fval,exitflag,output] = POPlsqnonlin(DataFile);
% 
% 	The meanings of argument and return values are described below.
% 
%  FILE ARGUMENT
% 
% 	DataFile must be a string containing the file name. The DataFile must
% 	be written in the SparsePOP format. For example, call with
% >> [x,fval,exitflag,output] = POPlsqnonlin('BroydenTriLS(10)');
% 	See userGuide.pdf for more details for the SparsePOP format. 
%
%   The user can specify an initial point x0 and options for lsqnonlin;
% >> [x,fval,exitflag,output] = POPlsqnonlin('BroydenTriLS(10)',x0);
% >> [x,fval,exitflag,output] = POPlsqnonlin('BroydenTriLS(10)',x0,options);
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
%     = POPfmincon(LSobjPoly,lbd,ubd);
% >> [x,fval,exitflag,output] ...
%     = POPlsqnonlin(LSobjPoly,lbd,ubd,x0);
% >> [x,fval,exitflag,output] ...
%     = POPlsqnonlin(LSobjPoly,lbd,ubd,x0,options);
% 
% 	One can directly pass all the information of a nonlinear least square problem
%   with bounds through MATLAB structures.
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

if ischar(LSobjPoly)
    % Input is described in either the GAMS format or the SparsePOP format.
	problemData = LSobjPoly;
    if nargin == 3
        x0 = lbd; 
        options = ubd;         
    elseif nargin == 2
        x0 = lbd;         
        options = optimset('Jacobian','on');
    else
        x0 = [];         
        options = optimset('Jacobian','on');
    end    
    gmsForm = strfind(problemData,'.gms');
    gmsSW = 0; 
    mFileSW = 0;
    if length(gmsForm) == 1
        %
        % Input is a gms file.
        %
        gmsSW = 1;
        error('Input problem must be a polynomial format file.');
    elseif length(gmsForm) >1 || isempty(problemData)
        %
        % if input has more than one string 'gms', we regard it as error.
        %
        error('Input problem must be a polynomial format file.');
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
        error('Input problem must be a polynomial format file.');
    elseif mFileSW == 1
        [LSobjPoly,ineqPolySys,lbd,ubd] = eval(problemData);
    end    
elseif ~exist('options')
    options = optimset('Jacobian','on'); 
end

fprintf('\n## lsqnonlin in Optimization Toolbox\n\n'); 

if ~exist('x0','var') || isempty(x0)
    x0 = ones(LSobjPoly{1}.dimVar,1);
elseif size(x0,1) < size(x0,2)
    x0 = x0';
end
if size(x0,1) == 1
    x0 = x0(1,1)*ones(LSobjPoly{1}.dimVar,1);
end
[x,resnorm,residual,exitflag,output] = ...
	lsqnonlin(@functGradient,x0,lbd,ubd,options);
[F] = functGradient(x); 
fval = F' * F; 
% Nested function that computes the values of F and the Jacobian matrix DF
% --->
    function [F, DF] = functGradient(x);
        F = [];
        DF = [];
        if nargout == 2
            for i=1:size(LSobjPoly,2)
                [value] = evalPolynomial(LSobjPoly{i},x);
                F = [F; value];
                [gradRowVector] = evalGradPoly(LSobjPoly{i},x);
                DF = [DF; gradRowVector];
            end
        else
             for i=1:size(LSobjPoly,2)
                [value] = evalPolynomial(LSobjPoly{i},x);
                F = [F; value];
            end
       end
    end
% <---
fprintf('\n'); 
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
    if ~isempty(I)
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
%     AllElemVal = coef.*monomial;
%     CandMaxVal = max(abs(AllElemVal),2);
%     maxAbsMonomial = max(maxAbsMonomial,norm(CandMaxVal,inf));
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
end
