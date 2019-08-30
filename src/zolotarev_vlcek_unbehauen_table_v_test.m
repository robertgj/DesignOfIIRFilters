% zolotarev_vlcek_unbehauen_table_v_test.m
% Working for Vlcek and Unbehauen Table V. See:
%  [1] "Zolotarev Polynomials and Optimal FIR Filters", M. Vlcek and
%       R. Unbehauen, IEEE Transactions on Signal Processing, Vol. 47,
%       No. 3, March, 1999, pp. 717-730
%  [2] Corrections to "Zolotarev Polynomials and Optimal FIR Filters",
%      M. Vlcek and R. Unbehauen, IEEE Transactions on Signal Processing,
%      Vol. 48, No.7, July, 2000 p. 2171
% Copyright (C) 2019 Robert G. Jenssen

test_common;

unlink("zolotarev_vlcek_unbehauen_table_v_test.diary");
unlink("zolotarev_vlcek_unbehauen_table_v_test.diary.tmp");
diary zolotarev_vlcek_unbehauen_table_v_test.diary.tmp

strf="zolotarev_vlcek_unbehauen_table_v_test";

% Initialise
p=3;
q=6;
n=p+q;
k=0.682;
k2=k^2;
K=ellipke(k2);
n=p+q;
u0=p*K/n;
[snu0,cnu0,dnu0]=ellipj(u0,k2);
Zu0=jacobi_Zeta(u0,k);
wp=(2*((cnu0/dnu0)^2))-1;
ws=(2*(cnu0^2))-1;
wm=ws+(2*(snu0*cnu0)*Zu0/dnu0);
wq=(wp+ws)/2;

%
% Expand the b power series in Chebychev Type 1 polynomials
%
if 0
  % From Table VI
  alphaTvi=[ 0.098598, 0.097937,-0.098642,-0.193401,-0.093506, ...
             0.095518, 0.182318, 0.085744,-0.088768,-1.085798];
else
  % From Table IV
  [a,b]=zolotarev_vlcek_unbehauen(p,q,k);
  n=p+q;
  alphaTvi=zeros(1,1+n);
  bt=b;
  for m=n:-1:0,
    Tm=chebychevT(m);
    Tm=fliplr(Tm);
    alphaTvi(1+m)=bt(1+m)/Tm(end);
    bt(1+(0:m))=bt(1+(0:m))-(alphaTvi(1+m)*Tm);
  endfor
  tol=1e-12;
  if max(abs(alphaTvi-a))>tol
    error(" max(abs(alphaTvi-a))>%g",tol);
  endif
endif

%
% Confirm that the alpha coefficients from Table VI satisfy Equation 75
%
eqn75=zeros(3,n+5);
for m=0:n,
  [Tm,Tmm1]=chebychevT(m);
  if 0
    eqn1=-conv(conv([1,-wp],conv([1,-ws],[1,-wm])),(m^2)*alphaTvi(1+m)*Tm);
    eqn2a=-conv((conv([1,-wp],[1,-ws])-conv([1,-wm],[1,-wq])), ...
                m*alphaTvi(1+m)*Tmm1);
    eqn2b=-conv((conv([1,-wp],[1,-ws])-conv([1,-wm],[1,-wq])), ...
                m*alphaTvi(1+m)*conv(Tm,[-1,0]));
    eqn3=+conv((n^2)*conv([1,-wm],conv([1,-wm],[1,-wm])),alphaTvi(1+m)*Tm);
  elseif 0
    eqn1=-conv([1,(-wp-ws-wm),(wm*wp)+(wm*ws)+(wp*ws),-wp*wm*ws], ...
               (m^2)*alphaTvi(1+m)*Tm);
    eqn2a=-conv([(-wp-ws+wm+wq),((wp*ws)-(wm*wq))],m*alphaTvi(1+m)*Tmm1);
    eqn2b=-conv([(-wp-ws+wm+wq),((wp*ws)-(wm*wq))], ...
                m*alphaTvi(1+m)*conv(Tm,[-1,0]));
    eqn3=+conv((n^2)*[1,-(3*wm),(3*(wm^2)),-(wm^3)],alphaTvi(1+m)*Tm);
  elseif 1
    eqn1=(m^2)*conv([-1,(wp+ws+wm),-((wm*wp)+(wm*ws)+(wp*ws)),wp*wm*ws], ...
                                                       alphaTvi(1+m)*Tm);
    eqn2a=   m*conv([0,0,(wp+ws-wm-wq),(-(wp*ws)+(wm*wq))],alphaTvi(1+m)*Tmm1);
    eqn2b=   m*conv([0,(-wp-ws+wm+wq),(wp*ws)-(wm*wq),0],alphaTvi(1+m)*Tm);
    eqn3=(n^2)*conv([1,-(3*wm),(3*(wm^2)),-(wm^3)],    alphaTvi(1+m)*Tm);
  endif
  eqn75(1,:)=eqn75(1,:)+[zeros(1,columns(eqn75)-columns(eqn1)),eqn1];
  eqn75(2,:)=eqn75(2,:)+[zeros(1,columns(eqn75)-columns(eqn2a)),eqn2a];
  eqn75(2,:)=eqn75(2,:)+[zeros(1,columns(eqn75)-columns(eqn2b)),eqn2b];
  eqn75(3,:)=eqn75(3,:)+[zeros(1,columns(eqn75)-columns(eqn3)),eqn3];
