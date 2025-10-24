% iir_socp_mmse_test.m
% Copyright (C) 2024-2025 Robert G. Jenssen

test_common;

strf="iir_socp_mmse_test";

delete(strcat(strf,".diary"));
delete(strcat(strf,".diary.tmp"));
eval(sprintf("diary %s.diary.tmp",strf));

verbose=false
ftol=1e-3
ctol=ftol/10
maxiter=2000

% Bandpass filter specification
% Filter specifications (frequencies are normalised to sample rate)
fapl=0.1;fapu=0.2;dBap=1;Wap=1;
fasl=0.05;fasu=0.25;dBas=27;Wasl=5;Wat=0;Wasu=10;
ftpl=0.05;ftpu=0.25;tp=8;tpr=0.04;Wtp=0.01;
pd=2;pdr=0.02;Wpp=0.02;

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
[N0,D0]=x2tf(x0,U,V,M,Q,R);

% Frequency points
n=1000;
w=(0:(n-1))'*pi/n;

% Coefficient constraints
dmax=0.05;
[xl,xu]=xConstraints(U,V,M,Q);

% Amplitude constraints
napl=floor(n*fapl/0.5)+1;
napu=ceil(n*fapu/0.5)+1;
wa=w(napl:napu);
Ad=ones(size(wa));
Adu=(10^(dBap/20))*Ad;
Adl=(10^(-dBap/20))*Ad;
Wa=Wap*ones(size(wa));

% Amplitude stop-band constraints
nasl=ceil(n*fasl/0.5)+1;
nasu=floor(n*fasu/0.5)+1;
ws=w;
Sd=zeros(size(ws));
Sdu=(10^(-dBas/20))*ones(size(ws));
Sdl=zeros(size(ws));
Ws=[Wasl*ones(nasl,1); ...
    Wat*ones(napl-nasl-1,1); ...
    zeros(napu-napl+1,1); ...
    Wat*ones(nasu-napu-1,1); ...
    Wasu*ones(n-nasu+1,1)];
% Check
wschk= ...
  [nasl-1,nasl,nasl+1,napl-1,napl,napl+1,napu-1,napu,napu+1,nasu-1,nasu,nasu+1];
ws(wschk)'*0.5/pi
Ws(wschk)'

% Group delay constraints
wt=wa;
Td=tp*ones(size(wt));
Tdu=(tp+(tpr/2))*ones(size(wt));
Tdl=(tp-(tpr/2))*ones(size(wt));
Wt=Wtp*ones(size(wt));

% Phase constraints
nppl=floor(n*fapl/0.5)+1;
nppu=ceil(n*fapu/0.5)+1;
wp=wa;
Pd=(pd*pi)-(tp*wp);
Pdu=Pd+(pdr*pi/2);
Pdl=Pd-(pdr*pi/2);
Wp=Wpp*ones(size(wp));

% Plot response of the initial filter
str0=sprintf("Initial filter : fapl=%g,fapu=%g,Wasl=%g,Wasu=%g,tp=%d,Wtp=%g", ...
             fapl,fapu,Wasl,Wasu,tp,Wtp);
showZPplot(x0,U,V,M,Q,R,str0);
zticks([]);
print(strcat(strf,"_x0pz"),"-dpdflatex");
close
showResponse(x0,U,V,M,Q,R,str0);
zticks([]);
print(strcat(strf,"_x0"),"-dpdflatex");
close
showResponsePassBands(fapl,fapu,-3,3,x0,U,V,M,Q,R,str0);
zticks([]);
print(strcat(strf,"_x0pass"),"-dpdflatex");
close

% Initial constraints
printf("\n\nInitial constraints:\n\n");
vS=iir_slb_update_constraints(x0,U,V,M,Q,R,wa,Adu,Adl,Wa, ...
                              ws,Sdu,Sdl,Ws,wt,Tdu,Tdl,Wt, ...
                              wp,Pdu,Pdl,Wp,ctol);
[A0,gradA0]=iirA(wa,x0,U,V,M,Q,R);
[S0,gradS0]=iirA(ws,x0,U,V,M,Q,R);
[T0,gradT0]=iirT(wt,x0,U,V,M,Q,R);
[P0,gradP0]=iirP(wp,x0,U,V,M,Q,R);
iir_slb_show_constraints(vS,wa,A0,ws,S0,wt,T0,wp,P0);

% MMSE pass
feasible=0;
try
[x1,E,socp_iter,func_iter,feasible] = ...
  iir_socp_mmse(vS,x0,xu,xl,dmax,U,V,M,Q,R, ...
                wa,Ad,Adu,Adl,Wa,ws,Sd,Sdu,Sdl,Ws, ...
                wt,Td,Tdu,Tdl,Wt,wp,Pd,Pdu,Pdl,Wp, ...
                maxiter,ftol,ctol,verbose);
