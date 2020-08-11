function [objPoly,ineqPolySys,lbd,ubd] = simpleExample(objValue,zetaValue,xCenter); 

if nargin == 0
    objValue = [];
    zetaValue = [];
    xCenter = [];
end

% the objective function
% f_0(\x) \equiv x_1 + x_2
objPoly.typeCone = 1;
objPoly.sizeCone = 1;
objPoly.dimVar   = 2;
objPoly.degree   = 1;
objPoly.noTerms  = 2;
objPoly.supports = [1,0; 0,1];
objPoly.coef = [-1; -1];

% the first inequality constraint
ineqPolySys{1}.typeCone = 1;
ineqPolySys{1}.sizeCone = 1;
ineqPolySys{1}.dimVar   = 2;
ineqPolySys{1}.degree = 2;
ineqPolySys{1}.noTerms = 2;
ineqPolySys{1}.supports = [0,0; 2,0];
ineqPolySys{1}.coef = [1;-1];

% the second inequality constraint
ineqPolySys{2}.typeCone = 1;
ineqPolySys{2}.sizeCone = 1;
ineqPolySys{2}.dimVar   = 2;
ineqPolySys{2}.degree = 2;
ineqPolySys{2}.noTerms = 2;
ineqPolySys{2}.supports = [0,0; 0,2];
ineqPolySys{2}.coef = [1;-1];

% the third inequality constraint
ineqPolySys{3}.typeCone = 1;
ineqPolySys{3}.sizeCone = 1;
ineqPolySys{3}.dimVar   = 2;
ineqPolySys{3}.degree = 2;
ineqPolySys{3}.noTerms = 5;
ineqPolySys{3}.supports = [0,0; 1,0; 2,0; 0,1; 0,2];
ineqPolySys{3}.coef = [1; -2; 1; -2; 1];

if (~isempty(objValue)) && (~isempty(zetaValue)) && (~isempty(xCenter))
    ineqPolySys{4}.typeCone = 1;
    ineqPolySys{4}.sizeCone = 1;
    ineqPolySys{4}.dimVar   = 2;
    ineqPolySys{4}.degree = 1;
    ineqPolySys{4}.noTerms = 3;
    ineqPolySys{4}.supports = [0,0; 1,0; 0,1];
    ineqPolySys{4}.coef = [objValue; 1; 1];         
    c = zetaValue - xCenter(1,1)*xCenter(1,1) - xCenter(2,1)*xCenter(2,1);
    b1 = 2*xCenter(1,1);
    b2 = 2*xCenter(2,1);
    ineqPolySys{5}.typeCone = 1;
    ineqPolySys{5}.sizeCone = 1;
    ineqPolySys{5}.dimVar   = 2;
    ineqPolySys{5}.degree = 2;
    ineqPolySys{5}.noTerms = 5;
    ineqPolySys{5}.supports = [0,0; 1,0; 2,0; 0,1; 0,2];
    ineqPolySys{5}.coef = [c; b1; -1; b2; -1];
end

lbd = -1.0e12*ones(1,2);
ubd = 1.0e12*ones(1,2);

return