endfor
tol=1e-10;
if sum(abs(sum(eqn75,1))) > tol
  error("sum(abs(sum(eqn75,1))) > %g",tol);
endif

%
% Check working for equation in alpha, Tm, Tm-1
%
eqn=zeros(6,n+5);
for m=0:n,
  [Tm,Tmm1]=chebychevT(m); 
  eqn1=((n^2)-(m^2))*alphaTvi(1+m)*conv([1,0,0,0],Tm);
  eqn2=((m*(m-1)*wp)+(m*(m-1)*ws)+(((m^2)+m-(3*(n^2)))*wm)+(m*wq))* ...
       alphaTvi(1+m)*conv([1,0,0],Tm);
  eqn3=((3*(n^2)*(wm^2))-((m^2)*wm*wp)-((m^2)*wm*ws)-((m^2)*wp*ws)+ ...
        (m*wp*ws)-(m*wm*wq))*alphaTvi(1+m)*conv([1,0],Tm);
  eqn4=((m*wp)+(m*ws)-(m*wm)-(m*wq))*alphaTvi(1+m)*conv([1,0],Tmm1);
  eqn5=(-((n^2)*(wm^3))+((m^2)*wm*wp*ws))*alphaTvi(1+m)*Tm; 
  eqn6=((m*wm*wq)-(m*wp*ws))*alphaTvi(1+m)*Tmm1;
  
  eqn(1,:)=eqn(1,:)+[zeros(1,columns(eqn)-columns(eqn1)),eqn1];
  eqn(2,:)=eqn(2,:)+[zeros(1,columns(eqn)-columns(eqn2)),eqn2];
  eqn(3,:)=eqn(3,:)+[zeros(1,columns(eqn)-columns(eqn3)),eqn3];
  eqn(4,:)=eqn(4,:)+[zeros(1,columns(eqn)-columns(eqn4)),eqn4];
  eqn(5,:)=eqn(5,:)+[zeros(1,columns(eqn)-columns(eqn5)),eqn5];
  eqn(6,:)=eqn(6,:)+[zeros(1,columns(eqn)-columns(eqn6)),eqn6];
endfor
tol=1e-10;
if sum(abs(sum(eqn,1))) > tol
  error("sum(abs(sum(eqn,1))) > %g",tol);
endif