catch
  err=lasterror();
  for frame=1:length(err.stack)
    fprintf(stderr, ...
            "Called %s at %s : %d\n", ...
            err.stack(frame).name,err.stack(frame).file,err.stack(frame).line);
  endfor
  error("\nCaught %s!\n",lasterr())
end_try_catch
if feasible == 0
  error("MMSE : x1 infeasible");
endif

print_polynomial(x1,"x1",strcat(strf,"_x1_coef.m"));
[N1,D1]=x2tf(x1,U,V,M,Q,R);

[A1,gradA1]=iirA(wa,x1,U,V,M,Q,R);
[S1,gradS1]=iirA(ws,x1,U,V,M,Q,R);
[T1,gradT1]=iirT(wt,x1,U,V,M,Q,R);
[P1,gradP1]=iirP(wp,x1,U,V,M,Q,R);
iir_slb_show_constraints(vS,wa,A1,ws,S1,wt,T1,wp,P1);

% Plot MMSE
strM=sprintf("MMSE filter : fapl=%g,fapu=%g,Wasl=%g,Wasu=%g,tp=%d,Wtp=%g", ...
             fapl,fapu,Wasl,Wasu,tp,Wtp);
showZPplot(x1,U,V,M,Q,R,strM);
zticks([]);
print(strcat(strf,"_x1pz"),"-dpdflatex");
close
showResponse(x1,U,V,M,Q,R,strM);
subplot(211)
hold;
plot(wa(vS.al)*0.5/pi,20*log10(A1(vS.al)),"x", ...
     wa(vS.au)*0.5/pi,20*log10(A1(vS.au)),"+", ...
     ws(vS.sl)*0.5/pi,20*log10(S1(vS.sl)),"x", ...
     ws(vS.su)*0.5/pi,20*log10(S1(vS.su)),"+")
subplot(212)
hold;
plot(wt(vS.tl)*0.5/pi,T1(vS.tl),"x",wt(vS.tu)*0.5/pi,T1(vS.tu),"+");
zticks([]);
print(strcat(strf,"_x1"),"-dpdflatex");
close
% Plot passbands
showResponsePassBands(fapl,fapu,-3,3,x1,U,V,M,Q,R,strM);
subplot(211)
hold;
plot(wa(vS.al)*0.5/pi,20*log10(A1(vS.al)),"x", ...
     wa(vS.au)*0.5/pi,20*log10(A1(vS.au)),"+", ...
     ws(vS.sl)*0.5/pi,20*log10(S1(vS.sl)),"x", ...
     ws(vS.su)*0.5/pi,20*log10(S1(vS.su)),"+")
subplot(212)
hold;
plot(wt(vS.tl)*0.5/pi,T1(vS.tl),"x",wt(vS.tu)*0.5/pi,T1(vS.tu),"+");
zticks([]);
print(strcat(strf,"_x1pass"),"-dpdflatex");
close
% Plot phase
Pp=(unwrap(P1)+(wp*tp))/pi;
plot(wp*0.5/pi,Pp, ...
     wp(vS.pl)*0.5/pi,Pp(vS.pl),"x", ...
     wp(vS.pu)*0.5/pi,Pp(vS.pu),"+");
grid("on");
xlabel("Frequency")
ylabel("Phase(rad./$\\pi$)");
zticks([]);
print(strcat(strf,"_x1phase"),"-dpdflatex");
close

% Compare with cl2bp. 
% There are N coefficients in the IIR filter. There will be Cfir+1
% distinct coefficients in the FIR filter and the delay of the FIR
% filter will be a constant Cfir samples.
wl=fapl*2*pi;
wu=fapu*2*pi;
up = [0.03, 1, 0.03];
lo = [-0.03, 0.98, -0.03];
Cfir=ceil(N/2);
nfir=2048;
b = cl2bp(Cfir,wl,wu,up,lo,nfir);
[xfir,Ufir,Vfir,Mfir,Qfir]=tf2x(b,1,ftol);
Rfir=1;
strMfir=sprintf("xfir:length=%d,fapl=%g,fapu=%g,stop band ripple=-30dB", ...
                length(b),fapl,fapu);
showResponse(xfir,Ufir,Vfir,Mfir,Qfir,Rfir,strMfir);
zticks([]);
print(strcat(strf,"_cl2bp_xfir"),"-dpdflatex");
close
showZPplot(xfir,Ufir,Vfir,Mfir,Qfir,Rfir,strMfir);
zticks([]);
print(strcat(strf,"_cl2bp_xfirpz"),"-dpdflatex");
close

% Save results
eval(sprintf(["save %s.mat ftol ctol U V M Q R N fapl fapu dBap Wap ", ...
 "fasl fasu dBas Wasl Wasu ftpl ftpu tp tpr pd pdr x1 N1 D1 ", ...
 "b Cfir wl wu up lo nfir xfir Ufir Vfir Mfir Qfir"],strf));

% Done 
diary off
movefile(strcat(strf,".diary.tmp"),strcat(strf,".diary"));
