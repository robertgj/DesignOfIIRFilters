% yalmip_parabolic_convex_bmi_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen
%
% See "Convexiﬁcation of Bilinear Matrix Inequalities via
% Conic and Parabolic Relaxations", Kheirandishfard et al.,
% https://www.columbia.edu/~rm3122/paper/convexification_bilinear.pdf

test_common;

strf="yalmip_parabolic_convex_bmi_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

fhandle=fopen(strcat(strf,".results"),"w");

tic;

verbose=false
maxiter=100
epsilon=1e-8

% See Example 1 of "Convexiﬁcation of Bilinear ...",  Kheirandishfard et al.

printf("\nKheirandishfard example\n");
fprintf(fhandle,"\nKheirandishfard example\n");

y=sdpvar(2,1,"full","real"); 
X=sdpvar(2,2,"symmetric","real");

for eta=[1],

  printf("\neta=%d\n",eta);
  
  yi=[1;1];
  
  for k=1:(maxiter+1),

    if k>maxiter
      printf("\nIteration limit exceeded!\n");
      break;
    endif

    Options=sdpsettings("solver","sedumi");
    % Equation 20a
    Objective=y(1) + eta*(X(1,1)+X(2,2)-(2*(y')*yi)+((yi')*yi));
    % Equation 20b-e
    Constraints=[ [ [2*X(1,1)-X(2,2)+y(2), -X(1,2)+2*y(1)]; ...
                    [-X(1,2)+2*y(1),        X(1,1)+X(2,2)-8] ]<=0, ...
                  (X(1,1)+X(2,2)-2*X(1,2))>=(y(1)-y(2))^2, ...
                  (X(1,1)+X(2,2)+2*X(1,2))>=(y(1)+y(2))^2, ...
                  X(1,1)>=y(1)^2, ...
                  X(2,2)>=y(2)^2 ];
    sol=optimize(Constraints,Objective,Options)
    if sol.problem ~= 0
      error("YALMIP failed : %s",sol.info);
    endif
    check(Constraints)

    vy=value(y);
    printf("\neta=%8.5f,k=%d,y=[%8.5f;%8.5f]\n",eta,k,vy(1),vy(2));

    if norm(vy-yi) > epsilon
      yi=vy;
    else
      fprintf(fhandle,"\neta=%8.5f,k=%d,y=[%8.5f;%8.5f]\n",eta,k,vy(1),vy(2));
      % Check equation 18b
      if ~isdefinite(-[[2*(vy(1)^2)-(vy(2)^2)+vy(2), -vy(1)*vy(2)+2*vy(1)]; ...
                       [-vy(1)*vy(2)+2*vy(1), (vy(1)^2)+(vy(2)^2)-8]])
        error("The example constraint matrix is not negative semi-definite!\n");
      endif
      printf("Stopping criterion met!\n");
      break;
    endif

  endfor
  
endfor

yalmip("clear");

% See: "POLYNOMIAL METHODS FOR ROBUST CONTROL PART II.7 : LMI RELAXATIONS",
% Didier HENRION, June 2007
% https://homepages.laas.fr/henrion/courses/barcelona07/polyrobustII7.pdf
% LMI hierarchy : example Quadratic problem

printf("\nHenrion example\n");
fprintf(fhandle,"\nHenrion example\n");

x=sdpvar(3,1,"full","real"); 
X=sdpvar(3,3,"symmetric","real");

cx=4*x(1)*x(1)-4*x(1)*x(2)+4*x(1)*x(3)-20*x(1)+ ...
   2*x(2)*x(2)-2*x(2)*x(3)+9*x(2)+2*x(3)*x(3)-13*x(3)+24;

for eta=[2,3],

  printf("\neta=%f\n",eta);
  
  xi=[-1;-1;-1];
  
  for k=1:(maxiter+1),

    if k>maxiter
      printf("\nIteration limit exceeded!\n");
      break;
    endif

    Options=sdpsettings("solver","sedumi");
    % Equation 20a
    fx=-2*x(1)+x(2)-x(3);
    Objective=fx + eta*(trace(X)-(2*(x')*xi)+((xi')*xi));
    % Equation 20b-e
    Constraints=[ 4*X(1,1)-4*X(1,2)+4*X(1,3)-20*x(1)+...
                  2*X(2,2)-2*X(2,3)+9*x(2)+2*X(3,3)-13*x(3)+24>=0, ...
                  x(1)+x(2)+x(3)<=4, ...
                  3*x(2)+x(3)<=6, ...
                  0<=x(1)<=2, ...
                  0<=x(2), ...
                  0<=x(3)<=3, ...
                  (X(1,1)+X(2,2)-2*X(1,2))>=(x(1)-x(2))^2, ...
                  (X(1,1)+X(2,2)+2*X(1,2))>=(x(1)+x(2))^2, ...
                  (X(1,1)+X(3,3)-2*X(1,3))>=(x(1)-x(3))^2, ...
                  (X(1,1)+X(3,3)+2*X(1,3))>=(x(1)+x(3))^2, ...
                  (X(2,2)+X(3,3)-2*X(2,3))>=(x(2)-x(3))^2, ...
                  (X(2,2)+X(3,3)+2*X(2,3))>=(x(2)+x(3))^2 ];
    sol=optimize(Constraints,Objective,Options)
    if sol.problem ~= 0
      error("YALMIP failed : %s",sol.info);
    endif
    check(Constraints)

    vx=real(value(x));
    vfx=real(value(fx));
    vcx=real(value(cx));
    printf("\neta=%8.5f,k=%d,x=[%8.5f;%8.5f;%8.5f],fx=%8.5f\n", ...
           eta,k,vx(1),vx(2),vx(3),vfx);
    if norm(vx-xi)>epsilon
      xi=vx;
    else
      fprintf(fhandle,"\neta=%8.5f,k=%d,x=[%8.5f;%8.5f;%8.5f],fx=%8.5f\n", ...
              eta,k,vx(1),vx(2),vx(3),vfx);
      printf("Stopping criterion met!\n");
      break;
    endif

  endfor

  if vcx<-epsilon
    warning("BMI constraint failed at eta=%8.5f,fx=%8.5f,cx=%8.5f\n",
            eta,vfx,vcx);
    fprintf(fhandle,"BMI constraint failed at eta=%8.5f,fx=%8.5f,cx=%8.5f\n", ...
            eta,vfx,vcx);
  endif

endfor

% Done
toc;
fclose(fhandle);
diary off;
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
