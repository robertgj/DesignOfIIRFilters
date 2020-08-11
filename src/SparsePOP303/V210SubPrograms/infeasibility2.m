function [infeasError,scaledError] = infeasibility2(inEqPolySys,xVect)
%%%%%%
% Check the feasibility of xVect.
% If infeasError >= 0 and scaledError >= 0
% then xVect is feasible in given region.
%%%%%%
% Modified by M. Kojima, 01/06/05.
%
% The modified version outputs a relative infeasibility error,
% scaledError.
%
% Let maxAbsMonomial(f,x) be the maximum over the absolute values of all
% monimials evaluated at x if the maximum is greater than 1 or
%  maxAbsMonomial(f,x) = 1 otherweise;
% 	maxAbsMonomial(f,x)
%	= max { | c_{\alpha} x^{\alpha} | (\alpha \in \FC), 1 },
% where we assume f(x) = \sum_{\alpha \in \FC} c_{\alpha} x^{\alpha}.
% If inequalities f_i(x) \geq 0 are given as input, then
% 	infeasError = min_i { min{f_i(x),0} },
% 	scaledError = min_i { min{f_i(x),0} / max{1,maxAbsMonomial(f,x)} }.
% If inequalities f_i(x) = 0 are given as input, then
%       infeasError = min_i { - |f_i(x)| },
%       scaledError = min_i { - |f_i(x)| / max{1, maxAbsMonomial(f,x)} }.
%
%%%%%%
noOfinEqPolySys = size(inEqPolySys,2);
infeasError = 0;
scaledError = 0;
for i=1:noOfinEqPolySys
    if inEqPolySys{i}.typeCone == 1
        [value,maxAbsMonomial] = evalPolynomials(inEqPolySys{i},xVect);
        maxAbsMonomial = max(1, maxAbsMonomial);
        %fprintf('%d --- %f\n',i,value);
        scaledError = min(scaledError,value/maxAbsMonomial);
        infeasError = min(infeasError,value);
    elseif inEqPolySys{i}.typeCone == 2
        vecSize = inEqPolySys{i}.sizeCone;
        [funcValues,maxAbsMonomial] = evalPolynomials(inEqPolySys{i},xVect);
        maxAbsMonomial = max(1, maxAbsMonomial);
        value = funcValues(1)-sqrt(sum(funcValues(2:vecSize).^(2* ...
            ones(1,vecSize-1))));
        %fprintf('%d --- %f\n',i,value);
        scaledError = min(scaledError,value/maxAbsMonomial);
        infeasError = min(infeasError,value);
    elseif inEqPolySys{i}.typeCone == 3
        [funcValues,maxAbsMonomial] = evalPolynomials(inEqPolySys{i},xVect);
        maxAbsMonomial = max(1, maxAbsMonomial);
        matSize = inEqPolySys{i}.sizeCone;
        sMat = reshape(funcValues,matSize,matSize);
        d = eig(sMat);
        scaledError = min(scaledError,min(d)/maxAbsMonomial);
        infeasError = min(infeasError,min(d));
    elseif inEqPolySys{i}.typeCone == -1
        [value,maxAbsMonomial] = evalPolynomials(inEqPolySys{i},xVect);
        maxAbsMonomial = max(1, maxAbsMonomial);
        %fprintf('%d --- %f\n',i,value);
        scaledError = min(scaledError,-abs(value)/maxAbsMonomial);
        infeasError = min(infeasError,-abs(value));
        %fprintf('%d --- %f\n',i,scaledError);
    end
end
return
