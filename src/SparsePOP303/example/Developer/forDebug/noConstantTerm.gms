*
* min{ x | x^2 >= 1, x >= 0}
* This POP is solved in the following paper:
* H. Waki, M. Nakata and M. Muramatsu, 
* Strange Behaviors of Interior-point Methods 
* for Solving Semidefinite Programming
* Problems in Polynomial Optimization, 
* available at http://www.optimization-online.org/DB_FILE/2008/08/2065.pdf 
* 
Variables x, objvar;
Equations e1, e2;

e1.. x - objvar =E= 0;
e2.. x  =G= 0;
