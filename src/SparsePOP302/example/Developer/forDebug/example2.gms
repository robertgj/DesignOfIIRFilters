* < List of the names of variables >
Variables  x1,x2,objvar;

* < List of the names of constraints >
Equations  e1,e2,e3,e4,e5, e6;

e1..    x2 - objvar =E= 0;

e2..    (x1 -1)^2 + x2^2  =G= 1;

e3..    (x1 +1)^2 + x2^2  =G= 1;

e4..    x1^2 + x2^2  =L= 4;

e5..   x2 =G= 0.01;
e6..   x2 =L= 0;

Solve m using NLP maximizing objvar;

