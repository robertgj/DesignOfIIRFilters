% Example of non-linear quasi-newton optimisation using Octave spq
% Copyright (C) 2017,2018 Robert G. Jenssen
% An optimum is at x=[-sqrt(2); 1; -0.527];

test_common;

delete("sqp_test.diary");
delete("sqp_test.diary.tmp");
diary sqp_test.diary.tmp


sqp_common;

% Initialise 
global x d fx gxf W lm tol fiter
tol=1e-5
maxiter=100;
fiter=0;

function gxg=gradxgp(x)
  gxg=gradxg(x);
  gxg=gxg';
endfunction

% Initial point
x0=[30;-20;10]
printf("Initial x0 = [ ");printf("%f ",x0);printf("]\n");

% SQP loop [fails if I pass hessxxf() or hessxxf_diag() with tol=1e-4]
[x, obj, info, iter, nf, lm] = sqp (x0, {@f, @gradxf, @hessxxf}, ...
                                    [], {@g, @gradxgp}, [], [], maxiter, tol)

% Print result
floatPrint("x = ",x); 
floatPrint("f(x) = ",obj); 
floatPrint("lm = ",lm); 
printf("%d iterations f(x) called %d times\n", iter, nf);

diary off
movefile sqp_test.diary.tmp sqp_test.diary;
