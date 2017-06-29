* 2011-11-28 H.Waki
* We modified ex9_2_8.gms to debug a bug in deleteVar.m
*

Variables  objvar,x2,x3,x4,x5,x6,x7;

Positive Variables x2,x3,x4,x5,x7;

Equations  e1,e2,e3,e4,e5,e6;


e1.. 3*x6 - 4*x2*x6 + 2*x2 - objvar =E= -1;

e2..  - x6 + x4 =E= 0;

e3..    x6 + x5 =E= 1;

e4.. x3*x4 =E= 0;

e5.. x7*x5 =E= 0;

e6..    4*x2 - x3 + x7 =E= 1;

* set non default bounds

x2.up = 1; 
x4.up = 20; 
x5.up = 20; 
x3.fx = 0; 
x7.fx = 0; 

* set non default levels


* set non default marginals


Model m / all /;

m.limrow=0; m.limcol=0;

$if NOT '%gams.u1%' == '' $include '%gams.u1%'

Solve m using NLP minimizing objvar;

