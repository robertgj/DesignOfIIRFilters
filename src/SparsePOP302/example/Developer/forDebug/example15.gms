* example11.gms --- fixed all variables, infeasible. 

Variables  x1,x2,x3,objvar;

Positive Variables x1, x2;

Equations  e1,e2,e3,e4;

* minimize objvar = -2*x1 +3*x2 -2*x3
e1..    2*x1 - 3*x2 +objvar +2*x3 =E= 0;

e2..    x1 + x2 + x3 =E= 4;

e3..    x2 =E= 0;

e4..    x3 =E= 3;

x2.fx = 0;
x3.fx = 3;

* end of example11.gms