%
% Check working for equation in alpha, Tm+3,...,Tm-3
%
eqn02=zeros(7,n+5);
eqn=zeros(7,n+5);
for m=0:2
  [Tm,Tmm1]=chebychevT(m); 
  eqn1=((n^2)-(m^2))*alphaTvi(1+m)*conv([1,0,0,0],Tm);
  eqn2=((m*(m-1)*wp)+(m*(m-1)*ws)+(((m^2)+m-(3*(n^2)))*wm)+(m*wq))* ...
       alphaTvi(1+m)*conv([1,0,0],Tm);
  eqn3=((3*(n^2)*(wm^2))-((m^2)*wm*wp)-((m^2)*wm*ws)-((m^2)*wp*ws)+ ...
        (m*wp*ws)-(m*wm*wq))*alphaTvi(1+m)*conv([1,0],Tm);
  eqn4=((m*wp)+(m*ws)-(m*wm)-(m*wq))*alphaTvi(1+m)*conv([1,0],Tmm1);
  eqn5=(-((n^2)*(wm^3))+((m^2)*wm*wp*ws))*alphaTvi(1+m)*Tm; 
  eqn6=((m*wm*wq)-(m*wp*ws))*alphaTvi(1+m)*Tmm1;
  
  eqn02(1,:)=eqn02(1,:)+[zeros(1,columns(eqn)-columns(eqn1)),eqn1];
  eqn02(2,:)=eqn02(2,:)+[zeros(1,columns(eqn)-columns(eqn2)),eqn2];
  eqn02(3,:)=eqn02(3,:)+[zeros(1,columns(eqn)-columns(eqn3)),eqn3];
  eqn02(4,:)=eqn02(4,:)+[zeros(1,columns(eqn)-columns(eqn4)),eqn4];
  eqn02(5,:)=eqn02(5,:)+[zeros(1,columns(eqn)-columns(eqn5)),eqn5];
  eqn02(6,:)=eqn02(6,:)+[zeros(1,columns(eqn)-columns(eqn6)),eqn6];
