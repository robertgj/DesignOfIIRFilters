1;

% sqp_common.m
% Copyright (C) 2017-2025 Robert G. Jenssen


  % Expected minimum: x=[-sqrt(2); 1; -0.527];
  xi=[30;-20;10];
  lbx=[-200; -150; -100];
  ubx=[ 150;  100;  100];

  function fx=f(x)
    global fiter
    fiter=fiter+1;
    fx=x(1)^4+x(2)^4+x(3)^4+x(1)*x(2)+x(1)*x(3)+x(2)*x(3)+x(1)+x(2)+x(3)+5;
  endfunction

  function gxf=gradxf(x)
    gxf=[4*x(1)^3+x(2)+x(3)+1;4*x(2)^3+x(1)+x(3)+1;4*x(3)^3+x(1)+x(2)+1];
  endfunction

  function hxxf=hessxxf(x)
    hxxf=[12*x(1)^2 1 1;1 12*x(2)^2 1;1 1 12*x(3)^2];
  endfunction

  function gx=g(x)
    gx=[x(2)-1;-x(1)-sqrt(2);-x(3)-0.5];
  endfunction

  function gxg=gradxg(x)
    gxg=[0 1 0; -1 0 0; 0 0 -1]';
  endfunction

  %{
  % Rosenbrock's function: f(x,y)=(a-x)^2 + b(y-x^2)^2  has a global
  % minimum at (x,y)=(a,a^2), f(x,y)=0. Usually a=1 and b=100.
  
  xi=[2;2];
  lbx=[-200; -150];
  ubx=[ 150;  100];

  global a=1 b=100
  
  function fx=f(x)
    global fiter a b
    fiter=fiter+1;
    fx=((a-x(1))^2)+(b*((x(2)-(x(1)^2))^2));
  endfunction

  function gxf=gradxf(x)
    global a b
    gxf=zeros(length(x),1);
    gxf(1)=-(2*a)+(2*x(1))-(4*b*x(2)*x(1))+(4*b*(x(1)^3));
    gxf(2)=(2*b*x(2))-(2*b*(x(1)^2));
  endfunction

  function hxxf=hessxxf(x)
    global a b
    hxxf=zeros(length(x),length(x));
    hxxf(1,1)=2-(4*b*x(2))+(12*b*(x(1)^2));
    hxxf(1,2)=-(4*b*x(1));
    hxxf(2,1)=hxxf(1,2);
    hxxf(2,2)=2*b;
  endfunction

  function gx=g(x)
    gx=[1+x(2);x(1)-sqrt(2)];
  endfunction

  function gxg=gradxg(x)
    gxg=[0 1;1 0]';
  endfunction
  %}

  %{
  % Himmelblau's function: f(x,y)=(x^2+y-11)^2 + (x+y^2-7)^2  has 
  % minima of value 0 at (3.0,2.0), (-2.805118,3.131312), (-3.779310,-3.283185)
  % and (3.584428,-1.848126)
  
  xi=[-3;3];
  lbx=[-10; -10];
  ubx=[ 10;  10];

  global a=11 b=7
  
  function fx=f(x)
    global fiter a b
    fiter=fiter+1;
    fx=(((x(1)^2)+x(2)-a)^2) + ((x(1)+(x(2)^2)-b)^2);
  endfunction

  function gxf=gradxf(x)
    global a b
    gxf=zeros(length(x),1);
    gxf(1)=(4*x(1)*((x(1)^2)+x(2)-a))+(2*(x(1)+(x(2)^2)-b));
    gxf(2)=(2*((x(1)^2)+x(2)-a))+(4*x(2)*(x(1)+(x(2)^2)-b));
  endfunction

  function hxxf=hessxxf(x)
    global a b
    hxxf=zeros(length(x),length(x));
    hxxf(1,1)=(12*(x(1)^2))+(4*x(2))-42;
    hxxf(1,2)=4*(x(1)+x(2));
    hxxf(2,1)=4*(x(1)+x(2));
    hxxf(2,2)=(12*(x(2)^2))+(4*x(1))-26;
  endfunction

  function gx=g(x)
    gx=[4-x(2);4-x(1)];
  endfunction

  function gxg=gradxg(x)
    gxg=[0 -1;-1 0]';
  endfunction
  %}

function hxxf=hessxxf_diag(x)
  hxxf=diag(diag(hessxxf(x)));
endfunction

function hxxf=hessxxf_eye(x)
  hxxf=eye(length(x));
endfunction

function [fx,gxf,hxxf]=sqp_fx(x)
  fx=f(x);
  gxf=gradxf(x);
  hxxf=hessxxf(x);
endfunction

function [gx,gxg]=sqp_gx(x)
  gx=g(x);
  gxg=gradxg(x);
endfunction

function floatPrint(s,x)
  printf("%s [ ",s);printf("%.5e ",x);printf("]\n");
endfunction

function intPrint(s,x)
  printf("%s [ ",s);printf("%d ",x);printf("]\n");
endfunction

function strPrint(s)
  printf("%s\n",s);
endfunction

function cf=contourf()
  v=-100:100;
  cf=zeros(201,201);
  for m=v
    for n=v
      cf(m+101,n+101)=f([-sqrt(2);m;n]/25);
    endfor
  endfor
  contour(v/25,v/25,cf);
endfunction

function pf=plotf()
  v=-100:100;
  pf=zeros(201);
  for n=v
    pf(n+101)=f([-100*sqrt(2);100;n-50]/100);
  endfor
  plot((v-50)/100,pf);
endfunction
