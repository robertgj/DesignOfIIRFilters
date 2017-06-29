% xInitLP_test.m

test_common;

unlink("xInitLP_test.diary");
diary xInitLP_test.diary

global fixNaN checkNaN checkInf
checkNaN=true
fixNaN=true
checkInf=true

%% Initialise
Q0=6
R=1
fap=0.10
dbap=0.5
dbas=40
tol=1e-3
L=1024;
w=(0:(L-1))*pi/L;
makeOdd=false

%% Define the filter
[x0,U,V,M,Q]=xInitLP(makeOdd,Q0,R,fap,dbap,dbas,tol)
figure(1);
showResponse(x0,U,V,M,Q,R,tol,"makeOdd=false,R=1 response");

%% Show results
[b,a]=x2tf(x0,U,V,M,Q,R)
[x0_test,U_test,V_test,M_test,Q_test] = tf2x(b,a,tol)
if max(abs(x0-x0_test)) > 1e-9
   error("tf2x failed");
endif

%% Compare
A=iirA(w,x0,U,V,M,Q,R);
T=iirT(w,x0,U,V,M,Q,R);
[h,wf]=freqz(b,a,L);
meanDiffA=mean(abs(abs(h)-A))
if meanDiffA>tol
  error("R=1 mean(abs(abs(h)-A))>tol");
endif
[t,wg]=grpdelay(b(:)',a(:)',L);
meanDiffTp=mean(abs(t)-T)
if meanDiffTp>tol
  error("R=1 mean(abs(tp-Tp))>tol");
endif
figure(2);
subplot(211),title("makeOdd=false,R=1 difference");
subplot(211),plot(wf*0.5/pi,abs(h)-A),axis([0 0.5]);
subplot(212),plot(wg*0.5/pi,t-T),axis([0 0.5]);

%% Repeat with R!=1
Q0=10
R=3
fap=0.10
dbap=0.5
dbas=40
tol=1e-3
makeodd=true

%% Define the filter
[x0,U,V,M,Q]=xInitLP(makeOdd,Q0,R,fap,dbap,dbas,tol);
figure(3)
showResponse(x0,U,V,M,Q,R,tol,"makeOdd=true,R=3");

%% Compare
A=iirA(w,x0,U,V,M,Q,R);
T=iirT(w,x0,U,V,M,Q,R);
[b,a]=x2tf(x0,U,V,M,Q,R);
[h,wf]=freqz(b,a,L);
meanDiffA=mean(abs(abs(h)-A))
if meanDiffA>tol
  error("R=3 mean(abs(abs(h)-A))>tol");
endif
[t,wg]=grpdelay(b(:)',a(:)',L);
meanDiffTp=mean(abs(t(1:(fap*L))-T(1:(fap*L))))
if meanDiffTp>tol
  error("R=3 mean(abs(tp-Tp))>tol");
endif
figure(4);
subplot(211),title("makeOdd=true,R=3");
subplot(211),plot(w*0.5/pi,abs(h)-A),axis([0 0.5]);
subplot(212),plot(w*0.5/pi,t-T),axis([0 0.5 -1 1]);

diary off