endfor
for m=3:n,
  Tmp3=chebychevT(m+3);
  Tmp3=[zeros(1,columns(eqn)-columns(Tmp3)),Tmp3];
  Tmp2=chebychevT(m+2);
  Tmp2=[zeros(1,columns(eqn)-columns(Tmp2)),Tmp2];
  Tmp1=chebychevT(m+1);
  Tmp1=[zeros(1,columns(eqn)-columns(Tmp1)),Tmp1];
  Tm=chebychevT(m);
  Tm=[zeros(1,columns(eqn)-columns(Tm)),Tm];
  Tmm1=chebychevT(m-1);
  Tmm1=[zeros(1,columns(eqn)-columns(Tmm1)),Tmm1];
  Tmm2=chebychevT(m-2);
  Tmm2=[zeros(1,columns(eqn)-columns(Tmm2)),Tmm2];
  Tmm3=chebychevT(m-3);
  Tmm3=[zeros(1,columns(eqn)-columns(Tmm3)),Tmm3];

  if any((Tmm3+(3*Tmm1)+(3*Tmp1)+Tmp3)-(8*shift(Tm,-3)))
    error("any((Tmm3+(3*Tmm1)+(3*Tmp1)+Tmp3)-(8*shift(Tm,-3)))");
  endif
  if any((Tmm2+(2*Tm)+Tmp2)-(4*shift(Tm,-2)))
    error("any((Tmm2+(2*Tm)+Tmp2)-(4*shift(Tm,-2)))");
  endif
  if any((Tmm1+Tmp1)-(2*shift(Tm,-1)))
    error("any((Tmm1+Tmp1)-(2*shift(Tm,-1)))");
  endif
  if any((Tmm2+Tm)-(2*shift(Tmm1,-1)))
    error("any((Tmm2+Tm)-(2*shift(Tmm1,-1)))");
  endif
  
  if 0
    eqn(1,:)=eqn(1,:)+ ...
             ((n^2)-(m^2))*alphaTvi(1+m)*(Tmm3+(3*Tmm1)+(3*Tmp1)+Tmp3)/8;
    eqn(2,:)=eqn(2,:)+ ...
             ((m*(m-1)*wp)+(m*(m-1)*ws)+(((m^2)+m-(3*(n^2)))*wm)+(m*wq))* ...
             alphaTvi(1+m)*(Tmm2+(2*Tm)+Tmp2)/4;
    eqn(3,:)=eqn(3,:)+ ...
             ((3*(n^2)*(wm^2))-((m^2)*wm*wp)-((m^2)*wm*ws)-((m^2)*wp*ws)+ ...
              (m*wp*ws)-(m*wm*wq))*alphaTvi(1+m)*(Tmm1+Tmp1)/2;
    eqn(4,:)=eqn(4,:)+ ...
             ((m*wp)+(m*ws)-(m*wm)-(m*wq))*alphaTvi(1+m)*(Tmm2+Tm)/2;
    eqn(5,:)=eqn(5,:)+(-((n^2)*(wm^3))+((m^2)*wm*wp*ws))*alphaTvi(1+m)*Tm; 
    eqn(6,:)=eqn(6,:)+((m*wm*wq)-(m*wp*ws))*alphaTvi(1+m)*Tmm1; 
  elseif 0
    eqn=eqn*8;
    eqn(1,:)=eqn(1,:)+ ...
             ((n^2)-(m^2))*alphaTvi(1+m)*(Tmm3+(3*Tmm1)+(3*Tmp1)+Tmp3);
    eqn(2,:)=eqn(2,:)+ ...
             ((m*(m-1)*wp)+(m*(m-1)*ws)+(((m^2)+m-(3*(n^2)))*wm)+(m*wq))* ...
             alphaTvi(1+m)*((2*Tmm2)+(4*Tm)+(2*Tmp2));
    eqn(3,:)=eqn(3,:)+ ...
             ((3*(n^2)*(wm^2))-((m^2)*wm*wp)-((m^2)*wm*ws)-((m^2)*wp*ws)+ ...
              (m*wp*ws)-(m*wm*wq))*alphaTvi(1+m)*((4*Tmm1)+(4*Tmp1));
    eqn(4,:)=eqn(4,:)+ ...
             ((m*wp)+(m*ws)-(m*wm)-(m*wq))*alphaTvi(1+m)*((4*Tmm2)+(4*Tm));
    eqn(5,:)=eqn(5,:)+(-((n^2)*(wm^3))+((m^2)*wm*wp*ws))*alphaTvi(1+m)*Tm*8; 
    eqn(6,:)=eqn(6,:)+((m*wm*wq)-(m*wp*ws))*alphaTvi(1+m)*Tmm1*8;
    eqn=eqn/8;
  else
    eqn=eqn*8;
    eqn(1,:)=eqn(1,:)+ ...
             ((n^2)-(m^2)) ...
              *alphaTvi(1+m)*Tmp3;
    eqn(2,:)=eqn(2,:)+ ...
             (2*((m*(m-1)*wp)+(m*(m-1)*ws)+(((m^2)+m-(3*(n^2)))*wm)+(m*wq))) ...
              *alphaTvi(1+m)*Tmp2;
    eqn(3,:)=eqn(3,:)+ ...
             ((3*((n^2)-(m^2))) ...
              +(4*((3*(n^2)*(wm^2))-((m^2)*wm*wp)- ...
                    ((m^2)*wm*ws)-((m^2)*wp*ws)+(m*wp*ws)-(m*wm*wq)))) ...
             *alphaTvi(1+m)*Tmp1;
    eqn(4,:)=eqn(4,:)+ ...
             ((4*((m*(m-1)*wp)+(m*(m-1)*ws)+(((m^2)+m-(3*(n^2)))*wm)+(m*wq))) ...
                +(4*((m*wp)+(m*ws)-(m*wm)-(m*wq))) ...
                +(8*(-((n^2)*(wm^3))+((m^2)*wm*wp*ws)))) ...
              *alphaTvi(1+m)*Tm;
    eqn(5,:)=eqn(5,:)+ ...
             ((3*((n^2)-(m^2))) ...
              +(4*((3*(n^2)*(wm^2))-((m^2)*wm*wp)- ...
                    ((m^2)*wm*ws)-((m^2)*wp*ws)+(m*wp*ws)-(m*wm*wq))) ...
              +(8*((m*wm*wq)-(m*wp*ws)))) ...
             *alphaTvi(1+m)*Tmm1;
    eqn(6,:)=eqn(6,:)+ ...
             ((2*((m*(m-1)*wp)+(m*(m-1)*ws)+ ...
                  (((m^2)+m-(3*(n^2)))*wm)+(m*wq))) ...
              +(4*((m*wp)+(m*ws)-(m*wm)-(m*wq)))) ...
              *alphaTvi(1+m)*Tmm2;
    eqn(7,:)=eqn(7,:)+ ...
             ((n^2)-(m^2)) ...
             *alphaTvi(1+m)*Tmm3;
    eqn=eqn/8;    
  endif
