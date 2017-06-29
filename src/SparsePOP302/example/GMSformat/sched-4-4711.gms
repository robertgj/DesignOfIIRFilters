* This is obtained from sched-4-4711.pop in http://polip.zib.de/polip.php
*
* SCIP STATISTICS
*   Problem name     : sched-4-4711.pip
*   Variables        : 7  6 binary, 0 integer, 0 implicit integer, 1 continuous 
*   Constraints      : 1
*   Obj. scale       : 1
*   Obj. offset      : 0




Variables
 objvar,
 x0, x1, x2, x3, x4, x5,
 x6;

Binary variables
 x0, x1, x2, x3, x4, x5;

* Variable bounds
*  All other bounds at default value: binary [0,1], integer [0,100], continuous [-inf,+inf]. 

Equations
 objequ,
 c0;

 objequ .. objvar =e=  x6 ;

 c0 ..+ x6  -2* x4 -4* x2 -2* x1 -2* x5 * x3  -2* x0 * x3  +2* x3 * x4  +2* x2 * x4  +2* x5 * x2  +2* x0 
     * x2  +2* x3 * x1  +2* x1 * x2  =l= 0;

Model m / all /;

$if not set MIQCP $set MIQCP MIQCP
Solve m using %MIQCP% maximizing objvar;
