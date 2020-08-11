*
* min{ -x-y | 0.5 - x*y >= 0, x, y >= 0.5}
* This POP is solved in the following paper:
* How to generate weakly infeasible semidefinite programs 
* via Lasserre's relaxations for polynomial optimization,
* available at http://www.optimization-online.org/DB_HTML/2011/07/3086.html
*
Variables x,y, objvar;
Equations e1, e2, e3, e4;

e1.. - x - y - objvar =E= 0;
e2.. x*y =L= 0.5;
e3.. x =G= 0.5;
e4.. y =G= 0.5;