endfor
tol=1e-10;
if sum(abs(sum(eqn02+eqn,1))) > tol
  error("sum(abs(sum(eqn02+eqn,1))) > %g",tol);
endif

%
% Check working for equation in alpha with reordering
%
eqn=zeros(7,n+5);
for m=6:(n+3),
  Tm=chebychevT(m);
  Tm=[zeros(1,columns(eqn)-columns(Tm)),Tm];
  eqn(1,:)=eqn(1,:)+ ...
           ((n^2)-((m-3)^2)) ...
           *alphaTvi(1+m-3)*Tm;
endfor
for m=5:(n+2),
  Tm=chebychevT(m);
  Tm=[zeros(1,columns(eqn)-columns(Tm)),Tm];
  eqn(2,:)=eqn(2,:)+ ...
           (2*(((m-2)*(m-3)*wp)+((m-2)*(m-3)*ws)+ ...
               ((((m-2)^2)+m-2-(3*(n^2)))*wm)+((m-2)*wq))) ...
           *alphaTvi(1+m-2)*Tm;
endfor
for m=4:(n+1),
  Tm=chebychevT(m);
  Tm=[zeros(1,columns(eqn)-columns(Tm)),Tm];
  eqn(3,:)=eqn(3,:)+ ...
           ((3*((n^2)-((m-1)^2))) ...
            +(4*((3*(n^2)*(wm^2))-(((m-1)^2)*wm*wp)- ...
                 (((m-1)^2)*wm*ws)-(((m-1)^2)*wp*ws)+ ...
                 ((m-1)*wp*ws)-((m-1)*wm*wq)))) ...
           *alphaTvi(1+m-1)*Tm;
endfor
for m=3:n,
  Tm=chebychevT(m);
  Tm=[zeros(1,columns(eqn)-columns(Tm)),Tm];
  eqn(4,:)=eqn(4,:)+ ...
           ((4*((m*(m-1)*wp)+(m*(m-1)*ws)+(((m^2)+m-(3*(n^2)))*wm)+(m*wq))) ...
            +(4*((m*wp)+(m*ws)-(m*wm)-(m*wq))) ...
            +(8*(-((n^2)*(wm^3))+((m^2)*wm*wp*ws)))) ...
           *alphaTvi(1+m)*Tm;
endfor
for m=2:(n-1),
  Tm=chebychevT(m);  
  Tm=[zeros(1,columns(eqn)-columns(Tm)),Tm];
  eqn(5,:)=eqn(5,:)+ ...
           ((3*((n^2)-((m+1)^2))) ...
            +(4*((3*(n^2)*(wm^2))-(((m+1)^2)*wm*wp) ...
                 -(((m+1)^2)*wm*ws)-(((m+1)^2)*wp*ws) ...
                 +((m+1)*wp*ws)-((m+1)*wm*wq))) ...
            +(8*(((m+1)*wm*wq)-((m+1)*wp*ws)))) ...
           *alphaTvi(1+m+1)*Tm;
