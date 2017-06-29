function [objPoly,LSobjPoly] = checkMultipleObj(objPoly); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Checking whether the given problem is a least square problem
%
%   minimize    \sum objPoly{i}^2 
%   subject to  ineqPolySys, lbd and ubd
%
% If size(objPoly,2) >= 2, then replace objPoly by LSobjPoly and set 
%       objPoly = \sum objPolyLS{i}^2. 
% Else LSobjPoly = []. 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if size(objPoly,2) >= 2
    % a constrained least square problem
    fprintf('## The problem is regarded as a nonlinear least square problem\n');
    fprintf('## since it involves multiple objective functions; size(objPoly,2) >= 2.\n')
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
        % objPoly = plusPolynomials(objPoly,tempPoly);
        objPoly.noTerms = objPoly.noTerms + tempPoly.noTerms;
        objPoly.supports= [objPoly.supports;tempPoly.supports];
        objPoly.coef    = [objPoly.coef;tempPoly.coef];        
    end
    objPoly = simplifyPolynomial(objPoly);    
else
    LSobjPoly = [];
end
return
