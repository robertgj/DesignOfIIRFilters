% iir_sqp_mmse_tarczynski_ex2_test.m
% Copyright (C) 2017-2025 Robert G. Jenssen
%
% Design a filter implementing the response of Example 2 of Tarczynski et al. 
% See "A WISE Method for Designing IIR Filters", A. Tarczynski et al.,
% IEEE Transactions on Signal Processing, Vol. 49, No. 7, pp. 1421-1432

test_common;

strf="iir_sqp_mmse_tarczynski_ex2_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

ftol=1e-2;
ctol=ftol
maxiter=2000;
verbose=true;

% Filter specification (fs=1)
fl=0.2;fu=0.3;
al=1;Wal=1;Wat=0;au=0.5;Wau=1;
tl=14.3;Wtl=0.1;Wtt=0;tu=20;Wtu=0.1;

% From Tarczynski standalone
%{
Ux=2,Vx=2,Mx=22,Qx=0,Rx=2
x = [   0.0055312083, ...
       -2.5172947901,  -1.3160771736, ...
       -0.9079549734,  -0.2702665552, ...
        1.3053633956,   1.2801339760,   1.2456925229,   1.3543680148, ... 
        1.3403320932,   1.3017549399,   1.1940407510,   1.0576998890, ... 
        0.8556848206,   0.6295806050,   0.5427391704, ...
        2.8130835406,   2.4936279734,   2.1815983114,   0.2206287582, ... 
        0.6636852829,   1.1146346726,   1.8756695277,   1.6003203081, ... 
        1.5609084989,   1.0945345539,   0.3907008473 ]';
%}

% "Butchered" version of standalone x0:
U=3;V=2;M=20;Q=0;R=2;
x0 = [  0.04 ...
       -1.1 0.36173 0.36173 ...
       -0.8842894  -0.1495357   ...
        1.3091281   1.2794257   1.3538295   1.3386509   1.3011204 ...
        1.2418447   1.1899991   1.0533570   0.8306859   0.6034298 ...
        2.8187821   2.5029369   0.2204128   0.6631062   1.1173639 ...
        2.1870677   1.8790233   1.6013209   1.5328472   0.9197805 ]';

% Coefficient constraints
[xl,xu]=xConstraints(U,V,M,Q);
dmax=0.01;

% Frequency points
n=500;

% Amplitude pass-band constraints
wa=pi*(0:(n-1))'/n;
% Transition band
bw=round(0.2*n/0.5);
bt=n-(2*bw);
Ad=[al*ones(n/2,1);au*ones(n/2,1)];
Adu=[];
Adl=[];
Wa=[Wal*ones(bw,1); Wat*ones(bt,1); Wau*ones(bw,1)];

% Amplitude stop-band constraints
ws=[];
Sd=[];
Sdu=[];
Sdl=[];
Ws=[];

% Group delay constraints
wt=wa;
Td=[tl*ones(n/2,1);tu*ones(n/2,1)];
Tdu=[];
Tdl=[];
Wt=[Wtl*ones(bw,1); Wtt*ones(bt,1); Wtu*ones(bw,1)];

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% SQP MMSE
[x1,E,sqp_iter,func_iter,feasible] = ...
  iir_sqp_mmse([],x0,xu,xl,dmax,U,V,M,Q,R, ...
               wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
               wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
               maxiter,ftol,ctol,verbose);
if feasible == 0 
  error("Tarczynski mmse x1 infeasible");
endif

% Response plot
A1=iirA(wa,x1,U,V,M,Q,R);
T1=iirT(wt,x1,U,V,M,Q,R);
subplot(211);
plot(wa*0.5/pi,20*log10(abs(A1)));
ylabel("Amplitude(dB)");
title(sprintf(["Tarczynski et al. Example 2 response : ", ...
 "U=%d,V=%d,M=%d,Q=%d,R=%d"],U,V,M,Q,R));
axis([0 0.5 -8 2]);
grid("on");
subplot(212);
plot(wt*0.5/pi,T1);
ylabel("Delay(samples)");
xlabel("Frequency");
axis([0 0.5 10 25]);
grid("on");
zticks([]);
print(strcat(strf,"_x1"),"-dpdflatex");
close

% Passband details plot
subplot(221);
plot(wa*0.5/pi,20*log10(abs(A1)));
ylabel("Amplitude(dB)");
axis([0 0.2 -0.2 0.2]);
grid("on");
subplot(222);
plot(wa*0.5/pi,20*log10(abs(A1)));
axis([0.3 0.5 -6.2 -5.8]);
grid("on");
subplot(223);
plot(wt*0.5/pi,T1);
xlabel("Frequency");
ylabel("Delay(samples)");
axis([0 0.2 14.2 14.4]);
grid("on");
subplot(224);
plot(wt*0.5/pi,T1);
xlabel("Frequency");
axis([0.3 0.5 19.9 20.1]);
grid("on");
zticks([]);
print(strcat(strf,"_x1pass"),"-dpdflatex");
close

% Z-plane plot
showZPplot(x1,U,V,M,Q,R,sprintf ...
("Tarczynski et al. Example 2 pole-zero plot : U=%d,V=%d,M=%d,Q=%d,R=%d", ...
U,V,M,Q,R));
zticks([]);
print(strcat(strf,"_x1pz"),"-dpdflatex");
close

% Save results
print_pole_zero(x0,U,V,M,Q,R,"x0");
print_pole_zero(x0,U,V,M,Q,R,"x0",strcat(strf,"_x0_coef.m"));
print_pole_zero(x1,U,V,M,Q,R,"x1");
print_pole_zero(x1,U,V,M,Q,R,"x1",strcat(strf,"_x1_coef.m"));

[N1,D1]=x2tf(x1,U,V,M,Q,R);
print_polynomial(N1,"N1");
print_polynomial(N1,"N1",strcat(strf,"_N1_coef.m"));
print_polynomial(D1,"D1");
print_polynomial(D1,"D1",strcat(strf,"_D1_coef.m"));

% Done
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