endfor
for m=1:(n-2),
  Tm=chebychevT(m);  
  Tm=[zeros(1,columns(eqn)-columns(Tm)),Tm];
  eqn(6,:)=eqn(6,:)+ ...
           ((2*(((m+2)*(m+1)*wp)+((m+2)*(m+1)*ws)+ ...
                ((((m+2)^2)+(m+2)-(3*(n^2)))*wm)+((m+2)*wq))) ...
            +(4*(((m+2)*wp)+((m+2)*ws)-((m+2)*wm)-((m+2)*wq)))) ...
           *alphaTvi(1+(m+2))*Tm;
endfor
for m=0:(n-3),
  Tm=chebychevT(m);  
  Tm=[zeros(1,columns(eqn)-columns(Tm)),Tm];
  eqn(7,:)=eqn(7,:)+ ...
           ((n^2)-((m+3)^2)) ...
           *alphaTvi(1+m+3)*Tm;
endfor
eqn=eqn/8;
tol=1e-10;
if sum(abs(sum(eqn02+eqn,1))) > tol
  error("sum(abs(sum(eqn02+eqn,1))) > %g",tol);
endif

%
% Check working for equation in alpha with reordering and simplifications
%
eqn=zeros(7,n+5);
for m=6:(n+3),
  Tm=chebychevT(m);
  Tm=[zeros(1,columns(eqn)-columns(Tm)),Tm];
  eqn(1,:)=eqn(1,:)+ ...
           ((n^2)-((m-3)^2)) ...
           *alphaTvi(1+m-3)*Tm;
endfor
for m=5:(n+2),
  Tm=chebychevT(m);
  Tm=[zeros(1,columns(eqn)-columns(Tm)),Tm];
  eqn(2,:)=eqn(2,:)+ ...
           (2*(((m-2)*(m-3)*wp)+((m-2)*(m-3)*ws)+ ...
               ((((m-2)*(m-1))-(3*(n^2)))*wm)+((m-2)*wq))) ...
           *alphaTvi(1+m-2)*Tm;
endfor
for m=4:(n+1),
  Tm=chebychevT(m);
  Tm=[zeros(1,columns(eqn)-columns(Tm)),Tm];
  eqn(3,:)=eqn(3,:)+ ...
           ((3*((n^2)-((m-1)^2))) ...
            +(4*((3*(n^2)*(wm^2))-(((m-1)^2)*wm*wp) ...
                 -(((m-1)^2)*wm*ws)-(((m-1)*(m-2))*wp*ws)-((m-1)*wm*wq)))) ...
           *alphaTvi(1+m-1)*Tm;
endfor
for m=3:n,
  Tm=chebychevT(m);
  Tm=[zeros(1,columns(eqn)-columns(Tm)),Tm];
  eqn(4,:)=eqn(4,:)+ ...
           ((4*(((m^2)*wp)+((m^2)*ws)+(((m^2)-(3*(n^2)))*wm))) ...
            +(8*(-((n^2)*(wm^3))+((m^2)*wm*wp*ws)))) ...
           *alphaTvi(1+m)*Tm;
endfor
for m=2:(n-1),
  Tm=chebychevT(m);  
  Tm=[zeros(1,columns(eqn)-columns(Tm)),Tm];
  eqn(5,:)=eqn(5,:)+ ...
           ((3*((n^2)-((m+1)^2))) ...
            +(4*((3*(n^2)*(wm^2))-(((m+1)^2)*wm*wp) ...
                 -(((m+1)^2)*wm*ws)-(((m+1)*(m+2))*wp*ws) ...
                 +((m+1)*wm*wq)))) ...
           *alphaTvi(1+m+1)*Tm;
endfor
for m=1:(n-2),
  Tm=chebychevT(m);  
  Tm=[zeros(1,columns(eqn)-columns(Tm)),Tm];
  eqn(6,:)=eqn(6,:)+ ...
           (2*(((m+2)*(m+3)*wp)+((m+2)*(m+3)*ws)+ ...
               ((((m+2)*(m+1))-(3*(n^2)))*wm)-((m+2)*wq))) ...
           *alphaTvi(1+(m+2))*Tm;
