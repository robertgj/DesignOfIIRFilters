* Example to check whether param.binarySW and param.SquareOneSW work or not.
* 
Variables  x1,x2,x3,objvar;

* Positive Variables x1, x2, x3;

Equations  e1,e2,e3,e4;

e1..    2*x1 - 3*x2 + 2*x3 + objvar =E= 0;

e2..    x1^2 =E= x1;
e3..    x2^2 =E= x2;
e4..    x3^2 =E= x3;

*x1.up = 2;
*x2.up = 1;
