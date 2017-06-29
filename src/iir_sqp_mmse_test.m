% iir_sqp_mmse_test.m
% Copyright (C) 2017 Robert G. Jenssen

test_common;

unlink("iir_sqp_mmse_test.diary");
unlink("iir_sqp_mmse_test.diary.tmp");
diary iir_sqp_mmse_test.diary.tmp

format compact

verbose=true
tol=1e-4
maxiter=2000

% Bandpass filter specification
% Filter specifications (frequencies are normalised to sample rate)
fapl=0.1;fapu=0.2;fasl=0.08;fasu=0.22;Wasl=1;Wap=1;Wasu=1;
ftpl=0.08;ftpu=0.22;tp=8;Wtp=0.05;

% Initial filter
U=0;V=0;M=16;Q=8;R=2;
N=U+V+M+Q+1;
x0 = [  0.02122 ...
        1.03386   0.97126   0.98346  -0.95764 ...
        0.97619   0.98736   0.99314   0.99314 ...
        0.00000   1.75442   1.49714   2.76167 ...
        2.05149   3.87481   3.14153   3.14179 ...
        0.73872   0.59932   0.59470   0.55392 ...
        0.86661   1.41964   3.49747   2.19863 ]';

% Frequency points
n=1000;

% Coefficient constraints
dmax=0.05;
[xl,xu]=xConstraints(U,V,M,Q);

% Amplitude constraints
wa=(0:(n-1))'*pi/n;
nasl=ceil(n*fasl/0.5)+1;
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
Ad=[zeros(napl-1,1);ones(napu-napl+1,1);zeros(n-napu,1)];
Adu=[];
Adl=[];
Wa=[Wasl*ones(nasl,1);
    zeros(napl-nasl-1,1);
    Wap*ones(napu-napl+1,1);
    zeros(nasu-napu-1,1);
    Wasu*ones(n-nasu+1,1)];
% Check
wa([nasl,napl,napu,nasu])*0.5/pi
Wa([nasl,nasl+1,napl-1,napl,napu,napu+1,nasu-1,nasu])

% Amplitude stop-band constraints
ws=[];
Sd=[];
Sdu=[];
Sdl=[];
Ws=[];

% Group delay constraints
wt=wa(napl:napu);
ntp=length(wt);
Td=tp*ones(ntp,1);
Tdu=[];
Tdl=[];
Wt=Wtp*ones(ntp,1);

% Phase constraints
wp=[];
Pd=[];
Pdu=[];
Pdl=[];
Wp=[];

% Initialise strings
strM=sprintf("%%s:fapl=%g,fapu=%g,Wasl=%%g,Wap=%%g,Wasu=%%g,tp=%d,Wtp=%%g",...
             fapl,fapu,tp);
strd=sprintf("iir_sqp_mmse_test_initial_%%s");
strM0=sprintf(strM,"x0",Wasl,Wap,Wasu,Wtp);

% Plot response of the initial filter
showZPplot(x0,U,V,M,Q,R,strM0);
print(sprintf(strd,"x0pz"),"-dpdflatex");
close
showResponse(x0,U,V,M,Q,R,strM0);
print(sprintf(strd,"x0"),"-dpdflatex");
close
showResponsePassBands(fapl,fapu,-3,3,x0,U,V,M,Q,R,strM0);
print(sprintf(strd,"x0pass"),"-dpdflatex");
close

% MMSE pass
[x1,E,sqp_iter,func_iter,feasible] = ...
  iir_sqp_mmse([],x0,xu,xl,dmax,U,V,M,Q,R, ...
               wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
               wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
               maxiter,tol,verbose);
if feasible == 0 
  error("iir_sqp_mmse_test, x1 infeasible");
endif
strd=sprintf("iir_sqp_mmse_test_mmse_%%s");
strM1=sprintf(strM,"x1",Wasl,Wap,Wasu,Wtp);
showZPplot(x1,U,V,M,Q,R,strM1);
print(sprintf(strd,"x1pz"),"-dpdflatex");
close
showResponse(x1,U,V,M,Q,R,strM1);
print(sprintf(strd,"x1"),"-dpdflatex");
close
showResponsePassBands(fapl,fapu,-3,3,x1,U,V,M,Q,R,strM1);
print(sprintf(strd,"x1pass"),"-dpdflatex");
close

print_polynomial(x1,"x1=","iir_sqp_mmse_test_x1_coef.m");
format short e
x1'
[N1,D1]=x2tf(x1,U,V,M,Q,R);
N1'
D1'

% MMSE pass using the Octave sqp() function
%{
[x1octave,E,sqp_iter,func_iter,feasible] = ...
  iir_sqp_octave(x0,U,V,M,Q,R,wa,Ad,Wa,wt,Td,Wt,maxiter,tol,verbose)
if feasible == 0 
  error("iir_sqp_mmse_test, x1octave infeasible");
endif
strd=sprintf("iir_sqp_mmse_test_octave_%%s");
strM1=sprintf(strM,"x1",Wasl,Wap,Wasu,Wtp);
showZPplot(x1octave,U,V,M,Q,R,strM1);
print(sprintf(strd,"x1pz"),"-dpdflatex");
close
showResponse(x1octave,U,V,M,Q,R,strM1);
print(sprintf(strd,"x1"),"-dpdflatex");
close
showResponsePassBands(fapl,fapu,x1octave,U,V,M,Q,R,strM1);
print(sprintf(strd,"x1pass"),"-dpdflatex");
close
x1octave'
%}

% Compare with cl2bp. 
% There are N coefficients in the IIR filter. There will be Cfir+1
% distinct coefficients in the FIR filter and the delay of the FIR
% filter will be a constant Cfir samples.
wl=fapl*2*pi;
wu=fapu*2*pi;
up = [0.03, 1, 0.03];
lo = [-0.03, 0.98, -0.03];
N
Cfir=ceil(N/2)
nfir=2048;
b = cl2bp(Cfir,wl,wu,up,lo,nfir);
length(b)
[xfir,Ufir,Vfir,Mfir,Qfir]=tf2x(b,1,tol);
Rfir=1;
strd=sprintf("iir_sqp_mmse_test_cl2bp_%%s");
strMfir=sprintf("xfir:length=%d,fapl=%g,fapu=%g,stop band ripple=-30dB", ...
                length(b),fapl,fapu);
showResponse(xfir,Ufir,Vfir,Mfir,Qfir,Rfir,strMfir);
print(sprintf(strd,"xfir"),"-dpdflatex");
close
showZPplot(xfir,Ufir,Vfir,Mfir,Qfir,Rfir,strMfir);
print(sprintf(strd,"xfirpz"),"-dpdflatex");
close

% Done 
save iir_sqp_mmse_test.mat U V M Q R N fapl fapu ftpl ftpu tp ...
     x1 b Cfir wl wu up lo nfir xfir Ufir Vfir Mfir Qfir 

diary off
movefile iir_sqp_mmse_test.diary.tmp iir_sqp_mmse_test.diary;