endfor
for m=0:(n-3),
  Tm=chebychevT(m);  
  Tm=[zeros(1,columns(eqn)-columns(Tm)),Tm];
  eqn(7,:)=eqn(7,:)+ ...
           ((n^2)-((m+3)^2)) ...
           *alphaTvi(1+m+3)*Tm;
endfor
eqn=eqn/8;
tol=1e-10;
if sum(abs(sum(eqn02+eqn,1))) > tol
  error("sum(abs(sum(eqn02+eqn,1))) > %g",tol);
endif

%
% Check working for Table V.
%
alpha=zeros(1,1+n+5);
alpha(1+n)=1;
c=zeros(7,1);
for m=n+2:-1:3,
  c(7)=(n^2)-((m-3)^2);
  c(6)=(2*(((m-2)*(m-3)*wp)+((m-2)*(m-3)*ws)+ ...
               ((((m-2)*(m-1))-(3*(n^2)))*wm)+((m-2)*wq)));
  c(5)=((3*((n^2)-((m-1)^2))) ...
            +(4*((3*(n^2)*(wm^2))-(((m-1)^2)*wm*wp) ...
                 -(((m-1)^2)*wm*ws)-(((m-1)*(m-2))*wp*ws)-((m-1)*wm*wq))));
  c(4)=((4*(((m^2)*wp)+((m^2)*ws)+(((m^2)-(3*(n^2)))*wm))) ...
            +(8*(-((n^2)*(wm^3))+((m^2)*wm*wp*ws))));
  c(3)=((3*((n^2)-((m+1)^2))) ...
            +(4*((3*(n^2)*(wm^2))-(((m+1)^2)*wm*wp) ...
                 -(((m+1)^2)*wm*ws)-(((m+1)*(m+2))*wp*ws) ...
                 +((m+1)*wm*wq))));
  c(2)=(2*(((m+2)*(m+3)*wp)+((m+2)*(m+3)*ws)+ ...
               ((((m+2)*(m+1))-(3*(n^2)))*wm)-((m+2)*wq)));
  c(1)=(n^2)-((m+3)^2);

  alpha(1+m-3)=-alpha((1+m+3):-1:(1+m-2))*c(1:6)/c(7);
endfor

s=sum(alpha)-(alpha(1+0)/2);
a(1+0)=((-1)^p)*alpha(1+0)/(2*s);
a(1+(1:n))=((-1)^p)*alpha(1+(1:n))/s;
tol=1e-12;
if max(abs(alphaTvi-a))>tol
  error("max(abs(alphaTvi-a))>%g",tol);
endif
print_polynomial(a,sprintf("a_%d_%d",p,q),...
                 sprintf("%s_a_%d_%d_coef.m",strf,p,q));

% Check with zolotarev_vlcek_unbehauen.m
azvu=zolotarev_vlcek_unbehauen(p,q,k);
if max(abs(a-azvu))>eps
  error("max(abs(a-azvu))>eps");
endif

Zp3q6=zeros(1,n+1);
for m=0:n,
  Tm=chebychevT(m);
  Tm=fliplr(Tm);
  Tm=[Tm,zeros(1,columns(Zp3q6)-columns(Tm))];
  Zp3q6=Zp3q6+(a(1+m)*Tm);
endfor
print_polynomial(Zp3q6,sprintf("Z_%d_%d",p,q),...
                 sprintf("%s_Z_%d_%d_coef.m",strf,p,q));

w=(-1000:1:1000)/1000;
Z=polyval(fliplr(Zp3q6),w);
plot(w,Z);
strt= ...
  sprintf("Zolotarev function (Vlcek and Unbehauen) : p=%d,q=%d,k=%6.4f",p,q,k);
title(strt);
ylabel(sprintf("$Z_{%d,%d}(u,%7.5f)$",p,q,k));
xlabel("w");
grid("on");
print(sprintf("%s_Z_%d_%d",strf,p,q),"-dpdflatex");
close

% Done
diary off
movefile zolotarev_vlcek_unbehauen_table_v_test.diary.tmp ...
         zolotarev_vlcek_unbehauen_table_v_test.diary;
